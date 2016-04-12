Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id AD2F26B0265
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:51:59 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id zm5so6134020pac.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:59 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id vz3si7889544pab.93.2016.04.11.21.51.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 21:51:58 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id bx7so6047459pad.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:58 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 09/11] mm/slab: separate cache_grow() to two parts
Date: Tue, 12 Apr 2016 13:51:04 +0900
Message-Id: <1460436666-20462-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

This is a preparation step to implement lockless allocation path when
there is no free objects in kmem_cache.  What we'd like to do here is to
refill cpu cache without holding a node lock.  To accomplish this purpose,
refill should be done after new slab allocation but before attaching the
slab to the management list.  So, this patch separates cache_grow() to two
parts, allocation and attaching to the list in order to add some code
inbetween them in the following patch.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 74 ++++++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 52 insertions(+), 22 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 1910589..2c28ad5 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -213,6 +213,11 @@ static void slabs_destroy(struct kmem_cache *cachep, struct list_head *list);
 static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp);
 static void cache_reap(struct work_struct *unused);
 
+static inline void fixup_objfreelist_debug(struct kmem_cache *cachep,
+						void **list);
+static inline void fixup_slab_list(struct kmem_cache *cachep,
+				struct kmem_cache_node *n, struct page *page,
+				void **list);
 static int slab_early_init = 1;
 
 #define INDEX_NODE kmalloc_index(sizeof(struct kmem_cache_node))
@@ -1797,7 +1802,7 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 
 			/*
 			 * Needed to avoid possible looping condition
-			 * in cache_grow()
+			 * in cache_grow_begin()
 			 */
 			if (OFF_SLAB(freelist_cache))
 				continue;
@@ -2543,7 +2548,8 @@ static void slab_map_pages(struct kmem_cache *cache, struct page *page,
  * Grow (by 1) the number of slabs within a cache.  This is called by
  * kmem_cache_alloc() when there are no active objs left in a cache.
  */
-static int cache_grow(struct kmem_cache *cachep, gfp_t flags, int nodeid)
+static struct page *cache_grow_begin(struct kmem_cache *cachep,
+				gfp_t flags, int nodeid)
 {
 	void *freelist;
 	size_t offset;
@@ -2609,21 +2615,40 @@ static int cache_grow(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 
 	if (gfpflags_allow_blocking(local_flags))
 		local_irq_disable();
-	check_irq_off();
-	spin_lock(&n->list_lock);
 
-	/* Make slab active. */
-	list_add_tail(&page->lru, &(n->slabs_free));
-	STATS_INC_GROWN(cachep);
-	n->free_objects += cachep->num;
-	spin_unlock(&n->list_lock);
-	return page_node;
+	return page;
+
 opps1:
 	kmem_freepages(cachep, page);
 failed:
 	if (gfpflags_allow_blocking(local_flags))
 		local_irq_disable();
-	return -1;
+	return NULL;
+}
+
+static void cache_grow_end(struct kmem_cache *cachep, struct page *page)
+{
+	struct kmem_cache_node *n;
+	void *list = NULL;
+
+	check_irq_off();
+
+	if (!page)
+		return;
+
+	INIT_LIST_HEAD(&page->lru);
+	n = get_node(cachep, page_to_nid(page));
+
+	spin_lock(&n->list_lock);
+	if (!page->active)
+		list_add_tail(&page->lru, &(n->slabs_free));
+	else
+		fixup_slab_list(cachep, n, page, &list);
+	STATS_INC_GROWN(cachep);
+	n->free_objects += cachep->num - page->active;
+	spin_unlock(&n->list_lock);
+
+	fixup_objfreelist_debug(cachep, &list);
 }
 
 #if DEBUG
@@ -2834,6 +2859,7 @@ static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
 	struct array_cache *ac;
 	int node;
 	void *list = NULL;
+	struct page *page;
 
 	check_irq_off();
 	node = numa_mem_id();
@@ -2861,7 +2887,6 @@ retry:
 	}
 
 	while (batchcount > 0) {
-		struct page *page;
 		/* Get slab alloc is to come from. */
 		page = get_first_slab(n, false);
 		if (!page)
@@ -2894,8 +2919,6 @@ alloc_done:
 	fixup_objfreelist_debug(cachep, &list);
 
 	if (unlikely(!ac->avail)) {
-		int x;
-
 		/* Check if we can use obj in pfmemalloc slab */
 		if (sk_memalloc_socks()) {
 			void *obj = cache_alloc_pfmemalloc(cachep, n, flags);
@@ -2904,14 +2927,18 @@ alloc_done:
 				return obj;
 		}
 
-		x = cache_grow(cachep, gfp_exact_node(flags), node);
+		page = cache_grow_begin(cachep, gfp_exact_node(flags), node);
+		cache_grow_end(cachep, page);
 
-		/* cache_grow can reenable interrupts, then ac could change. */
+		/*
+		 * cache_grow_begin() can reenable interrupts,
+		 * then ac could change.
+		 */
 		ac = cpu_cache_get(cachep);
 		node = numa_mem_id();
 
 		/* no objects in sight? abort */
-		if (x < 0 && ac->avail == 0)
+		if (!page && ac->avail == 0)
 			return NULL;
 
 		if (!ac->avail)		/* objects refilled by interrupt? */
@@ -3044,6 +3071,7 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
+	struct page *page;
 	int nid;
 	unsigned int cpuset_mems_cookie;
 
@@ -3079,8 +3107,10 @@ retry:
 		 * We may trigger various forms of reclaim on the allowed
 		 * set and go into memory reserves if necessary.
 		 */
-		nid = cache_grow(cache, flags, numa_mem_id());
-		if (nid >= 0) {
+		page = cache_grow_begin(cache, flags, numa_mem_id());
+		cache_grow_end(cache, page);
+		if (page) {
+			nid = page_to_nid(page);
 			obj = ____cache_alloc_node(cache,
 				gfp_exact_node(flags), nid);
 
@@ -3108,7 +3138,6 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 	struct kmem_cache_node *n;
 	void *obj;
 	void *list = NULL;
-	int x;
 
 	VM_BUG_ON(nodeid < 0 || nodeid >= MAX_NUMNODES);
 	n = get_node(cachep, nodeid);
@@ -3140,8 +3169,9 @@ retry:
 
 must_grow:
 	spin_unlock(&n->list_lock);
-	x = cache_grow(cachep, gfp_exact_node(flags), nodeid);
-	if (x >= 0)
+	page = cache_grow_begin(cachep, gfp_exact_node(flags), nodeid);
+	cache_grow_end(cachep, page);
+	if (page)
 		goto retry;
 
 	return fallback_alloc(cachep, flags);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
