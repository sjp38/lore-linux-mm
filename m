Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id AF0F16B006C
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:24 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 15/16] slab: remove useless statement for checking pfmemalloc
Date: Thu, 22 Aug 2013 17:44:24 +0900
Message-Id: <1377161065-30552-16-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, virt_to_page(page->s_mem) is same as the page,
because slab use this structure for management.
So remove useless statement.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index cf39309..6abc069 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -750,9 +750,7 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 
 static inline bool is_slab_pfmemalloc(struct page *page)
 {
-	struct page *mem_page = virt_to_page(page->s_mem);
-
-	return PageSlabPfmemalloc(mem_page);
+	return PageSlabPfmemalloc(page);
 }
 
 /* Clears pfmemalloc_active if no slabs have pfmalloc set */
@@ -817,7 +815,7 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		n = cachep->node[numa_mem_id()];
 		if (!list_empty(&n->slabs_free) && force_refill) {
 			struct page *page = virt_to_head_page(objp);
-			ClearPageSlabPfmemalloc(virt_to_head_page(page->s_mem));
+			ClearPageSlabPfmemalloc(page);
 			clear_obj_pfmemalloc(&objp);
 			recheck_pfmemalloc_active(cachep, ac);
 			return objp;
@@ -850,8 +848,7 @@ static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
 	if (unlikely(pfmemalloc_active)) {
 		/* Some pfmemalloc slabs exist, check if this is one */
 		struct page *page = virt_to_head_page(objp);
-		struct page *mem_page = virt_to_head_page(page->s_mem);
-		if (PageSlabPfmemalloc(mem_page))
+		if (PageSlabPfmemalloc(page))
 			set_obj_pfmemalloc(&objp);
 	}
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
