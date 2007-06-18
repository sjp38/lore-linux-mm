Message-Id: <20070618095914.332369986@sgi.com>
References: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:58:42 -0700
From: clameter@sgi.com
Subject: [patch 04/26] Slab allocators: Support __GFP_ZERO in all allocators.
Content-Disposition: inline; filename=slab_gfpzero
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

A kernel convention for many allocators is that if __GFP_ZERO is passed to
an allocator then the allocated memory should be zeroed.

This is currently not supported by the slab allocators. The inconsistency
makes it difficult to implement in derived allocators such as in the uncached
allocator and the pool allocators.

In addition the support zeroed allocations in the slab allocators does not
have a consistent API. There are no zeroing allocator functions for NUMA node
placement (kmalloc_node, kmem_cache_alloc_node). The zeroing allocations are
only provided for default allocs (kzalloc, kmem_cache_zalloc_node).
__GFP_ZERO will make zeroing universally available and does not require any
addititional functions.

So add the necessary logic to all slab allocators to support __GFP_ZERO.

The code is added to the hot path. The gfp flags are on the stack
and so the cacheline is readily available for checking if we want a zeroed
object.

Zeroing while allocating is now a frequent operation and we seem to be
gradually approaching a 1-1 parity between zeroing and not zeroing allocs.
The current tree has 3476 uses of kmalloc vs 2731 uses of kzalloc.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slab.c |    8 +++++++-
 mm/slob.c |    2 ++
 mm/slub.c |   24 +++++++++++++++---------
 3 files changed, 24 insertions(+), 10 deletions(-)

Index: linux-2.6.22-rc4-mm2/mm/slob.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slob.c	2007-06-17 22:30:01.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slob.c	2007-06-17 22:30:38.000000000 -0700
@@ -293,6 +293,8 @@ static void *slob_alloc(size_t size, gfp
 		BUG_ON(!b);
 		spin_unlock_irqrestore(&slob_lock, flags);
 	}
+	if (unlikely((gfp & __GFP_ZERO) && b))
+		memset(b, 0, size);
 	return b;
 }
 
Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-17 22:30:01.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-17 22:31:41.000000000 -0700
@@ -1087,7 +1087,7 @@ static struct page *new_slab(struct kmem
 	void *last;
 	void *p;
 
-	BUG_ON(flags & ~(GFP_DMA | GFP_LEVEL_MASK));
+	BUG_ON(flags & ~(GFP_DMA | __GFP_ZERO | GFP_LEVEL_MASK));
 
 	if (flags & __GFP_WAIT)
 		local_irq_enable();
@@ -1550,7 +1550,7 @@ debug:
  * Otherwise we can simply pick the next object from the lockless free list.
  */
 static void __always_inline *slab_alloc(struct kmem_cache *s,
-				gfp_t gfpflags, int node, void *addr)
+		gfp_t gfpflags, int node, void *addr, int length)
 {
 	struct page *page;
 	void **object;
@@ -1568,19 +1568,25 @@ static void __always_inline *slab_alloc(
 		page->lockless_freelist = object[page->offset];
 	}
 	local_irq_restore(flags);
+
+	if (unlikely((gfpflags & __GFP_ZERO) && object))
+		memset(object, 0, length);
+
 	return object;
 }
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
+	return slab_alloc(s, gfpflags, -1,
+			__builtin_return_address(0), s->objsize);
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
-	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
+	return slab_alloc(s, gfpflags, node,
+		__builtin_return_address(0), s->objsize);
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 #endif
@@ -2327,7 +2333,7 @@ void *__kmalloc(size_t size, gfp_t flags
 	if (ZERO_OR_NULL_PTR(s))
 		return s;
 
-	return slab_alloc(s, flags, -1, __builtin_return_address(0));
+	return slab_alloc(s, flags, -1, __builtin_return_address(0), size);
 }
 EXPORT_SYMBOL(__kmalloc);
 
@@ -2339,7 +2345,7 @@ void *__kmalloc_node(size_t size, gfp_t 
 	if (ZERO_OR_NULL_PTR(s))
 		return s;
 
-	return slab_alloc(s, flags, node, __builtin_return_address(0));
+	return slab_alloc(s, flags, node, __builtin_return_address(0), size);
 }
 EXPORT_SYMBOL(__kmalloc_node);
 #endif
@@ -2662,7 +2668,7 @@ void *kmem_cache_zalloc(struct kmem_cach
 {
 	void *x;
 
-	x = slab_alloc(s, flags, -1, __builtin_return_address(0));
+	x = slab_alloc(s, flags, -1, __builtin_return_address(0), 0);
 	if (x)
 		memset(x, 0, s->objsize);
 	return x;
@@ -2712,7 +2718,7 @@ void *__kmalloc_track_caller(size_t size
 	if (ZERO_OR_NULL_PTR(s))
 		return s;
 
-	return slab_alloc(s, gfpflags, -1, caller);
+	return slab_alloc(s, gfpflags, -1, caller, size);
 }
 
 void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
@@ -2723,7 +2729,7 @@ void *__kmalloc_node_track_caller(size_t
 	if (ZERO_OR_NULL_PTR(s))
 		return s;
 
-	return slab_alloc(s, gfpflags, node, caller);
+	return slab_alloc(s, gfpflags, node, caller, size);
 }
 
 #if defined(CONFIG_SYSFS) && defined(CONFIG_SLUB_DEBUG)
Index: linux-2.6.22-rc4-mm2/mm/slab.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slab.c	2007-06-17 22:30:01.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slab.c	2007-06-17 22:30:38.000000000 -0700
@@ -2734,7 +2734,7 @@ static int cache_grow(struct kmem_cache 
 	 * Be lazy and only check for valid flags here,  keeping it out of the
 	 * critical path in kmem_cache_alloc().
 	 */
-	BUG_ON(flags & ~(GFP_DMA | GFP_LEVEL_MASK));
+	BUG_ON(flags & ~(GFP_DMA | __GFP_ZERO | GFP_LEVEL_MASK));
 
 	local_flags = (flags & GFP_LEVEL_MASK);
 	/* Take the l3 list lock to change the colour_next on this node */
@@ -3380,6 +3380,9 @@ __cache_alloc_node(struct kmem_cache *ca
 	local_irq_restore(save_flags);
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
 
+	if (unlikely((flags & __GFP_ZERO) && ptr))
+		memset(ptr, 0, cachep->buffer_size);
+
 	return ptr;
 }
 
@@ -3431,6 +3434,9 @@ __cache_alloc(struct kmem_cache *cachep,
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
 	prefetchw(objp);
 
+	if (unlikely((flags & __GFP_ZERO) && objp))
+		memset(objp, 0, cachep->buffer_size);
+
 	return objp;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
