Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id CDE206B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:19 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 01/16] slab: correct pfmemalloc check
Date: Thu, 22 Aug 2013 17:44:10 +0900
Message-Id: <1377161065-30552-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>

We checked pfmemalloc by slab unit, not page unit. You can see this
in is_slab_pfmemalloc(). So other pages don't need to be set/cleared
pfmemalloc.

And, therefore we should check pfmemalloc in page flag of first page,
but current implementation don't do that. virt_to_head_page(obj) just
return 'struct page' of that object, not one of first page, since the SLAB
don't use __GFP_COMP when CONFIG_MMU. To get 'struct page' of first page,
we first get a slab and try to get it via virt_to_head_page(slab->s_mem).

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 8ccd296..d9eae39 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -930,7 +930,8 @@ static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
 {
 	if (unlikely(pfmemalloc_active)) {
 		/* Some pfmemalloc slabs exist, check if this is one */
-		struct page *page = virt_to_head_page(objp);
+		struct slab *slabp = virt_to_slab(objp);
+		struct page *page = virt_to_head_page(slabp->s_mem);
 		if (PageSlabPfmemalloc(page))
 			set_obj_pfmemalloc(&objp);
 	}
@@ -1770,7 +1771,7 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 		__SetPageSlab(page + i);
 
 		if (page->pfmemalloc)
-			SetPageSlabPfmemalloc(page + i);
+			SetPageSlabPfmemalloc(page);
 	}
 	memcg_bind_pages(cachep, cachep->gfporder);
 
@@ -1803,9 +1804,10 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
 	else
 		sub_zone_page_state(page_zone(page),
 				NR_SLAB_UNRECLAIMABLE, nr_freed);
+
+	__ClearPageSlabPfmemalloc(page);
 	while (i--) {
 		BUG_ON(!PageSlab(page));
-		__ClearPageSlabPfmemalloc(page);
 		__ClearPageSlab(page);
 		page++;
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
