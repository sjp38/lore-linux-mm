Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFD26B0036
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 11:02:45 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id z11so1235022lbi.22
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 08:02:43 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id gm4si1162152lbc.215.2014.04.09.08.02.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Apr 2014 08:02:42 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 3/4] memcg, slab: change memcg::slab_caches_mutex vs slab_mutex locking order
Date: Wed, 9 Apr 2014 19:02:32 +0400
Message-ID: <e1768486536973a5ca6cfe766e732e72f40c8804.1397054470.git.vdavydov@parallels.com>
In-Reply-To: <cover.1397054470.git.vdavydov@parallels.com>
References: <cover.1397054470.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

When creating/destroying a kmem cache for a memcg we must hold two locks
- memcg::slab_caches_mutex, which protects memcg caches list, and the
slab_mutex taken by kmem_cache_create/destroy. Currently we first take
the slab_mutex and then in memcg_{un}register_cache take the memcg's
slab_caches_mutex in order to synchronize changes to memcg caches list.

Such a locking order create the ugly dependency, which prevents us from
calling kmem_cache_shrink/destroy while iterating per-memcg caches list,
because we must hold memcg::slab_caches_mutex to protect against changes
to the list. As a result, in mem_cgroup_destroy_all_caches we can't just
shrink and destroy a memcg cache if it's get emptied. Instead we
schedule an async work that does the trick.

This patch changes the locking order of the two mutexes to opposite so
that we could get rid of the memcg cache destruction work (this is done
in the next patch).

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   10 -----
 include/linux/slab.h       |    3 +-
 mm/memcontrol.c            |   89 +++++++++++++++++++++++---------------------
 mm/slab_common.c           |   22 ++++-------
 4 files changed, 56 insertions(+), 68 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index da87fa2124cf..d815b26f8086 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -503,8 +503,6 @@ char *memcg_create_cache_name(struct mem_cgroup *memcg,
 int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 			     struct kmem_cache *root_cache);
 void memcg_free_cache_params(struct kmem_cache *s);
-void memcg_register_cache(struct kmem_cache *s);
-void memcg_unregister_cache(struct kmem_cache *s);
 
 int memcg_update_cache_size(struct kmem_cache *s, int num_groups);
 void memcg_update_array_size(int num_groups);
@@ -646,14 +644,6 @@ static inline void memcg_free_cache_params(struct kmem_cache *s)
 {
 }
 
-static inline void memcg_register_cache(struct kmem_cache *s)
-{
-}
-
-static inline void memcg_unregister_cache(struct kmem_cache *s)
-{
-}
-
 static inline struct kmem_cache *
 memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 0217e05e1d83..22ebcf475814 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -116,7 +116,8 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *));
 #ifdef CONFIG_MEMCG_KMEM
-void kmem_cache_create_memcg(struct mem_cgroup *, struct kmem_cache *);
+struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *,
+					   struct kmem_cache *);
 #endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 253d6a064d89..9621157f2e5b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3156,24 +3156,33 @@ void memcg_free_cache_params(struct kmem_cache *s)
 	kfree(s->memcg_params);
 }
 
-void memcg_register_cache(struct kmem_cache *s)
+static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
+				    struct kmem_cache *root_cache)
 {
-	struct kmem_cache *root;
-	struct mem_cgroup *memcg;
+	struct kmem_cache *cachep;
 	int id;
+	
+	id = memcg_cache_id(memcg);
 
-	if (is_root_cache(s))
-		return;
+	mutex_lock(&memcg->slab_caches_mutex);
+	/*
+	 * Since per-memcg caches are created asynchronously on first
+	 * allocation (see memcg_kmem_get_cache()), several threads can try to
+	 * create the same cache, but only one of them may succeed.
+	 */
+	if (cache_from_memcg_idx(root_cache, id))
+		goto out;
 
+	cachep = kmem_cache_create_memcg(memcg, root_cache);
 	/*
-	 * Holding the slab_mutex assures nobody will touch the memcg_caches
-	 * array while we are modifying it.
+	 * If we could not create a memcg cache, do not complain, because
+	 * that's not critical at all as we can always proceed with the root
+	 * cache.
 	 */
-	lockdep_assert_held(&slab_mutex);
+	if (!cachep)
+		goto out;
 
-	root = s->memcg_params->root_cache;
-	memcg = s->memcg_params->memcg;
-	id = memcg_cache_id(memcg);
+	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
 
 	/*
 	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
@@ -3183,48 +3192,45 @@ void memcg_register_cache(struct kmem_cache *s)
 	smp_wmb();
 
 	/*
-	 * Initialize the pointer to this cache in its parent's memcg_params
-	 * before adding it to the memcg_slab_caches list, otherwise we can
-	 * fail to convert memcg_params_to_cache() while traversing the list.
+	 * Holding the activate_kmem_mutex assures nobody will touch the
+	 * memcg_caches array while we are modifying it.
 	 */
-	VM_BUG_ON(root->memcg_params->memcg_caches[id]);
-	root->memcg_params->memcg_caches[id] = s;
-
-	mutex_lock(&memcg->slab_caches_mutex);
-	list_add(&s->memcg_params->list, &memcg->memcg_slab_caches);
+	mutex_lock(&activate_kmem_mutex);
+	BUG_ON(root_cache->memcg_params->memcg_caches[id]);
+	root_cache->memcg_params->memcg_caches[id] = cachep;
+	mutex_unlock(&activate_kmem_mutex);
+out:
 	mutex_unlock(&memcg->slab_caches_mutex);
 }
 
-void memcg_unregister_cache(struct kmem_cache *s)
+static void memcg_kmem_destroy_cache(struct kmem_cache *cachep)
 {
-	struct kmem_cache *root;
+	struct kmem_cache *root_cache;
 	struct mem_cgroup *memcg;
 	int id;
 
-	if (is_root_cache(s))
-		return;
+	BUG_ON(is_root_cache(cachep));
 
-	/*
-	 * Holding the slab_mutex assures nobody will touch the memcg_caches
-	 * array while we are modifying it.
-	 */
-	lockdep_assert_held(&slab_mutex);
-
-	root = s->memcg_params->root_cache;
-	memcg = s->memcg_params->memcg;
+	root_cache = cachep->memcg_params->root_cache;
+	memcg = cachep->memcg_params->memcg;
 	id = memcg_cache_id(memcg);
 
 	mutex_lock(&memcg->slab_caches_mutex);
-	list_del(&s->memcg_params->list);
-	mutex_unlock(&memcg->slab_caches_mutex);
 
 	/*
-	 * Clear the pointer to this cache in its parent's memcg_params only
-	 * after removing it from the memcg_slab_caches list, otherwise we can
-	 * fail to convert memcg_params_to_cache() while traversing the list.
+	 * Holding the activate_kmem_mutex assures nobody will touch the
+	 * memcg_caches array while we are modifying it.
 	 */
-	VM_BUG_ON(root->memcg_params->memcg_caches[id] != s);
-	root->memcg_params->memcg_caches[id] = NULL;
+	mutex_lock(&activate_kmem_mutex);
+	BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
+	root_cache->memcg_params->memcg_caches[id] = NULL;
+	mutex_unlock(&activate_kmem_mutex);
+
+	list_del(&cachep->memcg_params->list);
+
+	kmem_cache_destroy(cachep);
+
+	mutex_unlock(&memcg->slab_caches_mutex);
 }
 
 /*
@@ -3264,12 +3270,11 @@ static void kmem_cache_destroy_work_func(struct work_struct *w)
 	struct memcg_cache_params *p;
 
 	p = container_of(w, struct memcg_cache_params, destroy);
-
 	cachep = memcg_params_to_cache(p);
 
 	kmem_cache_shrink(cachep);
 	if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
-		kmem_cache_destroy(cachep);
+		memcg_kmem_destroy_cache(cachep);
 }
 
 int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
@@ -3299,7 +3304,7 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		 * proceed with destruction ourselves.
 		 */
 		cancel_work_sync(&c->memcg_params->destroy);
-		kmem_cache_destroy(c);
+		memcg_kmem_destroy_cache(c);
 
 		if (cache_from_memcg_idx(s, i))
 			failed++;
@@ -3336,7 +3341,7 @@ static void memcg_create_cache_work_func(struct work_struct *w)
 	struct mem_cgroup *memcg = cw->memcg;
 	struct kmem_cache *cachep = cw->cachep;
 
-	kmem_cache_create_memcg(memcg, cachep);
+	memcg_kmem_create_cache(memcg, cachep);
 	css_put(&memcg->css);
 	kfree(cw);
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index cab4c49b3e8c..b3968ca1e55d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -160,7 +160,6 @@ do_kmem_cache_create(char *name, size_t object_size, size_t size, size_t align,
 
 	s->refcount = 1;
 	list_add(&s->list, &slab_caches);
-	memcg_register_cache(s);
 out:
 	if (err)
 		return ERR_PTR(err);
@@ -266,22 +265,15 @@ EXPORT_SYMBOL(kmem_cache_create);
  * requests going from @memcg to @root_cache. The new cache inherits properties
  * from its parent.
  */
-void kmem_cache_create_memcg(struct mem_cgroup *memcg, struct kmem_cache *root_cache)
+struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *memcg,
+					   struct kmem_cache *root_cache)
 {
-	struct kmem_cache *s;
+	struct kmem_cache *s = NULL;
 	char *cache_name;
 
 	get_online_cpus();
 	mutex_lock(&slab_mutex);
 
-	/*
-	 * Since per-memcg caches are created asynchronously on first
-	 * allocation (see memcg_kmem_get_cache()), several threads can try to
-	 * create the same cache, but only one of them may succeed.
-	 */
-	if (cache_from_memcg_idx(root_cache, memcg_cache_id(memcg)))
-		goto out_unlock;
-
 	cache_name = memcg_create_cache_name(memcg, root_cache);
 	if (!cache_name)
 		goto out_unlock;
@@ -290,12 +282,15 @@ void kmem_cache_create_memcg(struct mem_cgroup *memcg, struct kmem_cache *root_c
 				 root_cache->size, root_cache->align,
 				 root_cache->flags, root_cache->ctor,
 				 memcg, root_cache);
-	if (IS_ERR(s))
+	if (IS_ERR(s)) {
 		kfree(cache_name);
+		s = NULL;
+	}
 
 out_unlock:
 	mutex_unlock(&slab_mutex);
 	put_online_cpus();
+	return s;
 }
 
 static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
@@ -332,11 +327,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
 		goto out_unlock;
 
 	list_del(&s->list);
-	memcg_unregister_cache(s);
-
 	if (__kmem_cache_shutdown(s) != 0) {
 		list_add(&s->list, &slab_caches);
-		memcg_register_cache(s);
 		printk(KERN_ERR "kmem_cache_destroy %s: "
 		       "Slab cache still has objects\n", s->name);
 		dump_stack();
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
