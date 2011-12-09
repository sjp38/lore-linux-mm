Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 650646B005C
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 11:40:10 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LVY004943MWGK70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 09 Dec 2011 16:40:08 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LVY00AWH3MVNK@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 09 Dec 2011 16:40:08 +0000 (GMT)
Date: Fri, 09 Dec 2011 17:39:54 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 4/8] ARM: dma-mapping: move all dma bounce code to separate dma
 ops structure
In-reply-to: <1323448798-18184-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1323448798-18184-5-git-send-email-m.szyprowski@samsung.com>
References: <1323448798-18184-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This patch removes dma bounce hooks from the common dma mapping
implementation on ARM architecture and creates a separate set of
dma_map_ops for dma bounce devices.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/common/dmabounce.c        |   62 ++++++++++++++++++-----
 arch/arm/include/asm/dma-mapping.h |   99 +-----------------------------------
 arch/arm/mm/dma-mapping.c          |   79 +++++++++++++++++++++++++----
 3 files changed, 120 insertions(+), 120 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 46b4b8d..5e7ba61 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -308,8 +308,9 @@ static inline void unmap_single(struct device *dev, struct safe_buffer *buf,
  * substitute the safe buffer for the unsafe one.
  * (basically move the buffer from an unsafe area to a safe one)
  */
-dma_addr_t __dma_map_page(struct device *dev, struct page *page,
-		unsigned long offset, size_t size, enum dma_data_direction dir)
+static dma_addr_t dmabounce_map_page(struct device *dev, struct page *page,
+		unsigned long offset, size_t size, enum dma_data_direction dir,
+		struct dma_attrs *attrs)
 {
 	dma_addr_t dma_addr;
 	int ret;
@@ -324,7 +325,7 @@ dma_addr_t __dma_map_page(struct device *dev, struct page *page,
 		return ~0;
 
 	if (ret == 0) {
-		__dma_page_cpu_to_dev(page, offset, size, dir);
+		arm_dma_ops.sync_single_for_device(dev, dma_addr, size, dir);
 		return dma_addr;
 	}
 
@@ -335,7 +336,6 @@ dma_addr_t __dma_map_page(struct device *dev, struct page *page,
 
 	return map_single(dev, page_address(page) + offset, size, dir);
 }
-EXPORT_SYMBOL(__dma_map_page);
 
 /*
  * see if a mapped address was really a "safe" buffer and if so, copy
@@ -343,8 +343,8 @@ EXPORT_SYMBOL(__dma_map_page);
  * the safe buffer.  (basically return things back to the way they
  * should be)
  */
-void __dma_unmap_page(struct device *dev, dma_addr_t dma_addr, size_t size,
-		enum dma_data_direction dir)
+static void dmabounce_unmap_page(struct device *dev, dma_addr_t dma_addr, size_t size,
+		enum dma_data_direction dir, struct dma_attrs *attrs)
 {
 	struct safe_buffer *buf;
 
@@ -353,16 +353,14 @@ void __dma_unmap_page(struct device *dev, dma_addr_t dma_addr, size_t size,
 
 	buf = find_safe_buffer_dev(dev, dma_addr, __func__);
 	if (!buf) {
-		__dma_page_dev_to_cpu(pfn_to_page(dma_to_pfn(dev, dma_addr)),
-			dma_addr & ~PAGE_MASK, size, dir);
+		arm_dma_ops.sync_single_for_cpu(dev, dma_addr, size, dir);
 		return;
 	}
 
 	unmap_single(dev, buf, size, dir);
 }
-EXPORT_SYMBOL(__dma_unmap_page);
 
-int dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
+static int __dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
 		size_t sz, enum dma_data_direction dir)
 {
 	struct safe_buffer *buf;
@@ -392,9 +390,17 @@ int dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
 	}
 	return 0;
 }
-EXPORT_SYMBOL(dmabounce_sync_for_cpu);
 
-int dmabounce_sync_for_device(struct device *dev, dma_addr_t addr,
+static void dmabounce_sync_for_cpu(struct device *dev,
+		dma_addr_t handle, size_t size, enum dma_data_direction dir)
+{
+	if (!__dmabounce_sync_for_cpu(dev, handle, size, dir))
+		return;
+
+	arm_dma_ops.sync_single_for_cpu(dev, handle, size, dir);
+}
+
+static int __dmabounce_sync_for_device(struct device *dev, dma_addr_t addr,
 		size_t sz, enum dma_data_direction dir)
 {
 	struct safe_buffer *buf;
@@ -424,7 +430,35 @@ int dmabounce_sync_for_device(struct device *dev, dma_addr_t addr,
 	}
 	return 0;
 }
-EXPORT_SYMBOL(dmabounce_sync_for_device);
+
+static void dmabounce_sync_for_device(struct device *dev,
+		dma_addr_t handle, size_t size, enum dma_data_direction dir)
+{
+	if (!__dmabounce_sync_for_device(dev, handle, size, dir))
+		return;
+
+	arm_dma_ops.sync_single_for_device(dev, handle, size, dir);
+}
+
+static int dmabounce_set_mask(struct device *dev, u64 dma_mask)
+{
+	if (dev->archdata.dmabounce)
+		return 0;
+
+	return arm_dma_ops.set_dma_mask(dev, dma_mask);
+}
+
+static struct dma_map_ops dmabounce_ops = {
+	.map_page		= dmabounce_map_page,
+	.unmap_page		= dmabounce_unmap_page,
+	.sync_single_for_cpu	= dmabounce_sync_for_cpu,
+	.sync_single_for_device	= dmabounce_sync_for_device,
+	.map_sg			= generic_dma_map_sg,
+	.unmap_sg		= generic_dma_unmap_sg,
+	.sync_sg_for_cpu	= generic_dma_sync_sg_for_cpu,
+	.sync_sg_for_device	= generic_dma_sync_sg_for_device,
+	.set_dma_mask		= dmabounce_set_mask,
+};
 
 static int dmabounce_init_pool(struct dmabounce_pool *pool, struct device *dev,
 		const char *name, unsigned long size)
@@ -486,6 +520,7 @@ int dmabounce_register_dev(struct device *dev, unsigned long small_buffer_size,
 #endif
 
 	dev->archdata.dmabounce = device_info;
+	set_dma_ops(dev, &dmabounce_ops);
 
 	dev_info(dev, "dmabounce: registered device\n");
 
@@ -504,6 +539,7 @@ void dmabounce_unregister_dev(struct device *dev)
 	struct dmabounce_device_info *device_info = dev->archdata.dmabounce;
 
 	dev->archdata.dmabounce = NULL;
+	set_dma_ops(dev, NULL);
 
 	if (!device_info) {
 		dev_warn(dev,
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index cf7b77c..0016bff 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -84,62 +84,6 @@ static inline dma_addr_t virt_to_dma(struct device *dev, void *addr)
 #endif
 
 /*
- * The DMA API is built upon the notion of "buffer ownership".  A buffer
- * is either exclusively owned by the CPU (and therefore may be accessed
- * by it) or exclusively owned by the DMA device.  These helper functions
- * represent the transitions between these two ownership states.
- *
- * Note, however, that on later ARMs, this notion does not work due to
- * speculative prefetches.  We model our approach on the assumption that
- * the CPU does do speculative prefetches, which means we clean caches
- * before transfers and delay cache invalidation until transfer completion.
- *
- * Private support functions: these are not part of the API and are
- * liable to change.  Drivers must not use these.
- */
-static inline void __dma_single_cpu_to_dev(const void *kaddr, size_t size,
-	enum dma_data_direction dir)
-{
-	extern void ___dma_single_cpu_to_dev(const void *, size_t,
-		enum dma_data_direction);
-
-	if (!arch_is_coherent())
-		___dma_single_cpu_to_dev(kaddr, size, dir);
-}
-
-static inline void __dma_single_dev_to_cpu(const void *kaddr, size_t size,
-	enum dma_data_direction dir)
-{
-	extern void ___dma_single_dev_to_cpu(const void *, size_t,
-		enum dma_data_direction);
-
-	if (!arch_is_coherent())
-		___dma_single_dev_to_cpu(kaddr, size, dir);
-}
-
-static inline void __dma_page_cpu_to_dev(struct page *page, unsigned long off,
-	size_t size, enum dma_data_direction dir)
-{
-	extern void ___dma_page_cpu_to_dev(struct page *, unsigned long,
-		size_t, enum dma_data_direction);
-
-	if (!arch_is_coherent())
-		___dma_page_cpu_to_dev(page, off, size, dir);
-}
-
-static inline void __dma_page_dev_to_cpu(struct page *page, unsigned long off,
-	size_t size, enum dma_data_direction dir)
-{
-	extern void ___dma_page_dev_to_cpu(struct page *, unsigned long,
-		size_t, enum dma_data_direction);
-
-	if (!arch_is_coherent())
-		___dma_page_dev_to_cpu(page, off, size, dir);
-}
-
-extern int dma_supported(struct device *, u64);
-extern int dma_set_mask(struct device *, u64);
-/*
  * DMA errors are defined by all-bits-set in the DMA address.
  */
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
@@ -162,6 +106,8 @@ static inline void dma_free_noncoherent(struct device *dev, size_t size,
 {
 }
 
+extern int dma_supported(struct device *dev, u64 mask);
+
 /**
  * dma_alloc_coherent - allocate consistent memory for DMA
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
@@ -234,7 +180,6 @@ int dma_mmap_writecombine(struct device *, struct vm_area_struct *,
 extern void __init init_consistent_dma_size(unsigned long size);
 
 
-#ifdef CONFIG_DMABOUNCE
 /*
  * For SA-1111, IXP425, and ADI systems  the dma-mapping functions are "magic"
  * and utilize bounce buffers as needed to work around limited DMA windows.
@@ -274,47 +219,7 @@ extern int dmabounce_register_dev(struct device *, unsigned long,
  */
 extern void dmabounce_unregister_dev(struct device *);
 
-/*
- * The DMA API, implemented by dmabounce.c.  See below for descriptions.
- */
-extern dma_addr_t __dma_map_page(struct device *, struct page *,
-		unsigned long, size_t, enum dma_data_direction);
-extern void __dma_unmap_page(struct device *, dma_addr_t, size_t,
-		enum dma_data_direction);
-
-/*
- * Private functions
- */
-int dmabounce_sync_for_cpu(struct device *, dma_addr_t, size_t, enum dma_data_direction);
-int dmabounce_sync_for_device(struct device *, dma_addr_t, size_t, enum dma_data_direction);
-#else
-static inline int dmabounce_sync_for_cpu(struct device *d, dma_addr_t addr,
-	size_t size, enum dma_data_direction dir)
-{
-	return 1;
-}
-
-static inline int dmabounce_sync_for_device(struct device *d, dma_addr_t addr,
-	size_t size, enum dma_data_direction dir)
-{
-	return 1;
-}
-
 
-static inline dma_addr_t __dma_map_page(struct device *dev, struct page *page,
-	     unsigned long offset, size_t size, enum dma_data_direction dir)
-{
-	__dma_page_cpu_to_dev(page, offset, size, dir);
-	return pfn_to_dma(dev, page_to_pfn(page)) + offset;
-}
-
-static inline void __dma_unmap_page(struct device *dev, dma_addr_t handle,
-		size_t size, enum dma_data_direction dir)
-{
-	__dma_page_dev_to_cpu(pfn_to_page(dma_to_pfn(dev, handle)),
-		handle & ~PAGE_MASK, size, dir);
-}
-#endif /* CONFIG_DMABOUNCE */
 
 /*
  * The scatter list versions of the above methods.
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 31ff699..5715e2e 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -29,6 +29,75 @@
 
 #include "mm.h"
 
+/*
+ * The DMA API is built upon the notion of "buffer ownership".  A buffer
+ * is either exclusively owned by the CPU (and therefore may be accessed
+ * by it) or exclusively owned by the DMA device.  These helper functions
+ * represent the transitions between these two ownership states.
+ *
+ * Note, however, that on later ARMs, this notion does not work due to
+ * speculative prefetches.  We model our approach on the assumption that
+ * the CPU does do speculative prefetches, which means we clean caches
+ * before transfers and delay cache invalidation until transfer completion.
+ *
+ * Private support functions: these are not part of the API and are
+ * liable to change.  Drivers must not use these.
+ */
+static inline void __dma_single_cpu_to_dev(const void *kaddr, size_t size,
+	enum dma_data_direction dir)
+{
+	extern void ___dma_single_cpu_to_dev(const void *, size_t,
+		enum dma_data_direction);
+
+	if (!arch_is_coherent())
+		___dma_single_cpu_to_dev(kaddr, size, dir);
+}
+
+static inline void __dma_single_dev_to_cpu(const void *kaddr, size_t size,
+	enum dma_data_direction dir)
+{
+	extern void ___dma_single_dev_to_cpu(const void *, size_t,
+		enum dma_data_direction);
+
+	if (!arch_is_coherent())
+		___dma_single_dev_to_cpu(kaddr, size, dir);
+}
+
+static inline void __dma_page_cpu_to_dev(struct page *page, unsigned long off,
+	size_t size, enum dma_data_direction dir)
+{
+	extern void ___dma_page_cpu_to_dev(struct page *, unsigned long,
+		size_t, enum dma_data_direction);
+
+	if (!arch_is_coherent())
+		___dma_page_cpu_to_dev(page, off, size, dir);
+}
+
+static inline void __dma_page_dev_to_cpu(struct page *page, unsigned long off,
+	size_t size, enum dma_data_direction dir)
+{
+	extern void ___dma_page_dev_to_cpu(struct page *, unsigned long,
+		size_t, enum dma_data_direction);
+
+	if (!arch_is_coherent())
+		___dma_page_dev_to_cpu(page, off, size, dir);
+}
+
+
+static inline dma_addr_t __dma_map_page(struct device *dev, struct page *page,
+	     unsigned long offset, size_t size, enum dma_data_direction dir)
+{
+	__dma_page_cpu_to_dev(page, offset, size, dir);
+	return pfn_to_dma(dev, page_to_pfn(page)) + offset;
+}
+
+static inline void __dma_unmap_page(struct device *dev, dma_addr_t handle,
+		size_t size, enum dma_data_direction dir)
+{
+	__dma_page_dev_to_cpu(pfn_to_page(dma_to_pfn(dev, handle)),
+		handle & ~PAGE_MASK, size, dir);
+}
+
 /**
  * dma_map_page - map a portion of a page for streaming DMA
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
@@ -77,9 +146,6 @@ static inline void arm_dma_sync_single_for_cpu(struct device *dev,
 {
 	unsigned int offset = handle & (PAGE_SIZE - 1);
 	struct page *page = pfn_to_page(dma_to_pfn(dev, handle-offset));
-	if (!dmabounce_sync_for_cpu(dev, handle, size, dir))
-		return;
-
 	__dma_page_dev_to_cpu(page, offset, size, dir);
 }
 
@@ -88,9 +154,6 @@ static inline void arm_dma_sync_single_for_device(struct device *dev,
 {
 	unsigned int offset = handle & (PAGE_SIZE - 1);
 	struct page *page = pfn_to_page(dma_to_pfn(dev, handle-offset));
-	if (!dmabounce_sync_for_device(dev, handle, size, dir))
-		return;
-
 	__dma_page_cpu_to_dev(page, offset, size, dir);
 }
 
@@ -594,7 +657,6 @@ void ___dma_page_cpu_to_dev(struct page *page, unsigned long off,
 	}
 	/* FIXME: non-speculating: flush on bidirectional mappings? */
 }
-EXPORT_SYMBOL(___dma_page_cpu_to_dev);
 
 void ___dma_page_dev_to_cpu(struct page *page, unsigned long off,
 	size_t size, enum dma_data_direction dir)
@@ -614,7 +676,6 @@ void ___dma_page_dev_to_cpu(struct page *page, unsigned long off,
 	if (dir != DMA_TO_DEVICE && off == 0 && size >= PAGE_SIZE)
 		set_bit(PG_dcache_clean, &page->flags);
 }
-EXPORT_SYMBOL(___dma_page_dev_to_cpu);
 
 /**
  * dma_map_sg - map a set of SG buffers for streaming mode DMA
@@ -732,9 +793,7 @@ static int arm_dma_set_mask(struct device *dev, u64 dma_mask)
 	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
 		return -EIO;
 
-#ifndef CONFIG_DMABOUNCE
 	*dev->dma_mask = dma_mask;
-#endif
 
 	return 0;
 }
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
