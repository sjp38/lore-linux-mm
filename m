Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 361E96B00E8
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 03:50:39 -0400 (EDT)
Received: from spt2.w1.samsung.com (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LN2007F8WGB02@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 20 Jun 2011 08:50:35 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN200H58WG9KG@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 08:50:34 +0100 (BST)
Date: Mon, 20 Jun 2011 09:50:11 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 6/8] ARM: dma-mapping: remove redundant code and cleanup
In-reply-to: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1308556213-24970-7-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

This patch just performs a global cleanup in DMA mapping implementation
for ARM architecture. Some of the tiny helper functions have been moved
to the caller code, some have been merged together.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/mm/dma-mapping.c |  133 +++++++++------------------------------------
 1 files changed, 26 insertions(+), 107 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 9536481..7c62e60 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -36,64 +36,12 @@
  * the CPU does do speculative prefetches, which means we clean caches
  * before transfers and delay cache invalidation until transfer completion.
  *
- * Private support functions: these are not part of the API and are
- * liable to change.  Drivers must not use these.
  */
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
+static void __dma_page_cpu_to_dev(struct page *, unsigned long,
 		size_t, enum dma_data_direction);
-
-	if (!arch_is_coherent())
-		___dma_page_cpu_to_dev(page, off, size, dir);
-}
-
-static inline void __dma_page_dev_to_cpu(struct page *page, unsigned long off,
-	size_t size, enum dma_data_direction dir)
-{
-	extern void ___dma_page_dev_to_cpu(struct page *, unsigned long,
+static void __dma_page_dev_to_cpu(struct page *, unsigned long,
 		size_t, enum dma_data_direction);
 
-	if (!arch_is_coherent())
-		___dma_page_dev_to_cpu(page, off, size, dir);
-}
-
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
-
 /**
  * dma_map_page - map a portion of a page for streaming DMA
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
@@ -108,11 +56,13 @@ static inline void __dma_unmap_page(struct device *dev, dma_addr_t handle,
  * The device owns this memory once this call has completed.  The CPU
  * can regain ownership by calling dma_unmap_page().
  */
-static inline dma_addr_t arm_dma_map_page(struct device *dev, struct page *page,
+static dma_addr_t arm_dma_map_page(struct device *dev, struct page *page,
 	     unsigned long offset, size_t size, enum dma_data_direction dir,
 	     struct dma_attrs *attrs)
 {
-	return __dma_map_page(dev, page, offset, size, dir);
+	if (!arch_is_coherent())
+		__dma_page_cpu_to_dev(page, offset, size, dir);
+	return pfn_to_dma(dev, page_to_pfn(page)) + offset;
 }
 
 /**
@@ -130,23 +80,29 @@ static inline dma_addr_t arm_dma_map_page(struct device *dev, struct page *page,
  * whatever the device wrote there.
  */
 
-static inline void arm_dma_unmap_page(struct device *dev, dma_addr_t handle,
+static void arm_dma_unmap_page(struct device *dev, dma_addr_t handle,
 		size_t size, enum dma_data_direction dir,
 		struct dma_attrs *attrs)
 {
-	__dma_unmap_page(dev, handle, size, dir);
+	if (!arch_is_coherent())
+		__dma_page_dev_to_cpu(pfn_to_page(dma_to_pfn(dev, handle)),
+				      handle & ~PAGE_MASK, size, dir);
 }
 
-static inline void arm_dma_sync_single_for_cpu(struct device *dev,
+static void arm_dma_sync_single_for_cpu(struct device *dev,
 		dma_addr_t handle, size_t size, enum dma_data_direction dir)
 {
-	__dma_single_dev_to_cpu(dma_to_virt(dev, handle), size, dir);
+	if (!arch_is_coherent())
+		__dma_page_dev_to_cpu(virt_to_page(dma_to_virt(dev, handle)),
+				      handle & ~PAGE_MASK, size, dir);
 }
 
-static inline void arm_dma_sync_single_for_device(struct device *dev,
+static void arm_dma_sync_single_for_device(struct device *dev,
 		dma_addr_t handle, size_t size, enum dma_data_direction dir)
 {
-	__dma_single_cpu_to_dev(dma_to_virt(dev, handle), size, dir);
+	if (!arch_is_coherent())
+		__dma_page_cpu_to_dev(virt_to_page(dma_to_virt(dev, handle)),
+				      handle & ~PAGE_MASK, size, dir);
 }
 
 static int arm_dma_set_mask(struct device *dev, u64 dma_mask)
@@ -567,47 +523,6 @@ void dma_free_coherent(struct device *dev, size_t size, void *cpu_addr, dma_addr
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
@@ -652,7 +567,13 @@ static void dma_cache_maint_page(struct page *page, unsigned long offset,
 	} while (left);
 }
 
-void ___dma_page_cpu_to_dev(struct page *page, unsigned long off,
+/*
+ * Make an area consistent for devices.
+ * Note: Drivers should NOT use this function directly, as it will break
+ * platforms with CONFIG_DMABOUNCE.
+ * Use the driver DMA support - see dma-mapping.h (dma_sync_*)
+ */
+static void __dma_page_cpu_to_dev(struct page *page, unsigned long off,
 	size_t size, enum dma_data_direction dir)
 {
 	unsigned long paddr;
@@ -667,9 +588,8 @@ void ___dma_page_cpu_to_dev(struct page *page, unsigned long off,
 	}
 	/* FIXME: non-speculating: flush on bidirectional mappings? */
 }
-EXPORT_SYMBOL(___dma_page_cpu_to_dev);
 
-void ___dma_page_dev_to_cpu(struct page *page, unsigned long off,
+static void __dma_page_dev_to_cpu(struct page *page, unsigned long off,
 	size_t size, enum dma_data_direction dir)
 {
 	unsigned long paddr = page_to_phys(page) + off;
@@ -687,7 +607,6 @@ void ___dma_page_dev_to_cpu(struct page *page, unsigned long off,
 	if (dir != DMA_TO_DEVICE && off == 0 && size >= PAGE_SIZE)
 		set_bit(PG_dcache_clean, &page->flags);
 }
-EXPORT_SYMBOL(___dma_page_dev_to_cpu);
 
 /**
  * generic_map_sg - map a set of SG buffers for streaming mode DMA
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
