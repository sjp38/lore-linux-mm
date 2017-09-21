Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 58B086B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 07:58:10 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g18so9589839itg.1
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 04:58:10 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a89si1021946oic.126.2017.09.21.04.58.09
        for <linux-mm@kvack.org>;
        Thu, 21 Sep 2017 04:58:09 -0700 (PDT)
Subject: Re: [PATCH 3/4] iommu/arm-smmu-v3: Use NUMA memory allocations for
 stream tables and comamnd queues
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
 <20170921085922.11659-4-ganapatrao.kulkarni@cavium.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <db28d6ff-77e5-ed59-c1b8-57c917564a68@arm.com>
Date: Thu, 21 Sep 2017 12:58:04 +0100
MIME-Version: 1.0
In-Reply-To: <20170921085922.11659-4-ganapatrao.kulkarni@cavium.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Will.Deacon@arm.com, lorenzo.pieralisi@arm.com, hanjun.guo@linaro.org, joro@8bytes.org, vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com, gklkml16@gmail.com

[+Christoph and Marek]

On 21/09/17 09:59, Ganapatrao Kulkarni wrote:
> Introduce smmu_alloc_coherent and smmu_free_coherent functions to
> allocate/free dma coherent memory from NUMA node associated with SMMU.
> Replace all calls of dmam_alloc_coherent with smmu_alloc_coherent
> for SMMU stream tables and command queues.

This doesn't work - not only do you lose the 'managed' aspect and risk
leaking various tables on probe failure or device removal, but more
importantly, unless you add DMA syncs around all the CPU accesses to the
tables, you lose the critical 'coherent' aspect, and that's a horribly
invasive change that I really don't want to make.

Christoph, Marek; how reasonable do you think it is to expect
dma_alloc_coherent() to be inherently NUMA-aware on NUMA-capable
systems? SWIOTLB looks fairly straightforward to fix up (for the simple
allocation case; I'm not sure it's even worth it for bounce-buffering),
but the likes of CMA might be a little trickier...

Robin.

> Signed-off-by: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
> ---
>  drivers/iommu/arm-smmu-v3.c | 57 ++++++++++++++++++++++++++++++++++++++++-----
>  1 file changed, 51 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
> index e67ba6c..bc4ba1f 100644
> --- a/drivers/iommu/arm-smmu-v3.c
> +++ b/drivers/iommu/arm-smmu-v3.c
> @@ -1158,6 +1158,50 @@ static void arm_smmu_init_bypass_stes(u64 *strtab, unsigned int nent)
>  	}
>  }
>  
> +static void *smmu_alloc_coherent(struct arm_smmu_device *smmu, size_t size,
> +		dma_addr_t *dma_handle,	gfp_t gfp)
> +{
> +	struct device *dev = smmu->dev;
> +	void *pages;
> +	dma_addr_t dma;
> +	int numa_node = dev_to_node(dev);
> +
> +	pages = alloc_pages_exact_nid(numa_node, size, gfp | __GFP_ZERO);
> +	if (!pages)
> +		return NULL;
> +
> +	if (!(smmu->features & ARM_SMMU_FEAT_COHERENCY)) {
> +		dma = dma_map_single(dev, pages, size, DMA_TO_DEVICE);
> +		if (dma_mapping_error(dev, dma))
> +			goto out_free;
> +		/*
> +		 * We depend on the SMMU being able to work with any physical
> +		 * address directly, so if the DMA layer suggests otherwise by
> +		 * translating or truncating them, that bodes very badly...
> +		 */
> +		if (dma != virt_to_phys(pages))
> +			goto out_unmap;
> +	}
> +
> +	*dma_handle = (dma_addr_t)virt_to_phys(pages);
> +	return pages;
> +
> +out_unmap:
> +	dev_err(dev, "Cannot accommodate DMA translation for IOMMU page tables\n");
> +	dma_unmap_single(dev, dma, size, DMA_TO_DEVICE);
> +out_free:
> +	free_pages_exact(pages, size);
> +	return NULL;
> +}
> +
> +static void smmu_free_coherent(struct arm_smmu_device *smmu, size_t size,
> +		void *pages, dma_addr_t dma_handle)
> +{
> +	if (!(smmu->features & ARM_SMMU_FEAT_COHERENCY))
> +		dma_unmap_single(smmu->dev, dma_handle, size, DMA_TO_DEVICE);
> +	free_pages_exact(pages, size);
> +}
> +
>  static int arm_smmu_init_l2_strtab(struct arm_smmu_device *smmu, u32 sid)
>  {
>  	size_t size;
> @@ -1172,7 +1216,7 @@ static int arm_smmu_init_l2_strtab(struct arm_smmu_device *smmu, u32 sid)
>  	strtab = &cfg->strtab[(sid >> STRTAB_SPLIT) * STRTAB_L1_DESC_DWORDS];
>  
>  	desc->span = STRTAB_SPLIT + 1;
> -	desc->l2ptr = dmam_alloc_coherent(smmu->dev, size, &desc->l2ptr_dma,
> +	desc->l2ptr = smmu_alloc_coherent(smmu, size, &desc->l2ptr_dma,
>  					  GFP_KERNEL | __GFP_ZERO);
>  	if (!desc->l2ptr) {
>  		dev_err(smmu->dev,
> @@ -1487,7 +1531,7 @@ static void arm_smmu_domain_free(struct iommu_domain *domain)
>  		struct arm_smmu_s1_cfg *cfg = &smmu_domain->s1_cfg;
>  
>  		if (cfg->cdptr) {
> -			dmam_free_coherent(smmu_domain->smmu->dev,
> +			smmu_free_coherent(smmu,
>  					   CTXDESC_CD_DWORDS << 3,
>  					   cfg->cdptr,
>  					   cfg->cdptr_dma);
> @@ -1515,7 +1559,7 @@ static int arm_smmu_domain_finalise_s1(struct arm_smmu_domain *smmu_domain,
>  	if (asid < 0)
>  		return asid;
>  
> -	cfg->cdptr = dmam_alloc_coherent(smmu->dev, CTXDESC_CD_DWORDS << 3,
> +	cfg->cdptr = smmu_alloc_coherent(smmu, CTXDESC_CD_DWORDS << 3,
>  					 &cfg->cdptr_dma,
>  					 GFP_KERNEL | __GFP_ZERO);
>  	if (!cfg->cdptr) {
> @@ -1984,7 +2028,7 @@ static int arm_smmu_init_one_queue(struct arm_smmu_device *smmu,
>  {
>  	size_t qsz = ((1 << q->max_n_shift) * dwords) << 3;
>  
> -	q->base = dmam_alloc_coherent(smmu->dev, qsz, &q->base_dma, GFP_KERNEL);
> +	q->base = smmu_alloc_coherent(smmu, qsz, &q->base_dma, GFP_KERNEL);
>  	if (!q->base) {
>  		dev_err(smmu->dev, "failed to allocate queue (0x%zx bytes)\n",
>  			qsz);
> @@ -2069,7 +2113,7 @@ static int arm_smmu_init_strtab_2lvl(struct arm_smmu_device *smmu)
>  			 size, smmu->sid_bits);
>  
>  	l1size = cfg->num_l1_ents * (STRTAB_L1_DESC_DWORDS << 3);
> -	strtab = dmam_alloc_coherent(smmu->dev, l1size, &cfg->strtab_dma,
> +	strtab = smmu_alloc_coherent(smmu, l1size, &cfg->strtab_dma,
>  				     GFP_KERNEL | __GFP_ZERO);
>  	if (!strtab) {
>  		dev_err(smmu->dev,
> @@ -2097,8 +2141,9 @@ static int arm_smmu_init_strtab_linear(struct arm_smmu_device *smmu)
>  	u32 size;
>  	struct arm_smmu_strtab_cfg *cfg = &smmu->strtab_cfg;
>  
> +
>  	size = (1 << smmu->sid_bits) * (STRTAB_STE_DWORDS << 3);
> -	strtab = dmam_alloc_coherent(smmu->dev, size, &cfg->strtab_dma,
> +	strtab = smmu_alloc_coherent(smmu, size, &cfg->strtab_dma,
>  				     GFP_KERNEL | __GFP_ZERO);
>  	if (!strtab) {
>  		dev_err(smmu->dev,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
