Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E2312828DF
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 01:27:40 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id fe3so90069562pab.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:27:40 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id hj1si25980199pac.235.2016.03.27.22.27.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Mar 2016 22:27:40 -0700 (PDT)
Received: by mail-pa0-x236.google.com with SMTP id fe3so90069428pab.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:27:40 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 09/11] mm/slab: separate cache_grow() to two parts
Date: Mon, 28 Mar 2016 14:26:59 +0900
Message-Id: <1459142821-20303-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

This is a preparation step to implement lockless allocation path when
there is no free objects in kmem_cache. What we'd like to do here is
to refill cpu cache without holding a node lock. To accomplish this
purpose, refill should be done after new slab allocation but before
attaching the slab to the management list. So, this patch separates
cache_grow() to two parts, allocation and attaching to the list
in order to add some code inbetween them in the following patch.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 74 ++++++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 52 insertions(+), 22 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index ce8ed65..401e60c 100644
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
@@ -1796,7 +1801,7 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 
 			/*
 			 * Needed to avoid possible looping condition
-			 * in cache_grow()
+			 * in cache_grow_begin()
 			 */
 			if (OFF_SLAB(freelist_cache))
 				continue;
@@ -2518,7 +2523,8 @@ static void slab_map_pages(struct kmem_cache *cache, struct page *page,
  * Grow (by 1) the number of slabs within a cache.  This is called by
  * kmem_cache_alloc() when there are no active objs left in a cache.
  */
-static int cache_grow(struct kmem_cache *cachep, gfp_t flags, int nodeid)
+static struct page *cache_grow_begin(struct kmem_cache *cachep,
+				gfp_t flags, int nodeid)
 {
 	void *freelist;
 	size_t offset;
@@ -2584,21 +2590,40 @@ static int cache_grow(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 
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
@@ -2809,6 +2834,7 @@ static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
 	struct array_cache *ac;
 	int node;
 	void *list = NULL;
+	struct page *page;
 
 	check_irq_off();
 	node = numa_mem_id();
@@ -2836,7 +2862,6 @@ retry:
 	}
 
 	while (batchcount > 0) {
-		struct page *page;
 		/* Get slab alloc is to come from. */
 		page = get_first_slab(n, false);
 		if (!page)
@@ -2869,8 +2894,6 @@ alloc_done:
 	fixup_objfreelist_debug(cachep, &list);
 
 	if (unlikely(!ac->avail)) {
-		int x;
-
 		/* Check if we can use obj in pfmemalloc slab */
 		if (sk_memalloc_socks()) {
 			void *obj = cache_alloc_pfmemalloc(cachep, n, flags);
@@ -2879,14 +2902,18 @@ alloc_done:
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
@@ -3019,6 +3046,7 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
+	struct page *page;
 	int nid;
 	unsigned int cpuset_mems_cookie;
 
@@ -3054,8 +3082,10 @@ retry:
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
 
@@ -3083,7 +3113,6 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 	struct kmem_cache_node *n;
 	void *obj;
 	void *list = NULL;
-	int x;
 
 	VM_BUG_ON(nodeid < 0 || nodeid >= MAX_NUMNODES);
 	n = get_node(cachep, nodeid);
@@ -3115,8 +3144,9 @@ retry:
 
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
