Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D29824403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 02:40:14 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id w123so36267317pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 23:40:14 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id y15si14916139pfi.232.2016.02.03.23.40.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 23:40:13 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id 65so36136695pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 23:40:13 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] mm/slab: re-implement pfmemalloc support
Date: Thu,  4 Feb 2016 16:40:12 +0900
Message-Id: <1454571612-9486-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Current implementation of pfmemalloc handling in SLAB has some problems.

1) pfmemalloc_active is set to true when there is just one or more
pfmemalloc slabs in the system, but it is cleared when there is
no pfmemalloc slab in one arbitrary kmem_cache. So, pfmemalloc_active
could be wrongly cleared.

2) Search to partial and free list doesn't happen when non-pfmemalloc
object are not found in cpu cache. Instead, allocating new slab happens
and it is not optimal.

3) Even after sk_memalloc_socks() is disabled, cpu cache would keep
pfmemalloc objects tagged with SLAB_OBJ_PFMEMALLOC. It isn't cleared if
sk_memalloc_socks() is disabled so it could cause problem.

4) If cpu cache is filled with pfmemalloc objects, it would cause slow
down non-pfmemalloc allocation.

To me, current pointer tagging approach looks complex and fragile
so this patch re-implement whole thing instead of fixing problems
one by one.

Design principle for new implementation is that

1) Don't disrupt non-pfmemalloc allocation in fast path even if
sk_memalloc_socks() is enabled. It's more likely case than pfmemalloc
allocation.

2) Ensure that pfmemalloc slab is used only for pfmemalloc allocation.

3) Don't consider performance of pfmemalloc allocation in memory
deficiency state.

As a result, all pfmemalloc alloc/free in memory tight state will
be handled in slow-path. If there is non-pfmemalloc free object,
it will be returned first even for pfmemalloc user in fast-path so that
performance of pfmemalloc user isn't affected in normal case and
pfmemalloc objects will be kept as long as possible.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 285 ++++++++++++++++++++++++++------------------------------------
 1 file changed, 118 insertions(+), 167 deletions(-)

Hello, Mel.

May I ask you to review the patch and test it on your swap over nbd setup
in order to check that it has no regression? For me, it's not easy
to setup this environment.

Thanks.

diff --git a/mm/slab.c b/mm/slab.c
index ff6526e..da5e2c1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -169,12 +169,6 @@ typedef unsigned short freelist_idx_t;
 #define SLAB_OBJ_MAX_NUM ((1 << sizeof(freelist_idx_t) * BITS_PER_BYTE) - 1)
 
 /*
- * true if a page was allocated from pfmemalloc reserves for network-based
- * swap
- */
-static bool pfmemalloc_active __read_mostly;
-
-/*
  * struct array_cache
  *
  * Purpose:
@@ -195,10 +189,6 @@ struct array_cache {
 			 * Must have this definition in here for the proper
 			 * alignment of array_cache. Also simplifies accessing
 			 * the entries.
-			 *
-			 * Entries should not be directly dereferenced as
-			 * entries belonging to slabs marked pfmemalloc will
-			 * have the lower bits set SLAB_OBJ_PFMEMALLOC
 			 */
 };
 
@@ -207,23 +197,6 @@ struct alien_cache {
 	struct array_cache ac;
 };
 
-#define SLAB_OBJ_PFMEMALLOC	1
-static inline bool is_obj_pfmemalloc(void *objp)
-{
-	return (unsigned long)objp & SLAB_OBJ_PFMEMALLOC;
-}
-
-static inline void set_obj_pfmemalloc(void **objp)
-{
-	*objp = (void *)((unsigned long)*objp | SLAB_OBJ_PFMEMALLOC);
-	return;
-}
-
-static inline void clear_obj_pfmemalloc(void **objp)
-{
-	*objp = (void *)((unsigned long)*objp & ~SLAB_OBJ_PFMEMALLOC);
-}
-
 /*
  * Need this for bootstrapping a per node allocator.
  */
@@ -620,120 +593,24 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 	return ac;
 }
 
-static inline bool is_slab_pfmemalloc(struct page *page)
-{
-	return PageSlabPfmemalloc(page);
-}
-
-/* Clears pfmemalloc_active if no slabs have pfmalloc set */
-static void recheck_pfmemalloc_active(struct kmem_cache *cachep,
-						struct array_cache *ac)
-{
-	struct kmem_cache_node *n = get_node(cachep, numa_mem_id());
-	struct page *page;
-	unsigned long flags;
-
-	if (!pfmemalloc_active)
-		return;
-
-	spin_lock_irqsave(&n->list_lock, flags);
-	list_for_each_entry(page, &n->slabs_full, lru)
-		if (is_slab_pfmemalloc(page))
-			goto out;
-
-	list_for_each_entry(page, &n->slabs_partial, lru)
-		if (is_slab_pfmemalloc(page))
-			goto out;
-
-	list_for_each_entry(page, &n->slabs_free, lru)
-		if (is_slab_pfmemalloc(page))
-			goto out;
-
-	pfmemalloc_active = false;
-out:
-	spin_unlock_irqrestore(&n->list_lock, flags);
-}
-
-static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
-						gfp_t flags, bool force_refill)
+static noinline void cache_free_pfmemalloc(struct kmem_cache *cachep,
+					void *objp)
 {
-	int i;
-	void *objp = ac->entry[--ac->avail];
-
-	/* Ensure the caller is allowed to use objects from PFMEMALLOC slab */
-	if (unlikely(is_obj_pfmemalloc(objp))) {
-		struct kmem_cache_node *n;
-
-		if (gfp_pfmemalloc_allowed(flags)) {
-			clear_obj_pfmemalloc(&objp);
-			return objp;
-		}
-
-		/* The caller cannot use PFMEMALLOC objects, find another one */
-		for (i = 0; i < ac->avail; i++) {
-			/* If a !PFMEMALLOC object is found, swap them */
-			if (!is_obj_pfmemalloc(ac->entry[i])) {
-				objp = ac->entry[i];
-				ac->entry[i] = ac->entry[ac->avail];
-				ac->entry[ac->avail] = objp;
-				return objp;
-			}
-		}
-
-		/*
-		 * If there are empty slabs on the slabs_free list and we are
-		 * being forced to refill the cache, mark this one !pfmemalloc.
-		 */
-		n = get_node(cachep, numa_mem_id());
-		if (!list_empty(&n->slabs_free) && force_refill) {
-			struct page *page = virt_to_head_page(objp);
-			ClearPageSlabPfmemalloc(page);
-			clear_obj_pfmemalloc(&objp);
-			recheck_pfmemalloc_active(cachep, ac);
-			return objp;
-		}
-
-		/* No !PFMEMALLOC objects available */
-		ac->avail++;
-		objp = NULL;
-	}
-
-	return objp;
-}
-
-static inline void *ac_get_obj(struct kmem_cache *cachep,
-			struct array_cache *ac, gfp_t flags, bool force_refill)
-{
-	void *objp;
+	struct page *page = virt_to_head_page(objp);
+	struct kmem_cache_node *n;
+	int page_node;
+	LIST_HEAD(list);
 
-	if (unlikely(sk_memalloc_socks()))
-		objp = __ac_get_obj(cachep, ac, flags, force_refill);
-	else
-		objp = ac->entry[--ac->avail];
+	if (unlikely(PageSlabPfmemalloc(page))) {
+		page_node = page_to_nid(page);
+		n = get_node(cachep, page_node);
 
-	return objp;
-}
+		spin_lock(&n->list_lock);
+		free_block(cachep, &objp, 1, page_node, &list);
+		spin_unlock(&n->list_lock);
 
-static noinline void *__ac_put_obj(struct kmem_cache *cachep,
-			struct array_cache *ac, void *objp)
-{
-	if (unlikely(pfmemalloc_active)) {
-		/* Some pfmemalloc slabs exist, check if this is one */
-		struct page *page = virt_to_head_page(objp);
-		if (PageSlabPfmemalloc(page))
-			set_obj_pfmemalloc(&objp);
+		slabs_destroy(cachep, &list);
 	}
-
-	return objp;
-}
-
-static inline void ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
-								void *objp)
-{
-	if (unlikely(sk_memalloc_socks()))
-		objp = __ac_put_obj(cachep, ac, objp);
-
-	ac->entry[ac->avail++] = objp;
 }
 
 /*
@@ -936,7 +813,7 @@ static int __cache_free_alien(struct kmem_cache *cachep, void *objp,
 			STATS_INC_ACOVERFLOW(cachep);
 			__drain_alien_cache(cachep, ac, page_node, &list);
 		}
-		ac_put_obj(cachep, ac, objp);
+		ac->entry[ac->avail++] = objp;
 		spin_unlock(&alien->lock);
 		slabs_destroy(cachep, &list);
 	} else {
@@ -1537,10 +1414,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 		return NULL;
 	}
 
-	/* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
-	if (page_is_pfmemalloc(page))
-		pfmemalloc_active = true;
-
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		add_zone_page_state(page_zone(page),
@@ -1548,8 +1421,10 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	else
 		add_zone_page_state(page_zone(page),
 			NR_SLAB_UNRECLAIMABLE, nr_pages);
+
 	__SetPageSlab(page);
-	if (page_is_pfmemalloc(page))
+	/* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
+	if (sk_memalloc_socks() && page_is_pfmemalloc(page))
 		SetPageSlabPfmemalloc(page);
 
 	if (kmemcheck_enabled && !(cachep->flags & SLAB_NOTRACK)) {
@@ -2820,7 +2695,46 @@ static inline void fixup_slab_list(struct kmem_cache *cachep,
 		list_add(&page->lru, &n->slabs_partial);
 }
 
-static struct page *get_first_slab(struct kmem_cache_node *n)
+/* Try to find non-pfmemalloc slab if needed */
+static noinline struct page *get_valid_first_slab(struct kmem_cache_node *n,
+					struct page *page, bool pfmemalloc)
+{
+	if (!page)
+		return NULL;
+
+	if (pfmemalloc)
+		return page;
+
+	if (!PageSlabPfmemalloc(page))
+		return page;
+
+	/* No need to keep pfmemalloc slab if we have enough free objects */
+	if (n->free_objects > n->free_limit) {
+		ClearPageSlabPfmemalloc(page);
+		return page;
+	}
+
+	/* Move pfmemalloc slab to the end of list to speed up next search */
+	list_del(&page->lru);
+	if (!page->active)
+		list_add_tail(&page->lru, &n->slabs_free);
+	else
+		list_add_tail(&page->lru, &n->slabs_partial);
+
+	list_for_each_entry(page, &n->slabs_partial, lru) {
+		if (!PageSlabPfmemalloc(page))
+			return page;
+	}
+
+	list_for_each_entry(page, &n->slabs_free, lru) {
+		if (!PageSlabPfmemalloc(page))
+			return page;
+	}
+
+	return NULL;
+}
+
+static struct page *get_first_slab(struct kmem_cache_node *n, bool pfmemalloc)
 {
 	struct page *page;
 
@@ -2832,11 +2746,45 @@ static struct page *get_first_slab(struct kmem_cache_node *n)
 				struct page, lru);
 	}
 
+	if (sk_memalloc_socks())
+		return get_valid_first_slab(n, page, pfmemalloc);
+
 	return page;
 }
 
-static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags,
-							bool force_refill)
+static noinline void *cache_alloc_pfmemalloc(struct kmem_cache *cachep,
+				struct kmem_cache_node *n, gfp_t flags)
+{
+	struct page *page;
+	void *obj;
+	void *list = NULL;
+
+	if (!gfp_pfmemalloc_allowed(flags))
+		return NULL;
+
+	/* Racy check if there is free objects */
+	if (!n->free_objects)
+		return NULL;
+
+	spin_lock(&n->list_lock);
+	page = get_first_slab(n, true);
+	if (!page) {
+		spin_unlock(&n->list_lock);
+		return NULL;
+	}
+
+	obj = slab_get_obj(cachep, page);
+	n->free_objects--;
+
+	fixup_slab_list(cachep, n, page, &list);
+
+	spin_unlock(&n->list_lock);
+	fixup_objfreelist_debug(cachep, &list);
+
+	return obj;
+}
+
+static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
 {
 	int batchcount;
 	struct kmem_cache_node *n;
@@ -2846,8 +2794,7 @@ static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags,
 
 	check_irq_off();
 	node = numa_mem_id();
-	if (unlikely(force_refill))
-		goto force_grow;
+
 retry:
 	ac = cpu_cache_get(cachep);
 	batchcount = ac->batchcount;
@@ -2873,7 +2820,7 @@ retry:
 	while (batchcount > 0) {
 		struct page *page;
 		/* Get slab alloc is to come from. */
-		page = get_first_slab(n);
+		page = get_first_slab(n, false);
 		if (!page)
 			goto must_grow;
 
@@ -2891,7 +2838,7 @@ retry:
 			STATS_INC_ACTIVE(cachep);
 			STATS_SET_HIGH(cachep);
 
-			ac_put_obj(cachep, ac, slab_get_obj(cachep, page));
+			ac->entry[ac->avail++] = slab_get_obj(cachep, page);
 		}
 
 		fixup_slab_list(cachep, n, page, &list);
@@ -2905,7 +2852,15 @@ alloc_done:
 
 	if (unlikely(!ac->avail)) {
 		int x;
-force_grow:
+
+		/* Check if we can use obj in pfmemalloc slab */
+		if (sk_memalloc_socks()) {
+			void *obj = cache_alloc_pfmemalloc(cachep, n, flags);
+
+			if (obj)
+				return obj;
+		}
+
 		x = cache_grow(cachep, gfp_exact_node(flags), node, NULL);
 
 		/* cache_grow can reenable interrupts, then ac could change. */
@@ -2913,7 +2868,7 @@ force_grow:
 		node = numa_mem_id();
 
 		/* no objects in sight? abort */
-		if (!x && (ac->avail == 0 || force_refill))
+		if (!x && ac->avail == 0)
 			return NULL;
 
 		if (!ac->avail)		/* objects refilled by interrupt? */
@@ -2921,7 +2876,7 @@ force_grow:
 	}
 	ac->touched = 1;
 
-	return ac_get_obj(cachep, ac, flags, force_refill);
+	return ac->entry[--ac->avail];
 }
 
 static inline void cache_alloc_debugcheck_before(struct kmem_cache *cachep,
@@ -2979,28 +2934,20 @@ static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
 	void *objp;
 	struct array_cache *ac;
-	bool force_refill = false;
 
 	check_irq_off();
 
 	ac = cpu_cache_get(cachep);
 	if (likely(ac->avail)) {
 		ac->touched = 1;
-		objp = ac_get_obj(cachep, ac, flags, false);
+		objp = ac->entry[--ac->avail];
 
-		/*
-		 * Allow for the possibility all avail objects are not allowed
-		 * by the current flags
-		 */
-		if (objp) {
-			STATS_INC_ALLOCHIT(cachep);
-			goto out;
-		}
-		force_refill = true;
+		STATS_INC_ALLOCHIT(cachep);
+		goto out;
 	}
 
 	STATS_INC_ALLOCMISS(cachep);
-	objp = cache_alloc_refill(cachep, flags, force_refill);
+	objp = cache_alloc_refill(cachep, flags);
 	/*
 	 * the 'ac' may be updated by cache_alloc_refill(),
 	 * and kmemleak_erase() requires its correct value.
@@ -3148,7 +3095,7 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 retry:
 	check_irq_off();
 	spin_lock(&n->list_lock);
-	page = get_first_slab(n);
+	page = get_first_slab(n, false);
 	if (!page)
 		goto must_grow;
 
@@ -3301,7 +3248,6 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 		void *objp;
 		struct page *page;
 
-		clear_obj_pfmemalloc(&objpp[i]);
 		objp = objpp[i];
 
 		page = virt_to_head_page(objp);
@@ -3407,7 +3353,12 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 		cache_flusharray(cachep, ac);
 	}
 
-	ac_put_obj(cachep, ac, objp);
+	if (sk_memalloc_socks()) {
+		cache_free_pfmemalloc(cachep, objp);
+		return;
+	}
+
+	ac->entry[ac->avail++] = objp;
 }
 
 /**
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
