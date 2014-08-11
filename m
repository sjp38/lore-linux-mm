Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3A96B003B
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 19:40:44 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id rl12so10777828iec.29
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 16:40:44 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id 7si21896716igl.11.2014.08.11.16.40.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Aug 2014 16:40:42 -0700 (PDT)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv7 5/5] arm64: Add atomic pool for non-coherent and CMA allocations.
Date: Mon, 11 Aug 2014 16:40:31 -0700
Message-Id: <1407800431-21566-6-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1407800431-21566-1-git-send-email-lauraa@codeaurora.org>
References: <1407800431-21566-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Russell King <linux@arm.linux.org.uk>
Cc: Laura Abbott <lauraa@codeaurora.org>, David Riley <davidriley@chromium.org>, linux-arm-kernel@lists.infradead.org, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>


Neither CMA nor noncoherent allocations support atomic allocations.
Add a dedicated atomic pool to support this.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 arch/arm64/Kconfig          |   1 +
 arch/arm64/mm/dma-mapping.c | 164 +++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 146 insertions(+), 19 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 839f48c..335374b 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -16,6 +16,7 @@ config ARM64
 	select COMMON_CLK
 	select CPU_PM if (SUSPEND || CPU_IDLE)
 	select DCACHE_WORD_ACCESS
+	select GENERIC_ALLOCATOR
 	select GENERIC_CLOCKEVENTS
 	select GENERIC_CLOCKEVENTS_BROADCAST if SMP
 	select GENERIC_CPU_AUTOPROBE
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index 4164c5a..90bb7b3 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -27,6 +27,7 @@
 #include <linux/vmalloc.h>
 #include <linux/swiotlb.h>
 #include <linux/amba/bus.h>
+#include <linux/genalloc.h>
 
 #include <asm/cacheflush.h>
 
@@ -41,6 +42,54 @@ static pgprot_t __get_dma_pgprot(struct dma_attrs *attrs, pgprot_t prot,
 	return prot;
 }
 
+static struct gen_pool *atomic_pool;
+
+#define DEFAULT_DMA_COHERENT_POOL_SIZE  SZ_256K
+static size_t atomic_pool_size = DEFAULT_DMA_COHERENT_POOL_SIZE;
+
+static int __init early_coherent_pool(char *p)
+{
+	atomic_pool_size = memparse(p, &p);
+	return 0;
+}
+early_param("coherent_pool", early_coherent_pool);
+
+static void *__alloc_from_pool(size_t size, struct page **ret_page)
+{
+	unsigned long val;
+	void *ptr = NULL;
+
+	if (!atomic_pool) {
+		WARN(1, "coherent pool not initialised!\n");
+		return NULL;
+	}
+
+	val = gen_pool_alloc(atomic_pool, size);
+	if (val) {
+		phys_addr_t phys = gen_pool_virt_to_phys(atomic_pool, val);
+
+		*ret_page = phys_to_page(phys);
+		ptr = (void *)val;
+	}
+
+	return ptr;
+}
+
+static bool __in_atomic_pool(void *start, size_t size)
+{
+	return addr_in_gen_pool(atomic_pool, (unsigned long)start, size);
+}
+
+static int __free_from_pool(void *start, size_t size)
+{
+	if (!__in_atomic_pool(start, size))
+		return 0;
+
+	gen_pool_free(atomic_pool, (unsigned long)start, size);
+
+	return 1;
+}
+
 static void *__dma_alloc_coherent(struct device *dev, size_t size,
 				  dma_addr_t *dma_handle, gfp_t flags,
 				  struct dma_attrs *attrs)
@@ -53,7 +102,7 @@ static void *__dma_alloc_coherent(struct device *dev, size_t size,
 	if (IS_ENABLED(CONFIG_ZONE_DMA) &&
 	    dev->coherent_dma_mask <= DMA_BIT_MASK(32))
 		flags |= GFP_DMA;
-	if (IS_ENABLED(CONFIG_DMA_CMA)) {
+	if (IS_ENABLED(CONFIG_DMA_CMA) && (flags & __GFP_WAIT)) {
 		struct page *page;
 
 		size = PAGE_ALIGN(size);
@@ -73,50 +122,54 @@ static void __dma_free_coherent(struct device *dev, size_t size,
 				void *vaddr, dma_addr_t dma_handle,
 				struct dma_attrs *attrs)
 {
+	bool freed;
+	phys_addr_t paddr = dma_to_phys(dev, dma_handle);
+
 	if (dev == NULL) {
 		WARN_ONCE(1, "Use an actual device structure for DMA allocation\n");
 		return;
 	}
 
-	if (IS_ENABLED(CONFIG_DMA_CMA)) {
-		phys_addr_t paddr = dma_to_phys(dev, dma_handle);
-
-		dma_release_from_contiguous(dev,
+	freed = dma_release_from_contiguous(dev,
 					phys_to_page(paddr),
 					size >> PAGE_SHIFT);
-	} else {
+	if (!freed)
 		swiotlb_free_coherent(dev, size, vaddr, dma_handle);
-	}
 }
 
 static void *__dma_alloc_noncoherent(struct device *dev, size_t size,
 				     dma_addr_t *dma_handle, gfp_t flags,
 				     struct dma_attrs *attrs)
 {
-	struct page *page, **map;
+	struct page *page;
 	void *ptr, *coherent_ptr;
-	int order, i;
 
 	size = PAGE_ALIGN(size);
-	order = get_order(size);
+
+	if (!(flags & __GFP_WAIT)) {
+		struct page *page = NULL;
+		void *addr = __alloc_from_pool(size, &page);
+
+		if (addr)
+			*dma_handle = phys_to_dma(dev, page_to_phys(page));
+
+		return addr;
+
+	}
 
 	ptr = __dma_alloc_coherent(dev, size, dma_handle, flags, attrs);
 	if (!ptr)
 		goto no_mem;
-	map = kmalloc(sizeof(struct page *) << order, flags & ~GFP_DMA);
-	if (!map)
-		goto no_map;
 
 	/* remove any dirty cache lines on the kernel alias */
 	__dma_flush_range(ptr, ptr + size);
 
 	/* create a coherent mapping */
 	page = virt_to_page(ptr);
-	for (i = 0; i < (size >> PAGE_SHIFT); i++)
-		map[i] = page + i;
-	coherent_ptr = vmap(map, size >> PAGE_SHIFT, VM_MAP,
-			    __get_dma_pgprot(attrs, __pgprot(PROT_NORMAL_NC), false));
-	kfree(map);
+	coherent_ptr = dma_common_contiguous_remap(page, size, VM_USERMAP,
+				__get_dma_pgprot(attrs,
+					__pgprot(PROT_NORMAL_NC), false),
+					NULL);
 	if (!coherent_ptr)
 		goto no_map;
 
@@ -135,6 +188,8 @@ static void __dma_free_noncoherent(struct device *dev, size_t size,
 {
 	void *swiotlb_addr = phys_to_virt(dma_to_phys(dev, dma_handle));
 
+	if (__free_from_pool(vaddr, size))
+		return;
 	vunmap(vaddr);
 	__dma_free_coherent(dev, size, swiotlb_addr, dma_handle, attrs);
 }
@@ -332,6 +387,67 @@ static struct notifier_block amba_bus_nb = {
 
 extern int swiotlb_late_init_with_default_size(size_t default_size);
 
+static int __init atomic_pool_init(void)
+{
+	pgprot_t prot = __pgprot(PROT_NORMAL_NC);
+	unsigned long nr_pages = atomic_pool_size >> PAGE_SHIFT;
+	struct page *page;
+	void *addr;
+	unsigned int pool_size_order = get_order(atomic_pool_size);
+
+	if (dev_get_cma_area(NULL))
+		page = dma_alloc_from_contiguous(NULL, nr_pages,
+							pool_size_order);
+	else
+		page = alloc_pages(GFP_DMA, pool_size_order);
+
+	if (page) {
+		int ret;
+		void *page_addr = page_address(page);
+
+		memset(page_addr, 0, atomic_pool_size);
+		__dma_flush_range(page_addr, page_addr + atomic_pool_size);
+
+		atomic_pool = gen_pool_create(PAGE_SHIFT, -1);
+		if (!atomic_pool)
+			goto free_page;
+
+		addr = dma_common_contiguous_remap(page, atomic_pool_size,
+					VM_USERMAP, prot, atomic_pool_init);
+
+		if (!addr)
+			goto destroy_genpool;
+
+		ret = gen_pool_add_virt(atomic_pool, (unsigned long)addr,
+					page_to_phys(page),
+					atomic_pool_size, -1);
+		if (ret)
+			goto remove_mapping;
+
+		gen_pool_set_algo(atomic_pool,
+				  gen_pool_first_fit_order_align,
+				  (void *)PAGE_SHIFT);
+
+		pr_info("DMA: preallocated %zu KiB pool for atomic allocations\n",
+			atomic_pool_size / 1024);
+		return 0;
+	}
+	goto out;
+
+remove_mapping:
+	dma_common_free_remap(addr, atomic_pool_size, VM_USERMAP);
+destroy_genpool:
+	gen_pool_destroy(atomic_pool);
+	atomic_pool = NULL;
+free_page:
+	if (!dma_release_from_contiguous(NULL, page, nr_pages))
+		__free_pages(page, pool_size_order);
+out:
+	pr_err("DMA: failed to allocate %zu KiB pool for atomic coherent allocation\n",
+		atomic_pool_size / 1024);
+	return -ENOMEM;
+}
+
 static int __init swiotlb_late_init(void)
 {
 	size_t swiotlb_size = min(SZ_64M, MAX_ORDER_NR_PAGES << PAGE_SHIFT);
@@ -346,7 +462,17 @@ static int __init swiotlb_late_init(void)
 
 	return swiotlb_late_init_with_default_size(swiotlb_size);
 }
-arch_initcall(swiotlb_late_init);
+
+static int __init arm64_dma_init(void)
+{
+	int ret = 0;
+
+	ret |= swiotlb_late_init();
+	ret |= atomic_pool_init();
+
+	return ret;
+}
+arch_initcall(arm64_dma_init);
 
 #define PREALLOC_DMA_DEBUG_ENTRIES	4096
 
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
