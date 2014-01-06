Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9211B6B0044
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 03:45:39 -0500 (EST)
Received: by mail-la0-f50.google.com with SMTP id el20so9493503lab.23
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 00:45:38 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 6si35735305lby.142.2014.01.06.00.45.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 00:45:38 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND 03/11] memcg, slab: cleanup memcg cache initialization/destruction
Date: Mon, 6 Jan 2014 12:44:54 +0400
Message-ID: <c37bfbb652917f782192cd08d3c526d9993aad39.1388996525.git.vdavydov@parallels.com>
In-Reply-To: <cover.1388996525.git.vdavydov@parallels.com>
References: <cover.1388996525.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Currently, we have rather a messy function set relating to per-memcg
kmem cache initialization/destruction.

Per-memcg caches are created in memcg_create_kmem_cache(). This function
calls kmem_cache_create_memcg() to allocate and initialize a kmem cache
and then "registers" the new cache in the memcg_params::memcg_caches
array of the parent cache.

During its work-flow, kmem_cache_create_memcg() executes the following
memcg-related functions:

 - memcg_alloc_cache_params(), to initialize memcg_params of the newly
   created cache;
 - memcg_cache_list_add(), to add the new cache to the memcg_slab_caches
   list.

On the other hand, kmem_cache_destroy() called on a cache destruction
only calls memcg_release_cache(), which does all the work: it cleans the
reference to the cache in its parent's memcg_params::memcg_caches,
removes the cache from the memcg_slab_caches list, and frees
memcg_params.

Such an inconsistency between destruction and initialization paths make
the code difficult to read, so let's clean this up a bit.

This patch moves all the code relating to registration of per-memcg
caches (adding to memcg list, setting the pointer to a cache from its
parent) to the newly created memcg_register_cache() and
memcg_unregister_cache() functions making the initialization and
destruction paths look symmetrical.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/memcontrol.h |    9 +++----
 mm/memcontrol.c            |   64 +++++++++++++++++++++-----------------------
 mm/slab_common.c           |    5 ++--
 3 files changed, 37 insertions(+), 41 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5e6541f..6202406 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -500,8 +500,8 @@ int memcg_cache_id(struct mem_cgroup *memcg);
 int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 			     struct kmem_cache *root_cache);
 void memcg_free_cache_params(struct kmem_cache *s);
-void memcg_release_cache(struct kmem_cache *cachep);
-void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep);
+void memcg_register_cache(struct kmem_cache *s);
+void memcg_unregister_cache(struct kmem_cache *s);
 
 int memcg_update_cache_size(struct kmem_cache *s, int num_groups);
 void memcg_update_array_size(int num_groups);
@@ -651,12 +651,11 @@ static inline void memcg_free_cache_params(struct kmem_cache *s);
 {
 }
 
-static inline void memcg_release_cache(struct kmem_cache *cachep)
+static inline void memcg_register_cache(struct kmem_cache *s)
 {
 }
 
-static inline void memcg_cache_list_add(struct mem_cgroup *memcg,
-					struct kmem_cache *s)
+static inline void memcg_unregister_cache(struct kmem_cache *s)
 {
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8c47910..f8eb994 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3059,16 +3059,6 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 		css_put(&memcg->css);
 }
 
-void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
-{
-	if (!memcg)
-		return;
-
-	mutex_lock(&memcg->slab_caches_mutex);
-	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
-	mutex_unlock(&memcg->slab_caches_mutex);
-}
-
 /*
  * helper for acessing a memcg's index. It will be used as an index in the
  * child cache array in kmem_cache, and also to derive its name. This function
@@ -3229,21 +3219,41 @@ void memcg_free_cache_params(struct kmem_cache *s)
 	kfree(s->memcg_params);
 }
 
-void memcg_release_cache(struct kmem_cache *s)
+void memcg_register_cache(struct kmem_cache *s)
 {
 	struct kmem_cache *root;
 	struct mem_cgroup *memcg;
 	int id;
 
+	if (is_root_cache(s))
+		return;
+
+	root = s->memcg_params->root_cache;
+	memcg = s->memcg_params->memcg;
+	id = memcg_cache_id(memcg);
+
+	css_get(&memcg->css);
+
+	mutex_lock(&memcg->slab_caches_mutex);
+	list_add(&s->memcg_params->list, &memcg->memcg_slab_caches);
+	mutex_unlock(&memcg->slab_caches_mutex);
+
+	root->memcg_params->memcg_caches[id] = s;
 	/*
-	 * This happens, for instance, when a root cache goes away before we
-	 * add any memcg.
+	 * the readers won't lock, make sure everybody sees the updated value,
+	 * so they won't put stuff in the queue again for no reason
 	 */
-	if (!s->memcg_params)
-		return;
+	wmb();
+}
 
-	if (s->memcg_params->is_root_cache)
-		goto out;
+void memcg_unregister_cache(struct kmem_cache *s)
+{
+	struct kmem_cache *root;
+	struct mem_cgroup *memcg;
+	int id;
+
+	if (is_root_cache(s))
+		return;
 
 	memcg = s->memcg_params->memcg;
 	id  = memcg_cache_id(memcg);
@@ -3256,8 +3266,6 @@ void memcg_release_cache(struct kmem_cache *s)
 	mutex_unlock(&memcg->slab_caches_mutex);
 
 	css_put(&memcg->css);
-out:
-	memcg_free_cache_params(s);
 }
 
 /*
@@ -3415,26 +3423,13 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
 	mutex_lock(&memcg_cache_mutex);
 	new_cachep = cache_from_memcg_idx(cachep, idx);
-	if (new_cachep) {
-		css_put(&memcg->css);
+	if (new_cachep)
 		goto out;
-	}
 
 	new_cachep = kmem_cache_dup(memcg, cachep);
-	if (new_cachep == NULL) {
+	if (new_cachep == NULL)
 		new_cachep = cachep;
-		css_put(&memcg->css);
-		goto out;
-	}
-
-	atomic_set(&new_cachep->memcg_params->nr_pages , 0);
 
-	cachep->memcg_params->memcg_caches[idx] = new_cachep;
-	/*
-	 * the readers won't lock, make sure everybody sees the updated value,
-	 * so they won't put stuff in the queue again for no reason
-	 */
-	wmb();
 out:
 	mutex_unlock(&memcg_cache_mutex);
 	return new_cachep;
@@ -3514,6 +3509,7 @@ static void memcg_create_cache_work_func(struct work_struct *w)
 
 	cw = container_of(w, struct create_work, work);
 	memcg_create_kmem_cache(cw->memcg, cw->cachep);
+	css_put(&cw->memcg->css);
 	kfree(cw);
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 70f9e24..db24ec4 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -215,7 +215,7 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 
 	s->refcount = 1;
 	list_add(&s->list, &slab_caches);
-	memcg_cache_list_add(memcg, s);
+	memcg_register_cache(s);
 
 out_unlock:
 	mutex_unlock(&slab_mutex);
@@ -265,7 +265,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
 			if (s->flags & SLAB_DESTROY_BY_RCU)
 				rcu_barrier();
 
-			memcg_release_cache(s);
+			memcg_unregister_cache(s);
+			memcg_free_cache_params(s);
 			kfree(s->name);
 			kmem_cache_free(kmem_cache, s);
 		} else {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
