Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id CBB1C6B00F3
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 16:00:08 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id y10so12251005pdj.28
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 13:00:08 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id yd1si14538585pab.61.2014.11.03.13.00.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 13:00:06 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 1/8] memcg: do not destroy kmem caches on css offline
Date: Mon, 3 Nov 2014 23:59:39 +0300
Message-ID: <3cebf2773b0eb4e38b3ad2fec2f3eed830112dcc.1415046910.git.vdavydov@parallels.com>
In-Reply-To: <cover.1415046910.git.vdavydov@parallels.com>
References: <cover.1415046910.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, we try to destroy per memcg kmem caches on css offline. Since
a cache can contain active objects when the memory cgroup is removed, we
can't destroy all caches immediately and therefore should introduce
asynchronous destruction for this scheme to work properly. However, this
requires a lot of trickery and complex synchronization stuff, so I'm
planning to go another way. I'm going to reuse caches left from dead
memory cgroups instead of recreating them. This patch makes the first
step in this direction: it removes caches destruction from css offline.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    4 ----
 mm/memcontrol.c      |   52 ++------------------------------------------------
 2 files changed, 2 insertions(+), 54 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 8a2457d42fc8..390341d30b2d 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -491,9 +491,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * Child caches will hold extra metadata needed for its operation. Fields are:
  *
  * @memcg: pointer to the memcg this cache belongs to
- * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
- * @nr_pages: number of pages that belongs to this cache.
  */
 struct memcg_cache_params {
 	bool is_root_cache;
@@ -504,9 +502,7 @@ struct memcg_cache_params {
 		};
 		struct {
 			struct mem_cgroup *memcg;
-			struct list_head list;
 			struct kmem_cache *root_cache;
-			atomic_t nr_pages;
 		};
 	};
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af53fea9978d..370a27509e45 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -344,9 +344,6 @@ struct mem_cgroup {
 	struct cg_proto tcp_mem;
 #endif
 #if defined(CONFIG_MEMCG_KMEM)
-	/* analogous to slab_common's slab_caches list, but per-memcg;
-	 * protected by memcg_slab_mutex */
-	struct list_head memcg_slab_caches;
         /* Index in the kmem_cache->memcg_params->memcg_caches array */
 	int kmemcg_id;
 #endif
@@ -2489,23 +2486,10 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * The memcg_slab_mutex is held whenever a per memcg kmem cache is created or
- * destroyed. It protects memcg_caches arrays and memcg_slab_caches lists.
+ * destroyed. It protects memcg_caches arrays.
  */
 static DEFINE_MUTEX(memcg_slab_mutex);
 
-/*
- * This is a bit cumbersome, but it is rarely used and avoids a backpointer
- * in the memcg_cache_params struct.
- */
-static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
-{
-	struct kmem_cache *cachep;
-
-	VM_BUG_ON(p->is_root_cache);
-	cachep = p->root_cache;
-	return cache_from_memcg_idx(cachep, memcg_cache_id(p->memcg));
-}
-
 static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
 			     unsigned long nr_pages)
 {
@@ -2647,7 +2631,6 @@ static void memcg_register_cache(struct mem_cgroup *memcg,
 		return;
 
 	css_get(&memcg->css);
-	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
 
 	/*
 	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
@@ -2677,8 +2660,6 @@ static void memcg_unregister_cache(struct kmem_cache *cachep)
 	BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
 	root_cache->memcg_params->memcg_caches[id] = NULL;
 
-	list_del(&cachep->memcg_params->list);
-
 	kmem_cache_destroy(cachep);
 
 	/* drop the reference taken in memcg_register_cache */
@@ -2736,24 +2717,6 @@ int __memcg_cleanup_cache_params(struct kmem_cache *s)
 	return failed;
 }
 
-static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
-{
-	struct kmem_cache *cachep;
-	struct memcg_cache_params *params, *tmp;
-
-	if (!memcg_kmem_is_active(memcg))
-		return;
-
-	mutex_lock(&memcg_slab_mutex);
-	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
-		cachep = memcg_params_to_cache(params);
-		kmem_cache_shrink(cachep);
-		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
-			memcg_unregister_cache(cachep);
-	}
-	mutex_unlock(&memcg_slab_mutex);
-}
-
 struct memcg_register_cache_work {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *cachep;
@@ -2818,12 +2781,8 @@ static void memcg_schedule_register_cache(struct mem_cgroup *memcg,
 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
 {
 	unsigned int nr_pages = 1 << order;
-	int res;
 
-	res = memcg_charge_kmem(cachep->memcg_params->memcg, gfp, nr_pages);
-	if (!res)
-		atomic_add(nr_pages, &cachep->memcg_params->nr_pages);
-	return res;
+	return memcg_charge_kmem(cachep->memcg_params->memcg, gfp, nr_pages);
 }
 
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
@@ -2831,7 +2790,6 @@ void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
 	unsigned int nr_pages = 1 << order;
 
 	memcg_uncharge_kmem(cachep->memcg_params->memcg, nr_pages);
-	atomic_sub(nr_pages, &cachep->memcg_params->nr_pages);
 }
 
 /*
@@ -2985,10 +2943,6 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	memcg_uncharge_kmem(memcg, 1 << order);
 	page->mem_cgroup = NULL;
 }
-#else
-static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
-{
-}
 #endif /* CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -3571,7 +3525,6 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
 	}
 
 	memcg->kmemcg_id = memcg_id;
-	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
 
 	/*
 	 * We couldn't have accounted to this cgroup, because it hasn't got the
@@ -4885,7 +4838,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	}
 	spin_unlock(&memcg->event_list_lock);
 
-	memcg_unregister_all_caches(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
