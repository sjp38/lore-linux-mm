Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 75E1C6B0271
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 05:00:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 188so10612974pgb.3
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 02:00:20 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0080.outbound.protection.outlook.com. [104.47.34.80])
        by mx.google.com with ESMTPS id t7si697852pgp.678.2017.09.21.02.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Sep 2017 02:00:19 -0700 (PDT)
From: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
Subject: [PATCH 3/4] iommu/arm-smmu-v3: Use NUMA memory allocations for stream tables and comamnd queues
Date: Thu, 21 Sep 2017 14:29:21 +0530
Message-Id: <20170921085922.11659-4-ganapatrao.kulkarni@cavium.com>
In-Reply-To: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Will.Deacon@arm.com, robin.murphy@arm.com, lorenzo.pieralisi@arm.com, hanjun.guo@linaro.org, joro@8bytes.org, vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com, gklkml16@gmail.com

Introduce smmu_alloc_coherent and smmu_free_coherent functions to
allocate/free dma coherent memory from NUMA node associated with SMMU.
Replace all calls of dmam_alloc_coherent with smmu_alloc_coherent
for SMMU stream tables and command queues.

Signed-off-by: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
---
 drivers/iommu/arm-smmu-v3.c | 57 ++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 51 insertions(+), 6 deletions(-)

diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
index e67ba6c..bc4ba1f 100644
--- a/drivers/iommu/arm-smmu-v3.c
+++ b/drivers/iommu/arm-smmu-v3.c
@@ -1158,6 +1158,50 @@ static void arm_smmu_init_bypass_stes(u64 *strtab, unsigned int nent)
 	}
 }
 
+static void *smmu_alloc_coherent(struct arm_smmu_device *smmu, size_t size,
+		dma_addr_t *dma_handle,	gfp_t gfp)
+{
+	struct device *dev = smmu->dev;
+	void *pages;
+	dma_addr_t dma;
+	int numa_node = dev_to_node(dev);
+
+	pages = alloc_pages_exact_nid(numa_node, size, gfp | __GFP_ZERO);
+	if (!pages)
+		return NULL;
+
+	if (!(smmu->features & ARM_SMMU_FEAT_COHERENCY)) {
+		dma = dma_map_single(dev, pages, size, DMA_TO_DEVICE);
+		if (dma_mapping_error(dev, dma))
+			goto out_free;
+		/*
+		 * We depend on the SMMU being able to work with any physical
+		 * address directly, so if the DMA layer suggests otherwise by
+		 * translating or truncating them, that bodes very badly...
+		 */
+		if (dma != virt_to_phys(pages))
+			goto out_unmap;
+	}
+
+	*dma_handle = (dma_addr_t)virt_to_phys(pages);
+	return pages;
+
+out_unmap:
+	dev_err(dev, "Cannot accommodate DMA translation for IOMMU page tables\n");
+	dma_unmap_single(dev, dma, size, DMA_TO_DEVICE);
+out_free:
+	free_pages_exact(pages, size);
+	return NULL;
+}
+
+static void smmu_free_coherent(struct arm_smmu_device *smmu, size_t size,
+		void *pages, dma_addr_t dma_handle)
+{
+	if (!(smmu->features & ARM_SMMU_FEAT_COHERENCY))
+		dma_unmap_single(smmu->dev, dma_handle, size, DMA_TO_DEVICE);
+	free_pages_exact(pages, size);
+}
+
 static int arm_smmu_init_l2_strtab(struct arm_smmu_device *smmu, u32 sid)
 {
 	size_t size;
@@ -1172,7 +1216,7 @@ static int arm_smmu_init_l2_strtab(struct arm_smmu_device *smmu, u32 sid)
 	strtab = &cfg->strtab[(sid >> STRTAB_SPLIT) * STRTAB_L1_DESC_DWORDS];
 
 	desc->span = STRTAB_SPLIT + 1;
-	desc->l2ptr = dmam_alloc_coherent(smmu->dev, size, &desc->l2ptr_dma,
+	desc->l2ptr = smmu_alloc_coherent(smmu, size, &desc->l2ptr_dma,
 					  GFP_KERNEL | __GFP_ZERO);
 	if (!desc->l2ptr) {
 		dev_err(smmu->dev,
@@ -1487,7 +1531,7 @@ static void arm_smmu_domain_free(struct iommu_domain *domain)
 		struct arm_smmu_s1_cfg *cfg = &smmu_domain->s1_cfg;
 
 		if (cfg->cdptr) {
-			dmam_free_coherent(smmu_domain->smmu->dev,
+			smmu_free_coherent(smmu,
 					   CTXDESC_CD_DWORDS << 3,
 					   cfg->cdptr,
 					   cfg->cdptr_dma);
@@ -1515,7 +1559,7 @@ static int arm_smmu_domain_finalise_s1(struct arm_smmu_domain *smmu_domain,
 	if (asid < 0)
 		return asid;
 
-	cfg->cdptr = dmam_alloc_coherent(smmu->dev, CTXDESC_CD_DWORDS << 3,
+	cfg->cdptr = smmu_alloc_coherent(smmu, CTXDESC_CD_DWORDS << 3,
 					 &cfg->cdptr_dma,
 					 GFP_KERNEL | __GFP_ZERO);
 	if (!cfg->cdptr) {
@@ -1984,7 +2028,7 @@ static int arm_smmu_init_one_queue(struct arm_smmu_device *smmu,
 {
 	size_t qsz = ((1 << q->max_n_shift) * dwords) << 3;
 
-	q->base = dmam_alloc_coherent(smmu->dev, qsz, &q->base_dma, GFP_KERNEL);
+	q->base = smmu_alloc_coherent(smmu, qsz, &q->base_dma, GFP_KERNEL);
 	if (!q->base) {
 		dev_err(smmu->dev, "failed to allocate queue (0x%zx bytes)\n",
 			qsz);
@@ -2069,7 +2113,7 @@ static int arm_smmu_init_strtab_2lvl(struct arm_smmu_device *smmu)
 			 size, smmu->sid_bits);
 
 	l1size = cfg->num_l1_ents * (STRTAB_L1_DESC_DWORDS << 3);
-	strtab = dmam_alloc_coherent(smmu->dev, l1size, &cfg->strtab_dma,
+	strtab = smmu_alloc_coherent(smmu, l1size, &cfg->strtab_dma,
 				     GFP_KERNEL | __GFP_ZERO);
 	if (!strtab) {
 		dev_err(smmu->dev,
@@ -2097,8 +2141,9 @@ static int arm_smmu_init_strtab_linear(struct arm_smmu_device *smmu)
 	u32 size;
 	struct arm_smmu_strtab_cfg *cfg = &smmu->strtab_cfg;
 
+
 	size = (1 << smmu->sid_bits) * (STRTAB_STE_DWORDS << 3);
-	strtab = dmam_alloc_coherent(smmu->dev, size, &cfg->strtab_dma,
+	strtab = smmu_alloc_coherent(smmu, size, &cfg->strtab_dma,
 				     GFP_KERNEL | __GFP_ZERO);
 	if (!strtab) {
 		dev_err(smmu->dev,
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
