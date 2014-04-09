Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id AA4C76B0039
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 11:02:45 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id c11so1229097lbj.40
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 08:02:43 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id c10si1163379lbv.210.2014.04.09.08.02.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Apr 2014 08:02:42 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 4/4] memcg, slab: remove memcg_cache_params::destroy work
Date: Wed, 9 Apr 2014 19:02:33 +0400
Message-ID: <5b28bf333ac756de906b4f0c96eba04bcc2971e4.1397054470.git.vdavydov@parallels.com>
In-Reply-To: <cover.1397054470.git.vdavydov@parallels.com>
References: <cover.1397054470.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

There is no need to schedule a work for kmem_cache_shrink/destroy from
mem_cgroup_destroy_all_caches any more, because we can now call them
directly under memcg's slab_caches_mutex.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    3 ---
 mm/memcontrol.c      |   45 +++++++++++++++++----------------------------
 2 files changed, 17 insertions(+), 31 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 22ebcf475814..5b48ef7c0cea 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -515,8 +515,6 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
  * @nr_pages: number of pages that belongs to this cache.
- * @destroy: worker to be called whenever we are ready, or believe we may be
- *           ready, to destroy this cache.
  */
 struct memcg_cache_params {
 	bool is_root_cache;
@@ -530,7 +528,6 @@ struct memcg_cache_params {
 			struct list_head list;
 			struct kmem_cache *root_cache;
 			atomic_t nr_pages;
-			struct work_struct destroy;
 		};
 	};
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9621157f2e5b..443a5ff0d923 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3040,8 +3040,6 @@ void memcg_update_array_size(int num)
 		memcg_limited_groups_array_size = memcg_caches_array_size(num);
 }
 
-static void kmem_cache_destroy_work_func(struct work_struct *w);
-
 int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 {
 	struct memcg_cache_params *cur_params = s->memcg_params;
@@ -3138,8 +3136,6 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 	if (memcg) {
 		s->memcg_params->memcg = memcg;
 		s->memcg_params->root_cache = root_cache;
-		INIT_WORK(&s->memcg_params->destroy,
-				kmem_cache_destroy_work_func);
 		css_get(&memcg->css);
 	} else
 		s->memcg_params->is_root_cache = true;
@@ -3203,7 +3199,7 @@ out:
 	mutex_unlock(&memcg->slab_caches_mutex);
 }
 
-static void memcg_kmem_destroy_cache(struct kmem_cache *cachep)
+static void __memcg_kmem_destroy_cache(struct kmem_cache *cachep)
 {
 	struct kmem_cache *root_cache;
 	struct mem_cgroup *memcg;
@@ -3215,7 +3211,7 @@ static void memcg_kmem_destroy_cache(struct kmem_cache *cachep)
 	memcg = cachep->memcg_params->memcg;
 	id = memcg_cache_id(memcg);
 
-	mutex_lock(&memcg->slab_caches_mutex);
+	lockdep_assert_held(&memcg->slab_caches_mutex);
 
 	/*
 	 * Holding the activate_kmem_mutex assures nobody will touch the
@@ -3229,7 +3225,17 @@ static void memcg_kmem_destroy_cache(struct kmem_cache *cachep)
 	list_del(&cachep->memcg_params->list);
 
 	kmem_cache_destroy(cachep);
+}
+
+static void memcg_kmem_destroy_cache(struct kmem_cache *cachep)
+{
+	struct mem_cgroup *memcg;
+
+	BUG_ON(is_root_cache(cachep));
+	memcg = cachep->memcg_params->memcg;
 
+	mutex_lock(&memcg->slab_caches_mutex);
+	__memcg_kmem_destroy_cache(cachep);
 	mutex_unlock(&memcg->slab_caches_mutex);
 }
 
@@ -3264,19 +3270,6 @@ static inline void memcg_resume_kmem_account(void)
 	current->memcg_kmem_skip_account--;
 }
 
-static void kmem_cache_destroy_work_func(struct work_struct *w)
-{
-	struct kmem_cache *cachep;
-	struct memcg_cache_params *p;
-
-	p = container_of(w, struct memcg_cache_params, destroy);
-	cachep = memcg_params_to_cache(p);
-
-	kmem_cache_shrink(cachep);
-	if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
-		memcg_kmem_destroy_cache(cachep);
-}
-
 int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 {
 	struct kmem_cache *c;
@@ -3298,12 +3291,6 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		if (!c)
 			continue;
 
-		/*
-		 * We will now manually delete the caches, so to avoid races
-		 * we need to cancel all pending destruction workers and
-		 * proceed with destruction ourselves.
-		 */
-		cancel_work_sync(&c->memcg_params->destroy);
 		memcg_kmem_destroy_cache(c);
 
 		if (cache_from_memcg_idx(s, i))
@@ -3316,15 +3303,17 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 {
 	struct kmem_cache *cachep;
-	struct memcg_cache_params *params;
+	struct memcg_cache_params *params, *tmp;
 
 	if (!memcg_kmem_is_active(memcg))
 		return;
 
 	mutex_lock(&memcg->slab_caches_mutex);
-	list_for_each_entry(params, &memcg->memcg_slab_caches, list) {
+	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
-		schedule_work(&cachep->memcg_params->destroy);
+		kmem_cache_shrink(cachep);
+		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
+			__memcg_kmem_destroy_cache(cachep);
 	}
 	mutex_unlock(&memcg->slab_caches_mutex);
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
