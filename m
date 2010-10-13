Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2D1396B0122
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:09:42 -0400 (EDT)
Subject: [PATCH] [RFC] slub tracing: move trace calls out of always inlined
 functions to reduce kernel code size
From: Richard Kennedy <richard@rsk.demon.co.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 13 Oct 2010 17:09:38 +0100
Message-ID: <1286986178.1901.60.camel@castor.rsk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

Having the trace calls defined in the always inlined kmalloc functions
in include/linux/slub_def.h causes a lot of code duplication as the
trace functions get instantiated for each kamalloc call site. This can
simply be removed by pushing the trace calls down into the functions in
slub.c.

On my x86_64 built this patch shrinks the code size of the kernel by
approx 29K and also shrinks the code size of many modules -- too many to
list here ;)

size vmlinux.o reports
       text	   data	    bss	    dec	    hex	filename
    4777011	 602052	 763072	6142135	 5db8b7	vmlinux.o
    4747120	 602388	 763072	6112580	 5d4544	vmlinux.o.patch

The resulting kernel has had some testing & kmalloc trace still seems to
work.

This patch
- moves trace_kmalloc out of the inlined kmalloc() and pushes it down
into kmem_cache_alloc_trace() so this it only get instantiated once.

- rename kmem_cache_alloc_notrace()  to kmem_cache_alloc_trace() to
indicate that now is does have tracing. (maybe this would better being
called something like kmalloc_kmem_cache ?)

- adds a new function kmalloc_order() to handle allocation and tracing
of large allocations of page order.

- removes tracing from the inlined kmalloc_large() replacing them with a
call to kmalloc_order();

- move tracing out of inlined kmalloc_node() and pushing it down into
kmem_cache_alloc_node_trace

- rename kmem_cache_alloc_node_notrace() to
kmem_cache_alloc_node_trace()

- removes the include of trace/events/kmem.h from slub_def.h.

Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
-----
patch against v2.6.36-rc7
compiled & tested on x86_64.

Overall this lowers the overhead of having trace enabled & AFAICT seems
to still work ;)

Do you think this is the correct approach or can you suggest any better
way to do this?


regards
Richard

diffstat
 include/linux/slub_def.h |   40 ++++++++++------------------------------
 mm/slub.c                |   34 +++++++++++++++++++++++++++-------
 2 files changed, 37 insertions(+), 37 deletions(-)



diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 9f63538..314272a 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -10,9 +10,6 @@
 #include <linux/gfp.h>
 #include <linux/workqueue.h>
 #include <linux/kobject.h>
-#include <linux/kmemleak.h>
-
-#include <trace/events/kmem.h>
 
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu slab */
@@ -221,12 +218,13 @@ static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
 
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
+void *kmalloc_order(size_t size, gfp_t flags, unsigned int order);
 
 #ifdef CONFIG_TRACING
-extern void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags);
+extern void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size);
 #else
 static __always_inline void *
-kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
+kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
 	return kmem_cache_alloc(s, gfpflags);
 }
@@ -235,18 +233,11 @@ kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
 static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 {
 	unsigned int order = get_order(size);
-	void *ret = (void *) __get_free_pages(flags | __GFP_COMP, order);
-
-	kmemleak_alloc(ret, size, 1, flags);
-	trace_kmalloc(_THIS_IP_, ret, size, PAGE_SIZE << order, flags);
-
-	return ret;
+	return kmalloc_order(size, flags, order);
 }
 
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
-	void *ret;
-
 	if (__builtin_constant_p(size)) {
 		if (size > SLUB_MAX_SIZE)
 			return kmalloc_large(size, flags);
@@ -257,11 +248,7 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 			if (!s)
 				return ZERO_SIZE_PTR;
 
-			ret = kmem_cache_alloc_notrace(s, flags);
-
-			trace_kmalloc(_THIS_IP_, ret, size, s->size, flags);
-
-			return ret;
+			return kmem_cache_alloc_trace(s, flags, size);
 		}
 	}
 	return __kmalloc(size, flags);
@@ -272,14 +259,14 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node);
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 
 #ifdef CONFIG_TRACING
-extern void *kmem_cache_alloc_node_notrace(struct kmem_cache *s,
+extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 					   gfp_t gfpflags,
-					   int node);
+					   int node, size_t size);
 #else
 static __always_inline void *
-kmem_cache_alloc_node_notrace(struct kmem_cache *s,
+kmem_cache_alloc_node_trace(struct kmem_cache *s,
 			      gfp_t gfpflags,
-			      int node)
+			      int node, size_t size)
 {
 	return kmem_cache_alloc_node(s, gfpflags, node);
 }
@@ -287,8 +274,6 @@ kmem_cache_alloc_node_notrace(struct kmem_cache *s,
 
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
-	void *ret;
-
 	if (__builtin_constant_p(size) &&
 		size <= SLUB_MAX_SIZE && !(flags & SLUB_DMA)) {
 			struct kmem_cache *s = kmalloc_slab(size);
@@ -296,12 +281,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 		if (!s)
 			return ZERO_SIZE_PTR;
 
-		ret = kmem_cache_alloc_node_notrace(s, flags, node);
-
-		trace_kmalloc_node(_THIS_IP_, ret,
-				   size, s->size, flags, node);
-
-		return ret;
+		return kmem_cache_alloc_node_trace(s, flags, node, size);
 	}
 	return __kmalloc_node(size, flags, node);
 }
diff --git a/mm/slub.c b/mm/slub.c
index 13fffe1..32b89ee 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -28,6 +28,9 @@
 #include <linux/math64.h>
 #include <linux/fault-inject.h>
 
+#include <linux/kmemleak.h>
+#include <trace/events/kmem.h>
+
 /*
  * Lock order:
  *   1. slab_lock(page)
@@ -1736,13 +1739,26 @@ void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 EXPORT_SYMBOL(kmem_cache_alloc);
 
 #ifdef CONFIG_TRACING
-void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
+void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
-	return slab_alloc(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
+	void *ret = slab_alloc(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
+	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
+	return ret;
 }
-EXPORT_SYMBOL(kmem_cache_alloc_notrace);
+EXPORT_SYMBOL(kmem_cache_alloc_trace);
 #endif
 
+void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
+{
+	void *ret = (void *) __get_free_pages(flags | __GFP_COMP, order);
+
+	kmemleak_alloc(ret, size, 1, flags);
+	trace_kmalloc(_RET_IP_, ret, size, PAGE_SIZE << order, flags);
+
+	return ret;
+}
+EXPORT_SYMBOL(kmalloc_order);
+
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
@@ -1757,13 +1773,17 @@ EXPORT_SYMBOL(kmem_cache_alloc_node);
 #endif
 
 #ifdef CONFIG_TRACING
-void *kmem_cache_alloc_node_notrace(struct kmem_cache *s,
+void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 				    gfp_t gfpflags,
-				    int node)
+				    int node, size_t size)
 {
-	return slab_alloc(s, gfpflags, node, _RET_IP_);
+	void *ret = slab_alloc(s, gfpflags, node, _RET_IP_);
+
+	trace_kmalloc_node(_RET_IP_, ret,
+			   size, s->size, gfpflags, node);
+	return ret;
 }
-EXPORT_SYMBOL(kmem_cache_alloc_node_notrace);
+EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
 #endif
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
