Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3A48D600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 13:03:39 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8F57E82C7E5
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 13:49:57 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NVF5bku3MNAf for <linux-mm@kvack.org>;
	Thu,  1 Oct 2009 13:49:57 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8AB2182C7E9
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 13:49:32 -0400 (EDT)
Message-Id: <20091001174122.790777428@gentwo.org>
References: <20091001174033.576397715@gentwo.org>
Date: Thu, 01 Oct 2009 13:40:50 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V3 17/19] this_cpu: Remove slub kmem_cache fields
Content-Disposition: inline; filename=this_cpu_slub_remove_fields
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Remove the fields in struct kmem_cache_cpu that were used to cache data from
struct kmem_cache when they were in different cachelines. The cacheline that
holds the per cpu array pointer now also holds these values. We can cut down
the struct kmem_cache_cpu size to almost half.

The get_freepointer() and set_freepointer() functions that used to be only
intended for the slow path now are also useful for the hot path since access
to the size field does not require accessing an additional cacheline anymore.
This results in consistent use of functions for setting the freepointer of
objects throughout SLUB.

Also we initialize all possible kmem_cache_cpu structures when a slab is
created. No need to initialize them when a processor or node comes online.

Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
---
 include/linux/slub_def.h |    2 -
 mm/slub.c                |   81 +++++++++++++----------------------------------
 2 files changed, 24 insertions(+), 59 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2009-09-29 11:44:03.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2009-09-29 11:44:35.000000000 -0500
@@ -38,8 +38,6 @@ struct kmem_cache_cpu {
 	void **freelist;	/* Pointer to first free per cpu object */
 	struct page *page;	/* The slab from which we are allocating */
 	int node;		/* The node of the page (or -1 for debug) */
-	unsigned int offset;	/* Freepointer offset (in word units) */
-	unsigned int objsize;	/* Size of an object (from kmem_cache) */
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2009-09-29 11:44:03.000000000 -0500
+++ linux-2.6/mm/slub.c	2009-09-29 11:44:35.000000000 -0500
@@ -260,13 +260,6 @@ static inline int check_valid_pointer(st
 	return 1;
 }
 
-/*
- * Slow version of get and set free pointer.
- *
- * This version requires touching the cache lines of kmem_cache which
- * we avoid to do in the fast alloc free paths. There we obtain the offset
- * from the page struct.
- */
 static inline void *get_freepointer(struct kmem_cache *s, void *object)
 {
 	return *(void **)(object + s->offset);
@@ -1473,10 +1466,10 @@ static void deactivate_slab(struct kmem_
 
 		/* Retrieve object from cpu_freelist */
 		object = c->freelist;
-		c->freelist = c->freelist[c->offset];
+		c->freelist = get_freepointer(s, c->freelist);
 
 		/* And put onto the regular freelist */
-		object[c->offset] = page->freelist;
+		set_freepointer(s, object, page->freelist);
 		page->freelist = object;
 		page->inuse--;
 	}
@@ -1635,7 +1628,7 @@ load_freelist:
 	if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
 		goto debug;
 
-	c->freelist = object[c->offset];
+	c->freelist = get_freepointer(s, object);
 	c->page->inuse = c->page->objects;
 	c->page->freelist = NULL;
 	c->node = page_to_nid(c->page);
@@ -1681,7 +1674,7 @@ debug:
 		goto another_slab;
 
 	c->page->inuse++;
-	c->page->freelist = object[c->offset];
+	c->page->freelist = get_freepointer(s, object);
 	c->node = -1;
 	goto unlock_out;
 }
@@ -1719,7 +1712,7 @@ static __always_inline void *slab_alloc(
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {
-		c->freelist = object[c->offset];
+		c->freelist = get_freepointer(s, object);
 		stat(c, ALLOC_FASTPATH);
 	}
 	local_irq_restore(flags);
@@ -1727,8 +1720,8 @@ static __always_inline void *slab_alloc(
 	if (unlikely((gfpflags & __GFP_ZERO) && object))
 		memset(object, 0, s->objsize);
 
-	kmemcheck_slab_alloc(s, gfpflags, object, c->objsize);
-	kmemleak_alloc_recursive(object, c->objsize, 1, s->flags, gfpflags);
+	kmemcheck_slab_alloc(s, gfpflags, object, s->objsize);
+	kmemleak_alloc_recursive(object, s->objsize, 1, s->flags, gfpflags);
 
 	return object;
 }
@@ -1783,7 +1776,7 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_notr
  * handling required then we can return immediately.
  */
 static void __slab_free(struct kmem_cache *s, struct page *page,
-			void *x, unsigned long addr, unsigned int offset)
+			void *x, unsigned long addr)
 {
 	void *prior;
 	void **object = (void *)x;
@@ -1797,7 +1790,8 @@ static void __slab_free(struct kmem_cach
 		goto debug;
 
 checks_ok:
-	prior = object[offset] = page->freelist;
+	prior = page->freelist;
+	set_freepointer(s, object, prior);
 	page->freelist = object;
 	page->inuse--;
 
@@ -1862,16 +1856,16 @@ static __always_inline void slab_free(st
 	kmemleak_free_recursive(x, s->flags);
 	local_irq_save(flags);
 	c = __this_cpu_ptr(s->cpu_slab);
-	kmemcheck_slab_free(s, object, c->objsize);
-	debug_check_no_locks_freed(object, c->objsize);
+	kmemcheck_slab_free(s, object, s->objsize);
+	debug_check_no_locks_freed(object, s->objsize);
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
-		debug_check_no_obj_freed(object, c->objsize);
+		debug_check_no_obj_freed(object, s->objsize);
 	if (likely(page == c->page && c->node >= 0)) {
-		object[c->offset] = c->freelist;
+		set_freepointer(s, object, c->freelist);
 		c->freelist = object;
 		stat(c, FREE_FASTPATH);
 	} else
-		__slab_free(s, page, x, addr, c->offset);
+		__slab_free(s, page, x, addr);
 
 	local_irq_restore(flags);
 }
@@ -2058,19 +2052,6 @@ static unsigned long calculate_alignment
 	return ALIGN(align, sizeof(void *));
 }
 
-static void init_kmem_cache_cpu(struct kmem_cache *s,
-			struct kmem_cache_cpu *c)
-{
-	c->page = NULL;
-	c->freelist = NULL;
-	c->node = 0;
-	c->offset = s->offset / sizeof(void *);
-	c->objsize = s->objsize;
-#ifdef CONFIG_SLUB_STATS
-	memset(c->stat, 0, NR_SLUB_STAT_ITEMS * sizeof(unsigned));
-#endif
-}
-
 static void
 init_kmem_cache_node(struct kmem_cache_node *n, struct kmem_cache *s)
 {
@@ -2088,8 +2069,6 @@ static DEFINE_PER_CPU(struct kmem_cache_
 
 static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
 {
-	int cpu;
-
 	if (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches)
 		/*
 		 * Boot time creation of the kmalloc array. Use static per cpu data
@@ -2102,8 +2081,6 @@ static inline int alloc_kmem_cache_cpus(
 	if (!s->cpu_slab)
 		return 0;
 
-	for_each_possible_cpu(cpu)
-		init_kmem_cache_cpu(s, per_cpu_ptr(s->cpu_slab, cpu));
 	return 1;
 }
 
@@ -2387,8 +2364,16 @@ static int kmem_cache_open(struct kmem_c
 	if (!init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
 		goto error;
 
-	if (alloc_kmem_cache_cpus(s, gfpflags & ~SLUB_DMA))
+	if (!alloc_kmem_cache_cpus(s, gfpflags & ~SLUB_DMA))
+		return 0;
+
+	/*
+	 * gfp_flags would be flags & ~SLUB_DMA but the per cpu
+	 * allocator does not support it.
+	 */
+	if (s->cpu_slab)
 		return 1;
+
 	free_kmem_cache_nodes(s);
 error:
 	if (flags & SLAB_PANIC)
@@ -3245,22 +3230,12 @@ struct kmem_cache *kmem_cache_create(con
 	down_write(&slub_lock);
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
-		int cpu;
-
 		s->refcount++;
 		/*
 		 * Adjust the object sizes so that we clear
 		 * the complete object on kzalloc.
 		 */
 		s->objsize = max(s->objsize, (int)size);
-
-		/*
-		 * And then we need to update the object size in the
-		 * per cpu structures
-		 */
-		for_each_online_cpu(cpu)
-			per_cpu_ptr(s->cpu_slab, cpu)->objsize = s->objsize;
-
 		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
 		up_write(&slub_lock);
 
@@ -3314,14 +3289,6 @@ static int __cpuinit slab_cpuup_callback
 	unsigned long flags;
 
 	switch (action) {
-	case CPU_UP_PREPARE:
-	case CPU_UP_PREPARE_FROZEN:
-		down_read(&slub_lock);
-		list_for_each_entry(s, &slab_caches, list)
-			init_kmem_cache_cpu(s, per_cpu_ptr(s->cpu_slab, cpu));
-		up_read(&slub_lock);
-		break;
-
 	case CPU_UP_CANCELED:
 	case CPU_UP_CANCELED_FROZEN:
 	case CPU_DEAD:

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
