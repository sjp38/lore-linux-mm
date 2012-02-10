Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id CA90B6B13FE
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 13:58:59 -0500 (EST)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LZ600FEVY2AV1@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 10 Feb 2012 18:58:58 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZ6004T1Y29AJ@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Feb 2012 18:58:58 +0000 (GMT)
Date: Fri, 10 Feb 2012 19:58:42 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv6 5/7] ARM: dma-mapping: remove redundant code and cleanup
In-reply-to: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1328900324-20946-6-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This patch just performs a global cleanup in DMA mapping implementation
for ARM architecture. Some of the tiny helper functions have been moved
to the caller code, some have been merged together.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/mm/dma-mapping.c |   88 ++++++++++++--------------------------------
 1 files changed, 24 insertions(+), 64 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 5715e2e..7c0e68b 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -40,64 +40,12 @@
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
@@ -112,11 +60,13 @@ static inline void __dma_unmap_page(struct device *dev, dma_addr_t handle,
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
@@ -134,27 +84,31 @@ static inline dma_addr_t arm_dma_map_page(struct device *dev, struct page *page,
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
 	unsigned int offset = handle & (PAGE_SIZE - 1);
 	struct page *page = pfn_to_page(dma_to_pfn(dev, handle-offset));
-	__dma_page_dev_to_cpu(page, offset, size, dir);
+	if (!arch_is_coherent())
+		__dma_page_dev_to_cpu(page, offset, size, dir);
 }
 
-static inline void arm_dma_sync_single_for_device(struct device *dev,
+static void arm_dma_sync_single_for_device(struct device *dev,
 		dma_addr_t handle, size_t size, enum dma_data_direction dir)
 {
 	unsigned int offset = handle & (PAGE_SIZE - 1);
 	struct page *page = pfn_to_page(dma_to_pfn(dev, handle-offset));
-	__dma_page_cpu_to_dev(page, offset, size, dir);
+	if (!arch_is_coherent())
+		__dma_page_cpu_to_dev(page, offset, size, dir);
 }
 
 static int arm_dma_set_mask(struct device *dev, u64 dma_mask);
@@ -642,7 +596,13 @@ static void dma_cache_maint_page(struct page *page, unsigned long offset,
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
@@ -658,7 +618,7 @@ void ___dma_page_cpu_to_dev(struct page *page, unsigned long off,
 	/* FIXME: non-speculating: flush on bidirectional mappings? */
 }
 
-void ___dma_page_dev_to_cpu(struct page *page, unsigned long off,
+static void __dma_page_dev_to_cpu(struct page *page, unsigned long off,
 	size_t size, enum dma_data_direction dir)
 {
 	unsigned long paddr = page_to_phys(page) + off;
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
