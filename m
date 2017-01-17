Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F005C6B025E
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 18:54:20 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 204so75844192pge.5
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:54:20 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id r5si26403446pgj.103.2017.01.17.15.54.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 15:54:20 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id e4so6812235pfg.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:54:20 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 03/10] slab: remove synchronous rcu_barrier() call in memcg cache release path
Date: Tue, 17 Jan 2017 15:54:04 -0800
Message-Id: <20170117235411.9408-4-tj@kernel.org>
In-Reply-To: <20170117235411.9408-1-tj@kernel.org>
References: <20170117235411.9408-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com, Tejun Heo <tj@kernel.org>

With kmem cgroup support enabled, kmem_caches can be created and
destroyed frequently and a great number of near empty kmem_caches can
accumulate if there are a lot of transient cgroups and the system is
not under memory pressure.  When memory reclaim starts under such
conditions, it can lead to consecutive deactivation and destruction of
many kmem_caches, easily hundreds of thousands on moderately large
systems, exposing scalability issues in the current slab management
code.  This is one of the patches to address the issue.

SLAB_DESTORY_BY_RCU caches need to flush all RCU operations before
destruction because slab pages are freed through RCU and they need to
be able to dereference the associated kmem_cache.  Currently, it's
done synchronously with rcu_barrier().  As rcu_barrier() is expensive
time-wise, slab implements a batching mechanism so that rcu_barrier()
can be done for multiple caches at the same time.

Unfortunately, the rcu_barrier() is in synchronous path which is
called while holding cgroup_mutex and the batching is too limited to
be actually helpful.

This patch updates the cache release path so that the batching is
asynchronous and global.  All SLAB_DESTORY_BY_RCU caches are queued
globally and a work item consumes the list.  The work item calls
rcu_barrier() only once for all caches that are currently queued.

* release_caches() is removed and shutdown_cache() now either directly
  release the cache or schedules a RCU callback to do that.  This
  makes the cache inaccessible once shutdown_cache() is called and
  makes it impossible for shutdown_memcg_caches() to do memcg-specific
  cleanups afterwards.  Move memcg-specific part into a helper,
  unlink_memcg_cache(), and make shutdown_cache() call it directly.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Jay Vana <jsvana@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab_common.c | 102 ++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 60 insertions(+), 42 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3bc4bb8..c6fd297 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -30,6 +30,11 @@ LIST_HEAD(slab_caches);
 DEFINE_MUTEX(slab_mutex);
 struct kmem_cache *kmem_cache;
 
+static LIST_HEAD(slab_caches_to_rcu_destroy);
+static void slab_caches_to_rcu_destroy_workfn(struct work_struct *work);
+static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
+		    slab_caches_to_rcu_destroy_workfn);
+
 /*
  * Set of flags that will prevent slab merging
  */
@@ -215,6 +220,11 @@ int memcg_update_all_caches(int num_memcgs)
 	mutex_unlock(&slab_mutex);
 	return ret;
 }
+
+static void unlink_memcg_cache(struct kmem_cache *s)
+{
+	list_del(&s->memcg_params.list);
+}
 #else
 static inline int init_memcg_params(struct kmem_cache *s,
 		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
@@ -225,6 +235,10 @@ static inline int init_memcg_params(struct kmem_cache *s,
 static inline void destroy_memcg_params(struct kmem_cache *s)
 {
 }
+
+static inline void unlink_memcg_cache(struct kmem_cache *s)
+{
+}
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 /*
@@ -458,33 +472,59 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
-static int shutdown_cache(struct kmem_cache *s,
-		struct list_head *release, bool *need_rcu_barrier)
+static void slab_caches_to_rcu_destroy_workfn(struct work_struct *work)
 {
-	if (__kmem_cache_shutdown(s) != 0)
-		return -EBUSY;
+	LIST_HEAD(to_destroy);
+	struct kmem_cache *s, *s2;
 
-	if (s->flags & SLAB_DESTROY_BY_RCU)
-		*need_rcu_barrier = true;
+	/*
+	 * On destruction, SLAB_DESTROY_BY_RCU kmem_caches are put on the
+	 * @slab_caches_to_rcu_destroy list.  The slab pages are freed
+	 * through RCU and and the associated kmem_cache are dereferenced
+	 * while freeing the pages, so the kmem_caches should be freed only
+	 * after the pending RCU operations are finished.  As rcu_barrier()
+	 * is a pretty slow operation, we batch all pending destructions
+	 * asynchronously.
+	 */
+	mutex_lock(&slab_mutex);
+	list_splice_init(&slab_caches_to_rcu_destroy, &to_destroy);
+	mutex_unlock(&slab_mutex);
 
-	list_move(&s->list, release);
-	return 0;
+	if (list_empty(&to_destroy))
+		return;
+
+	rcu_barrier();
+
+	list_for_each_entry_safe(s, s2, &to_destroy, list) {
+#ifdef SLAB_SUPPORTS_SYSFS
+		sysfs_slab_release(s);
+#else
+		slab_kmem_cache_release(s);
+#endif
+	}
 }
 
-static void release_caches(struct list_head *release, bool need_rcu_barrier)
+static int shutdown_cache(struct kmem_cache *s)
 {
-	struct kmem_cache *s, *s2;
+	if (__kmem_cache_shutdown(s) != 0)
+		return -EBUSY;
 
-	if (need_rcu_barrier)
-		rcu_barrier();
+	list_del(&s->list);
+	if (!is_root_cache(s))
+		unlink_memcg_cache(s);
 
-	list_for_each_entry_safe(s, s2, release, list) {
+	if (s->flags & SLAB_DESTROY_BY_RCU) {
+		list_add_tail(&s->list, &slab_caches_to_rcu_destroy);
+		schedule_work(&slab_caches_to_rcu_destroy_work);
+	} else {
 #ifdef SLAB_SUPPORTS_SYSFS
 		sysfs_slab_release(s);
 #else
 		slab_kmem_cache_release(s);
 #endif
 	}
+
+	return 0;
 }
 
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
@@ -599,22 +639,8 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 	put_online_cpus();
 }
 
-static int __shutdown_memcg_cache(struct kmem_cache *s,
-		struct list_head *release, bool *need_rcu_barrier)
-{
-	BUG_ON(is_root_cache(s));
-
-	if (shutdown_cache(s, release, need_rcu_barrier))
-		return -EBUSY;
-
-	list_del(&s->memcg_params.list);
-	return 0;
-}
-
 void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 {
-	LIST_HEAD(release);
-	bool need_rcu_barrier = false;
 	struct kmem_cache *s, *s2;
 
 	get_online_cpus();
@@ -628,18 +654,15 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 		 * The cgroup is about to be freed and therefore has no charges
 		 * left. Hence, all its caches must be empty by now.
 		 */
-		BUG_ON(__shutdown_memcg_cache(s, &release, &need_rcu_barrier));
+		BUG_ON(shutdown_cache(s));
 	}
 	mutex_unlock(&slab_mutex);
 
 	put_online_mems();
 	put_online_cpus();
-
-	release_caches(&release, need_rcu_barrier);
 }
 
-static int shutdown_memcg_caches(struct kmem_cache *s,
-		struct list_head *release, bool *need_rcu_barrier)
+static int shutdown_memcg_caches(struct kmem_cache *s)
 {
 	struct memcg_cache_array *arr;
 	struct kmem_cache *c, *c2;
@@ -658,7 +681,7 @@ static int shutdown_memcg_caches(struct kmem_cache *s,
 		c = arr->entries[i];
 		if (!c)
 			continue;
-		if (__shutdown_memcg_cache(c, release, need_rcu_barrier))
+		if (shutdown_cache(c))
 			/*
 			 * The cache still has objects. Move it to a temporary
 			 * list so as not to try to destroy it for a second
@@ -681,7 +704,7 @@ static int shutdown_memcg_caches(struct kmem_cache *s,
 	 */
 	list_for_each_entry_safe(c, c2, &s->memcg_params.list,
 				 memcg_params.list)
-		__shutdown_memcg_cache(c, release, need_rcu_barrier);
+		shutdown_cache(c);
 
 	list_splice(&busy, &s->memcg_params.list);
 
@@ -694,8 +717,7 @@ static int shutdown_memcg_caches(struct kmem_cache *s,
 	return 0;
 }
 #else
-static inline int shutdown_memcg_caches(struct kmem_cache *s,
-		struct list_head *release, bool *need_rcu_barrier)
+static inline int shutdown_memcg_caches(struct kmem_cache *s)
 {
 	return 0;
 }
@@ -711,8 +733,6 @@ void slab_kmem_cache_release(struct kmem_cache *s)
 
 void kmem_cache_destroy(struct kmem_cache *s)
 {
-	LIST_HEAD(release);
-	bool need_rcu_barrier = false;
 	int err;
 
 	if (unlikely(!s))
@@ -728,9 +748,9 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->refcount)
 		goto out_unlock;
 
-	err = shutdown_memcg_caches(s, &release, &need_rcu_barrier);
+	err = shutdown_memcg_caches(s);
 	if (!err)
-		err = shutdown_cache(s, &release, &need_rcu_barrier);
+		err = shutdown_cache(s);
 
 	if (err) {
 		pr_err("kmem_cache_destroy %s: Slab cache still has objects\n",
@@ -742,8 +762,6 @@ void kmem_cache_destroy(struct kmem_cache *s)
 
 	put_online_mems();
 	put_online_cpus();
-
-	release_caches(&release, need_rcu_barrier);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
