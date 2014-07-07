Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB386B003D
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 08:00:29 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id z11so2727438lbi.24
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 05:00:28 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id we7si2441192lbb.13.2014.07.07.05.00.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 05:00:27 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 1/8] memcg: add pointer from memcg_cache_params to owner cache
Date: Mon, 7 Jul 2014 16:00:06 +0400
Message-ID: <d7ce0402c30388339dd508891db0b19efcef9640.1404733720.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404733720.git.vdavydov@parallels.com>
References: <cover.1404733720.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We don't keep a pointer to the owner kmem cache in the
memcg_cache_params struct, because we can always get the cache by
reading the slot corresponding to the owner memcg in the root cache's
memcg_caches array (see memcg_params_to_cache). However, this won't work
when kmem cache re-parenting is introduced, because the slot in the root
cache's arrays must be cleared on css offline then.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    2 ++
 mm/memcontrol.c      |   25 +++++--------------------
 2 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 68b1feaba9d6..8bc62d5ef903 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -523,6 +523,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  *
  * Child caches will hold extra metadata needed for its operation. Fields are:
  *
+ * @cachep: cache which this struct is for
  * @memcg: pointer to the memcg this cache belongs to
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
@@ -536,6 +537,7 @@ struct memcg_cache_params {
 	union {
 		struct kmem_cache *memcg_caches[0];
 		struct {
+			struct kmem_cache *cachep;
 			struct mem_cgroup *memcg;
 			struct list_head list;
 			struct kmem_cache *root_cache;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d1b311687769..98b43a8125b9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2781,19 +2781,6 @@ static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 		memcg_kmem_is_active(memcg);
 }
 
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
 #ifdef CONFIG_SLABINFO
 static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 {
@@ -2807,7 +2794,7 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 
 	mutex_lock(&memcg_slab_mutex);
 	list_for_each_entry(params, &memcg->memcg_slab_caches, list)
-		cache_show(memcg_params_to_cache(params), m);
+		cache_show(params->cachep, m);
 	mutex_unlock(&memcg_slab_mutex);
 
 	return 0;
@@ -2982,6 +2969,7 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 		return -ENOMEM;
 
 	if (memcg) {
+		s->memcg_params->cachep = s;
 		s->memcg_params->memcg = memcg;
 		s->memcg_params->root_cache = root_cache;
 		atomic_long_set(&s->memcg_params->refcnt, 1);
@@ -3072,10 +3060,9 @@ static void memcg_unregister_cache_func(struct work_struct *work)
 {
 	struct memcg_cache_params *params =
 		container_of(work, struct memcg_cache_params, unregister_work);
-	struct kmem_cache *cachep = memcg_params_to_cache(params);
 
 	mutex_lock(&memcg_slab_mutex);
-	memcg_unregister_cache(cachep);
+	memcg_unregister_cache(params->cachep);
 	mutex_unlock(&memcg_slab_mutex);
 }
 
@@ -3140,7 +3127,6 @@ int __memcg_cleanup_cache_params(struct kmem_cache *s)
 
 static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 {
-	struct kmem_cache *cachep;
 	struct memcg_cache_params *params, *tmp;
 	LIST_HEAD(empty_caches);
 
@@ -3149,7 +3135,7 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 
 	mutex_lock(&memcg_slab_mutex);
 	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
-		cachep = memcg_params_to_cache(params);
+		struct kmem_cache *cachep = params->cachep;
 
 		memcg_cache_mark_dead(cachep);
 		kmem_cache_shrink(cachep);
@@ -3173,8 +3159,7 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 	while (!list_empty(&empty_caches)) {
 		params = list_first_entry(&empty_caches,
 					  struct memcg_cache_params, list);
-		cachep = memcg_params_to_cache(params);
-		memcg_unregister_cache(cachep);
+		memcg_unregister_cache(params->cachep);
 	}
 	mutex_unlock(&memcg_slab_mutex);
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
