Date: Wed, 23 May 2007 19:49:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070524020530.GA13694@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705231945450.23981@schroedinger.engr.sgi.com>
References: <20070523071200.GB9449@wotan.suse.de>
 <Pine.LNX.4.64.0705230956160.19822@schroedinger.engr.sgi.com>
 <20070523183224.GD11115@waste.org> <Pine.LNX.4.64.0705231208380.21222@schroedinger.engr.sgi.com>
 <20070523195824.GF11115@waste.org> <Pine.LNX.4.64.0705231300070.21541@schroedinger.engr.sgi.com>
 <20070523210612.GI11115@waste.org> <Pine.LNX.4.64.0705231524140.22666@schroedinger.engr.sgi.com>
 <20070523224206.GN11115@waste.org> <Pine.LNX.4.64.0705231544310.22857@schroedinger.engr.sgi.com>
 <20070524020530.GA13694@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Here is what I got trying to trim down SLUB on x84_64 (UP config)

Full:

   text    data     bss     dec     hex filename
  25928   11351     256   37535    929f mm/slub.o

!CONFIG_SLUB_DEBUG + patch below

   text    data     bss     dec     hex filename
   8639    4735     224   13598    351e mm/slub.o

SLOB

   text    data     bss     dec     hex filename
   4206      96       0    4302    10ce mm/slob.o

So we can get down to about double the text size. Data is of course an 
issue. Other 64 bit platforms bloat the code significantly.

Interesting that inlining some functions actually saves memory.

SLUB embedded: Reduce memory use II

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slub_def.h |    4 +++
 mm/slub.c                |   49 ++++++++++++++++++++++++++++++++---------------
 2 files changed, 38 insertions(+), 15 deletions(-)

Index: slub/include/linux/slub_def.h
===================================================================
--- slub.orig/include/linux/slub_def.h	2007-05-23 19:34:50.000000000 -0700
+++ slub/include/linux/slub_def.h	2007-05-23 19:35:12.000000000 -0700
@@ -17,7 +17,9 @@ struct kmem_cache_node {
 	unsigned long nr_partial;
 	atomic_long_t nr_slabs;
 	struct list_head partial;
+#ifdef CONFIG_SLUB_DEBUG
 	struct list_head full;
+#endif
 };
 
 /*
@@ -45,7 +47,9 @@ struct kmem_cache {
 	int align;		/* Alignment */
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
+#ifdef CONFIG_SLUB_DEBUG
 	struct kobject kobj;	/* For sysfs */
+#endif
 
 #ifdef CONFIG_NUMA
 	int defrag_ratio;
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-23 19:34:50.000000000 -0700
+++ slub/mm/slub.c	2007-05-23 19:35:12.000000000 -0700
@@ -183,7 +183,11 @@ static inline void ClearSlabDebug(struct
  * Mininum number of partial slabs. These will be left on the partial
  * lists even if they are empty. kmem_cache_shrink may reclaim them.
  */
+#ifdef CONFIG_SLUB_DEBUG
 #define MIN_PARTIAL 2
+#else
+#define MIN_PARTIAL 0
+#endif
 
 /*
  * Maximum number of desirable partial slabs.
@@ -254,9 +258,9 @@ static int sysfs_slab_add(struct kmem_ca
 static int sysfs_slab_alias(struct kmem_cache *, const char *);
 static void sysfs_slab_remove(struct kmem_cache *);
 #else
-static int sysfs_slab_add(struct kmem_cache *s) { return 0; }
-static int sysfs_slab_alias(struct kmem_cache *s, const char *p) { return 0; }
-static void sysfs_slab_remove(struct kmem_cache *s) {}
+static inline int sysfs_slab_add(struct kmem_cache *s) { return 0; }
+static inline int sysfs_slab_alias(struct kmem_cache *s, const char *p) { return 0; }
+static inline void sysfs_slab_remove(struct kmem_cache *s) {}
 #endif
 
 /********************************************************************
@@ -1011,7 +1015,7 @@ static struct page *allocate_slab(struct
 	return page;
 }
 
-static void setup_object(struct kmem_cache *s, struct page *page,
+static inline void setup_object(struct kmem_cache *s, struct page *page,
 				void *object)
 {
 	setup_object_debug(s, page, object);
@@ -1346,7 +1350,7 @@ static void deactivate_slab(struct kmem_
 	unfreeze_slab(s, page);
 }
 
-static void flush_slab(struct kmem_cache *s, struct page *page, int cpu)
+static inline void flush_slab(struct kmem_cache *s, struct page *page, int cpu)
 {
 	slab_lock(page);
 	deactivate_slab(s, page, cpu);
@@ -1356,7 +1360,7 @@ static void flush_slab(struct kmem_cache
  * Flush cpu slab.
  * Called from IPI handler with interrupts disabled.
  */
-static void __flush_cpu_slab(struct kmem_cache *s, int cpu)
+static inline void __flush_cpu_slab(struct kmem_cache *s, int cpu)
 {
 	struct page *page = s->cpu_slab[cpu];
 
@@ -1490,7 +1494,7 @@ debug:
  *
  * Otherwise we can simply pick the next object from the lockless free list.
  */
-static void __always_inline *slab_alloc(struct kmem_cache *s,
+static void *slab_alloc(struct kmem_cache *s,
 				gfp_t gfpflags, int node, void *addr)
 {
 	struct page *page;
@@ -1595,7 +1599,7 @@ debug:
  * If fastpath is not possible then fall back to __slab_free where we deal
  * with all sorts of special processing.
  */
-static void __always_inline slab_free(struct kmem_cache *s,
+static void slab_free(struct kmem_cache *s,
 			struct page *page, void *x, void *addr)
 {
 	void **object = (void *)x;
@@ -1764,7 +1768,7 @@ static inline int calculate_order(int si
 /*
  * Figure out what the alignment of the objects will be.
  */
-static unsigned long calculate_alignment(unsigned long flags,
+static inline unsigned long calculate_alignment(unsigned long flags,
 		unsigned long align, unsigned long size)
 {
 	/*
@@ -1786,13 +1790,15 @@ static unsigned long calculate_alignment
 	return ALIGN(align, sizeof(void *));
 }
 
-static void init_kmem_cache_node(struct kmem_cache_node *n)
+static inline void init_kmem_cache_node(struct kmem_cache_node *n)
 {
 	n->nr_partial = 0;
 	atomic_long_set(&n->nr_slabs, 0);
 	spin_lock_init(&n->list_lock);
 	INIT_LIST_HEAD(&n->partial);
+#ifdef CONFIG_SLUB_DEBUG
 	INIT_LIST_HEAD(&n->full);
+#endif
 }
 
 #ifdef CONFIG_NUMA
@@ -1877,11 +1883,11 @@ static int init_kmem_cache_nodes(struct 
 	return 1;
 }
 #else
-static void free_kmem_cache_nodes(struct kmem_cache *s)
+static inline void free_kmem_cache_nodes(struct kmem_cache *s)
 {
 }
 
-static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
+static inline int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
 {
 	init_kmem_cache_node(&s->local_node);
 	return 1;
@@ -2278,8 +2284,9 @@ size_t ksize(const void *object)
 
 	BUG_ON(!page);
 	s = page->slab;
-	BUG_ON(!s);
 
+#ifdef CONFIG_SLUB_DEBUG
+	BUG_ON(!s);
 	/*
 	 * Debugging requires use of the padding between object
 	 * and whatever may come after it.
@@ -2295,6 +2302,8 @@ size_t ksize(const void *object)
 	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
 		return s->inuse;
 
+#endif
+
 	/*
 	 * Else we can use all the padding etc for the allocation
 	 */
@@ -2329,6 +2338,7 @@ EXPORT_SYMBOL(kfree);
  */
 int kmem_cache_shrink(struct kmem_cache *s)
 {
+#ifdef CONFIG_SLUB_DEBUG
 	int node;
 	int i;
 	struct kmem_cache_node *n;
@@ -2392,6 +2402,9 @@ int kmem_cache_shrink(struct kmem_cache 
 	}
 
 	kfree(slabs_by_inuse);
+#else
+	flush_all(s);
+#endif
 	return 0;
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
@@ -2475,10 +2488,12 @@ void __init kmem_cache_init(void)
 
 	slab_state = UP;
 
+#ifdef CONFIG_SLUB_DEBUG
 	/* Provide the correct kmalloc names now that the caches are up */
 	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++)
 		kmalloc_caches[i]. name =
 			kasprintf(GFP_KERNEL, "kmalloc-%d", 1 << i);
+#endif
 
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);
@@ -3659,17 +3674,20 @@ static int sysfs_slab_alias(struct kmem_
 	return 0;
 }
 
+#endif
 static int __init slab_sysfs_init(void)
 {
 	struct list_head *h;
 	int err;
 
+#ifdef CONFIG_SLUB_DEBUG
 	err = subsystem_register(&slab_subsys);
 	if (err) {
 		printk(KERN_ERR "Cannot register slab subsystem.\n");
 		return -ENOSYS;
 	}
 
+#endif
 	slab_state = SYSFS;
 
 	list_for_each(h, &slab_caches) {
@@ -3678,8 +3696,10 @@ static int __init slab_sysfs_init(void)
 
 		err = sysfs_slab_add(s);
 		BUG_ON(err);
+		kmem_cache_shrink(s);
 	}
 
+#ifdef CONFIG_SLUB_DEBUG
 	while (alias_list) {
 		struct saved_alias *al = alias_list;
 
@@ -3690,8 +3710,7 @@ static int __init slab_sysfs_init(void)
 	}
 
 	resiliency_test();
+#endif
 	return 0;
 }
-
 __initcall(slab_sysfs_init);
-#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
