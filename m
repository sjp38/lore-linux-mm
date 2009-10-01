Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7722F6B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 02:55:21 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0DC3182C7EA
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 03:06:42 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ew7FCxgDglWC for <linux-mm@kvack.org>;
	Fri,  2 Oct 2009 03:06:36 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0E5B182C7DA
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 03:06:36 -0400 (EDT)
Message-Id: <20091001174122.413629421@gentwo.org>
References: <20091001174033.576397715@gentwo.org>
Date: Thu, 01 Oct 2009 13:40:48 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V3 15/19] Use this_cpu operations in slub
Content-Disposition: inline; filename=this_cpu_slub_conversion
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Using per cpu allocations removes the needs for the per cpu arrays in the
kmem_cache struct. These could get quite big if we have to support systems
with thousands of cpus. The use of this_cpu_xx operations results in:

1. The size of kmem_cache for SMP configuration shrinks since we will only
   need 1 pointer instead of NR_CPUS. The same pointer can be used by all
   processors. Reduces cache footprint of the allocator.

2. We can dynamically size kmem_cache according to the actual nodes in the
   system meaning less memory overhead for configurations that may potentially
   support up to 1k NUMA nodes / 4k cpus.

3. We can remove the diddle widdle with allocating and releasing of
   kmem_cache_cpu structures when bringing up and shutting down cpus. The cpu
   alloc logic will do it all for us. Removes some portions of the cpu hotplug
   functionality.

4. Fastpath performance increases since per cpu pointer lookups and
   address calculations are avoided.

V2->V3:
- Leave Linus' code ornament alone.

Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |    6 -
 mm/slub.c                |  207 ++++++++++-------------------------------------
 2 files changed, 49 insertions(+), 164 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2009-09-17 17:51:51.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2009-09-29 09:02:05.000000000 -0500
@@ -69,6 +69,7 @@ struct kmem_cache_order_objects {
  * Slab cache management.
  */
 struct kmem_cache {
+	struct kmem_cache_cpu *cpu_slab;
 	/* Used for retriving partial slabs etc */
 	unsigned long flags;
 	int size;		/* The size of an object including meta data */
@@ -104,11 +105,6 @@ struct kmem_cache {
 	int remote_node_defrag_ratio;
 	struct kmem_cache_node *node[MAX_NUMNODES];
 #endif
-#ifdef CONFIG_SMP
-	struct kmem_cache_cpu *cpu_slab[NR_CPUS];
-#else
-	struct kmem_cache_cpu cpu_slab;
-#endif
 };
 
 /*
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2009-09-28 10:08:10.000000000 -0500
+++ linux-2.6/mm/slub.c	2009-09-29 09:02:05.000000000 -0500
@@ -242,15 +242,6 @@ static inline struct kmem_cache_node *ge
 #endif
 }
 
-static inline struct kmem_cache_cpu *get_cpu_slab(struct kmem_cache *s, int cpu)
-{
-#ifdef CONFIG_SMP
-	return s->cpu_slab[cpu];
-#else
-	return &s->cpu_slab;
-#endif
-}
-
 /* Verify that a pointer has an address that is valid within a slab page */
 static inline int check_valid_pointer(struct kmem_cache *s,
 				struct page *page, const void *object)
@@ -1124,7 +1115,7 @@ static struct page *allocate_slab(struct
 		if (!page)
 			return NULL;
 
-		stat(get_cpu_slab(s, raw_smp_processor_id()), ORDER_FALLBACK);
+		stat(this_cpu_ptr(s->cpu_slab), ORDER_FALLBACK);
 	}
 
 	if (kmemcheck_enabled
@@ -1422,7 +1413,7 @@ static struct page *get_partial(struct k
 static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
-	struct kmem_cache_cpu *c = get_cpu_slab(s, smp_processor_id());
+	struct kmem_cache_cpu *c = this_cpu_ptr(s->cpu_slab);
 
 	__ClearPageSlubFrozen(page);
 	if (page->inuse) {
@@ -1454,7 +1445,7 @@ static void unfreeze_slab(struct kmem_ca
 			slab_unlock(page);
 		} else {
 			slab_unlock(page);
-			stat(get_cpu_slab(s, raw_smp_processor_id()), FREE_SLAB);
+			stat(__this_cpu_ptr(s->cpu_slab), FREE_SLAB);
 			discard_slab(s, page);
 		}
 	}
@@ -1507,7 +1498,7 @@ static inline void flush_slab(struct kme
  */
 static inline void __flush_cpu_slab(struct kmem_cache *s, int cpu)
 {
-	struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
 	if (likely(c && c->page))
 		flush_slab(s, c);
@@ -1673,7 +1661,7 @@ new_slab:
 		local_irq_disable();
 
 	if (new) {
-		c = get_cpu_slab(s, smp_processor_id());
+		c = __this_cpu_ptr(s->cpu_slab);
 		stat(c, ALLOC_SLAB);
 		if (c->page)
 			flush_slab(s, c);
@@ -1711,7 +1699,6 @@ static __always_inline void *slab_alloc(
 	void **object;
 	struct kmem_cache_cpu *c;
 	unsigned long flags;
-	unsigned int objsize;
 
 	gfpflags &= gfp_allowed_mask;
 
@@ -1722,24 +1709,23 @@ static __always_inline void *slab_alloc(
 		return NULL;
 
 	local_irq_save(flags);
-	c = get_cpu_slab(s, smp_processor_id());
-	objsize = c->objsize;
-	if (unlikely(!c->freelist || !node_match(c, node)))
+	c = __this_cpu_ptr(s->cpu_slab);
+	object = c->freelist;
+	if (unlikely(!object || !node_match(c, node)))
 
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {
-		object = c->freelist;
 		c->freelist = object[c->offset];
 		stat(c, ALLOC_FASTPATH);
 	}
 	local_irq_restore(flags);
 
 	if (unlikely((gfpflags & __GFP_ZERO) && object))
-		memset(object, 0, objsize);
+		memset(object, 0, s->objsize);
 
 	kmemcheck_slab_alloc(s, gfpflags, object, c->objsize);
-	kmemleak_alloc_recursive(object, objsize, 1, s->flags, gfpflags);
+	kmemleak_alloc_recursive(object, c->objsize, 1, s->flags, gfpflags);
 
 	return object;
 }
@@ -1800,7 +1786,7 @@ static void __slab_free(struct kmem_cach
 	void **object = (void *)x;
 	struct kmem_cache_cpu *c;
 
-	c = get_cpu_slab(s, raw_smp_processor_id());
+	c = __this_cpu_ptr(s->cpu_slab);
 	stat(c, FREE_SLOWPATH);
 	slab_lock(page);
 
@@ -1872,7 +1858,7 @@ static __always_inline void slab_free(st
 
 	kmemleak_free_recursive(x, s->flags);
 	local_irq_save(flags);
-	c = get_cpu_slab(s, smp_processor_id());
+	c = __this_cpu_ptr(s->cpu_slab);
 	kmemcheck_slab_free(s, object, c->objsize);
 	debug_check_no_locks_freed(object, c->objsize);
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
@@ -2095,130 +2081,28 @@ init_kmem_cache_node(struct kmem_cache_n
 #endif
 }
 
-#ifdef CONFIG_SMP
-/*
- * Per cpu array for per cpu structures.
- *
- * The per cpu array places all kmem_cache_cpu structures from one processor
- * close together meaning that it becomes possible that multiple per cpu
- * structures are contained in one cacheline. This may be particularly
- * beneficial for the kmalloc caches.
- *
- * A desktop system typically has around 60-80 slabs. With 100 here we are
- * likely able to get per cpu structures for all caches from the array defined
- * here. We must be able to cover all kmalloc caches during bootstrap.
- *
- * If the per cpu array is exhausted then fall back to kmalloc
- * of individual cachelines. No sharing is possible then.
- */
-#define NR_KMEM_CACHE_CPU 100
-
-static DEFINE_PER_CPU(struct kmem_cache_cpu [NR_KMEM_CACHE_CPU],
-		      kmem_cache_cpu);
-
-static DEFINE_PER_CPU(struct kmem_cache_cpu *, kmem_cache_cpu_free);
-static DECLARE_BITMAP(kmem_cach_cpu_free_init_once, CONFIG_NR_CPUS);
-
-static struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s,
-							int cpu, gfp_t flags)
-{
-	struct kmem_cache_cpu *c = per_cpu(kmem_cache_cpu_free, cpu);
-
-	if (c)
-		per_cpu(kmem_cache_cpu_free, cpu) =
-				(void *)c->freelist;
-	else {
-		/* Table overflow: So allocate ourselves */
-		c = kmalloc_node(
-			ALIGN(sizeof(struct kmem_cache_cpu), cache_line_size()),
-			flags, cpu_to_node(cpu));
-		if (!c)
-			return NULL;
-	}
-
-	init_kmem_cache_cpu(s, c);
-	return c;
-}
-
-static void free_kmem_cache_cpu(struct kmem_cache_cpu *c, int cpu)
-{
-	if (c < per_cpu(kmem_cache_cpu, cpu) ||
-			c >= per_cpu(kmem_cache_cpu, cpu) + NR_KMEM_CACHE_CPU) {
-		kfree(c);
-		return;
-	}
-	c->freelist = (void *)per_cpu(kmem_cache_cpu_free, cpu);
-	per_cpu(kmem_cache_cpu_free, cpu) = c;
-}
-
-static void free_kmem_cache_cpus(struct kmem_cache *s)
-{
-	int cpu;
+static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[SLUB_PAGE_SHIFT]);
 
-	for_each_online_cpu(cpu) {
-		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
-
-		if (c) {
-			s->cpu_slab[cpu] = NULL;
-			free_kmem_cache_cpu(c, cpu);
-		}
-	}
-}
-
-static int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
-{
-	int cpu;
-
-	for_each_online_cpu(cpu) {
-		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
-
-		if (c)
-			continue;
-
-		c = alloc_kmem_cache_cpu(s, cpu, flags);
-		if (!c) {
-			free_kmem_cache_cpus(s);
-			return 0;
-		}
-		s->cpu_slab[cpu] = c;
-	}
-	return 1;
-}
-
-/*
- * Initialize the per cpu array.
- */
-static void init_alloc_cpu_cpu(int cpu)
-{
-	int i;
-
-	if (cpumask_test_cpu(cpu, to_cpumask(kmem_cach_cpu_free_init_once)))
-		return;
-
-	for (i = NR_KMEM_CACHE_CPU - 1; i >= 0; i--)
-		free_kmem_cache_cpu(&per_cpu(kmem_cache_cpu, cpu)[i], cpu);
-
-	cpumask_set_cpu(cpu, to_cpumask(kmem_cach_cpu_free_init_once));
-}
-
-static void __init init_alloc_cpu(void)
+static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
 {
 	int cpu;
 
-	for_each_online_cpu(cpu)
-		init_alloc_cpu_cpu(cpu);
-  }
+	if (s < kmalloc_caches + SLUB_PAGE_SHIFT && s >= kmalloc_caches)
+		/*
+		 * Boot time creation of the kmalloc array. Use static per cpu data
+		 * since the per cpu allocator is not available yet.
+		 */
+		s->cpu_slab = per_cpu_var(kmalloc_percpu) + (s - kmalloc_caches);
+	else
+		s->cpu_slab =  alloc_percpu(struct kmem_cache_cpu);
 
-#else
-static inline void free_kmem_cache_cpus(struct kmem_cache *s) {}
-static inline void init_alloc_cpu(void) {}
+	if (!s->cpu_slab)
+		return 0;
 
-static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
-{
-	init_kmem_cache_cpu(s, &s->cpu_slab);
+	for_each_possible_cpu(cpu)
+		init_kmem_cache_cpu(s, per_cpu_ptr(s->cpu_slab, cpu));
 	return 1;
 }
-#endif
 
 #ifdef CONFIG_NUMA
 /*
@@ -2609,9 +2493,8 @@ static inline int kmem_cache_close(struc
 	int node;
 
 	flush_all(s);
-
+	free_percpu(s->cpu_slab);
 	/* Attempt to free all objects */
-	free_kmem_cache_cpus(s);
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
@@ -2760,7 +2643,19 @@ static noinline struct kmem_cache *dma_k
 	realsize = kmalloc_caches[index].objsize;
 	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
 			 (unsigned int)realsize);
-	s = kmalloc(kmem_size, flags & ~SLUB_DMA);
+
+	if (flags & __GFP_WAIT)
+		s = kmalloc(kmem_size, flags & ~SLUB_DMA);
+	else {
+		int i;
+
+		s = NULL;
+		for (i = 0; i < SLUB_PAGE_SHIFT; i++)
+			if (kmalloc_caches[i].size) {
+				s = kmalloc_caches + i;
+				break;
+			}
+	}
 
 	/*
 	 * Must defer sysfs creation to a workqueue because we don't know
@@ -3176,8 +3071,6 @@ void __init kmem_cache_init(void)
 	int i;
 	int caches = 0;
 
-	init_alloc_cpu();
-
 #ifdef CONFIG_NUMA
 	/*
 	 * Must first have the slab cache available for the allocations of the
@@ -3261,8 +3154,10 @@ void __init kmem_cache_init(void)
 
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);
-	kmem_size = offsetof(struct kmem_cache, cpu_slab) +
-				nr_cpu_ids * sizeof(struct kmem_cache_cpu *);
+#endif
+#ifdef CONFIG_NUMA
+	kmem_size = offsetof(struct kmem_cache, node) +
+				nr_node_ids * sizeof(struct kmem_cache_node *);
 #else
 	kmem_size = sizeof(struct kmem_cache);
 #endif
@@ -3365,7 +3260,7 @@ struct kmem_cache *kmem_cache_create(con
 		 * per cpu structures
 		 */
 		for_each_online_cpu(cpu)
-			get_cpu_slab(s, cpu)->objsize = s->objsize;
+			per_cpu_ptr(s->cpu_slab, cpu)->objsize = s->objsize;
 
 		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
 		up_write(&slub_lock);
@@ -3422,11 +3317,9 @@ static int __cpuinit slab_cpuup_callback
 	switch (action) {
 	case CPU_UP_PREPARE:
 	case CPU_UP_PREPARE_FROZEN:
-		init_alloc_cpu_cpu(cpu);
 		down_read(&slub_lock);
 		list_for_each_entry(s, &slab_caches, list)
-			s->cpu_slab[cpu] = alloc_kmem_cache_cpu(s, cpu,
-							GFP_KERNEL);
+			init_kmem_cache_cpu(s, per_cpu_ptr(s->cpu_slab, cpu));
 		up_read(&slub_lock);
 		break;
 
@@ -3436,13 +3329,9 @@ static int __cpuinit slab_cpuup_callback
 	case CPU_DEAD_FROZEN:
 		down_read(&slub_lock);
 		list_for_each_entry(s, &slab_caches, list) {
-			struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
-
 			local_irq_save(flags);
 			__flush_cpu_slab(s, cpu);
 			local_irq_restore(flags);
-			free_kmem_cache_cpu(c, cpu);
-			s->cpu_slab[cpu] = NULL;
 		}
 		up_read(&slub_lock);
 		break;
@@ -3928,7 +3817,7 @@ static ssize_t show_slab_objects(struct 
 		int cpu;
 
 		for_each_possible_cpu(cpu) {
-			struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
 			if (!c || c->node < 0)
 				continue;
@@ -4353,7 +4242,7 @@ static int show_stat(struct kmem_cache *
 		return -ENOMEM;
 
 	for_each_online_cpu(cpu) {
-		unsigned x = get_cpu_slab(s, cpu)->stat[si];
+		unsigned x = per_cpu_ptr(s->cpu_slab, cpu)->stat[si];
 
 		data[cpu] = x;
 		sum += x;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
