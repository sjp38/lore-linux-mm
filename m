Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D30226002CC
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:18:56 -0400 (EDT)
Message-Id: <20100521211537.530913777@quilx.com>
Date: Fri, 21 May 2010 16:14:53 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC V2 SLEB 01/14] slab: Introduce a constant for a unspecified node.
References: <20100521211452.659982351@quilx.com>
Content-Disposition: inline; filename=slab_node_unspecified
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kmalloc_node() and friends can be passed a constant -1 to indicate
that no choice was made for the node from which the object needs to
come.

Add a constant for this.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slab.h |    2 ++
 mm/slub.c            |   10 +++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2010-04-27 12:31:57.000000000 -0500
+++ linux-2.6/include/linux/slab.h	2010-04-27 12:32:26.000000000 -0500
@@ -92,6 +92,8 @@
 #define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
 				(unsigned long)ZERO_SIZE_PTR)
 
+#define SLAB_NODE_UNSPECIFIED (-1L)
+
 /*
  * struct kmem_cache related prototypes
  */
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-04-27 12:32:30.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-04-27 12:33:37.000000000 -0500
@@ -1081,7 +1081,7 @@ static inline struct page *alloc_slab_pa
 
 	flags |= __GFP_NOTRACK;
 
-	if (node == -1)
+	if (node == SLAB_NODE_UNSPECIFIED)
 		return alloc_pages(flags, order);
 	else
 		return alloc_pages_node(node, flags, order);
@@ -1731,7 +1731,7 @@ static __always_inline void *slab_alloc(
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	void *ret = slab_alloc(s, gfpflags, -1, _RET_IP_);
+	void *ret = slab_alloc(s, gfpflags, SLAB_NODE_UNSPECIFIED, _RET_IP_);
 
 	trace_kmem_cache_alloc(_RET_IP_, ret, s->objsize, s->size, gfpflags);
 
@@ -1742,7 +1742,7 @@ EXPORT_SYMBOL(kmem_cache_alloc);
 #ifdef CONFIG_TRACING
 void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
 {
-	return slab_alloc(s, gfpflags, -1, _RET_IP_);
+	return slab_alloc(s, gfpflags, SLAB_NODE_UNSPECIFIED, _RET_IP_);
 }
 EXPORT_SYMBOL(kmem_cache_alloc_notrace);
 #endif
@@ -2740,7 +2740,7 @@ void *__kmalloc(size_t size, gfp_t flags
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, flags, -1, _RET_IP_);
+	ret = slab_alloc(s, flags, SLAB_NODE_UNSPECIFIED, _RET_IP_);
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
@@ -3324,7 +3324,7 @@ void *__kmalloc_track_caller(size_t size
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	ret = slab_alloc(s, gfpflags, -1, caller);
+	ret = slab_alloc(s, gfpflags, SLAB_NODE_UNSPECIFIED, caller);
 
 	/* Honor the call site pointer we recieved. */
 	trace_kmalloc(caller, ret, size, s->size, gfpflags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
