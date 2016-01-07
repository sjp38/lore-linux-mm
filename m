Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id DD1BD6B0007
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 09:03:46 -0500 (EST)
Received: by mail-qk0-f174.google.com with SMTP id n135so178843366qka.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 06:03:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p47si10919807qge.79.2016.01.07.06.03.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 06:03:45 -0800 (PST)
Subject: [PATCH 02/10] mm/slab: move SLUB alloc hooks to common mm/slab.h
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 07 Jan 2016 15:03:43 +0100
Message-ID: <20160107140343.28907.29037.stgit@firesoul>
In-Reply-To: <20160107140253.28907.5469.stgit@firesoul>
References: <20160107140253.28907.5469.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

First step towards sharing alloc_hook's between SLUB and SLAB
allocators.  Move the SLUB allocators *_alloc_hook to the common
mm/slab.h for internal slab definitions.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slab.h |   62 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/slub.c |   54 -----------------------------------------------------
 2 files changed, 62 insertions(+), 54 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 7b6087197997..92b10da2c71f 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -38,6 +38,10 @@ struct kmem_cache {
 #endif
 
 #include <linux/memcontrol.h>
+#include <linux/fault-inject.h>
+#include <linux/kmemcheck.h>
+#include <linux/kasan.h>
+#include <linux/kmemleak.h>
 
 /*
  * State of the slab allocator.
@@ -319,6 +323,64 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 	return s;
 }
 
+static inline size_t slab_ksize(const struct kmem_cache *s)
+{
+#ifndef CONFIG_SLUB
+	return s->object_size;
+
+#else /* CONFIG_SLUB */
+# ifdef CONFIG_SLUB_DEBUG
+	/*
+	 * Debugging requires use of the padding between object
+	 * and whatever may come after it.
+	 */
+	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
+		return s->object_size;
+# endif
+	/*
+	 * If we have the need to store the freelist pointer
+	 * back there or track user information then we can
+	 * only use the space before that information.
+	 */
+	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
+		return s->inuse;
+	/*
+	 * Else we can use all the padding etc for the allocation
+	 */
+	return s->size;
+#endif
+}
+
+static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
+						     gfp_t flags)
+{
+	flags &= gfp_allowed_mask;
+	lockdep_trace_alloc(flags);
+	might_sleep_if(gfpflags_allow_blocking(flags));
+
+	if (should_failslab(s->object_size, flags, s->flags))
+		return NULL;
+
+	return memcg_kmem_get_cache(s, flags);
+}
+
+static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
+					size_t size, void **p)
+{
+	size_t i;
+
+	flags &= gfp_allowed_mask;
+	for (i = 0; i < size; i++) {
+		void *object = p[i];
+
+		kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
+		kmemleak_alloc_recursive(object, s->object_size, 1,
+					 s->flags, flags);
+		kasan_slab_alloc(s, object);
+	}
+	memcg_kmem_put_cache(s);
+}
+
 #ifndef CONFIG_SLOB
 /*
  * The slab lists for all objects.
diff --git a/mm/slub.c b/mm/slub.c
index 0538e45e1964..3697f216d7c7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -284,30 +284,6 @@ static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
 	return (p - addr) / s->size;
 }
 
-static inline size_t slab_ksize(const struct kmem_cache *s)
-{
-#ifdef CONFIG_SLUB_DEBUG
-	/*
-	 * Debugging requires use of the padding between object
-	 * and whatever may come after it.
-	 */
-	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
-		return s->object_size;
-
-#endif
-	/*
-	 * If we have the need to store the freelist pointer
-	 * back there or track user information then we can
-	 * only use the space before that information.
-	 */
-	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
-		return s->inuse;
-	/*
-	 * Else we can use all the padding etc for the allocation
-	 */
-	return s->size;
-}
-
 static inline int order_objects(int order, unsigned long size, int reserved)
 {
 	return ((PAGE_SIZE << order) - reserved) / size;
@@ -1279,36 +1255,6 @@ static inline void kfree_hook(const void *x)
 	kasan_kfree_large(x);
 }
 
-static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
-						     gfp_t flags)
-{
-	flags &= gfp_allowed_mask;
-	lockdep_trace_alloc(flags);
-	might_sleep_if(gfpflags_allow_blocking(flags));
-
-	if (should_failslab(s->object_size, flags, s->flags))
-		return NULL;
-
-	return memcg_kmem_get_cache(s, flags);
-}
-
-static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
-					size_t size, void **p)
-{
-	size_t i;
-
-	flags &= gfp_allowed_mask;
-	for (i = 0; i < size; i++) {
-		void *object = p[i];
-
-		kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
-		kmemleak_alloc_recursive(object, s->object_size, 1,
-					 s->flags, flags);
-		kasan_slab_alloc(s, object);
-	}
-	memcg_kmem_put_cache(s);
-}
-
 static inline void slab_free_hook(struct kmem_cache *s, void *x)
 {
 	kmemleak_free_recursive(x, s->flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
