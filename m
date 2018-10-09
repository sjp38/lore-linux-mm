Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D38F66B0276
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:25:54 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id c5-v6so992926plo.2
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:25:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id cc10-v6si25068060plb.97.2018.10.09.06.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 06:25:53 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 12/33] powerpc/cell: use the generic iommu bypass code
Date: Tue,  9 Oct 2018 15:24:39 +0200
Message-Id: <20181009132500.17643-13-hch@lst.de>
In-Reply-To: <20181009132500.17643-1-hch@lst.de>
References: <20181009132500.17643-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

This gets rid of a lot of clumsy code and finally allows us to mark
dma_iommu_ops const.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/dma-mapping.h |   2 +-
 arch/powerpc/include/asm/iommu.h       |   6 ++
 arch/powerpc/kernel/dma-iommu.c        |   7 +-
 arch/powerpc/platforms/cell/iommu.c    | 143 ++-----------------------
 4 files changed, 22 insertions(+), 136 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 27283eb68c50..59c090b7eaac 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -73,7 +73,7 @@ static inline unsigned long device_to_mask(struct device *dev)
  * Available generic sets of operations
  */
 #ifdef CONFIG_PPC64
-extern struct dma_map_ops dma_iommu_ops;
+extern const struct dma_map_ops dma_iommu_ops;
 #endif
 extern const struct dma_map_ops dma_nommu_ops;
 
diff --git a/arch/powerpc/include/asm/iommu.h b/arch/powerpc/include/asm/iommu.h
index 26b7cc176a99..264d04f1dcd1 100644
--- a/arch/powerpc/include/asm/iommu.h
+++ b/arch/powerpc/include/asm/iommu.h
@@ -328,5 +328,11 @@ extern void iommu_release_ownership(struct iommu_table *tbl);
 extern enum dma_data_direction iommu_tce_direction(unsigned long tce);
 extern unsigned long iommu_direction_to_tce_perm(enum dma_data_direction dir);
 
+#ifdef CONFIG_PPC_CELL_NATIVE
+extern bool iommu_fixed_is_weak;
+#else
+#define iommu_fixed_is_weak false
+#endif
+
 #endif /* __KERNEL__ */
 #endif /* _ASM_IOMMU_H */
diff --git a/arch/powerpc/kernel/dma-iommu.c b/arch/powerpc/kernel/dma-iommu.c
index c865e15ad024..7fa3636636fa 100644
--- a/arch/powerpc/kernel/dma-iommu.c
+++ b/arch/powerpc/kernel/dma-iommu.c
@@ -20,14 +20,15 @@
  */
 static inline bool dma_iommu_alloc_bypass(struct device *dev)
 {
-	return dev->archdata.iommu_bypass &&
+	return dev->archdata.iommu_bypass && !iommu_fixed_is_weak &&
 		dma_nommu_dma_supported(dev, dev->coherent_dma_mask);
 }
 
 static inline bool dma_iommu_map_bypass(struct device *dev,
 		unsigned long attrs)
 {
-	return dev->archdata.iommu_bypass;
+	return dev->archdata.iommu_bypass &&
+		(!iommu_fixed_is_weak || (attrs & DMA_ATTR_WEAK_ORDERING));
 }
 
 /* Allocates a contiguous real buffer and creates mappings over it.
@@ -168,7 +169,7 @@ int dma_iommu_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return dma_addr == IOMMU_MAPPING_ERROR;
 }
 
-struct dma_map_ops dma_iommu_ops = {
+const struct dma_map_ops dma_iommu_ops = {
 	.alloc			= dma_iommu_alloc_coherent,
 	.free			= dma_iommu_free_coherent,
 	.mmap			= dma_nommu_mmap_coherent,
diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index cce5bf9515e5..fb51f78035ce 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -546,7 +546,7 @@ static unsigned long cell_dma_nommu_offset;
 static unsigned long dma_iommu_fixed_base;
 
 /* iommu_fixed_is_weak is set if booted with iommu_fixed=weak */
-static int iommu_fixed_is_weak;
+bool iommu_fixed_is_weak;
 
 static struct iommu_table *cell_get_iommu_table(struct device *dev)
 {
@@ -568,95 +568,6 @@ static struct iommu_table *cell_get_iommu_table(struct device *dev)
 	return &window->table;
 }
 
-/* A coherent allocation implies strong ordering */
-
-static void *dma_fixed_alloc_coherent(struct device *dev, size_t size,
-				      dma_addr_t *dma_handle, gfp_t flag,
-				      unsigned long attrs)
-{
-	if (iommu_fixed_is_weak)
-		return iommu_alloc_coherent(dev, cell_get_iommu_table(dev),
-					    size, dma_handle,
-					    device_to_mask(dev), flag,
-					    dev_to_node(dev));
-	else
-		return dma_nommu_ops.alloc(dev, size, dma_handle, flag,
-					    attrs);
-}
-
-static void dma_fixed_free_coherent(struct device *dev, size_t size,
-				    void *vaddr, dma_addr_t dma_handle,
-				    unsigned long attrs)
-{
-	if (iommu_fixed_is_weak)
-		iommu_free_coherent(cell_get_iommu_table(dev), size, vaddr,
-				    dma_handle);
-	else
-		dma_nommu_ops.free(dev, size, vaddr, dma_handle, attrs);
-}
-
-static dma_addr_t dma_fixed_map_page(struct device *dev, struct page *page,
-				     unsigned long offset, size_t size,
-				     enum dma_data_direction direction,
-				     unsigned long attrs)
-{
-	if (iommu_fixed_is_weak == (attrs & DMA_ATTR_WEAK_ORDERING))
-		return dma_nommu_ops.map_page(dev, page, offset, size,
-					       direction, attrs);
-	else
-		return iommu_map_page(dev, cell_get_iommu_table(dev), page,
-				      offset, size, device_to_mask(dev),
-				      direction, attrs);
-}
-
-static void dma_fixed_unmap_page(struct device *dev, dma_addr_t dma_addr,
-				 size_t size, enum dma_data_direction direction,
-				 unsigned long attrs)
-{
-	if (iommu_fixed_is_weak == (attrs & DMA_ATTR_WEAK_ORDERING))
-		dma_nommu_ops.unmap_page(dev, dma_addr, size, direction,
-					  attrs);
-	else
-		iommu_unmap_page(cell_get_iommu_table(dev), dma_addr, size,
-				 direction, attrs);
-}
-
-static int dma_fixed_map_sg(struct device *dev, struct scatterlist *sg,
-			   int nents, enum dma_data_direction direction,
-			   unsigned long attrs)
-{
-	if (iommu_fixed_is_weak == (attrs & DMA_ATTR_WEAK_ORDERING))
-		return dma_nommu_ops.map_sg(dev, sg, nents, direction, attrs);
-	else
-		return ppc_iommu_map_sg(dev, cell_get_iommu_table(dev), sg,
-					nents, device_to_mask(dev),
-					direction, attrs);
-}
-
-static void dma_fixed_unmap_sg(struct device *dev, struct scatterlist *sg,
-			       int nents, enum dma_data_direction direction,
-			       unsigned long attrs)
-{
-	if (iommu_fixed_is_weak == (attrs & DMA_ATTR_WEAK_ORDERING))
-		dma_nommu_ops.unmap_sg(dev, sg, nents, direction, attrs);
-	else
-		ppc_iommu_unmap_sg(cell_get_iommu_table(dev), sg, nents,
-				   direction, attrs);
-}
-
-static int dma_suported_and_switch(struct device *dev, u64 dma_mask);
-
-static const struct dma_map_ops dma_iommu_fixed_ops = {
-	.alloc          = dma_fixed_alloc_coherent,
-	.free           = dma_fixed_free_coherent,
-	.map_sg         = dma_fixed_map_sg,
-	.unmap_sg       = dma_fixed_unmap_sg,
-	.dma_supported  = dma_suported_and_switch,
-	.map_page       = dma_fixed_map_page,
-	.unmap_page     = dma_fixed_unmap_page,
-	.mapping_error	= dma_iommu_mapping_error,
-};
-
 static u64 cell_iommu_get_fixed_address(struct device *dev);
 
 static void cell_dma_dev_setup(struct device *dev)
@@ -953,22 +864,10 @@ static u64 cell_iommu_get_fixed_address(struct device *dev)
 	return dev_addr;
 }
 
-static int dma_suported_and_switch(struct device *dev, u64 dma_mask)
+static bool cell_pci_iommu_bypass_supported(struct pci_dev *pdev, u64 mask)
 {
-	if (dma_mask == DMA_BIT_MASK(64) &&
-	    cell_iommu_get_fixed_address(dev) != OF_BAD_ADDR) {
-		dev_dbg(dev, "iommu: 64-bit OK, using fixed ops\n");
-		set_dma_ops(dev, &dma_iommu_fixed_ops);
-		return 1;
-	}
-
-	if (dma_iommu_dma_supported(dev, dma_mask)) {
-		dev_dbg(dev, "iommu: not 64-bit, using default ops\n");
-		set_dma_ops(dev, &dma_iommu_ops);
-		return 1;
-	}
-
-	return 0;
+	return mask == DMA_BIT_MASK(64) &&
+		cell_iommu_get_fixed_address(&pdev->dev) != OF_BAD_ADDR;
 }
 
 static void insert_16M_pte(unsigned long addr, unsigned long *ptab,
@@ -1122,9 +1021,6 @@ static int __init cell_iommu_fixed_mapping_init(void)
 		cell_iommu_setup_window(iommu, np, dbase, dsize, 0);
 	}
 
-	dma_iommu_ops.dma_supported = dma_suported_and_switch;
-	set_pci_dma_ops(&dma_iommu_ops);
-
 	return 0;
 }
 
@@ -1145,7 +1041,7 @@ static int __init setup_iommu_fixed(char *str)
 	pciep = of_find_node_by_type(NULL, "pcie-endpoint");
 
 	if (strcmp(str, "weak") == 0 || (pciep && strcmp(str, "strong") != 0))
-		iommu_fixed_is_weak = DMA_ATTR_WEAK_ORDERING;
+		iommu_fixed_is_weak = true;
 
 	of_node_put(pciep);
 
@@ -1153,26 +1049,6 @@ static int __init setup_iommu_fixed(char *str)
 }
 __setup("iommu_fixed=", setup_iommu_fixed);
 
-static u64 cell_dma_get_required_mask(struct device *dev)
-{
-	const struct dma_map_ops *dma_ops;
-
-	if (!dev->dma_mask)
-		return 0;
-
-	if (!iommu_fixed_disabled &&
-			cell_iommu_get_fixed_address(dev) != OF_BAD_ADDR)
-		return DMA_BIT_MASK(64);
-
-	dma_ops = get_dma_ops(dev);
-	if (dma_ops->get_required_mask)
-		return dma_ops->get_required_mask(dev);
-
-	WARN_ONCE(1, "no get_required_mask in %p ops", dma_ops);
-
-	return DMA_BIT_MASK(64);
-}
-
 static int __init cell_iommu_init(void)
 {
 	struct device_node *np;
@@ -1189,10 +1065,9 @@ static int __init cell_iommu_init(void)
 
 	/* Setup various callbacks */
 	cell_pci_controller_ops.dma_dev_setup = cell_pci_dma_dev_setup;
-	ppc_md.dma_get_required_mask = cell_dma_get_required_mask;
 
 	if (!iommu_fixed_disabled && cell_iommu_fixed_mapping_init() == 0)
-		goto bail;
+		goto done;
 
 	/* Create an iommu for each /axon node.  */
 	for_each_node_by_name(np, "axon") {
@@ -1209,8 +1084,12 @@ static int __init cell_iommu_init(void)
 			continue;
 		cell_iommu_init_one(np, SPIDER_DMA_OFFSET);
 	}
-
+ done:
 	/* Setup default PCI iommu ops */
+	if (!iommu_fixed_disabled) {
+		cell_pci_controller_ops.iommu_bypass_supported =
+				cell_pci_iommu_bypass_supported;
+	}
 	set_pci_dma_ops(&dma_iommu_ops);
 
  bail:
-- 
2.19.0
