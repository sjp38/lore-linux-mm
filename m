Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABEC26B0253
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 00:54:59 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id z128so174078007pfb.4
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:54:59 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id q2si14758892plh.215.2017.01.13.21.54.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 21:54:58 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id b1so343981pgc.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:54:58 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/9] slab: remove synchronous rcu_barrier() call in memcg cache release path
Date: Sat, 14 Jan 2017 00:54:42 -0500
Message-Id: <20170114055449.11044-3-tj@kernel.org>
In-Reply-To: <20170114055449.11044-1-tj@kernel.org>
References: <20170114055449.11044-1-tj@kernel.org>
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

SLAB_DESTORY_BY_RCU caches need a rcu grace period before destruction.
Currently, it's done synchronously with rcu_barrier().  As
rcu_barrier() is expensive time-wise, slab implements a batching
mechanism so that rcu_barrier() can be done for multiple caches at the
same time.

Unfortunately, the rcu_barrier() is in synchronous path which is
called while holding cgroup_mutex and the batching is too limited to
be actually helpful.  Besides, the batching is just a very degenerate
form of the actual RCU callback mechanism.

This patch updates the cache release path so that it simply uses
call_rcu() instead of the synchronous rcu_barrier() + custom batching.
This doesn't cost more while being logically simpler and way more
scalable.

* ->rcu_head is added to kmem_cache structs.  It shares storage space
  with ->list.

* slub sysfs removal and release are separated and the former is now
  called from __kmem_cache_shutdown() while the latter is called from
  the release path.  There's no reason to defer sysfs removal through
  RCU and this makes it unnecessary to bounce to workqueue from the
  RCU callback.

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
 include/linux/slab_def.h |  5 ++-
 include/linux/slub_def.h |  9 ++++--
 mm/slab.h                |  5 ++-
 mm/slab_common.c         | 84 ++++++++++++++++++++----------------------------
 mm/slub.c                |  9 +++++-
 5 files changed, 57 insertions(+), 55 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 4ad2c5a..b649629 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -39,7 +39,10 @@ struct kmem_cache {
 
 /* 4) cache creation/removal */
 	const char *name;
-	struct list_head list;
+	union {
+		struct list_head list;
+		struct rcu_head rcu_head;
+	};
 	int refcount;
 	int object_size;
 	int align;
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 75f56c2..7637b41 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -80,7 +80,10 @@ struct kmem_cache {
 	int align;		/* Alignment */
 	int reserved;		/* Reserved bytes at the end of slabs */
 	const char *name;	/* Name (only for display!) */
-	struct list_head list;	/* List of slab caches */
+	union {
+		struct list_head list;	/* List of slab caches */
+		struct rcu_head rcu_head;
+	};
 	int red_left_pad;	/* Left redzone padding size */
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
@@ -113,9 +116,9 @@ struct kmem_cache {
 
 #ifdef CONFIG_SYSFS
 #define SLAB_SUPPORTS_SYSFS
-void sysfs_slab_remove(struct kmem_cache *);
+void sysfs_slab_release(struct kmem_cache *);
 #else
-static inline void sysfs_slab_remove(struct kmem_cache *s)
+static inline void sysfs_slab_release(struct kmem_cache *s)
 {
 }
 #endif
diff --git a/mm/slab.h b/mm/slab.h
index 4acc644..3fa2d77 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -24,7 +24,10 @@ struct kmem_cache {
 	const char *name;	/* Slab name for sysfs */
 	int refcount;		/* Use counter */
 	void (*ctor)(void *);	/* Called on object slot creation */
-	struct list_head list;	/* List of all slab caches on the system */
+	union {
+		struct list_head list;	/* List of all slab caches on the system */
+		struct rcu_head rcu_head;
+	};
 };
 
 #endif /* CONFIG_SLOB */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 46ff746..851c75e 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -215,6 +215,11 @@ int memcg_update_all_caches(int num_memcgs)
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
@@ -225,6 +230,10 @@ static inline int init_memcg_params(struct kmem_cache *s,
 static inline void destroy_memcg_params(struct kmem_cache *s)
 {
 }
+
+static inline void unlink_memcg_cache(struct kmem_cache *s)
+{
+}
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 /*
@@ -458,33 +467,32 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
-static int shutdown_cache(struct kmem_cache *s,
-		struct list_head *release, bool *need_rcu_barrier)
+static void slab_kmem_cache_release_rcufn(struct rcu_head *head)
 {
-	if (__kmem_cache_shutdown(s) != 0)
-		return -EBUSY;
+	struct kmem_cache *s = container_of(head, struct kmem_cache, rcu_head);
 
-	if (s->flags & SLAB_DESTROY_BY_RCU)
-		*need_rcu_barrier = true;
-
-	list_move(&s->list, release);
-	return 0;
+#ifdef SLAB_SUPPORTS_SYSFS
+	sysfs_slab_release(s);
+#else
+	slab_kmem_cache_release(s);
+#endif
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
-#ifdef SLAB_SUPPORTS_SYSFS
-		sysfs_slab_remove(s);
-#else
-		slab_kmem_cache_release(s);
-#endif
-	}
+	if (s->flags & SLAB_DESTROY_BY_RCU)
+		call_rcu(&s->rcu_head, slab_kmem_cache_release_rcufn);
+	else
+		slab_kmem_cache_release_rcufn(&s->rcu_head);
+
+	return 0;
 }
 
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
@@ -599,22 +607,8 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
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
@@ -628,18 +622,15 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
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
@@ -658,7 +649,7 @@ static int shutdown_memcg_caches(struct kmem_cache *s,
 		c = arr->entries[i];
 		if (!c)
 			continue;
-		if (__shutdown_memcg_cache(c, release, need_rcu_barrier))
+		if (shutdown_cache(c))
 			/*
 			 * The cache still has objects. Move it to a temporary
 			 * list so as not to try to destroy it for a second
@@ -681,7 +672,7 @@ static int shutdown_memcg_caches(struct kmem_cache *s,
 	 */
 	list_for_each_entry_safe(c, c2, &s->memcg_params.list,
 				 memcg_params.list)
-		__shutdown_memcg_cache(c, release, need_rcu_barrier);
+		shutdown_cache(c);
 
 	list_splice(&busy, &s->memcg_params.list);
 
@@ -694,8 +685,7 @@ static int shutdown_memcg_caches(struct kmem_cache *s,
 	return 0;
 }
 #else
-static inline int shutdown_memcg_caches(struct kmem_cache *s,
-		struct list_head *release, bool *need_rcu_barrier)
+static inline int shutdown_memcg_caches(struct kmem_cache *s)
 {
 	return 0;
 }
@@ -711,8 +701,6 @@ void slab_kmem_cache_release(struct kmem_cache *s)
 
 void kmem_cache_destroy(struct kmem_cache *s)
 {
-	LIST_HEAD(release);
-	bool need_rcu_barrier = false;
 	int err;
 
 	if (unlikely(!s))
@@ -728,9 +716,9 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->refcount)
 		goto out_unlock;
 
-	err = shutdown_memcg_caches(s, &release, &need_rcu_barrier);
+	err = shutdown_memcg_caches(s);
 	if (!err)
-		err = shutdown_cache(s, &release, &need_rcu_barrier);
+		err = shutdown_cache(s);
 
 	if (err) {
 		pr_err("kmem_cache_destroy %s: Slab cache still has objects\n",
@@ -742,8 +730,6 @@ void kmem_cache_destroy(struct kmem_cache *s)
 
 	put_online_mems();
 	put_online_cpus();
-
-	release_caches(&release, need_rcu_barrier);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
diff --git a/mm/slub.c b/mm/slub.c
index 68b84f9..a26cb90 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -214,11 +214,13 @@ enum track_item { TRACK_ALLOC, TRACK_FREE };
 static int sysfs_slab_add(struct kmem_cache *);
 static int sysfs_slab_alias(struct kmem_cache *, const char *);
 static void memcg_propagate_slab_attrs(struct kmem_cache *s);
+static void sysfs_slab_remove(struct kmem_cache *);
 #else
 static inline int sysfs_slab_add(struct kmem_cache *s) { return 0; }
 static inline int sysfs_slab_alias(struct kmem_cache *s, const char *p)
 							{ return 0; }
 static inline void memcg_propagate_slab_attrs(struct kmem_cache *s) { }
+static inline void sysfs_slab_remove(struct kmem_cache *) { }
 #endif
 
 static inline void stat(const struct kmem_cache *s, enum stat_item si)
@@ -3679,6 +3681,7 @@ int __kmem_cache_shutdown(struct kmem_cache *s)
 		if (n->nr_partial || slabs_node(s, node))
 			return 1;
 	}
+	sysfs_slab_remove(s);
 	return 0;
 }
 
@@ -5629,7 +5632,7 @@ static int sysfs_slab_add(struct kmem_cache *s)
 	goto out;
 }
 
-void sysfs_slab_remove(struct kmem_cache *s)
+static void sysfs_slab_remove(struct kmem_cache *s)
 {
 	if (slab_state < FULL)
 		/*
@@ -5643,6 +5646,10 @@ void sysfs_slab_remove(struct kmem_cache *s)
 #endif
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
 	kobject_del(&s->kobj);
+}
+
+void sysfs_slab_release(struct kmem_cache *s)
+{
 	kobject_put(&s->kobj);
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
