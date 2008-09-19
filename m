From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 1/3] cpu alloc: Use in slub
Date: Fri, 19 Sep 2008 13:37:04 -0700
Message-ID: <20080919203724.012145763@quilx.com>
References: <20080919203703.312007962@quilx.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline; filename=cpu_alloc_slub_conversion
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-Id: linux-mm.kvack.org

Using cpu alloc removes the needs for the per cpu arrays in the kmem_cache struct.
These could get quite big if we have to support system of up to thousands of cpus.
The use of cpu_alloc means that:

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

4. Fastpath performance increases.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2008-09-19 13:14:36.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2008-09-19 13:24:04.000000000 -0500
@@ -68,6 +68,7 @@
  * Slab cache management.
  */
 struct kmem_cache {
+	struct kmem_cache_cpu *cpu_slab;
 	/* Used for retriving partial slabs etc */
 	unsigned long flags;
 	int size;		/* The size of an object including meta data */
@@ -100,12 +101,7 @@
 	 * Defragmentation by allocating from a remote node.
 	 */
 	int remote_node_defrag_ratio;
-	struct kmem_cache_node *node[MAX_NUMNODES];
-#endif
-#ifdef CONFIG_SMP
-	struct kmem_cache_cpu *cpu_slab[NR_CPUS];
-#else
-	struct kmem_cache_cpu cpu_slab;
+	struct kmem_cache_node *node[];
 #endif
 };
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-09-19 13:14:36.000000000 -0500
+++ linux-2.6/mm/slub.c	2008-09-19 13:25:51.000000000 -0500
@@ -226,15 +226,6 @@
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
@@ -1087,7 +1078,7 @@
 		if (!page)
 			return NULL;
 
-		stat(get_cpu_slab(s, raw_smp_processor_id()), ORDER_FALLBACK);
+		stat(THIS_CPU(s->cpu_slab), ORDER_FALLBACK);
 	}
 	page->objects = oo_objects(oo);
 	mod_zone_page_state(page_zone(page),
@@ -1364,7 +1355,7 @@
 static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
-	struct kmem_cache_cpu *c = get_cpu_slab(s, smp_processor_id());
+	struct kmem_cache_cpu *c = THIS_CPU(s->cpu_slab);
 
 	__ClearPageSlubFrozen(page);
 	if (page->inuse) {
@@ -1396,7 +1387,7 @@
 			slab_unlock(page);
 		} else {
 			slab_unlock(page);
-			stat(get_cpu_slab(s, raw_smp_processor_id()), FREE_SLAB);
+			stat(__THIS_CPU(s->cpu_slab), FREE_SLAB);
 			discard_slab(s, page);
 		}
 	}
@@ -1449,7 +1440,7 @@
  */
 static inline void __flush_cpu_slab(struct kmem_cache *s, int cpu)
 {
-	struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+	struct kmem_cache_cpu *c = CPU_PTR(s->cpu_slab, cpu);
 
 	if (likely(c && c->page))
 		flush_slab(s, c);
@@ -1552,7 +1543,7 @@
 		local_irq_disable();
 
 	if (new) {
-		c = get_cpu_slab(s, smp_processor_id());
+		c = __THIS_CPU(s->cpu_slab);
 		stat(c, ALLOC_SLAB);
 		if (c->page)
 			flush_slab(s, c);
@@ -1588,24 +1579,22 @@
 	void **object;
 	struct kmem_cache_cpu *c;
 	unsigned long flags;
-	unsigned int objsize;
 
 	local_irq_save(flags);
-	c = get_cpu_slab(s, smp_processor_id());
-	objsize = c->objsize;
-	if (unlikely(!c->freelist || !node_match(c, node)))
+	c = __THIS_CPU(s->cpu_slab);
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
 
 	return object;
 }
@@ -1639,7 +1628,7 @@
 	void **object = (void *)x;
 	struct kmem_cache_cpu *c;
 
-	c = get_cpu_slab(s, raw_smp_processor_id());
+	c = __THIS_CPU(s->cpu_slab);
 	stat(c, FREE_SLOWPATH);
 	slab_lock(page);
 
@@ -1710,7 +1699,7 @@
 	unsigned long flags;
 
 	local_irq_save(flags);
-	c = get_cpu_slab(s, smp_processor_id());
+	c = __THIS_CPU(s->cpu_slab);
 	debug_check_no_locks_freed(object, c->objsize);
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(object, s->objsize);
@@ -1937,130 +1926,19 @@
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
-static DEFINE_PER_CPU(struct kmem_cache_cpu,
-				kmem_cache_cpu)[NR_KMEM_CACHE_CPU];
-
-static DEFINE_PER_CPU(struct kmem_cache_cpu *, kmem_cache_cpu_free);
-static cpumask_t kmem_cach_cpu_free_init_once = CPU_MASK_NONE;
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
-			c > per_cpu(kmem_cache_cpu, cpu) + NR_KMEM_CACHE_CPU) {
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
-
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
 static int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
 {
 	int cpu;
 
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
-	if (cpu_isset(cpu, kmem_cach_cpu_free_init_once))
-		return;
+	s->cpu_slab = CPU_ALLOC(struct kmem_cache_cpu, flags);
 
-	for (i = NR_KMEM_CACHE_CPU - 1; i >= 0; i--)
-		free_kmem_cache_cpu(&per_cpu(kmem_cache_cpu, cpu)[i], cpu);
-
-	cpu_set(cpu, kmem_cach_cpu_free_init_once);
-}
-
-static void __init init_alloc_cpu(void)
-{
-	int cpu;
-
-	for_each_online_cpu(cpu)
-		init_alloc_cpu_cpu(cpu);
-  }
-
-#else
-static inline void free_kmem_cache_cpus(struct kmem_cache *s) {}
-static inline void init_alloc_cpu(void) {}
+	if (!s->cpu_slab)
+		return 0;
 
-static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
-{
-	init_kmem_cache_cpu(s, &s->cpu_slab);
+	for_each_possible_cpu(cpu)
+		init_kmem_cache_cpu(s, CPU_PTR(s->cpu_slab, cpu));
 	return 1;
 }
-#endif
 
 #ifdef CONFIG_NUMA
 /*
@@ -2427,9 +2305,8 @@
 	int node;
 
 	flush_all(s);
-
+	CPU_FREE(s->cpu_slab);
 	/* Attempt to free all objects */
-	free_kmem_cache_cpus(s);
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
@@ -2946,8 +2823,6 @@
 	int i;
 	int caches = 0;
 
-	init_alloc_cpu();
-
 #ifdef CONFIG_NUMA
 	/*
 	 * Must first have the slab cache available for the allocations of the
@@ -3015,11 +2890,12 @@
 	for (i = KMALLOC_SHIFT_LOW; i <= PAGE_SHIFT; i++)
 		kmalloc_caches[i]. name =
 			kasprintf(GFP_KERNEL, "kmalloc-%d", 1 << i);
-
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
@@ -3115,7 +2991,7 @@
 		 * per cpu structures
 		 */
 		for_each_online_cpu(cpu)
-			get_cpu_slab(s, cpu)->objsize = s->objsize;
+			CPU_PTR(s->cpu_slab, cpu)->objsize = s->objsize;
 
 		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
 		up_write(&slub_lock);
@@ -3163,11 +3039,9 @@
 	switch (action) {
 	case CPU_UP_PREPARE:
 	case CPU_UP_PREPARE_FROZEN:
-		init_alloc_cpu_cpu(cpu);
 		down_read(&slub_lock);
 		list_for_each_entry(s, &slab_caches, list)
-			s->cpu_slab[cpu] = alloc_kmem_cache_cpu(s, cpu,
-							GFP_KERNEL);
+			init_kmem_cache_cpu(s, CPU_PTR(s->cpu_slab, cpu));
 		up_read(&slub_lock);
 		break;
 
@@ -3177,13 +3051,9 @@
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
@@ -3674,7 +3544,7 @@
 		int cpu;
 
 		for_each_possible_cpu(cpu) {
-			struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+			struct kmem_cache_cpu *c = CPU_PTR(s->cpu_slab, cpu);
 
 			if (!c || c->node < 0)
 				continue;
@@ -4079,7 +3949,7 @@
 		return -ENOMEM;
 
 	for_each_online_cpu(cpu) {
-		unsigned x = get_cpu_slab(s, cpu)->stat[si];
+		unsigned x = CPU_PTR(s->cpu_slab, cpu)->stat[si];
 
 		data[cpu] = x;
 		sum += x;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
