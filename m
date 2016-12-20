Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B5C646B033F
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 13:11:11 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q10so502340186pgq.7
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 10:11:11 -0800 (PST)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id u189si23165768pfu.124.2016.12.20.10.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 10:11:10 -0800 (PST)
Received: by mail-pg0-x22c.google.com with SMTP id i5so10363368pgh.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 10:11:10 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 1/2] kasan: drain quarantine of memcg slab objects
Date: Tue, 20 Dec 2016 10:11:01 -0800
Message-Id: <1482257462-36948-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

Per memcg slab accounting and kasan have a problem with kmem_cache
destruction.
- kmem_cache_create() allocates a kmem_cache, which is used for
  allocations from processes running in root (top) memcg.
- Processes running in non root memcg and allocating with either
  __GFP_ACCOUNT or from a SLAB_ACCOUNT cache use a per memcg kmem_cache.
- Kasan catches use-after-free by having kfree() and kmem_cache_free()
  defer freeing of objects.  Objects are placed in a quarantine.
- kmem_cache_destroy() destroys root and non root kmem_caches.  It takes
  care to drain the quarantine of objects from the root memcg's
  kmem_cache, but ignores objects associated with non root memcg.  This
  causes leaks because quarantined per memcg objects refer to per memcg
  kmem cache being destroyed.

To see the problem:
1) create a slab cache with kmem_cache_create(,,,SLAB_ACCOUNT,)
2) from non root memcg, allocate and free a few objects from cache
3) dispose of the cache with kmem_cache_destroy()
kmem_cache_destroy() will trigger a "Slab cache still has objects"
warning indicating that the per memcg kmem_cache structure was leaked.

Fix the leak by draining kasan quarantined objects allocated from non
root memcg.

Racing memcg deletion is tricky, but handled.  kmem_cache_destroy() =>
shutdown_memcg_caches() => __shutdown_memcg_cache() => shutdown_cache()
flushes per memcg quarantined objects, even if that memcg has been
rmdir'd and gone through memcg_deactivate_kmem_caches().

This leak only affects destroyed SLAB_ACCOUNT kmem caches when kasan is
enabled.  So I don't think it's worth patching stable kernels.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/kasan.h | 4 ++--
 mm/kasan/kasan.c      | 2 +-
 mm/kasan/quarantine.c | 1 +
 mm/slab_common.c      | 4 +++-
 4 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 820c0ad54a01..c908b25bf5a5 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -52,7 +52,7 @@ void kasan_free_pages(struct page *page, unsigned int order);
 void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 			unsigned long *flags);
 void kasan_cache_shrink(struct kmem_cache *cache);
-void kasan_cache_destroy(struct kmem_cache *cache);
+void kasan_cache_shutdown(struct kmem_cache *cache);
 
 void kasan_poison_slab(struct page *page);
 void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
@@ -98,7 +98,7 @@ static inline void kasan_cache_create(struct kmem_cache *cache,
 				      size_t *size,
 				      unsigned long *flags) {}
 static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
-static inline void kasan_cache_destroy(struct kmem_cache *cache) {}
+static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
 
 static inline void kasan_poison_slab(struct page *page) {}
 static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 0e9505f66ec1..8d020ad5b74a 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -428,7 +428,7 @@ void kasan_cache_shrink(struct kmem_cache *cache)
 	quarantine_remove_cache(cache);
 }
 
-void kasan_cache_destroy(struct kmem_cache *cache)
+void kasan_cache_shutdown(struct kmem_cache *cache)
 {
 	quarantine_remove_cache(cache);
 }
diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index baabaad4a4aa..fb362cb19157 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -273,6 +273,7 @@ static void per_cpu_remove_cache(void *arg)
 	qlist_free_all(&to_free, cache);
 }
 
+/* Free all quarantined objects belonging to cache. */
 void quarantine_remove_cache(struct kmem_cache *cache)
 {
 	unsigned long flags;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 329b03843863..d3c8602dea5d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -455,6 +455,9 @@ EXPORT_SYMBOL(kmem_cache_create);
 static int shutdown_cache(struct kmem_cache *s,
 		struct list_head *release, bool *need_rcu_barrier)
 {
+	/* free asan quarantined objects */
+	kasan_cache_shutdown(s);
+
 	if (__kmem_cache_shutdown(s) != 0)
 		return -EBUSY;
 
@@ -715,7 +718,6 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	get_online_cpus();
 	get_online_mems();
 
-	kasan_cache_destroy(s);
 	mutex_lock(&slab_mutex);
 
 	s->refcount--;
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
