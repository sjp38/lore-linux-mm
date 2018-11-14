Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5BEC6B0274
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:23:59 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id l15-v6so12637198pff.5
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:23:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e9si9458751plt.330.2018.11.14.00.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:23:58 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 09/34] powerpc/dma: handle iommu bypass in dma_iommu_ops
Date: Wed, 14 Nov 2018 09:22:49 +0100
Message-Id: <20181114082314.8965-10-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Add a new iommu_bypass flag to struct dev_archdata so that the dma_iommu
implementation can handle the direct mapping transparently instead of
switiching ops around.  Setting of this flag is controlled by new
pci_controller_ops method.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/device.h      |  5 ++
 arch/powerpc/include/asm/dma-mapping.h |  8 +++
 arch/powerpc/include/asm/pci-bridge.h  |  2 +
 arch/powerpc/kernel/dma-iommu.c        | 70 +++++++++++++++++++++++---
 arch/powerpc/kernel/dma.c              | 19 +++----
 5 files changed, 87 insertions(+), 17 deletions(-)

diff --git a/arch/powerpc/include/asm/device.h b/arch/powerpc/include/asm/device.h
index 0245bfcaac32..1aa53318b4bc 100644
--- a/arch/powerpc/include/asm/device.h
+++ b/arch/powerpc/include/asm/device.h
@@ -19,6 +19,11 @@ struct iommu_table;
  * drivers/macintosh/macio_asic.c
  */
 struct dev_archdata {
+	/*
+	 * Set to %true if the dma_iommu_ops are requested to use a direct
+	 * window instead of dynamically mapping memory.
+	 */
+	bool			iommu_bypass : 1;
 	/*
 	 * These two used to be a union. However, with the hybrid ops we need
 	 * both so here we store both a DMA offset for direct mappings and
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index dacd0f93f2b2..824f55995a18 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -29,6 +29,14 @@ extern int dma_nommu_mmap_coherent(struct device *dev,
 				    struct vm_area_struct *vma,
 				    void *cpu_addr, dma_addr_t handle,
 				    size_t size, unsigned long attrs);
+int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
+		int nents, enum dma_data_direction direction,
+		unsigned long attrs);
+dma_addr_t dma_nommu_map_page(struct device *dev, struct page *page,
+		unsigned long offset, size_t size,
+		enum dma_data_direction dir, unsigned long attrs);
+int dma_nommu_dma_supported(struct device *dev, u64 mask);
+u64 dma_nommu_get_required_mask(struct device *dev);
 
 #ifdef CONFIG_NOT_COHERENT_CACHE
 /*
diff --git a/arch/powerpc/include/asm/pci-bridge.h b/arch/powerpc/include/asm/pci-bridge.h
index 94d449031b18..5c7a1e7ffc8a 100644
--- a/arch/powerpc/include/asm/pci-bridge.h
+++ b/arch/powerpc/include/asm/pci-bridge.h
@@ -19,6 +19,8 @@ struct device_node;
 struct pci_controller_ops {
 	void		(*dma_dev_setup)(struct pci_dev *pdev);
 	void		(*dma_bus_setup)(struct pci_bus *bus);
+	bool		(*iommu_bypass_supported)(struct pci_dev *pdev,
+				u64 mask);
 
 	int		(*probe_mode)(struct pci_bus *bus);
 
diff --git a/arch/powerpc/kernel/dma-iommu.c b/arch/powerpc/kernel/dma-iommu.c
index 0613278abf9f..459be16f8334 100644
--- a/arch/powerpc/kernel/dma-iommu.c
+++ b/arch/powerpc/kernel/dma-iommu.c
@@ -6,12 +6,30 @@
  * busses using the iommu infrastructure
  */
 
+#include <linux/dma-direct.h>
+#include <linux/pci.h>
 #include <asm/iommu.h>
 
 /*
  * Generic iommu implementation
  */
 
+/*
+ * The coherent mask may be smaller than the real mask, check if we can
+ * really use a direct window.
+ */
+static inline bool dma_iommu_alloc_bypass(struct device *dev)
+{
+	return dev->archdata.iommu_bypass &&
+		dma_nommu_dma_supported(dev, dev->coherent_dma_mask);
+}
+
+static inline bool dma_iommu_map_bypass(struct device *dev,
+		unsigned long attrs)
+{
+	return dev->archdata.iommu_bypass;
+}
+
 /* Allocates a contiguous real buffer and creates mappings over it.
  * Returns the virtual address of the buffer and sets dma_handle
  * to the dma address (mapping) of the first page.
@@ -20,6 +38,9 @@ static void *dma_iommu_alloc_coherent(struct device *dev, size_t size,
 				      dma_addr_t *dma_handle, gfp_t flag,
 				      unsigned long attrs)
 {
+	if (dma_iommu_alloc_bypass(dev))
+		return __dma_nommu_alloc_coherent(dev, size, dma_handle, flag,
+				attrs);
 	return iommu_alloc_coherent(dev, get_iommu_table_base(dev), size,
 				    dma_handle, dev->coherent_dma_mask, flag,
 				    dev_to_node(dev));
@@ -29,7 +50,11 @@ static void dma_iommu_free_coherent(struct device *dev, size_t size,
 				    void *vaddr, dma_addr_t dma_handle,
 				    unsigned long attrs)
 {
-	iommu_free_coherent(get_iommu_table_base(dev), size, vaddr, dma_handle);
+	if (dma_iommu_alloc_bypass(dev))
+		__dma_nommu_free_coherent(dev, size, vaddr, dma_handle, attrs);
+	else
+		iommu_free_coherent(get_iommu_table_base(dev), size, vaddr,
+				dma_handle);
 }
 
 /* Creates TCEs for a user provided buffer.  The user buffer must be
@@ -42,6 +67,9 @@ static dma_addr_t dma_iommu_map_page(struct device *dev, struct page *page,
 				     enum dma_data_direction direction,
 				     unsigned long attrs)
 {
+	if (dma_iommu_map_bypass(dev, attrs))
+		return dma_nommu_map_page(dev, page, offset, size, direction,
+				attrs);
 	return iommu_map_page(dev, get_iommu_table_base(dev), page, offset,
 			      size, device_to_mask(dev), direction, attrs);
 }
@@ -51,8 +79,9 @@ static void dma_iommu_unmap_page(struct device *dev, dma_addr_t dma_handle,
 				 size_t size, enum dma_data_direction direction,
 				 unsigned long attrs)
 {
-	iommu_unmap_page(get_iommu_table_base(dev), dma_handle, size, direction,
-			 attrs);
+	if (!dma_iommu_map_bypass(dev, attrs))
+		iommu_unmap_page(get_iommu_table_base(dev), dma_handle, size,
+				direction,  attrs);
 }
 
 
@@ -60,6 +89,8 @@ static int dma_iommu_map_sg(struct device *dev, struct scatterlist *sglist,
 			    int nelems, enum dma_data_direction direction,
 			    unsigned long attrs)
 {
+	if (dma_iommu_map_bypass(dev, attrs))
+		return dma_nommu_map_sg(dev, sglist, nelems, direction, attrs);
 	return ppc_iommu_map_sg(dev, get_iommu_table_base(dev), sglist, nelems,
 				device_to_mask(dev), direction, attrs);
 }
@@ -68,10 +99,20 @@ static void dma_iommu_unmap_sg(struct device *dev, struct scatterlist *sglist,
 		int nelems, enum dma_data_direction direction,
 		unsigned long attrs)
 {
-	ppc_iommu_unmap_sg(get_iommu_table_base(dev), sglist, nelems,
+	if (!dma_iommu_map_bypass(dev, attrs))
+		ppc_iommu_unmap_sg(get_iommu_table_base(dev), sglist, nelems,
 			   direction, attrs);
 }
 
+static bool dma_iommu_bypass_supported(struct device *dev, u64 mask)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct pci_controller *phb = pci_bus_to_host(pdev->bus);
+
+	return phb->controller_ops.iommu_bypass_supported &&
+		phb->controller_ops.iommu_bypass_supported(pdev, mask);
+}
+
 /* We support DMA to/from any memory page via the iommu */
 int dma_iommu_dma_supported(struct device *dev, u64 mask)
 {
@@ -83,22 +124,39 @@ int dma_iommu_dma_supported(struct device *dev, u64 mask)
 		return 0;
 	}
 
+	if (dev_is_pci(dev) && dma_iommu_bypass_supported(dev, mask)) {
+		dev->archdata.iommu_bypass = true;
+		dev_dbg(dev, "iommu: 64-bit OK, using fixed ops\n");
+		return 1;
+	}
+
 	if (tbl->it_offset > (mask >> tbl->it_page_shift)) {
 		dev_info(dev, "Warning: IOMMU offset too big for device mask\n");
 		dev_info(dev, "mask: 0x%08llx, table offset: 0x%08lx\n",
 				mask, tbl->it_offset << tbl->it_page_shift);
 		return 0;
-	} else
-		return 1;
+	}
+
+	dev_dbg(dev, "iommu: not 64-bit, using default ops\n");
+	dev->archdata.iommu_bypass = false;
+	return 1;
 }
 
 u64 dma_iommu_get_required_mask(struct device *dev)
 {
 	struct iommu_table *tbl = get_iommu_table_base(dev);
 	u64 mask;
+
 	if (!tbl)
 		return 0;
 
+	if (dev_is_pci(dev)) {
+		u64 bypass_mask = dma_nommu_get_required_mask(dev);
+
+		if (dma_iommu_bypass_supported(dev, bypass_mask))
+			return bypass_mask;
+	}
+
 	mask = 1ULL < (fls_long(tbl->it_offset + tbl->it_size) - 1);
 	mask += mask - 1;
 
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 7078d72baec2..6c368b6820bb 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -40,7 +40,7 @@ static u64 __maybe_unused get_pfn_limit(struct device *dev)
 	return pfn;
 }
 
-static int dma_nommu_dma_supported(struct device *dev, u64 mask)
+int dma_nommu_dma_supported(struct device *dev, u64 mask)
 {
 #ifdef CONFIG_PPC64
 	u64 limit = get_dma_offset(dev) + (memblock_end_of_DRAM() - 1);
@@ -177,9 +177,9 @@ int dma_nommu_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
 			       vma->vm_page_prot);
 }
 
-static int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
-			     int nents, enum dma_data_direction direction,
-			     unsigned long attrs)
+int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
+		int nents, enum dma_data_direction direction,
+		unsigned long attrs)
 {
 	struct scatterlist *sg;
 	int i;
@@ -197,7 +197,7 @@ static int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
 	return nents;
 }
 
-static u64 dma_nommu_get_required_mask(struct device *dev)
+u64 dma_nommu_get_required_mask(struct device *dev)
 {
 	u64 end, mask;
 
@@ -209,12 +209,9 @@ static u64 dma_nommu_get_required_mask(struct device *dev)
 	return mask;
 }
 
-static inline dma_addr_t dma_nommu_map_page(struct device *dev,
-					     struct page *page,
-					     unsigned long offset,
-					     size_t size,
-					     enum dma_data_direction dir,
-					     unsigned long attrs)
+dma_addr_t dma_nommu_map_page(struct device *dev, struct page *page,
+		unsigned long offset, size_t size,
+		enum dma_data_direction dir, unsigned long attrs)
 {
 	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
 		__dma_sync_page(page, offset, size, dir);
-- 
2.19.1
