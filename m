Date: Thu, 10 Jul 2008 21:06:11 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [RFC PATCH 3/5] kmemtrace: SLAB hooks.
Message-ID: <20080710210611.7c194a70@linux360.ro>
In-Reply-To: <1215712946-23572-3-git-send-email-eduard.munteanu@linux360.ro>
References: <1215712946-23572-1-git-send-email-eduard.munteanu@linux360.ro>
 <1215712946-23572-2-git-send-email-eduard.munteanu@linux360.ro>
 <1215712946-23572-3-git-send-email-eduard.munteanu@linux360.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This adds hooks for the SLAB allocator, to allow tracing with kmemtrace.

Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 include/linux/slab_def.h |   16 +++++++++++++---
 mm/slab.c                |   35 +++++++++++++++++++++++++++++------
 2 files changed, 42 insertions(+), 9 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 39c3a5e..89d0cca 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -14,6 +14,7 @@
 #include <asm/page.h>		/* kmalloc_sizes.h needs PAGE_SIZE */
 #include <asm/cache.h>		/* kmalloc_sizes.h needs L1_CACHE_BYTES */
 #include <linux/compiler.h>
+#include <linux/kmemtrace.h>
 
 /* Size description struct for general caches. */
 struct cache_sizes {
@@ -30,6 +31,8 @@ void *__kmalloc(size_t size, gfp_t flags);
 
 static inline void *kmalloc(size_t size, gfp_t flags)
 {
+	void *ret;
+	
 	if (__builtin_constant_p(size)) {
 		int i = 0;
 
@@ -50,10 +53,17 @@ static inline void *kmalloc(size_t size, gfp_t flags)
 found:
 #ifdef CONFIG_ZONE_DMA
 		if (flags & GFP_DMA)
-			return kmem_cache_alloc(malloc_sizes[i].cs_dmacachep,
-						flags);
+			ret = kmem_cache_alloc(malloc_sizes[i].cs_dmacachep,
+					       flags | __GFP_NOTRACE);
+		else
 #endif
-		return kmem_cache_alloc(malloc_sizes[i].cs_cachep, flags);
+			ret = kmem_cache_alloc(malloc_sizes[i].cs_cachep,
+					       flags | __GFP_NOTRACE);
+
+		kmemtrace_mark_alloc(KMEMTRACE_KIND_KERNEL, _THIS_IP_, ret,
+				     size, malloc_sizes[i].cs_size, flags);
+
+		return ret;
 	}
 	return __kmalloc(size, flags);
 }
diff --git a/mm/slab.c b/mm/slab.c
index 046607f..29f0599 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -111,6 +111,7 @@
 #include	<linux/rtmutex.h>
 #include	<linux/reciprocal_div.h>
 #include	<linux/debugobjects.h>
+#include	<linux/kmemtrace.h>
 
 #include	<asm/cacheflush.h>
 #include	<asm/tlbflush.h>
@@ -3621,7 +3622,12 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp)
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
 
@@ -3669,8 +3675,14 @@ out:
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
 
@@ -3718,6 +3730,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 					  void *caller)
 {
 	struct kmem_cache *cachep;
+	void *ret;
 
 	/* If you want to save a few bytes .text space: replace
 	 * __ with kmem_.
@@ -3726,12 +3739,18 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	 */
 	cachep = __find_general_cachep(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
-		return cachep;
-	return __cache_alloc(cachep, flags, caller);
+		ret = cachep;
+	else {
+		ret = __cache_alloc(cachep, flags, caller);
+		kmemtrace_mark_alloc(KMEMTRACE_KIND_KERNEL, caller, ret,
+				     size, cachep->buffer_size, flags);
+	}
+
+	return ret;
 }
 
 
-#ifdef CONFIG_DEBUG_SLAB
+#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_KMEMTRACE)
 void *__kmalloc(size_t size, gfp_t flags)
 {
 	return __do_kmalloc(size, flags, __builtin_return_address(0));
@@ -3770,6 +3789,8 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 		debug_check_no_obj_freed(objp, obj_size(cachep));
 	__cache_free(cachep, objp);
 	local_irq_restore(flags);
+
+	kmemtrace_mark_free(KMEMTRACE_KIND_CACHE, _RET_IP_, objp);
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
@@ -3796,6 +3817,8 @@ void kfree(const void *objp)
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
