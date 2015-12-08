Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7FF076B0258
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 11:19:02 -0500 (EST)
Received: by qgec40 with SMTP id c40so23109290qge.2
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 08:19:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c1si4083725qkh.3.2015.12.08.08.18.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 08:18:30 -0800 (PST)
Subject: [RFC PATCH V2 1/9] mm/slab: move SLUB alloc hooks to common
 mm/slab.h
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 08 Dec 2015 17:18:27 +0100
Message-ID: <20151208161827.21945.25463.stgit@firesoul>
In-Reply-To: <20151208161751.21945.53936.stgit@firesoul>
References: <20151208161751.21945.53936.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

First step towards sharing alloc_hook's between SLUB and SLAB
allocators.  Move the SLUB allocators *_alloc_hook to the common
mm/slab.h for internal slab definitions.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slab.h |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/slub.c |   54 ----------------------------------------------
 2 files changed, 71 insertions(+), 54 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 7b6087197997..588bc5281fc8 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -38,6 +38,17 @@ struct kmem_cache {
 #endif
 
 #include <linux/memcontrol.h>
+#include <linux/fault-inject.h>
+/* Q: Howto handle this nicely? below includes are needed for alloc hooks
+ *
+ * e.g. mm/mempool.c and mm/slab_common.c does not include kmemcheck.h
+ * including it here solves the probem, but should they include it
+ * themselves?
+ */
+#include <linux/kmemcheck.h>
+// Below includes are already included in other users of "mm/slab.h"
+//#include <linux/kasan.h>
+//#include <linux/kmemleak.h>
 
 /*
  * State of the slab allocator.
@@ -319,6 +330,66 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 	return s;
 }
 
+#ifdef CONFIG_SLUB
+static inline size_t slab_ksize(const struct kmem_cache *s)
+{
+#ifdef CONFIG_SLUB_DEBUG
+	/*
+	 * Debugging requires use of the padding between object
+	 * and whatever may come after it.
+	 */
+	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
+		return s->object_size;
+#endif
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
+}
+#else /* !CONFIG_SLUB */
+static inline size_t slab_ksize(const struct kmem_cache *s)
+{
+	return s->object_size;
+}
+#endif
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
index 46997517406e..6bc179952150 100644
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
