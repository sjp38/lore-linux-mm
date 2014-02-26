Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id A6A686B00AC
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:05:41 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id gl10so714155lab.14
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:05:41 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y6si1794932lal.140.2014.02.26.07.05.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 07:05:39 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 07/12] memcg: rework slab charging
Date: Wed, 26 Feb 2014 19:05:12 +0400
Message-ID: <bf7c4f6e88169690d57f2e8b6c1a9ae1f09f0fcd.1393423762.git.vdavydov@parallels.com>
In-Reply-To: <cover.1393423762.git.vdavydov@parallels.com>
References: <cover.1393423762.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

Currently kmemcg charging is embedded to the alloc_pages path - if we
get there with the GFP_KMEMCG bit set, we charge the new page to the
cgroup of the caller. All per-memcg caches have this bit set in
allocflags so kmalloc and friends are properly charged.

So, what's wrong with it, why should it be reworked?

First, we do some extra work due to this design. We get memcg from mm,
but we already know the cache we are allocating a page for, why not
simply get it from there? We remember the memcg a page is charged to in
a page_cgroup in order to properly uncharge it, but again each kmem slab
holds a reference to its kmem cache in page->slab_cache so we could use
that instead.

Second, it's racy. If a task changes its cgroup between selecting a
cache to allocate from (memcg_kmem_get_cache) and charging, an object
allocated from one cgroup's cache will be accounted to another cgroup.

And the last, but not least, we don't have a reliable way to track all
kmem pages accounted to a particular memcg, which makes reparenting
impossible. As a result, each memcg cache holds a reference to its memcg
until death, which is bad.

Since we have only a couple of places where we should actually charge
kmem pages, why not just insert kmemcg charge/uncharge there passing on
the slab we are allocating from instead of introdudingh into the generic
allocation path. That's what this patch does.

Note, it does not remove the old code - it will be handled further.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
---
 include/linux/memcontrol.h |   44 +++++++++++++++++++++++++++++---------------
 mm/memcontrol.c            |   15 +++++++++++++++
 mm/slab.c                  |    9 +++++++--
 mm/slab_common.c           |    6 +-----
 mm/slub.c                  |   30 +++++++++++++++++++++---------
 5 files changed, 73 insertions(+), 31 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b38b52ce59fb..3f0ff043ba94 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -496,6 +496,10 @@ void __memcg_kmem_commit_charge(struct page *page,
 				       struct mem_cgroup *memcg, int order);
 void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
+struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
+int __memcg_kmem_charge_slab(struct kmem_cache *s, gfp_t gfp, int nr_pages);
+void __memcg_kmem_uncharge_slab(struct kmem_cache *s, int nr_pages);
+
 int memcg_cache_id(struct mem_cgroup *memcg);
 
 char *memcg_create_cache_name(struct mem_cgroup *memcg,
@@ -509,9 +513,6 @@ void memcg_unregister_cache(struct kmem_cache *s);
 int memcg_update_cache_size(struct kmem_cache *s, int num_groups);
 void memcg_update_array_size(int num_groups);
 
-struct kmem_cache *
-__memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
-
 void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
 /**
@@ -587,18 +588,6 @@ memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg, int order)
  * memcg_kmem_get_cache: selects the correct per-memcg cache for allocation
  * @cachep: the original global kmem cache
  * @gfp: allocation flags.
- *
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
  */
 static __always_inline struct kmem_cache *
 memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
@@ -614,6 +603,21 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 
 	return __memcg_kmem_get_cache(cachep, gfp);
 }
+
+static __always_inline int memcg_kmem_charge_slab(struct kmem_cache *s,
+						  gfp_t gfp, int nr_pages)
+{
+	if (memcg_kmem_enabled())
+		return __memcg_kmem_charge_slab(s, gfp, nr_pages);
+	return 0;
+}
+
+static __always_inline void memcg_kmem_uncharge_slab(struct kmem_cache *s,
+						     int nr_pages)
+{
+	if (memcg_kmem_enabled())
+		__memcg_kmem_uncharge_slab(s, nr_pages);
+}
 #else
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
@@ -666,6 +670,16 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	return cachep;
 }
+
+static inline int memcg_kmem_charge_slab(struct kmem_cache *s,
+					 gfp_t gfp, int nr_pages)
+{
+	return 0;
+}
+
+static inline void memcg_kmem_uncharge_slab(struct kmem_cache *s, int nr_pages)
+{
+}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6af3c062dfb1..d60080812060 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3057,6 +3057,21 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 		css_put(&memcg->css);
 }
 
+int __memcg_kmem_charge_slab(struct kmem_cache *s, gfp_t gfp, int nr_pages)
+{
+	if (is_root_cache(s))
+		return 0;
+	return memcg_charge_kmem(s->memcg_params->memcg,
+				 gfp, nr_pages << PAGE_SHIFT);
+}
+
+void __memcg_kmem_uncharge_slab(struct kmem_cache *s, int nr_pages)
+{
+	if (is_root_cache(s))
+		return;
+	memcg_uncharge_kmem(s->memcg_params->memcg, nr_pages << PAGE_SHIFT);
+}
+
 /*
  * helper for acessing a memcg's index. It will be used as an index in the
  * child cache array in kmem_cache, and also to derive its name. This function
diff --git a/mm/slab.c b/mm/slab.c
index eae95847cdef..ef372599eb8b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1664,10 +1664,15 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		flags |= __GFP_RECLAIMABLE;
 
+	nr_pages = (1 << cachep->gfporder);
+	if (memcg_kmem_charge_slab(cachep, flags, nr_pages))
+		return NULL;
+
 	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
 	if (!page) {
 		if (!(flags & __GFP_NOWARN) && printk_ratelimit())
 			slab_out_of_memory(cachep, flags, nodeid);
+		memcg_kmem_uncharge_slab(cachep, nr_pages);
 		return NULL;
 	}
 
@@ -1675,7 +1680,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	if (unlikely(page->pfmemalloc))
 		pfmemalloc_active = true;
 
-	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		add_zone_page_state(page_zone(page),
 			NR_SLAB_RECLAIMABLE, nr_pages);
@@ -1724,7 +1728,8 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 	memcg_release_pages(cachep, cachep->gfporder);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += nr_freed;
-	__free_memcg_kmem_pages(page, cachep->gfporder);
+	memcg_kmem_uncharge_slab(cachep, nr_freed);
+	__free_pages(page, cachep->gfporder);
 }
 
 static void kmem_rcu_free(struct rcu_head *head)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 48e472894511..22e48d000b1d 100644
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
index 52864a6cb681..fa995823de60 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1328,8 +1328,9 @@ static inline struct page *alloc_slab_page(gfp_t flags, int node,
 
 static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
-	struct page *page;
+	struct page *page = NULL;
 	struct kmem_cache_order_objects oo = s->oo;
+	int pages = 1 << oo_order(oo);
 	gfp_t alloc_gfp;
 
 	flags &= gfp_allowed_mask;
@@ -1345,23 +1346,33 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	 */
 	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
 
+	if (memcg_kmem_charge_slab(s, alloc_gfp, pages))
+		goto out;
+
 	page = alloc_slab_page(alloc_gfp, node, oo);
 	if (unlikely(!page)) {
+		int charged = pages;
+
 		oo = s->min;
+		pages = 1 << oo_order(oo);
 		/*
 		 * Allocation may have failed due to fragmentation.
 		 * Try a lower order alloc if possible
 		 */
 		page = alloc_slab_page(flags, node, oo);
+		if (!page) {
+			memcg_kmem_uncharge_slab(s, charged);
+			goto out;
+		}
 
-		if (page)
-			stat(s, ORDER_FALLBACK);
-	}
+		VM_BUG_ON(charged <= pages);
+		memcg_kmem_uncharge_slab(s, charged - pages);
 
-	if (kmemcheck_enabled && page
-		&& !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
-		int pages = 1 << oo_order(oo);
+		stat(s, ORDER_FALLBACK);
+	}
 
+	if (kmemcheck_enabled &&
+	    !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
 		kmemcheck_alloc_shadow(page, oo_order(oo), flags, node);
 
 		/*
@@ -1373,7 +1384,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 		else
 			kmemcheck_mark_unallocated_pages(page, pages);
 	}
-
+out:
 	if (flags & __GFP_WAIT)
 		local_irq_disable();
 	if (!page)
@@ -1468,7 +1479,8 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	page_mapcount_reset(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
-	__free_memcg_kmem_pages(page, order);
+	memcg_kmem_uncharge_slab(s, pages);
+	__free_pages(page, order);
 }
 
 #define need_reserve_slab_rcu						\
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
