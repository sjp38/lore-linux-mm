Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B421990011A
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 03:41:59 -0400 (EDT)
Received: from spt2.w1.samsung.com (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LNU00KU0O1VCQ@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 05 Jul 2011 08:41:56 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LNU00EY7O1TS9@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 05 Jul 2011 08:41:54 +0100 (BST)
Date: Tue, 05 Jul 2011 09:41:49 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 7/8] ARM: integrate CMA with dma-mapping subsystem
In-reply-to: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1309851710-3828-8-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>

This patch adds support for CMA to dma-mapping subsystem for ARM
architecture. By default a global CMA area is used, but specific devices
are allowed to have their private memory areas if required (they can be
created with dma_declare_contiguous() function during board
initialization).

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/Kconfig                   |    1 +
 arch/arm/include/asm/device.h      |    3 ++
 arch/arm/include/asm/dma-mapping.h |   20 ++++++++++++++
 arch/arm/mm/dma-mapping.c          |   51 +++++++++++++++++++++++++++--------
 arch/arm/mm/init.c                 |    3 ++
 5 files changed, 66 insertions(+), 12 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 9adc278..3cca8cc 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -3,6 +3,7 @@ config ARM
 	default y
 	select HAVE_AOUT
 	select HAVE_DMA_API_DEBUG
+	select HAVE_DMA_CONTIGUOUS
 	select HAVE_IDE
 	select HAVE_MEMBLOCK
 	select RTC_LIB
diff --git a/arch/arm/include/asm/device.h b/arch/arm/include/asm/device.h
index 9f390ce..942913e 100644
--- a/arch/arm/include/asm/device.h
+++ b/arch/arm/include/asm/device.h
@@ -10,6 +10,9 @@ struct dev_archdata {
 #ifdef CONFIG_DMABOUNCE
 	struct dmabounce_device_info *dmabounce;
 #endif
+#ifdef CONFIG_CMA
+	struct cma *cma_area;
+#endif
 };
 
 struct pdev_archdata {
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 4fff837..a3e1e48c 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -6,6 +6,7 @@
 #include <linux/mm_types.h>
 #include <linux/scatterlist.h>
 #include <linux/dma-debug.h>
+#include <linux/dma-contiguous.h>
 
 #include <asm-generic/dma-coherent.h>
 #include <asm/memory.h>
@@ -14,6 +15,25 @@
 #error Please update to __arch_pfn_to_dma
 #endif
 
+#ifdef CONFIG_CMA
+static inline struct cma *get_dev_cma_area(struct device *dev)
+{
+	if (dev->archdata.cma_area)
+		return dev->archdata.cma_area;
+	return dma_contiguous_default_area;
+}
+
+static inline void set_dev_cma_area(struct device *dev, struct cma *cma)
+{
+	dev->archdata.cma_area = cma;
+}
+#else
+static inline struct cma *get_dev_cma_area(struct device *dev)
+{
+	return NULL;
+}
+#endif
+
 /*
  * dma_to_pfn/pfn_to_dma/dma_to_virt/virt_to_dma are architecture private
  * functions used internally by the DMA-mapping API to provide DMA
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 82a093c..1d4e916 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -17,6 +17,7 @@
 #include <linux/init.h>
 #include <linux/device.h>
 #include <linux/dma-mapping.h>
+#include <linux/dma-contiguous.h>
 #include <linux/highmem.h>
 
 #include <asm/memory.h>
@@ -52,16 +53,35 @@ static u64 get_coherent_dma_mask(struct device *dev)
 	return mask;
 }
 
+
+static struct page *__alloc_system_pages(size_t count, unsigned int order, gfp_t gfp)
+{
+	struct page *page, *p, *e;
+
+	page = alloc_pages(gfp, order);
+	if (!page)
+		return NULL;
+
+	/*
+	 * Now split the huge page and free the excess pages
+	 */
+	split_page(page, order);
+	for (p = page + count, e = page + (1 << order); p < e; p++)
+		__free_page(p);
+	return page;
+}
+
 /*
  * Allocate a DMA buffer for 'dev' of size 'size' using the
  * specified gfp mask.  Note that 'size' must be page aligned.
  */
 static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gfp)
 {
-	unsigned long order = get_order(size);
-	struct page *page, *p, *e;
+	struct page *page;
+	size_t count = size >> PAGE_SHIFT;
 	void *ptr;
 	u64 mask = get_coherent_dma_mask(dev);
+	unsigned long order = get_order(count << PAGE_SHIFT);
 
 #ifdef CONFIG_DMA_API_DEBUG
 	u64 limit = (mask + 1) & ~mask;
@@ -78,16 +98,19 @@ static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gf
 	if (mask < 0xffffffffULL)
 		gfp |= GFP_DMA;
 
-	page = alloc_pages(gfp, order);
-	if (!page)
-		return NULL;
+	/*
+	 * First, try to allocate memory from contiguous area
+	 */
+	page = dma_alloc_from_contiguous(dev, count, order);
 
 	/*
-	 * Now split the huge page and free the excess pages
+	 * Fallback if contiguous alloc fails or is not available
 	 */
-	split_page(page, order);
-	for (p = page + (size >> PAGE_SHIFT), e = page + (1 << order); p < e; p++)
-		__free_page(p);
+	if (!page)
+		page = __alloc_system_pages(count, order, gfp);
+
+	if (!page)
+		return NULL;
 
 	/*
 	 * Ensure that the allocated pages are zeroed, and that any data
@@ -104,9 +127,13 @@ static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gf
 /*
  * Free a DMA buffer.  'size' must be page aligned.
  */
-static void __dma_free_buffer(struct page *page, size_t size)
+static void __dma_free_buffer(struct device *dev, struct page *page, size_t size)
 {
-	struct page *e = page + (size >> PAGE_SHIFT);
+	size_t count = size >> PAGE_SHIFT;
+	struct page *e = page + count;
+
+	if (dma_release_from_contiguous(dev, page, count))
+		return;
 
 	while (page < e) {
 		__free_page(page);
@@ -416,7 +443,7 @@ void dma_free_coherent(struct device *dev, size_t size, void *cpu_addr, dma_addr
 	if (!arch_is_coherent())
 		__dma_free_remap(cpu_addr, size);
 
-	__dma_free_buffer(pfn_to_page(dma_to_pfn(dev, handle)), size);
+	__dma_free_buffer(dev, pfn_to_page(dma_to_pfn(dev, handle)), size);
 }
 EXPORT_SYMBOL(dma_free_coherent);
 
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index c19571c..b2dfdeb 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -20,6 +20,7 @@
 #include <linux/gfp.h>
 #include <linux/memblock.h>
 #include <linux/sort.h>
+#include <linux/dma-contiguous.h>
 
 #include <asm/mach-types.h>
 #include <asm/prom.h>
@@ -358,6 +359,8 @@ void __init arm_memblock_init(struct meminfo *mi, struct machine_desc *mdesc)
 	if (mdesc->reserve)
 		mdesc->reserve();
 
+	dma_contiguous_reserve();
+
 	memblock_analyze();
 	memblock_dump_all();
 }
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
