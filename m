Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 07ED86B0082
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 03:50:37 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LN2008Y9WGAOG70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 08:50:34 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN200E92WG8NI@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 08:50:33 +0100 (BST)
Date: Mon, 20 Jun 2011 09:50:07 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 2/8] ARM: dma-mapping: implement dma_map_single on top of
 dma_map_page
In-reply-to: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1308556213-24970-3-git-send-email-m.szyprowski@samsung.com>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

This patch consolidates dma_map_single and dma_map_page calls. This is
required to let dma-mapping framework on ARM architecture use common,
generic dma-mapping helpers.

Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 arch/arm/common/dmabounce.c        |   28 ----------
 arch/arm/include/asm/dma-mapping.h |  100 +++++++++++++----------------------
 2 files changed, 37 insertions(+), 91 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index f7b330f..9eb161e 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -329,34 +329,6 @@ static inline void unmap_single(struct device *dev, dma_addr_t dma_addr,
  * substitute the safe buffer for the unsafe one.
  * (basically move the buffer from an unsafe area to a safe one)
  */
-dma_addr_t __dma_map_single(struct device *dev, void *ptr, size_t size,
-		enum dma_data_direction dir)
-{
-	dev_dbg(dev, "%s(ptr=%p,size=%d,dir=%x)\n",
-		__func__, ptr, size, dir);
-
-	BUG_ON(!valid_dma_direction(dir));
-
-	return map_single(dev, ptr, size, dir);
-}
-EXPORT_SYMBOL(__dma_map_single);
-
-/*
- * see if a mapped address was really a "safe" buffer and if so, copy
- * the data from the safe buffer back to the unsafe buffer and free up
- * the safe buffer.  (basically return things back to the way they
- * should be)
- */
-void __dma_unmap_single(struct device *dev, dma_addr_t dma_addr, size_t size,
-		enum dma_data_direction dir)
-{
-	dev_dbg(dev, "%s(ptr=%p,size=%d,dir=%x)\n",
-		__func__, (void *) dma_addr, size, dir);
-
-	unmap_single(dev, dma_addr, size, dir);
-}
-EXPORT_SYMBOL(__dma_unmap_single);
-
 dma_addr_t __dma_map_page(struct device *dev, struct page *page,
 		unsigned long offset, size_t size, enum dma_data_direction dir)
 {
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index ca920aa..799669d 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -298,10 +298,6 @@ extern int dma_needs_bounce(struct device*, dma_addr_t, size_t);
 /*
  * The DMA API, implemented by dmabounce.c.  See below for descriptions.
  */
-extern dma_addr_t __dma_map_single(struct device *, void *, size_t,
-		enum dma_data_direction);
-extern void __dma_unmap_single(struct device *, dma_addr_t, size_t,
-		enum dma_data_direction);
 extern dma_addr_t __dma_map_page(struct device *, struct page *,
 		unsigned long, size_t, enum dma_data_direction);
 extern void __dma_unmap_page(struct device *, dma_addr_t, size_t,
@@ -325,14 +321,6 @@ static inline int dmabounce_sync_for_device(struct device *d, dma_addr_t addr,
 	return 1;
 }
 
-
-static inline dma_addr_t __dma_map_single(struct device *dev, void *cpu_addr,
-		size_t size, enum dma_data_direction dir)
-{
-	__dma_single_cpu_to_dev(cpu_addr, size, dir);
-	return virt_to_dma(dev, cpu_addr);
-}
-
 static inline dma_addr_t __dma_map_page(struct device *dev, struct page *page,
 	     unsigned long offset, size_t size, enum dma_data_direction dir)
 {
@@ -340,12 +328,6 @@ static inline dma_addr_t __dma_map_page(struct device *dev, struct page *page,
 	return pfn_to_dma(dev, page_to_pfn(page)) + offset;
 }
 
-static inline void __dma_unmap_single(struct device *dev, dma_addr_t handle,
-		size_t size, enum dma_data_direction dir)
-{
-	__dma_single_dev_to_cpu(dma_to_virt(dev, handle), size, dir);
-}
-
 static inline void __dma_unmap_page(struct device *dev, dma_addr_t handle,
 		size_t size, enum dma_data_direction dir)
 {
@@ -354,34 +336,6 @@ static inline void __dma_unmap_page(struct device *dev, dma_addr_t handle,
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
-	dma_addr_t addr;
-
-	BUG_ON(!valid_dma_direction(dir));
-
-	addr = __dma_map_single(dev, cpu_addr, size, dir);
-	debug_dma_map_page(dev, virt_to_page(cpu_addr),
-			(unsigned long)cpu_addr & ~PAGE_MASK, size,
-			dir, addr, true);
-
-	return addr;
-}
 
 /**
  * dma_map_page - map a portion of a page for streaming DMA
@@ -411,48 +365,68 @@ static inline dma_addr_t dma_map_page(struct device *dev, struct page *page,
 }
 
 /**
- * dma_unmap_single - unmap a single buffer previously mapped
+ * dma_unmap_page - unmap a buffer previously mapped through dma_map_page()
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
  * @handle: DMA address of buffer
- * @size: size of buffer (same as passed to dma_map_single)
- * @dir: DMA transfer direction (same as passed to dma_map_single)
+ * @size: size of buffer (same as passed to dma_map_page)
+ * @dir: DMA transfer direction (same as passed to dma_map_page)
  *
- * Unmap a single streaming mode DMA translation.  The handle and size
- * must match what was provided in the previous dma_map_single() call.
+ * Unmap a page streaming mode DMA translation.  The handle and size
+ * must match what was provided in the previous dma_map_page() call.
  * All other usages are undefined.
  *
  * After this call, reads by the CPU to the buffer are guaranteed to see
  * whatever the device wrote there.
  */
-static inline void dma_unmap_single(struct device *dev, dma_addr_t handle,
+
+static inline void dma_unmap_page(struct device *dev, dma_addr_t handle,
 		size_t size, enum dma_data_direction dir)
 {
-	debug_dma_unmap_page(dev, handle, size, dir, true);
-	__dma_unmap_single(dev, handle, size, dir);
+	debug_dma_unmap_page(dev, handle, size, dir, false);
+	__dma_unmap_page(dev, handle, size, dir);
 }
 
 /**
- * dma_unmap_page - unmap a buffer previously mapped through dma_map_page()
+ * dma_map_single - map a single buffer for streaming DMA
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @cpu_addr: CPU direct mapped address of buffer
+ * @size: size of buffer to map
+ * @dir: DMA transfer direction
+ *
+ * Ensure that any data held in the cache is appropriately discarded
+ * or written back.
+ *
+ * The device owns this memory once this call has completed.  The CPU
+ * can regain ownership by calling dma_unmap_single() or
+ * dma_sync_single_for_cpu().
+ */
+static inline dma_addr_t dma_map_single(struct device *dev, void *cpu_addr,
+		size_t size, enum dma_data_direction dir)
+{
+	return dma_map_page(dev, virt_to_page(cpu_addr),
+			    (unsigned long)cpu_addr & ~PAGE_MASK, size, dir);
+}
+
+/**
+ * dma_unmap_single - unmap a single buffer previously mapped
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
  * @handle: DMA address of buffer
- * @size: size of buffer (same as passed to dma_map_page)
- * @dir: DMA transfer direction (same as passed to dma_map_page)
+ * @size: size of buffer (same as passed to dma_map_single)
+ * @dir: DMA transfer direction (same as passed to dma_map_single)
  *
- * Unmap a page streaming mode DMA translation.  The handle and size
- * must match what was provided in the previous dma_map_page() call.
+ * Unmap a single streaming mode DMA translation.  The handle and size
+ * must match what was provided in the previous dma_map_single() call.
  * All other usages are undefined.
  *
  * After this call, reads by the CPU to the buffer are guaranteed to see
  * whatever the device wrote there.
  */
-static inline void dma_unmap_page(struct device *dev, dma_addr_t handle,
+static inline void dma_unmap_single(struct device *dev, dma_addr_t handle,
 		size_t size, enum dma_data_direction dir)
 {
-	debug_dma_unmap_page(dev, handle, size, dir, false);
-	__dma_unmap_page(dev, handle, size, dir);
+	dma_unmap_page(dev, handle, size, dir);
 }
 
-
 static inline void dma_sync_single_for_cpu(struct device *dev,
 		dma_addr_t handle, size_t size, enum dma_data_direction dir)
 {
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
