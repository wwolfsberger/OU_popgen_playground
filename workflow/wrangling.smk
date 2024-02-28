rule download_1kgdata:
    output:
        "1kdown/all_hg38.pgen.zst",
        "1kdown/all_hg38_rs.pvar.zst",
        "1kdown/all_hg38.psam"
    shell:
        """
        mkdir -p 1kdown
        wget -O 1kdown/all_hg38.pgen.zst "https://www.dropbox.com/s/j72j6uciq5zuzii/all_hg38.pgen.zst?dl=1"
        wget -O 1kdown/all_hg38_rs.pvar.zst "https://www.dropbox.com/scl/fi/fn0bcm5oseyuawxfvkcpb/all_hg38_rs.pvar.zst?rlkey=przncwb78rhz4g4ukovocdxaz&dl=1"
        wget -O 1kdown/hg38_corrected.psam "https://www.dropbox.com/s/2e87z6nc4qexjjm/hg38_corrected.psam?dl=1"
        mv 1kdown/hg38_corrected.psam 1kdown/all_hg38.psam
        """

rule unpack:
    input:
        "1kdown/all_hg38.pgen.zst",
        "1kdown/all_hg38_rs.pvar.zst"
    output:
        "1kdown/all_hg38.pgen",
        "1kdown/all_hg38.pvar",
    shell:
        """
        plink2 --zst-decompress 1kdown/all_hg38.pgen.zst > 1kdown/all_hg38.pgen
        plink2 --zst-decompress 1kdown/all_hg38_rs.pvar.zst > 1kdown/all_hg38.pvar

        """
        # rm *.zst


rule slicepop:
    input:
        pgen = "1kdown/all_hg38.pgen",
        pvar = "1kdown/all_hg38.pvar"
    output:
        vcf_gz = "1kdown/{population_id}.vcf.gz"
    params:
        population_id = "{population_id}"
    shell:
        """
        grep "{params.population_id}" 1kdown/all_hg38.psam | cut -f 1 > 1kdown/{params.population_id}.pop
        plink2 --pfile 1kdown/all_hg38 --allow-extra-chr --keep 1kdown/{params.population_id}.pop --chr 1-22, xy --mac 1 --recode vcf --out 1kdown/{params.population_id}
        bgzip 1kdown/{params.population_id}.vcf
        """



