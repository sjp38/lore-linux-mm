From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070910112432.3097.41949.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
References: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 13/13] Print out statistics in relation to fragmentation avoidance to /proc/pagetypeinfo
Date: Mon, 10 Sep 2007 12:24:32 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Subject: Print out statistics in relation to fragmentation avoidance to /proc/pagetypeinfo
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch provides fragmentation avoidance statistics via /proc/pagetypeinfo.
The information is collected only on request so there is no runtime overhead.
The statistics are in three parts:

The first part prints information on the size of blocks that pages are
being grouped on and looks like

Page block order: 10
Pages per block:  1024

The second part is a more detailed version of /proc/buddyinfo and looks like

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
Node    0, zone      DMA, type    Unmovable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type  Reclaimable      1      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type      Reserve      0      4      4      0      0      0      0      1      0      1      0
Node    0, zone   Normal, type    Unmovable    111      8      4      4      2      3      1      0      0      0      0
Node    0, zone   Normal, type  Reclaimable    293     89      8      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type      Movable      1      6     13      9      7      6      3      0      0      0      0
Node    0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      4

The third part looks like

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve
Node 0, zone      DMA            0            1            2            1
Node 0, zone   Normal            3           17           94            4

To walk the zones within a node with interrupts disabled, walk_zones_in_node()
is introduced and shared between /proc/buddyinfo, /proc/zoneinfo and
/proc/pagetypeinfo to reduce code duplication.  It seems specific to what
vmstat.c requires but could be broken out as a general utility function in
mmzone.c if there were other other potential users.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/proc/proc_misc.c    |   14 ++
 include/linux/gfp.h    |   12 +
 include/linux/mmzone.h |   10 +
 mm/page_alloc.c        |   20 ---
 mm/vmstat.c            |  284 +++++++++++++++++++++++++++++++-------------
 5 files changed, 240 insertions(+), 100 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-012-be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback/fs/proc/proc_misc.c linux-2.6.23-rc5-013-print-out-statistics-in-relation-to-fragmentation-avoidance-to-proc-pagetypeinfo/fs/proc/proc_misc.c
--- linux-2.6.23-rc5-012-be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback/fs/proc/proc_misc.c	2007-09-02 16:22:31.000000000 +0100
+++ linux-2.6.23-rc5-013-print-out-statistics-in-relation-to-fragmentation-avoidance-to-proc-pagetypeinfo/fs/proc/proc_misc.c	2007-09-02 16:23:11.000000000 +0100
@@ -230,6 +230,19 @@ static const struct file_operations frag
 	.release	= seq_release,
 };
 
+extern struct seq_operations pagetypeinfo_op;
+static int pagetypeinfo_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &pagetypeinfo_op);
+}
+
+static const struct file_operations pagetypeinfo_file_ops = {
+	.open		= pagetypeinfo_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 extern struct seq_operations zoneinfo_op;
 static int zoneinfo_open(struct inode *inode, struct file *file)
 {
@@ -716,6 +729,7 @@ void __init proc_misc_init(void)
 #endif
 #endif
 	create_seq_entry("buddyinfo",S_IRUGO, &fragmentation_file_operations);
+	create_seq_entry("pagetypeinfo", S_IRUGO, &pagetypeinfo_file_ops);
 	create_seq_entry("vmstat",S_IRUGO, &proc_vmstat_file_operations);
 	create_seq_entry("zoneinfo",S_IRUGO, &proc_zoneinfo_file_operations);
 #ifdef CONFIG_BLOCK
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-012-be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback/include/linux/gfp.h linux-2.6.23-rc5-013-print-out-statistics-in-relation-to-fragmentation-avoidance-to-proc-pagetypeinfo/include/linux/gfp.h
--- linux-2.6.23-rc5-012-be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback/include/linux/gfp.h	2007-09-02 16:22:29.000000000 +0100
+++ linux-2.6.23-rc5-013-print-out-statistics-in-relation-to-fragmentation-avoidance-to-proc-pagetypeinfo/include/linux/gfp.h	2007-09-02 16:23:11.000000000 +0100
@@ -100,6 +100,18 @@ struct vm_area_struct;
 /* 4GB DMA on some platforms */
 #define GFP_DMA32	__GFP_DMA32
 
+/* Convert GFP flags to their corresponding migrate type */
+static inline int allocflags_to_migratetype(gfp_t gfp_flags)
+{
+	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
+
+	if (unlikely(page_group_by_mobility_disabled))
+		return MIGRATE_UNMOVABLE;
+
+	/* Group based on mobility */
+	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
+		((gfp_flags & __GFP_RECLAIMABLE) != 0);
+}
 
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-012-be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback/include/linux/mmzone.h linux-2.6.23-rc5-013-print-out-statistics-in-relation-to-fragmentation-avoidance-to-proc-pagetypeinfo/include/linux/mmzone.h
--- linux-2.6.23-rc5-012-be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback/include/linux/mmzone.h	2007-09-02 16:22:29.000000000 +0100
+++ linux-2.6.23-rc5-013-print-out-statistics-in-relation-to-fragmentation-avoidance-to-proc-pagetypeinfo/include/linux/mmzone.h	2007-09-02 16:23:11.000000000 +0100
@@ -43,6 +43,16 @@
 	for (order = 0; order < MAX_ORDER; order++) \
 		for (type = 0; type < MIGRATE_TYPES; type++)
 
+extern int page_group_by_mobility_disabled;
+
+static inline int get_pageblock_migratetype(struct page *page)
+{
+	if (unlikely(page_group_by_mobility_disabled))
+		return MIGRATE_UNMOVABLE;
+
+	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
+}
+
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-012-be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback/mm/page_alloc.c linux-2.6.23-rc5-013-print-out-statistics-in-relation-to-fragmentation-avoidance-to-proc-pagetypeinfo/mm/page_alloc.c
--- linux-2.6.23-rc5-012-be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback/mm/page_alloc.c	2007-09-02 16:22:47.000000000 +0100
+++ linux-2.6.23-rc5-013-print-out-statistics-in-relation-to-fragmentation-avoidance-to-proc-pagetypeinfo/mm/page_alloc.c	2007-09-02 16:23:11.000000000 +0100
@@ -156,32 +156,12 @@ EXPORT_SYMBOL(nr_node_ids);
 
 int page_group_by_mobility_disabled __read_mostly;
 
-static inline int get_pageblock_migratetype(struct page *page)
-{
-	if (unlikely(page_group_by_mobility_disabled))
-		return MIGRATE_UNMOVABLE;
-
-	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
-}
-
 static void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 	set_pageblock_flags_group(page, (unsigned long)migratetype,
 					PB_migrate, PB_migrate_end);
 }
 
-static inline int allocflags_to_migratetype(gfp_t gfp_flags)
-{
-	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
-
-	if (unlikely(page_group_by_mobility_disabled))
-		return MIGRATE_UNMOVABLE;
-
-	/* Cluster based on mobility */
-	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
-		((gfp_flags & __GFP_RECLAIMABLE) != 0);
-}
-
 #ifdef CONFIG_DEBUG_VM
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-012-be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback/mm/vmstat.c linux-2.6.23-rc5-013-print-out-statistics-in-relation-to-fragmentation-avoidance-to-proc-pagetypeinfo/mm/vmstat.c
--- linux-2.6.23-rc5-012-be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback/mm/vmstat.c	2007-09-02 16:22:34.000000000 +0100
+++ linux-2.6.23-rc5-013-print-out-statistics-in-relation-to-fragmentation-avoidance-to-proc-pagetypeinfo/mm/vmstat.c	2007-09-02 16:23:11.000000000 +0100
@@ -398,6 +398,13 @@ void zone_statistics(struct zonelist *zo
 
 #include <linux/seq_file.h>
 
+static char * const migratetype_names[MIGRATE_TYPES] = {
+	"Unmovable",
+	"Reclaimable",
+	"Movable",
+	"Reserve",
+};
+
 static void *frag_start(struct seq_file *m, loff_t *pos)
 {
 	pg_data_t *pgdat;
@@ -422,28 +429,144 @@ static void frag_stop(struct seq_file *m
 {
 }
 
-/*
- * This walks the free areas for each zone.
- */
-static int frag_show(struct seq_file *m, void *arg)
+/* Walk all the zones in a node and print using a callback */
+static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
+		void (*print)(struct seq_file *m, pg_data_t *, struct zone *))
 {
-	pg_data_t *pgdat = (pg_data_t *)arg;
 	struct zone *zone;
 	struct zone *node_zones = pgdat->node_zones;
 	unsigned long flags;
-	int order;
 
 	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
 		if (!populated_zone(zone))
 			continue;
 
 		spin_lock_irqsave(&zone->lock, flags);
-		seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
-		for (order = 0; order < MAX_ORDER; ++order)
-			seq_printf(m, "%6lu ", zone->free_area[order].nr_free);
+		print(m, pgdat, zone);
 		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+}
+
+static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
+						struct zone *zone)
+{
+	int order;
+
+	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	for (order = 0; order < MAX_ORDER; ++order)
+		seq_printf(m, "%6lu ", zone->free_area[order].nr_free);
+	seq_putc(m, '\n');
+}
+
+/*
+ * This walks the free areas for each zone.
+ */
+static int frag_show(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+	walk_zones_in_node(m, pgdat, frag_show_print);
+	return 0;
+}
+
+static void pagetypeinfo_showfree_print(struct seq_file *m,
+					pg_data_t *pgdat, struct zone *zone)
+{
+	int order, mtype;
+
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++) {
+		seq_printf(m, "Node %4d, zone %8s, type %12s ",
+					pgdat->node_id,
+					zone->name,
+					migratetype_names[mtype]);
+		for (order = 0; order < MAX_ORDER; ++order) {
+			unsigned long freecount = 0;
+			struct free_area *area;
+			struct list_head *curr;
+
+			area = &(zone->free_area[order]);
+
+			list_for_each(curr, &area->free_list[mtype])
+				freecount++;
+			seq_printf(m, "%6lu ", freecount);
+		}
 		seq_putc(m, '\n');
 	}
+}
+
+/* Print out the free pages at each order for each migatetype */
+static int pagetypeinfo_showfree(struct seq_file *m, void *arg)
+{
+	int order;
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	/* Print header */
+	seq_printf(m, "%-43s ", "Free pages count per migrate type at order");
+	for (order = 0; order < MAX_ORDER; ++order)
+		seq_printf(m, "%6d ", order);
+	seq_putc(m, '\n');
+
+	walk_zones_in_node(m, pgdat, pagetypeinfo_showfree_print);
+
+	return 0;
+}
+
+static void pagetypeinfo_showblockcount_print(struct seq_file *m,
+					pg_data_t *pgdat, struct zone *zone)
+{
+	int mtype;
+	unsigned long pfn;
+	unsigned long start_pfn = zone->zone_start_pfn;
+	unsigned long end_pfn = start_pfn + zone->spanned_pages;
+	unsigned long count[MIGRATE_TYPES] = { 0, };
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
+		struct page *page;
+
+		if (!pfn_valid(pfn))
+			continue;
+
+		page = pfn_to_page(pfn);
+		mtype = get_pageblock_migratetype(page);
+
+		count[mtype]++;
+	}
+
+	/* Print counts */
+	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
+		seq_printf(m, "%12lu ", count[mtype]);
+	seq_putc(m, '\n');
+}
+
+/* Print out the free pages at each order for each migratetype */
+static int pagetypeinfo_showblockcount(struct seq_file *m, void *arg)
+{
+	int mtype;
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	seq_printf(m, "\n%-23s", "Number of blocks type ");
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
+		seq_printf(m, "%12s ", migratetype_names[mtype]);
+	seq_putc(m, '\n');
+	walk_zones_in_node(m, pgdat, pagetypeinfo_showblockcount_print);
+
+	return 0;
+}
+
+/*
+ * This prints out statistics in relation to grouping pages by mobility.
+ * It is expensive to collect so do not constantly read the file.
+ */
+static int pagetypeinfo_show(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	seq_printf(m, "Page block order: %d\n", pageblock_order);
+	seq_printf(m, "Pages per block:  %lu\n", pageblock_nr_pages);
+	seq_putc(m, '\n');
+	pagetypeinfo_showfree(m, pgdat);
+	pagetypeinfo_showblockcount(m, pgdat);
+
 	return 0;
 }
 
@@ -454,6 +577,13 @@ const struct seq_operations fragmentatio
 	.show	= frag_show,
 };
 
+const struct seq_operations pagetypeinfo_op = {
+	.start	= frag_start,
+	.next	= frag_next,
+	.stop	= frag_stop,
+	.show	= pagetypeinfo_show,
+};
+
 #ifdef CONFIG_ZONE_DMA
 #define TEXT_FOR_DMA(xx) xx "_dma",
 #else
@@ -532,84 +662,78 @@ static const char * const vmstat_text[] 
 #endif
 };
 
-/*
- * Output information about zones in @pgdat.
- */
-static int zoneinfo_show(struct seq_file *m, void *arg)
+static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
+							struct zone *zone)
 {
-	pg_data_t *pgdat = arg;
-	struct zone *zone;
-	struct zone *node_zones = pgdat->node_zones;
-	unsigned long flags;
-
-	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; zone++) {
-		int i;
+	int i;
+	seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
+	seq_printf(m,
+		   "\n  pages free     %lu"
+		   "\n        min      %lu"
+		   "\n        low      %lu"
+		   "\n        high     %lu"
+		   "\n        scanned  %lu (a: %lu i: %lu)"
+		   "\n        spanned  %lu"
+		   "\n        present  %lu",
+		   zone_page_state(zone, NR_FREE_PAGES),
+		   zone->pages_min,
+		   zone->pages_low,
+		   zone->pages_high,
+		   zone->pages_scanned,
+		   zone->nr_scan_active, zone->nr_scan_inactive,
+		   zone->spanned_pages,
+		   zone->present_pages);
 
-		if (!populated_zone(zone))
-			continue;
+	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+		seq_printf(m, "\n    %-12s %lu", vmstat_text[i],
+				zone_page_state(zone, i));
 
-		spin_lock_irqsave(&zone->lock, flags);
-		seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
-		seq_printf(m,
-			   "\n  pages free     %lu"
-			   "\n        min      %lu"
-			   "\n        low      %lu"
-			   "\n        high     %lu"
-			   "\n        scanned  %lu (a: %lu i: %lu)"
-			   "\n        spanned  %lu"
-			   "\n        present  %lu",
-			   zone_page_state(zone, NR_FREE_PAGES),
-			   zone->pages_min,
-			   zone->pages_low,
-			   zone->pages_high,
-			   zone->pages_scanned,
-			   zone->nr_scan_active, zone->nr_scan_inactive,
-			   zone->spanned_pages,
-			   zone->present_pages);
-
-		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-			seq_printf(m, "\n    %-12s %lu", vmstat_text[i],
-					zone_page_state(zone, i));
-
-		seq_printf(m,
-			   "\n        protection: (%lu",
-			   zone->lowmem_reserve[0]);
-		for (i = 1; i < ARRAY_SIZE(zone->lowmem_reserve); i++)
-			seq_printf(m, ", %lu", zone->lowmem_reserve[i]);
-		seq_printf(m,
-			   ")"
-			   "\n  pagesets");
-		for_each_online_cpu(i) {
-			struct per_cpu_pageset *pageset;
-			int j;
-
-			pageset = zone_pcp(zone, i);
-			for (j = 0; j < ARRAY_SIZE(pageset->pcp); j++) {
-				seq_printf(m,
-					   "\n    cpu: %i pcp: %i"
-					   "\n              count: %i"
-					   "\n              high:  %i"
-					   "\n              batch: %i",
-					   i, j,
-					   pageset->pcp[j].count,
-					   pageset->pcp[j].high,
-					   pageset->pcp[j].batch);
+	seq_printf(m,
+		   "\n        protection: (%lu",
+		   zone->lowmem_reserve[0]);
+	for (i = 1; i < ARRAY_SIZE(zone->lowmem_reserve); i++)
+		seq_printf(m, ", %lu", zone->lowmem_reserve[i]);
+	seq_printf(m,
+		   ")"
+		   "\n  pagesets");
+	for_each_online_cpu(i) {
+		struct per_cpu_pageset *pageset;
+		int j;
+
+		pageset = zone_pcp(zone, i);
+		for (j = 0; j < ARRAY_SIZE(pageset->pcp); j++) {
+			seq_printf(m,
+				   "\n    cpu: %i pcp: %i"
+				   "\n              count: %i"
+				   "\n              high:  %i"
+				   "\n              batch: %i",
+				   i, j,
+				   pageset->pcp[j].count,
+				   pageset->pcp[j].high,
+				   pageset->pcp[j].batch);
 			}
 #ifdef CONFIG_SMP
-			seq_printf(m, "\n  vm stats threshold: %d",
-					pageset->stat_threshold);
+		seq_printf(m, "\n  vm stats threshold: %d",
+				pageset->stat_threshold);
 #endif
-		}
-		seq_printf(m,
-			   "\n  all_unreclaimable: %u"
-			   "\n  prev_priority:     %i"
-			   "\n  start_pfn:         %lu",
-			   zone->all_unreclaimable,
-			   zone->prev_priority,
-			   zone->zone_start_pfn);
-		spin_unlock_irqrestore(&zone->lock, flags);
-		seq_putc(m, '\n');
 	}
+	seq_printf(m,
+		   "\n  all_unreclaimable: %u"
+		   "\n  prev_priority:     %i"
+		   "\n  start_pfn:         %lu",
+		   zone->all_unreclaimable,
+		   zone->prev_priority,
+		   zone->zone_start_pfn);
+	seq_putc(m, '\n');
+}
+
+/*
+ * Output information about zones in @pgdat.
+ */
+static int zoneinfo_show(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+	walk_zones_in_node(m, pgdat, zoneinfo_show_print);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
