From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 3/3] cpu alloc: Remove slub fields
Date: Fri, 03 Oct 2008 08:24:39 -0700
Message-ID: <20081003152500.490056344@quilx.com>
References: <20081003152436.089811999@quilx.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline; filename=cpu_alloc_remove_slub_fields
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-Id: linux-mm.kvack.org

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
And all fields are set to zero. So just use __GFP_ZERO on cpu alloc.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
---
 include/linux/slub_def.h |    2 --
 mm/slub.c                |   39 +++++++++++----------------------------
 2 files changed, 11 insertions(+), 30 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2008-10-03 10:17:32.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2008-10-03 10:18:15.000000000 -0500
@@ -36,8 +36,6 @@
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
--- linux-2.6.orig/mm/slub.c	2008-10-03 10:17:32.000000000 -0500
+++ linux-2.6/mm/slub.c	2008-10-03 10:18:15.000000000 -0500
@@ -244,13 +244,6 @@
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
@@ -1415,10 +1408,10 @@
 
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
@@ -1514,7 +1507,7 @@
 	if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
 		goto debug;
 
-	c->freelist = object[c->offset];
+	c->freelist = get_freepointer(s, object);
 	c->page->inuse = c->page->objects;
 	c->page->freelist = NULL;
 	c->node = page_to_nid(c->page);
@@ -1558,7 +1551,7 @@
 		goto another_slab;
 
 	c->page->inuse++;
-	c->page->freelist = object[c->offset];
+	c->page->freelist = get_freepointer(s, object);
 	c->node = -1;
 	goto unlock_out;
 }
@@ -1588,7 +1581,7 @@
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {
-		c->freelist = object[c->offset];
+		c->freelist = get_freepointer(s, object);
 		stat(c, ALLOC_FASTPATH);
 	}
 	local_irq_restore(flags);
@@ -1622,7 +1615,7 @@
  * handling required then we can return immediately.
  */
 static void __slab_free(struct kmem_cache *s, struct page *page,
-				void *x, void *addr, unsigned int offset)
+				void *x, void *addr)
 {
 	void *prior;
 	void **object = (void *)x;
@@ -1636,7 +1629,8 @@
 		goto debug;
 
 checks_ok:
-	prior = object[offset] = page->freelist;
+	prior = page->freelist;
+	set_freepointer(s, object, prior);
 	page->freelist = object;
 	page->inuse--;
 
@@ -1700,15 +1694,15 @@
 
 	local_irq_save(flags);
 	c = __THIS_CPU(s->cpu_slab);
-	debug_check_no_locks_freed(object, c->objsize);
+	debug_check_no_locks_freed(object, s->objsize);
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(object, s->objsize);
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
@@ -1889,19 +1883,6 @@
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
@@ -1926,20 +1907,6 @@
 #endif
 }
 
-static int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
-{
-	int cpu;
-
-	s->cpu_slab = CPU_ALLOC(struct kmem_cache_cpu, flags);
-
-	if (!s->cpu_slab)
-		return 0;
-
-	for_each_possible_cpu(cpu)
-		init_kmem_cache_cpu(s, CPU_PTR(s->cpu_slab, cpu));
-	return 1;
-}
-
 #ifdef CONFIG_NUMA
 /*
  * No kmalloc_node yet so do it by hand. We know that this is the first
@@ -2196,8 +2163,11 @@
 	if (!init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
 		goto error;
 
-	if (alloc_kmem_cache_cpus(s, gfpflags & ~SLUB_DMA))
+	s->cpu_slab = CPU_ALLOC(struct kmem_cache_cpu,
+				(flags & ~SLUB_DMA) | __GFP_ZERO);
+	if (s->cpu_slab)
 		return 1;
+
 	free_kmem_cache_nodes(s);
 error:
 	if (flags & SLAB_PANIC)
@@ -2977,8 +2947,6 @@
 	down_write(&slub_lock);
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
-		int cpu;
-
 		s->refcount++;
 		/*
 		 * Adjust the object sizes so that we clear
@@ -2986,13 +2954,6 @@
 		 */
 		s->objsize = max(s->objsize, (int)size);
 
-		/*
-		 * And then we need to update the object size in the
-		 * per cpu structures
-		 */
-		for_each_online_cpu(cpu)
-			CPU_PTR(s->cpu_slab, cpu)->objsize = s->objsize;
-
 		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
 		up_write(&slub_lock);
 
@@ -3037,14 +2998,6 @@
 	unsigned long flags;
 
 	switch (action) {
-	case CPU_UP_PREPARE:
-	case CPU_UP_PREPARE_FROZEN:
-		down_read(&slub_lock);
-		list_for_each_entry(s, &slab_caches, list)
-			init_kmem_cache_cpu(s, CPU_PTR(s->cpu_slab, cpu));
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
