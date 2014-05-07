From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH v2 03/10] slab: move up code to get kmem_cache_node in free_block()
Date: 7 May 2014 17:22:24 -0400
Message-ID: <20140507212224.9085.qmail@ns.horizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: cl@linux.com, iamjoonsoo.kim@lge.com
Cc: linux@horizon.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Seeing this patch made me think of a larger cleanup.
Would this be worth adding to the series?
(I incorporated your patch, as I couldn't decide whether
to write mine before or after; I assume it's no problem
to separate whichever way you want to order it.)

Commit comment something like:

Subject: Let clear_obj_pfmemalloc return the modified pointer

All callers fetch it immediately after, so just return the written
value for convenience.

Signed-off-by: George Spelvin <linux@horizon.com>
---
 mm/slab.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 388cb1ae6f..7fdc8df104 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -215,9 +215,9 @@ static inline void set_obj_pfmemalloc(void **objp)
 	return;
 }
 
-static inline void clear_obj_pfmemalloc(void **objp)
+static inline void *clear_obj_pfmemalloc(void **objp)
 {
-	*objp = (void *)((unsigned long)*objp & ~SLAB_OBJ_PFMEMALLOC);
+	return *objp = (void *)((unsigned long)*objp & ~SLAB_OBJ_PFMEMALLOC);
 }
 
 /*
@@ -809,10 +809,8 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 	if (unlikely(is_obj_pfmemalloc(objp))) {
 		struct kmem_cache_node *n;
 
-		if (gfp_pfmemalloc_allowed(flags)) {
-			clear_obj_pfmemalloc(&objp);
-			return objp;
-		}
+		if (gfp_pfmemalloc_allowed(flags))
+			return clear_obj_pfmemalloc(&objp);
 
 		/* The caller cannot use PFMEMALLOC objects, find another one */
 		for (i = 0; i < ac->avail; i++) {
@@ -833,9 +831,8 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		if (!list_empty(&n->slabs_free) && force_refill) {
 			struct page *page = virt_to_head_page(objp);
 			ClearPageSlabPfmemalloc(page);
-			clear_obj_pfmemalloc(&objp);
 			recheck_pfmemalloc_active(cachep, ac);
-			return objp;
+			return clear_obj_pfmemalloc(&objp);
 		}
 
 		/* No !PFMEMALLOC objects available */
@@ -3362,17 +3359,12 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 		       int node)
 {
 	int i;
-	struct kmem_cache_node *n;
+	struct kmem_cache_node *n = cachep->node[node];
 
 	for (i = 0; i < nr_objects; i++) {
-		void *objp;
-		struct page *page;
-
-		clear_obj_pfmemalloc(&objpp[i]);
-		objp = objpp[i];
+		void *objp = clear_obj_pfmemalloc(&objpp[i]);
+		struct page *page = virt_to_head_page(objp);
 
-		page = virt_to_head_page(objp);
-		n = cachep->node[node];
 		list_del(&page->lru);
 		check_spinlock_acquired_node(cachep, node);
 		slab_put_obj(cachep, page, objp, node);
