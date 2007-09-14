Date: Fri, 14 Sep 2007 15:18:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] SLUB: Make NUMA support optional on NUMA machines
Message-ID: <Pine.LNX.4.64.0709141518070.14856@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

NUMA support in the slab allocators may create unnecessary overhead for
small NUMA configurations (especially those that realize multiple nodes
on a motherboard like Opterons).

If NUMA support is disabled on a NUMA machines then the NUMA locality
controls will not work for slab allocations anymore. However, the resulting
memory imbalances and non optimal placements may not matter much if the
system is small.

Is this worth doing?

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2007-09-14 13:54:51.000000000 -0700
+++ linux-2.6/include/linux/slab.h	2007-09-14 13:54:56.000000000 -0700
@@ -178,7 +178,7 @@ static inline void *kcalloc(size_t n, si
 	return __kmalloc(n * size, flags | __GFP_ZERO);
 }
 
-#if !defined(CONFIG_NUMA) && !defined(CONFIG_SLOB)
+#if !defined(CONFIG_SLAB_NUMA) && !defined(CONFIG_SLOB)
 /**
  * kmalloc_node - allocate memory from a specific node
  * @size: how many bytes of memory are required.
@@ -206,7 +206,7 @@ static inline void *kmem_cache_alloc_nod
 {
 	return kmem_cache_alloc(cachep, flags);
 }
-#endif /* !CONFIG_NUMA && !CONFIG_SLOB */
+#endif /* !CONFIG_SLAB_NUMA && !CONFIG_SLOB */
 
 /*
  * kmalloc_track_caller is a special version of kmalloc that records the
@@ -225,7 +225,7 @@ extern void *__kmalloc_track_caller(size
 	__kmalloc(size, flags)
 #endif /* DEBUG_SLAB */
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 /*
  * kmalloc_node_track_caller is a special version of kmalloc_node that
  * records the calling function of the routine calling it for slab leak
@@ -244,7 +244,7 @@ extern void *__kmalloc_node_track_caller
 	__kmalloc_node(size, flags, node)
 #endif
 
-#else /* CONFIG_NUMA */
+#else /* CONFIG_SLAB_NUMA */
 
 #define kmalloc_node_track_caller(size, flags, node) \
 	kmalloc_track_caller(size, flags)
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2007-09-14 13:54:51.000000000 -0700
+++ linux-2.6/include/linux/slub_def.h	2007-09-14 13:54:56.000000000 -0700
@@ -58,7 +58,7 @@ struct kmem_cache {
 	struct kobject kobj;	/* For sysfs */
 #endif
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 	int defrag_ratio;
 	struct kmem_cache_node *node[MAX_NUMNODES];
 #endif
@@ -181,7 +181,7 @@ static __always_inline void *kmalloc(siz
 	return __kmalloc(size, flags);
 }
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-09-14 13:54:51.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-09-14 13:58:50.000000000 -0700
@@ -137,6 +137,12 @@ static inline void ClearSlabDebug(struct
 	page->flags &= ~SLABDEBUG;
 }
 
+#ifdef CONFIG_SLAB_NUMA
+#define node(x) page_to_nid(x)
+#else
+#define node(x) 0
+#endif
+
 /*
  * Issues still to be resolved:
  *
@@ -260,7 +266,7 @@ int slab_is_available(void)
 
 static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 {
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 	return s->node[node];
 #else
 	return &s->local_node;
@@ -813,7 +819,7 @@ static void remove_full(struct kmem_cach
 	if (!(s->flags & SLAB_STORE_USER))
 		return;
 
-	n = get_node(s, page_to_nid(page));
+	n = get_node(s, node(page));
 
 	spin_lock(&n->list_lock);
 	list_del(&page->lru);
@@ -1067,7 +1073,7 @@ static struct page *new_slab(struct kmem
 	if (!page)
 		goto out;
 
-	n = get_node(s, page_to_nid(page));
+	n = get_node(s, node(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
 	page->slab = s;
@@ -1141,7 +1147,7 @@ static void free_slab(struct kmem_cache 
 
 static void discard_slab(struct kmem_cache *s, struct page *page)
 {
-	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+	struct kmem_cache_node *n = get_node(s, node(page));
 
 	atomic_long_dec(&n->nr_slabs);
 	reset_page_mapcount(page);
@@ -1192,7 +1198,7 @@ static void add_partial(struct kmem_cach
 static void remove_partial(struct kmem_cache *s,
 						struct page *page)
 {
-	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+	struct kmem_cache_node *n = get_node(s, node(page));
 
 	spin_lock(&n->list_lock);
 	list_del(&page->lru);
@@ -1247,7 +1253,7 @@ out:
  */
 static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 {
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 	struct zonelist *zonelist;
 	struct zone **z;
 	struct page *page;
@@ -1315,7 +1321,7 @@ static struct page *get_partial(struct k
  */
 static void unfreeze_slab(struct kmem_cache *s, struct page *page)
 {
-	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+	struct kmem_cache_node *n = get_node(s, node(page));
 
 	ClearSlabFrozen(page);
 	if (page->inuse) {
@@ -1463,7 +1469,7 @@ load_freelist:
 	c->freelist = object[c->offset];
 	c->page->inuse = s->objects;
 	c->page->freelist = NULL;
-	c->node = page_to_nid(c->page);
+	c->node = node(c->page);
 	slab_unlock(c->page);
 	return object;
 
@@ -1566,7 +1572,7 @@ void *kmem_cache_alloc(struct kmem_cache
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
 	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
@@ -1609,7 +1615,7 @@ checks_ok:
 	 * then add it.
 	 */
 	if (unlikely(!prior))
-		add_partial(get_node(s, page_to_nid(page)), page);
+		add_partial(get_node(s, node(page)), page);
 
 out_unlock:
 	slab_unlock(page);
@@ -1979,7 +1985,7 @@ static inline int alloc_kmem_cache_cpus(
 }
 #endif
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 /*
  * No kmalloc_node yet so do it by hand. We know that this is the first
  * slab on the node for this slabcache. There are no concurrent accesses
@@ -2202,7 +2208,7 @@ static int kmem_cache_open(struct kmem_c
 		goto error;
 
 	s->refcount = 1;
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 	s->defrag_ratio = 100;
 #endif
 
@@ -2529,7 +2535,7 @@ void *__kmalloc(size_t size, gfp_t flags
 }
 EXPORT_SYMBOL(__kmalloc);
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	struct kmem_cache *s;
@@ -2683,7 +2689,7 @@ void __init kmem_cache_init(void)
 
 	init_alloc_cpu();
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 	/*
 	 * Must first have the slab cache available for the allocations of the
 	 * struct kmem_cache_node's. There is special bootstrap code in
@@ -2754,7 +2760,13 @@ void __init kmem_cache_init(void)
 		" CPUs=%d, Nodes=%d\n",
 		caches, cache_line_size(),
 		slub_min_order, slub_max_order, slub_min_objects,
-		nr_cpu_ids, nr_node_ids);
+		nr_cpu_ids,
+#ifdef CONFIG_SLUB_NUMA
+		nr_node_ids
+#else
+		1
+#endif
+		);
 }
 
 /*
@@ -3422,7 +3434,7 @@ static unsigned long slab_objects(struct
 	}
 
 	x = sprintf(buf, "%lu", total);
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 	for_each_online_node(node)
 		if (nodes[node])
 			x += sprintf(buf + x, " N%d=%lu",
@@ -3719,7 +3731,7 @@ static ssize_t free_calls_show(struct km
 }
 SLAB_ATTR_RO(free_calls);
 
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 static ssize_t defrag_ratio_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", s->defrag_ratio / 10);
@@ -3764,7 +3776,7 @@ static struct attribute * slab_attrs[] =
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
 #endif
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_SLAB_NUMA
 	&defrag_ratio_attr.attr,
 #endif
 	NULL
Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/init/Kconfig	2007-09-14 13:54:56.000000000 -0700
@@ -543,6 +543,7 @@ choice
 
 config SLAB
 	bool "SLAB"
+	select SLAB_NUMA
 	help
 	  The regular slab allocator that is established and known to work
 	  well in all environments. It organizes cache hot objects in
@@ -570,6 +571,19 @@ config SLOB
 
 endchoice
 
+config SLAB_NUMA
+	depends on NUMA
+	bool "Slab NUMA Support"
+	default y
+	help
+	  Slab NUMA support allows NUMA aware slab operations. The
+	  NUMA logic creates overhead that may result in regressions on
+	  systems with a small number of nodes (such as multiple nodes
+	  on the same motherboard) but it may be essential for distributed
+	  NUMA systems with a high NUMA factor.
+	  WARNING: Disabling Slab NUMA support will disable all NUMA locality
+	  controls for slab objects.
+
 endmenu		# General setup
 
 config RT_MUTEXES

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
