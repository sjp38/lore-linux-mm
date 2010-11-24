Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BB7F46B004A
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 16:27:19 -0500 (EST)
Message-Id: <20101124212717.158709480@goodmis.org>
Date: Wed, 24 Nov 2010 16:23:34 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: [RFC][PATCH 1/2] [PATCH 1/2] tracing/slab: Move kmalloc tracepoint out of inline code
References: <20101124212333.808256210@goodmis.org>
Content-Disposition: inline; filename=0001-tracing-slab-Move-kmalloc-tracepoint-out-of-inline-c.patch
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

From: Steven Rostedt <srostedt@redhat.com>

The tracepoint for kmalloc is in the slab inlined code which causes
every instance of kmalloc to have the tracepoint.

This patch moves the tracepoint out of the inline code to the
slab C file, which removes a large number of inlined trace
points.

  objdump -dr vmlinux.slab| grep 'jmpq.*<trace_kmalloc' |wc -l
213
  objdump -dr vmlinux.slab.patched| grep 'jmpq.*<trace_kmalloc' |wc -l
1

This also has a nice impact on size.

   text	   data	    bss	    dec	    hex	filename
7023060	2121564	2482432	11627056	 b16a30	vmlinux.slab
6970579	2109772	2482432	11562783	 b06f1f	vmlinux.slab.patched

Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 include/linux/slab_def.h |   33 +++++++++++++--------------------
 mm/slab.c                |   38 +++++++++++++++++++++++---------------
 2 files changed, 36 insertions(+), 35 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 791a502..83203ae 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -138,11 +138,12 @@ void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
 #ifdef CONFIG_TRACING
-extern void *kmem_cache_alloc_notrace(struct kmem_cache *cachep, gfp_t flags);
+extern void *kmem_cache_alloc_trace(size_t size,
+				    struct kmem_cache *cachep, gfp_t flags);
 extern size_t slab_buffer_size(struct kmem_cache *cachep);
 #else
 static __always_inline void *
-kmem_cache_alloc_notrace(struct kmem_cache *cachep, gfp_t flags)
+kmem_cache_alloc_trace(size_t size, struct kmem_cache *cachep, gfp_t flags)
 {
 	return kmem_cache_alloc(cachep, flags);
 }
@@ -179,10 +180,7 @@ found:
 #endif
 			cachep = malloc_sizes[i].cs_cachep;
 
-		ret = kmem_cache_alloc_notrace(cachep, flags);
-
-		trace_kmalloc(_THIS_IP_, ret,
-			      size, slab_buffer_size(cachep), flags);
+		ret = kmem_cache_alloc_trace(size, cachep, flags);
 
 		return ret;
 	}
@@ -194,14 +192,16 @@ extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
 extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 
 #ifdef CONFIG_TRACING
-extern void *kmem_cache_alloc_node_notrace(struct kmem_cache *cachep,
-					   gfp_t flags,
-					   int nodeid);
+extern void *kmem_cache_alloc_node_trace(size_t size,
+					 struct kmem_cache *cachep,
+					 gfp_t flags,
+					 int nodeid);
 #else
 static __always_inline void *
-kmem_cache_alloc_node_notrace(struct kmem_cache *cachep,
-			      gfp_t flags,
-			      int nodeid)
+kmem_cache_alloc_node_trace(size_t size,
+			    struct kmem_cache *cachep,
+			    gfp_t flags,
+			    int nodeid)
 {
 	return kmem_cache_alloc_node(cachep, flags, nodeid);
 }
@@ -210,7 +210,6 @@ kmem_cache_alloc_node_notrace(struct kmem_cache *cachep,
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	struct kmem_cache *cachep;
-	void *ret;
 
 	if (__builtin_constant_p(size)) {
 		int i = 0;
@@ -234,13 +233,7 @@ found:
 #endif
 			cachep = malloc_sizes[i].cs_cachep;
 
-		ret = kmem_cache_alloc_node_notrace(cachep, flags, node);
-
-		trace_kmalloc_node(_THIS_IP_, ret,
-				   size, slab_buffer_size(cachep),
-				   flags, node);
-
-		return ret;
+		return kmem_cache_alloc_node_trace(size, cachep, flags, node);
 	}
 	return __kmalloc_node(size, flags, node);
 }
diff --git a/mm/slab.c b/mm/slab.c
index b1e40da..dfcc888 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3653,11 +3653,18 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 EXPORT_SYMBOL(kmem_cache_alloc);
 
 #ifdef CONFIG_TRACING
-void *kmem_cache_alloc_notrace(struct kmem_cache *cachep, gfp_t flags)
+void *
+kmem_cache_alloc_trace(size_t size, struct kmem_cache *cachep, gfp_t flags)
 {
-	return __cache_alloc(cachep, flags, __builtin_return_address(0));
+	void *ret;
+
+	ret = __cache_alloc(cachep, flags, __builtin_return_address(0));
+
+	trace_kmalloc(_RET_IP_, ret,
+		      size, slab_buffer_size(cachep), flags);
+	return ret;
 }
-EXPORT_SYMBOL(kmem_cache_alloc_notrace);
+EXPORT_SYMBOL(kmem_cache_alloc_trace);
 #endif
 
 /**
@@ -3705,31 +3712,32 @@ void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
 #ifdef CONFIG_TRACING
-void *kmem_cache_alloc_node_notrace(struct kmem_cache *cachep,
-				    gfp_t flags,
-				    int nodeid)
+void *kmem_cache_alloc_node_trace(size_t size,
+				  struct kmem_cache *cachep,
+				  gfp_t flags,
+				  int nodeid)
 {
-	return __cache_alloc_node(cachep, flags, nodeid,
+	void *ret;
+
+	ret = __cache_alloc_node(cachep, flags, nodeid,
 				  __builtin_return_address(0));
+	trace_kmalloc_node(_RET_IP_, ret,
+			   size, slab_buffer_size(cachep),
+			   flags, nodeid);
+	return ret;
 }
-EXPORT_SYMBOL(kmem_cache_alloc_node_notrace);
+EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
 #endif
 
 static __always_inline void *
 __do_kmalloc_node(size_t size, gfp_t flags, int node, void *caller)
 {
 	struct kmem_cache *cachep;
-	void *ret;
 
 	cachep = kmem_find_general_cachep(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	ret = kmem_cache_alloc_node_notrace(cachep, flags, node);
-
-	trace_kmalloc_node((unsigned long) caller, ret,
-			   size, cachep->buffer_size, flags, node);
-
-	return ret;
+	return kmem_cache_alloc_node_trace(size, cachep, flags, node);
 }
 
 #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
