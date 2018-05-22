Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43AA26B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 16:13:46 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id p19-v6so12793990plo.14
        for <linux-mm@kvack.org>; Tue, 22 May 2018 13:13:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1-v6sor6820368pfo.48.2018.05.22.13.13.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 May 2018 13:13:44 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v2] mm: fix race between kmem_cache destroy, create and deactivate
Date: Tue, 22 May 2018 13:13:36 -0700
Message-Id: <20180522201336.196994-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

The memcg kmem cache creation and deactivation (SLUB only) is
asynchronous. If a root kmem cache is destroyed whose memcg cache is in
the process of creation or deactivation, the kernel may crash.

Example of one such crash:
	general protection fault: 0000 [#1] SMP PTI
	CPU: 1 PID: 1721 Comm: kworker/14:1 Not tainted 4.17.0-smp
	...
	Workqueue: memcg_kmem_cache kmemcg_deactivate_workfn
	RIP: 0010:has_cpu_slab
	...
	Call Trace:
	? on_each_cpu_cond
	__kmem_cache_shrink
	kmemcg_cache_deact_after_rcu
	kmemcg_deactivate_workfn
	process_one_work
	worker_thread
	kthread
	ret_from_fork+0x35/0x40

This issue is due to the lack of real reference counting for the root
kmem_caches. Currently kmem_cache does have a field named refcount which
has been used for multiple purposes i.e. shared count, reference count
and noshare flag. Due to its conflated nature, it can not be used for
reference counting by other subsystems.

This patch decoupled the reference counting from shared count and
noshare flag. The new field 'shared_count' represents the shared count
and noshare flag while 'refcount' is converted into a real reference
counter.

The reference counting is only implemented for root kmem_caches for
simplicity. The reference of a root kmem_cache is elevated on sharing or
while its memcg kmem_cache creation or deactivation request is in the
fly and thus it is made sure that the root kmem_cache is not destroyed
in the middle. As the reference of kmem_cache is elevated on sharing,
the 'shared_count' does not need any locking protection as at worst it
can be out-dated for a small window which is tolerable.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v1:
- Added more documentation to the code
- Renamed fields to be more readable

 include/linux/slab.h     |   2 +
 include/linux/slab_def.h |   5 +-
 include/linux/slub_def.h |   3 +-
 mm/memcontrol.c          |   7 +++
 mm/slab.c                |   4 +-
 mm/slab.h                |   5 +-
 mm/slab_common.c         | 122 ++++++++++++++++++++++++++++++++-------
 mm/slub.c                |  14 +++--
 8 files changed, 130 insertions(+), 32 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9ebe659bd4a5..4c28f2483a22 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -674,6 +674,8 @@ struct memcg_cache_params {
 };
 
 int memcg_update_all_caches(int num_memcgs);
+bool kmem_cache_tryget(struct kmem_cache *s);
+void kmem_cache_put(struct kmem_cache *s);
 
 /**
  * kmalloc_array - allocate memory for an array.
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index d9228e4d0320..a3aa2c7c1fcd 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -41,7 +41,10 @@ struct kmem_cache {
 /* 4) cache creation/removal */
 	const char *name;
 	struct list_head list;
-	int refcount;
+	/* Refcount for root kmem caches */
+	refcount_t refcount;
+	/* Number of root kmem caches sharing this cache */
+	int shared_count;
 	int object_size;
 	int align;
 
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 3773e26c08c1..a2d53cd28bb6 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -97,7 +97,8 @@ struct kmem_cache {
 	struct kmem_cache_order_objects max;
 	struct kmem_cache_order_objects min;
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
-	int refcount;		/* Refcount for slab cache destroy */
+	refcount_t refcount;	/* Refcount for root kmem cache */
+	int shared_count;	/* Number of kmem caches sharing this cache */
 	void (*ctor)(void *);
 	unsigned int inuse;		/* Offset to metadata */
 	unsigned int align;		/* Alignment */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bdb8028c806c..ab5673dbfc4e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2185,6 +2185,7 @@ static void memcg_kmem_cache_create_func(struct work_struct *w)
 	memcg_create_kmem_cache(memcg, cachep);
 
 	css_put(&memcg->css);
+	kmem_cache_put(cachep);
 	kfree(cw);
 }
 
@@ -2200,6 +2201,12 @@ static void __memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
 	if (!cw)
 		return;
 
+	/* Make sure root kmem cache does not get destroyed in the middle */
+	if (!kmem_cache_tryget(cachep)) {
+		kfree(cw);
+		return;
+	}
+
 	css_get(&memcg->css);
 
 	cw->memcg = memcg;
diff --git a/mm/slab.c b/mm/slab.c
index c1fe8099b3cd..7e494b83bcef 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1883,8 +1883,8 @@ __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 	struct kmem_cache *cachep;
 
 	cachep = find_mergeable(size, align, flags, name, ctor);
-	if (cachep) {
-		cachep->refcount++;
+	if (cachep && kmem_cache_tryget(cachep)) {
+		cachep->shared_count++;
 
 		/*
 		 * Adjust the object sizes so that we clear
diff --git a/mm/slab.h b/mm/slab.h
index 68bdf498da3b..2a940984b305 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -25,7 +25,8 @@ struct kmem_cache {
 	unsigned int useroffset;/* Usercopy region offset */
 	unsigned int usersize;	/* Usercopy region size */
 	const char *name;	/* Slab name for sysfs */
-	int refcount;		/* Use counter */
+	refcount_t refcount;	/* Refcount for root kmem cache */
+	int shared_count;	/* Number of kmem caches sharing this cache */
 	void (*ctor)(void *);	/* Called on object slot creation */
 	struct list_head list;	/* List of all slab caches on the system */
 };
@@ -295,7 +296,7 @@ extern void slab_init_memcg_params(struct kmem_cache *);
 extern void memcg_link_cache(struct kmem_cache *s);
 extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 				void (*deact_fn)(struct kmem_cache *));
-
+extern void kmem_cache_put_locked(struct kmem_cache *s);
 #else /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 /* If !memcg, all caches are root. */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index b0dd9db1eb2f..ebe28ad516e3 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -306,7 +306,7 @@ int slab_unmergeable(struct kmem_cache *s)
 	/*
 	 * We may have set a slab to be unmergeable during bootstrap.
 	 */
-	if (s->refcount < 0)
+	if (s->shared_count < 0)
 		return 1;
 
 	return 0;
@@ -391,7 +391,8 @@ static struct kmem_cache *create_cache(const char *name,
 	if (err)
 		goto out_free_cache;
 
-	s->refcount = 1;
+	s->shared_count = 1;
+	refcount_set(&s->refcount, 1);
 	list_add(&s->list, &slab_caches);
 	memcg_link_cache(s);
 out:
@@ -611,6 +612,18 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	if (memcg->kmem_state != KMEM_ONLINE)
 		goto out_unlock;
 
+	/*
+	 * The root cache has been requested to be destroyed while its memcg
+	 * cache was in creation queue.
+	 *
+	 * The shared_count can be out-dated or can be incremented after return.
+	 * No big worries, at worst the creation of memcg kmem_cache is delayed.
+	 * The next allocation will again trigger the memcg kmem_cache creation
+	 * request.
+	 */
+	if (!root_cache->shared_count)
+		goto out_unlock;
+
 	idx = memcg_cache_id(memcg);
 	arr = rcu_dereference_protected(root_cache->memcg_params.memcg_caches,
 					lockdep_is_held(&slab_mutex));
@@ -663,6 +676,8 @@ static void kmemcg_deactivate_workfn(struct work_struct *work)
 {
 	struct kmem_cache *s = container_of(work, struct kmem_cache,
 					    memcg_params.deact_work);
+	struct kmem_cache *root = s->memcg_params.root_cache;
+	struct mem_cgroup *memcg = s->memcg_params.memcg;
 
 	get_online_cpus();
 	get_online_mems();
@@ -677,7 +692,8 @@ static void kmemcg_deactivate_workfn(struct work_struct *work)
 	put_online_cpus();
 
 	/* done, put the ref from slab_deactivate_memcg_cache_rcu_sched() */
-	css_put(&s->memcg_params.memcg->css);
+	css_put(&memcg->css);
+	kmem_cache_put(root);
 }
 
 static void kmemcg_deactivate_rcufn(struct rcu_head *head)
@@ -712,6 +728,10 @@ void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 	    WARN_ON_ONCE(s->memcg_params.deact_fn))
 		return;
 
+	/* Make sure root kmem_cache does not get destroyed in the middle */
+	if (!kmem_cache_tryget(s->memcg_params.root_cache))
+		return;
+
 	/* pin memcg so that @s doesn't get destroyed in the middle */
 	css_get(&s->memcg_params.memcg->css);
 
@@ -838,21 +858,17 @@ void slab_kmem_cache_release(struct kmem_cache *s)
 	kmem_cache_free(kmem_cache, s);
 }
 
-void kmem_cache_destroy(struct kmem_cache *s)
+static void __kmem_cache_destroy(struct kmem_cache *s, bool lock)
 {
 	int err;
 
-	if (unlikely(!s))
-		return;
-
-	get_online_cpus();
-	get_online_mems();
-
-	mutex_lock(&slab_mutex);
+	if (lock) {
+		get_online_cpus();
+		get_online_mems();
+		mutex_lock(&slab_mutex);
+	}
 
-	s->refcount--;
-	if (s->refcount)
-		goto out_unlock;
+	VM_BUG_ON(s->shared_count);
 
 	err = shutdown_memcg_caches(s);
 	if (!err)
@@ -863,11 +879,75 @@ void kmem_cache_destroy(struct kmem_cache *s)
 		       s->name);
 		dump_stack();
 	}
-out_unlock:
-	mutex_unlock(&slab_mutex);
 
-	put_online_mems();
-	put_online_cpus();
+	if (lock) {
+		mutex_unlock(&slab_mutex);
+		put_online_mems();
+		put_online_cpus();
+	}
+}
+
+/*
+ * kmem_cache_tryget - Try to get a reference on a kmem_cache
+ * @s: target kmem_cache
+ *
+ * Obtain a reference on a kmem_cache unless it already has reached zero and is
+ * being released. The caller needs to ensure that kmem_cache is accessible.
+ * Currently only root kmem_cache supports reference counting.
+ */
+bool kmem_cache_tryget(struct kmem_cache *s)
+{
+	if (is_root_cache(s))
+		return refcount_inc_not_zero(&s->refcount);
+	return false;
+}
+
+/*
+ * kmem_cache_put - Put a reference on a kmem_cache
+ * @s: target kmem_cache
+ *
+ * Put a reference obtained via kmem_cache_tryget(). This function can not be
+ * called within slab_mutex as it can trigger a destruction of a kmem_cache
+ * which requires slab_mutex.
+ */
+void kmem_cache_put(struct kmem_cache *s)
+{
+	if (is_root_cache(s) &&
+	    refcount_dec_and_test(&s->refcount))
+		__kmem_cache_destroy(s, true);
+}
+
+/*
+ * kmem_cache_put_locked - Put a reference on a kmem_cache while holding
+ * slab_mutex
+ * @s: target kmem_cache
+ *
+ * Put a reference obtained via kmem_cache_tryget(). Use this function instead
+ * of kmem_cache_put if the caller has already acquired slab_mutex.
+ *
+ * At the moment this function is not exposed externally and is used by SLUB.
+ */
+void kmem_cache_put_locked(struct kmem_cache *s)
+{
+	if (is_root_cache(s) &&
+	    refcount_dec_and_test(&s->refcount))
+		__kmem_cache_destroy(s, false);
+}
+
+void kmem_cache_destroy(struct kmem_cache *s)
+{
+	if (unlikely(!s))
+		return;
+
+	/*
+	 * It is safe to decrement shared_count without any lock. In
+	 * __kmem_cache_alias the kmem_cache's refcount is elevated before
+	 * incrementing shared_count and below the reference is dropped after
+	 * decrementing shared_count. At worst shared_count can be outdated for
+	 * a small window but that is tolerable.
+	 */
+	s->shared_count--;
+	kmem_cache_put(s);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
@@ -919,7 +999,8 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name,
 		panic("Creation of kmalloc slab %s size=%u failed. Reason %d\n",
 					name, size, err);
 
-	s->refcount = -1;	/* Exempt from merging for now */
+	s->shared_count = -1;	/* Exempt from merging for now */
+	refcount_set(&s->refcount, 1);
 }
 
 struct kmem_cache *__init create_kmalloc_cache(const char *name,
@@ -934,7 +1015,8 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name,
 	create_boot_cache(s, name, size, flags, useroffset, usersize);
 	list_add(&s->list, &slab_caches);
 	memcg_link_cache(s);
-	s->refcount = 1;
+	s->shared_count = 1;
+	refcount_set(&s->refcount, 1);
 	return s;
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index 48f75872c356..41203710de70 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4270,8 +4270,8 @@ __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 	struct kmem_cache *s, *c;
 
 	s = find_mergeable(size, align, flags, name, ctor);
-	if (s) {
-		s->refcount++;
+	if (s && kmem_cache_tryget(s)) {
+		s->shared_count++;
 
 		/*
 		 * Adjust the object sizes so that we clear
@@ -4286,7 +4286,8 @@ __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		}
 
 		if (sysfs_slab_alias(s, name)) {
-			s->refcount--;
+			s->shared_count--;
+			kmem_cache_put_locked(s);
 			s = NULL;
 		}
 	}
@@ -5009,7 +5010,8 @@ SLAB_ATTR_RO(ctor);
 
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->refcount < 0 ? 0 : s->refcount - 1);
+	return sprintf(buf, "%d\n",
+		       s->shared_count < 0 ? 0 : s->shared_count - 1);
 }
 SLAB_ATTR_RO(aliases);
 
@@ -5162,7 +5164,7 @@ static ssize_t trace_store(struct kmem_cache *s, const char *buf,
 	 * as well as cause other issues like converting a mergeable
 	 * cache into an umergeable one.
 	 */
-	if (s->refcount > 1)
+	if (s->shared_count > 1)
 		return -EINVAL;
 
 	s->flags &= ~SLAB_TRACE;
@@ -5280,7 +5282,7 @@ static ssize_t failslab_show(struct kmem_cache *s, char *buf)
 static ssize_t failslab_store(struct kmem_cache *s, const char *buf,
 							size_t length)
 {
-	if (s->refcount > 1)
+	if (s->shared_count > 1)
 		return -EINVAL;
 
 	s->flags &= ~SLAB_FAILSLAB;
-- 
2.17.0.441.gb46fe60e1d-goog
