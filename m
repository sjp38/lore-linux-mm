Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id DAA146B002B
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 01:14:28 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [v4 1/4] ARM: dma-mapping: atomic_pool with struct page **pages
Date: Tue, 28 Aug 2012 08:13:01 +0300
Message-ID: <1346130784-23571-2-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1346130784-23571-1-git-send-email-hdoyu@nvidia.com>
References: <1346130784-23571-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com
Cc: Hiroshi Doyu <hdoyu@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com, konrad.wilk@oracle.com, linux-tegra@vger.kernel.org

struct page **pages is necessary to align with non atomic path in
__iommu_get_pages(). atomic_pool() has the intialized **pages instead
of just *page.

Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
---
 arch/arm/mm/dma-mapping.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 1123808..51d5e2b 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -296,7 +296,7 @@ struct dma_pool {
 	unsigned long *bitmap;
 	unsigned long nr_pages;
 	void *vaddr;
-	struct page *page;
+	struct page **pages;
 };
 
 static struct dma_pool atomic_pool = {
@@ -335,6 +335,7 @@ static int __init atomic_pool_init(void)
 	unsigned long nr_pages = pool->size >> PAGE_SHIFT;
 	unsigned long *bitmap;
 	struct page *page;
+	struct page **pages;
 	void *ptr;
 	int bitmap_size = BITS_TO_LONGS(nr_pages) * sizeof(long);
 
@@ -342,21 +343,31 @@ static int __init atomic_pool_init(void)
 	if (!bitmap)
 		goto no_bitmap;
 
+	pages = kzalloc(nr_pages * sizeof(struct page *), GFP_KERNEL);
+	if (!pages)
+		goto no_pages;
+
 	if (IS_ENABLED(CONFIG_CMA))
 		ptr = __alloc_from_contiguous(NULL, pool->size, prot, &page);
 	else
 		ptr = __alloc_remap_buffer(NULL, pool->size, GFP_KERNEL, prot,
 					   &page, NULL);
 	if (ptr) {
+		int i;
+
+		for (i = 0; i < nr_pages; i++)
+			pages[i] = page + i;
+
 		spin_lock_init(&pool->lock);
 		pool->vaddr = ptr;
-		pool->page = page;
+		pool->pages = pages;
 		pool->bitmap = bitmap;
 		pool->nr_pages = nr_pages;
 		pr_info("DMA: preallocated %u KiB pool for atomic coherent allocations\n",
 		       (unsigned)pool->size / 1024);
 		return 0;
 	}
+no_pages:
 	kfree(bitmap);
 no_bitmap:
 	pr_err("DMA: failed to allocate %u KiB pool for atomic coherent allocation\n",
@@ -481,7 +492,7 @@ static void *__alloc_from_pool(size_t size, struct page **ret_page)
 	if (pageno < pool->nr_pages) {
 		bitmap_set(pool->bitmap, pageno, count);
 		ptr = pool->vaddr + PAGE_SIZE * pageno;
-		*ret_page = pool->page + pageno;
+		*ret_page = pool->pages[pageno];
 	} else {
 		pr_err_once("ERROR: %u KiB atomic DMA coherent pool is too small!\n"
 			    "Please increase it with coherent_pool= kernel parameter!\n",
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
