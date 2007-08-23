From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 5/6] SLUB: Place kmem_cache_cpu structures in a NUMA aware way
Date: Wed, 22 Aug 2007 23:46:58 -0700
Message-ID: <20070823064734.766659809@sgi.com>
References: <20070823064653.081843729@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760562AbXHWGt2@vger.kernel.org>
Content-Disposition: inline; filename=0009-SLUB-Place-kmem_cache_cpu-structures-in-a-NUMA-awar.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-Id: linux-mm.kvack.org

The kmem_cache_cpu structures introduced are currently an array placed in the
kmem_cache struct. Meaning the kmem_cache_cpu structures are overwhelmingly
on the wrong node for systems with a higher amount of nodes. These are
performance critical structures since the per node information has
to be touched for every alloc and free in a slab.

In order to place the kmem_cache_cpu structure optimally we put an array
of pointers to kmem_cache_cpu structs in kmem_cache (similar to SLAB).

However, the kmem_cache_cpu structures can now be allocated in a more
intelligent way.

We would like to put per cpu structures for the same cpu but different
slab caches in cachelines together to save space and decrease the cache
footprint. However, the slab allocators itself control only allocations
per node. We set up a simple per cpu array for every processor with
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
 include/linux/slub_def.h |    9 +-
 mm/slub.c                |  162 ++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 154 insertions(+), 17 deletions(-)

Index: linux-2.6.23-rc3-mm1/include/linux/slub_def.h
===================================================================
--- linux-2.6.23-rc3-mm1.orig/include/linux/slub_def.h	2007-08-22 17:23:29.000000000 -0700
+++ linux-2.6.23-rc3-mm1/include/linux/slub_def.h	2007-08-22 17:23:47.000000000 -0700
@@ -16,8 +16,7 @@ struct kmem_cache_cpu {
 	struct page *page;
 	int node;
 	unsigned int offset;
-	/* Lots of wasted space */
-} ____cacheline_aligned_in_smp;
+};
 
 struct kmem_cache_node {
 	spinlock_t list_lock;	/* Protect partial list and nr_partial */
@@ -62,7 +61,11 @@ struct kmem_cache {
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
Index: linux-2.6.23-rc3-mm1/mm/slub.c
===================================================================
--- linux-2.6.23-rc3-mm1.orig/mm/slub.c	2007-08-22 17:23:40.000000000 -0700
+++ linux-2.6.23-rc3-mm1/mm/slub.c	2007-08-22 17:23:47.000000000 -0700
@@ -276,7 +276,11 @@ static inline struct kmem_cache_node *ge
 
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
@@ -1843,16 +1847,6 @@ static void init_kmem_cache_cpu(struct k
 	c->node = 0;
 }
 
-static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
-{
-	int cpu;
-
-	for_each_possible_cpu(cpu)
-		init_kmem_cache_cpu(s, get_cpu_slab(s, cpu));
-
-	return 1;
-}
-
 static void init_kmem_cache_node(struct kmem_cache_node *n)
 {
 	n->nr_partial = 0;
@@ -1864,6 +1858,125 @@ static void init_kmem_cache_node(struct 
 #endif
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
+static struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s,
+							int cpu, gfp_t flags)
+{
+	struct kmem_cache_cpu *c = per_cpu(kmem_cache_cpu_free, cpu);
+
+	if (c)
+		per_cpu(kmem_cache_cpu_free, cpu) =
+				(void *)c->freelist;
+	else {
+		/* Table overflow: So allocate ourselves */
+		c = kmalloc_node(
+			ALIGN(sizeof(struct kmem_cache_cpu), cache_line_size()),
+			flags, cpu_to_node(cpu));
+		if (!c)
+			return NULL;
+	}
+
+	init_kmem_cache_cpu(s, c);
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
+	c->freelist = (void *)per_cpu(kmem_cache_cpu_free, cpu);
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
+		c = alloc_kmem_cache_cpu(s, cpu, flags);
+		if (!c) {
+			free_kmem_cache_cpus(s);
+			return 0;
+		}
+		s->cpu_slab[cpu] = c;
+	}
+	return 1;
+}
+
+/*
+ * Initialize the per cpu array.
+ */
+static void init_alloc_cpu_cpu(int cpu)
+{
+	int i;
+
+	for (i = NR_KMEM_CACHE_CPU - 1; i >= 0; i--)
+		free_kmem_cache_cpu(&per_cpu(kmem_cache_cpu, cpu)[i], cpu);
+}
+
+static void __init init_alloc_cpu(void)
+{
+	int cpu;
+
+	for_each_online_cpu(cpu)
+		init_alloc_cpu_cpu(cpu);
+  }
+
+#else
+static inline void free_kmem_cache_cpus(struct kmem_cache *s) {}
+static inline void init_alloc_cpu(void) {}
+
+static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
+{
+	init_kmem_cache_cpu(s, &s->cpu_slab);
+	return 1;
+}
+#endif
+
 #ifdef CONFIG_NUMA
 /*
  * No kmalloc_node yet so do it by hand. We know that this is the first
@@ -1871,7 +1984,8 @@ static void init_kmem_cache_node(struct 
  * possible.
  *
  * Note that this function only works on the kmalloc_node_cache
- * when allocating for the kmalloc_node_cache.
+ * when allocating for the kmalloc_node_cache. This is used for bootstrapping
+ * memory on a fresh node that has no slab structures yet.
  */
 static struct kmem_cache_node *early_kmem_cache_node_alloc(gfp_t gfpflags,
 							   int node)
@@ -2102,6 +2216,7 @@ static int kmem_cache_open(struct kmem_c
 	if (alloc_kmem_cache_cpus(s, gfpflags & ~SLUB_DMA))
 		return 1;
 
+	free_kmem_cache_nodes(s);
 error:
 	if (flags & SLAB_PANIC)
 		panic("Cannot create slab %s size=%lu realsize=%u "
@@ -2184,6 +2299,7 @@ static inline int kmem_cache_close(struc
 	flush_all(s);
 
 	/* Attempt to free all objects */
+	free_kmem_cache_cpus(s);
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
@@ -2580,6 +2696,8 @@ void __init kmem_cache_init(void)
 		slub_min_objects = DEFAULT_ANTIFRAG_MIN_OBJECTS;
 	}
 
+	init_alloc_cpu();
+
 #ifdef CONFIG_NUMA
 	/*
 	 * Must first have the slab cache available for the allocations of the
@@ -2640,10 +2758,12 @@ void __init kmem_cache_init(void)
 
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);
+	kmem_size = offsetof(struct kmem_cache, cpu_slab) +
+				nr_cpu_ids * sizeof(struct kmem_cache_cpu *);
+#else
+	kmem_size = sizeof(struct kmem_cache);
 #endif
 
-	kmem_size = offsetof(struct kmem_cache, cpu_slab) +
-				nr_cpu_ids * sizeof(struct kmem_cache_cpu);
 
 	printk(KERN_INFO "SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d, MinObjects=%d,"
 		" CPUs=%d, Nodes=%d\n",
@@ -2771,15 +2891,29 @@ static int __cpuinit slab_cpuup_callback
 	unsigned long flags;
 
 	switch (action) {
+	case CPU_UP_PREPARE:
+	case CPU_UP_PREPARE_FROZEN:
+		init_alloc_cpu_cpu(cpu);
+		down_read(&slub_lock);
+		list_for_each_entry(s, &slab_caches, list)
+			s->cpu_slab[cpu] = alloc_kmem_cache_cpu(s, cpu,
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
