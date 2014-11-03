Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 937376B00F4
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 16:00:10 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id fp1so12310058pdb.9
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 13:00:10 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id gc7si9141427pac.58.2014.11.03.13.00.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 13:00:08 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 2/8] slab: charge slab pages to the current memory cgroup
Date: Mon, 3 Nov 2014 23:59:40 +0300
Message-ID: <16d8b42a986bd5931459d11490f959bd9a2c5b7e.1415046910.git.vdavydov@parallels.com>
In-Reply-To: <cover.1415046910.git.vdavydov@parallels.com>
References: <cover.1415046910.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, new slabs are charged to the memory cgroup that owns the
cache (kmem_cache->memcg_params->memcg), but I'm going to decouple kmem
caches from memory cgroups so I make them charged to the current cgroup.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    5 -----
 mm/memcontrol.c            |   14 --------------
 mm/slab.c                  |   22 +++++++++++++++-------
 mm/slab.h                  |   28 ----------------------------
 mm/slub.c                  |   18 ++++++++----------
 5 files changed, 23 insertions(+), 64 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e789551d4db0..31b495ff5f3a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -416,9 +416,6 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
-int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
-void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
-
 int __memcg_cleanup_cache_params(struct kmem_cache *s);
 
 /**
@@ -490,8 +487,6 @@ memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg, int order)
  * memcg_kmem_get_cache: selects the correct per-memcg cache for allocation
  * @cachep: the original global kmem cache
  * @gfp: allocation flags.
- *
- * All memory allocated from a per-memcg cache is charged to the owner memcg.
  */
 static __always_inline struct kmem_cache *
 memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 370a27509e45..8c60d7a30f4f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2778,20 +2778,6 @@ static void memcg_schedule_register_cache(struct mem_cgroup *memcg,
 	memcg_resume_kmem_account();
 }
 
-int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
-{
-	unsigned int nr_pages = 1 << order;
-
-	return memcg_charge_kmem(cachep->memcg_params->memcg, gfp, nr_pages);
-}
-
-void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
-{
-	unsigned int nr_pages = 1 << order;
-
-	memcg_uncharge_kmem(cachep->memcg_params->memcg, nr_pages);
-}
-
 /*
  * Return the kmem_cache we're supposed to use for a slab allocation.
  * We try to use the current memcg's version of the cache.
diff --git a/mm/slab.c b/mm/slab.c
index 458613d75533..a9eb49f40c0a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1559,6 +1559,19 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 #endif
 }
 
+static inline struct page *alloc_slab_page(gfp_t flags, int nodeid, int order)
+{
+	struct mem_cgroup *memcg = NULL;
+	struct page *page;
+
+	flags |= __GFP_NOTRACK;
+	if (!memcg_kmem_newpage_charge(flags, &memcg, order))
+		return NULL;
+	page = alloc_pages_exact_node(nodeid, flags, order);
+	memcg_kmem_commit_charge(page, memcg, order);
+	return page;
+}
+
 /*
  * Interface to system's page allocator. No need to hold the
  * kmem_cache_node ->list_lock.
@@ -1577,12 +1590,8 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		flags |= __GFP_RECLAIMABLE;
 
-	if (memcg_charge_slab(cachep, flags, cachep->gfporder))
-		return NULL;
-
-	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
+	page = alloc_slab_page(flags, nodeid, cachep->gfporder);
 	if (!page) {
-		memcg_uncharge_slab(cachep, cachep->gfporder);
 		slab_out_of_memory(cachep, flags, nodeid);
 		return NULL;
 	}
@@ -1638,8 +1647,7 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += nr_freed;
-	__free_pages(page, cachep->gfporder);
-	memcg_uncharge_slab(cachep, cachep->gfporder);
+	__free_kmem_pages(page, cachep->gfporder);
 }
 
 static void kmem_rcu_free(struct rcu_head *head)
diff --git a/mm/slab.h b/mm/slab.h
index 3347fd77f7be..1ba7ad07dce4 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -227,25 +227,6 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 		return s;
 	return s->memcg_params->root_cache;
 }
-
-static __always_inline int memcg_charge_slab(struct kmem_cache *s,
-					     gfp_t gfp, int order)
-{
-	if (!memcg_kmem_enabled())
-		return 0;
-	if (is_root_cache(s))
-		return 0;
-	return __memcg_charge_slab(s, gfp, order);
-}
-
-static __always_inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
-{
-	if (!memcg_kmem_enabled())
-		return;
-	if (is_root_cache(s))
-		return;
-	__memcg_uncharge_slab(s, order);
-}
 #else
 static inline bool is_root_cache(struct kmem_cache *s)
 {
@@ -273,15 +254,6 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 {
 	return s;
 }
-
-static inline int memcg_charge_slab(struct kmem_cache *s, gfp_t gfp, int order)
-{
-	return 0;
-}
-
-static inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
-{
-}
 #endif
 
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
diff --git a/mm/slub.c b/mm/slub.c
index 80c170e92ffc..205eaca18b7b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1276,15 +1276,16 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 /*
  * Slab allocation and freeing
  */
-static inline struct page *alloc_slab_page(struct kmem_cache *s,
-		gfp_t flags, int node, struct kmem_cache_order_objects oo)
+static inline struct page *alloc_slab_page(gfp_t flags, int node,
+					   struct kmem_cache_order_objects oo)
 {
+	struct mem_cgroup *memcg = NULL;
 	struct page *page;
 	int order = oo_order(oo);
 
 	flags |= __GFP_NOTRACK;
 
-	if (memcg_charge_slab(s, flags, order))
+	if (!memcg_kmem_newpage_charge(flags, &memcg, order))
 		return NULL;
 
 	if (node == NUMA_NO_NODE)
@@ -1292,9 +1293,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	else
 		page = alloc_pages_exact_node(node, flags, order);
 
-	if (!page)
-		memcg_uncharge_slab(s, order);
-
+	memcg_kmem_commit_charge(page, memcg, order);
 	return page;
 }
 
@@ -1317,7 +1316,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	 */
 	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
 
-	page = alloc_slab_page(s, alloc_gfp, node, oo);
+	page = alloc_slab_page(alloc_gfp, node, oo);
 	if (unlikely(!page)) {
 		oo = s->min;
 		alloc_gfp = flags;
@@ -1325,7 +1324,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 		 * Allocation may have failed due to fragmentation.
 		 * Try a lower order alloc if possible
 		 */
-		page = alloc_slab_page(s, alloc_gfp, node, oo);
+		page = alloc_slab_page(alloc_gfp, node, oo);
 
 		if (page)
 			stat(s, ORDER_FALLBACK);
@@ -1438,8 +1437,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	page_mapcount_reset(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
-	__free_pages(page, order);
-	memcg_uncharge_slab(s, order);
+	__free_kmem_pages(page, order);
 }
 
 #define need_reserve_slab_rcu						\
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
