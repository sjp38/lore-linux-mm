Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id BF93A6B0074
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 03:13:26 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id c6so429978lan.30
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 00:13:26 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y8si39559lae.217.2014.04.23.00.13.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Apr 2014 00:13:25 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 3/3] memcg, slab: simplify synchronization scheme
Date: Wed, 23 Apr 2014 11:13:15 +0400
Message-ID: <04cc42ac7d7d97750e3c003a423d8159610ecb34.1398235154.git.vdavydov@parallels.com>
In-Reply-To: <cover.1398235153.git.vdavydov@parallels.com>
References: <cover.1398235153.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

At present, we have the following mutexes protecting data related to
per memcg kmem caches:

 - slab_mutex. This one is held during the whole kmem cache creation and
   destruction paths. We also take it when updating per root cache
   memcg_caches arrays (see memcg_update_all_caches). As a result,
   taking it guarantees there will be no changes to any kmem cache
   (including per memcg). Why do we need something else then? The point
   is it is private to slab implementation and has some internal
   dependencies with other mutexes (get_online_cpus). So we just don't
   want to rely upon it and prefer to introduce additional mutexes
   instead.

 - activate_kmem_mutex. Initially it was added to synchronize
   initializing kmem limit (memcg_activate_kmem). However, since we can
   grow per root cache memcg_caches arrays only on kmem limit
   initialization (see memcg_update_all_caches), we also employ it to
   protect against memcg_caches arrays relocation (e.g. see
   __kmem_cache_destroy_memcg_children).

 - We have a convention not to take slab_mutex in memcontrol.c, but we
   want to walk over per memcg memcg_slab_caches lists there (e.g. for
   destroying all memcg caches on offline). So we have per memcg
   slab_caches_mutex's protecting those lists.

The mutexes are taken in the following order:

   activate_kmem_mutex -> slab_mutex -> memcg::slab_caches_mutex

Such a syncrhonization scheme has a number of flaws, for instance:

 - We can't call kmem_cache_{destroy,shrink} while walking over a
   memcg::memcg_slab_caches list due to locking order. As a result, in
   mem_cgroup_destroy_all_caches we schedule the
   memcg_cache_params::destroy work shrinking and destroying the cache.

 - We don't have a mutex to synchronize per memcg caches destruction
   between memcg offline (mem_cgroup_destroy_all_caches) and root cache
   destruction (__kmem_cache_destroy_memcg_children). Currently we just
   don't bother about it.

This patch simplifies it by substituting per memcg slab_caches_mutex's
with the global memcg_slab_mutex. It will be held whenever a new per
memcg cache is created or destroyed, so it protects per root cache
memcg_caches arrays and per memcg memcg_slab_caches lists. The locking
order is following:

   activate_kmem_mutex -> memcg_slab_mutex -> slab_mutex

This allows us to call kmem_cache_{create,shrink,destroy} under the
memcg_slab_mutex. As a result, we don't need memcg_cache_params::destroy
work any more - we can simply destroy caches while iterating over a per
memcg slab caches list.

Also using the global mutex simplifies synchronization between
concurrent per memcg caches creation/destruction, e.g.
mem_cgroup_destroy_all_caches vs __kmem_cache_destroy_memcg_children.

The downside of this is that we substitute per-memcg slab_caches_mutex's
with a hummer-like global mutex, but since we already take either the
slab_mutex or the cgroup_mutex along with a memcg::slab_caches_mutex, it
shouldn't hurt concurrency a lot.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |   10 ---
 include/linux/slab.h       |    6 +-
 mm/memcontrol.c            |  150 +++++++++++++++++---------------------------
 mm/slab_common.c           |   23 +++----
 4 files changed, 69 insertions(+), 120 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d38d190f4cec..1fa23244fe37 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -497,8 +497,6 @@ char *memcg_create_cache_name(struct mem_cgroup *memcg,
 int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 			     struct kmem_cache *root_cache);
 void memcg_free_cache_params(struct kmem_cache *s);
-void memcg_register_cache(struct kmem_cache *s);
-void memcg_unregister_cache(struct kmem_cache *s);
 
 int memcg_update_cache_size(struct kmem_cache *s, int num_groups);
 void memcg_update_array_size(int num_groups);
@@ -640,14 +638,6 @@ static inline void memcg_free_cache_params(struct kmem_cache *s)
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
index 905541dd3778..ecbec9ccb80d 100644
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
@@ -525,8 +526,6 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
  * @nr_pages: number of pages that belongs to this cache.
- * @destroy: worker to be called whenever we are ready, or believe we may be
- *           ready, to destroy this cache.
  */
 struct memcg_cache_params {
 	bool is_root_cache;
@@ -540,7 +539,6 @@ struct memcg_cache_params {
 			struct list_head list;
 			struct kmem_cache *root_cache;
 			atomic_t nr_pages;
-			struct work_struct destroy;
 		};
 	};
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 73fe4db2cecd..ea03a4e130ee 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -357,10 +357,9 @@ struct mem_cgroup {
 	struct cg_proto tcp_mem;
 #endif
 #if defined(CONFIG_MEMCG_KMEM)
-	/* analogous to slab_common's slab_caches list. per-memcg */
+	/* analogous to slab_common's slab_caches list, but per-memcg;
+	 * protected by memcg_slab_mutex */
 	struct list_head memcg_slab_caches;
-	/* Not a spinlock, we can take a lot of time walking the list */
-	struct mutex slab_caches_mutex;
         /* Index in the kmem_cache->memcg_params->memcg_caches array */
 	int kmemcg_id;
 #endif
@@ -2910,6 +2909,12 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 static DEFINE_MUTEX(set_limit_mutex);
 
 #ifdef CONFIG_MEMCG_KMEM
+/*
+ * The memcg_slab_mutex is held whenever a per memcg kmem cache is created or
+ * destroyed. It protects memcg_caches arrays and memcg_slab_caches lists.
+ */
+static DEFINE_MUTEX(memcg_slab_mutex);
+
 static DEFINE_MUTEX(activate_kmem_mutex);
 
 static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
@@ -2942,10 +2947,10 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 
 	print_slabinfo_header(m);
 
-	mutex_lock(&memcg->slab_caches_mutex);
+	mutex_lock(&memcg_slab_mutex);
 	list_for_each_entry(params, &memcg->memcg_slab_caches, list)
 		cache_show(memcg_params_to_cache(params), m);
-	mutex_unlock(&memcg->slab_caches_mutex);
+	mutex_unlock(&memcg_slab_mutex);
 
 	return 0;
 }
@@ -3047,8 +3052,6 @@ void memcg_update_array_size(int num)
 		memcg_limited_groups_array_size = memcg_caches_array_size(num);
 }
 
-static void kmem_cache_destroy_work_func(struct work_struct *w);
-
 int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 {
 	struct memcg_cache_params *cur_params = s->memcg_params;
@@ -3145,8 +3148,6 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 	if (memcg) {
 		s->memcg_params->memcg = memcg;
 		s->memcg_params->root_cache = root_cache;
-		INIT_WORK(&s->memcg_params->destroy,
-				kmem_cache_destroy_work_func);
 		css_get(&memcg->css);
 	} else
 		s->memcg_params->is_root_cache = true;
@@ -3163,24 +3164,34 @@ void memcg_free_cache_params(struct kmem_cache *s)
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
 
-	if (is_root_cache(s))
+	lockdep_assert_held(&memcg_slab_mutex);
+
+	id = memcg_cache_id(memcg);
+
+	/*
+	 * Since per-memcg caches are created asynchronously on first
+	 * allocation (see memcg_kmem_get_cache()), several threads can try to
+	 * create the same cache, but only one of them may succeed.
+	 */
+	if (cache_from_memcg_idx(root_cache, id))
 		return;
 
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
+		return;
 
-	root = s->memcg_params->root_cache;
-	memcg = s->memcg_params->memcg;
-	id = memcg_cache_id(memcg);
+	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
 
 	/*
 	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
@@ -3189,49 +3200,30 @@ void memcg_register_cache(struct kmem_cache *s)
 	 */
 	smp_wmb();
 
-	/*
-	 * Initialize the pointer to this cache in its parent's memcg_params
-	 * before adding it to the memcg_slab_caches list, otherwise we can
-	 * fail to convert memcg_params_to_cache() while traversing the list.
-	 */
-	VM_BUG_ON(root->memcg_params->memcg_caches[id]);
-	root->memcg_params->memcg_caches[id] = s;
-
-	mutex_lock(&memcg->slab_caches_mutex);
-	list_add(&s->memcg_params->list, &memcg->memcg_slab_caches);
-	mutex_unlock(&memcg->slab_caches_mutex);
+	BUG_ON(root_cache->memcg_params->memcg_caches[id]);
+	root_cache->memcg_params->memcg_caches[id] = cachep;
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
+	lockdep_assert_held(&memcg_slab_mutex);
 
-	/*
-	 * Holding the slab_mutex assures nobody will touch the memcg_caches
-	 * array while we are modifying it.
-	 */
-	lockdep_assert_held(&slab_mutex);
+	BUG_ON(is_root_cache(cachep));
 
-	root = s->memcg_params->root_cache;
-	memcg = s->memcg_params->memcg;
+	root_cache = cachep->memcg_params->root_cache;
+	memcg = cachep->memcg_params->memcg;
 	id = memcg_cache_id(memcg);
 
-	mutex_lock(&memcg->slab_caches_mutex);
-	list_del(&s->memcg_params->list);
-	mutex_unlock(&memcg->slab_caches_mutex);
+	BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
+	root_cache->memcg_params->memcg_caches[id] = NULL;
 
-	/*
-	 * Clear the pointer to this cache in its parent's memcg_params only
-	 * after removing it from the memcg_slab_caches list, otherwise we can
-	 * fail to convert memcg_params_to_cache() while traversing the list.
-	 */
-	VM_BUG_ON(root->memcg_params->memcg_caches[id] != s);
-	root->memcg_params->memcg_caches[id] = NULL;
+	list_del(&cachep->memcg_params->list);
+
+	kmem_cache_destroy(cachep);
 }
 
 /*
@@ -3265,70 +3257,42 @@ static inline void memcg_resume_kmem_account(void)
 	current->memcg_kmem_skip_account--;
 }
 
-static void kmem_cache_destroy_work_func(struct work_struct *w)
-{
-	struct kmem_cache *cachep;
-	struct memcg_cache_params *p;
-
-	p = container_of(w, struct memcg_cache_params, destroy);
-
-	cachep = memcg_params_to_cache(p);
-
-	kmem_cache_shrink(cachep);
-	if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
-		kmem_cache_destroy(cachep);
-}
-
 int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 {
 	struct kmem_cache *c;
 	int i, failed = 0;
 
-	/*
-	 * If the cache is being destroyed, we trust that there is no one else
-	 * requesting objects from it. Even if there are, the sanity checks in
-	 * kmem_cache_destroy should caught this ill-case.
-	 *
-	 * Still, we don't want anyone else freeing memcg_caches under our
-	 * noses, which can happen if a new memcg comes to life. As usual,
-	 * we'll take the activate_kmem_mutex to protect ourselves against
-	 * this.
-	 */
-	mutex_lock(&activate_kmem_mutex);
+	mutex_lock(&memcg_slab_mutex);
 	for_each_memcg_cache_index(i) {
 		c = cache_from_memcg_idx(s, i);
 		if (!c)
 			continue;
 
-		/*
-		 * We will now manually delete the caches, so to avoid races
-		 * we need to cancel all pending destruction workers and
-		 * proceed with destruction ourselves.
-		 */
-		cancel_work_sync(&c->memcg_params->destroy);
-		kmem_cache_destroy(c);
+		memcg_kmem_destroy_cache(c);
 
 		if (cache_from_memcg_idx(s, i))
 			failed++;
 	}
-	mutex_unlock(&activate_kmem_mutex);
+	mutex_unlock(&memcg_slab_mutex);
 	return failed;
 }
 
 static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 {
 	struct kmem_cache *cachep;
-	struct memcg_cache_params *params;
+	struct memcg_cache_params *params, *tmp;
 
 	if (!memcg_kmem_is_active(memcg))
 		return;
 
-	mutex_lock(&memcg->slab_caches_mutex);
-	list_for_each_entry(params, &memcg->memcg_slab_caches, list) {
+	mutex_lock(&memcg_slab_mutex);
+	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
-		schedule_work(&cachep->memcg_params->destroy);
+		kmem_cache_shrink(cachep);
+		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
+			memcg_kmem_destroy_cache(cachep);
 	}
-	mutex_unlock(&memcg->slab_caches_mutex);
+	mutex_unlock(&memcg_slab_mutex);
 }
 
 struct create_work {
@@ -3343,7 +3307,10 @@ static void memcg_create_cache_work_func(struct work_struct *w)
 	struct mem_cgroup *memcg = cw->memcg;
 	struct kmem_cache *cachep = cw->cachep;
 
-	kmem_cache_create_memcg(memcg, cachep);
+	mutex_lock(&memcg_slab_mutex);
+	memcg_kmem_create_cache(memcg, cachep);
+	mutex_unlock(&memcg_slab_mutex);
+
 	css_put(&memcg->css);
 	kfree(cw);
 }
@@ -5027,13 +4994,14 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 	 * Make sure we have enough space for this cgroup in each root cache's
 	 * memcg_params.
 	 */
+	mutex_lock(&memcg_slab_mutex);
 	err = memcg_update_all_caches(memcg_id + 1);
+	mutex_unlock(&memcg_slab_mutex);
 	if (err)
 		goto out_rmid;
 
 	memcg->kmemcg_id = memcg_id;
 	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
-	mutex_init(&memcg->slab_caches_mutex);
 
 	/*
 	 * We couldn't have accounted to this cgroup, because it hasn't got the
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 94db71602bfb..4f16f374392a 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -160,7 +160,6 @@ do_kmem_cache_create(char *name, size_t object_size, size_t size, size_t align,
 
 	s->refcount = 1;
 	list_add(&s->list, &slab_caches);
-	memcg_register_cache(s);
 out:
 	if (err)
 		return ERR_PTR(err);
@@ -270,9 +269,10 @@ EXPORT_SYMBOL(kmem_cache_create);
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
@@ -280,14 +280,6 @@ void kmem_cache_create_memcg(struct mem_cgroup *memcg, struct kmem_cache *root_c
 
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
@@ -296,14 +288,18 @@ void kmem_cache_create_memcg(struct mem_cgroup *memcg, struct kmem_cache *root_c
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
 
 	put_online_mems();
 	put_online_cpus();
+
+	return s;
 }
 
 static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
@@ -342,11 +338,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
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
