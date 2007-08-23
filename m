From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 1/6] SLUB: Avoid page struct cacheline bouncing due to remote frees to cpu slab
Date: Wed, 22 Aug 2007 23:46:54 -0700
Message-ID: <20070823064733.846804178@sgi.com>
References: <20070823064653.081843729@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761412AbXHWGtq@vger.kernel.org>
Content-Disposition: inline; filename=0005-SLUB-Avoid-page-struct-cacheline-bouncing-due-to-re.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-Id: linux-mm.kvack.org

A remote free may access the same page struct that also contains the lockless
freelist for the cpu slab. If objects have a short lifetime and are freed by
a different processor then remote frees back to the slab from which we are
currently allocating are frequent. The cacheline with the page struct needs
to be repeately acquired in exclusive mode by both the allocating thread and
the freeing thread. If this is frequent enough then performance will suffer
because of cacheline bouncing.

This patchset puts the lockless_freelist pointer in its own cacheline. In
order to make that happen we introduce a per cpu structure called
kmem_cache_cpu.

Instead of keeping an array of pointers to page structs we now keep an array
to a per cpu structure that--among other things--contains the pointer to the
lockless freelist. The freeing thread can then keep possession of exclusive
access to the page struct cacheline while the allocating thread keeps its
exclusive access to the cacheline containing the per cpu structure.

This works as long as the allocating cpu is able to service its request
from the lockless freelist. If the lockless freelist runs empty then the
allocating thread needs to acquire exclusive access to the cacheline with
the page struct lock the slab.

The allocating thread will then check if new objects were freed to the per
cpu slab. If so it will keep the slab as the cpu slab and continue with the
recently remote freed objects. So the allocating thread can take a series
of just freed remote pages and dish them out again. Ideally allocations
could be just recycling objects in the same slab this way which will lead
to an ideal allocation / remote free pattern.

The number of objects that can be handled in this way is limited by the
capacity of one slab. Increasing slab size via slub_min_objects/
slub_max_order may increase the number of objects and therefore performance.

If the allocating thread runs out of objects and finds that no objects were
put back by the remote processor then it will retrieve a new slab (from the
partial lists or from the page allocator) and start with a whole
new set of objects while the remote thread may still be freeing objects to
the old cpu slab. This may then repeat until the new slab is also exhausted.
If remote freeing has freed objects in the earlier slab then that earlier
slab will now be on the partial freelist and the allocating thread will
pick that slab next for allocation. So the loop is extended. However,
both threads need to take the list_lock to make the swizzling via
the partial list happen.

It is likely that this kind of scheme will keep the objects being passed
around to a small set that can be kept in the cpu caches leading to increased
performance.

More code cleanups become possible:

- Instead of passing a cpu we can now pass a kmem_cache_cpu structure around.
  Allows reducing the number of parameters to various functions.
- Can define a new node_match() function for NUMA to encapsulate locality
  checks.

Effect on allocations:

Cachelines touched before this patch:

	Write:	page cache struct and first cacheline of object

Cachelines touched after this patch:

	Write:	kmem_cache_cpu cacheline and first cacheline of object
	Read: page cache struct (but see later patch that avoids touching
		that cacheline)

The handling when the lockless alloc list runs empty gets to be a bit more
complicated since another cacheline has now to be written to. But that is
halfway out of the hot path.

Effect on freeing:

Cachelines touched before this patch:

	Write: page_struct and first cacheline of object

Cachelines touched after this patch depending on how we free:

  Write(to cpu_slab):	kmem_cache_cpu struct and first cacheline of object
  Write(to other):	page struct and first cacheline of object

  Read(to cpu_slab):	page struct to id slab etc. (but see later patch that
  			avoids touching the page struct on free)
  Read(to other):	cpu local kmem_cache_cpu struct to verify its not
  			the cpu slab.

Summary:

Pro:
	- Distinct cachelines so that concurrent remote frees and local
	  allocs on a cpuslab can occur without cacheline bouncing.
	- Avoids potential bouncing cachelines because of neighboring
	  per cpu pointer updates in kmem_cache's cpu_slab structure since
	  it now grows to a cacheline (Therefore remove the comment
	  that talks about that concern).

Cons:
	- Freeing objects now requires the reading of one additional
	  cacheline. That can be mitigated for some cases by the following
	  patches but its not possible to completely eliminate these
	  references.

	- Memory usage grows slightly.

	The size of each per cpu object is blown up from one word
	(pointing to the page_struct) to one cacheline with various data.
	So this is NR_CPUS*NR_SLABS*L1_BYTES more memory use. Lets say
	NR_SLABS is 100 and a cache line size of 128 then we have just
	increased SLAB metadata requirements by 12.8k per cpu.
	(Another later patch reduces these requirements)

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slub_def.h |    9 +-
 mm/slub.c                |  192 ++++++++++++++++++++++++++++-------------------
 2 files changed, 126 insertions(+), 75 deletions(-)

Index: linux-2.6.23-rc3-mm1/include/linux/slub_def.h
===================================================================
--- linux-2.6.23-rc3-mm1.orig/include/linux/slub_def.h	2007-08-22 17:14:32.000000000 -0700
+++ linux-2.6.23-rc3-mm1/include/linux/slub_def.h	2007-08-22 17:18:56.000000000 -0700
@@ -11,6 +11,13 @@
 #include <linux/workqueue.h>
 #include <linux/kobject.h>
 
+struct kmem_cache_cpu {
+	void **freelist;
+	struct page *page;
+	int node;
+	/* Lots of wasted space */
+} ____cacheline_aligned_in_smp;
+
 struct kmem_cache_node {
 	spinlock_t list_lock;	/* Protect partial list and nr_partial */
 	unsigned long nr_partial;
@@ -54,7 +61,7 @@ struct kmem_cache {
 	int defrag_ratio;
 	struct kmem_cache_node *node[MAX_NUMNODES];
 #endif
-	struct page *cpu_slab[NR_CPUS];
+	struct kmem_cache_cpu cpu_slab[NR_CPUS];
 };
 
 /*
Index: linux-2.6.23-rc3-mm1/mm/slub.c
===================================================================
--- linux-2.6.23-rc3-mm1.orig/mm/slub.c	2007-08-22 17:18:50.000000000 -0700
+++ linux-2.6.23-rc3-mm1/mm/slub.c	2007-08-22 17:20:05.000000000 -0700
@@ -90,7 +90,7 @@
  * 			One use of this flag is to mark slabs that are
  * 			used for allocations. Then such a slab becomes a cpu
  * 			slab. The cpu slab may be equipped with an additional
- * 			lockless_freelist that allows lockless access to
+ * 			freelist that allows lockless access to
  * 			free objects in addition to the regular freelist
  * 			that requires the slab lock.
  *
@@ -140,11 +140,6 @@ static inline void ClearSlabDebug(struct
 /*
  * Issues still to be resolved:
  *
- * - The per cpu array is updated for each new slab and and is a remote
- *   cacheline for most nodes. This could become a bouncing cacheline given
- *   enough frequent updates. There are 16 pointers in a cacheline, so at
- *   max 16 cpus could compete for the cacheline which may be okay.
- *
  * - Support PAGE_ALLOC_DEBUG. Should be easy to do.
  *
  * - Variable sizing of the per node arrays
@@ -284,6 +279,11 @@ static inline struct kmem_cache_node *ge
 #endif
 }
 
+static inline struct kmem_cache_cpu *get_cpu_slab(struct kmem_cache *s, int cpu)
+{
+	return &s->cpu_slab[cpu];
+}
+
 static inline int check_valid_pointer(struct kmem_cache *s,
 				struct page *page, const void *object)
 {
@@ -1385,33 +1385,34 @@ static void unfreeze_slab(struct kmem_ca
 /*
  * Remove the cpu slab
  */
-static void deactivate_slab(struct kmem_cache *s, struct page *page, int cpu)
+static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
+	struct page *page = c->page;
 	/*
 	 * Merge cpu freelist into freelist. Typically we get here
 	 * because both freelists are empty. So this is unlikely
 	 * to occur.
 	 */
-	while (unlikely(page->lockless_freelist)) {
+	while (unlikely(c->freelist)) {
 		void **object;
 
 		/* Retrieve object from cpu_freelist */
-		object = page->lockless_freelist;
-		page->lockless_freelist = page->lockless_freelist[page->offset];
+		object = c->freelist;
+		c->freelist = c->freelist[page->offset];
 
 		/* And put onto the regular freelist */
 		object[page->offset] = page->freelist;
 		page->freelist = object;
 		page->inuse--;
 	}
-	s->cpu_slab[cpu] = NULL;
+	c->page = NULL;
 	unfreeze_slab(s, page);
 }
 
-static inline void flush_slab(struct kmem_cache *s, struct page *page, int cpu)
+static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
-	slab_lock(page);
-	deactivate_slab(s, page, cpu);
+	slab_lock(c->page);
+	deactivate_slab(s, c);
 }
 
 /*
@@ -1420,18 +1421,17 @@ static inline void flush_slab(struct kme
  */
 static inline void __flush_cpu_slab(struct kmem_cache *s, int cpu)
 {
-	struct page *page = s->cpu_slab[cpu];
+	struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
 
-	if (likely(page))
-		flush_slab(s, page, cpu);
+	if (likely(c && c->page))
+		flush_slab(s, c);
 }
 
 static void flush_cpu_slab(void *d)
 {
 	struct kmem_cache *s = d;
-	int cpu = smp_processor_id();
 
-	__flush_cpu_slab(s, cpu);
+	__flush_cpu_slab(s, smp_processor_id());
 }
 
 static void flush_all(struct kmem_cache *s)
@@ -1448,6 +1448,19 @@ static void flush_all(struct kmem_cache 
 }
 
 /*
+ * Check if the objects in a per cpu structure fit numa
+ * locality expectations.
+ */
+static inline int node_match(struct kmem_cache_cpu *c, int node)
+{
+#ifdef CONFIG_NUMA
+	if (node != -1 && c->node != node)
+		return 0;
+#endif
+	return 1;
+}
+
+/*
  * Slow path. The lockless freelist is empty or we need to perform
  * debugging duties.
  *
@@ -1465,45 +1478,46 @@ static void flush_all(struct kmem_cache 
  * we need to allocate a new slab. This is slowest path since we may sleep.
  */
 static void *__slab_alloc(struct kmem_cache *s,
-		gfp_t gfpflags, int node, void *addr, struct page *page)
+		gfp_t gfpflags, int node, void *addr, struct kmem_cache_cpu *c)
 {
 	void **object;
-	int cpu = smp_processor_id();
+	struct page *new;
 
-	if (!page)
+	if (!c->page)
 		goto new_slab;
 
-	slab_lock(page);
-	if (unlikely(node != -1 && page_to_nid(page) != node))
+	slab_lock(c->page);
+	if (unlikely(!node_match(c, node)))
 		goto another_slab;
 load_freelist:
-	object = page->freelist;
+	object = c->page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
-	if (unlikely(SlabDebug(page)))
+	if (unlikely(SlabDebug(c->page)))
 		goto debug;
 
-	object = page->freelist;
-	page->lockless_freelist = object[page->offset];
-	page->inuse = s->objects;
-	page->freelist = NULL;
-	slab_unlock(page);
+	object = c->page->freelist;
+	c->freelist = object[c->page->offset];
+	c->page->inuse = s->objects;
+	c->page->freelist = NULL;
+	c->node = page_to_nid(c->page);
+	slab_unlock(c->page);
 	return object;
 
 another_slab:
-	deactivate_slab(s, page, cpu);
+	deactivate_slab(s, c);
 
 new_slab:
-	page = get_partial(s, gfpflags, node);
-	if (page) {
-		s->cpu_slab[cpu] = page;
+	new = get_partial(s, gfpflags, node);
+	if (new) {
+		c->page = new;
 		goto load_freelist;
 	}
 
-	page = new_slab(s, gfpflags, node);
-	if (page) {
-		cpu = smp_processor_id();
-		if (s->cpu_slab[cpu]) {
+	new = new_slab(s, gfpflags, node);
+	if (new) {
+		c = get_cpu_slab(s, smp_processor_id());
+		if (c->page) {
 			/*
 			 * Someone else populated the cpu_slab while we
 			 * enabled interrupts, or we have gotten scheduled
@@ -1511,34 +1525,32 @@ new_slab:
 			 * requested node even if __GFP_THISNODE was
 			 * specified. So we need to recheck.
 			 */
-			if (node == -1 ||
-				page_to_nid(s->cpu_slab[cpu]) == node) {
+			if (node_match(c, node)) {
 				/*
 				 * Current cpuslab is acceptable and we
 				 * want the current one since its cache hot
 				 */
-				discard_slab(s, page);
-				page = s->cpu_slab[cpu];
-				slab_lock(page);
+				discard_slab(s, new);
+				slab_lock(c->page);
 				goto load_freelist;
 			}
 			/* New slab does not fit our expectations */
-			flush_slab(s, s->cpu_slab[cpu], cpu);
+			flush_slab(s, c);
 		}
-		slab_lock(page);
-		SetSlabFrozen(page);
-		s->cpu_slab[cpu] = page;
+		slab_lock(new);
+		SetSlabFrozen(new);
+		c->page = new;
 		goto load_freelist;
 	}
 	return NULL;
 debug:
-	object = page->freelist;
-	if (!alloc_debug_processing(s, page, object, addr))
+	object = c->page->freelist;
+	if (!alloc_debug_processing(s, c->page, object, addr))
 		goto another_slab;
 
-	page->inuse++;
-	page->freelist = object[page->offset];
-	slab_unlock(page);
+	c->page->inuse++;
+	c->page->freelist = object[c->page->offset];
+	slab_unlock(c->page);
 	return object;
 }
 
@@ -1555,20 +1567,20 @@ debug:
 static void __always_inline *slab_alloc(struct kmem_cache *s,
 		gfp_t gfpflags, int node, void *addr)
 {
-	struct page *page;
 	void **object;
 	unsigned long flags;
+	struct kmem_cache_cpu *c;
 
 	local_irq_save(flags);
-	page = s->cpu_slab[smp_processor_id()];
-	if (unlikely(!page || !page->lockless_freelist ||
-			(node != -1 && page_to_nid(page) != node)))
+	c = get_cpu_slab(s, smp_processor_id());
+	if (unlikely(!c->page || !c->freelist ||
+					!node_match(c, node)))
 
-		object = __slab_alloc(s, gfpflags, node, addr, page);
+		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {
-		object = page->lockless_freelist;
-		page->lockless_freelist = object[page->offset];
+		object = c->freelist;
+		c->freelist = object[c->page->offset];
 	}
 	local_irq_restore(flags);
 
@@ -1666,13 +1678,14 @@ static void __always_inline slab_free(st
 {
 	void **object = (void *)x;
 	unsigned long flags;
+	struct kmem_cache_cpu *c;
 
 	local_irq_save(flags);
 	debug_check_no_locks_freed(object, s->objsize);
-	if (likely(page == s->cpu_slab[smp_processor_id()] &&
-						!SlabDebug(page))) {
-		object[page->offset] = page->lockless_freelist;
-		page->lockless_freelist = object;
+	c = get_cpu_slab(s, smp_processor_id());
+	if (likely(page == c->page && !SlabDebug(page))) {
+		object[page->offset] = c->freelist;
+		c->freelist = object;
 	} else
 		__slab_free(s, page, x, addr);
 
@@ -1865,6 +1878,24 @@ static unsigned long calculate_alignment
 	return ALIGN(align, sizeof(void *));
 }
 
+static void init_kmem_cache_cpu(struct kmem_cache *s,
+			struct kmem_cache_cpu *c)
+{
+	c->page = NULL;
+	c->freelist = NULL;
+	c->node = 0;
+}
+
+static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		init_kmem_cache_cpu(s, get_cpu_slab(s, cpu));
+
+	return 1;
+}
+
 static void init_kmem_cache_node(struct kmem_cache_node *n)
 {
 	n->nr_partial = 0;
@@ -2115,8 +2146,12 @@ static int kmem_cache_open(struct kmem_c
 #ifdef CONFIG_NUMA
 	s->defrag_ratio = 100;
 #endif
-	if (init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
+	if (!init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
+		goto error;
+
+	if (alloc_kmem_cache_cpus(s, gfpflags & ~SLUB_DMA))
 		return 1;
+
 error:
 	if (flags & SLAB_PANIC)
 		panic("Cannot create slab %s size=%lu realsize=%u "
@@ -2658,7 +2693,7 @@ void __init kmem_cache_init(void)
 #endif
 
 	kmem_size = offsetof(struct kmem_cache, cpu_slab) +
-				nr_cpu_ids * sizeof(struct page *);
+				nr_cpu_ids * sizeof(struct kmem_cache_cpu);
 
 	printk(KERN_INFO "SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d, MinObjects=%d,"
 		" CPUs=%d, Nodes=%d\n",
@@ -3261,11 +3296,14 @@ static unsigned long slab_objects(struct
 	per_cpu = nodes + nr_node_ids;
 
 	for_each_possible_cpu(cpu) {
-		struct page *page = s->cpu_slab[cpu];
-		int node;
+		struct page *page;
+		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
 
+		if (!c)
+			continue;
+
+		page = c->page;
 		if (page) {
-			node = page_to_nid(page);
 			if (flags & SO_CPU) {
 				int x = 0;
 
@@ -3274,9 +3312,9 @@ static unsigned long slab_objects(struct
 				else
 					x = 1;
 				total += x;
-				nodes[node] += x;
+				nodes[c->node] += x;
 			}
-			per_cpu[node]++;
+			per_cpu[c->node]++;
 		}
 	}
 
@@ -3322,13 +3360,19 @@ static int any_slab_objects(struct kmem_
 	int node;
 	int cpu;
 
-	for_each_possible_cpu(cpu)
-		if (s->cpu_slab[cpu])
+	for_each_possible_cpu(cpu) {
+		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+
+		if (c && c->page)
 			return 1;
+	}
 
-	for_each_node(node) {
+	for_each_online_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
+		if (!n)
+			continue;
+
 		if (n->nr_partial || atomic_long_read(&n->nr_slabs))
 			return 1;
 	}

-- 
