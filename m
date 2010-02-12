Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F17BE6B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 07:01:01 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 04/12] Export fragmentation index via /proc/pagetypeinfo
Date: Fri, 12 Feb 2010 12:00:51 +0000
Message-Id: <1265976059-7459-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fragmentation index is a value that makes sense when an allocation of a
given size would fail. The index indicates whether an allocation failure is
due to a lack of memory (values towards 0) or due to external fragmentation
(value towards 1).  For the most part, the huge page size will be the size
of interest but not necessarily so it is exported on a per-order and per-zone
basis via /proc/pagetypeinfo.

The index is normally calculated as a value between 0 and 1 which is
obviously unsuitable within the kernel. Instead, the first three decimal
places are used as a value between 0 and 1000 for an integer approximation.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 Documentation/filesystems/proc.txt |   11 ++++++
 mm/vmstat.c                        |   63 ++++++++++++++++++++++++++++++++++++
 2 files changed, 74 insertions(+), 0 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 0968a81..06bf53c 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -618,6 +618,10 @@ Unusable free space index at order
 Node    0, zone      DMA                         0      0      0      2      6     18     34     67     99    227    485
 Node    0, zone    DMA32                         0      0      1      2      4      7     10     17     23     31     34
 
+Fragmentation index at order
+Node    0, zone      DMA                        -1     -1     -1     -1     -1     -1     -1     -1     -1     -1     -1
+Node    0, zone    DMA32                        -1     -1     -1     -1     -1     -1     -1     -1     -1     -1     -1
+
 Number of blocks type     Unmovable  Reclaimable      Movable      Reserve      Isolate
 Node 0, zone      DMA            2            0            5            1            0
 Node 0, zone    DMA32           41            6          967            2            0
@@ -639,6 +643,13 @@ value between 0 and 1000. The higher the value, the more of free memory is
 unusable and by implication, the worse the external fragmentation is. The
 percentage of unusable free memory can be found by dividing this value by 10.
 
+The fragmentation index, is only meaningful if an allocation would fail and
+indicates what the failure is due to. A value of -1 such as in the example
+states that the allocation would succeed. If it would fail, the value is
+between 0 and 1000. A value tending towards 0 implies the allocation failed
+due to a lack of memory. A value tending towards 1000 implies it failed
+due to external fragmentation.
+
 If min_free_kbytes has been tuned correctly (recommendations made by hugeadm
 from libhugetlbfs http://sourceforge.net/projects/libhugetlbfs/), one can
 make an estimate of the likely number of huge pages that can be allocated
diff --git a/mm/vmstat.c b/mm/vmstat.c
index d05d610..e2d0cc1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -494,6 +494,35 @@ static void fill_contig_page_info(struct zone *zone,
 }
 
 /*
+ * A fragmentation index only makes sense if an allocation of a requested
+ * size would fail. If that is true, the fragmentation index indicates
+ * whether external fragmentation or a lack of memory was the problem.
+ * The value can be used to determine if page reclaim or compaction
+ * should be used
+ */
+int fragmentation_index(struct zone *zone,
+				unsigned int order,
+				struct contig_page_info *info)
+{
+	unsigned long requested = 1UL << order;
+
+	if (!info->free_blocks_total)
+		return 0;
+
+	/* Fragmentation index only makes sense when a request would fail */
+	if (info->free_blocks_suitable)
+		return -1;
+
+	/*
+	 * Index is between 0 and 1 so return within 3 decimal places
+	 *
+	 * 0 => allocation would fail due to lack of memory
+	 * 1 => allocation would fail due to fragmentation
+	 */
+	return 1000 - ( (1000+(info->free_pages * 1000 / requested)) / info->free_blocks_total);
+}
+
+/*
  * Return an index indicating how much of the available free memory is
  * unusable for an allocation of the requested size.
  */
@@ -516,6 +545,39 @@ static int unusable_free_index(struct zone *zone,
 
 }
 
+static void pagetypeinfo_showfragmentation_print(struct seq_file *m,
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
+		seq_printf(m, "%6d ", fragmentation_index(zone, order, &info));
+	}
+
+	seq_putc(m, '\n');
+}
+
+/*
+ * Display fragmentation index for orders that allocations would fail for
+ * XXX: Could be a lot more efficient, but it's not a critical path
+ */
+static int pagetypeinfo_showfragmentation(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	seq_printf(m, "\nFragmentation index at order\n");
+	walk_zones_in_node(m, pgdat, pagetypeinfo_showfragmentation_print);
+
+	return 0;
+}
+
 static void pagetypeinfo_showunusable_print(struct seq_file *m,
 					pg_data_t *pgdat, struct zone *zone)
 {
@@ -657,6 +719,7 @@ static int pagetypeinfo_show(struct seq_file *m, void *arg)
 	seq_putc(m, '\n');
 	pagetypeinfo_showfree(m, pgdat);
 	pagetypeinfo_showunusable(m, pgdat);
+	pagetypeinfo_showfragmentation(m, pgdat);
 	pagetypeinfo_showblockcount(m, pgdat);
 
 	return 0;
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
