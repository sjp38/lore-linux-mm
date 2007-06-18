Message-Id: <20070618095919.579023320@sgi.com>
References: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:59:04 -0700
From: clameter@sgi.com
Subject: [patch 26/26] SLUB: Place kmem_cache_cpu structures in a NUMA aware way.
Content-Disposition: inline; filename=slub_performance_numa_placement
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

The kmem_cache_cpu structures introduced are currently an array placed in the
kmem_cache struct. Meaning the kmem_cache_cpu structures are overwhelmingly
on the wrong node for systems with a higher amount of nodes. These are
performance critical structures since the per node information has
to be touched for every alloc and free in a slab.

In order to place the kmem_cache_cpu structure optimally we put an array
of pointers to kmem_cache_cpu structs in kmem_cache (similar to SLAB).

The kmem_cache_cpu structures can now be allocated in a more intelligent way.
We could put per cpu structures for the same cpu but different
slab caches in cachelines together to save space and decrease the cache
footprint. However, the slab allocators itself control only allocations
per node. Thus we set up a simple per cpu array for every processor with
100 per cpu structures which is usually enough to get them all set up right.
If we run out then we fall back to kmalloc_node. This also solves the
bootstrap problem since we do not have to use slab allocator functions
early in boot to get memory for the small per cpu structures.

Pro:
	- NUMA aware placement improves memory performance
	- All global structures in struct kmem_cache become readonly
	- Dense packing of per cpu structures reduces cacheline
	  footprint in SMP and NUMA.
	- Potential avoidance of exclusive cacheline fetches
	  on the free and alloc hotpath since multiple kmem_cache_cpu
	  structures are in one cacheline. This is particularly important
	  for the kmalloc array.

Cons:
	- Additional reference to one read only cacheline (per cpu
	  array of pointers to kmem_cache_cpu) in both slab_alloc()
	  and slab_free().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slub_def.h |    9 ++-
 mm/slub.c                |  131 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 133 insertions(+), 7 deletions(-)

Index: linux-2.6.22-rc4-mm2/include/linux/slub_def.h
===================================================================
--- linux-2.6.22-rc4-mm2.orig/include/linux/slub_def.h	2007-06-18 01:28:48.000000000 -0700
+++ linux-2.6.22-rc4-mm2/include/linux/slub_def.h	2007-06-18 01:34:52.000000000 -0700
@@ -16,8 +16,7 @@ struct kmem_cache_cpu {
 	struct page *page;
 	int objects;	/* Saved page->inuse */
 	int node;
-	/* Lots of wasted space */
-} ____cacheline_aligned_in_smp;
+};
 
 struct kmem_cache_node {
 	spinlock_t list_lock;	/* Protect partial list and nr_partial */
@@ -63,7 +62,11 @@ struct kmem_cache {
 	int defrag_ratio;
 	struct kmem_cache_node *node[MAX_NUMNODES];
 #endif
-	struct kmem_cache_cpu cpu_slab[NR_CPUS];
+#ifdef CONFIG_SMP
+	struct kmem_cache_cpu *cpu_slab[NR_CPUS];
+#else
+	struct kmem_cache_cpu cpu_slab;
+#endif
 };
 
 /*
Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-18 01:34:42.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-18 02:15:22.000000000 -0700
@@ -280,7 +280,11 @@ static inline struct kmem_cache_node *ge
 
 static inline struct kmem_cache_cpu *get_cpu_slab(struct kmem_cache *s, int cpu)
 {
-	return &s->cpu_slab[cpu];
+#ifdef CONFIG_SMP
+	return s->cpu_slab[cpu];
+#else
+	return &s->cpu_slab;
+#endif
 }
 
 static inline int check_valid_pointer(struct kmem_cache *s,
@@ -1924,14 +1928,126 @@ static void init_kmem_cache_node(struct 
 	INIT_LIST_HEAD(&n->full);
 }
 
+#ifdef CONFIG_SMP
+/*
+ * Per cpu array for per cpu structures.
+ *
+ * The per cpu array places all kmem_cache_cpu structures from one processor
+ * close together meaning that it becomes possible that multiple per cpu
+ * structures are contained in one cacheline. This may be particularly
+ * beneficial for the kmalloc caches.
+ *
+ * A desktop system typically has around 60-80 slabs. With 100 here we are
+ * likely able to get per cpu structures for all caches from the array defined
+ * here. We must be able to cover all kmalloc caches during bootstrap.
+ *
+ * If the per cpu array is exhausted then fall back to kmalloc
+ * of individual cachelines. No sharing is possible then.
+ */
+#define NR_KMEM_CACHE_CPU 100
+
+static DEFINE_PER_CPU(struct kmem_cache_cpu,
+				kmem_cache_cpu)[NR_KMEM_CACHE_CPU];
+
+static DEFINE_PER_CPU(struct kmem_cache_cpu *, kmem_cache_cpu_free);
+
+static struct kmem_cache_cpu *alloc_kmem_cache_cpu(int cpu, gfp_t flags)
+{
+	struct kmem_cache_cpu *c = per_cpu(kmem_cache_cpu_free, cpu);
+
+	if (c)
+		per_cpu(kmem_cache_cpu_free, cpu) =
+				(void *)c->lockless_freelist;
+	else {
+		/* Table overflow: So allocate ourselves */
+		c = kmalloc_node(
+			ALIGN(sizeof(struct kmem_cache_cpu), cache_line_size()),
+			flags, cpu_to_node(cpu));
+		if (!c)
+			return NULL;
+	}
+
+	memset(c, 0, sizeof(struct kmem_cache_cpu));
+	return c;
+}
+
+static void free_kmem_cache_cpu(struct kmem_cache_cpu *c, int cpu)
+{
+	if (c < per_cpu(kmem_cache_cpu, cpu) ||
+			c > per_cpu(kmem_cache_cpu, cpu) + NR_KMEM_CACHE_CPU) {
+		kfree(c);
+		return;
+	}
+	c->lockless_freelist = (void *)per_cpu(kmem_cache_cpu_free, cpu);
+	per_cpu(kmem_cache_cpu_free, cpu) = c;
+}
+
+static void free_kmem_cache_cpus(struct kmem_cache *s)
+{
+	int cpu;
+
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+
+		if (c) {
+			s->cpu_slab[cpu] = NULL;
+			free_kmem_cache_cpu(c, cpu);
+		}
+	}
+}
+
+static int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
+{
+	int cpu;
+
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+
+		if (c)
+			continue;
+
+		c = alloc_kmem_cache_cpu(cpu, flags);
+		if (!c) {
+			free_kmem_cache_cpus(s);
+			return 0;
+		}
+		s->cpu_slab[cpu] = c;
+	}
+	return 1;
+}
+
+static void __init init_alloc_cpu(void)
+{
+	int cpu;
+	int i;
+
+	for_each_online_cpu(cpu) {
+		for (i = NR_KMEM_CACHE_CPU - 1; i >= 0; i--)
+			free_kmem_cache_cpu(&per_cpu(kmem_cache_cpu, cpu)[i],
+								cpu);
+	}
+}
+
+#else
+static inline void free_kmem_cache_cpus(struct kmem_cache *s) {}
+static inline void init_alloc_cpu(struct kmem_cache *s) {}
+
+static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
+{
+	return 1;
+}
+#endif
+
 #ifdef CONFIG_NUMA
+
 /*
  * No kmalloc_node yet so do it by hand. We know that this is the first
  * slab on the node for this slabcache. There are no concurrent accesses
  * possible.
  *
  * Note that this function only works on the kmalloc_node_cache
- * when allocating for the kmalloc_node_cache.
+ * when allocating for the kmalloc_node_cache. This is used for bootstrapping
+ * memory on a fresh node that has no slab structures yet.
  */
 static struct kmem_cache_node * __init early_kmem_cache_node_alloc(gfp_t gfpflags,
 								int node)
@@ -2152,8 +2268,13 @@ static int kmem_cache_open(struct kmem_c
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
+	free_kmem_cache_nodes(s);
 error:
 	if (flags & SLAB_PANIC)
 		panic("Cannot create slab %s size=%lu realsize=%u "
@@ -2236,6 +2357,8 @@ static inline int kmem_cache_close(struc
 	flush_all(s);
 
 	/* Attempt to free all objects */
+	free_kmem_cache_cpus(s);
+
 	for_each_online_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
@@ -2908,6 +3031,8 @@ void __init kmem_cache_init(void)
 		slub_min_objects = DEFAULT_ANTIFRAG_MIN_OBJECTS;
 	}
 
+	init_alloc_cpu();
+
 #ifdef CONFIG_NUMA
 	/*
 	 * Must first have the slab cache available for the allocations of the
@@ -2971,7 +3096,7 @@ void __init kmem_cache_init(void)
 #endif
 
 	kmem_size = offsetof(struct kmem_cache, cpu_slab) +
-				nr_cpu_ids * sizeof(struct kmem_cache_cpu);
+				nr_cpu_ids * sizeof(struct kmem_cache_cpu *);
 
 	printk(KERN_INFO "SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d,"
 		" MinObjects=%d, CPUs=%d, Nodes=%d\n",
@@ -3116,15 +3241,28 @@ static int __cpuinit slab_cpuup_callback
 	unsigned long flags;
 
 	switch (action) {
+	case CPU_UP_PREPARE:
+	case CPU_UP_PREPARE_FROZEN:
+		down_read(&slub_lock);
+		list_for_each_entry(s, &slab_caches, list)
+			s->cpu_slab[cpu] = alloc_kmem_cache_cpu(cpu,
+							GFP_KERNEL);
+		up_read(&slub_lock);
+		break;
+
 	case CPU_UP_CANCELED:
 	case CPU_UP_CANCELED_FROZEN:
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN:
 		down_read(&slub_lock);
 		list_for_each_entry(s, &slab_caches, list) {
+			struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+
 			local_irq_save(flags);
 			__flush_cpu_slab(s, cpu);
 			local_irq_restore(flags);
+			free_kmem_cache_cpu(c, cpu);
+			s->cpu_slab[cpu] = NULL;
 		}
 		up_read(&slub_lock);
 		break;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
