From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH v2 03/10] slab: move up code to get kmem_cache_node in free_block()
Date: 7 May 2014 17:50:12 -0400
Message-ID: <20140507215012.11213.qmail@ns.horizon.com>
References: <alpine.DEB.2.02.1405071429310.8454@chino.kir.corp.google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1405071429310.8454@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux@horizon.com, rientjes@google.com
Cc: cl@linux.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

> I think this unnecessarily obfuscates the code.

Thanks for the feedback!  (Even if it's negative, I appreciate it.)

To me, the confusing thing is the whole passing-a-pointer-to-a-pointer
business.  How about the following, which makes set_obj_pfmemalloc and
clear_obj_pfmemalloc take void *, not void **?  Is this better, or worse?

(Also Signed-off-by: George Spelvin <linux@horizon.com>)

diff --git a/mm/slab.c b/mm/slab.c
index 388cb1ae6f..f09716ce87 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -209,15 +209,14 @@ static inline bool is_obj_pfmemalloc(void *objp)
 	return (unsigned long)objp & SLAB_OBJ_PFMEMALLOC;
 }
 
-static inline void set_obj_pfmemalloc(void **objp)
+static inline void *set_obj_pfmemalloc(void *objp)
 {
-	*objp = (void *)((unsigned long)*objp | SLAB_OBJ_PFMEMALLOC);
-	return;
+	return (void *)((unsigned long)objp | SLAB_OBJ_PFMEMALLOC);
 }
 
-static inline void clear_obj_pfmemalloc(void **objp)
+static inline void *clear_obj_pfmemalloc(void *objp)
 {
-	*objp = (void *)((unsigned long)*objp & ~SLAB_OBJ_PFMEMALLOC);
+	return (void *)((unsigned long)objp & ~SLAB_OBJ_PFMEMALLOC);
 }
 
 /*
@@ -809,10 +808,8 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 	if (unlikely(is_obj_pfmemalloc(objp))) {
 		struct kmem_cache_node *n;
 
-		if (gfp_pfmemalloc_allowed(flags)) {
-			clear_obj_pfmemalloc(&objp);
-			return objp;
-		}
+		if (gfp_pfmemalloc_allowed(flags))
+			return clear_obj_pfmemalloc(objp);
 
 		/* The caller cannot use PFMEMALLOC objects, find another one */
 		for (i = 0; i < ac->avail; i++) {
@@ -833,9 +830,8 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		if (!list_empty(&n->slabs_free) && force_refill) {
 			struct page *page = virt_to_head_page(objp);
 			ClearPageSlabPfmemalloc(page);
-			clear_obj_pfmemalloc(&objp);
 			recheck_pfmemalloc_active(cachep, ac);
-			return objp;
+			return clear_obj_pfmemalloc(objp);
 		}
 
 		/* No !PFMEMALLOC objects available */
@@ -866,7 +862,7 @@ static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		/* Some pfmemalloc slabs exist, check if this is one */
 		struct page *page = virt_to_head_page(objp);
 		if (PageSlabPfmemalloc(page))
-			set_obj_pfmemalloc(&objp);
+			objp = set_obj_pfmemalloc(objp);
 	}
 
 	return objp;
@@ -3362,17 +3358,12 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
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
+		void *objp = objpp[i] = clear_obj_pfmemalloc(objpp[i]);
+		struct page *page = virt_to_head_page(objp);
 
-		page = virt_to_head_page(objp);
-		n = cachep->node[node];
 		list_del(&page->lru);
 		check_spinlock_acquired_node(cachep, node);
 		slab_put_obj(cachep, page, objp, node);
