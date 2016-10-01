Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5644E6B0253
	for <linux-mm@kvack.org>; Sat,  1 Oct 2016 09:56:53 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x23so5848482lfi.0
        for <linux-mm@kvack.org>; Sat, 01 Oct 2016 06:56:53 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id o21si11638529lfo.228.2016.10.01.06.56.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Oct 2016 06:56:51 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id l131so7077526lfl.0
        for <linux-mm@kvack.org>; Sat, 01 Oct 2016 06:56:51 -0700 (PDT)
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: [PATCH 2/2] slub: move synchronize_sched out of slab_mutex on shrink
Date: Sat,  1 Oct 2016 16:56:48 +0300
Message-Id: <0a10d71ecae3db00fb4421bcd3f82bcc911f4be4.1475329751.git.vdavydov.dev@gmail.com>
In-Reply-To: <c509c51d47b387c3d8e879678aca0b5e881b4613.1475329751.git.vdavydov.dev@gmail.com>
References: <c509c51d47b387c3d8e879678aca0b5e881b4613.1475329751.git.vdavydov.dev@gmail.com>
In-Reply-To: <c509c51d47b387c3d8e879678aca0b5e881b4613.1475329751.git.vdavydov.dev@gmail.com>
References: <c509c51d47b387c3d8e879678aca0b5e881b4613.1475329751.git.vdavydov.dev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Pekka Enberg <penberg@kernel.org>

synchronize_sched() is a heavy operation and calling it per each cache
owned by a memory cgroup being destroyed may take quite some time. What
is worse, it's currently called under the slab_mutex, stalling all works
doing cache creation/destruction.

Actually, there isn't much point in calling synchronize_sched() for each
cache - it's enough to call it just once - after setting cpu_partial for
all caches and before shrinking them. This way, we can also move it out
of the slab_mutex, which we have to hold for iterating over the slab
cache list.

Link: https://bugzilla.kernel.org/show_bug.cgi?id=172991
Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Reported-by: Doug Smythies <dsmythies@telus.net>
Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>
---
 mm/slab.c        |  4 ++--
 mm/slab.h        |  2 +-
 mm/slab_common.c | 27 +++++++++++++++++++++++++--
 mm/slob.c        |  2 +-
 mm/slub.c        | 19 ++-----------------
 5 files changed, 31 insertions(+), 23 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index b67271024135..fb9b0b06f6b9 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2339,7 +2339,7 @@ out:
 	return nr_freed;
 }
 
-int __kmem_cache_shrink(struct kmem_cache *cachep, bool deactivate)
+int __kmem_cache_shrink(struct kmem_cache *cachep)
 {
 	int ret = 0;
 	int node;
@@ -2359,7 +2359,7 @@ int __kmem_cache_shrink(struct kmem_cache *cachep, bool deactivate)
 
 int __kmem_cache_shutdown(struct kmem_cache *cachep)
 {
-	return __kmem_cache_shrink(cachep, false);
+	return __kmem_cache_shrink(cachep);
 }
 
 void __kmem_cache_release(struct kmem_cache *cachep)
diff --git a/mm/slab.h b/mm/slab.h
index 9653f2e2591a..36382b24ba98 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -146,7 +146,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
 
 int __kmem_cache_shutdown(struct kmem_cache *);
 void __kmem_cache_release(struct kmem_cache *);
-int __kmem_cache_shrink(struct kmem_cache *, bool);
+int __kmem_cache_shrink(struct kmem_cache *);
 void slab_kmem_cache_release(struct kmem_cache *);
 
 struct seq_file;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 71f0b28a1bec..3fac1e2ca67b 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -573,6 +573,29 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 	get_online_cpus();
 	get_online_mems();
 
+#ifdef CONFIG_SLUB
+	/*
+	 * In case of SLUB, we need to disable empty slab caching to
+	 * avoid pinning the offline memory cgroup by freeable kmem
+	 * pages charged to it. SLAB doesn't need this, as it
+	 * periodically purges unused slabs.
+	 */
+	mutex_lock(&slab_mutex);
+	list_for_each_entry(s, &slab_caches, list) {
+		c = is_root_cache(s) ? cache_from_memcg_idx(s, idx) : NULL;
+		if (c) {
+			c->cpu_partial = 0;
+			c->min_partial = 0;
+		}
+	}
+	mutex_unlock(&slab_mutex);
+	/*
+	 * kmem_cache->cpu_partial is checked locklessly (see
+	 * put_cpu_partial()). Make sure the change is visible.
+	 */
+	synchronize_sched();
+#endif
+
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list) {
 		if (!is_root_cache(s))
@@ -584,7 +607,7 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 		if (!c)
 			continue;
 
-		__kmem_cache_shrink(c, true);
+		__kmem_cache_shrink(c);
 		arr->entries[idx] = NULL;
 	}
 	mutex_unlock(&slab_mutex);
@@ -755,7 +778,7 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
 	get_online_cpus();
 	get_online_mems();
 	kasan_cache_shrink(cachep);
-	ret = __kmem_cache_shrink(cachep, false);
+	ret = __kmem_cache_shrink(cachep);
 	put_online_mems();
 	put_online_cpus();
 	return ret;
diff --git a/mm/slob.c b/mm/slob.c
index 5ec158054ffe..eac04d4357ec 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -634,7 +634,7 @@ void __kmem_cache_release(struct kmem_cache *c)
 {
 }
 
-int __kmem_cache_shrink(struct kmem_cache *d, bool deactivate)
+int __kmem_cache_shrink(struct kmem_cache *d)
 {
 	return 0;
 }
diff --git a/mm/slub.c b/mm/slub.c
index 9adae58462f8..379b7963e48e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3868,7 +3868,7 @@ EXPORT_SYMBOL(kfree);
  * being allocated from last increasing the chance that the last objects
  * are freed in them.
  */
-int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
+int __kmem_cache_shrink(struct kmem_cache *s)
 {
 	int node;
 	int i;
@@ -3880,21 +3880,6 @@ int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
 	unsigned long flags;
 	int ret = 0;
 
-	if (deactivate) {
-		/*
-		 * Disable empty slabs caching. Used to avoid pinning offline
-		 * memory cgroups by kmem pages that can be freed.
-		 */
-		s->cpu_partial = 0;
-		s->min_partial = 0;
-
-		/*
-		 * s->cpu_partial is checked locklessly (see put_cpu_partial),
-		 * so we have to make sure the change is visible.
-		 */
-		synchronize_sched();
-	}
-
 	flush_all(s);
 	for_each_kmem_cache_node(s, node, n) {
 		INIT_LIST_HEAD(&discard);
@@ -3951,7 +3936,7 @@ static int slab_mem_going_offline_callback(void *arg)
 
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list)
-		__kmem_cache_shrink(s, false);
+		__kmem_cache_shrink(s);
 	mutex_unlock(&slab_mutex);
 
 	return 0;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
