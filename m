Date: Fri, 4 Aug 2006 17:15:46 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/2] slab: optimize kmalloc_node the same way as kmalloc
Message-ID: <20060804151546.GB29422@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, viro@zeniv.linux.org.uk
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2006-07-26 15:30:49.000000000 +0200
+++ linux-2.6/include/linux/slab.h	2006-07-26 15:42:49.000000000 +0200
@@ -213,7 +213,30 @@
 
 #ifdef CONFIG_NUMA
 extern void *kmem_cache_alloc_node(kmem_cache_t *, gfp_t flags, int node);
-extern void *kmalloc_node(size_t size, gfp_t flags, int node);
+extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
+
+static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	if (__builtin_constant_p(size)) {
+		int i = 0;
+#define CACHE(x) \
+		if (size <= x) \
+			goto found; \
+		else \
+			i++;
+#include "kmalloc_sizes.h"
+#undef CACHE
+		{
+			extern void __you_cannot_kmalloc_that_much(void);
+			__you_cannot_kmalloc_that_much();
+		}
+found:
+		return kmem_cache_alloc_node((flags & GFP_DMA) ?
+			malloc_sizes[i].cs_dmacachep :
+			malloc_sizes[i].cs_cachep, flags, node);
+	}
+	return __kmalloc_node(size, flags, node);
+}
 #else
 static inline void *kmem_cache_alloc_node(kmem_cache_t *cachep, gfp_t flags, int node)
 {
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2006-07-26 15:25:28.000000000 +0200
+++ linux-2.6/mm/slab.c	2006-07-26 15:42:49.000000000 +0200
@@ -3317,7 +3317,7 @@
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
-void *kmalloc_node(size_t size, gfp_t flags, int node)
+void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	struct kmem_cache *cachep;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
