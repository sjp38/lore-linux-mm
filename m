Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9A86B00F6
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 16:00:16 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id v10so12163511pde.36
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 13:00:16 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id q8si730265pds.51.2014.11.03.13.00.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 13:00:14 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 4/8] memcg: zap memcg_{un}register_cache
Date: Mon, 3 Nov 2014 23:59:42 +0300
Message-ID: <1f90d7989c062dbe8016e8409540548cee196bb7.1415046910.git.vdavydov@parallels.com>
In-Reply-To: <cover.1415046910.git.vdavydov@parallels.com>
References: <cover.1415046910.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

No need in these helpers any more. We can do the stuff in
memcg_create_kmem_cache and kmem_cache_destroy.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    2 -
 include/linux/slab.h       |    3 +-
 mm/memcontrol.c            |  115 ++++++--------------------------------------
 mm/slab_common.c           |   60 ++++++++++++++++++-----
 4 files changed, 64 insertions(+), 116 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 31b495ff5f3a..617652712da8 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -416,8 +416,6 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
-int __memcg_cleanup_cache_params(struct kmem_cache *s);
-
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
  * @gfp: the gfp allocation flags.
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 293c04df7953..411b25f95ed8 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -116,8 +116,7 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *));
 #ifdef CONFIG_MEMCG_KMEM
-struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *,
-					   struct kmem_cache *);
+void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
 #endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 78d12076b01d..923fe4c29e92 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2484,12 +2484,6 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
-/*
- * The memcg_slab_mutex is held whenever a per memcg kmem cache is created or
- * destroyed. It protects memcg_caches arrays.
- */
-static DEFINE_MUTEX(memcg_slab_mutex);
-
 static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
 			     unsigned long nr_pages)
 {
@@ -2574,10 +2568,7 @@ static int memcg_alloc_cache_id(void)
 	else if (size > MEMCG_CACHES_MAX_SIZE)
 		size = MEMCG_CACHES_MAX_SIZE;
 
-	mutex_lock(&memcg_slab_mutex);
 	err = memcg_update_all_caches(size);
-	mutex_unlock(&memcg_slab_mutex);
-
 	if (err) {
 		ida_simple_remove(&kmem_limited_groups, id);
 		return err;
@@ -2600,62 +2591,6 @@ void memcg_update_array_size(int num)
 	memcg_limited_groups_array_size = num;
 }
 
-static void memcg_register_cache(struct mem_cgroup *memcg,
-				 struct kmem_cache *root_cache)
-{
-	struct kmem_cache *cachep;
-	int id;
-
-	lockdep_assert_held(&memcg_slab_mutex);
-
-	id = memcg_cache_id(memcg);
-
-	/*
-	 * Since per-memcg caches are created asynchronously on first
-	 * allocation (see memcg_kmem_get_cache()), several threads can try to
-	 * create the same cache, but only one of them may succeed.
-	 */
-	if (cache_from_memcg_idx(root_cache, id))
-		return;
-
-	cachep = memcg_create_kmem_cache(memcg, root_cache);
-	/*
-	 * If we could not create a memcg cache, do not complain, because
-	 * that's not critical at all as we can always proceed with the root
-	 * cache.
-	 */
-	if (!cachep)
-		return;
-
-	/*
-	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
-	 * barrier here to ensure nobody will see the kmem_cache partially
-	 * initialized.
-	 */
-	smp_wmb();
-
-	BUG_ON(root_cache->memcg_params->memcg_caches[id]);
-	root_cache->memcg_params->memcg_caches[id] = cachep;
-}
-
-static void memcg_unregister_cache(struct kmem_cache *cachep)
-{
-	struct kmem_cache *root_cache;
-	int id;
-
-	lockdep_assert_held(&memcg_slab_mutex);
-
-	BUG_ON(is_root_cache(cachep));
-
-	root_cache = cachep->memcg_params->root_cache;
-	id = cachep->memcg_params->id;
-
-	BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
-	root_cache->memcg_params->memcg_caches[id] = NULL;
-
-	kmem_cache_destroy(cachep);
-}
-
 /*
  * During the creation a new cache, we need to disable our accounting mechanism
  * altogether. This is true even if we are not creating, but rather just
@@ -2687,42 +2622,20 @@ static inline void memcg_resume_kmem_account(void)
 	current->memcg_kmem_skip_account--;
 }
 
-int __memcg_cleanup_cache_params(struct kmem_cache *s)
-{
-	struct kmem_cache *c;
-	int i, failed = 0;
-
-	mutex_lock(&memcg_slab_mutex);
-	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg_idx(s, i);
-		if (!c)
-			continue;
-
-		memcg_unregister_cache(c);
-
-		if (cache_from_memcg_idx(s, i))
-			failed++;
-	}
-	mutex_unlock(&memcg_slab_mutex);
-	return failed;
-}
-
-struct memcg_register_cache_work {
+struct memcg_cache_create_work {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *cachep;
 	struct work_struct work;
 };
 
-static void memcg_register_cache_func(struct work_struct *w)
+static void memcg_cache_create_work_fn(struct work_struct *w)
 {
-	struct memcg_register_cache_work *cw =
-		container_of(w, struct memcg_register_cache_work, work);
+	struct memcg_cache_create_work *cw = container_of(w,
+			struct memcg_cache_create_work, work);
 	struct mem_cgroup *memcg = cw->memcg;
 	struct kmem_cache *cachep = cw->cachep;
 
-	mutex_lock(&memcg_slab_mutex);
-	memcg_register_cache(memcg, cachep);
-	mutex_unlock(&memcg_slab_mutex);
+	memcg_create_kmem_cache(memcg, cachep);
 
 	css_put(&memcg->css);
 	kfree(cw);
@@ -2731,10 +2644,10 @@ static void memcg_register_cache_func(struct work_struct *w)
 /*
  * Enqueue the creation of a per-memcg kmem_cache.
  */
-static void __memcg_schedule_register_cache(struct mem_cgroup *memcg,
-					    struct kmem_cache *cachep)
+static void __memcg_schedule_cache_create(struct mem_cgroup *memcg,
+					  struct kmem_cache *cachep)
 {
-	struct memcg_register_cache_work *cw;
+	struct memcg_cache_create_work *cw;
 
 	cw = kmalloc(sizeof(*cw), GFP_NOWAIT);
 	if (cw == NULL) {
@@ -2745,17 +2658,17 @@ static void __memcg_schedule_register_cache(struct mem_cgroup *memcg,
 	cw->memcg = memcg;
 	cw->cachep = cachep;
 
-	INIT_WORK(&cw->work, memcg_register_cache_func);
+	INIT_WORK(&cw->work, memcg_cache_create_work_fn);
 	schedule_work(&cw->work);
 }
 
-static void memcg_schedule_register_cache(struct mem_cgroup *memcg,
-					  struct kmem_cache *cachep)
+static void memcg_schedule_cache_create(struct mem_cgroup *memcg,
+					struct kmem_cache *cachep)
 {
 	/*
 	 * We need to stop accounting when we kmalloc, because if the
 	 * corresponding kmalloc cache is not yet created, the first allocation
-	 * in __memcg_schedule_register_cache will recurse.
+	 * in __memcg_schedule_cache_create will recurse.
 	 *
 	 * However, it is better to enclose the whole function. Depending on
 	 * the debugging options enabled, INIT_WORK(), for instance, can
@@ -2764,7 +2677,7 @@ static void memcg_schedule_register_cache(struct mem_cgroup *memcg,
 	 * the safest choice is to do it like this, wrapping the whole function.
 	 */
 	memcg_stop_kmem_account();
-	__memcg_schedule_register_cache(memcg, cachep);
+	__memcg_schedule_cache_create(memcg, cachep);
 	memcg_resume_kmem_account();
 }
 
@@ -2822,7 +2735,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	 * could happen with the slab_mutex held. So it's better to
 	 * defer everything.
 	 */
-	memcg_schedule_register_cache(memcg, cachep);
+	memcg_schedule_cache_create(memcg, cachep);
 	return cachep;
 out:
 	rcu_read_unlock();
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 974d77db1b39..70a2ba4b4600 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -431,10 +431,11 @@ EXPORT_SYMBOL(kmem_cache_create);
  * requests going from @memcg to @root_cache. The new cache inherits properties
  * from its parent.
  */
-struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
-					   struct kmem_cache *root_cache)
+void memcg_create_kmem_cache(struct mem_cgroup *memcg,
+			     struct kmem_cache *root_cache)
 {
-	struct kmem_cache *s = NULL;
+	int id = memcg_cache_id(memcg);
+	struct kmem_cache *s;
 	char *cache_name;
 
 	get_online_cpus();
@@ -442,8 +443,15 @@ struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
 	mutex_lock(&slab_mutex);
 
-	cache_name = kasprintf(GFP_KERNEL, "%s(%d)", root_cache->name,
-			       memcg_cache_id(memcg));
+	/*
+	 * Since per-memcg caches are created asynchronously on first
+	 * allocation (see memcg_kmem_get_cache()), several threads can try to
+	 * create the same cache, but only one of them may succeed.
+	 */
+	if (cache_from_memcg_idx(root_cache, id))
+		goto out_unlock;
+
+	cache_name = kasprintf(GFP_KERNEL, "%s(%d)", root_cache->name, id);
 	if (!cache_name)
 		goto out_unlock;
 
@@ -453,31 +461,52 @@ struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 				 memcg, root_cache);
 	if (IS_ERR(s)) {
 		kfree(cache_name);
-		s = NULL;
+		goto out_unlock;
 	}
 
+	/*
+	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
+	 * barrier here to ensure nobody will see the kmem_cache partially
+	 * initialized.
+	 */
+	smp_wmb();
+
+	BUG_ON(root_cache->memcg_params->memcg_caches[id]);
+	root_cache->memcg_params->memcg_caches[id] = s;
+
 out_unlock:
 	mutex_unlock(&slab_mutex);
 
 	put_online_mems();
 	put_online_cpus();
-
-	return s;
 }
 
 static int memcg_cleanup_cache_params(struct kmem_cache *s)
 {
-	int rc;
+	int i;
+	int ret = 0;
 
 	if (!s->memcg_params ||
 	    !s->memcg_params->is_root_cache)
 		return 0;
 
 	mutex_unlock(&slab_mutex);
-	rc = __memcg_cleanup_cache_params(s);
+	for_each_memcg_cache_index(i) {
+		struct kmem_cache *c;
+
+		c = cache_from_memcg_idx(s, i);
+		if (!c)
+			continue;
+
+		kmem_cache_destroy(s);
+
+		/* failed to destroy? */
+		if (cache_from_memcg_idx(s, i))
+			ret = -EBUSY;
+	}
 	mutex_lock(&slab_mutex);
 
-	return rc;
+	return ret;
 }
 #else
 static int memcg_cleanup_cache_params(struct kmem_cache *s)
@@ -513,6 +542,15 @@ void kmem_cache_destroy(struct kmem_cache *s)
 		goto out_unlock;
 	}
 
+#ifdef CONFIG_MEMCG_KMEM
+	if (!is_root_cache(s)) {
+		int id = s->memcg_params->id;
+		struct kmem_cache *root_cache = s->memcg_params->root_cache;
+
+		BUG_ON(root_cache->memcg_params->memcg_caches[id] != s);
+		root_cache->memcg_params->memcg_caches[id] = NULL;
+	}
+#endif
 	list_del(&s->list);
 
 	mutex_unlock(&slab_mutex);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
