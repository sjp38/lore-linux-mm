Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5796B0283
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:24:28 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 33-v6so11528719pld.19
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:24:28 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y40-v6si24191358pla.391.2018.11.14.00.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:24:27 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 22/34] powerpc/dma: remove the iommu fallback for coherent allocations
Date: Wed, 14 Nov 2018 09:23:02 +0100
Message-Id: <20181114082314.8965-23-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

All iommu capable platforms now always use the iommu code with the
internal bypass, so there is not need for this magic anymore.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/Kconfig      |  4 ---
 arch/powerpc/kernel/dma.c | 68 ++-------------------------------------
 2 files changed, 2 insertions(+), 70 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index cffff3613bc1..2d4a19bc8023 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -119,9 +119,6 @@ config GENERIC_HWEIGHT
 	bool
 	default y
 
-config ARCH_HAS_DMA_SET_COHERENT_MASK
-        bool
-
 config PPC
 	bool
 	default y
@@ -129,7 +126,6 @@ config PPC
 	# Please keep this list sorted alphabetically.
 	#
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
-	select ARCH_HAS_DMA_SET_COHERENT_MASK
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 829eb2fefc8c..f9f51fc505a1 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -114,51 +114,6 @@ void __dma_nommu_free_coherent(struct device *dev, size_t size,
 }
 #endif /* !CONFIG_NOT_COHERENT_CACHE */
 
-static void *dma_nommu_alloc_coherent(struct device *dev, size_t size,
-				       dma_addr_t *dma_handle, gfp_t flag,
-				       unsigned long attrs)
-{
-	struct iommu_table *iommu;
-
-	/* The coherent mask may be smaller than the real mask, check if
-	 * we can really use the direct ops
-	 */
-	if (dma_nommu_dma_supported(dev, dev->coherent_dma_mask))
-		return __dma_nommu_alloc_coherent(dev, size, dma_handle,
-						   flag, attrs);
-
-	/* Ok we can't ... do we have an iommu ? If not, fail */
-	iommu = get_iommu_table_base(dev);
-	if (!iommu)
-		return NULL;
-
-	/* Try to use the iommu */
-	return iommu_alloc_coherent(dev, iommu, size, dma_handle,
-				    dev->coherent_dma_mask, flag,
-				    dev_to_node(dev));
-}
-
-static void dma_nommu_free_coherent(struct device *dev, size_t size,
-				     void *vaddr, dma_addr_t dma_handle,
-				     unsigned long attrs)
-{
-	struct iommu_table *iommu;
-
-	/* See comments in dma_nommu_alloc_coherent() */
-	if (dma_nommu_dma_supported(dev, dev->coherent_dma_mask))
-		return __dma_nommu_free_coherent(dev, size, vaddr, dma_handle,
-						  attrs);
-	/* Maybe we used an iommu ... */
-	iommu = get_iommu_table_base(dev);
-
-	/* If we hit that we should have never allocated in the first
-	 * place so how come we are freeing ?
-	 */
-	if (WARN_ON(!iommu))
-		return;
-	iommu_free_coherent(iommu, size, vaddr, dma_handle);
-}
-
 int dma_nommu_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
 			     void *cpu_addr, dma_addr_t handle, size_t size,
 			     unsigned long attrs)
@@ -240,8 +195,8 @@ static inline void dma_nommu_sync_single(struct device *dev,
 #endif
 
 const struct dma_map_ops dma_nommu_ops = {
-	.alloc				= dma_nommu_alloc_coherent,
-	.free				= dma_nommu_free_coherent,
+	.alloc				= __dma_nommu_alloc_coherent,
+	.free				= __dma_nommu_free_coherent,
 	.mmap				= dma_nommu_mmap_coherent,
 	.map_sg				= dma_nommu_map_sg,
 	.dma_supported			= dma_nommu_dma_supported,
@@ -255,25 +210,6 @@ const struct dma_map_ops dma_nommu_ops = {
 };
 EXPORT_SYMBOL(dma_nommu_ops);
 
-int dma_set_coherent_mask(struct device *dev, u64 mask)
-{
-	if (!dma_supported(dev, mask)) {
-		/*
-		 * We need to special case the direct DMA ops which can
-		 * support a fallback for coherent allocations. There
-		 * is no dma_op->set_coherent_mask() so we have to do
-		 * things the hard way:
-		 */
-		if (get_dma_ops(dev) != &dma_nommu_ops ||
-		    get_iommu_table_base(dev) == NULL ||
-		    !dma_iommu_dma_supported(dev, mask))
-			return -EIO;
-	}
-	dev->coherent_dma_mask = mask;
-	return 0;
-}
-EXPORT_SYMBOL(dma_set_coherent_mask);
-
 int dma_set_mask(struct device *dev, u64 dma_mask)
 {
 	if (ppc_md.dma_set_mask)
-- 
2.19.1
