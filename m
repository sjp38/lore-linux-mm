Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C03D6B024B
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 15:06:19 -0400 (EDT)
Date: Tue, 15 Jun 2010 14:03:02 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: slub: Use a constant for a unspecified node.
Message-ID: <alpine.DEB.2.00.1006151401330.10865@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Subject: slub: Use a constant for a unspecified node.

kmalloc_node() and friends can be passed a constant -1 to indicate
that no choice was made for the node from which the object needs to
come.

Use NUMA_NO_NODE instead of -1.

Signed-off-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slab.h |    2 ++
 mm/slub.c            |   10 +++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-06-01 08:51:39.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-06-01 08:58:46.000000000 -0500
@@ -1073,7 +1073,7 @@ static inline struct page *alloc_slab_pa

 	flags |= __GFP_NOTRACK;

-	if (node == -1)
+	if (node == NUMA_NO_NODE)
 		return alloc_pages(flags, order);
 	else
 		return alloc_pages_exact_node(node, flags, order);
@@ -1727,7 +1727,7 @@ static __always_inline void *slab_alloc(

 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	void *ret = slab_alloc(s, gfpflags, -1, _RET_IP_);
+	void *ret = slab_alloc(s, gfpflags, NUMA_NO_NODE, _RET_IP_);

 	trace_kmem_cache_alloc(_RET_IP_, ret, s->objsize, s->size, gfpflags);

@@ -1738,7 +1738,7 @@ EXPORT_SYMBOL(kmem_cache_alloc);
 #ifdef CONFIG_TRACING
 void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
 {
-	return slab_alloc(s, gfpflags, -1, _RET_IP_);
+	return slab_alloc(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
 }
 EXPORT_SYMBOL(kmem_cache_alloc_notrace);
 #endif
@@ -2728,7 +2728,7 @@ void *__kmalloc(size_t size, gfp_t flags
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;

-	ret = slab_alloc(s, flags, -1, _RET_IP_);
+	ret = slab_alloc(s, flags, NUMA_NO_NODE, _RET_IP_);

 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);

@@ -3312,7 +3312,7 @@ void *__kmalloc_track_caller(size_t size
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;

-	ret = slab_alloc(s, gfpflags, -1, caller);
+	ret = slab_alloc(s, gfpflags, NUMA_NO_NODE, caller);

 	/* Honor the call site pointer we recieved. */
 	trace_kmalloc(caller, ret, size, s->size, gfpflags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
