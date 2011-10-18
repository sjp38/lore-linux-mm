Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 65D276B002F
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 13:19:48 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LT9008B4USUP080@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 18 Oct 2011 18:19:42 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LT900MTSUST2F@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 18 Oct 2011 18:19:42 +0100 (BST)
Date: Tue, 18 Oct 2011 19:19:19 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 2/8] ARM: dma-mapping: use asm-generic/dma-mapping-common.h
In-reply-to: <1318958365-19120-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1318958365-19120-3-git-send-email-m.szyprowski@samsung.com>
References: <1318958365-19120-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>

This patch modifies dma-mapping implementation on ARM architecture to
use common dma_map_ops structure and asm-generic/dma-mapping-common.h
helpers.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/Kconfig                   |    1 +
 arch/arm/include/asm/device.h      |    1 +
 arch/arm/include/asm/dma-mapping.h |  196 +++++-------------------------------
 arch/arm/mm/dma-mapping.c          |  149 ++++++++++++++++-----------
 4 files changed, 116 insertions(+), 231 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index d0abf54..f9d01e0 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -3,6 +3,7 @@ config ARM
 	default y
 	select HAVE_AOUT
 	select HAVE_DMA_API_DEBUG
+	select HAVE_DMA_ATTRS
 	select HAVE_DMA_CONTIGUOUS if (CPU_V6 || CPU_V6K || CPU_V7)
 	select CMA if (CPU_V6 || CPU_V6K || CPU_V7)
 	select HAVE_IDE
diff --git a/arch/arm/include/asm/device.h b/arch/arm/include/asm/device.h
index 9f390ce..d3b35d8 100644
--- a/arch/arm/include/asm/device.h
+++ b/arch/arm/include/asm/device.h
@@ -7,6 +7,7 @@
 #define ASMARM_DEVICE_H
 
 struct dev_archdata {
+	struct dma_map_ops	*dma_ops;
 #ifdef CONFIG_DMABOUNCE
 	struct dmabounce_device_info *dmabounce;
 #endif
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 6bc056c..54b4a8d 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -10,6 +10,27 @@
 #include <asm-generic/dma-coherent.h>
 #include <asm/memory.h>
 
+extern struct dma_map_ops arm_dma_ops;
+
+static inline struct dma_map_ops *get_dma_ops(struct device *dev)
+{
+	if (dev->archdata.dma_ops)
+		return dev->archdata.dma_ops;
+	return &arm_dma_ops;
+}
+
+static inline void set_dma_ops(struct device *dev, struct dma_map_ops *ops)
+{
+	dev->archdata.dma_ops = ops;
+}
+
+#include <asm-generic/dma-mapping-common.h>
+
+static inline int dma_set_mask(struct device *dev, u64 mask)
+{
+	return get_dma_ops(dev)->set_dma_mask(dev, mask);
+}
+
 #ifdef __arch_page_to_dma
 #error Please update to __arch_pfn_to_dma
 #endif
@@ -117,7 +138,6 @@ static inline void __dma_page_dev_to_cpu(struct page *page, unsigned long off,
 
 extern int dma_supported(struct device *, u64);
 extern int dma_set_mask(struct device *, u64);
-
 /*
  * DMA errors are defined by all-bits-set in the DMA address.
  */
@@ -295,179 +315,17 @@ static inline void __dma_unmap_page(struct device *dev, dma_addr_t handle,
 }
 #endif /* CONFIG_DMABOUNCE */
 
-/**
- * dma_map_single - map a single buffer for streaming DMA
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @cpu_addr: CPU direct mapped address of buffer
- * @size: size of buffer to map
- * @dir: DMA transfer direction
- *
- * Ensure that any data held in the cache is appropriately discarded
- * or written back.
- *
- * The device owns this memory once this call has completed.  The CPU
- * can regain ownership by calling dma_unmap_single() or
- * dma_sync_single_for_cpu().
- */
-static inline dma_addr_t dma_map_single(struct device *dev, void *cpu_addr,
-		size_t size, enum dma_data_direction dir)
-{
-	unsigned long offset;
-	struct page *page;
-	dma_addr_t addr;
-
-	BUG_ON(!virt_addr_valid(cpu_addr));
-	BUG_ON(!virt_addr_valid(cpu_addr + size - 1));
-	BUG_ON(!valid_dma_direction(dir));
-
-	page = virt_to_page(cpu_addr);
-	offset = (unsigned long)cpu_addr & ~PAGE_MASK;
-	addr = __dma_map_page(dev, page, offset, size, dir);
-	debug_dma_map_page(dev, page, offset, size, dir, addr, true);
-
-	return addr;
-}
-
-/**
- * dma_map_page - map a portion of a page for streaming DMA
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @page: page that buffer resides in
- * @offset: offset into page for start of buffer
- * @size: size of buffer to map
- * @dir: DMA transfer direction
- *
- * Ensure that any data held in the cache is appropriately discarded
- * or written back.
- *
- * The device owns this memory once this call has completed.  The CPU
- * can regain ownership by calling dma_unmap_page().
- */
-static inline dma_addr_t dma_map_page(struct device *dev, struct page *page,
-	     unsigned long offset, size_t size, enum dma_data_direction dir)
-{
-	dma_addr_t addr;
-
-	BUG_ON(!valid_dma_direction(dir));
-
-	addr = __dma_map_page(dev, page, offset, size, dir);
-	debug_dma_map_page(dev, page, offset, size, dir, addr, false);
-
-	return addr;
-}
-
-/**
- * dma_unmap_single - unmap a single buffer previously mapped
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @handle: DMA address of buffer
- * @size: size of buffer (same as passed to dma_map_single)
- * @dir: DMA transfer direction (same as passed to dma_map_single)
- *
- * Unmap a single streaming mode DMA translation.  The handle and size
- * must match what was provided in the previous dma_map_single() call.
- * All other usages are undefined.
- *
- * After this call, reads by the CPU to the buffer are guaranteed to see
- * whatever the device wrote there.
- */
-static inline void dma_unmap_single(struct device *dev, dma_addr_t handle,
-		size_t size, enum dma_data_direction dir)
-{
-	debug_dma_unmap_page(dev, handle, size, dir, true);
-	__dma_unmap_page(dev, handle, size, dir);
-}
-
-/**
- * dma_unmap_page - unmap a buffer previously mapped through dma_map_page()
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @handle: DMA address of buffer
- * @size: size of buffer (same as passed to dma_map_page)
- * @dir: DMA transfer direction (same as passed to dma_map_page)
- *
- * Unmap a page streaming mode DMA translation.  The handle and size
- * must match what was provided in the previous dma_map_page() call.
- * All other usages are undefined.
- *
- * After this call, reads by the CPU to the buffer are guaranteed to see
- * whatever the device wrote there.
- */
-static inline void dma_unmap_page(struct device *dev, dma_addr_t handle,
-		size_t size, enum dma_data_direction dir)
-{
-	debug_dma_unmap_page(dev, handle, size, dir, false);
-	__dma_unmap_page(dev, handle, size, dir);
-}
-
-
-static inline void dma_sync_single_for_cpu(struct device *dev,
-		dma_addr_t handle, size_t size, enum dma_data_direction dir)
-{
-	BUG_ON(!valid_dma_direction(dir));
-
-	debug_dma_sync_single_for_cpu(dev, handle, size, dir);
-
-	if (!dmabounce_sync_for_cpu(dev, handle, size, dir))
-		return;
-
-	__dma_single_dev_to_cpu(dma_to_virt(dev, handle), size, dir);
-}
-
-static inline void dma_sync_single_for_device(struct device *dev,
-		dma_addr_t handle, size_t size, enum dma_data_direction dir)
-{
-	BUG_ON(!valid_dma_direction(dir));
-
-	debug_dma_sync_single_for_device(dev, handle, size, dir);
-
-	if (!dmabounce_sync_for_device(dev, handle, size, dir))
-		return;
-
-	__dma_single_cpu_to_dev(dma_to_virt(dev, handle), size, dir);
-}
-
-/**
- * dma_sync_single_range_for_cpu
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @handle: DMA address of buffer
- * @offset: offset of region to start sync
- * @size: size of region to sync
- * @dir: DMA transfer direction (same as passed to dma_map_single)
- *
- * Make physical memory consistent for a single streaming mode DMA
- * translation after a transfer.
- *
- * If you perform a dma_map_single() but wish to interrogate the
- * buffer using the cpu, yet do not wish to teardown the PCI dma
- * mapping, you must call this function before doing so.  At the
- * next point you give the PCI dma address back to the card, you
- * must first the perform a dma_sync_for_device, and then the
- * device again owns the buffer.
- */
-static inline void dma_sync_single_range_for_cpu(struct device *dev,
-		dma_addr_t handle, unsigned long offset, size_t size,
-		enum dma_data_direction dir)
-{
-	dma_sync_single_for_cpu(dev, handle + offset, size, dir);
-}
-
-static inline void dma_sync_single_range_for_device(struct device *dev,
-		dma_addr_t handle, unsigned long offset, size_t size,
-		enum dma_data_direction dir)
-{
-	dma_sync_single_for_device(dev, handle + offset, size, dir);
-}
-
 /*
  * The scatter list versions of the above methods.
  */
-extern int dma_map_sg(struct device *, struct scatterlist *, int,
-		enum dma_data_direction);
-extern void dma_unmap_sg(struct device *, struct scatterlist *, int,
+extern int arm_dma_map_sg(struct device *, struct scatterlist *, int,
+		enum dma_data_direction, struct dma_attrs *attrs);
+extern void arm_dma_unmap_sg(struct device *, struct scatterlist *, int,
+		enum dma_data_direction, struct dma_attrs *attrs);
+extern void arm_dma_sync_sg_for_cpu(struct device *, struct scatterlist *, int,
 		enum dma_data_direction);
-extern void dma_sync_sg_for_cpu(struct device *, struct scatterlist *, int,
+extern void arm_dma_sync_sg_for_device(struct device *, struct scatterlist *, int,
 		enum dma_data_direction);
-extern void dma_sync_sg_for_device(struct device *, struct scatterlist *, int,
-		enum dma_data_direction);
-
 
 #endif /* __KERNEL__ */
 #endif
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index efbdc6e..31692dc 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -33,6 +33,86 @@
 
 #include "mm.h"
 
+/**
+ * dma_map_page - map a portion of a page for streaming DMA
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @page: page that buffer resides in
+ * @offset: offset into page for start of buffer
+ * @size: size of buffer to map
+ * @dir: DMA transfer direction
+ *
+ * Ensure that any data held in the cache is appropriately discarded
+ * or written back.
+ *
+ * The device owns this memory once this call has completed.  The CPU
+ * can regain ownership by calling dma_unmap_page().
+ */
+static inline dma_addr_t arm_dma_map_page(struct device *dev, struct page *page,
+	     unsigned long offset, size_t size, enum dma_data_direction dir,
+	     struct dma_attrs *attrs)
+{
+	return __dma_map_page(dev, page, offset, size, dir);
+}
+
+/**
+ * dma_unmap_page - unmap a buffer previously mapped through dma_map_page()
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @handle: DMA address of buffer
+ * @size: size of buffer (same as passed to dma_map_page)
+ * @dir: DMA transfer direction (same as passed to dma_map_page)
+ *
+ * Unmap a page streaming mode DMA translation.  The handle and size
+ * must match what was provided in the previous dma_map_page() call.
+ * All other usages are undefined.
+ *
+ * After this call, reads by the CPU to the buffer are guaranteed to see
+ * whatever the device wrote there.
+ */
+
+static inline void arm_dma_unmap_page(struct device *dev, dma_addr_t handle,
+		size_t size, enum dma_data_direction dir,
+		struct dma_attrs *attrs)
+{
+	__dma_unmap_page(dev, handle, size, dir);
+}
+
+static inline void arm_dma_sync_single_for_cpu(struct device *dev,
+		dma_addr_t handle, size_t size, enum dma_data_direction dir)
+{
+	unsigned int offset = handle & (PAGE_SIZE - 1);
+	struct page *page = pfn_to_page(dma_to_pfn(dev, handle-offset));
+	if (!dmabounce_sync_for_cpu(dev, handle, size, dir))
+		return;
+
+	__dma_page_dev_to_cpu(page, offset, size, dir);
+}
+
+static inline void arm_dma_sync_single_for_device(struct device *dev,
+		dma_addr_t handle, size_t size, enum dma_data_direction dir)
+{
+	unsigned int offset = handle & (PAGE_SIZE - 1);
+	struct page *page = pfn_to_page(dma_to_pfn(dev, handle-offset));
+	if (!dmabounce_sync_for_device(dev, handle, size, dir))
+		return;
+
+	__dma_page_cpu_to_dev(page, offset, size, dir);
+}
+
+static int arm_dma_set_mask(struct device *dev, u64 dma_mask);
+
+struct dma_map_ops arm_dma_ops = {
+	.map_page		= arm_dma_map_page,
+	.unmap_page		= arm_dma_unmap_page,
+	.map_sg			= arm_dma_map_sg,
+	.unmap_sg		= arm_dma_unmap_sg,
+	.sync_single_for_cpu	= arm_dma_sync_single_for_cpu,
+	.sync_single_for_device	= arm_dma_sync_single_for_device,
+	.sync_sg_for_cpu	= arm_dma_sync_sg_for_cpu,
+	.sync_sg_for_device	= arm_dma_sync_sg_for_device,
+	.set_dma_mask		= arm_dma_set_mask,
+};
+EXPORT_SYMBOL(arm_dma_ops);
+
 static u64 get_coherent_dma_mask(struct device *dev)
 {
 	u64 mask = (u64)arm_dma_limit;
@@ -676,47 +756,6 @@ void dma_free_coherent(struct device *dev, size_t size, void *cpu_addr, dma_addr
 }
 EXPORT_SYMBOL(dma_free_coherent);
 
-/*
- * Make an area consistent for devices.
- * Note: Drivers should NOT use this function directly, as it will break
- * platforms with CONFIG_DMABOUNCE.
- * Use the driver DMA support - see dma-mapping.h (dma_sync_*)
- */
-void ___dma_single_cpu_to_dev(const void *kaddr, size_t size,
-	enum dma_data_direction dir)
-{
-	unsigned long paddr;
-
-	BUG_ON(!virt_addr_valid(kaddr) || !virt_addr_valid(kaddr + size - 1));
-
-	dmac_map_area(kaddr, size, dir);
-
-	paddr = __pa(kaddr);
-	if (dir == DMA_FROM_DEVICE) {
-		outer_inv_range(paddr, paddr + size);
-	} else {
-		outer_clean_range(paddr, paddr + size);
-	}
-	/* FIXME: non-speculating: flush on bidirectional mappings? */
-}
-EXPORT_SYMBOL(___dma_single_cpu_to_dev);
-
-void ___dma_single_dev_to_cpu(const void *kaddr, size_t size,
-	enum dma_data_direction dir)
-{
-	BUG_ON(!virt_addr_valid(kaddr) || !virt_addr_valid(kaddr + size - 1));
-
-	/* FIXME: non-speculating: not required */
-	/* don't bother invalidating if DMA to device */
-	if (dir != DMA_TO_DEVICE) {
-		unsigned long paddr = __pa(kaddr);
-		outer_inv_range(paddr, paddr + size);
-	}
-
-	dmac_unmap_area(kaddr, size, dir);
-}
-EXPORT_SYMBOL(___dma_single_dev_to_cpu);
-
 static void dma_cache_maint_page(struct page *page, unsigned long offset,
 	size_t size, enum dma_data_direction dir,
 	void (*op)(const void *, size_t, int))
@@ -814,21 +853,18 @@ EXPORT_SYMBOL(___dma_page_dev_to_cpu);
  * Device ownership issues as mentioned for dma_map_single are the same
  * here.
  */
-int dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
-		enum dma_data_direction dir)
+int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
+		enum dma_data_direction dir, struct dma_attrs *attrs)
 {
 	struct scatterlist *s;
 	int i, j;
 
-	BUG_ON(!valid_dma_direction(dir));
-
 	for_each_sg(sg, s, nents, i) {
 		s->dma_address = __dma_map_page(dev, sg_page(s), s->offset,
 						s->length, dir);
 		if (dma_mapping_error(dev, s->dma_address))
 			goto bad_mapping;
 	}
-	debug_dma_map_sg(dev, sg, nents, nents, dir);
 	return nents;
 
  bad_mapping:
@@ -836,7 +872,6 @@ int dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
 	return 0;
 }
-EXPORT_SYMBOL(dma_map_sg);
 
 /**
  * dma_unmap_sg - unmap a set of SG buffers mapped by dma_map_sg
@@ -848,18 +883,15 @@ EXPORT_SYMBOL(dma_map_sg);
  * Unmap a set of streaming mode DMA translations.  Again, CPU access
  * rules concerning calls here are the same as for dma_unmap_single().
  */
-void dma_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
-		enum dma_data_direction dir)
+void arm_dma_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
+		enum dma_data_direction dir, struct dma_attrs *attrs)
 {
 	struct scatterlist *s;
 	int i;
 
-	debug_dma_unmap_sg(dev, sg, nents, dir);
-
 	for_each_sg(sg, s, nents, i)
 		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
 }
-EXPORT_SYMBOL(dma_unmap_sg);
 
 /**
  * dma_sync_sg_for_cpu
@@ -868,7 +900,7 @@ EXPORT_SYMBOL(dma_unmap_sg);
  * @nents: number of buffers to map (returned from dma_map_sg)
  * @dir: DMA transfer direction (same as was passed to dma_map_sg)
  */
-void dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
+void arm_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 			int nents, enum dma_data_direction dir)
 {
 	struct scatterlist *s;
@@ -882,10 +914,7 @@ void dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 		__dma_page_dev_to_cpu(sg_page(s), s->offset,
 				      s->length, dir);
 	}
-
-	debug_dma_sync_sg_for_cpu(dev, sg, nents, dir);
 }
-EXPORT_SYMBOL(dma_sync_sg_for_cpu);
 
 /**
  * dma_sync_sg_for_device
@@ -894,7 +923,7 @@ EXPORT_SYMBOL(dma_sync_sg_for_cpu);
  * @nents: number of buffers to map (returned from dma_map_sg)
  * @dir: DMA transfer direction (same as was passed to dma_map_sg)
  */
-void dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
+void arm_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 			int nents, enum dma_data_direction dir)
 {
 	struct scatterlist *s;
@@ -908,10 +937,7 @@ void dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 		__dma_page_cpu_to_dev(sg_page(s), s->offset,
 				      s->length, dir);
 	}
-
-	debug_dma_sync_sg_for_device(dev, sg, nents, dir);
 }
-EXPORT_SYMBOL(dma_sync_sg_for_device);
 
 /*
  * Return whether the given device DMA address mask can be supported
@@ -927,7 +953,7 @@ int dma_supported(struct device *dev, u64 mask)
 }
 EXPORT_SYMBOL(dma_supported);
 
-int dma_set_mask(struct device *dev, u64 dma_mask)
+static int arm_dma_set_mask(struct device *dev, u64 dma_mask)
 {
 	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
 		return -EIO;
@@ -938,7 +964,6 @@ int dma_set_mask(struct device *dev, u64 dma_mask)
 
 	return 0;
 }
-EXPORT_SYMBOL(dma_set_mask);
 
 #define PREALLOC_DMA_DEBUG_ENTRIES	4096
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
