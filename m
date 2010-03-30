Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B2A5F6B01FA
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 05:14:53 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 06/14] Export fragmentation index via /proc/extfrag_index
Date: Tue, 30 Mar 2010 10:14:41 +0100
Message-Id: <1269940489-5776-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fragmentation index is a value that makes sense when an allocation of a
given size would fail. The index indicates whether an allocation failure is
due to a lack of memory (values towards 0) or due to external fragmentation
(value towards 1).  For the most part, the huge page size will be the size
of interest but not necessarily so it is exported on a per-order and per-zone
basis via /proc/extfrag_index

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
---
 Documentation/filesystems/proc.txt |   14 ++++++-
 mm/vmstat.c                        |   82 ++++++++++++++++++++++++++++++++++++
 2 files changed, 95 insertions(+), 1 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index e87775a..c041638 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -422,6 +422,7 @@ Table 1-5: Kernel info in /proc
  filesystems Supported filesystems                             
  driver	     Various drivers grouped here, currently rtc (2.4)
  execdomains Execdomains, related to security			(2.4)
+ extfrag_index Additional page allocator information (see text) (2.5)
  fb	     Frame Buffer devices				(2.4)
  fs	     File system parameters, currently nfs/exports	(2.4)
  ide         Directory containing info about the IDE subsystem 
@@ -611,7 +612,7 @@ ZONE_DMA, 4 chunks of 2^1*PAGE_SIZE in ZONE_DMA, 101 chunks of 2^4*PAGE_SIZE
 available in ZONE_NORMAL, etc... 
 
 More information relevant to external fragmentation can be found in
-pagetypeinfo and unusable_index
+pagetypeinfo, unusable_index and extfrag_index.
 
 > cat /proc/pagetypeinfo
 Page block order: 9
@@ -662,6 +663,17 @@ value between 0 and 1. The higher the value, the more of free memory is
 unusable and by implication, the worse the external fragmentation is. This
 can be expressed as a percentage by multiplying by 100.
 
+> cat /proc/extfrag_index
+Node 0, zone      DMA -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.00
+Node 0, zone   Normal -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 0.954
+
+The external fragmentation index, is only meaningful if an allocation
+would fail and indicates what the failure is due to. A value of -1 such as
+in many of the examples above states that the allocation would succeed.
+If it would fail, the value is between 0 and 1. A value tending towards
+0 implies the allocation failed due to a lack of memory. A value tending
+towards 1 implies it failed due to external fragmentation.
+
 ..............................................................................
 
 meminfo:
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 2fb4986..351e491 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -15,6 +15,7 @@
 #include <linux/cpu.h>
 #include <linux/vmstat.h>
 #include <linux/sched.h>
+#include <linux/math64.h>
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
@@ -553,6 +554,67 @@ static int unusable_show(struct seq_file *m, void *arg)
 	return 0;
 }
 
+/*
+ * A fragmentation index only makes sense if an allocation of a requested
+ * size would fail. If that is true, the fragmentation index indicates
+ * whether external fragmentation or a lack of memory was the problem.
+ * The value can be used to determine if page reclaim or compaction
+ * should be used
+ */
+int fragmentation_index(unsigned int order, struct contig_page_info *info)
+{
+	unsigned long requested = 1UL << order;
+
+	if (!info->free_blocks_total)
+		return 0;
+
+	/* Fragmentation index only makes sense when a request would fail */
+	if (info->free_blocks_suitable)
+		return -1000;
+
+	/*
+	 * Index is between 0 and 1 so return within 3 decimal places
+	 *
+	 * 0 => allocation would fail due to lack of memory
+	 * 1 => allocation would fail due to fragmentation
+	 */
+	return 1000 - div_u64( (1000+(div_u64(info->free_pages * 1000ULL, requested))), info->free_blocks_total);
+}
+
+
+static void extfrag_show_print(struct seq_file *m,
+					pg_data_t *pgdat, struct zone *zone)
+{
+	unsigned int order;
+	int index;
+
+	/* Alloc on stack as interrupts are disabled for zone walk */
+	struct contig_page_info info;
+
+	seq_printf(m, "Node %d, zone %8s ",
+				pgdat->node_id,
+				zone->name);
+	for (order = 0; order < MAX_ORDER; ++order) {
+		fill_contig_page_info(zone, order, &info);
+		index = fragmentation_index(order, &info);
+		seq_printf(m, "%d.%03d ", index / 1000, index % 1000);
+	}
+
+	seq_putc(m, '\n');
+}
+
+/*
+ * Display fragmentation index for orders that allocations would fail for
+ */
+static int extfrag_show(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	walk_zones_in_node(m, pgdat, extfrag_show_print);
+
+	return 0;
+}
+
 static void pagetypeinfo_showfree_print(struct seq_file *m,
 					pg_data_t *pgdat, struct zone *zone)
 {
@@ -722,6 +784,25 @@ static const struct file_operations unusable_file_ops = {
 	.release	= seq_release,
 };
 
+static const struct seq_operations extfrag_op = {
+	.start	= frag_start,
+	.next	= frag_next,
+	.stop	= frag_stop,
+	.show	= extfrag_show,
+};
+
+static int extfrag_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &extfrag_op);
+}
+
+static const struct file_operations extfrag_file_ops = {
+	.open		= extfrag_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 #ifdef CONFIG_ZONE_DMA
 #define TEXT_FOR_DMA(xx) xx "_dma",
 #else
@@ -1067,6 +1148,7 @@ static int __init setup_vmstat(void)
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
 	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
 	proc_create("unusable_index", S_IRUGO, NULL, &unusable_file_ops);
+	proc_create("extfrag_index", S_IRUGO, NULL, &extfrag_file_ops);
 	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
 	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
 #endif
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
