Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF18D6B0294
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:26:41 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x2-v6so834728pgr.8
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:26:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z12-v6si19047795pgp.274.2018.10.09.06.26.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 06:26:40 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 31/33] powerpc/dma: remove dma_nommu_mmap_coherent
Date: Tue,  9 Oct 2018 15:24:58 +0200
Message-Id: <20181009132500.17643-32-hch@lst.de>
In-Reply-To: <20181009132500.17643-1-hch@lst.de>
References: <20181009132500.17643-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The coherent cache version of this function already is functionally
identicall to the default version, and by defining the
arch_dma_coherent_to_pfn hook the same is ture for the noncoherent
version as well.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/dma-mapping.h |  4 ----
 arch/powerpc/kernel/dma-iommu.c        |  1 -
 arch/powerpc/kernel/dma-swiotlb.c      |  1 -
 arch/powerpc/kernel/dma.c              | 19 -------------------
 arch/powerpc/mm/dma-noncoherent.c      |  7 +++++--
 arch/powerpc/platforms/Kconfig.cputype |  1 +
 arch/powerpc/platforms/pseries/vio.c   |  1 -
 7 files changed, 6 insertions(+), 28 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index e12439ae8211..ababad4b07a7 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -25,10 +25,6 @@ extern void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
 extern void __dma_nommu_free_coherent(struct device *dev, size_t size,
 				       void *vaddr, dma_addr_t dma_handle,
 				       unsigned long attrs);
-extern int dma_nommu_mmap_coherent(struct device *dev,
-				    struct vm_area_struct *vma,
-				    void *cpu_addr, dma_addr_t handle,
-				    size_t size, unsigned long attrs);
 int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
 		int nents, enum dma_data_direction direction,
 		unsigned long attrs);
diff --git a/arch/powerpc/kernel/dma-iommu.c b/arch/powerpc/kernel/dma-iommu.c
index 7fa3636636fa..2e682004959f 100644
--- a/arch/powerpc/kernel/dma-iommu.c
+++ b/arch/powerpc/kernel/dma-iommu.c
@@ -172,7 +172,6 @@ int dma_iommu_mapping_error(struct device *dev, dma_addr_t dma_addr)
 const struct dma_map_ops dma_iommu_ops = {
 	.alloc			= dma_iommu_alloc_coherent,
 	.free			= dma_iommu_free_coherent,
-	.mmap			= dma_nommu_mmap_coherent,
 	.map_sg			= dma_iommu_map_sg,
 	.unmap_sg		= dma_iommu_unmap_sg,
 	.dma_supported		= dma_iommu_dma_supported,
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index d33caff8c684..c6f8519f8d4e 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -42,7 +42,6 @@ unsigned int ppc_swiotlb_enable;
 const struct dma_map_ops powerpc_swiotlb_dma_ops = {
 	.alloc = __dma_nommu_alloc_coherent,
 	.free = __dma_nommu_free_coherent,
-	.mmap = dma_nommu_mmap_coherent,
 	.map_sg = swiotlb_map_sg_attrs,
 	.unmap_sg = swiotlb_unmap_sg_attrs,
 	.dma_supported = swiotlb_dma_supported,
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 7f7f3a069b63..92cc402d249f 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -113,24 +113,6 @@ void __dma_nommu_free_coherent(struct device *dev, size_t size,
 }
 #endif /* !CONFIG_NOT_COHERENT_CACHE */
 
-int dma_nommu_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
-			     void *cpu_addr, dma_addr_t handle, size_t size,
-			     unsigned long attrs)
-{
-	unsigned long pfn;
-
-#ifdef CONFIG_NOT_COHERENT_CACHE
-	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
-	pfn = __dma_get_coherent_pfn((unsigned long)cpu_addr);
-#else
-	pfn = page_to_pfn(virt_to_page(cpu_addr));
-#endif
-	return remap_pfn_range(vma, vma->vm_start,
-			       pfn + vma->vm_pgoff,
-			       vma->vm_end - vma->vm_start,
-			       vma->vm_page_prot);
-}
-
 int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
 		int nents, enum dma_data_direction direction,
 		unsigned long attrs)
@@ -184,7 +166,6 @@ static inline void dma_nommu_sync_single(struct device *dev,
 const struct dma_map_ops dma_nommu_ops = {
 	.alloc				= __dma_nommu_alloc_coherent,
 	.free				= __dma_nommu_free_coherent,
-	.mmap				= dma_nommu_mmap_coherent,
 	.map_sg				= dma_nommu_map_sg,
 	.dma_supported			= dma_nommu_dma_supported,
 	.map_page			= dma_nommu_map_page,
diff --git a/arch/powerpc/mm/dma-noncoherent.c b/arch/powerpc/mm/dma-noncoherent.c
index 965ce3d19f5a..a016c9c356d5 100644
--- a/arch/powerpc/mm/dma-noncoherent.c
+++ b/arch/powerpc/mm/dma-noncoherent.c
@@ -30,6 +30,7 @@
 #include <linux/types.h>
 #include <linux/highmem.h>
 #include <linux/dma-direct.h>
+#include <linux/dma-noncoherent.h>
 #include <linux/export.h>
 
 #include <asm/tlbflush.h>
@@ -400,14 +401,16 @@ EXPORT_SYMBOL(__dma_sync_page);
 
 /*
  * Return the PFN for a given cpu virtual address returned by
- * __dma_nommu_alloc_coherent. This is used by dma_mmap_coherent()
+ * __dma_nommu_alloc_coherent.
  */
-unsigned long __dma_get_coherent_pfn(unsigned long cpu_addr)
+long arch_dma_coherent_to_pfn(struct device *dev, void *vaddr,
+		dma_addr_t dma_addr)
 {
 	/* This should always be populated, so we don't test every
 	 * level. If that fails, we'll have a nice crash which
 	 * will be as good as a BUG_ON()
 	 */
+	unsigned long cpu_addr = (unsigned long)vaddr;
 	pgd_t *pgd = pgd_offset_k(cpu_addr);
 	pud_t *pud = pud_offset(pgd, cpu_addr);
 	pmd_t *pmd = pmd_offset(pud, cpu_addr);
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index 6c6a7c72cae4..0c4fc631cb33 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -415,6 +415,7 @@ config NR_CPUS
 config NOT_COHERENT_CACHE
 	bool
 	depends on 4xx || PPC_8xx || E200 || PPC_MPC512x || GAMECUBE_COMMON
+	select ARCH_HAS_DMA_COHERENT_TO_PFN
 	default n if PPC_47x
 	default y
 
diff --git a/arch/powerpc/platforms/pseries/vio.c b/arch/powerpc/platforms/pseries/vio.c
index 1dfff53ebd7f..3ad74efc83bf 100644
--- a/arch/powerpc/platforms/pseries/vio.c
+++ b/arch/powerpc/platforms/pseries/vio.c
@@ -603,7 +603,6 @@ static void vio_dma_iommu_unmap_sg(struct device *dev,
 static const struct dma_map_ops vio_dma_mapping_ops = {
 	.alloc             = vio_dma_iommu_alloc_coherent,
 	.free              = vio_dma_iommu_free_coherent,
-	.mmap		   = dma_nommu_mmap_coherent,
 	.map_sg            = vio_dma_iommu_map_sg,
 	.unmap_sg          = vio_dma_iommu_unmap_sg,
 	.map_page          = vio_dma_iommu_map_page,
-- 
2.19.0
