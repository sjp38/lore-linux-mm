Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C74EC6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 13:41:52 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g92-v6so10400464plg.6
        for <linux-mm@kvack.org>; Mon, 21 May 2018 10:41:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s14-v6sor5928642pfh.17.2018.05.21.10.41.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 10:41:51 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm: fix race between kmem_cache destroy, create and deactivate
Date: Mon, 21 May 2018 10:41:16 -0700
Message-Id: <20180521174116.171846-1-shakeelb@google.com>
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

This issue is due to the lack of reference counting for the root
kmem_caches. There exist a refcount in kmem_cache but it is actually a
count of aliases i.e. number of kmem_caches merged together.

This patch make alias count explicit and adds reference counting to the
root kmem_caches. The reference of a root kmem cache is elevated on
merge and while its memcg kmem_cache is in the process of creation or
deactivation.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/slab.h     |  2 +
 include/linux/slab_def.h |  3 +-
 include/linux/slub_def.h |  3 +-
 mm/memcontrol.c          |  7 ++++
 mm/slab.c                |  4 +-
 mm/slab.h                |  5 ++-
 mm/slab_common.c         | 84 ++++++++++++++++++++++++++++++----------
 mm/slub.c                | 14 ++++---
 8 files changed, 90 insertions(+), 32 deletions(-)

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
index d9228e4d0320..4bb22c89a740 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -41,7 +41,8 @@ struct kmem_cache {
 /* 4) cache creation/removal */
 	const char *name;
 	struct list_head list;
-	int refcount;
+	refcount_t refcount;
+	int alias_count;
 	int object_size;
 	int align;
 
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 3773e26c08c1..532d4b6f83ed 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -97,7 +97,8 @@ struct kmem_cache {
 	struct kmem_cache_order_objects max;
 	struct kmem_cache_order_objects min;
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
-	int refcount;		/* Refcount for slab cache destroy */
+	refcount_t refcount;	/* Refcount for slab cache destroy */
+	int alias_count;	/* Number of root kmem caches merged */
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
index c1fe8099b3cd..080732f5f20d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1883,8 +1883,8 @@ __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 	struct kmem_cache *cachep;
 
 	cachep = find_mergeable(size, align, flags, name, ctor);
-	if (cachep) {
-		cachep->refcount++;
+	if (cachep && kmem_cache_tryget(cachep)) {
+		cachep->alias_count++;
 
 		/*
 		 * Adjust the object sizes so that we clear
diff --git a/mm/slab.h b/mm/slab.h
index 68bdf498da3b..25962ab75ec1 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -25,7 +25,8 @@ struct kmem_cache {
 	unsigned int useroffset;/* Usercopy region offset */
 	unsigned int usersize;	/* Usercopy region size */
 	const char *name;	/* Slab name for sysfs */
-	int refcount;		/* Use counter */
+	refcount_t refcount;	/* Use counter */
+	int alias_count;
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
index b0dd9db1eb2f..390eb47486fd 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -306,7 +306,7 @@ int slab_unmergeable(struct kmem_cache *s)
 	/*
 	 * We may have set a slab to be unmergeable during bootstrap.
 	 */
-	if (s->refcount < 0)
+	if (s->alias_count < 0)
 		return 1;
 
 	return 0;
@@ -391,7 +391,8 @@ static struct kmem_cache *create_cache(const char *name,
 	if (err)
 		goto out_free_cache;
 
-	s->refcount = 1;
+	s->alias_count = 1;
+	refcount_set(&s->refcount, 1);
 	list_add(&s->list, &slab_caches);
 	memcg_link_cache(s);
 out:
@@ -611,6 +612,13 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	if (memcg->kmem_state != KMEM_ONLINE)
 		goto out_unlock;
 
+	/*
+	 * The root cache has been requested to be destroyed while its memcg
+	 * cache was in creation queue.
+	 */
+	if (!root_cache->alias_count)
+		goto out_unlock;
+
 	idx = memcg_cache_id(memcg);
 	arr = rcu_dereference_protected(root_cache->memcg_params.memcg_caches,
 					lockdep_is_held(&slab_mutex));
@@ -663,6 +671,8 @@ static void kmemcg_deactivate_workfn(struct work_struct *work)
 {
 	struct kmem_cache *s = container_of(work, struct kmem_cache,
 					    memcg_params.deact_work);
+	struct kmem_cache *root = s->memcg_params.root_cache;
+	struct mem_cgroup *memcg = s->memcg_params.memcg;
 
 	get_online_cpus();
 	get_online_mems();
@@ -677,7 +687,8 @@ static void kmemcg_deactivate_workfn(struct work_struct *work)
 	put_online_cpus();
 
 	/* done, put the ref from slab_deactivate_memcg_cache_rcu_sched() */
-	css_put(&s->memcg_params.memcg->css);
+	css_put(&memcg->css);
+	kmem_cache_put(root);
 }
 
 static void kmemcg_deactivate_rcufn(struct rcu_head *head)
@@ -712,6 +723,10 @@ void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 	    WARN_ON_ONCE(s->memcg_params.deact_fn))
 		return;
 
+	/* Make sure root kmem_cache does not get destroyed in the middle */
+	if (!kmem_cache_tryget(s->memcg_params.root_cache))
+		return;
+
 	/* pin memcg so that @s doesn't get destroyed in the middle */
 	css_get(&s->memcg_params.memcg->css);
 
@@ -838,21 +853,17 @@ void slab_kmem_cache_release(struct kmem_cache *s)
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
+	if (lock) {
+		get_online_cpus();
+		get_online_mems();
+		mutex_lock(&slab_mutex);
+	}
 
-	mutex_lock(&slab_mutex);
-
-	s->refcount--;
-	if (s->refcount)
-		goto out_unlock;
+	VM_BUG_ON(s->alias_count);
 
 	err = shutdown_memcg_caches(s);
 	if (!err)
@@ -863,11 +874,42 @@ void kmem_cache_destroy(struct kmem_cache *s)
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
+bool kmem_cache_tryget(struct kmem_cache *s)
+{
+	if (is_root_cache(s))
+		return refcount_inc_not_zero(&s->refcount);
+	return false;
+}
+
+void kmem_cache_put(struct kmem_cache *s)
+{
+	if (is_root_cache(s) &&
+	    refcount_dec_and_test(&s->refcount))
+		__kmem_cache_destroy(s, true);
+}
+
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
+	s->alias_count--;
+	kmem_cache_put(s);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
@@ -919,7 +961,8 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name,
 		panic("Creation of kmalloc slab %s size=%u failed. Reason %d\n",
 					name, size, err);
 
-	s->refcount = -1;	/* Exempt from merging for now */
+	s->alias_count = -1;	/* Exempt from merging for now */
+	refcount_set(&s->refcount, 1);
 }
 
 struct kmem_cache *__init create_kmalloc_cache(const char *name,
@@ -934,7 +977,8 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name,
 	create_boot_cache(s, name, size, flags, useroffset, usersize);
 	list_add(&s->list, &slab_caches);
 	memcg_link_cache(s);
-	s->refcount = 1;
+	s->alias_count = 1;
+	refcount_set(&s->refcount, 1);
 	return s;
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index 48f75872c356..2e45f7febc6e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4270,8 +4270,8 @@ __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 	struct kmem_cache *s, *c;
 
 	s = find_mergeable(size, align, flags, name, ctor);
-	if (s) {
-		s->refcount++;
+	if (s && kmem_cache_tryget(s)) {
+		s->alias_count++;
 
 		/*
 		 * Adjust the object sizes so that we clear
@@ -4286,7 +4286,8 @@ __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		}
 
 		if (sysfs_slab_alias(s, name)) {
-			s->refcount--;
+			s->alias_count--;
+			kmem_cache_put_locked(s);
 			s = NULL;
 		}
 	}
@@ -5009,7 +5010,8 @@ SLAB_ATTR_RO(ctor);
 
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->refcount < 0 ? 0 : s->refcount - 1);
+	return sprintf(buf, "%d\n",
+		       s->alias_count < 0 ? 0 : s->alias_count - 1);
 }
 SLAB_ATTR_RO(aliases);
 
@@ -5162,7 +5164,7 @@ static ssize_t trace_store(struct kmem_cache *s, const char *buf,
 	 * as well as cause other issues like converting a mergeable
 	 * cache into an umergeable one.
 	 */
-	if (s->refcount > 1)
+	if (s->alias_count > 1)
 		return -EINVAL;
 
 	s->flags &= ~SLAB_TRACE;
@@ -5280,7 +5282,7 @@ static ssize_t failslab_show(struct kmem_cache *s, char *buf)
 static ssize_t failslab_store(struct kmem_cache *s, const char *buf,
 							size_t length)
 {
-	if (s->refcount > 1)
+	if (s->alias_count > 1)
 		return -EINVAL;
 
 	s->flags &= ~SLAB_FAILSLAB;
-- 
2.17.0.441.gb46fe60e1d-goog
