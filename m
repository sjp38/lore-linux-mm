Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C82F76B005D
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 21:36:09 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D033982C514
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 21:53:33 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Y-hco2pOg-PS for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 21:53:33 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9A6D882C510
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 21:45:13 -0400 (EDT)
Message-Id: <20090617203445.497710695@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:51 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 14/19] this_cpu: Remove slub kmem_cache fields
Content-Disposition: inline; filename=this_cpu_slub_remove_fields
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Remove the fields in kmem_cache_cpu that were used to cache data from
kmem_cache when they were in different cachelines. The cacheline that holds
the per cpu array pointer now also holds these values. We can cut down the
struct kmem_cache_cpu size to almost half.

The get_freepointer() and set_freepointer() functions that used to be only
intended for the slow path now are also useful for the hot path since access
to the field does not require accessing an additional cacheline anymore. This
results in consistent use of setting the freepointer for objects throughout
SLUB.

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
--- linux-2.6.orig/include/linux/slub_def.h	2009-06-17 14:11:15.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2009-06-17 14:11:20.000000000 -0500
@@ -37,8 +37,6 @@ struct kmem_cache_cpu {
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
--- linux-2.6.orig/mm/slub.c	2009-06-17 14:11:15.000000000 -0500
+++ linux-2.6/mm/slub.c	2009-06-17 14:11:20.000000000 -0500
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
@@ -1456,10 +1449,10 @@ static void deactivate_slab(struct kmem_
 
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
@@ -1611,7 +1604,7 @@ load_freelist:
 	if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
 		goto debug;
 
-	c->freelist = object[c->offset];
+	c->freelist = get_freepointer(s, object);
 	c->page->inuse = c->page->objects;
 	c->page->freelist = NULL;
 	c->node = page_to_nid(c->page);
@@ -1657,7 +1650,7 @@ debug:
 		goto another_slab;
 
 	c->page->inuse++;
-	c->page->freelist = object[c->offset];
+	c->page->freelist = get_freepointer(s, object);
 	c->node = -1;
 	goto unlock_out;
 }
@@ -1695,7 +1688,7 @@ static __always_inline void *slab_alloc(
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {
-		c->freelist = object[c->offset];
+		c->freelist = get_freepointer(s, object);
 		stat(c, ALLOC_FASTPATH);
 	}
 	local_irq_restore(flags);
@@ -1703,8 +1696,8 @@ static __always_inline void *slab_alloc(
 	if (unlikely((gfpflags & __GFP_ZERO) && object))
 		memset(object, 0, s->objsize);
 
-	kmemcheck_slab_alloc(s, gfpflags, object, c->objsize);
-	kmemleak_alloc_recursive(object, c->objsize, 1, s->flags, gfpflags);
+	kmemcheck_slab_alloc(s, gfpflags, object, s->objsize);
+	kmemleak_alloc_recursive(object, s->objsize, 1, s->flags, gfpflags);
 
 	return object;
 }
@@ -1759,7 +1752,7 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_notr
  * handling required then we can return immediately.
  */
 static void __slab_free(struct kmem_cache *s, struct page *page,
-			void *x, unsigned long addr, unsigned int offset)
+			void *x, unsigned long addr)
 {
 	void *prior;
 	void **object = (void *)x;
@@ -1773,7 +1766,8 @@ static void __slab_free(struct kmem_cach
 		goto debug;
 
 checks_ok:
-	prior = object[offset] = page->freelist;
+	prior = page->freelist;
+	set_freepointer(s, object, prior);
 	page->freelist = object;
 	page->inuse--;
 
@@ -1838,16 +1832,16 @@ static __always_inline void slab_free(st
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
@@ -2034,19 +2028,6 @@ static unsigned long calculate_alignment
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
@@ -2064,8 +2045,6 @@ static DEFINE_PER_CPU(struct kmem_cache_
 
 static int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
 {
-	int cpu;
-
 	if (s < kmalloc_caches + SLUB_PAGE_SHIFT && s >= kmalloc_caches)
 		/*
 		 * Boot time creation of the kmalloc array. Use static per cpu data
@@ -2078,8 +2057,6 @@ static int alloc_kmem_cache_cpus(struct 
 	if (!s->cpu_slab)
 		return 0;
 
-	for_each_possible_cpu(cpu)
-		init_kmem_cache_cpu(s, per_cpu_ptr(s->cpu_slab, cpu));
 	return 1;
 }
 
@@ -2350,8 +2327,16 @@ static int kmem_cache_open(struct kmem_c
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
@@ -3190,22 +3175,12 @@ struct kmem_cache *kmem_cache_create(con
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
 
@@ -3259,14 +3234,6 @@ static int __cpuinit slab_cpuup_callback
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
