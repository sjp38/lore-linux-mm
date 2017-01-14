Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEFE46B0253
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 13:48:52 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id x64so74975888qkb.5
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:48:52 -0800 (PST)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id f18si10982327qkh.323.2017.01.14.10.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 10:48:52 -0800 (PST)
Received: by mail-qk0-x243.google.com with SMTP id 11so11434536qkl.0
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:48:51 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/8] Revert "slub: move synchronize_sched out of slab_mutex on shrink"
Date: Sat, 14 Jan 2017 13:48:27 -0500
Message-Id: <20170114184834.8658-2-tj@kernel.org>
In-Reply-To: <20170114184834.8658-1-tj@kernel.org>
References: <20170114184834.8658-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com, Tejun Heo <tj@kernel.org>

This reverts commit 89e364db71fb5e7fc8d93228152abfa67daf35fa.

With kmem cgroup support enabled, kmem_caches can be created and
destroyed frequently and a great number of near empty kmem_caches can
accumulate if there are a lot of transient cgroups and the system is
not under memory pressure.  When memory reclaim starts under such
conditions, it can lead to consecutive deactivation and destruction of
many kmem_caches, easily hundreds of thousands on moderately large
systems, exposing scalability issues in the current slab management
code.  This is one of the patches to address the issue.

Moving synchronize_sched() out of slab_mutex isn't enough as it's
still inside cgroup_mutex.  The whole deactivation / release path will
be updated to avoid all synchronous RCU operations.  Revert this
insufficient optimization in preparation to ease future changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Jay Vana <jsvana@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c        |  4 ++--
 mm/slab.h        |  2 +-
 mm/slab_common.c | 27 ++-------------------------
 mm/slob.c        |  2 +-
 mm/slub.c        | 19 +++++++++++++++++--
 5 files changed, 23 insertions(+), 31 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 29bc6c0..767e8e4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2314,7 +2314,7 @@ static int drain_freelist(struct kmem_cache *cache,
 	return nr_freed;
 }
 
-int __kmem_cache_shrink(struct kmem_cache *cachep)
+int __kmem_cache_shrink(struct kmem_cache *cachep, bool deactivate)
 {
 	int ret = 0;
 	int node;
@@ -2334,7 +2334,7 @@ int __kmem_cache_shrink(struct kmem_cache *cachep)
 
 int __kmem_cache_shutdown(struct kmem_cache *cachep)
 {
-	return __kmem_cache_shrink(cachep);
+	return __kmem_cache_shrink(cachep, false);
 }
 
 void __kmem_cache_release(struct kmem_cache *cachep)
diff --git a/mm/slab.h b/mm/slab.h
index de6579d..4acc644 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -161,7 +161,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
 
 int __kmem_cache_shutdown(struct kmem_cache *);
 void __kmem_cache_release(struct kmem_cache *);
-int __kmem_cache_shrink(struct kmem_cache *);
+int __kmem_cache_shrink(struct kmem_cache *, bool);
 void slab_kmem_cache_release(struct kmem_cache *);
 
 struct seq_file;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index ae32384..46ff746 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -579,29 +579,6 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 	get_online_cpus();
 	get_online_mems();
 
-#ifdef CONFIG_SLUB
-	/*
-	 * In case of SLUB, we need to disable empty slab caching to
-	 * avoid pinning the offline memory cgroup by freeable kmem
-	 * pages charged to it. SLAB doesn't need this, as it
-	 * periodically purges unused slabs.
-	 */
-	mutex_lock(&slab_mutex);
-	list_for_each_entry(s, &slab_caches, list) {
-		c = is_root_cache(s) ? cache_from_memcg_idx(s, idx) : NULL;
-		if (c) {
-			c->cpu_partial = 0;
-			c->min_partial = 0;
-		}
-	}
-	mutex_unlock(&slab_mutex);
-	/*
-	 * kmem_cache->cpu_partial is checked locklessly (see
-	 * put_cpu_partial()). Make sure the change is visible.
-	 */
-	synchronize_sched();
-#endif
-
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list) {
 		if (!is_root_cache(s))
@@ -613,7 +590,7 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 		if (!c)
 			continue;
 
-		__kmem_cache_shrink(c);
+		__kmem_cache_shrink(c, true);
 		arr->entries[idx] = NULL;
 	}
 	mutex_unlock(&slab_mutex);
@@ -784,7 +761,7 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
 	get_online_cpus();
 	get_online_mems();
 	kasan_cache_shrink(cachep);
-	ret = __kmem_cache_shrink(cachep);
+	ret = __kmem_cache_shrink(cachep, false);
 	put_online_mems();
 	put_online_cpus();
 	return ret;
diff --git a/mm/slob.c b/mm/slob.c
index eac04d4..5ec1580 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -634,7 +634,7 @@ void __kmem_cache_release(struct kmem_cache *c)
 {
 }
 
-int __kmem_cache_shrink(struct kmem_cache *d)
+int __kmem_cache_shrink(struct kmem_cache *d, bool deactivate)
 {
 	return 0;
 }
diff --git a/mm/slub.c b/mm/slub.c
index 067598a..68b84f9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3883,7 +3883,7 @@ EXPORT_SYMBOL(kfree);
  * being allocated from last increasing the chance that the last objects
  * are freed in them.
  */
-int __kmem_cache_shrink(struct kmem_cache *s)
+int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
 {
 	int node;
 	int i;
@@ -3895,6 +3895,21 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 	unsigned long flags;
 	int ret = 0;
 
+	if (deactivate) {
+		/*
+		 * Disable empty slabs caching. Used to avoid pinning offline
+		 * memory cgroups by kmem pages that can be freed.
+		 */
+		s->cpu_partial = 0;
+		s->min_partial = 0;
+
+		/*
+		 * s->cpu_partial is checked locklessly (see put_cpu_partial),
+		 * so we have to make sure the change is visible.
+		 */
+		synchronize_sched();
+	}
+
 	flush_all(s);
 	for_each_kmem_cache_node(s, node, n) {
 		INIT_LIST_HEAD(&discard);
@@ -3951,7 +3966,7 @@ static int slab_mem_going_offline_callback(void *arg)
 
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list)
-		__kmem_cache_shrink(s);
+		__kmem_cache_shrink(s, false);
 	mutex_unlock(&slab_mutex);
 
 	return 0;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
