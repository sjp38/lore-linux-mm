Received: by ti-out-0910.google.com with SMTP id j3so992596tid.8
        for <linux-mm@kvack.org>; Tue, 22 Jul 2008 11:33:29 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [RFC PATCH 3/4] kmemtrace: SLUB hooks.
Date: Tue, 22 Jul 2008 21:31:32 +0300
Message-Id: <1216751493-13785-4-git-send-email-eduard.munteanu@linux360.ro>
In-Reply-To: <1216751493-13785-3-git-send-email-eduard.munteanu@linux360.ro>
References: <1216751493-13785-1-git-send-email-eduard.munteanu@linux360.ro>
 <1216751493-13785-2-git-send-email-eduard.munteanu@linux360.ro>
 <1216751493-13785-3-git-send-email-eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.co
List-ID: <linux-mm.kvack.org>

This adds hooks for the SLUB allocator, to allow tracing with kmemtrace.

Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 include/linux/slub_def.h |   53 ++++++++++++++++++++++++++++++++++--
 mm/slub.c                |   66 +++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 110 insertions(+), 9 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d117ea2..d77012a 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -10,6 +10,7 @@
 #include <linux/gfp.h>
 #include <linux/workqueue.h>
 #include <linux/kobject.h>
+#include <linux/kmemtrace.h>
 
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu slab */
@@ -203,13 +204,31 @@ static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
+#ifdef CONFIG_KMEMTRACE
+extern void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags);
+#else
+static __always_inline void *
+kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
+{
+	return kmem_cache_alloc(s, gfpflags);
+}
+#endif
+
 static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 {
-	return (void *)__get_free_pages(flags | __GFP_COMP, get_order(size));
+	unsigned int order = get_order(size);
+	void *ret = (void *) __get_free_pages(flags, order);
+
+	kmemtrace_mark_alloc(KMEMTRACE_TYPE_KMALLOC, _THIS_IP_, ret,
+			     size, PAGE_SIZE << order, flags);
+
+	return ret;
 }
 
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
+	void *ret;
+
 	if (__builtin_constant_p(size)) {
 		if (size > PAGE_SIZE)
 			return kmalloc_large(size, flags);
@@ -220,7 +239,13 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 			if (!s)
 				return ZERO_SIZE_PTR;
 
-			return kmem_cache_alloc(s, flags);
+			ret = kmem_cache_alloc_notrace(s, flags);
+
+			kmemtrace_mark_alloc(KMEMTRACE_TYPE_KMALLOC,
+					     _THIS_IP_, ret,
+					     size, s->size, flags);
+
+			return ret;
 		}
 	}
 	return __kmalloc(size, flags);
@@ -230,8 +255,24 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 
+#ifdef CONFIG_KMEMTRACE
+extern void *kmem_cache_alloc_node_notrace(struct kmem_cache *s,
+					   gfp_t gfpflags,
+					   int node);
+#else
+static __always_inline void *
+kmem_cache_alloc_node_notrace(struct kmem_cache *s,
+			      gfp_t gfpflags,
+			      int node)
+{
+	return kmem_cache_alloc_node(s, gfpflags, node);
+}
+#endif
+
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
+	void *ret;
+
 	if (__builtin_constant_p(size) &&
 		size <= PAGE_SIZE && !(flags & SLUB_DMA)) {
 			struct kmem_cache *s = kmalloc_slab(size);
@@ -239,7 +280,13 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 		if (!s)
 			return ZERO_SIZE_PTR;
 
-		return kmem_cache_alloc_node(s, flags, node);
+		ret = kmem_cache_alloc_node_notrace(s, flags, node);
+
+		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_KMALLOC,
+					  _THIS_IP_, ret,
+					  size, s->size, flags, node);
+
+		return ret;
 	}
 	return __kmalloc_node(size, flags, node);
 }
diff --git a/mm/slub.c b/mm/slub.c
index 315c392..940145f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -23,6 +23,7 @@
 #include <linux/kallsyms.h>
 #include <linux/memory.h>
 #include <linux/math64.h>
+#include <linux/kmemtrace.h>
 
 /*
  * Lock order:
@@ -1652,18 +1653,47 @@ static __always_inline void *slab_alloc(struct kmem_cache *s,
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
+	void *ret = slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
+
+	kmemtrace_mark_alloc(KMEMTRACE_TYPE_CACHE, _RET_IP_, ret,
+			     s->objsize, s->size, gfpflags);
+
+	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
+#ifdef CONFIG_KMEMTRACE
+void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
+{
+	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
+}
+EXPORT_SYMBOL(kmem_cache_alloc_notrace);
+#endif
+
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
-	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
+	void *ret = slab_alloc(s, gfpflags, node,
+			       __builtin_return_address(0));
+
+	kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_CACHE, _RET_IP_, ret,
+				  s->objsize, s->size, gfpflags, node);
+
+	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 #endif
 
+#ifdef CONFIG_KMEMTRACE
+void *kmem_cache_alloc_node_notrace(struct kmem_cache *s,
+				    gfp_t gfpflags,
+				    int node)
+{
+	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
+}
+EXPORT_SYMBOL(kmem_cache_alloc_node_notrace);
+#endif
+
 /*
  * Slow patch handling. This may still be called frequently since objects
  * have a longer lifetime than the cpu slabs in most processing loads.
@@ -1771,6 +1801,8 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
 	page = virt_to_head_page(x);
 
 	slab_free(s, page, x, __builtin_return_address(0));
+
+	kmemtrace_mark_free(KMEMTRACE_TYPE_CACHE, _RET_IP_, x);
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
@@ -2676,6 +2708,7 @@ static struct kmem_cache *get_slab(size_t size, gfp_t flags)
 void *__kmalloc(size_t size, gfp_t flags)
 {
 	struct kmem_cache *s;
+	void *ret;
 
 	if (unlikely(size > PAGE_SIZE))
 		return kmalloc_large(size, flags);
@@ -2685,7 +2718,12 @@ void *__kmalloc(size_t size, gfp_t flags)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	return slab_alloc(s, flags, -1, __builtin_return_address(0));
+	ret = slab_alloc(s, flags, -1, __builtin_return_address(0));
+
+	kmemtrace_mark_alloc(KMEMTRACE_TYPE_KMALLOC, _RET_IP_, ret,
+			     size, s->size, flags);
+
+	return ret;
 }
 EXPORT_SYMBOL(__kmalloc);
 
@@ -2704,16 +2742,30 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	struct kmem_cache *s;
+	void *ret;
 
-	if (unlikely(size > PAGE_SIZE))
-		return kmalloc_large_node(size, flags, node);
+	if (unlikely(size > PAGE_SIZE)) {
+		ret = kmalloc_large_node(size, flags, node);
+
+		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_KMALLOC,
+					  _RET_IP_, ret,
+					  size, PAGE_SIZE << get_order(size),
+					  flags, node);
+
+		return ret;
+	}
 
 	s = get_slab(size, flags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	return slab_alloc(s, flags, node, __builtin_return_address(0));
+	ret = slab_alloc(s, flags, node, __builtin_return_address(0));
+
+	kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_KMALLOC, _RET_IP_, ret,
+				  size, s->size, flags, node);
+
+	return ret;
 }
 EXPORT_SYMBOL(__kmalloc_node);
 #endif
@@ -2771,6 +2823,8 @@ void kfree(const void *x)
 		return;
 	}
 	slab_free(page->slab, page, object, __builtin_return_address(0));
+
+	kmemtrace_mark_free(KMEMTRACE_TYPE_KMALLOC, _RET_IP_, x);
 }
 EXPORT_SYMBOL(kfree);
 
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
