Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5CBC56B0039
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 11:28:12 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id ec20so1582998lab.25
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 08:28:11 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id on7si14699978lbb.53.2014.03.26.08.28.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Mar 2014 08:28:10 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 2/4] sl[au]b: charge slabs to memcg explicitly
Date: Wed, 26 Mar 2014 19:28:05 +0400
Message-ID: <1d0196602182e5284f3289eaea0219e62a51d1c4.1395846845.git.vdavydov@parallels.com>
In-Reply-To: <cover.1395846845.git.vdavydov@parallels.com>
References: <cover.1395846845.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

We have only a few places where we actually want to charge kmem so
instead of intruding into the general page allocation path with
__GFP_KMEMCG it's better to explictly charge kmem there. All kmem
charges will be easier to follow that way.

This is a step towards removing __GFP_KMEMCG. It removes __GFP_KMEMCG
from memcg caches' allocflags. Instead it makes slab allocation path
call memcg_charge_kmem directly getting memcg to charge from the cache's
memcg params.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
---
 include/linux/memcontrol.h |   24 +++++++++++++-----------
 mm/memcontrol.c            |   15 +++++++++++++++
 mm/slab.c                  |    7 ++++++-
 mm/slab_common.c           |    6 +-----
 mm/slub.c                  |   24 +++++++++++++++++-------
 5 files changed, 52 insertions(+), 24 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e9dfcdad24c5..b8aaecc25cbf 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -512,6 +512,9 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
+int memcg_charge_slab(struct kmem_cache *s, gfp_t gfp, int order);
+void memcg_uncharge_slab(struct kmem_cache *s, int order);
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
@@ -667,6 +660,15 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	return cachep;
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
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 81a162d01d4d..9bbc088e3107 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3506,6 +3506,21 @@ out:
 }
 EXPORT_SYMBOL(__memcg_kmem_get_cache);
 
+int memcg_charge_slab(struct kmem_cache *s, gfp_t gfp, int order)
+{
+	if (is_root_cache(s))
+		return 0;
+	return memcg_charge_kmem(s->memcg_params->memcg, gfp,
+				 PAGE_SIZE << order);
+}
+
+void memcg_uncharge_slab(struct kmem_cache *s, int order)
+{
+	if (is_root_cache(s))
+		return;
+	memcg_uncharge_kmem(s->memcg_params->memcg, PAGE_SIZE << order);
+}
+
 /*
  * We need to verify if the allocation against current->mm->owner's memcg is
  * possible for the given order. But the page is not allocated yet, so we'll
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
index c2e58a787443..6fefe3b33ce0 100644
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
