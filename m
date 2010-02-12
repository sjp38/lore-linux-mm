Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3A46B007B
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 07:01:02 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 03/12] Export unusable free space index via /proc/pagetypeinfo
Date: Fri, 12 Feb 2010 12:00:50 +0000
Message-Id: <1265976059-7459-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Unusuable free space index is a measure of external fragmentation that
takes the allocation size into account. For the most part, the huge page
size will be the size of interest but not necessarily so it is exported
on a per-order and per-zone basis via /proc/pagetypeinfo.

The index is normally calculated as a value between 0 and 1 which is
obviously unsuitable within the kernel. Instead, the first three decimal
places are used as a value between 0 and 1000 for an integer approximation.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 Documentation/filesystems/proc.txt |   10 ++++
 mm/vmstat.c                        |   99 ++++++++++++++++++++++++++++++++++++
 2 files changed, 109 insertions(+), 0 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 1829dfb..0968a81 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -614,6 +614,10 @@ Node    0, zone    DMA32, type      Movable    169    152    113     91     77
 Node    0, zone    DMA32, type      Reserve      1      2      2      2      2      0      1      1      1      1      0
 Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
 
+Unusable free space index at order
+Node    0, zone      DMA                         0      0      0      2      6     18     34     67     99    227    485
+Node    0, zone    DMA32                         0      0      1      2      4      7     10     17     23     31     34
+
 Number of blocks type     Unmovable  Reclaimable      Movable      Reserve      Isolate
 Node 0, zone      DMA            2            0            5            1            0
 Node 0, zone    DMA32           41            6          967            2            0
@@ -629,6 +633,12 @@ then gives the same type of information as buddyinfo except broken down
 by migrate-type and finishes with details on how many page blocks of each
 type exist.
 
+The unusable free space index measures how much of the available free
+memory cannot be used to satisfy an allocation of a given size and is a
+value between 0 and 1000. The higher the value, the more of free memory is
+unusable and by implication, the worse the external fragmentation is. The
+percentage of unusable free memory can be found by dividing this value by 10.
+
 If min_free_kbytes has been tuned correctly (recommendations made by hugeadm
 from libhugetlbfs http://sourceforge.net/projects/libhugetlbfs/), one can
 make an estimate of the likely number of huge pages that can be allocated
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 6051fba..d05d610 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -451,6 +451,104 @@ static int frag_show(struct seq_file *m, void *arg)
 	return 0;
 }
 
+
+struct contig_page_info {
+	unsigned long free_pages;
+	unsigned long free_blocks_total;
+	unsigned long free_blocks_suitable;
+};
+
+/*
+ * Calculate the number of free pages in a zone, how many contiguous
+ * pages are free and how many are large enough to satisfy an allocation of
+ * the target size. Note that this function makes to attempt to estimate
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
+
+/*
+ * Return an index indicating how much of the available free memory is
+ * unusable for an allocation of the requested size.
+ */
+static int unusable_free_index(struct zone *zone,
+				unsigned int order,
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
+	return ((info->free_pages - (info->free_blocks_suitable << order)) * 1000) / info->free_pages;
+
+}
+
+static void pagetypeinfo_showunusable_print(struct seq_file *m,
+					pg_data_t *pgdat, struct zone *zone)
+{
+	unsigned int order;
+
+	/* Alloc on stack as interrupts are disabled for zone walk */
+	struct contig_page_info info;
+
+	seq_printf(m, "Node %4d, zone %8s %19s",
+				pgdat->node_id,
+				zone->name, " ");
+	for (order = 0; order < MAX_ORDER; ++order) {
+		fill_contig_page_info(zone, order, &info);
+		seq_printf(m, "%6d ", unusable_free_index(zone, order, &info));
+	}
+
+	seq_putc(m, '\n');
+}
+
+/*
+ * Display unusable free space index
+ * XXX: Could be a lot more efficient, but it's not a critical path
+ */
+static int pagetypeinfo_showunusable(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	seq_printf(m, "\nUnusable free space index at order\n");
+	walk_zones_in_node(m, pgdat, pagetypeinfo_showunusable_print);
+
+	return 0;
+}
+
 static void pagetypeinfo_showfree_print(struct seq_file *m,
 					pg_data_t *pgdat, struct zone *zone)
 {
@@ -558,6 +656,7 @@ static int pagetypeinfo_show(struct seq_file *m, void *arg)
 	seq_printf(m, "Pages per block:  %lu\n", pageblock_nr_pages);
 	seq_putc(m, '\n');
 	pagetypeinfo_showfree(m, pgdat);
+	pagetypeinfo_showunusable(m, pgdat);
 	pagetypeinfo_showblockcount(m, pgdat);
 
 	return 0;
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
