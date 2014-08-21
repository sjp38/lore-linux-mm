Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id ECD5B6B0039
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 04:09:34 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so13991964pab.16
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 01:09:34 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id v1si20679013pdm.225.2014.08.21.01.09.32
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 01:09:34 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/5] mm/slab_common: move kmem_cache definition to internal header
Date: Thu, 21 Aug 2014 17:09:18 +0900
Message-Id: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We don't need to keep kmem_cache definition in include/linux/slab.h
if we don't need to inline kmem_cache_size(). According to my
code inspection, this function is only called at lc_create() in
lib/lru_cache.c which may be called at initialization phase of something,
so we don't need to inline it. Therfore, move it to slab_common.c and
move kmem_cache definition to internal header.

After this change, we can change kmem_cache definition easily without
full kernel build. For instance, we can turn on/off CONFIG_SLUB_STATS
without full kernel build.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/slab.h |   42 +-----------------------------------------
 mm/slab.h            |   33 +++++++++++++++++++++++++++++++++
 mm/slab_common.c     |    8 ++++++++
 3 files changed, 42 insertions(+), 41 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1d9abb7..9062e4a 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -158,31 +158,6 @@ size_t ksize(const void *);
 #define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
 #endif
 
-#ifdef CONFIG_SLOB
-/*
- * Common fields provided in kmem_cache by all slab allocators
- * This struct is either used directly by the allocator (SLOB)
- * or the allocator must include definitions for all fields
- * provided in kmem_cache_common in their definition of kmem_cache.
- *
- * Once we can do anonymous structs (C11 standard) we could put a
- * anonymous struct definition in these allocators so that the
- * separate allocations in the kmem_cache structure of SLAB and
- * SLUB is no longer needed.
- */
-struct kmem_cache {
-	unsigned int object_size;/* The original size of the object */
-	unsigned int size;	/* The aligned/padded/added on size  */
-	unsigned int align;	/* Alignment as calculated */
-	unsigned long flags;	/* Active flags on the slab */
-	const char *name;	/* Slab name for sysfs */
-	int refcount;		/* Use counter */
-	void (*ctor)(void *);	/* Called on object slot creation */
-	struct list_head list;	/* List of all slab caches on the system */
-};
-
-#endif /* CONFIG_SLOB */
-
 /*
  * Kmalloc array related definitions
  */
@@ -363,14 +338,6 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
 }
 #endif /* CONFIG_TRACING */
 
-#ifdef CONFIG_SLAB
-#include <linux/slab_def.h>
-#endif
-
-#ifdef CONFIG_SLUB
-#include <linux/slub_def.h>
-#endif
-
 extern void *kmalloc_order(size_t size, gfp_t flags, unsigned int order);
 
 #ifdef CONFIG_TRACING
@@ -650,14 +617,7 @@ static inline void *kzalloc_node(size_t size, gfp_t flags, int node)
 	return kmalloc_node(size, flags | __GFP_ZERO, node);
 }
 
-/*
- * Determine the size of a slab object
- */
-static inline unsigned int kmem_cache_size(struct kmem_cache *s)
-{
-	return s->object_size;
-}
-
+unsigned int kmem_cache_size(struct kmem_cache *s);
 void __init kmem_cache_init_late(void);
 
 #endif	/* _LINUX_SLAB_H */
diff --git a/mm/slab.h b/mm/slab.h
index 0e0fdd3..bd1c54a 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -4,6 +4,39 @@
  * Internal slab definitions
  */
 
+#ifdef CONFIG_SLOB
+/*
+ * Common fields provided in kmem_cache by all slab allocators
+ * This struct is either used directly by the allocator (SLOB)
+ * or the allocator must include definitions for all fields
+ * provided in kmem_cache_common in their definition of kmem_cache.
+ *
+ * Once we can do anonymous structs (C11 standard) we could put a
+ * anonymous struct definition in these allocators so that the
+ * separate allocations in the kmem_cache structure of SLAB and
+ * SLUB is no longer needed.
+ */
+struct kmem_cache {
+	unsigned int object_size;/* The original size of the object */
+	unsigned int size;	/* The aligned/padded/added on size  */
+	unsigned int align;	/* Alignment as calculated */
+	unsigned long flags;	/* Active flags on the slab */
+	const char *name;	/* Slab name for sysfs */
+	int refcount;		/* Use counter */
+	void (*ctor)(void *);	/* Called on object slot creation */
+	struct list_head list;	/* List of all slab caches on the system */
+};
+
+#endif /* CONFIG_SLOB */
+
+#ifdef CONFIG_SLAB
+#include <linux/slab_def.h>
+#endif
+
+#ifdef CONFIG_SLUB
+#include <linux/slub_def.h>
+#endif
+
 /*
  * State of the slab allocator.
  *
diff --git a/mm/slab_common.c b/mm/slab_common.c
index d319502..2088904 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -30,6 +30,14 @@ LIST_HEAD(slab_caches);
 DEFINE_MUTEX(slab_mutex);
 struct kmem_cache *kmem_cache;
 
+/*
+ * Determine the size of a slab object
+ */
+unsigned int kmem_cache_size(struct kmem_cache *s)
+{
+	return s->object_size;
+}
+
 #ifdef CONFIG_DEBUG_VM
 static int kmem_cache_sanity_check(const char *name, size_t size)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
