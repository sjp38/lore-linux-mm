Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5EB5C6B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 20:18:40 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c4-v6so13487955pfg.22
        for <linux-mm@kvack.org>; Thu, 31 May 2018 17:18:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e5-v6si6724014pgp.105.2018.05.31.17.18.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 17:18:38 -0700 (PDT)
Date: Thu, 31 May 2018 17:18:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm: fix race between kmem_cache destroy, create and
  deactivate
Message-Id: <20180531171834.e16fc59550d24437a12c612b@linux-foundation.org>
In-Reply-To: <20180530001204.183758-1-shakeelb@google.com>
References: <20180530001204.183758-1-shakeelb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 29 May 2018 17:12:04 -0700 Shakeel Butt <shakeelb@google.com> wrote:

> The memcg kmem cache creation and deactivation (SLUB only) is
> asynchronous. If a root kmem cache is destroyed whose memcg cache is in
> the process of creation or deactivation, the kernel may crash.
> 
> Example of one such crash:
> 	general protection fault: 0000 [#1] SMP PTI
> 	CPU: 1 PID: 1721 Comm: kworker/14:1 Not tainted 4.17.0-smp
> 	...
> 	Workqueue: memcg_kmem_cache kmemcg_deactivate_workfn
> 	RIP: 0010:has_cpu_slab
> 	...
> 	Call Trace:
> 	? on_each_cpu_cond
> 	__kmem_cache_shrink
> 	kmemcg_cache_deact_after_rcu
> 	kmemcg_deactivate_workfn
> 	process_one_work
> 	worker_thread
> 	kthread
> 	ret_from_fork+0x35/0x40
> 
> To fix this race, on root kmem cache destruction, mark the cache as
> dying and flush the workqueue used for memcg kmem cache creation and
> deactivation.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
> Changelog since v2:
> - Instead of refcount, flush the workqueue

This one-liner doesn't appear to fully describe the difference between
v2 and v3, which is rather large:

 include/linux/slab.h     |    3 
 include/linux/slab_def.h |    5 -
 include/linux/slub_def.h |    3 
 mm/memcontrol.c          |    7 -
 mm/slab.c                |    4 -
 mm/slab.h                |    6 -
 mm/slab_common.c         |  139 ++++++++++---------------------------
 mm/slub.c                |   14 +--
 8 files changed, 51 insertions(+), 130 deletions(-)

diff -puN include/linux/slab_def.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3 include/linux/slab_def.h
--- a/include/linux/slab_def.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3
+++ a/include/linux/slab_def.h
@@ -41,10 +41,7 @@ struct kmem_cache {
 /* 4) cache creation/removal */
 	const char *name;
 	struct list_head list;
-	/* Refcount for root kmem caches */
-	refcount_t refcount;
-	/* Number of root kmem caches sharing this cache */
-	int shared_count;
+	int refcount;
 	int object_size;
 	int align;
 
diff -puN include/linux/slab.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3 include/linux/slab.h
--- a/include/linux/slab.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3
+++ a/include/linux/slab.h
@@ -599,6 +599,7 @@ struct memcg_cache_params {
 			struct memcg_cache_array __rcu *memcg_caches;
 			struct list_head __root_caches_node;
 			struct list_head children;
+			bool dying;
 		};
 		struct {
 			struct mem_cgroup *memcg;
@@ -615,8 +616,6 @@ struct memcg_cache_params {
 };
 
 int memcg_update_all_caches(int num_memcgs);
-bool kmem_cache_tryget(struct kmem_cache *s);
-void kmem_cache_put(struct kmem_cache *s);
 
 /**
  * kmalloc_array - allocate memory for an array.
diff -puN include/linux/slub_def.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3 include/linux/slub_def.h
--- a/include/linux/slub_def.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3
+++ a/include/linux/slub_def.h
@@ -97,8 +97,7 @@ struct kmem_cache {
 	struct kmem_cache_order_objects max;
 	struct kmem_cache_order_objects min;
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
-	refcount_t refcount;	/* Refcount for root kmem cache */
-	int shared_count;	/* Number of kmem caches sharing this cache */
+	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *);
 	unsigned int inuse;		/* Offset to metadata */
 	unsigned int align;		/* Alignment */
diff -puN mm/memcontrol.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3 mm/memcontrol.c
--- a/mm/memcontrol.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3
+++ a/mm/memcontrol.c
@@ -2181,7 +2181,6 @@ static void memcg_kmem_cache_create_func
 	memcg_create_kmem_cache(memcg, cachep);
 
 	css_put(&memcg->css);
-	kmem_cache_put(cachep);
 	kfree(cw);
 }
 
@@ -2197,12 +2196,6 @@ static void __memcg_schedule_kmem_cache_
 	if (!cw)
 		return;
 
-	/* Make sure root kmem cache does not get destroyed in the middle */
-	if (!kmem_cache_tryget(cachep)) {
-		kfree(cw);
-		return;
-	}
-
 	css_get(&memcg->css);
 
 	cw->memcg = memcg;
diff -puN mm/slab.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3 mm/slab.c
--- a/mm/slab.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3
+++ a/mm/slab.c
@@ -1883,8 +1883,8 @@ __kmem_cache_alias(const char *name, uns
 	struct kmem_cache *cachep;
 
 	cachep = find_mergeable(size, align, flags, name, ctor);
-	if (cachep && kmem_cache_tryget(cachep)) {
-		cachep->shared_count++;
+	if (cachep) {
+		cachep->refcount++;
 
 		/*
 		 * Adjust the object sizes so that we clear
diff -puN mm/slab_common.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3 mm/slab_common.c
--- a/mm/slab_common.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3
+++ a/mm/slab_common.c
@@ -136,6 +136,7 @@ void slab_init_memcg_params(struct kmem_
 	s->memcg_params.root_cache = NULL;
 	RCU_INIT_POINTER(s->memcg_params.memcg_caches, NULL);
 	INIT_LIST_HEAD(&s->memcg_params.children);
+	s->memcg_params.dying = false;
 }
 
 static int init_memcg_params(struct kmem_cache *s,
@@ -306,7 +307,7 @@ int slab_unmergeable(struct kmem_cache *
 	/*
 	 * We may have set a slab to be unmergeable during bootstrap.
 	 */
-	if (s->shared_count < 0)
+	if (s->refcount < 0)
 		return 1;
 
 	return 0;
@@ -391,8 +392,7 @@ static struct kmem_cache *create_cache(c
 	if (err)
 		goto out_free_cache;
 
-	s->shared_count = 1;
-	refcount_set(&s->refcount, 1);
+	s->refcount = 1;
 	list_add(&s->list, &slab_caches);
 	memcg_link_cache(s);
 out:
@@ -609,19 +609,7 @@ void memcg_create_kmem_cache(struct mem_
 	 * The memory cgroup could have been offlined while the cache
 	 * creation work was pending.
 	 */
-	if (memcg->kmem_state != KMEM_ONLINE)
-		goto out_unlock;
-
-	/*
-	 * The root cache has been requested to be destroyed while its memcg
-	 * cache was in creation queue.
-	 *
-	 * The shared_count can be out-dated or can be incremented after return.
-	 * No big worries, at worst the creation of memcg kmem_cache is delayed.
-	 * The next allocation will again trigger the memcg kmem_cache creation
-	 * request.
-	 */
-	if (!root_cache->shared_count)
+	if (memcg->kmem_state != KMEM_ONLINE || root_cache->memcg_params.dying)
 		goto out_unlock;
 
 	idx = memcg_cache_id(memcg);
@@ -676,8 +664,6 @@ static void kmemcg_deactivate_workfn(str
 {
 	struct kmem_cache *s = container_of(work, struct kmem_cache,
 					    memcg_params.deact_work);
-	struct kmem_cache *root = s->memcg_params.root_cache;
-	struct mem_cgroup *memcg = s->memcg_params.memcg;
 
 	get_online_cpus();
 	get_online_mems();
@@ -692,8 +678,7 @@ static void kmemcg_deactivate_workfn(str
 	put_online_cpus();
 
 	/* done, put the ref from slab_deactivate_memcg_cache_rcu_sched() */
-	css_put(&memcg->css);
-	kmem_cache_put(root);
+	css_put(&s->memcg_params.memcg->css);
 }
 
 static void kmemcg_deactivate_rcufn(struct rcu_head *head)
@@ -728,8 +713,7 @@ void slab_deactivate_memcg_cache_rcu_sch
 	    WARN_ON_ONCE(s->memcg_params.deact_fn))
 		return;
 
-	/* Make sure root kmem_cache does not get destroyed in the middle */
-	if (!kmem_cache_tryget(s->memcg_params.root_cache))
+	if (s->memcg_params.root_cache->memcg_params.dying)
 		return;
 
 	/* pin memcg so that @s doesn't get destroyed in the middle */
@@ -843,11 +827,24 @@ static int shutdown_memcg_caches(struct
 		return -EBUSY;
 	return 0;
 }
+
+static void flush_memcg_workqueue(struct kmem_cache *s)
+{
+	mutex_lock(&slab_mutex);
+	s->memcg_params.dying = true;
+	mutex_unlock(&slab_mutex);
+
+	flush_workqueue(memcg_kmem_cache_wq);
+}
 #else
 static inline int shutdown_memcg_caches(struct kmem_cache *s)
 {
 	return 0;
 }
+
+static inline void flush_memcg_workqueue(struct kmem_cache *s)
+{
+}
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 void slab_kmem_cache_release(struct kmem_cache *s)
@@ -858,17 +855,23 @@ void slab_kmem_cache_release(struct kmem
 	kmem_cache_free(kmem_cache, s);
 }
 
-static void __kmem_cache_destroy(struct kmem_cache *s, bool lock)
+void kmem_cache_destroy(struct kmem_cache *s)
 {
 	int err;
 
-	if (lock) {
-		get_online_cpus();
-		get_online_mems();
-		mutex_lock(&slab_mutex);
-	}
+	if (unlikely(!s))
+		return;
+
+	flush_memcg_workqueue(s);
+
+	get_online_cpus();
+	get_online_mems();
 
-	VM_BUG_ON(s->shared_count);
+	mutex_lock(&slab_mutex);
+
+	s->refcount--;
+	if (s->refcount)
+		goto out_unlock;
 
 	err = shutdown_memcg_caches(s);
 	if (!err)
@@ -879,75 +882,11 @@ static void __kmem_cache_destroy(struct
 		       s->name);
 		dump_stack();
 	}
+out_unlock:
+	mutex_unlock(&slab_mutex);
 
-	if (lock) {
-		mutex_unlock(&slab_mutex);
-		put_online_mems();
-		put_online_cpus();
-	}
-}
-
-/*
- * kmem_cache_tryget - Try to get a reference on a kmem_cache
- * @s: target kmem_cache
- *
- * Obtain a reference on a kmem_cache unless it already has reached zero and is
- * being released. The caller needs to ensure that kmem_cache is accessible.
- * Currently only root kmem_cache supports reference counting.
- */
-bool kmem_cache_tryget(struct kmem_cache *s)
-{
-	if (is_root_cache(s))
-		return refcount_inc_not_zero(&s->refcount);
-	return false;
-}
-
-/*
- * kmem_cache_put - Put a reference on a kmem_cache
- * @s: target kmem_cache
- *
- * Put a reference obtained via kmem_cache_tryget(). This function can not be
- * called within slab_mutex as it can trigger a destruction of a kmem_cache
- * which requires slab_mutex.
- */
-void kmem_cache_put(struct kmem_cache *s)
-{
-	if (is_root_cache(s) &&
-	    refcount_dec_and_test(&s->refcount))
-		__kmem_cache_destroy(s, true);
-}
-
-/*
- * kmem_cache_put_locked - Put a reference on a kmem_cache while holding
- * slab_mutex
- * @s: target kmem_cache
- *
- * Put a reference obtained via kmem_cache_tryget(). Use this function instead
- * of kmem_cache_put if the caller has already acquired slab_mutex.
- *
- * At the moment this function is not exposed externally and is used by SLUB.
- */
-void kmem_cache_put_locked(struct kmem_cache *s)
-{
-	if (is_root_cache(s) &&
-	    refcount_dec_and_test(&s->refcount))
-		__kmem_cache_destroy(s, false);
-}
-
-void kmem_cache_destroy(struct kmem_cache *s)
-{
-	if (unlikely(!s))
-		return;
-
-	/*
-	 * It is safe to decrement shared_count without any lock. In
-	 * __kmem_cache_alias the kmem_cache's refcount is elevated before
-	 * incrementing shared_count and below the reference is dropped after
-	 * decrementing shared_count. At worst shared_count can be outdated for
-	 * a small window but that is tolerable.
-	 */
-	s->shared_count--;
-	kmem_cache_put(s);
+	put_online_mems();
+	put_online_cpus();
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
@@ -999,8 +938,7 @@ void __init create_boot_cache(struct kme
 		panic("Creation of kmalloc slab %s size=%u failed. Reason %d\n",
 					name, size, err);
 
-	s->shared_count = -1;	/* Exempt from merging for now */
-	refcount_set(&s->refcount, 1);
+	s->refcount = -1;	/* Exempt from merging for now */
 }
 
 struct kmem_cache *__init create_kmalloc_cache(const char *name,
@@ -1015,8 +953,7 @@ struct kmem_cache *__init create_kmalloc
 	create_boot_cache(s, name, size, flags, useroffset, usersize);
 	list_add(&s->list, &slab_caches);
 	memcg_link_cache(s);
-	s->shared_count = 1;
-	refcount_set(&s->refcount, 1);
+	s->refcount = 1;
 	return s;
 }
 
diff -puN mm/slab.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3 mm/slab.h
--- a/mm/slab.h~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3
+++ a/mm/slab.h
@@ -25,8 +25,7 @@ struct kmem_cache {
 	unsigned int useroffset;/* Usercopy region offset */
 	unsigned int usersize;	/* Usercopy region size */
 	const char *name;	/* Slab name for sysfs */
-	refcount_t refcount;	/* Refcount for root kmem cache */
-	int shared_count;	/* Number of kmem caches sharing this cache */
+	int refcount;		/* Use counter */
 	void (*ctor)(void *);	/* Called on object slot creation */
 	struct list_head list;	/* List of all slab caches on the system */
 };
@@ -204,8 +203,6 @@ ssize_t slabinfo_write(struct file *file
 void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
 int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 
-extern void kmem_cache_put_locked(struct kmem_cache *s);
-
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 
 /* List of all root caches. */
@@ -298,6 +295,7 @@ extern void slab_init_memcg_params(struc
 extern void memcg_link_cache(struct kmem_cache *s);
 extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 				void (*deact_fn)(struct kmem_cache *));
+
 #else /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 /* If !memcg, all caches are root. */
diff -puN mm/slub.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3 mm/slub.c
--- a/mm/slub.c~mm-fix-race-between-kmem_cache-destroy-create-and-deactivate-v3
+++ a/mm/slub.c
@@ -4274,8 +4274,8 @@ __kmem_cache_alias(const char *name, uns
 	struct kmem_cache *s, *c;
 
 	s = find_mergeable(size, align, flags, name, ctor);
-	if (s && kmem_cache_tryget(s)) {
-		s->shared_count++;
+	if (s) {
+		s->refcount++;
 
 		/*
 		 * Adjust the object sizes so that we clear
@@ -4290,8 +4290,7 @@ __kmem_cache_alias(const char *name, uns
 		}
 
 		if (sysfs_slab_alias(s, name)) {
-			s->shared_count--;
-			kmem_cache_put_locked(s);
+			s->refcount--;
 			s = NULL;
 		}
 	}
@@ -5014,8 +5013,7 @@ SLAB_ATTR_RO(ctor);
 
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n",
-		       s->shared_count < 0 ? 0 : s->shared_count - 1);
+	return sprintf(buf, "%d\n", s->refcount < 0 ? 0 : s->refcount - 1);
 }
 SLAB_ATTR_RO(aliases);
 
@@ -5168,7 +5166,7 @@ static ssize_t trace_store(struct kmem_c
 	 * as well as cause other issues like converting a mergeable
 	 * cache into an umergeable one.
 	 */
-	if (s->shared_count > 1)
+	if (s->refcount > 1)
 		return -EINVAL;
 
 	s->flags &= ~SLAB_TRACE;
@@ -5286,7 +5284,7 @@ static ssize_t failslab_show(struct kmem
 static ssize_t failslab_store(struct kmem_cache *s, const char *buf,
 							size_t length)
 {
-	if (s->shared_count > 1)
+	if (s->refcount > 1)
 		return -EINVAL;
 
 	s->flags &= ~SLAB_FAILSLAB;
_
