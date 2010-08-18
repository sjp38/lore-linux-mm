Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6834B6B01F2
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:26:40 -0400 (EDT)
Message-Id: <20100818162637.055888444@linux.com>
Date: Wed, 18 Aug 2010 11:25:41 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q Cleanup2 2/6] slub: remove dynamic dma slab allocation
References: <20100818162539.281413425@linux.com>
Content-Disposition: inline; filename=slub_remove_dynamic_dma
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Remove the dynamic dma slab allocation since this causes too many issues with
nested locks etc etc. The change avoids passing gfpflags into many functions.

V3->V4:
- Create dma caches in kmem_cache_init() instead of kmem_cache_init_late().

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |  150 ++++++++++++++++----------------------------------------------
 1 file changed, 39 insertions(+), 111 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-08-18 09:40:14.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-18 09:41:00.000000000 -0500
@@ -2064,7 +2064,7 @@ init_kmem_cache_node(struct kmem_cache_n
 
 static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);
 
-static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
+static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
 {
 	if (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches)
 		/*
@@ -2091,7 +2091,7 @@ static inline int alloc_kmem_cache_cpus(
  * when allocating for the kmalloc_node_cache. This is used for bootstrapping
  * memory on a fresh node that has no slab structures yet.
  */
-static void early_kmem_cache_node_alloc(gfp_t gfpflags, int node)
+static void early_kmem_cache_node_alloc(int node)
 {
 	struct page *page;
 	struct kmem_cache_node *n;
@@ -2099,7 +2099,7 @@ static void early_kmem_cache_node_alloc(
 
 	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
 
-	page = new_slab(kmalloc_caches, gfpflags, node);
+	page = new_slab(kmalloc_caches, GFP_NOWAIT, node);
 
 	BUG_ON(!page);
 	if (page_to_nid(page) != node) {
@@ -2143,7 +2143,7 @@ static void free_kmem_cache_nodes(struct
 	}
 }
 
-static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
+static int init_kmem_cache_nodes(struct kmem_cache *s)
 {
 	int node;
 
@@ -2151,11 +2151,11 @@ static int init_kmem_cache_nodes(struct 
 		struct kmem_cache_node *n;
 
 		if (slab_state == DOWN) {
-			early_kmem_cache_node_alloc(gfpflags, node);
+			early_kmem_cache_node_alloc(node);
 			continue;
 		}
 		n = kmem_cache_alloc_node(kmalloc_caches,
-						gfpflags, node);
+						GFP_KERNEL, node);
 
 		if (!n) {
 			free_kmem_cache_nodes(s);
@@ -2172,7 +2172,7 @@ static void free_kmem_cache_nodes(struct
 {
 }
 
-static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
+static int init_kmem_cache_nodes(struct kmem_cache *s)
 {
 	init_kmem_cache_node(&s->local_node, s);
 	return 1;
@@ -2312,7 +2312,7 @@ static int calculate_sizes(struct kmem_c
 
 }
 
-static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
+static int kmem_cache_open(struct kmem_cache *s,
 		const char *name, size_t size,
 		size_t align, unsigned long flags,
 		void (*ctor)(void *))
@@ -2348,10 +2348,10 @@ static int kmem_cache_open(struct kmem_c
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
-	if (!init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
+	if (!init_kmem_cache_nodes(s))
 		goto error;
 
-	if (alloc_kmem_cache_cpus(s, gfpflags & ~SLUB_DMA))
+	if (alloc_kmem_cache_cpus(s))
 		return 1;
 
 	free_kmem_cache_nodes(s);
@@ -2510,6 +2510,10 @@ EXPORT_SYMBOL(kmem_cache_destroy);
 struct kmem_cache kmalloc_caches[KMALLOC_CACHES] __cacheline_aligned;
 EXPORT_SYMBOL(kmalloc_caches);
 
+#ifdef CONFIG_ZONE_DMA
+static struct kmem_cache kmalloc_dma_caches[SLUB_PAGE_SHIFT];
+#endif
+
 static int __init setup_slub_min_order(char *str)
 {
 	get_option(&str, &slub_min_order);
@@ -2546,116 +2550,26 @@ static int __init setup_slub_nomerge(cha
 
 __setup("slub_nomerge", setup_slub_nomerge);
 
-static struct kmem_cache *create_kmalloc_cache(struct kmem_cache *s,
-		const char *name, int size, gfp_t gfp_flags)
+static void create_kmalloc_cache(struct kmem_cache *s,
+		const char *name, int size, unsigned int flags)
 {
-	unsigned int flags = 0;
-
-	if (gfp_flags & SLUB_DMA)
-		flags = SLAB_CACHE_DMA;
-
 	/*
 	 * This function is called with IRQs disabled during early-boot on
 	 * single CPU so there's no need to take slub_lock here.
 	 */
-	if (!kmem_cache_open(s, gfp_flags, name, size, ARCH_KMALLOC_MINALIGN,
+	if (!kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
 								flags, NULL))
 		goto panic;
 
 	list_add(&s->list, &slab_caches);
 
-	if (sysfs_slab_add(s))
-		goto panic;
-	return s;
+	if (!sysfs_slab_add(s))
+		return;
 
 panic:
 	panic("Creation of kmalloc slab %s size=%d failed.\n", name, size);
 }
 
-#ifdef CONFIG_ZONE_DMA
-static struct kmem_cache *kmalloc_caches_dma[SLUB_PAGE_SHIFT];
-
-static void sysfs_add_func(struct work_struct *w)
-{
-	struct kmem_cache *s;
-
-	down_write(&slub_lock);
-	list_for_each_entry(s, &slab_caches, list) {
-		if (s->flags & __SYSFS_ADD_DEFERRED) {
-			s->flags &= ~__SYSFS_ADD_DEFERRED;
-			sysfs_slab_add(s);
-		}
-	}
-	up_write(&slub_lock);
-}
-
-static DECLARE_WORK(sysfs_add_work, sysfs_add_func);
-
-static noinline struct kmem_cache *dma_kmalloc_cache(int index, gfp_t flags)
-{
-	struct kmem_cache *s;
-	char *text;
-	size_t realsize;
-	unsigned long slabflags;
-	int i;
-
-	s = kmalloc_caches_dma[index];
-	if (s)
-		return s;
-
-	/* Dynamically create dma cache */
-	if (flags & __GFP_WAIT)
-		down_write(&slub_lock);
-	else {
-		if (!down_write_trylock(&slub_lock))
-			goto out;
-	}
-
-	if (kmalloc_caches_dma[index])
-		goto unlock_out;
-
-	realsize = kmalloc_caches[index].objsize;
-	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
-			 (unsigned int)realsize);
-
-	s = NULL;
-	for (i = 0; i < KMALLOC_CACHES; i++)
-		if (!kmalloc_caches[i].size)
-			break;
-
-	BUG_ON(i >= KMALLOC_CACHES);
-	s = kmalloc_caches + i;
-
-	/*
-	 * Must defer sysfs creation to a workqueue because we don't know
-	 * what context we are called from. Before sysfs comes up, we don't
-	 * need to do anything because our sysfs initcall will start by
-	 * adding all existing slabs to sysfs.
-	 */
-	slabflags = SLAB_CACHE_DMA|SLAB_NOTRACK;
-	if (slab_state >= SYSFS)
-		slabflags |= __SYSFS_ADD_DEFERRED;
-
-	if (!text || !kmem_cache_open(s, flags, text,
-			realsize, ARCH_KMALLOC_MINALIGN, slabflags, NULL)) {
-		s->size = 0;
-		kfree(text);
-		goto unlock_out;
-	}
-
-	list_add(&s->list, &slab_caches);
-	kmalloc_caches_dma[index] = s;
-
-	if (slab_state >= SYSFS)
-		schedule_work(&sysfs_add_work);
-
-unlock_out:
-	up_write(&slub_lock);
-out:
-	return kmalloc_caches_dma[index];
-}
-#endif
-
 /*
  * Conversion table for small slabs sizes / 8 to the index in the
  * kmalloc array. This is necessary for slabs < 192 since we have non power
@@ -2708,7 +2622,7 @@ static struct kmem_cache *get_slab(size_
 
 #ifdef CONFIG_ZONE_DMA
 	if (unlikely((flags & SLUB_DMA)))
-		return dma_kmalloc_cache(index, flags);
+		return &kmalloc_dma_caches[index];
 
 #endif
 	return &kmalloc_caches[index];
@@ -3047,7 +2961,7 @@ void __init kmem_cache_init(void)
 	 * kmem_cache_open for slab_state == DOWN.
 	 */
 	create_kmalloc_cache(&kmalloc_caches[0], "kmem_cache_node",
-		sizeof(struct kmem_cache_node), GFP_NOWAIT);
+		sizeof(struct kmem_cache_node), 0);
 	kmalloc_caches[0].refcount = -1;
 	caches++;
 
@@ -3060,18 +2974,18 @@ void __init kmem_cache_init(void)
 	/* Caches that are not of the two-to-the-power-of size */
 	if (KMALLOC_MIN_SIZE <= 32) {
 		create_kmalloc_cache(&kmalloc_caches[1],
-				"kmalloc-96", 96, GFP_NOWAIT);
+				"kmalloc-96", 96, 0);
 		caches++;
 	}
 	if (KMALLOC_MIN_SIZE <= 64) {
 		create_kmalloc_cache(&kmalloc_caches[2],
-				"kmalloc-192", 192, GFP_NOWAIT);
+				"kmalloc-192", 192, 0);
 		caches++;
 	}
 
 	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
 		create_kmalloc_cache(&kmalloc_caches[i],
-			"kmalloc", 1 << i, GFP_NOWAIT);
+			"kmalloc", 1 << i, 0);
 		caches++;
 	}
 
@@ -3134,6 +3048,20 @@ void __init kmem_cache_init(void)
 	kmem_size = sizeof(struct kmem_cache);
 #endif
 
+#ifdef CONFIG_ZONE_DMA
+	for (i = 1; i < SLUB_PAGE_SHIFT; i++) {
+		struct kmem_cache *s = &kmalloc_caches[i];
+
+		if (s->size) {
+			char *name = kasprintf(GFP_NOWAIT,
+				 "dma-kmalloc-%d", s->objsize);
+
+			BUG_ON(!name);
+			create_kmalloc_cache(&kmalloc_dma_caches[i],
+				name, s->objsize, SLAB_CACHE_DMA);
+		}
+	}
+#endif
 	printk(KERN_INFO
 		"SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d, MinObjects=%d,"
 		" CPUs=%d, Nodes=%d\n",
@@ -3236,7 +3164,7 @@ struct kmem_cache *kmem_cache_create(con
 
 	s = kmalloc(kmem_size, GFP_KERNEL);
 	if (s) {
-		if (kmem_cache_open(s, GFP_KERNEL, name,
+		if (kmem_cache_open(s, name,
 				size, align, flags, ctor)) {
 			list_add(&s->list, &slab_caches);
 			if (sysfs_slab_add(s)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
