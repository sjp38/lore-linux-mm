Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A90F25F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 05:29:23 -0400 (EDT)
Subject: Re: [PATCH] [v2] slub tracing: move trace calls out of always
 inlined functions to reduce kernel code size
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <1287049769.1909.4.camel@castor.rsk>
References: <1286986178.1901.60.camel@castor.rsk>
	 <4CB6ACB7.8060006@kernel.org>  <1287049769.1909.4.camel@castor.rsk>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Oct 2010 10:29:19 +0100
Message-ID: <1287653359.1906.13.camel@castor.rsk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

Having the trace calls defined in the always inlined kmalloc functions
in include/linux/slub_def.h causes a lot of code duplication as the
trace functions get instantiated for each kamalloc call site. This can
simply be removed by pushing the trace calls down into the functions in
slub.c.

On my x86_64 built this patch shrinks the code size of the kernel by
approx 36K and also shrinks the code size of many modules -- too many to
list here ;)

size vmlinux (2.6.36) reports
       text        data     bss     dec     hex filename
    5410611	 743172	 828928	6982711	 6a8c37	vmlinux
    5373738	 744244	 828928	6946910	 6a005e	vmlinux + patch

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

v2
- keep kmalloc_order_trace inline when !CONFIG_TRACE

Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>

----
patch against v2.6.36
compiled & tested on x86_64

regards
Richard

 include/linux/slub_def.h |   55 ++++++++++++++++++++++-------------------------
 mm/slub.c                |   30 +++++++++++++++++++------
 2 files changed, 49 insertions(+), 36 deletions(-)



diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 9f63538..d5a4ced 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -10,9 +10,8 @@
 #include <linux/gfp.h>
 #include <linux/workqueue.h>
 #include <linux/kobject.h>
-#include <linux/kmemleak.h>
 
-#include <trace/events/kmem.h>
+#include <linux/kmemleak.h>
 
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu slab */
@@ -222,31 +221,40 @@ static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
+static __always_inline void *
+kmalloc_order(size_t size, gfp_t flags, unsigned int order)
+{
+	void *ret = (void *) __get_free_pages(flags | __GFP_COMP, order);
+	kmemleak_alloc(ret, size, 1, flags);
+	return ret;
+}
+
 #ifdef CONFIG_TRACING
-extern void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags);
+extern void *
+kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size);
+extern void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order);
 #else
 static __always_inline void *
-kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
+kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
 	return kmem_cache_alloc(s, gfpflags);
 }
+
+static __always_inline void *
+kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
+{
+	return kmalloc_order(size, flags, order);
+}
 #endif
 
 static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 {
 	unsigned int order = get_order(size);
-	void *ret = (void *) __get_free_pages(flags | __GFP_COMP, order);
-
-	kmemleak_alloc(ret, size, 1, flags);
-	trace_kmalloc(_THIS_IP_, ret, size, PAGE_SIZE << order, flags);
-
-	return ret;
+	return kmalloc_order_trace(size, flags, order);
 }
 
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
-	void *ret;
-
 	if (__builtin_constant_p(size)) {
 		if (size > SLUB_MAX_SIZE)
 			return kmalloc_large(size, flags);
@@ -257,11 +265,7 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
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
@@ -272,14 +276,14 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node);
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
@@ -287,8 +291,6 @@ kmem_cache_alloc_node_notrace(struct kmem_cache *s,
 
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
-	void *ret;
-
 	if (__builtin_constant_p(size) &&
 		size <= SLUB_MAX_SIZE && !(flags & SLUB_DMA)) {
 			struct kmem_cache *s = kmalloc_slab(size);
@@ -296,12 +298,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
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
index 13fffe1..aab2165 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -28,6 +28,8 @@
 #include <linux/math64.h>
 #include <linux/fault-inject.h>
 
+#include <trace/events/kmem.h>
+
 /*
  * Lock order:
  *   1. slab_lock(page)
@@ -1736,11 +1738,21 @@ void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 EXPORT_SYMBOL(kmem_cache_alloc);
 
 #ifdef CONFIG_TRACING
-void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
+void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
+{
+	void *ret = slab_alloc(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
+	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
+	return ret;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_trace);
+
+void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
 {
-	return slab_alloc(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
+	void *ret = kmalloc_order(size, flags, order);
+	trace_kmalloc(_RET_IP_, ret, size, PAGE_SIZE << order, flags);
+	return ret;
 }
-EXPORT_SYMBOL(kmem_cache_alloc_notrace);
+EXPORT_SYMBOL(kmalloc_order_trace);
 #endif
 
 #ifdef CONFIG_NUMA
@@ -1757,13 +1769,17 @@ EXPORT_SYMBOL(kmem_cache_alloc_node);
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
