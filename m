Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id CDFCA6B00A9
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 16:50:24 -0400 (EDT)
Received: by mail-gh0-f169.google.com with SMTP id r18so248154ghr.14
        for <linux-mm@kvack.org>; Sat, 08 Sep 2012 13:50:24 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 10/10] mm: Factor SLAB and SLUB common code
Date: Sat,  8 Sep 2012 17:47:59 -0300
Message-Id: <1347137279-17568-10-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Several interfaces are now exactly the same in both SLAB and SLUB,
and it's very easy to factor them out.
To make this work slab_alloc() and slab_alloc_node() are made non-static.

This has the benefit of putting most of the tracing code in mm/slab_common.c,
making it harder to produce inconsistent trace behavior.

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 include/linux/slab_def.h |    2 +
 include/linux/slub_def.h |    2 +
 mm/slab.c                |   68 +--------------------------------------------
 mm/slab_common.c         |   57 ++++++++++++++++++++++++++++++++++++++
 mm/slub.c                |   49 +-------------------------------
 5 files changed, 65 insertions(+), 113 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index e98caeb..021c162 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -107,6 +107,8 @@ struct cache_sizes {
 };
 extern struct cache_sizes malloc_sizes[];
 
+void *slab_alloc(struct kmem_cache *, gfp_t, unsigned long);
+void *slab_alloc_node(struct kmem_cache *, gfp_t, int, unsigned long);
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index df448ad..d94f457 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -216,6 +216,8 @@ static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
 	return kmalloc_caches[index];
 }
 
+void *slab_alloc(struct kmem_cache *, gfp_t, unsigned long);
+void *slab_alloc_node(struct kmem_cache *, gfp_t, int, unsigned long);
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
diff --git a/mm/slab.c b/mm/slab.c
index 57094ee..d7f8466 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3559,7 +3559,7 @@ done:
  *
  * Fallback to other node is possible if __GFP_THISNODE is not set.
  */
-static __always_inline void *
+__always_inline void *
 slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 		   unsigned long caller)
 {
@@ -3646,7 +3646,7 @@ __do_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 
 #endif /* CONFIG_NUMA */
 
-static __always_inline void *
+__always_inline void *
 slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 {
 	unsigned long save_flags;
@@ -3813,71 +3813,7 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 	ac_put_obj(cachep, ac, objp);
 }
 
-/**
- * kmem_cache_alloc - Allocate an object
- * @cachep: The cache to allocate from.
- * @flags: See kmalloc().
- *
- * Allocate an object from this cache.  The flags are only relevant
- * if the cache has no available objects.
- */
-void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
-{
-	void *ret = slab_alloc(cachep, flags, _RET_IP_);
-
-	trace_kmem_cache_alloc(_RET_IP_, ret,
-			       cachep->object_size, cachep->size, flags);
-
-	return ret;
-}
-EXPORT_SYMBOL(kmem_cache_alloc);
-
-#ifdef CONFIG_TRACING
-void *
-kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
-{
-	void *ret;
-
-	ret = slab_alloc(cachep, flags, _RET_IP_);
-
-	trace_kmalloc(_RET_IP_, ret,
-		      size, cachep->size, flags);
-	return ret;
-}
-EXPORT_SYMBOL(kmem_cache_alloc_trace);
-#endif
-
 #ifdef CONFIG_NUMA
-void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
-{
-	void *ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
-
-	trace_kmem_cache_alloc_node(_RET_IP_, ret,
-				    cachep->object_size, cachep->size,
-				    flags, nodeid);
-
-	return ret;
-}
-EXPORT_SYMBOL(kmem_cache_alloc_node);
-
-#ifdef CONFIG_TRACING
-void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
-				  gfp_t flags,
-				  int nodeid,
-				  size_t size)
-{
-	void *ret;
-
-	ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP);
-
-	trace_kmalloc_node(_RET_IP_, ret,
-			   size, cachep->size,
-			   flags, nodeid);
-	return ret;
-}
-EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
-#endif
-
 static __always_inline void *
 __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8cf8b49..5fc0da0 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -17,6 +17,7 @@
 #include <asm/tlbflush.h>
 #include <asm/page.h>
 
+#include <trace/events/kmem.h>
 #include "slab.h"
 
 enum slab_state slab_state;
@@ -113,6 +114,62 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
+#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
+/**
+ * kmem_cache_alloc - Allocate an object
+ * @cachep: The cache to allocate from.
+ * @flags: See kmalloc().
+ *
+ * Allocate an object from this cache.  The flags are only relevant
+ * if the cache has no available objects.
+ */
+void *kmem_cache_alloc(struct kmem_cache *s, gfp_t flags)
+{
+	void *ret = slab_alloc(s, flags, _RET_IP_);
+
+	trace_kmem_cache_alloc(_RET_IP_, ret, s->object_size, s->size, flags);
+
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc);
+
+#ifdef CONFIG_TRACING
+void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
+{
+	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
+	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_trace);
+#endif
+
+#ifdef CONFIG_NUMA
+void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
+{
+	void *ret = slab_alloc_node(s, gfpflags, node, _RET_IP_);
+
+	trace_kmem_cache_alloc_node(_RET_IP_, ret,
+				    s->object_size, s->size, gfpflags, node);
+
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_node);
+
+#ifdef CONFIG_TRACING
+void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
+				    gfp_t gfpflags,
+				    int node, size_t size)
+{
+	void *ret = slab_alloc_node(s, gfpflags, node, _RET_IP_);
+
+	trace_kmalloc_node(_RET_IP_, ret, size, s->size, gfpflags, node);
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
+#endif /* CONFIG_TRACING */
+#endif /* CONFIG_NUMA */
+#endif /* CONFIG_SLAB || CONFIG_SLUB */
+
 int slab_is_available(void)
 {
 	return slab_state >= UP;
diff --git a/mm/slub.c b/mm/slub.c
index 786a181..fa0fb4a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2311,7 +2311,7 @@ new_slab:
  *
  * Otherwise we can simply pick the next object from the lockless free list.
  */
-static __always_inline void *slab_alloc_node(struct kmem_cache *s,
+__always_inline void *slab_alloc_node(struct kmem_cache *s,
 		gfp_t gfpflags, int node, unsigned long addr)
 {
 	void **object;
@@ -2381,31 +2381,13 @@ redo:
 	return object;
 }
 
-static __always_inline void *slab_alloc(struct kmem_cache *s,
+__always_inline void *slab_alloc(struct kmem_cache *s,
 		gfp_t gfpflags, unsigned long addr)
 {
 	return slab_alloc_node(s, gfpflags, NUMA_NO_NODE, addr);
 }
 
-void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
-{
-	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
-
-	trace_kmem_cache_alloc(_RET_IP_, ret, s->object_size, s->size, gfpflags);
-
-	return ret;
-}
-EXPORT_SYMBOL(kmem_cache_alloc);
-
 #ifdef CONFIG_TRACING
-void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
-{
-	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
-	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
-	return ret;
-}
-EXPORT_SYMBOL(kmem_cache_alloc_trace);
-
 void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
 {
 	void *ret = kmalloc_order(size, flags, order);
@@ -2415,33 +2397,6 @@ void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
 EXPORT_SYMBOL(kmalloc_order_trace);
 #endif
 
-#ifdef CONFIG_NUMA
-void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
-{
-	void *ret = slab_alloc_node(s, gfpflags, node, _RET_IP_);
-
-	trace_kmem_cache_alloc_node(_RET_IP_, ret,
-				    s->object_size, s->size, gfpflags, node);
-
-	return ret;
-}
-EXPORT_SYMBOL(kmem_cache_alloc_node);
-
-#ifdef CONFIG_TRACING
-void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
-				    gfp_t gfpflags,
-				    int node, size_t size)
-{
-	void *ret = slab_alloc_node(s, gfpflags, node, _RET_IP_);
-
-	trace_kmalloc_node(_RET_IP_, ret,
-			   size, s->size, gfpflags, node);
-	return ret;
-}
-EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
-#endif
-#endif
-
 /*
  * Slow patch handling. This may still be called frequently since objects
  * have a longer lifetime than the cpu slabs in most processing loads.
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
