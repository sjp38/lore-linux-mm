Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ECE8A5F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 09:07:20 -0500 (EST)
Date: Tue, 3 Feb 2009 15:07:12 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/2] slqb: dynamic array allocations
Message-ID: <20090203140712.GB8723@wotan.suse.de>
References: <20090203135559.GA8723@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090203135559.GA8723@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Well I promised to improve this situation before slqb can go upstream, so
here it is.

It would be nice to keep this changeset in history if it gets merged upstream.
I don't know for sure if there won't be a performance impact.

--

Implement dynamic allocation for SLQB per-cpu and per-node arrays. This
should hopefully have minimal runtime performance impact, because although
there is an extra level of indirection to do allocations, the pointer should
be in the cache hot area of the struct kmem_cache.

It's not quite possible to use dynamic percpu allocator for this: firstly,
that subsystem uses the slab allocator. Secondly, it doesn't have good
support for per-node data. If those problems were improved, we could use it.
For now, just implement a very very simple allocator until the kmalloc
caches are up.

On x86-64 with a NUMA MAXCPUS config, sizes look like this:
   text    data     bss     dec     hex filename
  29960  259565     100  289625   46b59 mm/slab.o
  34130  497130     696  531956   81df4 mm/slub.o
  24575 1634267  111136 1769978  1b01fa mm/slqb.o
  24845   13959     712   39516    9a5c mm/slqb.o + this patch

SLQB is now 2 orders of magnitude smaller than it was, and an order of
magnitude smaller than SLAB or SLUB (in total size -- text size has
always been smaller). So it should now be very suitable for distro-type
configs in this respect.

As a side-effect the UP version of cpu_slab (which is embedded directly
in the kmem_cache struct) moves up to the hot cachelines, so it need no
longer be cacheline aligned on UP. The overall result should be a
reduction in cacheline footprint on UP kernels.

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 include/linux/slqb_def.h |   21 ++++----
 mm/slqb.c                |  117 +++++++++++++++++++++++++++++++++++------------
 2 files changed, 99 insertions(+), 39 deletions(-)

Index: linux-2.6/include/linux/slqb_def.h
===================================================================
--- linux-2.6.orig/include/linux/slqb_def.h
+++ linux-2.6/include/linux/slqb_def.h
@@ -111,7 +111,7 @@ struct kmem_cache_cpu {
 	struct kmlist		rlist;
 	struct kmem_cache_list	*remote_cache_list;
 #endif
-} ____cacheline_aligned;
+} ____cacheline_aligned_in_smp;
 
 /*
  * Per-node, per-kmem_cache structure. Used for node-specific allocations.
@@ -128,10 +128,19 @@ struct kmem_cache {
 	unsigned long	flags;
 	int		hiwater;	/* LIFO list high watermark */
 	int		freebatch;	/* LIFO freelist batch flush size */
+#ifdef CONFIG_SMP
+	struct kmem_cache_cpu	**cpu_slab; /* dynamic per-cpu structures */
+#else
+	struct kmem_cache_cpu	cpu_slab;
+#endif
 	int		objsize;	/* Size of object without meta data */
 	int		offset;		/* Free pointer offset. */
 	int		objects;	/* Number of objects in slab */
 
+#ifdef CONFIG_NUMA
+	struct kmem_cache_node	**node_slab; /* dynamic per-node structures */
+#endif
+
 	int		size;		/* Size of object including meta data */
 	int		order;		/* Allocation order */
 	gfp_t		allocflags;	/* gfp flags to use on allocation */
@@ -148,15 +157,7 @@ struct kmem_cache {
 #ifdef CONFIG_SLQB_SYSFS
 	struct kobject	kobj;		/* For sysfs */
 #endif
-#ifdef CONFIG_NUMA
-	struct kmem_cache_node	*node[MAX_NUMNODES];
-#endif
-#ifdef CONFIG_SMP
-	struct kmem_cache_cpu	*cpu_slab[NR_CPUS];
-#else
-	struct kmem_cache_cpu	cpu_slab;
-#endif
-};
+} ____cacheline_aligned;
 
 /*
  * Kmalloc subsystem.
Index: linux-2.6/mm/slqb.c
===================================================================
--- linux-2.6.orig/mm/slqb.c
+++ linux-2.6/mm/slqb.c
@@ -56,7 +56,6 @@ static inline void struct_slqb_page_wron
 
 #define PG_SLQB_BIT (1 << PG_slab)
 
-static int kmem_size __read_mostly;
 #ifdef CONFIG_NUMA
 static inline int slab_numa(struct kmem_cache *s)
 {
@@ -1329,7 +1328,7 @@ static noinline void *__slab_alloc_page(
 #ifdef CONFIG_NUMA
 		struct kmem_cache_node *n;
 
-		n = s->node[slqb_page_to_nid(page)];
+		n = s->node_slab[slqb_page_to_nid(page)];
 		l = &n->list;
 		page->list = l;
 
@@ -1373,7 +1372,7 @@ static void *__remote_slab_alloc_node(st
 	struct kmem_cache_list *l;
 	void *object;
 
-	n = s->node[node];
+	n = s->node_slab[node];
 	if (unlikely(!n)) /* node has no memory */
 		return NULL;
 	l = &n->list;
@@ -1818,7 +1817,7 @@ static void init_kmem_cache_node(struct
 }
 #endif
 
-/* Initial slabs. XXX: allocate dynamically (with bootmem maybe) */
+/* Initial slabs. */
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct kmem_cache_cpu, kmem_cache_cpus);
 #endif
@@ -1912,10 +1911,10 @@ static void free_kmem_cache_nodes(struct
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n;
 
-		n = s->node[node];
+		n = s->node_slab[node];
 		if (n) {
 			kmem_cache_free(&kmem_node_cache, n);
-			s->node[node] = NULL;
+			s->node_slab[node] = NULL;
 		}
 	}
 }
@@ -1933,7 +1932,7 @@ static int alloc_kmem_cache_nodes(struct
 			return 0;
 		}
 		init_kmem_cache_node(s, n);
-		s->node[node] = n;
+		s->node_slab[node] = n;
 	}
 	return 1;
 }
@@ -2069,13 +2068,56 @@ static int calculate_sizes(struct kmem_c
 
 }
 
+#ifdef CONFIG_SMP
+/*
+ * Per-cpu allocator can't be used because it always uses slab allocator,
+ * and it can't do per-node allocations.
+ */
+static void *kmem_cache_dyn_array_alloc(int ids)
+{
+	size_t size = sizeof(void *) * ids;
+
+	if (unlikely(!slab_is_available())) {
+		static void *nextmem;
+		void *ret;
+
+		/*
+		 * Special case for setting up initial caches. These will
+		 * never get freed by definition so we can do it rather
+		 * simply.
+		 */
+		if (!nextmem) {
+			nextmem = alloc_pages_exact(size, GFP_KERNEL);
+			if (!nextmem)
+				return NULL;
+		}
+		ret = nextmem;
+		nextmem = (void *)((unsigned long)ret + size);
+		if ((unsigned long)ret >> PAGE_SHIFT !=
+				(unsigned long)nextmem >> PAGE_SHIFT)
+			nextmem = NULL;
+		memset(ret, 0, size);
+		return ret;
+	} else {
+		return kzalloc(size, GFP_KERNEL);
+	}
+}
+
+static void kmem_cache_dyn_array_free(void *array)
+{
+	if (unlikely(!slab_is_available()))
+		return; /* error case without crashing here (will panic soon) */
+	kfree(array);
+}
+#endif
+
 static int kmem_cache_open(struct kmem_cache *s,
 			const char *name, size_t size, size_t align,
 			unsigned long flags, void (*ctor)(void *), int alloc)
 {
 	unsigned int left_over;
 
-	memset(s, 0, kmem_size);
+	memset(s, 0, sizeof(struct kmem_cache));
 	s->name = name;
 	s->ctor = ctor;
 	s->objsize = size;
@@ -2094,10 +2136,26 @@ static int kmem_cache_open(struct kmem_c
 		s->colour_range = 0;
 	}
 
+	/*
+	 * Protect all alloc_kmem_cache_cpus/nodes allocations with slqb_lock
+	 * to lock out hotplug, just in case (probably not strictly needed
+	 * here).
+	 */
 	down_write(&slqb_lock);
+#ifdef CONFIG_SMP
+	s->cpu_slab = kmem_cache_dyn_array_alloc(nr_cpu_ids);
+	if (!s->cpu_slab)
+		goto error_lock;
+# ifdef CONFIG_NUMA
+	s->node_slab = kmem_cache_dyn_array_alloc(nr_node_ids);
+	if (!s->node_slab)
+		goto error_cpu_array;
+# endif
+#endif
+
 	if (likely(alloc)) {
 		if (!alloc_kmem_cache_nodes(s))
-			goto error_lock;
+			goto error_node_array;
 
 		if (!alloc_kmem_cache_cpus(s))
 			goto error_nodes;
@@ -2111,6 +2169,14 @@ static int kmem_cache_open(struct kmem_c
 
 error_nodes:
 	free_kmem_cache_nodes(s);
+error_node_array:
+#ifdef CONFIG_NUMA
+	kmem_cache_dyn_array_free(s->node_slab);
+#endif
+error_cpu_array:
+#ifdef CONFIG_SMP
+	kmem_cache_dyn_array_free(s->cpu_slab);
+#endif
 error_lock:
 	up_write(&slqb_lock);
 error:
@@ -2152,7 +2218,7 @@ int kmem_ptr_validate(struct kmem_cache
 	page = virt_to_head_slqb_page(ptr);
 	if (unlikely(!(page->flags & PG_SLQB_BIT)))
 		goto out;
-	if (unlikely(page->list->cache != s))
+	if (unlikely(page->list->cache != s)) /* XXX: ouch, racy */
 		goto out;
 	return 1;
 out:
@@ -2220,7 +2286,7 @@ void kmem_cache_destroy(struct kmem_cach
 		struct kmem_cache_node *n;
 		struct kmem_cache_list *l;
 
-		n = s->node[node];
+		n = s->node_slab[node];
 		if (!n)
 			continue;
 		l = &n->list;
@@ -2449,7 +2515,7 @@ int kmem_cache_shrink(struct kmem_cache
 		struct kmem_cache_node *n;
 		struct kmem_cache_list *l;
 
-		n = s->node[node];
+		n = s->node_slab[node];
 		if (!n)
 			continue;
 		l = &n->list;
@@ -2502,7 +2568,7 @@ static void kmem_cache_reap(void)
 			struct kmem_cache_node *n;
 			struct kmem_cache_list *l;
 
-			n = s->node[node];
+			n = s->node_slab[node];
 			if (!n)
 				continue;
 			l = &n->list;
@@ -2529,7 +2595,7 @@ static void cache_trim_worker(struct wor
 	list_for_each_entry(s, &slab_caches, list) {
 #ifdef CONFIG_NUMA
 		int node = numa_node_id();
-		struct kmem_cache_node *n = s->node[node];
+		struct kmem_cache_node *n = s->node_slab[node];
 
 		if (n) {
 			struct kmem_cache_list *l = &n->list;
@@ -2618,7 +2684,7 @@ static int slab_mem_going_online_callbac
 		 *      since memory is not yet available from the node that
 		 *      is brought up.
 		 */
-		if (s->node[nid]) /* could be lefover from last online */
+		if (s->node_slab[nid]) /* could be lefover from last online */
 			continue;
 		n = kmem_cache_alloc(&kmem_node_cache, GFP_KERNEL);
 		if (!n) {
@@ -2626,7 +2692,7 @@ static int slab_mem_going_online_callbac
 			goto out;
 		}
 		init_kmem_cache_node(s, n);
-		s->node[nid] = n;
+		s->node_slab[nid] = n;
 	}
 out:
 	up_write(&slqb_lock);
@@ -2673,15 +2739,8 @@ void __init kmem_cache_init(void)
 	 * All the ifdefs are rather ugly here, but it's just the setup code,
 	 * so it doesn't have to be too readable :)
 	 */
-#ifdef CONFIG_SMP
-	kmem_size = offsetof(struct kmem_cache, cpu_slab) +
-				nr_cpu_ids * sizeof(struct kmem_cache_cpu *);
-#else
-	kmem_size = sizeof(struct kmem_cache);
-#endif
-
 	kmem_cache_open(&kmem_cache_cache, "kmem_cache",
-			kmem_size, 0, flags, NULL, 0);
+			sizeof(struct kmem_cache), 0, flags, NULL, 0);
 #ifdef CONFIG_SMP
 	kmem_cache_open(&kmem_cpu_cache, "kmem_cache_cpu",
 			sizeof(struct kmem_cache_cpu), 0, flags, NULL, 0);
@@ -2719,15 +2778,15 @@ void __init kmem_cache_init(void)
 
 		n = &per_cpu(kmem_cache_nodes, i);
 		init_kmem_cache_node(&kmem_cache_cache, n);
-		kmem_cache_cache.node[i] = n;
+		kmem_cache_cache.node_slab[i] = n;
 
 		n = &per_cpu(kmem_cpu_nodes, i);
 		init_kmem_cache_node(&kmem_cpu_cache, n);
-		kmem_cpu_cache.node[i] = n;
+		kmem_cpu_cache.node_slab[i] = n;
 
 		n = &per_cpu(kmem_node_nodes, i);
 		init_kmem_cache_node(&kmem_node_cache, n);
-		kmem_node_cache.node[i] = n;
+		kmem_node_cache.node_slab[i] = n;
 	}
 #endif
 
@@ -2793,7 +2852,7 @@ void __init kmem_cache_init(void)
 #endif
 	/*
 	 * smp_init() has not yet been called, so no worries about memory
-	 * ordering here (eg. slab_is_available vs numa_platform)
+	 * ordering with __slab_is_available.
 	 */
 	__slab_is_available = 1;
 }
@@ -3036,7 +3095,7 @@ static void gather_stats(struct kmem_cac
 
 #ifdef CONFIG_NUMA
 	for_each_online_node(node) {
-		struct kmem_cache_node *n = s->node[node];
+		struct kmem_cache_node *n = s->node_slab[node];
 		struct kmem_cache_list *l = &n->list;
 		struct slqb_page *page;
 		unsigned long flags;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
