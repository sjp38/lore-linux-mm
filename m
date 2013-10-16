Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C6B6B6B004D
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 04:44:20 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so572473pdj.4
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 01:44:20 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 08/15] slab: use __GFP_COMP flag for allocating slab pages
Date: Wed, 16 Oct 2013 17:44:05 +0900
Message-Id: <1381913052-23875-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If we use 'struct page' of first page as 'struct slab', there is no
advantage not to use __GFP_COMP. So use __GFP_COMP flag for all the cases.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index f9e676e..75c6082 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1718,15 +1718,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 {
 	struct page *page;
 	int nr_pages;
-	int i;
-
-#ifndef CONFIG_MMU
-	/*
-	 * Nommu uses slab's for process anonymous memory allocations, and thus
-	 * requires __GFP_COMP to properly refcount higher order allocations
-	 */
-	flags |= __GFP_COMP;
-#endif
 
 	flags |= cachep->allocflags;
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
@@ -1750,12 +1741,9 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	else
 		add_zone_page_state(page_zone(page),
 			NR_SLAB_UNRECLAIMABLE, nr_pages);
-	for (i = 0; i < nr_pages; i++) {
-		__SetPageSlab(page + i);
-
-		if (page->pfmemalloc)
-			SetPageSlabPfmemalloc(page);
-	}
+	__SetPageSlab(page);
+	if (page->pfmemalloc)
+		SetPageSlabPfmemalloc(page);
 	memcg_bind_pages(cachep, cachep->gfporder);
 
 	if (kmemcheck_enabled && !(cachep->flags & SLAB_NOTRACK)) {
@@ -1775,8 +1763,7 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
  */
 static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 {
-	unsigned long i = (1 << cachep->gfporder);
-	const unsigned long nr_freed = i;
+	const unsigned long nr_freed = (1 << cachep->gfporder);
 
 	kmemcheck_free_shadow(page, cachep->gfporder);
 
@@ -1787,12 +1774,9 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 		sub_zone_page_state(page_zone(page),
 				NR_SLAB_UNRECLAIMABLE, nr_freed);
 
+	BUG_ON(!PageSlab(page));
 	__ClearPageSlabPfmemalloc(page);
-	while (i--) {
-		BUG_ON(!PageSlab(page));
-		__ClearPageSlab(page);
-		page++;
-	}
+	__ClearPageSlab(page);
 
 	memcg_release_pages(cachep, cachep->gfporder);
 	if (current->reclaim_state)
@@ -2362,7 +2346,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	cachep->colour = left_over / cachep->colour_off;
 	cachep->slab_size = slab_size;
 	cachep->flags = flags;
-	cachep->allocflags = 0;
+	cachep->allocflags = __GFP_COMP;
 	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
 		cachep->allocflags |= GFP_DMA;
 	cachep->size = size;
@@ -2729,17 +2713,8 @@ static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
 static void slab_map_pages(struct kmem_cache *cache, struct slab *slab,
 			   struct page *page)
 {
-	int nr_pages;
-
-	nr_pages = 1;
-	if (likely(!PageCompound(page)))
-		nr_pages <<= cache->gfporder;
-
-	do {
-		page->slab_cache = cache;
-		page->slab_page = slab;
-		page++;
-	} while (--nr_pages);
+	page->slab_cache = cache;
+	page->slab_page = slab;
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
