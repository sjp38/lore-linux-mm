Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 371D16B0085
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 07:46:21 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so7245159pab.0
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 04:46:20 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id gz1si1768961pbd.178.2014.12.12.04.46.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Dec 2014 04:46:19 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] memcg: zap memcg_slab_caches and memcg_slab_mutex
Date: Fri, 12 Dec 2014 15:46:02 +0300
Message-ID: <1418388362-11221-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mem_cgroup->memcg_slab_caches is a list of kmem caches corresponding to
the given cgroup. Currently, it is only used on css free in order to
destroy all caches corresponding to the memory cgroup being freed. The
list is protected by memcg_slab_mutex. The mutex is also used to protect
kmem_cache->memcg_params->memcg_caches arrays and synchronizes
kmem_cache_destroy vs memcg_unregister_all_caches.

However, we can perfectly get on without these two. To destroy all
caches corresponding to a memory cgroup, we can walk over the global
list of kmem caches, slab_caches, and we can do all the synchronization
stuff using the slab_mutex instead of the memcg_slab_mutex. This patch
therefore gets rid of the memcg_slab_caches and memcg_slab_mutex.

Apart from this nice cleanup, it also:

 - assures that rcu_barrier() is called once at max when a root cache is
   destroyed or a memory cgroup is freed, no matter how many caches have
   SLAB_DESTROY_BY_RCU flag set;

 - fixes the race between kmem_cache_destroy and kmem_cache_create that
   exists, because memcg_cleanup_cache_params, which is called from
   kmem_cache_destroy after checking that kmem_cache->refcount=0,
   releases the slab_mutex, which gives kmem_cache_create a chance to
   make an alias to a cache doomed to be destroyed.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
The patch is based on top of v3.18-rc7-mmotm-2014-12-02-15-55 with the
following patches applied:
 memcg: fix possible use-after-free in memcg_kmem_get_cache
 memcg: zap __memcg_{charge,uncharge}_slab
 memcg: zap memcg_name argument of memcg_create_kmem_cache

 include/linux/memcontrol.h |    2 -
 include/linux/slab.h       |    6 +-
 mm/memcontrol.c            |  156 +++++---------------------------------------
 mm/slab_common.c           |  142 +++++++++++++++++++++++++++++-----------
 4 files changed, 120 insertions(+), 186 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 18ccb2988979..fb212e1d700d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -407,8 +407,6 @@ int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
 		      unsigned long nr_pages);
 void memcg_uncharge_kmem(struct mem_cgroup *memcg, unsigned long nr_pages);
 
-int __memcg_cleanup_cache_params(struct kmem_cache *s);
-
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
  * @gfp: the gfp allocation flags.
diff --git a/include/linux/slab.h b/include/linux/slab.h
index eca9ed303a1b..2e3b448cfa2d 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -116,8 +116,8 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *));
 #ifdef CONFIG_MEMCG_KMEM
-struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *,
-					   struct kmem_cache *);
+void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
+void memcg_destroy_kmem_caches(struct mem_cgroup *);
 #endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
@@ -490,7 +490,6 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * Child caches will hold extra metadata needed for its operation. Fields are:
  *
  * @memcg: pointer to the memcg this cache belongs to
- * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
  */
 struct memcg_cache_params {
@@ -502,7 +501,6 @@ struct memcg_cache_params {
 		};
 		struct {
 			struct mem_cgroup *memcg;
-			struct list_head list;
 			struct kmem_cache *root_cache;
 		};
 	};
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e4263e10456c..ccbbd2930bd0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -343,9 +343,6 @@ struct mem_cgroup {
 	struct cg_proto tcp_mem;
 #endif
 #if defined(CONFIG_MEMCG_KMEM)
-	/* analogous to slab_common's slab_caches list, but per-memcg;
-	 * protected by memcg_slab_mutex */
-	struct list_head memcg_slab_caches;
         /* Index in the kmem_cache->memcg_params->memcg_caches array */
 	int kmemcg_id;
 #endif
@@ -2475,25 +2472,6 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
-/*
- * The memcg_slab_mutex is held whenever a per memcg kmem cache is created or
- * destroyed. It protects memcg_caches arrays and memcg_slab_caches lists.
- */
-static DEFINE_MUTEX(memcg_slab_mutex);
-
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
 int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
 		      unsigned long nr_pages)
 {
@@ -2577,10 +2555,7 @@ static int memcg_alloc_cache_id(void)
 	else if (size > MEMCG_CACHES_MAX_SIZE)
 		size = MEMCG_CACHES_MAX_SIZE;
 
-	mutex_lock(&memcg_slab_mutex);
 	err = memcg_update_all_caches(size);
-	mutex_unlock(&memcg_slab_mutex);
-
 	if (err) {
 		ida_simple_remove(&kmem_limited_groups, id);
 		return err;
@@ -2603,120 +2578,20 @@ void memcg_update_array_size(int num)
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
-	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
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
-	struct mem_cgroup *memcg;
-	int id;
-
-	lockdep_assert_held(&memcg_slab_mutex);
-
-	BUG_ON(is_root_cache(cachep));
-
-	root_cache = cachep->memcg_params->root_cache;
-	memcg = cachep->memcg_params->memcg;
-	id = memcg_cache_id(memcg);
-
-	BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
-	root_cache->memcg_params->memcg_caches[id] = NULL;
-
-	list_del(&cachep->memcg_params->list);
-
-	kmem_cache_destroy(cachep);
-}
-
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
-static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
-{
-	struct kmem_cache *cachep;
-	struct memcg_cache_params *params, *tmp;
-
-	if (!memcg_kmem_is_active(memcg))
-		return;
-
-	mutex_lock(&memcg_slab_mutex);
-	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
-		cachep = memcg_params_to_cache(params);
-		memcg_unregister_cache(cachep);
-	}
-	mutex_unlock(&memcg_slab_mutex);
-}
-
-struct memcg_register_cache_work {
+struct memcg_kmem_cache_create_work {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *cachep;
 	struct work_struct work;
 };
 
-static void memcg_register_cache_func(struct work_struct *w)
+static void memcg_kmem_cache_create_func(struct work_struct *w)
 {
-	struct memcg_register_cache_work *cw =
-		container_of(w, struct memcg_register_cache_work, work);
+	struct memcg_kmem_cache_create_work *cw =
+		container_of(w, struct memcg_kmem_cache_create_work, work);
 	struct mem_cgroup *memcg = cw->memcg;
 	struct kmem_cache *cachep = cw->cachep;
 
-	mutex_lock(&memcg_slab_mutex);
-	memcg_register_cache(memcg, cachep);
-	mutex_unlock(&memcg_slab_mutex);
+	memcg_create_kmem_cache(memcg, cachep);
 
 	css_put(&memcg->css);
 	kfree(cw);
@@ -2725,10 +2600,10 @@ static void memcg_register_cache_func(struct work_struct *w)
 /*
  * Enqueue the creation of a per-memcg kmem_cache.
  */
-static void __memcg_schedule_register_cache(struct mem_cgroup *memcg,
-					    struct kmem_cache *cachep)
+static void __memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
+					       struct kmem_cache *cachep)
 {
-	struct memcg_register_cache_work *cw;
+	struct memcg_kmem_cache_create_work *cw;
 
 	cw = kmalloc(sizeof(*cw), GFP_NOWAIT);
 	if (!cw)
@@ -2738,18 +2613,18 @@ static void __memcg_schedule_register_cache(struct mem_cgroup *memcg,
 
 	cw->memcg = memcg;
 	cw->cachep = cachep;
+	INIT_WORK(&cw->work, memcg_kmem_cache_create_func);
 
-	INIT_WORK(&cw->work, memcg_register_cache_func);
 	schedule_work(&cw->work);
 }
 
-static void memcg_schedule_register_cache(struct mem_cgroup *memcg,
-					  struct kmem_cache *cachep)
+static void memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
+					     struct kmem_cache *cachep)
 {
 	/*
 	 * We need to stop accounting when we kmalloc, because if the
 	 * corresponding kmalloc cache is not yet created, the first allocation
-	 * in __memcg_schedule_register_cache will recurse.
+	 * in __memcg_schedule_kmem_cache_create will recurse.
 	 *
 	 * However, it is better to enclose the whole function. Depending on
 	 * the debugging options enabled, INIT_WORK(), for instance, can
@@ -2758,7 +2633,7 @@ static void memcg_schedule_register_cache(struct mem_cgroup *memcg,
 	 * the safest choice is to do it like this, wrapping the whole function.
 	 */
 	current->memcg_kmem_skip_account = 1;
-	__memcg_schedule_register_cache(memcg, cachep);
+	__memcg_schedule_kmem_cache_create(memcg, cachep);
 	current->memcg_kmem_skip_account = 0;
 }
 
@@ -2806,7 +2681,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)
 	 * could happen with the slab_mutex held. So it's better to
 	 * defer everything.
 	 */
-	memcg_schedule_register_cache(memcg, cachep);
+	memcg_schedule_kmem_cache_create(memcg, cachep);
 out:
 	css_put(&memcg->css);
 	return cachep;
@@ -4150,7 +4025,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
-	memcg_unregister_all_caches(memcg);
+	memcg_destroy_kmem_caches(memcg);
 	mem_cgroup_sockets_destroy(memcg);
 }
 #else
@@ -4677,7 +4552,6 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	spin_lock_init(&memcg->event_list_lock);
 #ifdef CONFIG_MEMCG_KMEM
 	memcg->kmemcg_id = -1;
-	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
 #endif
 
 	return &memcg->css;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index b958f27d1833..481cf81eadc3 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -425,6 +425,49 @@ out_unlock:
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
+static int do_kmem_cache_shutdown(struct kmem_cache *s,
+		struct list_head *release, bool *need_rcu_barrier)
+{
+	if (__kmem_cache_shutdown(s) != 0) {
+		printk(KERN_ERR "kmem_cache_destroy %s: "
+		       "Slab cache still has objects\n", s->name);
+		dump_stack();
+		return -EBUSY;
+	}
+
+	if (s->flags & SLAB_DESTROY_BY_RCU)
+		*need_rcu_barrier = true;
+
+#ifdef CONFIG_MEMCG_KMEM
+	if (!is_root_cache(s)) {
+		struct kmem_cache *root_cache = s->memcg_params->root_cache;
+		int memcg_id = memcg_cache_id(s->memcg_params->memcg);
+
+		BUG_ON(root_cache->memcg_params->memcg_caches[memcg_id] != s);
+		root_cache->memcg_params->memcg_caches[memcg_id] = NULL;
+	}
+#endif
+	list_move(&s->list, release);
+	return 0;
+}
+
+static void do_kmem_cache_release(struct list_head *release,
+				  bool need_rcu_barrier)
+{
+	struct kmem_cache *s, *s2;
+
+	if (need_rcu_barrier)
+		rcu_barrier();
+
+	list_for_each_entry_safe(s, s2, release, list) {
+#ifdef SLAB_SUPPORTS_SYSFS
+		sysfs_slab_remove(s);
+#else
+		slab_kmem_cache_release(s);
+#endif
+	}
+}
+
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * memcg_create_kmem_cache - Create a cache for a memory cgroup.
@@ -435,10 +478,11 @@ EXPORT_SYMBOL(kmem_cache_create);
  * requests going from @memcg to @root_cache. The new cache inherits properties
  * from its parent.
  */
-struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
-					   struct kmem_cache *root_cache)
+void memcg_create_kmem_cache(struct mem_cgroup *memcg,
+			     struct kmem_cache *root_cache)
 {
 	static char memcg_name_buf[NAME_MAX + 1]; /* protected by slab_mutex */
+	int memcg_id = memcg_cache_id(memcg);
 	struct kmem_cache *s = NULL;
 	char *cache_name;
 
@@ -447,6 +491,14 @@ struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
 	mutex_lock(&slab_mutex);
 
+	/*
+	 * Since per-memcg caches are created asynchronously on first
+	 * allocation (see memcg_kmem_get_cache()), several threads can try to
+	 * create the same cache, but only one of them may succeed.
+	 */
+	if (cache_from_memcg_idx(root_cache, memcg_id))
+		goto out_unlock;
+
 	cgroup_name(mem_cgroup_css(memcg)->cgroup,
 		    memcg_name_buf, sizeof(memcg_name_buf));
 	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
@@ -458,49 +510,73 @@ struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 				 root_cache->size, root_cache->align,
 				 root_cache->flags, root_cache->ctor,
 				 memcg, root_cache);
+	/*
+	 * If we could not create a memcg cache, do not complain, because
+	 * that's not critical at all as we can always proceed with the root
+	 * cache.
+	 */
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
+	root_cache->memcg_params->memcg_caches[memcg_id] = s;
+
 out_unlock:
 	mutex_unlock(&slab_mutex);
 
 	put_online_mems();
 	put_online_cpus();
-
-	return s;
 }
 
-static int memcg_cleanup_cache_params(struct kmem_cache *s)
+void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 {
-	int rc;
+	LIST_HEAD(release);
+	bool need_rcu_barrier = false;
+	struct kmem_cache *s, *s2;
 
-	if (!s->memcg_params ||
-	    !s->memcg_params->is_root_cache)
-		return 0;
+	get_online_cpus();
+	get_online_mems();
 
-	mutex_unlock(&slab_mutex);
-	rc = __memcg_cleanup_cache_params(s);
 	mutex_lock(&slab_mutex);
+	list_for_each_entry_safe(s, s2, &slab_caches, list) {
+		if (is_root_cache(s) || s->memcg_params->memcg != memcg)
+			continue;
+		/*
+		 * The cgroup is about to be freed and therefore has no charges
+		 * left. Hence, all its caches must be empty by now.
+		 */
+		BUG_ON(do_kmem_cache_shutdown(s, &release, &need_rcu_barrier));
+	}
+	mutex_unlock(&slab_mutex);
 
-	return rc;
-}
-#else
-static int memcg_cleanup_cache_params(struct kmem_cache *s)
-{
-	return 0;
+	put_online_mems();
+	put_online_cpus();
+
+	do_kmem_cache_release(&release, need_rcu_barrier);
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
 void slab_kmem_cache_release(struct kmem_cache *s)
 {
+	memcg_free_cache_params(s);
 	kfree(s->name);
 	kmem_cache_free(kmem_cache, s);
 }
 
 void kmem_cache_destroy(struct kmem_cache *s)
 {
+	int i;
+	LIST_HEAD(release);
+	bool need_rcu_barrier = false;
+	bool busy = false;
+
 	get_online_cpus();
 	get_online_mems();
 
@@ -510,35 +586,23 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->refcount)
 		goto out_unlock;
 
-	if (memcg_cleanup_cache_params(s) != 0)
-		goto out_unlock;
+	for_each_memcg_cache_index(i) {
+		struct kmem_cache *c = cache_from_memcg_idx(s, i);
 
-	if (__kmem_cache_shutdown(s) != 0) {
-		printk(KERN_ERR "kmem_cache_destroy %s: "
-		       "Slab cache still has objects\n", s->name);
-		dump_stack();
-		goto out_unlock;
+		if (c && do_kmem_cache_shutdown(c, &release, &need_rcu_barrier))
+			busy = true;
 	}
 
-	list_del(&s->list);
-
-	mutex_unlock(&slab_mutex);
-	if (s->flags & SLAB_DESTROY_BY_RCU)
-		rcu_barrier();
-
-	memcg_free_cache_params(s);
-#ifdef SLAB_SUPPORTS_SYSFS
-	sysfs_slab_remove(s);
-#else
-	slab_kmem_cache_release(s);
-#endif
-	goto out;
+	if (!busy)
+		do_kmem_cache_shutdown(s, &release, &need_rcu_barrier);
 
 out_unlock:
 	mutex_unlock(&slab_mutex);
-out:
+
 	put_online_mems();
 	put_online_cpus();
+
+	do_kmem_cache_release(&release, need_rcu_barrier);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
