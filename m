Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0016B003B
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 08:33:24 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id p9so1781657lbv.31
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 05:33:23 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id wk2si1777390lbb.77.2014.04.25.05.33.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Apr 2014 05:33:22 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 5/6] memcg: cleanup kmem cache creation/destruction functions naming
Date: Fri, 25 Apr 2014 16:33:11 +0400
Message-ID: <a6700a550361b6858c2424815cd2d4461b1b6ac8.1398428532.git.vdavydov@parallels.com>
In-Reply-To: <cover.1398428532.git.vdavydov@parallels.com>
References: <cover.1398428532.git.vdavydov@parallels.com>
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

__kmem_cache_destroy_memcg_children     kmem_cache_destroy_memcg_copies
kmem_cache_destroy_memcg_children       kmem_cache_destroy_memcg_array
mem_cgroup_destroy_all_caches           memcg_destroy_kmem_cache_copies

create_work                             memcg_kmem_cache_copy_work
memcg_create_cache_work_func            memcg_kmem_cache_copy_work_func
memcg_create_cache_enqueue              memcg_schedule_kmem_cache_copy

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    2 +-
 include/linux/slab.h       |    4 +-
 mm/memcontrol.c            |   92 +++++++++++++++++++++++++-------------------
 mm/slab_common.c           |   14 +++----
 4 files changed, 62 insertions(+), 50 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3aee79fc7876..3ee73da2991b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -498,7 +498,7 @@ __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
 
-int __kmem_cache_destroy_memcg_children(struct kmem_cache *s);
+int kmem_cache_destroy_memcg_copies(struct kmem_cache *cachep);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 22cc9cab4279..1f22c6130f1a 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -118,8 +118,8 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *));
 #ifdef CONFIG_MEMCG_KMEM
-struct kmem_cache *kmem_cache_create_memcg(struct memcg_cache_params *,
-					   const char *);
+struct kmem_cache *kmem_cache_request_memcg_copy(struct memcg_cache_params *,
+						 const char *);
 int kmem_cache_init_memcg_array(struct kmem_cache *, int);
 int kmem_cache_grow_memcg_arrays(int);
 #endif
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b6ddbe8b4364..bdd3d373cdca 100644
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
 	struct memcg_cache_params *params;
@@ -3127,7 +3131,7 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	params->root_cache = root_cache;
 
 	cgroup_name(memcg->css.cgroup, memcg_name, NAME_MAX + 1);
-	cachep = kmem_cache_create_memcg(params, memcg_name);
+	cachep = kmem_cache_request_memcg_copy(params, memcg_name);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
 	 * that's not critical at all as we can always proceed with the root
@@ -3152,7 +3156,8 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	root_cache->memcg_params->memcg_caches[id] = cachep;
 }
 
-static int memcg_kmem_destroy_cache(struct kmem_cache *cachep)
+/* Attempts to destroy a per memcg kmem cache copy. Returns 0 on success. */
+static int memcg_destroy_kmem_cache_copy(struct kmem_cache *cachep)
 {
 	struct kmem_cache *root_cache;
 	struct mem_cgroup *memcg;
@@ -3225,25 +3230,39 @@ static inline void memcg_resume_kmem_account(void)
 	current->memcg_kmem_skip_account--;
 }
 
-int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+/*
+ * Attempts to destroy all per memcg copies of the given kmem cache. Called on
+ * kmem cache destruction. Returns 0 on success.
+ */
+int kmem_cache_destroy_memcg_copies(struct kmem_cache *cachep)
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
@@ -3256,20 +3275,21 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
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
 
@@ -3277,22 +3297,19 @@ static void memcg_create_cache_work_func(struct work_struct *w)
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
@@ -3300,18 +3317,18 @@ static void __memcg_create_cache_enqueue(struct mem_cgroup *memcg,
 
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
@@ -3320,7 +3337,7 @@ static void memcg_create_cache_enqueue(struct mem_cgroup *memcg,
 	 * the safest choice is to do it like this, wrapping the whole function.
 	 */
 	memcg_stop_kmem_account();
-	__memcg_create_cache_enqueue(memcg, cachep);
+	__memcg_schedule_kmem_cache_copy(memcg, cachep);
 	memcg_resume_kmem_account();
 }
 
@@ -3384,22 +3401,17 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 
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
-	 * better to defer everything.
+	 * kmem_cache_create, this means no further allocation could
+	 * happen with the slab_mutex held. So it's better to defer
+	 * everything.
 	 */
-	memcg_create_cache_enqueue(memcg, cachep);
+	memcg_schedule_kmem_cache_copy(memcg, cachep);
 	return cachep;
 out:
 	rcu_read_unlock();
@@ -3523,7 +3535,7 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
 }
 #else
-static inline void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
+static inline void memcg_destroy_kmem_cache_copies(struct mem_cgroup *memcg)
 {
 }
 #endif /* CONFIG_MEMCG_KMEM */
@@ -6358,7 +6370,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	css_for_each_descendant_post(iter, css)
 		mem_cgroup_reparent_charges(mem_cgroup_from_css(iter));
 
-	mem_cgroup_destroy_all_caches(memcg);
+	memcg_destroy_kmem_cache_copies(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index cb4e2293ec46..36d9b866a3ab 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -304,7 +304,7 @@ EXPORT_SYMBOL(kmem_cache_create);
 
 #ifdef CONFIG_MEMCG_KMEM
 /*
- * kmem_cache_create_memcg - Create a cache for a memory cgroup.
+ * kmem_cache_request_memcg_copy - Create a cache for a memory cgroup.
  * @memcg_params: The memcg params to initialize the cache with.
  * @memcg_name: The name of the memory cgroup.
  *
@@ -313,8 +313,8 @@ EXPORT_SYMBOL(kmem_cache_create);
  * from its parent.
  */
 struct kmem_cache *
-kmem_cache_create_memcg(struct memcg_cache_params *memcg_params,
-			const char *memcg_name)
+kmem_cache_request_memcg_copy(struct memcg_cache_params *memcg_params,
+			      const char *memcg_name)
 {
 	struct mem_cgroup *memcg = memcg_params->memcg;
 	struct kmem_cache *root_cache = memcg_params->root_cache;
@@ -349,7 +349,7 @@ out_unlock:
 	return s;
 }
 
-static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+static int kmem_cache_destroy_memcg_array(struct kmem_cache *s)
 {
 	int rc;
 
@@ -358,7 +358,7 @@ static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		return 0;
 
 	mutex_unlock(&slab_mutex);
-	rc = __kmem_cache_destroy_memcg_children(s);
+	rc = kmem_cache_destroy_memcg_copies(s);
 	mutex_lock(&slab_mutex);
 
 	if (rc == 0)
@@ -366,7 +366,7 @@ static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	return rc;
 }
 #else
-static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+static int kmem_cache_destroy_memcg_array(struct kmem_cache *s)
 {
 	return 0;
 }
@@ -393,7 +393,7 @@ int kmem_cache_destroy(struct kmem_cache *s)
 		goto out_unlock;
 
 	ret = -EBUSY;
-	if (kmem_cache_destroy_memcg_children(s) != 0)
+	if (kmem_cache_destroy_memcg_array(s) != 0)
 		goto out_unlock;
 
 	list_del(&s->list);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
