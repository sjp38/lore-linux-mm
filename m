Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BC3F16B00EC
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 03:50:39 -0400 (EDT)
Received: from spt2.w1.samsung.com (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LN2009F6WG9CE@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 20 Jun 2011 08:50:34 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN200KUJWG8AK@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 08:50:33 +0100 (BST)
Date: Mon, 20 Jun 2011 09:50:08 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 3/8] ARM: dma-mapping: use asm-generic/dma-mapping-common.h
In-reply-to: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1308556213-24970-4-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

This patch modifies dma-mapping implementation on ARM architecture to
use common dma_map_ops structure and asm-generic/dma-mapping-common.h
helpers.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/Kconfig                   |    1 +
 arch/arm/include/asm/device.h      |    1 +
 arch/arm/include/asm/dma-mapping.h |  201 +++++-------------------------------
 arch/arm/mm/dma-mapping.c          |  117 +++++++++++++++++----
 4 files changed, 127 insertions(+), 193 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 9adc278..0b834c1 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -3,6 +3,7 @@ config ARM
 	default y
 	select HAVE_AOUT
 	select HAVE_DMA_API_DEBUG
+	select HAVE_DMA_ATTRS
 	select HAVE_IDE
 	select HAVE_MEMBLOCK
 	select RTC_LIB
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
index 799669d..f4e4968 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -10,6 +10,27 @@
 #include <asm-generic/dma-coherent.h>
 #include <asm/memory.h>
 
+extern struct dma_map_ops dma_ops;
+
+static inline struct dma_map_ops *get_dma_ops(struct device *dev)
+{
+	if (dev->archdata.dma_ops)
+		return dev->archdata.dma_ops;
+	return &dma_ops;
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
@@ -131,24 +152,6 @@ static inline int dma_supported(struct device *dev, u64 mask)
 	return 1;
 }
 
-static inline int dma_set_mask(struct device *dev, u64 dma_mask)
-{
-#ifdef CONFIG_DMABOUNCE
-	if (dev->archdata.dmabounce) {
-		if (dma_mask >= ISA_DMA_THRESHOLD)
-			return 0;
-		else
-			return -EIO;
-	}
-#endif
-	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
-		return -EIO;
-
-	*dev->dma_mask = dma_mask;
-
-	return 0;
-}
-
 /*
  * DMA errors are defined by all-bits-set in the DMA address.
  */
@@ -336,167 +339,17 @@ static inline void __dma_unmap_page(struct device *dev, dma_addr_t handle,
 }
 #endif /* CONFIG_DMABOUNCE */
 
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
-
-static inline void dma_unmap_page(struct device *dev, dma_addr_t handle,
-		size_t size, enum dma_data_direction dir)
-{
-	debug_dma_unmap_page(dev, handle, size, dir, false);
-	__dma_unmap_page(dev, handle, size, dir);
-}
-
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
-	return dma_map_page(dev, virt_to_page(cpu_addr),
-			    (unsigned long)cpu_addr & ~PAGE_MASK, size, dir);
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
-	dma_unmap_page(dev, handle, size, dir);
-}
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
index c11f234..5264552 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -25,6 +25,98 @@
 #include <asm/tlbflush.h>
 #include <asm/sizes.h>
 
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
+	if (!dmabounce_sync_for_cpu(dev, handle, size, dir))
+		return;
+
+	__dma_single_dev_to_cpu(dma_to_virt(dev, handle), size, dir);
+}
+
+static inline void arm_dma_sync_single_for_device(struct device *dev,
+		dma_addr_t handle, size_t size, enum dma_data_direction dir)
+{
+	if (!dmabounce_sync_for_device(dev, handle, size, dir))
+		return;
+
+	__dma_single_cpu_to_dev(dma_to_virt(dev, handle), size, dir);
+}
+
+static int arm_dma_set_mask(struct device *dev, u64 dma_mask)
+{
+#ifdef CONFIG_DMABOUNCE
+	if (dev->archdata.dmabounce) {
+		if (dma_mask >= ISA_DMA_THRESHOLD)
+			return 0;
+		else
+			return -EIO;
+	}
+#endif
+	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
+		return -EIO;
+
+	*dev->dma_mask = dma_mask;
+
+	return 0;
+}
+
+struct dma_map_ops dma_ops = {
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
+EXPORT_SYMBOL(dma_ops);
+
 static u64 get_coherent_dma_mask(struct device *dev)
 {
 	u64 mask = ISA_DMA_THRESHOLD;
@@ -558,21 +650,18 @@ EXPORT_SYMBOL(___dma_page_dev_to_cpu);
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
@@ -580,7 +669,6 @@ int dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
 	return 0;
 }
-EXPORT_SYMBOL(dma_map_sg);
 
 /**
  * dma_unmap_sg - unmap a set of SG buffers mapped by dma_map_sg
@@ -592,18 +680,15 @@ EXPORT_SYMBOL(dma_map_sg);
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
@@ -612,7 +697,7 @@ EXPORT_SYMBOL(dma_unmap_sg);
  * @nents: number of buffers to map (returned from dma_map_sg)
  * @dir: DMA transfer direction (same as was passed to dma_map_sg)
  */
-void dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
+void arm_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 			int nents, enum dma_data_direction dir)
 {
 	struct scatterlist *s;
@@ -626,10 +711,7 @@ void dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 		__dma_page_dev_to_cpu(sg_page(s), s->offset,
 				      s->length, dir);
 	}
-
-	debug_dma_sync_sg_for_cpu(dev, sg, nents, dir);
 }
-EXPORT_SYMBOL(dma_sync_sg_for_cpu);
 
 /**
  * dma_sync_sg_for_device
@@ -638,7 +720,7 @@ EXPORT_SYMBOL(dma_sync_sg_for_cpu);
  * @nents: number of buffers to map (returned from dma_map_sg)
  * @dir: DMA transfer direction (same as was passed to dma_map_sg)
  */
-void dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
+void arm_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 			int nents, enum dma_data_direction dir)
 {
 	struct scatterlist *s;
@@ -652,10 +734,7 @@ void dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 		__dma_page_cpu_to_dev(sg_page(s), s->offset,
 				      s->length, dir);
 	}
-
-	debug_dma_sync_sg_for_device(dev, sg, nents, dir);
 }
-EXPORT_SYMBOL(dma_sync_sg_for_device);
 
 #define PREALLOC_DMA_DEBUG_ENTRIES	4096
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
