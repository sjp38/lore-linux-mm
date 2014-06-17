Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7582B6B0039
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 21:39:36 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so2667019pad.0
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 18:39:36 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ee6si15535207pac.4.2014.06.16.18.39.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jun 2014 18:39:35 -0700 (PDT)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv3 5/5] arm64: Add atomic pool for non-coherent and CMA allocations.
Date: Mon, 16 Jun 2014 18:39:25 -0700
Message-Id: <1402969165-7526-6-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1402969165-7526-1-git-send-email-lauraa@codeaurora.org>
References: <1402969165-7526-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <lauraa@codeaurora.org>, David Riley <davidriley@chromium.org>, linux-arm-kernel@lists.infradead.org, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Neither CMA nor noncoherent allocations support atomic allocations.
Add a dedicated atomic pool to support this.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 arch/arm64/Kconfig          |   1 +
 arch/arm64/mm/dma-mapping.c | 155 +++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 139 insertions(+), 17 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 7295419..9de71a26 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -14,6 +14,7 @@ config ARM64
 	select COMMON_CLK
 	select CPU_PM if (SUSPEND || CPU_IDLE)
 	select DCACHE_WORD_ACCESS
+	select GENERIC_ALLOCATOR
 	select GENERIC_CLOCKEVENTS
 	select GENERIC_CLOCKEVENTS_BROADCAST if SMP
 	select GENERIC_CPU_AUTOPROBE
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index 4164c5a..8e8049b 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -27,6 +27,7 @@
 #include <linux/vmalloc.h>
 #include <linux/swiotlb.h>
 #include <linux/amba/bus.h>
+#include <linux/genalloc.h>
 
 #include <asm/cacheflush.h>
 
@@ -41,6 +42,55 @@ static pgprot_t __get_dma_pgprot(struct dma_attrs *attrs, pgprot_t prot,
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
+
 static void *__dma_alloc_coherent(struct device *dev, size_t size,
 				  dma_addr_t *dma_handle, gfp_t flags,
 				  struct dma_attrs *attrs)
@@ -53,7 +103,8 @@ static void *__dma_alloc_coherent(struct device *dev, size_t size,
 	if (IS_ENABLED(CONFIG_ZONE_DMA) &&
 	    dev->coherent_dma_mask <= DMA_BIT_MASK(32))
 		flags |= GFP_DMA;
-	if (IS_ENABLED(CONFIG_DMA_CMA)) {
+
+	if (!(flags & __GFP_WAIT) && IS_ENABLED(CONFIG_DMA_CMA)) {
 		struct page *page;
 
 		size = PAGE_ALIGN(size);
@@ -73,50 +124,56 @@ static void __dma_free_coherent(struct device *dev, size_t size,
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
 
+
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
 
@@ -135,6 +192,8 @@ static void __dma_free_noncoherent(struct device *dev, size_t size,
 {
 	void *swiotlb_addr = phys_to_virt(dma_to_phys(dev, dma_handle));
 
+	if (__free_from_pool(vaddr, size))
+		return;
 	vunmap(vaddr);
 	__dma_free_coherent(dev, size, swiotlb_addr, dma_handle, attrs);
 }
@@ -332,6 +391,68 @@ static struct notifier_block amba_bus_nb = {
 
 extern int swiotlb_late_init_with_default_size(size_t default_size);
 
+static int __init atomic_pool_init(void)
+{
+	pgprot_t prot = __pgprot(PROT_NORMAL_NC);
+	unsigned long nr_pages = atomic_pool_size >> PAGE_SHIFT;
+	struct page *page;
+	void *addr;
+
+
+	if (dev_get_cma_area(NULL))
+		page = dma_alloc_from_contiguous(NULL, nr_pages,
+					get_order(atomic_pool_size));
+	else
+		page = alloc_pages(GFP_KERNEL, get_order(atomic_pool_size));
+
+
+	if (page) {
+		int ret;
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
+		memset(addr, 0, atomic_pool_size);
+		__dma_flush_range(addr, addr + atomic_pool_size);
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
+		pr_info("DMA: preallocated %zd KiB pool for atomic allocations\n",
+			atomic_pool_size / 1024);
+		return 0;
+	}
+	goto out;
+
+remove_mapping:
+	dma_common_free_remap(addr, atomic_pool_size, VM_USERMAP);
+destroy_genpool:
+	gen_pool_destroy(atomic_pool);
+	atomic_pool == NULL;
+free_page:
+	if (!dma_release_from_contiguous(NULL, page, nr_pages))
+		__free_pages(page, get_order(atomic_pool_size));
+out:
+	pr_err("DMA: failed to allocate %zx KiB pool for atomic coherent allocation\n",
+		atomic_pool_size / 1024);
+	return -ENOMEM;
+}
+postcore_initcall(atomic_pool_init);
+
 static int __init swiotlb_late_init(void)
 {
 	size_t swiotlb_size = min(SZ_64M, MAX_ORDER_NR_PAGES << PAGE_SHIFT);
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
