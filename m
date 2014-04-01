Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id E645B6B0038
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 03:38:55 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id 10so6463835lbg.25
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 00:38:55 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id e6si10220422lah.16.2014.04.01.00.38.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Apr 2014 00:38:54 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 1/2] sl[au]b: charge slabs to kmemcg explicitly
Date: Tue, 1 Apr 2014 11:38:44 +0400
Message-ID: <031f9e2374dcb4cb6c2e7d509d1276623d5b1fba.1396335798.git.vdavydov@parallels.com>
In-Reply-To: <cover.1396335798.git.vdavydov@parallels.com>
References: <cover.1396335798.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, gthelen@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

We have only a few places where we actually want to charge kmem so
instead of intruding into the general page allocation path with
__GFP_KMEMCG it's better to explictly charge kmem there. All kmem
charges will be easier to follow that way.

This is a step towards removing __GFP_KMEMCG. It removes __GFP_KMEMCG
from memcg caches' allocflags. Instead it makes slab allocation path
call memcg_charge_kmem directly getting memcg to charge from the cache's
memcg params.

This also eliminates any possibility of misaccounting an allocation
going from one memcg's cache to another memcg, because now we always
charge slabs against the memcg the cache belongs to. That's why this
patch removes the big comment to memcg_kmem_get_cache.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   15 ++++-----------
 mm/memcontrol.c            |    4 ++--
 mm/slab.c                  |    7 ++++++-
 mm/slab.h                  |   29 +++++++++++++++++++++++++++++
 mm/slab_common.c           |    6 +-----
 mm/slub.c                  |   24 +++++++++++++++++-------
 6 files changed, 59 insertions(+), 26 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e9dfcdad24c5..29068dd26c3d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -512,6 +512,9 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
+int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size);
+void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size);
+
 void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
 int __kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
@@ -589,17 +592,7 @@ memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg, int order)
  * @cachep: the original global kmem cache
  * @gfp: allocation flags.
  *
- * This function assumes that the task allocating, which determines the memcg
- * in the page allocator, belongs to the same cgroup throughout the whole
- * process.  Misacounting can happen if the task calls memcg_kmem_get_cache()
- * while belonging to a cgroup, and later on changes. This is considered
- * acceptable, and should only happen upon task migration.
- *
- * Before the cache is created by the memcg core, there is also a possible
- * imbalance: the task belongs to a memcg, but the cache being allocated from
- * is the global cache, since the child cache is not yet guaranteed to be
- * ready. This case is also fine, since in this case the GFP_KMEMCG will not be
- * passed and the page allocator will not attempt any cgroup accounting.
+ * All memory allocated from a per-memcg cache is charged to the owner memcg.
  */
 static __always_inline struct kmem_cache *
 memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b4b6aef562fa..71e1e11ab6a2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2944,7 +2944,7 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 }
 #endif
 
-static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
+int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 {
 	struct res_counter *fail_res;
 	int ret = 0;
@@ -2982,7 +2982,7 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 	return ret;
 }
 
-static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
+void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 {
 	res_counter_uncharge(&memcg->res, size);
 	if (do_swap_account)
diff --git a/mm/slab.c b/mm/slab.c
index eebc619ae33c..af126a37dafd 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1664,8 +1664,12 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		flags |= __GFP_RECLAIMABLE;
 
+	if (memcg_charge_slab(cachep, flags, cachep->gfporder))
+		return NULL;
+
 	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
 	if (!page) {
+		memcg_uncharge_slab(cachep, cachep->gfporder);
 		if (!(flags & __GFP_NOWARN) && printk_ratelimit())
 			slab_out_of_memory(cachep, flags, nodeid);
 		return NULL;
@@ -1724,7 +1728,8 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 	memcg_release_pages(cachep, cachep->gfporder);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += nr_freed;
-	__free_memcg_kmem_pages(page, cachep->gfporder);
+	__free_pages(page, cachep->gfporder);
+	memcg_uncharge_slab(cachep, cachep->gfporder);
 }
 
 static void kmem_rcu_free(struct rcu_head *head)
diff --git a/mm/slab.h b/mm/slab.h
index 3045316b7c9d..3db3c52f80a2 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -191,6 +191,26 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 		return s;
 	return s->memcg_params->root_cache;
 }
+
+static __always_inline int memcg_charge_slab(struct kmem_cache *s,
+					     gfp_t gfp, int order)
+{
+	if (!memcg_kmem_enabled())
+		return 0;
+	if (is_root_cache(s))
+		return 0;
+	return memcg_charge_kmem(s->memcg_params->memcg, gfp,
+				 PAGE_SIZE << order);
+}
+
+static __always_inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
+{
+	if (!memcg_kmem_enabled())
+		return;
+	if (is_root_cache(s))
+		return;
+	memcg_uncharge_kmem(s->memcg_params->memcg, PAGE_SIZE << order);
+}
 #else
 static inline bool is_root_cache(struct kmem_cache *s)
 {
@@ -226,6 +246,15 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 {
 	return s;
 }
+
+static inline int memcg_charge_slab(struct kmem_cache *s, gfp_t gfp, int order)
+{
+	return 0;
+}
+
+static inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
+{
+}
 #endif
 
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index f3cfccf76dda..6673597ac967 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -290,12 +290,8 @@ void kmem_cache_create_memcg(struct mem_cgroup *memcg, struct kmem_cache *root_c
 				 root_cache->size, root_cache->align,
 				 root_cache->flags, root_cache->ctor,
 				 memcg, root_cache);
-	if (IS_ERR(s)) {
+	if (IS_ERR(s))
 		kfree(cache_name);
-		goto out_unlock;
-	}
-
-	s->allocflags |= __GFP_KMEMCG;
 
 out_unlock:
 	mutex_unlock(&slab_mutex);
diff --git a/mm/slub.c b/mm/slub.c
index 5e234f1f8853..b203cfceff95 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1317,17 +1317,26 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 /*
  * Slab allocation and freeing
  */
-static inline struct page *alloc_slab_page(gfp_t flags, int node,
-					struct kmem_cache_order_objects oo)
+static inline struct page *alloc_slab_page(struct kmem_cache *s,
+		gfp_t flags, int node, struct kmem_cache_order_objects oo)
 {
+	struct page *page;
 	int order = oo_order(oo);
 
 	flags |= __GFP_NOTRACK;
 
+	if (memcg_charge_slab(s, flags, order))
+		return NULL;
+
 	if (node == NUMA_NO_NODE)
-		return alloc_pages(flags, order);
+		page = alloc_pages(flags, order);
 	else
-		return alloc_pages_exact_node(node, flags, order);
+		page = alloc_pages_exact_node(node, flags, order);
+
+	if (!page)
+		memcg_uncharge_slab(s, order);
+
+	return page;
 }
 
 static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
@@ -1349,7 +1358,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	 */
 	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
 
-	page = alloc_slab_page(alloc_gfp, node, oo);
+	page = alloc_slab_page(s, alloc_gfp, node, oo);
 	if (unlikely(!page)) {
 		oo = s->min;
 		alloc_gfp = flags;
@@ -1357,7 +1366,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 		 * Allocation may have failed due to fragmentation.
 		 * Try a lower order alloc if possible
 		 */
-		page = alloc_slab_page(alloc_gfp, node, oo);
+		page = alloc_slab_page(s, alloc_gfp, node, oo);
 
 		if (page)
 			stat(s, ORDER_FALLBACK);
@@ -1473,7 +1482,8 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	page_mapcount_reset(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
-	__free_memcg_kmem_pages(page, order);
+	__free_pages(page, order);
+	memcg_uncharge_slab(s, order);
 }
 
 #define need_reserve_slab_rcu						\
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
