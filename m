From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070618092941.7790.35167.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/7] Provide metrics on the extent of fragmentation in zones
Date: Mon, 18 Jun 2007 10:29:41 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

It is useful to know the state of external fragmentation in the system
and whether allocation failures are due to low memory or external
fragmentation. This patch introduces two metrics for evaluation the state
of fragmentation and exports the information to /proc/pagetypeinfo. The
metrics will be used later to determine if it is better to compact memory
or directly reclaim for a high-order allocation to succeed.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 vmstat.c |  131 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 131 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-020_isolate_nolock/mm/vmstat.c linux-2.6.22-rc4-mm2-105_measure_fragmentation/mm/vmstat.c
--- linux-2.6.22-rc4-mm2-020_isolate_nolock/mm/vmstat.c	2007-06-13 23:43:12.000000000 +0100
+++ linux-2.6.22-rc4-mm2-105_measure_fragmentation/mm/vmstat.c	2007-06-15 16:25:55.000000000 +0100
@@ -625,6 +625,135 @@ static void pagetypeinfo_showmixedcount_
 #endif /* CONFIG_PAGE_OWNER */
 
 /*
+ * Calculate the number of free pages in a zone and how many contiguous
+ * pages are free and how many are large enough to satisfy an allocation of
+ * the target size
+ */
+void calculate_freepages(struct zone *zone, unsigned int target_order,
+				unsigned long *ret_freepages,
+				unsigned long *ret_areas_free,
+				unsigned long *ret_suitable_areas_free)
+{
+	unsigned int order;
+	unsigned long freepages;
+	unsigned long areas_free;
+	unsigned long suitable_areas_free;
+
+	freepages = areas_free = suitable_areas_free = 0;
+	for (order = 0; order < MAX_ORDER; order++) {
+		unsigned long order_areas_free;
+
+		/* Count number of free blocks */
+		order_areas_free = zone->free_area[order].nr_free;
+		areas_free += order_areas_free;
+
+		/* Count free base pages */
+		freepages += order_areas_free << order;
+
+		/* Count the number of target_order sized free blocks */
+		if (order >= target_order)
+			suitable_areas_free += order_areas_free <<
+							(order - target_order);
+	}
+
+	*ret_freepages = freepages;
+	*ret_areas_free = areas_free;
+	*ret_suitable_areas_free = suitable_areas_free;
+}
+
+/*
+ * Return an index indicating how much of the available free memory is
+ * unusable for an allocation of the requested size. A value towards 100
+ * implies that the majority of free memory is unusable and compaction
+ * may be required.
+ */
+int unusable_free_index(struct zone *zone, unsigned int target_order)
+{
+	unsigned long freepages, areas_free, suitable_areas_free;
+
+	calculate_freepages(zone, target_order,
+				&freepages, &areas_free, &suitable_areas_free);
+
+	/* No free memory is interpreted as all free memory is unusable */
+	if (freepages == 0)
+		return 100;
+
+	return ((freepages - (suitable_areas_free << target_order)) * 100) /
+								freepages;
+}
+
+/*
+ * Return the external fragmentation index for a zone. Values towards 100
+ * imply the allocation failure was due to external fragmentation. Values
+ * towards 0 imply the failure was due to lack of memory. The value is only
+ * useful when an allocation of the requested order would fail and it does
+ * not take into account pages free on the pcp list.
+ */
+int fragmentation_index(struct zone *zone, unsigned int target_order)
+{
+	unsigned long freepages, areas_free, suitable_areas_free;
+
+	calculate_freepages(zone, target_order,
+				&freepages, &areas_free, &suitable_areas_free);
+
+	/* An allocation succeeding implies this index has no meaning */
+	if (suitable_areas_free)
+		return -1;
+
+	return 100 - ((freepages / (1 << target_order)) * 100) / areas_free;
+}
+
+static void pagetypeinfo_showunusable_print(struct seq_file *m,
+					pg_data_t *pgdat, struct zone *zone)
+{
+	unsigned int order;
+
+	seq_printf(m, "Node %4d, zone %8s %19s",
+				pgdat->node_id,
+				zone->name, " ");
+	for (order = 0; order < MAX_ORDER; ++order)
+		seq_printf(m, "%6d ", unusable_free_index(zone, order));
+
+	seq_putc(m, '\n');
+}
+
+/* Print out percentage of unusable free memory at each order */
+static int pagetypeinfo_showunusable(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	seq_printf(m, "\nPercentage unusable free memory at order\n");
+	walk_zones_in_node(m, pgdat, pagetypeinfo_showunusable_print);
+
+	return 0;
+}
+
+static void pagetypeinfo_showfragmentation_print(struct seq_file *m,
+					pg_data_t *pgdat, struct zone *zone)
+{
+	unsigned int order;
+
+	seq_printf(m, "Node %4d, zone %8s %19s",
+				pgdat->node_id,
+				zone->name, " ");
+	for (order = 0; order < MAX_ORDER; ++order)
+		seq_printf(m, "%6d ", fragmentation_index(zone, order));
+
+	seq_putc(m, '\n');
+}
+
+/* Print the fragmentation index at each order */
+static int pagetypeinfo_showfragmentation(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	seq_printf(m, "\nFragmentation index\n");
+	walk_zones_in_node(m, pgdat, pagetypeinfo_showfragmentation_print);
+
+	return 0;
+}
+
+/*
  * Print out the number of pageblocks for each migratetype that contain pages
  * of other types. This gives an indication of how well fallbacks are being
  * contained by rmqueue_fallback(). It requires information from PAGE_OWNER
@@ -656,6 +785,8 @@ static int pagetypeinfo_show(struct seq_
 	seq_printf(m, "Pages per block:  %lu\n", pageblock_nr_pages);
 	seq_putc(m, '\n');
 	pagetypeinfo_showfree(m, pgdat);
+	pagetypeinfo_showunusable(m, pgdat);
+	pagetypeinfo_showfragmentation(m, pgdat);
 	pagetypeinfo_showblockcount(m, pgdat);
 	pagetypeinfo_showmixedcount(m, pgdat);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
