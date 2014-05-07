Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7AB6B0036
	for <linux-mm@kvack.org>; Wed,  7 May 2014 04:15:35 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id 10so832526lbg.18
        for <linux-mm@kvack.org>; Wed, 07 May 2014 01:15:34 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id j3si6406513lbp.90.2014.05.07.01.15.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 May 2014 01:15:33 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 2/2] memcg: cleanup kmem cache creation/destruction functions naming
Date: Wed, 7 May 2014 12:15:30 +0400
Message-ID: <c3bef5d3667668f89a4acabda64eb79d730037ec.1399450112.git.vdavydov@parallels.com>
In-Reply-To: <a4aa62026c10fc709e8bf13542b29cf771381394.1399450112.git.vdavydov@parallels.com>
References: <a4aa62026c10fc709e8bf13542b29cf771381394.1399450112.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Current names are rather inconsistent. Let's try to improve them.

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
Initially this was a part of "memcg/kmem: cleanup naming and callflows"
patch set (https://lkml.org/lkml/2014/4/27/345).

 include/linux/memcontrol.h |    2 +-
 include/linux/slab.h       |    6 ++---
 mm/memcontrol.c            |   58 +++++++++++++++++++++-----------------------
 mm/slab_common.c           |   29 +++++++++++-----------
 4 files changed, 45 insertions(+), 50 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7b639ab48aa8..0958f0361af0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -514,7 +514,7 @@ __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
 
-int __kmem_cache_destroy_memcg_children(struct kmem_cache *s);
+int __kmem_cache_destroy_memcg_copies(struct kmem_cache *s);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 86e5b26fbdab..e08e369d42ac 100644
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
 #endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f401f227a099..52a31f6876ce 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3138,8 +3138,8 @@ void memcg_free_cache_params(struct kmem_cache *s)
 	kfree(s->memcg_params);
 }
 
-static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
-				    struct kmem_cache *root_cache)
+static void memcg_copy_kmem_cache(struct mem_cgroup *memcg,
+				  struct kmem_cache *root_cache)
 {
 	static char *memcg_name_buf;
 	struct kmem_cache *cachep;
@@ -3164,7 +3164,7 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	}
 
 	cgroup_name(memcg->css.cgroup, memcg_name_buf, NAME_MAX + 1);
-	cachep = kmem_cache_create_memcg(memcg, root_cache, memcg_name_buf);
+	cachep = kmem_cache_request_memcg_copy(root_cache, memcg, memcg_name_buf);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
 	 * that's not critical at all as we can always proceed with the root
@@ -3186,7 +3186,7 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	root_cache->memcg_params->memcg_caches[id] = cachep;
 }
 
-static void memcg_kmem_destroy_cache(struct kmem_cache *cachep)
+static void memcg_destroy_kmem_cache_copy(struct kmem_cache *cachep)
 {
 	struct kmem_cache *root_cache;
 	struct mem_cgroup *memcg;
@@ -3239,7 +3239,7 @@ static inline void memcg_resume_kmem_account(void)
 	current->memcg_kmem_skip_account--;
 }
 
-int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+int __kmem_cache_destroy_memcg_copies(struct kmem_cache *s)
 {
 	struct kmem_cache *c;
 	int i, failed = 0;
@@ -3250,7 +3250,7 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		if (!c)
 			continue;
 
-		memcg_kmem_destroy_cache(c);
+		memcg_destroy_kmem_cache_copy(c);
 
 		if (cache_from_memcg_idx(s, i))
 			failed++;
@@ -3259,7 +3259,7 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	return failed;
 }
 
-static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
+static void memcg_destroy_kmem_cache_copies(struct mem_cgroup *memcg)
 {
 	struct kmem_cache *cachep;
 	struct memcg_cache_params *params, *tmp;
@@ -3272,25 +3272,26 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
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
 
 	mutex_lock(&memcg_slab_mutex);
-	memcg_kmem_create_cache(memcg, cachep);
+	memcg_copy_kmem_cache(memcg, cachep);
 	mutex_unlock(&memcg_slab_mutex);
 
 	css_put(&memcg->css);
@@ -3300,12 +3301,12 @@ static void memcg_create_cache_work_func(struct work_struct *w)
 /*
  * Enqueue the creation of a per-memcg kmem_cache.
  */
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
@@ -3314,17 +3315,17 @@ static void __memcg_create_cache_enqueue(struct mem_cgroup *memcg,
 	cw->memcg = memcg;
 	cw->cachep = cachep;
 
-	INIT_WORK(&cw->work, memcg_create_cache_work_func);
+	INIT_WORK(&cw->work, memcg_kmem_cache_copy_work_func);
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
@@ -3333,7 +3334,7 @@ static void memcg_create_cache_enqueue(struct mem_cgroup *memcg,
 	 * the safest choice is to do it like this, wrapping the whole function.
 	 */
 	memcg_stop_kmem_account();
-	__memcg_create_cache_enqueue(memcg, cachep);
+	__memcg_schedule_kmem_cache_copy(memcg, cachep);
 	memcg_resume_kmem_account();
 }
 
@@ -3404,16 +3405,11 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
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
@@ -3537,7 +3533,7 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
 }
 #else
-static inline void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
+static inline void memcg_destroy_kmem_cache_copies(struct mem_cgroup *memcg)
 {
 }
 #endif /* CONFIG_MEMCG_KMEM */
@@ -6415,7 +6411,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	css_for_each_descendant_post(iter, css)
 		mem_cgroup_reparent_charges(mem_cgroup_from_css(iter));
 
-	mem_cgroup_destroy_all_caches(memcg);
+	memcg_destroy_kmem_cache_copies(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 32175617cb75..802466c7e736 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -261,18 +261,18 @@ EXPORT_SYMBOL(kmem_cache_create);
 
 #ifdef CONFIG_MEMCG_KMEM
 /*
- * kmem_cache_create_memcg - Create a cache for a memory cgroup.
+ * kmem_cache_request_memcg_copy - Create copy of a cache for a memcg.
+ * @cachep: The cache to make a copy of.
  * @memcg: The memory cgroup the new cache is for.
- * @root_cache: The parent of the new cache.
  * @memcg_name: The name of the memory cgroup (used for naming the new cache).
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
 	char *cache_name;
@@ -282,15 +282,14 @@ struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *memcg,
 
 	mutex_lock(&slab_mutex);
 
-	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
+	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", cachep->name,
 			       memcg_cache_id(memcg), memcg_name);
 	if (!cache_name)
 		goto out_unlock;
 
-	s = do_kmem_cache_create(cache_name, root_cache->object_size,
-				 root_cache->size, root_cache->align,
-				 root_cache->flags, root_cache->ctor,
-				 memcg, root_cache);
+	s = do_kmem_cache_create(cache_name, cachep->object_size, cachep->size,
+				 cachep->align, cachep->flags, cachep->ctor,
+				 memcg, cachep);
 	if (IS_ERR(s)) {
 		kfree(cache_name);
 		s = NULL;
@@ -305,7 +304,7 @@ out_unlock:
 	return s;
 }
 
-static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+static int kmem_cache_destroy_memcg_copies(struct kmem_cache *s)
 {
 	int rc;
 
@@ -314,13 +313,13 @@ static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
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
@@ -343,7 +342,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->refcount)
 		goto out_unlock;
 
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
