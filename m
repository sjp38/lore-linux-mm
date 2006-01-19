From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Message-Id: <20060119080413.24736.27946.sendpatchset@debian>
In-Reply-To: <20060119080408.24736.13148.sendpatchset@debian>
References: <20060119080408.24736.13148.sendpatchset@debian>
Subject: [PATCH 1/2] Add the pzone
Date: Thu, 19 Jan 2006 17:04:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: linux-mm@kvack.org, KUROSAWA Takahiro <kurosawa@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch implements the pzone (pseudo zone).  A pzone can be used
for reserving pages in a zone.  Pzones are implemented by extending
the zone structure and act almost the same as the conventional zones;
we can specify pzones in a zonelist for __alloc_pages() and the vmscan
code works on pzones with few modifications.

Signed-off-by: KUROSAWA Takahiro <kurosawa@valinux.co.jp>

---
 include/linux/gfp.h    |    3 
 include/linux/mm.h     |   49 ++
 include/linux/mmzone.h |  118 ++++++
 include/linux/swap.h   |    2 
 mm/Kconfig             |    6 
 mm/page_alloc.c        |  845 +++++++++++++++++++++++++++++++++++++++++++++----
 mm/shmem.c             |    2 
 mm/vmscan.c            |   75 +++-
 8 files changed, 1020 insertions(+), 80 deletions(-)

diff -urNp a/include/linux/gfp.h b/include/linux/gfp.h
--- a/include/linux/gfp.h	2006-01-03 12:21:10.000000000 +0900
+++ b/include/linux/gfp.h	2006-01-19 15:23:42.000000000 +0900
@@ -47,6 +47,7 @@ struct vm_area_struct;
 #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
+#define __GFP_NOLRU      ((__force gfp_t)0x40000u) /* GFP_USER but will not be in LRU lists */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
@@ -55,7 +56,7 @@ struct vm_area_struct;
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
-			__GFP_NOMEMALLOC|__GFP_HARDWALL)
+			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_NOLRU)
 
 #define GFP_ATOMIC	(__GFP_HIGH)
 #define GFP_NOIO	(__GFP_WAIT)
diff -urNp a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h	2006-01-03 12:21:10.000000000 +0900
+++ b/include/linux/mm.h	2006-01-19 15:23:00.000000000 +0900
@@ -397,6 +397,12 @@ void put_page(struct page *page);
  * with space for node: | SECTION | NODE | ZONE | ... | FLAGS |
  *   no space for node: | SECTION |     ZONE    | ... | FLAGS |
  */
+
+#ifdef CONFIG_PSEUDO_ZONE
+#define PZONE_BIT_WIDTH		1
+#else
+#define PZONE_BIT_WIDTH		0
+#endif
 #ifdef CONFIG_SPARSEMEM
 #define SECTIONS_WIDTH		SECTIONS_SHIFT
 #else
@@ -405,14 +411,15 @@ void put_page(struct page *page);
 
 #define ZONES_WIDTH		ZONES_SHIFT
 
-#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT <= FLAGS_RESERVED
+#if PZONE_BIT_WIDTH+SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT <= FLAGS_RESERVED
 #define NODES_WIDTH		NODES_SHIFT
 #else
 #define NODES_WIDTH		0
 #endif
 
-/* Page flags: | [SECTION] | [NODE] | ZONE | ... | FLAGS | */
-#define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
+/* Page flags: | [PZONE] | [SECTION] | [NODE] | ZONE | ... | FLAGS | */
+#define PZONE_BIT_PGOFF		((sizeof(unsigned long)*8) - PZONE_BIT_WIDTH)
+#define SECTIONS_PGOFF		(PZONE_BIT_PGOFF - SECTIONS_WIDTH)
 #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
 #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
 
@@ -431,6 +438,7 @@ void put_page(struct page *page);
  * sections we define the shift as 0; that plus a 0 mask ensures
  * the compiler will optimise away reference to them.
  */
+#define PZONE_BIT_PGSHIFT	(PZONE_BIT_PGOFF * (PZONE_BIT_WIDTH != 0))
 #define SECTIONS_PGSHIFT	(SECTIONS_PGOFF * (SECTIONS_WIDTH != 0))
 #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
 #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
@@ -443,10 +451,11 @@ void put_page(struct page *page);
 #endif
 #define ZONETABLE_PGSHIFT	ZONES_PGSHIFT
 
-#if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
-#error SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
+#if PZONE_BIT_WIDTH+SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
+#error PZONE_BIT_WIDTH+SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
 #endif
 
+#define PZONE_BIT_MASK		((1UL << PZONE_BIT_WIDTH) - 1)
 #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
 #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
@@ -454,12 +463,38 @@ void put_page(struct page *page);
 
 static inline unsigned long page_zonenum(struct page *page)
 {
-	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
+	return (page->flags >> ZONES_PGSHIFT) & (ZONES_MASK | PZONE_BIT_MASK);
 }
 
 struct zone;
 extern struct zone *zone_table[];
 
+#ifdef CONFIG_PSEUDO_ZONE
+static inline int page_in_pzone(struct page *page)
+{
+	return (page->flags >> PZONE_BIT_PGSHIFT) & PZONE_BIT_MASK;
+}
+
+static inline struct zone *page_zone(struct page *page)
+{
+	int idx;
+
+	idx = (page->flags >> ZONETABLE_PGSHIFT) & ZONETABLE_MASK;
+	if (page_in_pzone(page))
+		return pzone_table[idx].zone;
+	return zone_table[idx];
+}
+
+static inline unsigned long page_to_nid(struct page *page)
+{
+	return page_zone(page)->zone_pgdat->node_id;
+}
+#else
+static inline int page_in_pzone(struct page *page)
+{
+	return 0;
+}
+
 static inline struct zone *page_zone(struct page *page)
 {
 	return zone_table[(page->flags >> ZONETABLE_PGSHIFT) &
@@ -473,6 +508,8 @@ static inline unsigned long page_to_nid(
 	else
 		return page_zone(page)->zone_pgdat->node_id;
 }
+#endif
+
 static inline unsigned long page_to_section(struct page *page)
 {
 	return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;
diff -urNp a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h	2006-01-03 12:21:10.000000000 +0900
+++ b/include/linux/mmzone.h	2006-01-19 15:23:00.000000000 +0900
@@ -111,6 +111,15 @@ struct zone {
 	/* Fields commonly accessed by the page allocator */
 	unsigned long		free_pages;
 	unsigned long		pages_min, pages_low, pages_high;
+
+#ifdef CONFIG_PSEUDO_ZONE
+	/* Pseudo zone members: children list is protected by nr_zones_lock */
+	struct zone		*parent;
+	struct list_head	children;
+	struct list_head	sibling;
+	int			pzone_idx;
+#endif
+
 	/*
 	 * We don't know if the memory that we're going to allocate will be freeable
 	 * or/and it will be released eventually, so to avoid totally wasting several
@@ -336,7 +345,71 @@ unsigned long __init node_memmap_size_by
 /*
  * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
  */
-#define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
+#define zone_idx(zone)		(real_zone(zone) - (zone)->zone_pgdat->node_zones)
+
+#ifdef CONFIG_PSEUDO_ZONE
+#define MAX_NR_PZONES		1024
+
+struct pzone_table {
+	struct zone *zone;
+	struct list_head list;
+};
+
+extern struct pzone_table pzone_table[];
+
+void read_lock_nr_zones(void);
+void read_unlock_nr_zones(void);
+struct zone *pzone_create(struct zone *z, char *name, int npages);
+void pzone_destroy(struct zone *z);
+int pzone_set_numpages(struct zone *z, int npages);
+
+static inline void zone_init_pzone_link(struct zone *z)
+{
+	z->parent = NULL;
+	INIT_LIST_HEAD(&z->children);
+	INIT_LIST_HEAD(&z->sibling);
+	z->pzone_idx = -1;
+}
+
+static inline int zone_is_pseudo(struct zone *z)
+{
+	return (z->parent != NULL);
+}
+
+static inline struct zone *real_zone(struct zone *z)
+{
+	if (z->parent)
+		return z->parent;
+	return z;
+}
+
+static inline struct zone *pzone_next_in_zone(struct zone *z)
+{
+	if (zone_is_pseudo(z)) {
+		if (z->sibling.next == &z->parent->children)
+			z = NULL;
+		else
+			z = list_entry(z->sibling.next, struct zone, sibling);
+	} else {
+		if (list_empty(&z->children))
+			z = NULL;
+		else
+			z = list_entry(z->children.next, struct zone, sibling);
+	}
+
+	return z;
+}
+
+#else
+#define MAX_PSEUDO_ZONES	0
+
+static inline void read_lock_nr_zones(void) {}
+static inline void read_unlock_nr_zones(void) {}
+static inline void zone_init_pzone_link(struct zone *z) {}
+
+static inline int zone_is_pseudo(struct zone *z) { return 0; }
+static inline struct zone *real_zone(struct zone *z) { return z; }
+#endif
 
 /**
  * for_each_pgdat - helper macro to iterate over all nodes
@@ -360,6 +433,19 @@ static inline struct zone *next_zone(str
 {
 	pg_data_t *pgdat = zone->zone_pgdat;
 
+#ifdef CONFIG_PSEUDO_ZONE
+	if (zone_is_pseudo(zone)) {
+		if (zone->sibling.next != &zone->parent->children)
+			return list_entry(zone->sibling.next, struct zone,
+					  sibling);
+		else
+			zone = zone->parent;
+	} else {
+		if (!list_empty(&zone->children))
+			return list_entry(zone->children.next, struct zone,
+					  sibling);
+	}
+#endif
 	if (zone < pgdat->node_zones + MAX_NR_ZONES - 1)
 		zone++;
 	else if (pgdat->pgdat_next) {
@@ -371,6 +457,31 @@ static inline struct zone *next_zone(str
 	return zone;
 }
 
+static inline struct zone *next_zone_in_node(struct zone *zone, int len)
+{
+	pg_data_t *pgdat = zone->zone_pgdat;
+
+#ifdef CONFIG_PSEUDO_ZONE
+	if (zone_is_pseudo(zone)) {
+		if (zone->sibling.next != &zone->parent->children)
+			return list_entry(zone->sibling.next, struct zone,
+					  sibling);
+		else
+			zone = zone->parent;
+	} else {
+		if (!list_empty(&zone->children))
+			return list_entry(zone->children.next, struct zone,
+					  sibling);
+	}
+#endif
+	if (zone < pgdat->node_zones + len - 1)
+		zone++;
+	else
+		zone = NULL;
+
+	return zone;
+}
+
 /**
  * for_each_zone - helper macro to iterate over all memory zones
  * @zone - pointer to struct zone variable
@@ -389,6 +500,9 @@ static inline struct zone *next_zone(str
 #define for_each_zone(zone) \
 	for (zone = pgdat_list->node_zones; zone; zone = next_zone(zone))
 
+#define for_each_zone_in_node(zone, pgdat, len) \
+	for (zone = pgdat->node_zones; zone; zone = next_zone_in_node(zone, len))
+
 static inline int is_highmem_idx(int idx)
 {
 	return (idx == ZONE_HIGHMEM);
@@ -406,11 +520,13 @@ static inline int is_normal_idx(int idx)
  */
 static inline int is_highmem(struct zone *zone)
 {
+	zone = real_zone(zone);
 	return zone == zone->zone_pgdat->node_zones + ZONE_HIGHMEM;
 }
 
 static inline int is_normal(struct zone *zone)
 {
+	zone = real_zone(zone);
 	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
 }
 
diff -urNp a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h	2006-01-03 12:21:10.000000000 +0900
+++ b/include/linux/swap.h	2006-01-19 15:23:00.000000000 +0900
@@ -171,6 +171,8 @@ extern int rotate_reclaimable_page(struc
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
+extern int isolate_lru_pages(int, struct list_head *, struct list_head *,
+		int *);
 extern int try_to_free_pages(struct zone **, gfp_t);
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
 extern int shrink_all_memory(int);
diff -urNp a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig	2006-01-03 12:21:10.000000000 +0900
+++ b/mm/Kconfig	2006-01-19 15:24:13.000000000 +0900
@@ -132,3 +132,9 @@ config SPLIT_PTLOCK_CPUS
 	default "4096" if ARM && !CPU_CACHE_VIPT
 	default "4096" if PARISC && !PA20
 	default "4"
+
+config PSEUDO_ZONE
+	bool "Pseudo zone support"
+	help
+	  This option provides pseudo zone creation from a non-pseudo zone.
+	  Pseudo zones could be used for memory resource management.
diff -urNp a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	2006-01-03 12:21:10.000000000 +0900
+++ b/mm/page_alloc.c	2006-01-19 15:23:00.000000000 +0900
@@ -309,6 +309,14 @@ static inline void __free_pages_bulk (st
 	BUG_ON(bad_range(zone, page));
 
 	zone->free_pages += order_size;
+
+	/*
+	 * Do not concatenate a page in the pzone.
+	 * Order>0 pages are never allocated from pzones (so far?).
+	 */
+	if (unlikely(page_in_pzone(page)))
+		goto skip_buddy;
+
 	while (order < MAX_ORDER-1) {
 		unsigned long combined_idx;
 		struct free_area *area;
@@ -321,6 +329,7 @@ static inline void __free_pages_bulk (st
 			break;
 		if (!page_is_buddy(buddy, order))
 			break;		/* Move the buddy up one level. */
+		BUG_ON(page_zone(page) != page_zone(buddy));
 		list_del(&buddy->lru);
 		area = zone->free_area + order;
 		area->nr_free--;
@@ -330,6 +339,8 @@ static inline void __free_pages_bulk (st
 		order++;
 	}
 	set_page_order(page, order);
+
+skip_buddy: /* Keep order and PagePrivate unset for pzone pages. */
 	list_add(&page->lru, &zone->free_area[order].free_list);
 	zone->free_area[order].nr_free++;
 }
@@ -565,6 +576,7 @@ void drain_remote_pages(void)
 	unsigned long flags;
 
 	local_irq_save(flags);
+	read_lock_nr_zones();
 	for_each_zone(zone) {
 		struct per_cpu_pageset *pset;
 
@@ -582,30 +594,37 @@ void drain_remote_pages(void)
 						&pcp->list, 0);
 		}
 	}
+	read_unlock_nr_zones();
 	local_irq_restore(flags);
 }
 #endif
 
-#if defined(CONFIG_PM) || defined(CONFIG_HOTPLUG_CPU)
-static void __drain_pages(unsigned int cpu)
+#if defined(CONFIG_PM) || defined(CONFIG_HOTPLUG_CPU) || defined(CONFIG_PSEUDO_ZONE)
+static void __drain_zone_pages(struct zone *zone, int cpu)
 {
-	struct zone *zone;
+	struct per_cpu_pageset *pset;
 	int i;
 
-	for_each_zone(zone) {
-		struct per_cpu_pageset *pset;
-
-		pset = zone_pcp(zone, cpu);
-		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
-			struct per_cpu_pages *pcp;
+	pset = zone_pcp(zone, cpu);
+	for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
+		struct per_cpu_pages *pcp;
 
-			pcp = &pset->pcp[i];
-			pcp->count -= free_pages_bulk(zone, pcp->count,
-						&pcp->list, 0);
-		}
+		pcp = &pset->pcp[i];
+		pcp->count -= free_pages_bulk(zone, pcp->count,
+					&pcp->list, 0);
 	}
 }
-#endif /* CONFIG_PM || CONFIG_HOTPLUG_CPU */
+
+static void __drain_pages(unsigned int cpu)
+{
+	struct zone *zone;
+
+	read_lock_nr_zones();
+	for_each_zone(zone)
+		__drain_zone_pages(zone, cpu);
+	read_unlock_nr_zones();
+}
+#endif /* CONFIG_PM || CONFIG_HOTPLUG_CPU || CONFIG_PSEUDO_ZONE */
 
 #ifdef CONFIG_PM
 
@@ -1080,8 +1099,10 @@ unsigned int nr_free_pages(void)
 	unsigned int sum = 0;
 	struct zone *zone;
 
+	read_lock_nr_zones();
 	for_each_zone(zone)
 		sum += zone->free_pages;
+	read_unlock_nr_zones();
 
 	return sum;
 }
@@ -1331,6 +1352,7 @@ void show_free_areas(void)
 	unsigned long free;
 	struct zone *zone;
 
+	read_lock_nr_zones();
 	for_each_zone(zone) {
 		show_node(zone);
 		printk("%s per-cpu:", zone->name);
@@ -1427,6 +1449,7 @@ void show_free_areas(void)
 		spin_unlock_irqrestore(&zone->lock, flags);
 		printk("= %lukB\n", K(total));
 	}
+	read_unlock_nr_zones();
 
 	show_swap_cache_info();
 }
@@ -1836,6 +1859,7 @@ static int __devinit process_zones(int c
 {
 	struct zone *zone, *dzone;
 
+	read_lock_nr_zones();
 	for_each_zone(zone) {
 
 		zone->pageset[cpu] = kmalloc_node(sizeof(struct per_cpu_pageset),
@@ -1845,6 +1869,7 @@ static int __devinit process_zones(int c
 
 		setup_pageset(zone->pageset[cpu], zone_batchsize(zone));
 	}
+	read_unlock_nr_zones();
 
 	return 0;
 bad:
@@ -1854,6 +1879,7 @@ bad:
 		kfree(dzone->pageset[cpu]);
 		dzone->pageset[cpu] = NULL;
 	}
+	read_unlock_nr_zones();
 	return -ENOMEM;
 }
 
@@ -1862,12 +1888,14 @@ static inline void free_zone_pagesets(in
 #ifdef CONFIG_NUMA
 	struct zone *zone;
 
+	read_lock_nr_zones();
 	for_each_zone(zone) {
 		struct per_cpu_pageset *pset = zone_pcp(zone, cpu);
 
 		zone_pcp(zone, cpu) = NULL;
 		kfree(pset);
 	}
+	read_unlock_nr_zones();
 #endif
 }
 
@@ -2006,6 +2034,7 @@ static void __init free_area_init_core(s
 
 		zone->temp_priority = zone->prev_priority = DEF_PRIORITY;
 
+		zone_init_pzone_link(zone);
 		zone_pcp_init(zone);
 		INIT_LIST_HEAD(&zone->active_list);
 		INIT_LIST_HEAD(&zone->inactive_list);
@@ -2111,11 +2140,11 @@ static int frag_show(struct seq_file *m,
 {
 	pg_data_t *pgdat = (pg_data_t *)arg;
 	struct zone *zone;
-	struct zone *node_zones = pgdat->node_zones;
 	unsigned long flags;
 	int order;
 
-	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
+	read_lock_nr_zones();
+	for_each_zone_in_node(zone, pgdat, MAX_NR_ZONES) {
 		if (!zone->present_pages)
 			continue;
 
@@ -2126,6 +2155,7 @@ static int frag_show(struct seq_file *m,
 		spin_unlock_irqrestore(&zone->lock, flags);
 		seq_putc(m, '\n');
 	}
+	read_unlock_nr_zones();
 	return 0;
 }
 
@@ -2143,10 +2173,10 @@ static int zoneinfo_show(struct seq_file
 {
 	pg_data_t *pgdat = arg;
 	struct zone *zone;
-	struct zone *node_zones = pgdat->node_zones;
 	unsigned long flags;
 
-	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; zone++) {
+	read_lock_nr_zones();
+	for_each_zone_in_node(zone, pgdat, MAX_NR_ZONES) {
 		int i;
 
 		if (!zone->present_pages)
@@ -2234,6 +2264,7 @@ static int zoneinfo_show(struct seq_file
 		spin_unlock_irqrestore(&zone->lock, flags);
 		seq_putc(m, '\n');
 	}
+	read_unlock_nr_zones();
 	return 0;
 }
 
@@ -2414,6 +2445,45 @@ static void setup_per_zone_lowmem_reserv
 	}
 }
 
+static void setup_zone_pages_min(struct zone *zone, unsigned long lowmem_pages)
+{
+	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned long flags;
+	unsigned long tmp;
+
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	tmp = (pages_min * zone->present_pages) / lowmem_pages;
+	if (is_highmem(zone)) {
+		/*
+		 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
+		 * need highmem pages, so cap pages_min to a small
+		 * value here.
+		 *
+		 * The (pages_high-pages_low) and (pages_low-pages_min)
+		 * deltas controls asynch page reclaim, and so should
+		 * not be capped for highmem.
+		 */
+		int min_pages;
+
+		min_pages = zone->present_pages / 1024;
+		if (min_pages < SWAP_CLUSTER_MAX)
+			min_pages = SWAP_CLUSTER_MAX;
+		if (min_pages > 128)
+			min_pages = 128;
+		zone->pages_min = min_pages;
+	} else {
+		/*
+		 * If it's a lowmem zone, reserve a number of pages
+		 * proportionate to the zone's size.
+		 */
+		zone->pages_min = tmp;
+	}
+
+	zone->pages_low   = zone->pages_min + tmp / 4;
+	zone->pages_high  = zone->pages_min + tmp / 2;
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
+}
+
 /*
  * setup_per_zone_pages_min - called when min_free_kbytes changes.  Ensures 
  *	that the pages_{min,low,high} values for each zone are set correctly 
@@ -2421,51 +2491,19 @@ static void setup_per_zone_lowmem_reserv
  */
 void setup_per_zone_pages_min(void)
 {
-	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
 	struct zone *zone;
-	unsigned long flags;
 
+	read_lock_nr_zones();
 	/* Calculate total number of !ZONE_HIGHMEM pages */
 	for_each_zone(zone) {
 		if (!is_highmem(zone))
 			lowmem_pages += zone->present_pages;
 	}
 
-	for_each_zone(zone) {
-		unsigned long tmp;
-		spin_lock_irqsave(&zone->lru_lock, flags);
-		tmp = (pages_min * zone->present_pages) / lowmem_pages;
-		if (is_highmem(zone)) {
-			/*
-			 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
-			 * need highmem pages, so cap pages_min to a small
-			 * value here.
-			 *
-			 * The (pages_high-pages_low) and (pages_low-pages_min)
-			 * deltas controls asynch page reclaim, and so should
-			 * not be capped for highmem.
-			 */
-			int min_pages;
-
-			min_pages = zone->present_pages / 1024;
-			if (min_pages < SWAP_CLUSTER_MAX)
-				min_pages = SWAP_CLUSTER_MAX;
-			if (min_pages > 128)
-				min_pages = 128;
-			zone->pages_min = min_pages;
-		} else {
-			/*
-			 * If it's a lowmem zone, reserve a number of pages
-			 * proportionate to the zone's size.
-			 */
-			zone->pages_min = tmp;
-		}
-
-		zone->pages_low   = zone->pages_min + tmp / 4;
-		zone->pages_high  = zone->pages_min + tmp / 2;
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
-	}
+	for_each_zone(zone)
+		setup_zone_pages_min(zone, lowmem_pages);
+	read_unlock_nr_zones();
 }
 
 /*
@@ -2629,3 +2667,702 @@ void *__init alloc_large_system_hash(con
 
 	return table;
 }
+
+#ifdef CONFIG_PSEUDO_ZONE
+
+#include <linux/mm_inline.h>
+
+struct pzone_table pzone_table[MAX_NR_PZONES];
+EXPORT_SYMBOL(pzone_table);
+
+static struct list_head pzone_freelist = LIST_HEAD_INIT(pzone_freelist);
+
+/*
+ * Protection between pzone_destroy() and pzone list lookups.
+ * These routines don't guard references from zonelists used in the page
+ * allocator.
+ * pzone maintainer (i.e. the class support routine) should remove the pzone
+ * from a zonelist (and probably make sure that there are no tasks in
+ * that class), then destroy the pzone.
+ */
+static spinlock_t nr_zones_lock = SPIN_LOCK_UNLOCKED;
+static int zones_readers = 0;
+static DECLARE_WAIT_QUEUE_HEAD(zones_waitqueue);
+
+static struct workqueue_struct *pzone_drain_wq;
+static DEFINE_PER_CPU(struct work_struct, pzone_drain_work);
+
+void read_lock_nr_zones(void)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&nr_zones_lock, flags);
+	zones_readers++;
+	spin_unlock_irqrestore(&nr_zones_lock, flags);
+}
+
+void read_unlock_nr_zones(void)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&nr_zones_lock, flags);
+	zones_readers--;
+	if ((zones_readers == 0) && waitqueue_active(&zones_waitqueue))
+		wake_up(&zones_waitqueue);
+	spin_unlock_irqrestore(&nr_zones_lock, flags);
+}
+
+static void write_lock_nr_zones(unsigned long *flagsp)
+{
+	DEFINE_WAIT(wait);
+
+	spin_lock_irqsave(&nr_zones_lock, *flagsp);
+	while (zones_readers) {
+		spin_unlock_irqrestore(&nr_zones_lock, *flagsp);
+		prepare_to_wait(&zones_waitqueue, &wait,
+				TASK_UNINTERRUPTIBLE);
+		schedule();
+		finish_wait(&zones_waitqueue, &wait);
+		spin_lock_irqsave(&nr_zones_lock, *flagsp);
+	}
+}
+
+static void write_unlock_nr_zones(unsigned long *flagsp)
+{
+	spin_unlock_irqrestore(&nr_zones_lock, *flagsp);
+}
+
+static int pzone_table_register(struct zone *z)
+{
+	struct pzone_table *t;
+	unsigned long flags;
+
+	write_lock_nr_zones(&flags);
+	if (list_empty(&pzone_freelist)) {
+		write_unlock_nr_zones(&flags);
+		return -ENOMEM;
+	}
+
+	t = list_entry(pzone_freelist.next, struct pzone_table, list);
+	list_del(&t->list);
+	z->pzone_idx = t - pzone_table;
+	t->zone = z;
+	write_unlock_nr_zones(&flags);
+
+	return 0;
+}
+
+static void pzone_table_unregister(struct zone *z)
+{
+	struct pzone_table *t;
+	unsigned long flags;
+
+	write_lock_nr_zones(&flags);
+	t = &pzone_table[z->pzone_idx];
+	t->zone = NULL;
+	list_add(&t->list, &pzone_freelist);
+	write_unlock_nr_zones(&flags);
+}
+
+static void pzone_parent_register(struct zone *z, struct zone *parent)
+{
+	unsigned long flags;
+
+	write_lock_nr_zones(&flags);
+	list_add(&z->sibling, &parent->children);
+	write_unlock_nr_zones(&flags);
+}
+
+static void pzone_parent_unregister(struct zone *z)
+{
+	unsigned long flags;
+
+	write_lock_nr_zones(&flags);
+	list_del(&z->sibling);
+	write_unlock_nr_zones(&flags);
+}
+
+/*
+ * pzone alloc/free routines
+ */
+#ifdef CONFIG_NUMA
+static int pzone_setup_pagesets(struct zone *z)
+{
+	struct per_cpu_pageset *pageset;
+	int batch;
+	int nid;
+	int i;
+
+	zone_pcp_init(z);
+
+	nid = z->zone_pgdat->node_id;
+	batch = zone_batchsize(z);
+
+	lock_cpu_hotplug();
+	for_each_online_cpu(i) {
+		pageset = kmalloc_node(sizeof(*pageset), GFP_KERNEL, nid);
+		if (!pageset)
+			goto bad;
+		z->pageset[i] = pageset;
+		setup_pageset(pageset, batch);
+	}
+	unlock_cpu_hotplug();
+
+	return 0;
+bad:
+	for (i = 0; i < NR_CPUS; i++) {
+		if (z->pageset[i] != &boot_pageset[i])
+			kfree(z->pageset[i]);
+		z->pageset[i] = NULL;
+	}
+	unlock_cpu_hotplug();
+
+	return -ENOMEM;
+}
+
+static void pzone_free_pagesets(struct zone *z)
+{
+	int i;
+
+	for (i = 0; i < NR_CPUS; i++) {
+		if (z->pageset[i] && (zone_pcp(z, i) != &boot_pageset[i])) {
+			BUG_ON(zone_pcp(z, i)->pcp[0].count != 0);
+			BUG_ON(zone_pcp(z, i)->pcp[1].count != 0);
+			kfree(zone_pcp(z, i));
+		}
+		zone_pcp(z, i) = NULL;
+	}
+}
+#else /* !CONFIG_NUMA */
+static inline int pzone_setup_pagesets(struct zone *z)
+{
+	int batch;
+	int i;
+
+	batch = zone_batchsize(z);
+	for (i = 0; i < NR_CPUS; i++)
+		setup_pageset(zone_pcp(z, i), batch);
+
+	return 0;
+}
+
+static inline void pzone_free_pagesets(struct zone *z)
+{
+	int i;
+
+	for (i = 0; i < NR_CPUS; i++) {
+		BUG_ON(zone_pcp(z, i)->pcp[0].count != 0);
+		BUG_ON(zone_pcp(z, i)->pcp[1].count != 0);
+	}
+}
+#endif /* CONFIG_NUMA */
+
+static inline void pzone_setup_page_flags(struct zone *z,
+						struct page *page)
+{
+	page->flags &= ~(ZONETABLE_MASK << ZONETABLE_PGSHIFT);
+	page->flags |= ((unsigned long)z->pzone_idx << ZONETABLE_PGSHIFT);
+	page->flags |= 1UL << PZONE_BIT_PGSHIFT;
+}
+
+static inline void pzone_restore_page_flags(struct zone *parent,
+						struct page *page)
+{
+	set_page_links(page, zone_idx(parent), parent->zone_pgdat->node_id,
+		       page_to_pfn(page));
+	page->flags &= ~(1UL << PZONE_BIT_PGSHIFT);
+}
+
+/*
+ * pzone_bad_range(): implemented for debugging instead of bad_range()
+ * in order to distinguish what causes the crash.
+ */
+static int pzone_bad_range(struct zone *zone, struct page *page)
+{
+	if (page_to_pfn(page) >= zone->zone_start_pfn + zone->spanned_pages)
+		BUG();
+	if (page_to_pfn(page) < zone->zone_start_pfn)
+		BUG();
+#ifdef CONFIG_HOLES_IN_ZONE
+	if (!pfn_valid(page_to_pfn(page)))
+		BUG();
+#endif
+	if (zone != page_zone(page))
+		BUG();
+	return 0;
+}
+
+static void pzone_drain(void *arg)
+{
+	lru_add_drain();
+}
+
+static void pzone_punt_drain(void *arg)
+{
+	struct work_struct *wp;
+
+	wp = &get_cpu_var(pzone_drain_work);
+	PREPARE_WORK(wp, pzone_drain, arg);
+	/* queue_work() checks whether the work is used or not. */
+	queue_work(pzone_drain_wq, wp);
+	put_cpu_var(pzone_drain_work);
+}
+
+static void pzone_flush_percpu(void *arg)
+{
+	struct zone *z = arg;
+	unsigned long flags;
+	int cpu;
+
+	/*
+	 * lru_add_drain() must not be called from interrupt context
+	 * (LRU pagevecs are interrupt unsafe).
+	 */
+
+	local_irq_save(flags);
+	cpu = smp_processor_id();
+	pzone_punt_drain(arg);
+	__drain_zone_pages(z, cpu);
+	local_irq_restore(flags);
+}
+
+static int pzone_flush_lru(struct zone *z, struct zone *parent,
+			   struct list_head *clist, unsigned long *cnr,
+			   int block)
+{
+	unsigned long flags;
+	struct page *page;
+	struct list_head list;
+	int n, moved, scan;
+
+	INIT_LIST_HEAD(&list);
+
+	spin_lock_irqsave(&z->lru_lock, flags);
+	n = isolate_lru_pages(*cnr, clist, &list, &scan);
+	*cnr -= n;
+	spin_unlock_irqrestore(&z->lru_lock, flags);
+
+	moved = 0;
+	while (!list_empty(&list) && n-- > 0) {
+		page = list_entry(list.prev, struct page, lru);
+		list_del(&page->lru);
+
+		if (block) {
+			lock_page(page);
+			wait_on_page_writeback(page);
+		} else {
+			if (TestSetPageLocked(page))
+				goto goaround;
+
+			/* Make sure the writeback bit being kept zero. */
+			if (PageWriteback(page))
+				goto goaround_pagelocked;
+		}
+
+		/* Now we can safely modify the flags field. */
+		pzone_restore_page_flags(parent, page);
+		unlock_page(page);
+
+		spin_lock_irqsave(&parent->lru_lock, flags);
+		if (TestSetPageLRU(page))
+			BUG();
+
+		__put_page(page);
+		if (PageActive(page))
+			add_page_to_active_list(parent, page);
+		else
+			add_page_to_inactive_list(parent, page);
+		spin_unlock_irqrestore(&parent->lru_lock, flags);
+
+		moved++;
+		continue;
+
+goaround_pagelocked:
+		unlock_page(page);
+goaround:
+		spin_lock_irqsave(&z->lru_lock, flags);
+		__put_page(page);
+		if (TestSetPageLRU(page))
+			BUG();
+		list_add(&page->lru, clist);
+		++*cnr;
+		spin_unlock_irqrestore(&z->lru_lock, flags);
+	}
+
+	return moved;
+}
+
+static void pzone_flush_free_area(struct zone *z)
+{
+	struct free_area *area;
+	struct page *page;
+	struct list_head list;
+	unsigned long flags;
+	int order;
+
+	INIT_LIST_HEAD(&list);
+
+	spin_lock_irqsave(&z->lock, flags);
+	area = &z->free_area[0];
+	while (!list_empty(&area->free_list)) {
+		page = list_entry(area->free_list.next, struct page, lru);
+		list_del(&page->lru);
+		area->nr_free--;
+		z->free_pages--;
+		z->present_pages--;
+		spin_unlock_irqrestore(&z->lock, flags);
+		pzone_restore_page_flags(z->parent, page);
+		pzone_bad_range(z->parent, page);
+		list_add(&page->lru, &list);
+		free_pages_bulk(z->parent, 1, &list, 0);
+
+		spin_lock_irqsave(&z->lock, flags);
+	}
+
+	BUG_ON(area->nr_free != 0);
+	spin_unlock_irqrestore(&z->lock, flags);
+
+	/* currently pzone only supports order-0 only. do sanity check. */
+	spin_lock_irqsave(&z->lock, flags);
+	for (order = 1; order < MAX_ORDER; order++) {
+		area = &z->free_area[order];
+		BUG_ON(area->nr_free != 0);
+	}
+	spin_unlock_irqrestore(&z->lock, flags);
+}
+
+static int pzone_is_empty(struct zone *z)
+{
+	unsigned long flags;
+	int ret = 0;
+	int i;
+
+	spin_lock_irqsave(&z->lock, flags);
+	ret += z->present_pages;
+	ret += z->free_pages;
+	ret += z->free_area[0].nr_free;
+
+	/* would better use smp_call_function for scanning pcp. */
+	for (i = 0; i < NR_CPUS; i++) {
+#ifdef CONFIG_NUMA
+		if (!zone_pcp(z, i) || (zone_pcp(z, i) == &boot_pageset[i]))
+			continue;
+#endif
+		ret += zone_pcp(z, i)->pcp[0].count;
+		ret += zone_pcp(z, i)->pcp[1].count;
+	}
+	spin_unlock_irqrestore(&z->lock, flags);
+
+	spin_lock_irqsave(&z->lru_lock, flags);
+	ret += z->nr_active;
+	ret += z->nr_inactive;
+	spin_unlock_irqrestore(&z->lru_lock, flags);
+
+	return ret == 0;
+}
+
+struct zone *pzone_create(struct zone *parent, char *name, int npages)
+{
+	struct zonelist zonelist;
+	struct zone *z;
+	struct page *page;
+	struct list_head *l;
+	unsigned long flags;
+	int len;
+	int i;
+
+	if (npages > parent->present_pages)
+		return NULL;
+
+	z = kmalloc_node(sizeof(*z), GFP_KERNEL, parent->zone_pgdat->node_id);
+	if (!z)
+		goto bad1;
+	memset(z, 0, sizeof(*z));
+
+	z->present_pages = z->free_pages = npages;
+	z->parent = parent;
+
+	spin_lock_init(&z->lock);
+	spin_lock_init(&z->lru_lock);
+	INIT_LIST_HEAD(&z->active_list);
+	INIT_LIST_HEAD(&z->inactive_list);
+
+	INIT_LIST_HEAD(&z->children);
+	INIT_LIST_HEAD(&z->sibling);
+
+	z->zone_pgdat = parent->zone_pgdat;
+	z->zone_mem_map = parent->zone_mem_map;
+	z->zone_start_pfn = parent->zone_start_pfn;
+	z->spanned_pages = parent->spanned_pages;
+	z->temp_priority = z->prev_priority = DEF_PRIORITY;
+
+	/* use wait_table of parents. */
+	z->wait_table = parent->wait_table;
+	z->wait_table_size = parent->wait_table_size;
+	z->wait_table_bits = parent->wait_table_bits;
+
+	len = strlen(name);
+	z->name = kmalloc_node(len + 1, GFP_KERNEL,
+			       parent->zone_pgdat->node_id);
+	if (!z->name)
+		goto bad2;
+	strcpy(z->name, name);
+
+	if (pzone_setup_pagesets(z) < 0)
+		goto bad3;
+
+	/* no lowmem for the pseudo zone.  leave lowmem_reserve all-0. */
+
+	zone_init_free_lists(z->zone_pgdat, z, z->spanned_pages);
+
+	/* setup a fake zonelist for allocating pages only from the parent. */
+	memset(&zonelist, 0, sizeof(zonelist));
+	zonelist.zones[0] = parent;
+	for (i = 0; i < npages; i++) {
+		page = __alloc_pages(GFP_KERNEL, 0, &zonelist);
+		if (!page)
+			goto bad4;
+		set_page_count(page, 0);
+		list_add(&page->lru, &z->free_area[0].free_list);
+		z->free_area[0].nr_free++;
+	}
+
+	if (pzone_table_register(z))
+		goto bad4;
+
+	list_for_each(l, &z->free_area[0].free_list) {
+		page = list_entry(l, struct page, lru);
+		pzone_setup_page_flags(z, page);
+	}
+
+	spin_lock_irqsave(&parent->lock, flags);
+	parent->present_pages -= npages;
+	spin_unlock_irqrestore(&parent->lock, flags);
+	
+	setup_per_zone_pages_min();
+	setup_per_zone_lowmem_reserve();
+	pzone_parent_register(z, parent);
+
+	return z;
+bad4:
+	while (!list_empty(&z->free_area[0].free_list)) {
+		page = list_entry(z->free_area[0].free_list.next,
+				  struct page, lru);
+		list_del(&page->lru);
+		pzone_restore_page_flags(parent, page);
+		set_page_count(page, 1);
+		__free_pages(page, 0);
+	}
+
+	pzone_free_pagesets(z);
+bad3:
+	if (z->name)
+		kfree(z->name);
+bad2:
+	kfree(z);
+bad1:
+	setup_per_zone_pages_min();
+	setup_per_zone_lowmem_reserve();
+
+	return NULL;
+}
+
+#define PZONE_FLUSH_LOOP_COUNT		8
+
+/*
+ * destroying pseudo zone. the caller should make sure that no one references
+ * this pseudo zone.
+ */
+void pzone_destroy(struct zone *z)
+{
+	struct zone *parent;
+	unsigned long flags;
+	unsigned long present;
+	int freed;
+	int retrycnt = 0;
+
+	parent = z->parent;
+	present = z->present_pages;
+	pzone_parent_unregister(z);
+retry:
+	/* drain pages in per-cpu pageset to free_area */
+	smp_call_function(pzone_flush_percpu, z, 0, 1);
+	pzone_flush_percpu(z);
+	
+	/* drain pages in the LRU list. */
+	freed = pzone_flush_lru(z, parent, &z->active_list, &z->nr_active,
+				retrycnt > 0);
+	spin_lock_irqsave(&z->lock, flags);
+	z->present_pages -= freed;
+	spin_unlock_irqrestore(&z->lock, flags);
+
+	freed = pzone_flush_lru(z, parent, &z->inactive_list, &z->nr_inactive,
+				retrycnt > 0);
+	spin_lock_irqsave(&z->lock, flags);
+	z->present_pages -= freed;
+	spin_unlock_irqrestore(&z->lock, flags);
+
+	pzone_flush_free_area(z);
+
+	if (!pzone_is_empty(z)) {
+		retrycnt++;
+		if (retrycnt > PZONE_FLUSH_LOOP_COUNT) {
+			BUG();
+		} else {
+			flush_workqueue(pzone_drain_wq);
+			set_current_state(TASK_UNINTERRUPTIBLE);
+			schedule_timeout(HZ);
+			goto retry;
+		}
+	}
+
+	spin_lock_irqsave(&parent->lock, flags);
+	parent->present_pages += present;
+	spin_unlock_irqrestore(&parent->lock, flags);
+
+	flush_workqueue(pzone_drain_wq);
+	pzone_table_unregister(z);
+	pzone_free_pagesets(z);
+	kfree(z->name);
+	kfree(z);
+
+	setup_per_zone_pages_min();
+	setup_per_zone_lowmem_reserve();
+}
+
+extern int shrink_zone_memory(struct zone *zone, int nr_pages);
+
+static int pzone_move_free_pages(struct zone *dst, struct zone *src,
+					int npages)
+{
+	struct zonelist zonelist;
+	struct list_head pagelist;
+	struct page *page;
+	unsigned long flags;
+	int err;
+	int i;
+
+	err = 0;
+	spin_lock_irqsave(&src->lock, flags);
+	if (npages > src->present_pages)
+		err = -ENOMEM;
+	spin_unlock_irqrestore(&src->lock, flags);
+	if (err)
+		return err;
+
+	smp_call_function(pzone_flush_percpu, src, 0, 1);
+	pzone_flush_percpu(src);
+
+	INIT_LIST_HEAD(&pagelist);
+	memset(&zonelist, 0, sizeof(zonelist));
+	zonelist.zones[0] = src;
+	for (i = 0; i < npages; i++) {
+		/*
+		 * XXX to prevent myself from being arrested by oom-killer...
+		 *     should be replaced to the cleaner code.
+		 */
+		if (src->free_pages < npages - i) {
+			shrink_zone_memory(src, npages - i);
+			smp_call_function(pzone_flush_percpu, src, 0, 1);
+			pzone_flush_percpu(src);
+			blk_congestion_wait(WRITE, HZ/50);
+		}
+
+		page = __alloc_pages(GFP_KERNEL, 0, &zonelist);
+		if (!page) {
+			err = -ENOMEM;
+			goto bad;
+		}
+		list_add(&page->lru, &pagelist);
+	}
+
+	while (!list_empty(&pagelist)) {
+		page = list_entry(pagelist.next, struct page, lru);
+		list_del(&page->lru);
+		if (zone_is_pseudo(dst))
+			pzone_setup_page_flags(dst, page);
+		else
+			pzone_restore_page_flags(dst, page);
+
+		set_page_count(page, 1);
+		spin_lock_irqsave(&dst->lock, flags);
+		dst->present_pages++;
+		spin_unlock_irqrestore(&dst->lock, flags);
+		__free_pages(page, 0);
+	}
+
+	spin_lock_irqsave(&src->lock, flags);
+	src->present_pages -= npages;
+	spin_unlock_irqrestore(&src->lock, flags);
+
+	return 0;
+bad:
+	while (!list_empty(&pagelist)) {
+		page = list_entry(pagelist.next, struct page, lru);
+		list_del(&page->lru);
+		__free_pages(page, 0);
+	}
+
+	return err;
+}
+
+int pzone_set_numpages(struct zone *z, int npages)
+{
+	struct zone *src, *dst;
+	unsigned long flags;
+	int err;
+	int n;
+
+	/*
+	 * This function must not be called simultaneously so far.
+	 * The caller should make sure that.
+	 */
+	if (z->present_pages == npages) {
+		return 0;
+	} else if (z->present_pages > npages) {
+		n = z->present_pages - npages;
+		src = z;
+		dst = z->parent;
+	} else {
+		n = npages - z->present_pages;
+		src = z->parent;
+		dst = z;
+	}
+
+	/* XXX  Preventing oom-killer from complaining */
+	spin_lock_irqsave(&z->lock, flags);
+	z->pages_min = z->pages_low = z->pages_high = 0;
+	spin_unlock_irqrestore(&z->lock, flags);
+
+	err = pzone_move_free_pages(dst, src, n);
+	setup_per_zone_pages_min();
+	setup_per_zone_lowmem_reserve();
+
+	return err;
+}
+
+static int pzone_init(void)
+{
+	struct work_struct *wp;
+	int i;
+
+	pzone_drain_wq = create_workqueue("pzone");
+	if (!pzone_drain_wq) {
+		printk(KERN_ERR "pzone: create_workqueue failed.\n");
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < NR_CPUS; i++) {
+		wp = &per_cpu(pzone_drain_work, i);
+		INIT_WORK(wp, pzone_drain, NULL);
+	}
+
+	for (i = 0; i < MAX_NR_PZONES; i++)
+		list_add_tail(&pzone_table[i].list, &pzone_freelist);
+
+	return 0;
+}
+
+__initcall(pzone_init);
+
+#endif /* CONFIG_PSEUDO_ZONE */
diff -urNp a/mm/shmem.c b/mm/shmem.c
--- a/mm/shmem.c	2006-01-03 12:21:10.000000000 +0900
+++ b/mm/shmem.c	2006-01-19 15:23:00.000000000 +0900
@@ -366,7 +366,7 @@ static swp_entry_t *shmem_swp_alloc(stru
 		}
 
 		spin_unlock(&info->lock);
-		page = shmem_dir_alloc(mapping_gfp_mask(inode->i_mapping) | __GFP_ZERO);
+		page = shmem_dir_alloc(mapping_gfp_mask(inode->i_mapping) | __GFP_ZERO | __GFP_NOLRU);
 		if (page)
 			set_page_private(page, 0);
 		spin_lock(&info->lock);
diff -urNp a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	2006-01-03 12:21:10.000000000 +0900
+++ b/mm/vmscan.c	2006-01-19 15:23:00.000000000 +0900
@@ -591,8 +591,8 @@ keep:
  *
  * returns how many pages were moved onto *@dst.
  */
-static int isolate_lru_pages(int nr_to_scan, struct list_head *src,
-			     struct list_head *dst, int *scanned)
+int isolate_lru_pages(int nr_to_scan, struct list_head *src,
+		      struct list_head *dst, int *scanned)
 {
 	int nr_taken = 0;
 	struct page *page;
@@ -1047,6 +1047,7 @@ static int balance_pgdat(pg_data_t *pgda
 	int priority;
 	int i;
 	int total_scanned, total_reclaimed;
+	struct zone *zone;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc;
 
@@ -1060,11 +1061,8 @@ loop_again:
 
 	inc_page_state(pageoutrun);
 
-	for (i = 0; i < pgdat->nr_zones; i++) {
-		struct zone *zone = pgdat->node_zones + i;
-
+	for_each_zone_in_node(zone, pgdat, pgdat->nr_zones)
 		zone->temp_priority = DEF_PRIORITY;
-	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
@@ -1082,7 +1080,24 @@ loop_again:
 			 * zone which needs scanning
 			 */
 			for (i = pgdat->nr_zones - 1; i >= 0; i--) {
-				struct zone *zone = pgdat->node_zones + i;
+#ifdef CONFIG_PSEUDO_ZONE
+				for (zone = pgdat->node_zones + i; zone;
+				     zone = pzone_next_in_zone(zone)) {
+					if (zone->present_pages == 0)
+						continue;
+
+					if (zone->all_unreclaimable &&
+							priority != DEF_PRIORITY)
+						continue;
+
+					if (!zone_watermark_ok(zone, order,
+						zone->pages_high, 0, 0)) {
+						end_zone = i;
+						goto scan;
+					}
+				}
+#else /* !CONFIG_PSEUDO_ZONE */
+				zone = pgdat->node_zones + i;
 
 				if (zone->present_pages == 0)
 					continue;
@@ -1096,17 +1111,15 @@ loop_again:
 					end_zone = i;
 					goto scan;
 				}
+#endif /* !CONFIG_PSEUDO_ZONE */
 			}
 			goto out;
 		} else {
 			end_zone = pgdat->nr_zones - 1;
 		}
 scan:
-		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
-
+		for_each_zone_in_node(zone, pgdat, end_zone)
 			lru_pages += zone->nr_active + zone->nr_inactive;
-		}
 
 		/*
 		 * Now scan the zone in the dma->highmem direction, stopping
@@ -1117,8 +1130,7 @@ scan:
 		 * pages behind kswapd's direction of progress, which would
 		 * cause too much scanning of the lower zones.
 		 */
-		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
+		for_each_zone_in_node(zone, pgdat, end_zone) {
 			int nr_slab;
 
 			if (zone->present_pages == 0)
@@ -1183,11 +1195,9 @@ scan:
 			break;
 	}
 out:
-	for (i = 0; i < pgdat->nr_zones; i++) {
-		struct zone *zone = pgdat->node_zones + i;
-
+	for_each_zone_in_node(zone, pgdat, pgdat->nr_zones)
 		zone->prev_priority = zone->temp_priority;
-	}
+
 	if (!all_zones_ok) {
 		cond_resched();
 		goto loop_again;
@@ -1261,7 +1271,9 @@ static int kswapd(void *p)
 		}
 		finish_wait(&pgdat->kswapd_wait, &wait);
 
+		read_lock_nr_zones();
 		balance_pgdat(pgdat, 0, order);
+		read_unlock_nr_zones();
 	}
 	return 0;
 }
@@ -1316,6 +1328,35 @@ int shrink_all_memory(int nr_pages)
 }
 #endif
 
+#ifdef CONFIG_PSEUDO_ZONE
+int shrink_zone_memory(struct zone *zone, int nr_pages)
+{
+	struct scan_control sc;
+
+	sc.gfp_mask = GFP_KERNEL;
+	sc.may_writepage = 1;
+	sc.may_swap = 1;
+	sc.nr_mapped = read_page_state(nr_mapped);
+	sc.nr_scanned = 0;
+	sc.nr_reclaimed = 0;
+	sc.priority = 0;
+
+	if (nr_pages < SWAP_CLUSTER_MAX)
+		sc.swap_cluster_max = nr_pages;
+	else
+		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
+
+	sc.nr_to_reclaim = sc.swap_cluster_max;
+	sc.nr_to_scan = sc.swap_cluster_max;
+	sc.nr_mapped = total_memory;	/* XXX  to make vmscan aggressive */
+	refill_inactive_zone(zone, &sc);
+	sc.nr_to_scan = sc.swap_cluster_max;
+	shrink_cache(zone, &sc);
+
+	return sc.nr_reclaimed;
+}
+#endif
+
 #ifdef CONFIG_HOTPLUG_CPU
 /* It's optimal to keep kswapds on the same CPUs as their memory, but
    not required for correctness.  So if the last cpu in a node goes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
