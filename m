Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DC6806B0083
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 03:50:38 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LN2005BOWGAUJ40@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 08:50:35 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN200J56WG9UE@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 08:50:34 +0100 (BST)
Date: Mon, 20 Jun 2011 09:50:10 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 5/8] ARM: dma-mapping: move all dma bounce code to separate dma
 ops structure
In-reply-to: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1308556213-24970-6-git-send-email-m.szyprowski@samsung.com>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

This patch removes dma bounce hooks from the common dma mapping
implementation on ARM architecture and creates a separate set of
dma_map_ops for dma bounce devices.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/common/dmabounce.c        |   68 ++++++++++++++++++++------
 arch/arm/include/asm/dma-mapping.h |   96 ------------------------------------
 arch/arm/mm/dma-mapping.c          |   83 ++++++++++++++++++++++++++-----
 3 files changed, 122 insertions(+), 125 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 9eb161e..5b411ef 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -256,7 +256,7 @@ static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
 		if (buf == 0) {
 			dev_err(dev, "%s: unable to map unsafe buffer %p!\n",
 			       __func__, ptr);
-			return 0;
+			return ~0;
 		}
 
 		dev_dbg(dev,
@@ -278,7 +278,7 @@ static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
 		 * We don't need to sync the DMA buffer since
 		 * it was allocated via the coherent allocators.
 		 */
-		__dma_single_cpu_to_dev(ptr, size, dir);
+		dma_ops.sync_single_for_device(dev, dma_addr, size, dir);
 	}
 
 	return dma_addr;
@@ -317,7 +317,7 @@ static inline void unmap_single(struct device *dev, dma_addr_t dma_addr,
 		}
 		free_safe_buffer(dev->archdata.dmabounce, buf);
 	} else {
-		__dma_single_dev_to_cpu(dma_to_virt(dev, dma_addr), size, dir);
+		dma_ops.sync_single_for_cpu(dev, dma_addr, size, dir);
 	}
 }
 
@@ -329,14 +329,13 @@ static inline void unmap_single(struct device *dev, dma_addr_t dma_addr,
  * substitute the safe buffer for the unsafe one.
  * (basically move the buffer from an unsafe area to a safe one)
  */
-dma_addr_t __dma_map_page(struct device *dev, struct page *page,
-		unsigned long offset, size_t size, enum dma_data_direction dir)
+static dma_addr_t dmabounce_map_page(struct device *dev, struct page *page,
+		unsigned long offset, size_t size, enum dma_data_direction dir,
+		struct dma_attrs *attrs)
 {
 	dev_dbg(dev, "%s(page=%p,off=%#lx,size=%zx,dir=%x)\n",
 		__func__, page, offset, size, dir);
 
-	BUG_ON(!valid_dma_direction(dir));
-
 	if (PageHighMem(page)) {
 		dev_err(dev, "DMA buffer bouncing of HIGHMEM pages "
 			     "is not supported\n");
@@ -345,7 +344,6 @@ dma_addr_t __dma_map_page(struct device *dev, struct page *page,
 
 	return map_single(dev, page_address(page) + offset, size, dir);
 }
-EXPORT_SYMBOL(__dma_map_page);
 
 /*
  * see if a mapped address was really a "safe" buffer and if so, copy
@@ -353,17 +351,16 @@ EXPORT_SYMBOL(__dma_map_page);
  * the safe buffer.  (basically return things back to the way they
  * should be)
  */
-void __dma_unmap_page(struct device *dev, dma_addr_t dma_addr, size_t size,
-		enum dma_data_direction dir)
+static void dmabounce_unmap_page(struct device *dev, dma_addr_t dma_addr, size_t size,
+		enum dma_data_direction dir, struct dma_attrs *attrs)
 {
 	dev_dbg(dev, "%s(ptr=%p,size=%d,dir=%x)\n",
 		__func__, (void *) dma_addr, size, dir);
 
 	unmap_single(dev, dma_addr, size, dir);
 }
-EXPORT_SYMBOL(__dma_unmap_page);
 
-int dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
+static int __dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
 		size_t sz, enum dma_data_direction dir)
 {
 	struct safe_buffer *buf;
@@ -393,9 +390,17 @@ int dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
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
+	dma_ops.sync_single_for_cpu(dev, handle, size, dir);
+}
+
+static int __dmabounce_sync_for_device(struct device *dev, dma_addr_t addr,
 		size_t sz, enum dma_data_direction dir)
 {
 	struct safe_buffer *buf;
@@ -425,7 +430,38 @@ int dmabounce_sync_for_device(struct device *dev, dma_addr_t addr,
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
+	dma_ops.sync_single_for_device(dev, handle, size, dir);
+}
+
+static int dmabounce_set_mask(struct device *dev, u64 dma_mask)
+{
+	if (dev->archdata.dmabounce) {
+		if (dma_mask >= ISA_DMA_THRESHOLD)
+			return 0;
+		else
+			return -EIO;
+	}
+	return dma_ops.set_dma_mask(dev, dma_mask);
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
@@ -485,6 +521,7 @@ int dmabounce_register_dev(struct device *dev, unsigned long small_buffer_size,
 #endif
 
 	dev->archdata.dmabounce = device_info;
+	set_dma_ops(dev, &dmabounce_ops);
 
 	dev_info(dev, "dmabounce: registered device\n");
 
@@ -503,6 +540,7 @@ void dmabounce_unregister_dev(struct device *dev)
 	struct dmabounce_device_info *device_info = dev->archdata.dmabounce;
 
 	dev->archdata.dmabounce = NULL;
+	set_dma_ops(dev, NULL);
 
 	if (!device_info) {
 		dev_warn(dev,
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index fa73efc..7ceec8f 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -83,60 +83,6 @@ static inline dma_addr_t virt_to_dma(struct device *dev, void *addr)
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
-/*
  * Return whether the given device DMA address mask can be supported
  * properly.  For example, if your device can only drive the low 24-bits
  * during bus mastering, then you would pass 0x00ffffff as the mask
@@ -240,7 +186,6 @@ int dma_mmap_writecombine(struct device *, struct vm_area_struct *,
 		void *, dma_addr_t, size_t);
 
 
-#ifdef CONFIG_DMABOUNCE
 /*
  * For SA-1111, IXP425, and ADI systems  the dma-mapping functions are "magic"
  * and utilize bounce buffers as needed to work around limited DMA windows.
@@ -299,47 +244,6 @@ extern void dmabounce_unregister_dev(struct device *);
 extern int dma_needs_bounce(struct device*, dma_addr_t, size_t);
 
 /*
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
-	unsigned long offset, size_t size, enum dma_data_direction dir)
-{
-	return 1;
-}
-
-static inline int dmabounce_sync_for_device(struct device *d, dma_addr_t addr,
-	unsigned long offset, size_t size, enum dma_data_direction dir)
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
-
-/*
  * The generic scatter list versions of dma methods.
  */
 extern int generic_dma_map_sg(struct device *, struct scatterlist *, int,
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index ebbd76c..9536481 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -25,6 +25,75 @@
 #include <asm/tlbflush.h>
 #include <asm/sizes.h>
 
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
@@ -71,31 +140,17 @@ static inline void arm_dma_unmap_page(struct device *dev, dma_addr_t handle,
 static inline void arm_dma_sync_single_for_cpu(struct device *dev,
 		dma_addr_t handle, size_t size, enum dma_data_direction dir)
 {
-	if (!dmabounce_sync_for_cpu(dev, handle, size, dir))
-		return;
-
 	__dma_single_dev_to_cpu(dma_to_virt(dev, handle), size, dir);
 }
 
 static inline void arm_dma_sync_single_for_device(struct device *dev,
 		dma_addr_t handle, size_t size, enum dma_data_direction dir)
 {
-	if (!dmabounce_sync_for_device(dev, handle, size, dir))
-		return;
-
 	__dma_single_cpu_to_dev(dma_to_virt(dev, handle), size, dir);
 }
 
 static int arm_dma_set_mask(struct device *dev, u64 dma_mask)
 {
-#ifdef CONFIG_DMABOUNCE
-	if (dev->archdata.dmabounce) {
-		if (dma_mask >= ISA_DMA_THRESHOLD)
-			return 0;
-		else
-			return -EIO;
-	}
-#endif
 	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
 		return -EIO;
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
