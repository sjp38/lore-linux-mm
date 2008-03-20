Date: Thu, 20 Mar 2008 16:57:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 8/9] slub: Make the order configurable for each slab
 cache
In-Reply-To: <Pine.LNX.4.64.0803201130230.10474@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0803201656450.13349@schroedinger.engr.sgi.com>
References: <20080317230516.078358225@sgi.com>  <20080317230529.701336582@sgi.com>
 <1205992409.14496.48.camel@ymzhang> <Pine.LNX.4.64.0803201130230.10474@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here is a potential fix:

Subject: Fix race between allocate_slab and calculate sizes through word accesses

Fix the race by fetching the order and the number of objects in one word.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slub_def.h |   16 ++++++--
 mm/slub.c                |   87 +++++++++++++++++++++++++++++------------------
 2 files changed, 67 insertions(+), 36 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2008-03-20 16:13:51.843215895 -0700
+++ linux-2.6/include/linux/slub_def.h	2008-03-20 16:37:36.277897003 -0700
@@ -55,6 +55,15 @@ struct kmem_cache_node {
 };
 
 /*
+ * Word size structure that can be atomically updated or read and that
+ * contains both the order and the number of objects that a slab of the
+ * given order would contain.
+ */
+struct kmem_cache_order_objects {
+	unsigned long x;
+};
+
+/*
  * Slab cache management.
  */
 struct kmem_cache {
@@ -63,7 +72,7 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int objsize;		/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
-	int order;		/* Current preferred allocation order */
+	struct kmem_cache_order_objects active;
 
 	/*
 	 * Avoid an extra cache line for UP, SMP and for the node local to
@@ -72,9 +81,8 @@ struct kmem_cache {
 	struct kmem_cache_node local_node;
 
 	/* Allocation and freeing of slabs */
-	int max_objects;	/* Number of objects in a slab of maximum size */
-	int objects;		/* Number of objects in a slab of current size */
-	int min_objects;	/* Number of objects in a slab of mininum size */
+	struct kmem_cache_order_objects max;
+	struct kmem_cache_order_objects min;
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(struct kmem_cache *, void *);
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-03-20 16:13:51.855215725 -0700
+++ linux-2.6/mm/slub.c	2008-03-20 16:39:08.283420656 -0700
@@ -322,6 +322,25 @@ static inline int slab_index(void *p, st
 	return (p - addr) / s->size;
 }
 
+static inline struct kmem_cache_order_objects set_korder(int order,
+						unsigned long size)
+{
+	struct kmem_cache_order_objects x =
+			{ (order << 16) + (PAGE_SIZE << order) / size };
+
+	return x;
+}
+
+static inline int get_korder(struct kmem_cache_order_objects x)
+{
+	return x.x >> 16;
+}
+
+static inline int get_kobjects(struct kmem_cache_order_objects x)
+{
+	return x.x & ((1 << 16) - 1);
+}
+
 #ifdef CONFIG_SLUB_DEBUG
 /*
  * Debug settings:
@@ -1032,8 +1051,11 @@ static inline unsigned long kmem_cache_f
 #define slub_debug 0
 #endif
 
-static inline struct page *alloc_slab_page(gfp_t flags, int node, int order)
+static inline struct page *alloc_slab_page(gfp_t flags, int node,
+			struct kmem_cache_order_objects oo)
 {
+	int order = get_korder(oo);
+
 	if (node == -1)
 		return alloc_pages(flags, order);
 	else
@@ -1046,32 +1068,30 @@ static inline struct page *alloc_slab_pa
 static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page *page;
-	int pages = 1 << s->order;
+	struct kmem_cache_order_objects oo = s->active;
 
 	flags |= s->allocflags;
 
-	page = alloc_slab_page(flags | __GFP_NOWARN | __GFP_NORETRY,
-								node, s->order);
+	page = alloc_slab_page(flags | __GFP_NOWARN | __GFP_NORETRY, node, oo);
 	if (unlikely(!page)) {
 		/*
 		 * Allocation may have failed due to fragmentation.
 		 * Try a lower order alloc if possible
 		 */
-		page = alloc_slab_page(flags, node, get_order(s->size));
-		if (page) {
-			pages = 1 << compound_order(page);
-			stat(get_cpu_slab(s, raw_smp_processor_id()),
-							ORDER_FALLBACK);
-			page->objects = s->min_objects;
-		} else
+		oo = s->min;
+		page = alloc_slab_page(flags, node, oo);
+		if (!page)
 			return NULL;
-	} else
-		page->objects = s->objects;
+
+		stat(get_cpu_slab(s, raw_smp_processor_id()),
+							ORDER_FALLBACK);
+	}
+	page->objects = get_kobjects(oo);
 
 	mod_zone_page_state(page_zone(page),
 		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
-		pages);
+		1 << get_korder(oo));
 
 	return page;
 }
@@ -2151,6 +2171,7 @@ static int calculate_sizes(struct kmem_c
 	unsigned long flags = s->flags;
 	unsigned long size = s->objsize;
 	unsigned long align = s->align;
+	int order;
 
 	/*
 	 * Round up object size to the next word boundary. We can only
@@ -2236,15 +2257,15 @@ static int calculate_sizes(struct kmem_c
 	s->size = size;
 
 	if (forced_order >= 0)
-		s->order = forced_order;
+		order = forced_order;
 	else
-		s->order = calculate_order(size);
+		order = calculate_order(size);
 
-	if (s->order < 0)
+	if (order < 0)
 		return 0;
 
 	s->allocflags = 0;
-	if (s->order)
+	if (order)
 		s->allocflags |= __GFP_COMP;
 
 	if (s->flags & SLAB_CACHE_DMA)
@@ -2256,11 +2277,12 @@ static int calculate_sizes(struct kmem_c
 	/*
 	 * Determine the number of objects per slab
 	 */
-	s->objects = (PAGE_SIZE << s->order) / size;
-	s->min_objects = (PAGE_SIZE << get_order(size)) / size;
-	if (s->objects > s->max_objects)
-		s->max_objects = s->objects;
-	return !!s->objects;
+	s->active = set_korder(order, size);
+	s->min = set_korder(get_order(size), size);
+
+	if (get_kobjects(s->active) > get_kobjects(s->max))
+		s->max = s->active;
+	return !!get_kobjects(s->active);
 }
 
 static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
@@ -2292,7 +2314,7 @@ error:
 	if (flags & SLAB_PANIC)
 		panic("Cannot create slab %s size=%lu realsize=%u "
 			"order=%u offset=%u flags=%lx\n",
-			s->name, (unsigned long)size, s->size, s->order,
+			s->name, (unsigned long)size, s->size, get_korder(s->active),
 			s->offset, flags);
 	return 0;
 }
@@ -2734,7 +2756,7 @@ int kmem_cache_shrink(struct kmem_cache 
 	struct page *page;
 	struct page *t;
 	struct list_head *slabs_by_inuse =
-		kmalloc(sizeof(struct list_head) * s->max_objects, GFP_KERNEL);
+		kmalloc(sizeof(struct list_head) * get_kobjects(s->max), GFP_KERNEL);
 	unsigned long flags;
 
 	if (!slabs_by_inuse)
@@ -2747,7 +2769,7 @@ int kmem_cache_shrink(struct kmem_cache 
 		if (!n->nr_partial)
 			continue;
 
-		for (i = 0; i < s->max_objects; i++)
+		for (i = 0; i < get_kobjects(s->max); i++)
 			INIT_LIST_HEAD(slabs_by_inuse + i);
 
 		spin_lock_irqsave(&n->list_lock, flags);
@@ -2779,7 +2801,7 @@ int kmem_cache_shrink(struct kmem_cache 
 		 * Rebuild the partial list with the slabs filled up most
 		 * first and the least used slabs at the end.
 		 */
-		for (i = s->max_objects - 1; i >= 0; i--)
+		for (i = get_kobjects(s->max) - 1; i >= 0; i--)
 			list_splice(slabs_by_inuse + i, n->partial.prev);
 
 		spin_unlock_irqrestore(&n->list_lock, flags);
@@ -3277,8 +3299,8 @@ static long validate_slab_cache(struct k
 {
 	int node;
 	unsigned long count = 0;
-	unsigned long *map = kmalloc(BITS_TO_LONGS(s->max_objects) *
-				sizeof(unsigned long), GFP_KERNEL);
+	unsigned long *map = kmalloc(BITS_TO_LONGS(get_kobjects(s->max)) *
+			sizeof(unsigned long), GFP_KERNEL);
 
 	if (!map)
 		return -ENOMEM;
@@ -3727,7 +3749,7 @@ SLAB_ATTR_RO(object_size);
 
 static ssize_t objs_per_slab_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->objects);
+	return sprintf(buf, "%d\n", get_kobjects(s->active));
 }
 SLAB_ATTR_RO(objs_per_slab);
 
@@ -3745,7 +3767,7 @@ static ssize_t order_store(struct kmem_c
 
 static ssize_t order_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->order);
+	return sprintf(buf, "%d\n", get_korder(s->active));
 }
 SLAB_ATTR(order);
 
@@ -4410,7 +4432,8 @@ static int s_show(struct seq_file *m, vo
 	nr_inuse = nr_objs - nr_free;
 
 	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d", s->name, nr_inuse,
-		   nr_objs, s->size, s->objects, (1 << s->order));
+		   nr_objs, s->size, get_kobjects(s->active),
+		   (1 << get_korder(s->active)));
 	seq_printf(m, " : tunables %4u %4u %4u", 0, 0, 0);
 	seq_printf(m, " : slabdata %6lu %6lu %6lu", nr_slabs, nr_slabs,
 		   0UL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
