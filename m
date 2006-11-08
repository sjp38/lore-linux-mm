Date: Wed, 8 Nov 2006 16:54:44 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 1/3]: leak tracking for kmalloc node
In-Reply-To: <4551E795.3090805@shadowen.org>
Message-ID: <Pine.LNX.4.64.0611081652020.13867@sbz-30.cs.Helsinki.FI>
References: <20061030141454.GB7164@lst.de> <84144f020610300632i799214a6p255e1690a93a95d4@mail.gmail.com>
 <4551E795.3090805@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andy,

On Wed, 8 Nov 2006, Andy Whitcroft wrote:
> I can give this a test, what is it based on...

While you are at it, could you please give Christoph's NUMA leak tracking 
patch a spin too? I have included a rediffed version of it on top of 
my alloc path cleanup patch. Thanks!

			Pekka

[PATCH] slab: leak tracking for kmalloc node

From: Christoph Hellwig <hch@lst.de>

If we want to use the node-aware kmalloc in __alloc_skb we need
the tracker is responsible for leak tracking magic for it.  This
patch implements it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---

 include/linux/slab.h |   23 +++++++++++++++++++++++
 mm/slab.c            |   28 +++++++++++++++++++++++++---
 2 files changed, 48 insertions(+), 3 deletions(-)

Index: 2.6/include/linux/slab.h
===================================================================
--- 2.6.orig/include/linux/slab.h
+++ 2.6/include/linux/slab.h
@@ -236,7 +236,25 @@ found:
 	}
 	return __kmalloc_node(size, flags, node);
 }
+
+/*
+ * kmalloc_node_track_caller is a special version of kmalloc_node that
+ * records the calling function of the routine calling it for slab leak
+ * tracking instead of just the calling function (confusing, eh?).
+ * It's useful when the call to kmalloc_node comes from a widely-used
+ * standard allocator where we care about the real place the memory
+ * allocation request comes from.
+ */
+#ifndef CONFIG_DEBUG_SLAB
+#define kmalloc_node_track_caller(size, flags, node) \
+	__kmalloc_node(size, flags, node)
 #else
+extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, void *);
+#define kmalloc_node_track_caller(size, flags, node) \
+	__kmalloc_node_track_caller(size, flags, node, \
+			__builtin_return_address(0))
+#endif
+#else /* CONFIG_NUMA */
 static inline void *kmem_cache_alloc_node(kmem_cache_t *cachep, gfp_t flags, int node)
 {
 	return kmem_cache_alloc(cachep, flags);
@@ -245,6 +263,9 @@ static inline void *kmalloc_node(size_t 
 {
 	return kmalloc(size, flags);
 }
+
+#define kmalloc_node_track_caller(size, flags, node) \
+	kmalloc_track_caller(size, flags)
 #endif
 
 extern int FASTCALL(kmem_cache_reap(int));
@@ -283,6 +304,8 @@ static inline void *kcalloc(size_t n, si
 #define kzalloc(s, f) __kzalloc(s, f)
 #define kmalloc_track_caller kmalloc
 
+#define kmalloc_node_track_caller kmalloc_node
+
 #endif /* CONFIG_SLOB */
 
 /* System wide caches */
Index: 2.6/mm/slab.c
===================================================================
--- 2.6.orig/mm/slab.c
+++ 2.6/mm/slab.c
@@ -3478,17 +3478,39 @@ void *kmem_cache_alloc_node(struct kmem_
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
-void *__kmalloc_node(size_t size, gfp_t flags, int node)
+static __always_inline void *__do_kmalloc_node(size_t size, gfp_t flags,
+					       int node, void *caller)
 {
 	struct kmem_cache *cachep;
 
 	cachep = kmem_find_general_cachep(size, flags);
 	if (unlikely(cachep == NULL))
 		return NULL;
-	return kmem_cache_alloc_node(cachep, flags, node);
+	return cache_alloc(cachep, flags, node, caller);
+}
+
+#ifdef CONFIG_DEBUG_SLAB
+void *__kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return __do_kmalloc_node(size, flags, node,
+			__builtin_return_address(0));
 }
 EXPORT_SYMBOL(__kmalloc_node);
-#endif
+
+void *__kmalloc_node_track_caller(size_t size, gfp_t flags,
+		int node, void *caller)
+{
+	return __do_kmalloc_node(size, flags, node, caller);
+}
+EXPORT_SYMBOL(__kmalloc_node_track_caller);
+#else
+void *__kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return __do_kmalloc_node(size, flags, node, NULL);
+}
+EXPORT_SYMBOL(__kmalloc_node);
+#endif /* CONFIG_DEBUG_SLAB */
+#endif /* CONFIG_NUMA */
 
 /**
  * __do_kmalloc - allocate memory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
