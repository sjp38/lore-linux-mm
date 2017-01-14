Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 873A26B026E
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 13:49:20 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id k15so64069191qtg.5
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:49:20 -0800 (PST)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id m189si10975526qkf.251.2017.01.14.10.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 10:49:19 -0800 (PST)
Received: by mail-qt0-x241.google.com with SMTP id n13so9996920qtc.0
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:49:19 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 6/8] slab: introduce __kmemcg_cache_deactivate()
Date: Sat, 14 Jan 2017 13:48:32 -0500
Message-Id: <20170114184834.8658-7-tj@kernel.org>
In-Reply-To: <20170114184834.8658-1-tj@kernel.org>
References: <20170114184834.8658-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com, Tejun Heo <tj@kernel.org>

__kmem_cache_shrink() is called with %true @deactivate only for memcg
caches.  Remove @deactivate from __kmem_cache_shrink() and introduce
__kmemcg_cache_deactivate() instead.  Each memcg-supporting allocator
should implement it and it should deactivate and drain the cache.

This is to allow memcg cache deactivation behavior to further deviate
from simple shrinking without messing up __kmem_cache_shrink().

This is pure reorganization and doesn't introduce any observable
behavior changes.

v2: Dropped unnecessary ifdef in mm/slab.h as suggested by Vladimir.

Signed-off-by: Tejun Heo <tj@kernel.org>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c        | 11 +++++++++--
 mm/slab.h        |  3 ++-
 mm/slab_common.c |  4 ++--
 mm/slob.c        |  2 +-
 mm/slub.c        | 39 ++++++++++++++++++++++-----------------
 5 files changed, 36 insertions(+), 23 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 767e8e4..65814f2 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2314,7 +2314,7 @@ static int drain_freelist(struct kmem_cache *cache,
 	return nr_freed;
 }
 
-int __kmem_cache_shrink(struct kmem_cache *cachep, bool deactivate)
+int __kmem_cache_shrink(struct kmem_cache *cachep)
 {
 	int ret = 0;
 	int node;
@@ -2332,9 +2332,16 @@ int __kmem_cache_shrink(struct kmem_cache *cachep, bool deactivate)
 	return (ret ? 1 : 0);
 }
 
+#ifdef CONFIG_MEMCG
+void __kmemcg_cache_deactivate(struct kmem_cache *cachep)
+{
+	__kmem_cache_shrink(cachep);
+}
+#endif
+
 int __kmem_cache_shutdown(struct kmem_cache *cachep)
 {
-	return __kmem_cache_shrink(cachep, false);
+	return __kmem_cache_shrink(cachep);
 }
 
 void __kmem_cache_release(struct kmem_cache *cachep)
diff --git a/mm/slab.h b/mm/slab.h
index d4d9270..0946d97 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -164,7 +164,8 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
 
 int __kmem_cache_shutdown(struct kmem_cache *);
 void __kmem_cache_release(struct kmem_cache *);
-int __kmem_cache_shrink(struct kmem_cache *, bool);
+int __kmem_cache_shrink(struct kmem_cache *);
+void __kmemcg_cache_deactivate(struct kmem_cache *s);
 void slab_kmem_cache_release(struct kmem_cache *);
 
 struct seq_file;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index bae6a63..cd81cad 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -611,7 +611,7 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 		if (!c)
 			continue;
 
-		__kmem_cache_shrink(c, true);
+		__kmemcg_cache_deactivate(c);
 		arr->entries[idx] = NULL;
 	}
 	mutex_unlock(&slab_mutex);
@@ -759,7 +759,7 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
 	get_online_cpus();
 	get_online_mems();
 	kasan_cache_shrink(cachep);
-	ret = __kmem_cache_shrink(cachep, false);
+	ret = __kmem_cache_shrink(cachep);
 	put_online_mems();
 	put_online_cpus();
 	return ret;
diff --git a/mm/slob.c b/mm/slob.c
index 5ec1580..eac04d4 100644
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
index 8f37896..c754ea0 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3886,7 +3886,7 @@ EXPORT_SYMBOL(kfree);
  * being allocated from last increasing the chance that the last objects
  * are freed in them.
  */
-int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
+int __kmem_cache_shrink(struct kmem_cache *s)
 {
 	int node;
 	int i;
@@ -3898,21 +3898,6 @@ int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
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
@@ -3963,13 +3948,33 @@ int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
 	return ret;
 }
 
+#ifdef CONFIG_MEMCG
+void __kmemcg_cache_deactivate(struct kmem_cache *s)
+{
+	/*
+	 * Disable empty slabs caching. Used to avoid pinning offline
+	 * memory cgroups by kmem pages that can be freed.
+	 */
+	s->cpu_partial = 0;
+	s->min_partial = 0;
+
+	/*
+	 * s->cpu_partial is checked locklessly (see put_cpu_partial), so
+	 * we have to make sure the change is visible.
+	 */
+	synchronize_sched();
+
+	__kmem_cache_shrink(s);
+}
+#endif
+
 static int slab_mem_going_offline_callback(void *arg)
 {
 	struct kmem_cache *s;
 
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list)
-		__kmem_cache_shrink(s, false);
+		__kmem_cache_shrink(s);
 	mutex_unlock(&slab_mutex);
 
 	return 0;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
