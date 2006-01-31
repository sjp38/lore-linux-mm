From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Message-Id: <20060131023025.7915.79078.sendpatchset@debian>
In-Reply-To: <20060131023000.7915.71955.sendpatchset@debian>
References: <20060131023000.7915.71955.sendpatchset@debian>
Subject: [PATCH 5/8] Add the pzone_create() function
Date: Tue, 31 Jan 2006 11:30:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: linux-mm@kvack.org, KUROSAWA Takahiro <kurosawa@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch implements creation of pzones.  A pzone can be used
for reserving pages in a conventional zone.  Pzones are implemented by 
extending the zone structure and act almost the same as the conventional 
zones; we can specify pzones in a zonelist for __alloc_pages() and the 
vmscan code works on pzones with few modifications.

Signed-off-by: KUROSAWA Takahiro <kurosawa@valinux.co.jp>

---
 include/linux/mm.h     |   49 ++++++++-
 include/linux/mmzone.h |   97 +++++++++++++++++
 mm/Kconfig             |    6 +
 mm/page_alloc.c        |  266 ++++++++++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c            |   20 +++
 5 files changed, 430 insertions(+), 8 deletions(-)

diff -urNp a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h	2006-01-03 12:21:10.000000000 +0900
+++ b/include/linux/mm.h	2006-01-30 14:31:30.000000000 +0900
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
@@ -405,16 +411,21 @@ void put_page(struct page *page);
 
 #define ZONES_WIDTH		ZONES_SHIFT
 
-#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT <= FLAGS_RESERVED
+#if PZONE_BIT_WIDTH+SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT <= FLAGS_RESERVED
 #define NODES_WIDTH		NODES_SHIFT
 #else
 #define NODES_WIDTH		0
 #endif
 
-/* Page flags: | [SECTION] | [NODE] | ZONE | ... | FLAGS | */
+/*
+ * Page flags: | [SECTION] | [NODE] | ZONE | [PZONE(0)] | ... | FLAGS |
+ * If PZONE bit is 1, page flags are as follows:
+ * Page flags: |       [PZONE index]       | [PZONE(1)] | ... | FLAGS |
+ */
 #define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
 #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
 #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
+#define PZONE_BIT_PGOFF		(ZONES_PGOFF - PZONE_BIT_WIDTH)
 
 /*
  * We are going to use the flags for the page to node mapping if its in
@@ -434,6 +445,7 @@ void put_page(struct page *page);
 #define SECTIONS_PGSHIFT	(SECTIONS_PGOFF * (SECTIONS_WIDTH != 0))
 #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
 #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
+#define PZONE_BIT_PGSHIFT	(PZONE_BIT_PGOFF * (PZONE_BIT_WIDTH != 0))
 
 /* NODE:ZONE or SECTION:ZONE is used to lookup the zone from a page. */
 #if FLAGS_HAS_NODE
@@ -443,13 +455,14 @@ void put_page(struct page *page);
 #endif
 #define ZONETABLE_PGSHIFT	ZONES_PGSHIFT
 
-#if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
-#error SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
+#if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH+PZONE_BIT_WIDTH > FLAGS_RESERVED
+#error SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH+PZONE_BIT_WIDTH > FLAGS_RESERVED
 #endif
 
 #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
 #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
+#define PZONE_BIT_MASK		((1UL << PZONE_BIT_WIDTH) - 1)
 #define ZONETABLE_MASK		((1UL << ZONETABLE_SHIFT) - 1)
 
 static inline unsigned long page_zonenum(struct page *page)
@@ -460,6 +473,32 @@ static inline unsigned long page_zonenum
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
@@ -473,6 +512,8 @@ static inline unsigned long page_to_nid(
 	else
 		return page_zone(page)->zone_pgdat->node_id;
 }
+#endif
+
 static inline unsigned long page_to_section(struct page *page)
 {
 	return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;
diff -urNp a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h	2006-01-30 14:23:30.000000000 +0900
+++ b/include/linux/mmzone.h	2006-01-30 14:31:30.000000000 +0900
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
@@ -340,7 +349,65 @@ unsigned long __init node_memmap_size_by
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
+struct zone *pzone_create(struct zone *z, char *name, int npages);
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
+static inline void zone_init_pzone_link(struct zone *z) {}
+
+static inline int zone_is_pseudo(struct zone *z) { return 0; }
+static inline struct zone *real_zone(struct zone *z) { return z; }
+#endif
 
 /**
  * for_each_pgdat - helper macro to iterate over all nodes
@@ -364,6 +431,19 @@ static inline struct zone *next_zone(str
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
@@ -379,6 +459,19 @@ static inline struct zone *next_zone_in_
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
 	if (zone < pgdat->node_zones + len - 1)
 		zone++;
 	else
@@ -425,11 +518,13 @@ static inline int is_normal_idx(int idx)
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
 
diff -urNp a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig	2006-01-03 12:21:10.000000000 +0900
+++ b/mm/Kconfig	2006-01-30 14:31:30.000000000 +0900
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
--- a/mm/page_alloc.c	2006-01-30 14:23:30.000000000 +0900
+++ b/mm/page_alloc.c	2006-01-30 14:31:30.000000000 +0900
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
@@ -588,7 +599,7 @@ void drain_remote_pages(void)
 }
 #endif
 
-#if defined(CONFIG_PM) || defined(CONFIG_HOTPLUG_CPU)
+#if defined(CONFIG_PM) || defined(CONFIG_HOTPLUG_CPU) || defined(CONFIG_PSEUDO_ZONE)
 static void __drain_zone_pages(struct zone *zone, int cpu)
 {
 	struct per_cpu_pageset *pset;
@@ -613,7 +624,7 @@ static void __drain_pages(unsigned int c
 		__drain_zone_pages(zone, cpu);
 	read_unlock_nr_zones();
 }
-#endif /* CONFIG_PM || CONFIG_HOTPLUG_CPU */
+#endif /* CONFIG_PM || CONFIG_HOTPLUG_CPU || CONFIG_PSEUDO_ZONE */
 
 #ifdef CONFIG_PM
 
@@ -2023,6 +2034,7 @@ static void __init free_area_init_core(s
 
 		zone->temp_priority = zone->prev_priority = DEF_PRIORITY;
 
+		zone_init_pzone_link(zone);
 		zone_pcp_init(zone);
 		INIT_LIST_HEAD(&zone->active_list);
 		INIT_LIST_HEAD(&zone->inactive_list);
@@ -2704,3 +2716,253 @@ void write_unlock_nr_zones(unsigned long
 {
 	spin_unlock_irqrestore(&nr_zones_lock, *flagsp);
 }
+
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
+static void pzone_parent_register(struct zone *z, struct zone *parent)
+{
+	unsigned long flags;
+
+	write_lock_nr_zones(&flags);
+	list_add(&z->sibling, &parent->children);
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
+static int pzone_init(void)
+{
+	int i;
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
diff -urNp a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	2006-01-30 14:23:30.000000000 +0900
+++ b/mm/vmscan.c	2006-01-30 14:31:30.000000000 +0900
@@ -1080,7 +1080,24 @@ loop_again:
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
@@ -1094,6 +1111,7 @@ loop_again:
 					end_zone = i;
 					goto scan;
 				}
+#endif /* !CONFIG_PSEUDO_ZONE */
 			}
 			goto out;
 		} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
