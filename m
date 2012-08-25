Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id F24E56B002B
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 10:12:27 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so5540475pbb.14
        for <linux-mm@kvack.org>; Sat, 25 Aug 2012 07:12:27 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1/2] slab:  do ClearSlabPfmemalloc() for all pages of slab
Date: Sat, 25 Aug 2012 23:11:10 +0900
Message-Id: <1345903871-1921-1-git-send-email-js1304@gmail.com>
In-Reply-To: <Yes>
References: <Yes>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux-foundation.org>

Now, we just do ClearSlabPfmemalloc() for first page of slab
when we clear SlabPfmemalloc flag. It is a problem because we sometimes
test flag of page which is not first page of slab in __ac_put_obj().

So add code to do ClearSlabPfmemalloc for all pages of slab.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
This patch based on Pekka's slab/next tree

diff --git a/mm/slab.c b/mm/slab.c
index 3b4587b..45cf59a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -992,8 +992,11 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		 */
 		l3 = cachep->nodelists[numa_mem_id()];
 		if (!list_empty(&l3->slabs_free) && force_refill) {
-			struct slab *slabp = virt_to_slab(objp);
-			ClearPageSlabPfmemalloc(virt_to_page(slabp->s_mem));
+			int i, nr_pages = (1 << cachep->gfporder);
+			struct page *page = virt_to_head_page(objp);
+
+			for (i = 0; i < nr_pages; i++)
+				ClearPageSlabPfmemalloc(page + i);
 			clear_obj_pfmemalloc(&objp);
 			recheck_pfmemalloc_active(cachep, ac);
 			return objp;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
