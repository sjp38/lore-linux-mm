Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-4.corp.sgi.com (Postfix) with ESMTP id 3CDC661B75
	for <linux-mm@kvack.org>; Fri,  6 Jul 2007 12:50:53 -0700 (PDT)
Received: from clameter (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1I6tpN-0006KX-00
	for <linux-mm@kvack.org>; Fri, 06 Jul 2007 12:50:53 -0700
Date: Fri, 6 Jul 2007 12:50:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Do not use length parameter in slab_alloc() (fwd)
Message-ID: <Pine.LNX.4.64.0707061250450.24321@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


---------- Forwarded message ----------
Date: Fri, 6 Jul 2007 12:47:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
To: akpm@linux-foundation.org
Subject: SLUB: Do not use length parameter in slab_alloc()

We can get to the length of the object through the kmem_cache_structure.
The additional parameter does no good and causes the compiler to generate
bad code.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

Index: linux-2.6.22-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slub.c	2007-07-04 13:32:41.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slub.c	2007-07-04 13:36:54.000000000 -0700
@@ -1551,7 +1551,7 @@ debug:
  * Otherwise we can simply pick the next object from the lockless free list.
  */
 static void __always_inline *slab_alloc(struct kmem_cache *s,
-		gfp_t gfpflags, int node, void *addr, int length)
+		gfp_t gfpflags, int node, void *addr)
 {
 	struct page *page;
 	void **object;
@@ -1571,23 +1571,21 @@ static void __always_inline *slab_alloc(
 	local_irq_restore(flags);
 
 	if (unlikely((gfpflags & __GFP_ZERO) && object))
-		memset(object, 0, length);
+		memset(object, 0, s->objsize);
 
 	return object;
 }
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	return slab_alloc(s, gfpflags, -1,
-			__builtin_return_address(0), s->objsize);
+	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
-	return slab_alloc(s, gfpflags, node,
-		__builtin_return_address(0), s->objsize);
+	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 #endif
@@ -2379,7 +2377,7 @@ void *__kmalloc(size_t size, gfp_t flags
 	if (ZERO_OR_NULL_PTR(s))
 		return s;
 
-	return slab_alloc(s, flags, -1, __builtin_return_address(0), size);
+	return slab_alloc(s, flags, -1, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(__kmalloc);
 
@@ -2391,7 +2389,7 @@ void *__kmalloc_node(size_t size, gfp_t 
 	if (ZERO_OR_NULL_PTR(s))
 		return s;
 
-	return slab_alloc(s, flags, node, __builtin_return_address(0), size);
+	return slab_alloc(s, flags, node, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(__kmalloc_node);
 #endif
@@ -2732,7 +2730,7 @@ void *kmem_cache_zalloc(struct kmem_cach
 {
 	void *x;
 
-	x = slab_alloc(s, flags, -1, __builtin_return_address(0), 0);
+	x = slab_alloc(s, flags, -1, __builtin_return_address(0));
 	if (x)
 		memset(x, 0, s->objsize);
 	return x;
@@ -2782,7 +2780,7 @@ void *__kmalloc_track_caller(size_t size
 	if (ZERO_OR_NULL_PTR(s))
 		return s;
 
-	return slab_alloc(s, gfpflags, -1, caller, size);
+	return slab_alloc(s, gfpflags, -1, caller);
 }
 
 void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
@@ -2793,7 +2791,7 @@ void *__kmalloc_node_track_caller(size_t
 	if (ZERO_OR_NULL_PTR(s))
 		return s;
 
-	return slab_alloc(s, gfpflags, node, caller, size);
+	return slab_alloc(s, gfpflags, node, caller);
 }
 
 #if defined(CONFIG_SYSFS) && defined(CONFIG_SLUB_DEBUG)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
