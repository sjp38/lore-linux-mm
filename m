Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8F26B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 11:05:57 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id 10so385252lbg.30
        for <linux-mm@kvack.org>; Tue, 13 May 2014 08:05:56 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ll9si8102156lac.105.2014.05.13.08.05.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 08:05:55 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2] memcg: cleanup kmem cache creation/destruction functions naming
Date: Tue, 13 May 2014 19:05:51 +0400
Message-ID: <1399993551-13298-1-git-send-email-vdavydov@parallels.com>
In-Reply-To: <20140507124533.GF9489@dhcp22.suse.cz>
References: <20140507124533.GF9489@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Current names are rather inconsistent. Let's try to improve them.

Brief change log:

** old name **                          ** new name **

kmem_cache_create_memcg                 memcg_create_kmem_cache
memcg_kmem_create_cache                 memcg_regsiter_cache
memcg_kmem_destroy_cache                memcg_unregister_cache

kmem_cache_destroy_memcg_children       memcg_cleanup_cache_params
mem_cgroup_destroy_all_caches           memcg_unregister_all_caches

create_work                             memcg_register_cache_work
memcg_create_cache_work_func            memcg_register_cache_func
memcg_create_cache_enqueue              memcg_schedule_register_cache

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    2 +-
 include/linux/slab.h       |    2 +-
 mm/memcontrol.c            |   60 +++++++++++++++++++++-----------------------
 mm/slab_common.c           |   12 ++++-----
 4 files changed, 36 insertions(+), 40 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index aa429de275cc..c3a53cbb88eb 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -514,7 +514,7 @@ __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
 
-int __kmem_cache_destroy_memcg_children(struct kmem_cache *s);
+int __memcg_cleanup_cache_params(struct kmem_cache *s);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 86e5b26fbdab..1d9abb7d22a0 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -116,7 +116,7 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *));
 #ifdef CONFIG_MEMCG_KMEM
-struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *,
+struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *,
 					   struct kmem_cache *,
 					   const char *);
 #endif
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f5ea266f4d9a..b12a05049f2a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3127,8 +3127,8 @@ void memcg_free_cache_params(struct kmem_cache *s)
 	kfree(s->memcg_params);
 }
 
-static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
-				    struct kmem_cache *root_cache)
+static void memcg_register_cache(struct mem_cgroup *memcg,
+				 struct kmem_cache *root_cache)
 {
 	static char memcg_name_buf[NAME_MAX + 1]; /* protected by
 						     memcg_slab_mutex */
@@ -3148,7 +3148,7 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 		return;
 
 	cgroup_name(memcg->css.cgroup, memcg_name_buf, NAME_MAX + 1);
-	cachep = kmem_cache_create_memcg(memcg, root_cache, memcg_name_buf);
+	cachep = memcg_create_kmem_cache(memcg, root_cache, memcg_name_buf);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
 	 * that's not critical at all as we can always proceed with the root
@@ -3170,7 +3170,7 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	root_cache->memcg_params->memcg_caches[id] = cachep;
 }
 
-static void memcg_kmem_destroy_cache(struct kmem_cache *cachep)
+static void memcg_unregister_cache(struct kmem_cache *cachep)
 {
 	struct kmem_cache *root_cache;
 	struct mem_cgroup *memcg;
@@ -3223,7 +3223,7 @@ static inline void memcg_resume_kmem_account(void)
 	current->memcg_kmem_skip_account--;
 }
 
-int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+int __memcg_cleanup_cache_params(struct kmem_cache *s)
 {
 	struct kmem_cache *c;
 	int i, failed = 0;
@@ -3234,7 +3234,7 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		if (!c)
 			continue;
 
-		memcg_kmem_destroy_cache(c);
+		memcg_unregister_cache(c);
 
 		if (cache_from_memcg_idx(s, i))
 			failed++;
@@ -3243,7 +3243,7 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	return failed;
 }
 
-static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
+static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 {
 	struct kmem_cache *cachep;
 	struct memcg_cache_params *params, *tmp;
@@ -3256,25 +3256,26 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 		cachep = memcg_params_to_cache(params);
 		kmem_cache_shrink(cachep);
 		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
-			memcg_kmem_destroy_cache(cachep);
+			memcg_unregister_cache(cachep);
 	}
 	mutex_unlock(&memcg_slab_mutex);
 }
 
-struct create_work {
+struct memcg_register_cache_work {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *cachep;
 	struct work_struct work;
 };
 
-static void memcg_create_cache_work_func(struct work_struct *w)
+static void memcg_register_cache_func(struct work_struct *w)
 {
-	struct create_work *cw = container_of(w, struct create_work, work);
+	struct memcg_register_cache_work *cw =
+		container_of(w, struct memcg_register_cache_work, work);
 	struct mem_cgroup *memcg = cw->memcg;
 	struct kmem_cache *cachep = cw->cachep;
 
 	mutex_lock(&memcg_slab_mutex);
-	memcg_kmem_create_cache(memcg, cachep);
+	memcg_register_cache(memcg, cachep);
 	mutex_unlock(&memcg_slab_mutex);
 
 	css_put(&memcg->css);
@@ -3284,12 +3285,12 @@ static void memcg_create_cache_work_func(struct work_struct *w)
 /*
  * Enqueue the creation of a per-memcg kmem_cache.
  */
-static void __memcg_create_cache_enqueue(struct mem_cgroup *memcg,
-					 struct kmem_cache *cachep)
+static void __memcg_schedule_register_cache(struct mem_cgroup *memcg,
+					    struct kmem_cache *cachep)
 {
-	struct create_work *cw;
+	struct memcg_register_cache_work *cw;
 
-	cw = kmalloc(sizeof(struct create_work), GFP_NOWAIT);
+	cw = kmalloc(sizeof(*cw), GFP_NOWAIT);
 	if (cw == NULL) {
 		css_put(&memcg->css);
 		return;
@@ -3298,17 +3299,17 @@ static void __memcg_create_cache_enqueue(struct mem_cgroup *memcg,
 	cw->memcg = memcg;
 	cw->cachep = cachep;
 
-	INIT_WORK(&cw->work, memcg_create_cache_work_func);
+	INIT_WORK(&cw->work, memcg_register_cache_func);
 	schedule_work(&cw->work);
 }
 
-static void memcg_create_cache_enqueue(struct mem_cgroup *memcg,
-				       struct kmem_cache *cachep)
+static void memcg_schedule_register_cache(struct mem_cgroup *memcg,
+					  struct kmem_cache *cachep)
 {
 	/*
 	 * We need to stop accounting when we kmalloc, because if the
 	 * corresponding kmalloc cache is not yet created, the first allocation
-	 * in __memcg_create_cache_enqueue will recurse.
+	 * in __memcg_schedule_register_cache will recurse.
 	 *
 	 * However, it is better to enclose the whole function. Depending on
 	 * the debugging options enabled, INIT_WORK(), for instance, can
@@ -3317,7 +3318,7 @@ static void memcg_create_cache_enqueue(struct mem_cgroup *memcg,
 	 * the safest choice is to do it like this, wrapping the whole function.
 	 */
 	memcg_stop_kmem_account();
-	__memcg_create_cache_enqueue(memcg, cachep);
+	__memcg_schedule_register_cache(memcg, cachep);
 	memcg_resume_kmem_account();
 }
 
@@ -3388,16 +3389,11 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
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
+	 * memcg_create_kmem_cache, this means no further allocation
+	 * could happen with the slab_mutex held. So it's better to
+	 * defer everything.
 	 */
-	memcg_create_cache_enqueue(memcg, cachep);
+	memcg_schedule_register_cache(memcg, cachep);
 	return cachep;
 out:
 	rcu_read_unlock();
@@ -3521,7 +3517,7 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
 }
 #else
-static inline void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
+static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 {
 }
 #endif /* CONFIG_MEMCG_KMEM */
@@ -6399,7 +6395,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	css_for_each_descendant_post(iter, css)
 		mem_cgroup_reparent_charges(mem_cgroup_from_css(iter));
 
-	mem_cgroup_destroy_all_caches(memcg);
+	memcg_unregister_all_caches(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 32175617cb75..48fafb61f35e 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -261,7 +261,7 @@ EXPORT_SYMBOL(kmem_cache_create);
 
 #ifdef CONFIG_MEMCG_KMEM
 /*
- * kmem_cache_create_memcg - Create a cache for a memory cgroup.
+ * memcg_create_kmem_cache - Create a cache for a memory cgroup.
  * @memcg: The memory cgroup the new cache is for.
  * @root_cache: The parent of the new cache.
  * @memcg_name: The name of the memory cgroup (used for naming the new cache).
@@ -270,7 +270,7 @@ EXPORT_SYMBOL(kmem_cache_create);
  * requests going from @memcg to @root_cache. The new cache inherits properties
  * from its parent.
  */
-struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *memcg,
+struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 					   struct kmem_cache *root_cache,
 					   const char *memcg_name)
 {
@@ -305,7 +305,7 @@ out_unlock:
 	return s;
 }
 
-static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+static int memcg_cleanup_cache_params(struct kmem_cache *s)
 {
 	int rc;
 
@@ -314,13 +314,13 @@ static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		return 0;
 
 	mutex_unlock(&slab_mutex);
-	rc = __kmem_cache_destroy_memcg_children(s);
+	rc = __memcg_cleanup_cache_params(s);
 	mutex_lock(&slab_mutex);
 
 	return rc;
 }
 #else
-static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+static int memcg_cleanup_cache_params(struct kmem_cache *s)
 {
 	return 0;
 }
@@ -343,7 +343,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->refcount)
 		goto out_unlock;
 
-	if (kmem_cache_destroy_memcg_children(s) != 0)
+	if (memcg_cleanup_cache_params(s) != 0)
 		goto out_unlock;
 
 	list_del(&s->list);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
