Received: by ti-out-0910.google.com with SMTP id j3so1780283tid.8
        for <linux-mm@kvack.org>; Sat, 12 Jul 2008 12:05:28 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [PATCH] kmemtrace: SLAB hooks.
Date: Sat, 12 Jul 2008 22:04:31 +0300
Message-Id: <1215889471-5734-1-git-send-email-eduard.munteanu@linux360.ro>
In-Reply-To: <84144f020807110149v4806404fjdb9c3e4af3cfdb70@mail.gmail.com>
References: <84144f020807110149v4806404fjdb9c3e4af3cfdb70@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This adds hooks for the SLAB allocator, to allow tracing with kmemtrace.

Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---

Dropped the __GFP_NOTRACE thing. Also fixed NUMA tracing and some whitespace
errors.

What do you think?

 include/linux/slab_def.h |   56 +++++++++++++++++++++++++++++++++++++-----
 mm/slab.c                |   61 +++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 104 insertions(+), 13 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 39c3a5e..040fe72 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -14,6 +14,7 @@
 #include <asm/page.h>		/* kmalloc_sizes.h needs PAGE_SIZE */
 #include <asm/cache.h>		/* kmalloc_sizes.h needs L1_CACHE_BYTES */
 #include <linux/compiler.h>
+#include <linux/kmemtrace.h>
 
 /* Size description struct for general caches. */
 struct cache_sizes {
@@ -28,8 +29,20 @@ extern struct cache_sizes malloc_sizes[];
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
+#ifdef CONFIG_KMEMTRACE
+extern void *__kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags);
+#else
+static inline void *__kmem_cache_alloc(struct kmem_cache *cachep,
+				       gfp_t flags)
+{
+	return __kmem_cache_alloc(cachep, flags);
+}
+#endif
+
 static inline void *kmalloc(size_t size, gfp_t flags)
 {
+	void *ret;
+
 	if (__builtin_constant_p(size)) {
 		int i = 0;
 
@@ -50,10 +63,17 @@ static inline void *kmalloc(size_t size, gfp_t flags)
 found:
 #ifdef CONFIG_ZONE_DMA
 		if (flags & GFP_DMA)
-			return kmem_cache_alloc(malloc_sizes[i].cs_dmacachep,
-						flags);
+			ret = __kmem_cache_alloc(malloc_sizes[i].cs_dmacachep,
+						 flags);
+		else
 #endif
-		return kmem_cache_alloc(malloc_sizes[i].cs_cachep, flags);
+			ret = __kmem_cache_alloc(malloc_sizes[i].cs_cachep,
+						 flags);
+
+		kmemtrace_mark_alloc(KMEMTRACE_KIND_KERNEL, _THIS_IP_, ret,
+				     size, malloc_sizes[i].cs_size, flags);
+
+		return ret;
 	}
 	return __kmalloc(size, flags);
 }
@@ -62,8 +82,23 @@ found:
 extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
 extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 
+#ifdef CONFIG_KMEMTRACE
+extern void *__kmem_cache_alloc_node(struct kmem_cache *cachep,
+				     gfp_t flags,
+				     int nodeid);
+#else
+static inline void *__kmem_cache_alloc_node(struct kmem_cache *cachep,
+					    gfp_t flags,
+					    int nodeid)
+{
+	return kmem_cache_alloc_node(cachep, flags, nodeid);
+}
+#endif
+
 static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
+	void *ret;
+
 	if (__builtin_constant_p(size)) {
 		int i = 0;
 
@@ -84,11 +119,18 @@ static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 found:
 #ifdef CONFIG_ZONE_DMA
 		if (flags & GFP_DMA)
-			return kmem_cache_alloc_node(malloc_sizes[i].cs_dmacachep,
-						flags, node);
+			ret = __kmem_cache_alloc_node(malloc_sizes[i].cs_dmacachep,
+						      flags, node);
+		else
 #endif
-		return kmem_cache_alloc_node(malloc_sizes[i].cs_cachep,
-						flags, node);
+			ret =  __kmem_cache_alloc_node(malloc_sizes[i].cs_cachep,
+						       flags, node);
+
+		kmemtrace_mark_alloc_node(KMEMTRACE_KIND_KERNEL, _THIS_IP_,
+					  ret, size, malloc_sizes[i].cs_size,
+					  flags, node);
+
+		return ret;
 	}
 	return __kmalloc_node(size, flags, node);
 }
diff --git a/mm/slab.c b/mm/slab.c
index 046607f..f07e022 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -111,6 +111,7 @@
 #include	<linux/rtmutex.h>
 #include	<linux/reciprocal_div.h>
 #include	<linux/debugobjects.h>
+#include	<linux/kmemtrace.h>
 
 #include	<asm/cacheflush.h>
 #include	<asm/tlbflush.h>
@@ -3621,10 +3622,23 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp)
  */
 void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
-	return __cache_alloc(cachep, flags, __builtin_return_address(0));
+	void *ret = __cache_alloc(cachep, flags, __builtin_return_address(0));
+
+	kmemtrace_mark_alloc(KMEMTRACE_KIND_CACHE, _RET_IP_, ret,
+			     obj_size(cachep), obj_size(cachep), flags);
+
+	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
+#ifdef CONFIG_KMEMTRACE
+void *__kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
+{
+	return __cache_alloc(cachep, flags, __builtin_return_address(0));
+}
+EXPORT_SYMBOL(__kmem_cache_alloc);
+#endif
+
 /**
  * kmem_ptr_validate - check if an untrusted pointer might be a slab entry.
  * @cachep: the cache we're checking against
@@ -3669,20 +3683,44 @@ out:
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
-	return __cache_alloc_node(cachep, flags, nodeid,
-			__builtin_return_address(0));
+	void *ret = __cache_alloc_node(cachep, flags, nodeid,
+				       __builtin_return_address(0));
+
+	kmemtrace_mark_alloc_node(KMEMTRACE_KIND_CACHE, _RET_IP_, ret,
+				  obj_size(cachep), obj_size(cachep),
+				  flags, nodeid);
+
+	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
+#ifdef CONFIG_KMEMTRACE
+void *__kmem_cache_alloc_node(struct kmem_cache *cachep,
+			      gfp_t flags,
+			      int nodeid)
+{
+	return __cache_alloc_node(cachep, flags, nodeid,
+				  __builtin_return_address(0));
+}
+EXPORT_SYMBOL(__kmem_cache_alloc_node);
+#endif
+
 static __always_inline void *
 __do_kmalloc_node(size_t size, gfp_t flags, int node, void *caller)
 {
 	struct kmem_cache *cachep;
+	void *ret;
 
 	cachep = kmem_find_general_cachep(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	return kmem_cache_alloc_node(cachep, flags, node);
+	ret = __kmem_cache_alloc_node(cachep, flags, node);
+
+	kmemtrace_mark_alloc_node(KMEMTRACE_KIND_KERNEL,
+				  (unsigned long) caller, ret,
+				  size, cachep->buffer_size, flags, node);
+
+	return ret;
 }
 
 #ifdef CONFIG_DEBUG_SLAB
@@ -3718,6 +3756,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 					  void *caller)
 {
 	struct kmem_cache *cachep;
+	void *ret;
 
 	/* If you want to save a few bytes .text space: replace
 	 * __ with kmem_.
@@ -3727,11 +3766,17 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	cachep = __find_general_cachep(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	return __cache_alloc(cachep, flags, caller);
+	ret = __cache_alloc(cachep, flags, caller);
+
+	kmemtrace_mark_alloc(KMEMTRACE_KIND_KERNEL,
+			     (unsigned long) caller, ret,
+			     size, cachep->buffer_size, flags);
+
+	return ret;
 }
 
 
-#ifdef CONFIG_DEBUG_SLAB
+#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_KMEMTRACE)
 void *__kmalloc(size_t size, gfp_t flags)
 {
 	return __do_kmalloc(size, flags, __builtin_return_address(0));
@@ -3770,6 +3815,8 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 		debug_check_no_obj_freed(objp, obj_size(cachep));
 	__cache_free(cachep, objp);
 	local_irq_restore(flags);
+
+	kmemtrace_mark_free(KMEMTRACE_KIND_CACHE, _RET_IP_, objp);
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
@@ -3796,6 +3843,8 @@ void kfree(const void *objp)
 	debug_check_no_obj_freed(objp, obj_size(c));
 	__cache_free(c, (void *)objp);
 	local_irq_restore(flags);
+
+	kmemtrace_mark_free(KMEMTRACE_KIND_KERNEL, _RET_IP_, objp);
 }
 EXPORT_SYMBOL(kfree);
 
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
