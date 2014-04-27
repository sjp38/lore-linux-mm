Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id BD5766B006C
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 05:04:20 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id c6so4171829lan.2
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 02:04:20 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id j1si2788883laf.132.2014.04.27.02.04.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Apr 2014 02:04:19 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 5/6] memcg: cleanup kmem cache creation/destruction functions naming
Date: Sun, 27 Apr 2014 13:04:07 +0400
Message-ID: <d8a54ab48081d8b8d19530fd60f58d683166c0da.1398587474.git.vdavydov@parallels.com>
In-Reply-To: <cover.1398587474.git.vdavydov@parallels.com>
References: <cover.1398587474.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Current names are rather confusing. Let's try to improve them.

Brief change log:

** old name **                          ** new name **

kmem_cache_create_memcg                 kmem_cache_request_memcg_copy
memcg_kmem_create_cache                 memcg_copy_kmem_cache
memcg_kmem_destroy_cache                memcg_destroy_kmem_cache_copy

__kmem_cache_destroy_memcg_children     __kmem_cache_destroy_memcg_copies
kmem_cache_destroy_memcg_children       kmem_cache_destroy_memcg_copies
mem_cgroup_destroy_all_caches           memcg_destroy_kmem_cache_copies

create_work                             memcg_kmem_cache_copy_work
memcg_create_cache_work_func            memcg_kmem_cache_copy_work_func
memcg_create_cache_enqueue              memcg_schedule_kmem_cache_copy

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    2 +-
 include/linux/slab.h       |    6 +--
 mm/memcontrol.c            |   90 +++++++++++++++++++++++++-------------------
 mm/slab_common.c           |   29 +++++++-------
 4 files changed, 69 insertions(+), 58 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3aee79fc7876..b20f533a92ca 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -498,7 +498,7 @@ __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
 
-int __kmem_cache_destroy_memcg_children(struct kmem_cache *s);
+int __kmem_cache_destroy_memcg_copies(struct kmem_cache *cachep);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
diff --git a/include/linux/slab.h b/include/linux/slab.h
index d041539b2bfb..ecb26a4547fe 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -116,9 +116,9 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *));
 #ifdef CONFIG_MEMCG_KMEM
-struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *,
-					   struct kmem_cache *,
-					   const char *);
+struct kmem_cache *kmem_cache_request_memcg_copy(struct kmem_cache *,
+						 struct mem_cgroup *,
+						 const char *);
 int kmem_cache_init_memcg_array(struct kmem_cache *, int);
 int kmem_cache_memcg_arrays_grow(int);
 #endif
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 415c81c2710a..c795c3e388dc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3099,8 +3099,12 @@ static int memcg_prepare_kmem_cache(struct kmem_cache *cachep)
 	return ret;
 }
 
-static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
-				    struct kmem_cache *root_cache)
+/*
+ * Creates a copy of the given kmem cache to be used for fulfilling allocation
+ * requests coming from the memcg to the cache.
+ */
+static void memcg_copy_kmem_cache(struct mem_cgroup *memcg,
+				  struct kmem_cache *root_cache)
 {
 	static char memcg_name[NAME_MAX + 1];
 	struct kmem_cache *cachep;
@@ -3119,7 +3123,7 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 		return;
 
 	cgroup_name(memcg->css.cgroup, memcg_name, NAME_MAX + 1);
-	cachep = kmem_cache_create_memcg(memcg, root_cache, memcg_name);
+	cachep = kmem_cache_request_memcg_copy(root_cache, memcg, memcg_name);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
 	 * that's not critical at all as we can always proceed with the root
@@ -3142,7 +3146,8 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	root_cache->memcg_params->memcg_caches[id] = cachep;
 }
 
-static int memcg_kmem_destroy_cache(struct kmem_cache *cachep)
+/* Attempts to destroy a per memcg kmem cache copy. Returns 0 on success. */
+static int memcg_destroy_kmem_cache_copy(struct kmem_cache *cachep)
 {
 	struct kmem_cache *root_cache;
 	struct mem_cgroup *memcg;
@@ -3208,25 +3213,39 @@ static inline void memcg_resume_kmem_account(void)
 	current->memcg_kmem_skip_account--;
 }
 
-int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+/*
+ * Attempts to destroy all per memcg copies of the given kmem cache. Called on
+ * kmem cache destruction. Returns 0 on success.
+ */
+int __kmem_cache_destroy_memcg_copies(struct kmem_cache *cachep)
 {
 	struct kmem_cache *c;
-	int i, failed = 0;
+	int i;
+	int ret = 0;
+
+	BUG_ON(!is_root_cache(cachep));
 
 	mutex_lock(&memcg_slab_mutex);
 	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg_idx(s, i);
+		c = cache_from_memcg_idx(cachep, i);
 		if (!c)
 			continue;
 
-		if (memcg_kmem_destroy_cache(c) != 0)
-			failed++;
+		if (memcg_destroy_kmem_cache_copy(c) != 0)
+			ret = -EBUSY;
 	}
 	mutex_unlock(&memcg_slab_mutex);
-	return failed;
+	return ret;
 }
 
-static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
+/*
+ * Attempts to destroy all kmem cache copies corresponding to the given memcg.
+ * Called on css offline.
+ *
+ * XXX: Caches that still have objects on css offline will be leaked. Need to
+ * reparent them instead.
+ */
+static void memcg_destroy_kmem_cache_copies(struct mem_cgroup *memcg)
 {
 	struct kmem_cache *cachep;
 	struct memcg_cache_params *params, *tmp;
@@ -3239,20 +3258,21 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 		cachep = memcg_params_to_cache(params);
 		kmem_cache_shrink(cachep);
 		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
-			memcg_kmem_destroy_cache(cachep);
+			memcg_destroy_kmem_cache_copy(cachep);
 	}
 	mutex_unlock(&memcg_slab_mutex);
 }
 
-struct create_work {
+struct memcg_kmem_cache_copy_work {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *cachep;
 	struct work_struct work;
 };
 
-static void memcg_create_cache_work_func(struct work_struct *w)
+static void memcg_kmem_cache_copy_work_func(struct work_struct *w)
 {
-	struct create_work *cw = container_of(w, struct create_work, work);
+	struct memcg_kmem_cache_copy_work *cw = container_of(w,
+			struct memcg_kmem_cache_copy_work, work);
 	struct mem_cgroup *memcg = cw->memcg;
 	struct kmem_cache *cachep = cw->cachep;
 
@@ -3260,22 +3280,19 @@ static void memcg_create_cache_work_func(struct work_struct *w)
 		goto out;
 
 	mutex_lock(&memcg_slab_mutex);
-	memcg_kmem_create_cache(memcg, cachep);
+	memcg_copy_kmem_cache(memcg, cachep);
 	mutex_unlock(&memcg_slab_mutex);
 out:
 	css_put(&memcg->css);
 	kfree(cw);
 }
 
-/*
- * Enqueue the creation of a per-memcg kmem_cache.
- */
-static void __memcg_create_cache_enqueue(struct mem_cgroup *memcg,
-					 struct kmem_cache *cachep)
+static void __memcg_schedule_kmem_cache_copy(struct mem_cgroup *memcg,
+					     struct kmem_cache *cachep)
 {
-	struct create_work *cw;
+	struct memcg_kmem_cache_copy_work *cw;
 
-	cw = kmalloc(sizeof(struct create_work), GFP_NOWAIT);
+	cw = kmalloc(sizeof(*cw), GFP_NOWAIT);
 	if (cw == NULL) {
 		css_put(&memcg->css);
 		return;
@@ -3283,18 +3300,18 @@ static void __memcg_create_cache_enqueue(struct mem_cgroup *memcg,
 
 	cw->memcg = memcg;
 	cw->cachep = cachep;
+	INIT_WORK(&cw->work, memcg_kmem_cache_copy_work_func);
 
-	INIT_WORK(&cw->work, memcg_create_cache_work_func);
 	schedule_work(&cw->work);
 }
 
-static void memcg_create_cache_enqueue(struct mem_cgroup *memcg,
-				       struct kmem_cache *cachep)
+static void memcg_schedule_kmem_cache_copy(struct mem_cgroup *memcg,
+					   struct kmem_cache *cachep)
 {
 	/*
 	 * We need to stop accounting when we kmalloc, because if the
 	 * corresponding kmalloc cache is not yet created, the first allocation
-	 * in __memcg_create_cache_enqueue will recurse.
+	 * in __memcg_schedule_kmem_cache_copy will recurse.
 	 *
 	 * However, it is better to enclose the whole function. Depending on
 	 * the debugging options enabled, INIT_WORK(), for instance, can
@@ -3303,7 +3320,7 @@ static void memcg_create_cache_enqueue(struct mem_cgroup *memcg,
 	 * the safest choice is to do it like this, wrapping the whole function.
 	 */
 	memcg_stop_kmem_account();
-	__memcg_create_cache_enqueue(memcg, cachep);
+	__memcg_schedule_kmem_cache_copy(memcg, cachep);
 	memcg_resume_kmem_account();
 }
 
@@ -3367,22 +3384,17 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 
 	/*
 	 * If we are in a safe context (can wait, and not in interrupt
-	 * context), we could be be predictable and return right away.
+	 * context), we could be predictable and return right away.
 	 * This would guarantee that the allocation being performed
 	 * already belongs in the new cache.
 	 *
 	 * However, there are some clashes that can arrive from locking.
 	 * For instance, because we acquire the slab_mutex while doing
-	 * kmem_cache_dup, this means no further allocation could happen
-	 * with the slab_mutex held.
-	 *
-	 * Also, because cache creation issue get_online_cpus(), this
-	 * creates a lock chain: memcg_slab_mutex -> cpu_hotplug_mutex,
-	 * that ends up reversed during cpu hotplug. (cpuset allocates
-	 * a bunch of GFP_KERNEL memory during cpuup). Due to all that,
+	 * kmem_cache_request_memcg_copy, this means no further
+	 * allocation could happen with the slab_mutex held. So it's
 	 * better to defer everything.
 	 */
-	memcg_create_cache_enqueue(memcg, cachep);
+	memcg_schedule_kmem_cache_copy(memcg, cachep);
 	return cachep;
 out:
 	rcu_read_unlock();
@@ -3506,7 +3518,7 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
 }
 #else
-static inline void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
+static inline void memcg_destroy_kmem_cache_copies(struct mem_cgroup *memcg)
 {
 }
 #endif /* CONFIG_MEMCG_KMEM */
@@ -6341,7 +6353,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	css_for_each_descendant_post(iter, css)
 		mem_cgroup_reparent_charges(mem_cgroup_from_css(iter));
 
-	mem_cgroup_destroy_all_caches(memcg);
+	memcg_destroy_kmem_cache_copies(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 055506ba6d37..36c7d32a6f97 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -302,18 +302,18 @@ EXPORT_SYMBOL(kmem_cache_create);
 
 #ifdef CONFIG_MEMCG_KMEM
 /*
- * kmem_cache_create_memcg - Create a cache for a memory cgroup.
+ * kmem_cache_request_memcg_copy - Create a cache for a memory cgroup.
+ * @cachep: The kmem cache to make a copy of.
  * @memcg: The memory cgroup the new cache is for.
- * @root_cache: The parent of the new cache.
  * @memcg_name: The name of the memory cgroup.
  *
  * This function attempts to create a kmem cache that will serve allocation
- * requests going from @memcg to @root_cache. The new cache inherits properties
+ * requests going from @memcg to @cachep. The new cache inherits properties
  * from its parent.
  */
-struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *memcg,
-					   struct kmem_cache *root_cache,
-					   const char *memcg_name)
+struct kmem_cache *kmem_cache_request_memcg_copy(struct kmem_cache *cachep,
+						 struct mem_cgroup *memcg,
+						 const char *memcg_name)
 {
 	struct kmem_cache *s = NULL;
 	char *cache_name = NULL;
@@ -329,16 +329,15 @@ struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *memcg,
 		goto out_unlock;
 
 	memcg_params->memcg = memcg;
-	memcg_params->root_cache = root_cache;
+	memcg_params->root_cache = cachep;
 
-	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
+	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", cachep->name,
 			       memcg_cache_id(memcg), memcg_name);
 	if (!cache_name)
 		goto out_unlock;
 
-	s = do_kmem_cache_create(cache_name, root_cache->object_size,
-				 root_cache->size, root_cache->align,
-				 root_cache->flags, root_cache->ctor,
+	s = do_kmem_cache_create(cache_name, cachep->object_size, cachep->size,
+				 cachep->align, cachep->flags, cachep->ctor,
 				 memcg_params);
 	if (IS_ERR(s))
 		s = NULL;
@@ -356,7 +355,7 @@ out_unlock:
 	return s;
 }
 
-static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+static int kmem_cache_destroy_memcg_copies(struct kmem_cache *s)
 {
 	int rc;
 
@@ -365,13 +364,13 @@ static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		return 0;
 
 	mutex_unlock(&slab_mutex);
-	rc = __kmem_cache_destroy_memcg_children(s);
+	rc = __kmem_cache_destroy_memcg_copies(s);
 	mutex_lock(&slab_mutex);
 
 	return rc;
 }
 #else
-static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+static int kmem_cache_destroy_memcg_copies(struct kmem_cache *s)
 {
 	return 0;
 }
@@ -398,7 +397,7 @@ int kmem_cache_destroy(struct kmem_cache *s)
 		goto out_unlock;
 
 	ret = -EBUSY;
-	if (kmem_cache_destroy_memcg_children(s) != 0)
+	if (kmem_cache_destroy_memcg_copies(s) != 0)
 		goto out_unlock;
 
 	list_del(&s->list);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
