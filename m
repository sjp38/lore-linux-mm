Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6356B01F7
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 17:01:22 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 06/14] mm: Export unusable free space index via debugfs
Date: Tue, 20 Apr 2010 22:01:08 +0100
Message-Id: <1271797276-31358-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The unusable free space index measures how much of the available free
memory cannot be used to satisfy an allocation of a given size and is
a value between 0 and 1. The higher the value, the more of free memory
is unusable and by implication, the worse the external fragmentation
is. For the most part, the huge page size will be the size of interest
but not necessarily so it is exported on a per-order and per-zone basis
via /sys/kernel/debug/extfrag/unusable_index.

> cat /sys/kernel/debug/extfrag/unusable_index
Node 0, zone      DMA 0.000 0.000 0.000 0.001 0.005 0.013 0.021 0.037 0.037 0.101 0.230
Node 0, zone   Normal 0.000 0.000 0.000 0.001 0.002 0.002 0.005 0.015 0.028 0.028 0.054

[akpm@linux-foundation.org: Fix allnoconfig]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
---
 mm/vmstat.c |  150 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 149 insertions(+), 1 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index fa12ea3..d3e0fa1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -379,7 +379,50 @@ void zone_statistics(struct zone *preferred_zone, struct zone *z)
 }
 #endif
 
-#ifdef CONFIG_PROC_FS
+#ifdef CONFIG_COMPACTION
+struct contig_page_info {
+	unsigned long free_pages;
+	unsigned long free_blocks_total;
+	unsigned long free_blocks_suitable;
+};
+
+/*
+ * Calculate the number of free pages in a zone, how many contiguous
+ * pages are free and how many are large enough to satisfy an allocation of
+ * the target size. Note that this function makes no attempt to estimate
+ * how many suitable free blocks there *might* be if MOVABLE pages were
+ * migrated. Calculating that is possible, but expensive and can be
+ * figured out from userspace
+ */
+static void fill_contig_page_info(struct zone *zone,
+				unsigned int suitable_order,
+				struct contig_page_info *info)
+{
+	unsigned int order;
+
+	info->free_pages = 0;
+	info->free_blocks_total = 0;
+	info->free_blocks_suitable = 0;
+
+	for (order = 0; order < MAX_ORDER; order++) {
+		unsigned long blocks;
+
+		/* Count number of free blocks */
+		blocks = zone->free_area[order].nr_free;
+		info->free_blocks_total += blocks;
+
+		/* Count free base pages */
+		info->free_pages += blocks << order;
+
+		/* Count the suitable free blocks */
+		if (order >= suitable_order)
+			info->free_blocks_suitable += blocks <<
+						(order - suitable_order);
+	}
+}
+#endif
+
+#if defined(CONFIG_PROC_FS) || defined(CONFIG_COMPACTION)
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
@@ -432,7 +475,9 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 }
+#endif
 
+#ifdef CONFIG_PROC_FS
 static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 						struct zone *zone)
 {
@@ -954,3 +999,106 @@ static int __init setup_vmstat(void)
 	return 0;
 }
 module_init(setup_vmstat)
+
+#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
+#include <linux/debugfs.h>
+
+static struct dentry *extfrag_debug_root;
+
+/*
+ * Return an index indicating how much of the available free memory is
+ * unusable for an allocation of the requested size.
+ */
+static int unusable_free_index(unsigned int order,
+				struct contig_page_info *info)
+{
+	/* No free memory is interpreted as all free memory is unusable */
+	if (info->free_pages == 0)
+		return 1000;
+
+	/*
+	 * Index should be a value between 0 and 1. Return a value to 3
+	 * decimal places.
+	 *
+	 * 0 => no fragmentation
+	 * 1 => high fragmentation
+	 */
+	return div_u64((info->free_pages - (info->free_blocks_suitable << order)) * 1000ULL, info->free_pages);
+
+}
+
+static void unusable_show_print(struct seq_file *m,
+					pg_data_t *pgdat, struct zone *zone)
+{
+	unsigned int order;
+	int index;
+	struct contig_page_info info;
+
+	seq_printf(m, "Node %d, zone %8s ",
+				pgdat->node_id,
+				zone->name);
+	for (order = 0; order < MAX_ORDER; ++order) {
+		fill_contig_page_info(zone, order, &info);
+		index = unusable_free_index(order, &info);
+		seq_printf(m, "%d.%03d ", index / 1000, index % 1000);
+	}
+
+	seq_putc(m, '\n');
+}
+
+/*
+ * Display unusable free space index
+ *
+ * The unusable free space index measures how much of the available free
+ * memory cannot be used to satisfy an allocation of a given size and is a
+ * value between 0 and 1. The higher the value, the more of free memory is
+ * unusable and by implication, the worse the external fragmentation is. This
+ * can be expressed as a percentage by multiplying by 100.
+ */
+static int unusable_show(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	/* check memoryless node */
+	if (!node_state(pgdat->node_id, N_HIGH_MEMORY))
+		return 0;
+
+	walk_zones_in_node(m, pgdat, unusable_show_print);
+
+	return 0;
+}
+
+static const struct seq_operations unusable_op = {
+	.start	= frag_start,
+	.next	= frag_next,
+	.stop	= frag_stop,
+	.show	= unusable_show,
+};
+
+static int unusable_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &unusable_op);
+}
+
+static const struct file_operations unusable_file_ops = {
+	.open		= unusable_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+static int __init extfrag_debug_init(void)
+{
+	extfrag_debug_root = debugfs_create_dir("extfrag", NULL);
+	if (!extfrag_debug_root)
+		return -ENOMEM;
+
+	if (!debugfs_create_file("unusable_index", 0444,
+			extfrag_debug_root, NULL, &unusable_file_ops))
+		return -ENOMEM;
+
+	return 0;
+}
+
+module_init(extfrag_debug_init);
+#endif
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
