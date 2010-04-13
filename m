Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4916B01EF
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 08:44:31 -0400 (EDT)
Date: Tue, 13 Apr 2010 13:43:15 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 06/14] Export fragmentation index via
	/proc/extfrag_index
Message-ID: <20100413124315.GW25756@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-7-git-send-email-mel@csn.ul.ie> <20100406170542.fe9b9f33.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170542.fe9b9f33.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:05:42PM -0700, Andrew Morton wrote:
> On Fri,  2 Apr 2010 17:02:40 +0100
> > Fragmentation index is a value that makes sense when an allocation of a
> > given size would fail. The index indicates whether an allocation failure is
> > due to a lack of memory (values towards 0) or due to external fragmentation
> > (value towards 1).  For the most part, the huge page size will be the size
> > of interest but not necessarily so it is exported on a per-order and per-zone
> > basis via /proc/extfrag_index
> 
> (/proc/sys/vm?)
> 
> Like unusable_index, this seems awfully specialised.  Perhaps we could
> hide it under CONFIG_MEL, or even put it in debugfs with the intention
> of removing it in 6 or 12 months time. 
> <SNIP>

==== CUT HERE ====
mm,compaction: Move extfrag_index to debugfs

extfrag_index can be worked out from userspace but for debugging and
tuning compaction, it'd be best for all users to have the same
information. This patch moves extfrag_index to debugfs where it is both
easier to configure out and remove at some future date.

This is a fix to the patch "Export fragmentation index via
/proc/extfrag_index". When merged, it'll collide with the patch "Direct
compact when a high-order allocation fails" but the resolution is
relatively straight forward - preserve the fragmentation_index functions
and delete the proc-related functions as they are now at the bottom of
the file under ifdef CONFIG_DEBUG_FS.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 Documentation/filesystems/proc.txt |   14 +----
 mm/vmstat.c                        |  110 ++++++++++++++++++------------------
 2 files changed, 57 insertions(+), 67 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 66ebc11..74d2605 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -422,7 +422,6 @@ Table 1-5: Kernel info in /proc
  filesystems Supported filesystems                             
  driver	     Various drivers grouped here, currently rtc (2.4)
  execdomains Execdomains, related to security			(2.4)
- extfrag_index Additional page allocator information (see text) (2.5)
  fb	     Frame Buffer devices				(2.4)
  fs	     File system parameters, currently nfs/exports	(2.4)
  ide         Directory containing info about the IDE subsystem 
@@ -611,7 +610,7 @@ ZONE_DMA, 4 chunks of 2^1*PAGE_SIZE in ZONE_DMA, 101 chunks of 2^4*PAGE_SIZE
 available in ZONE_NORMAL, etc... 
 
 More information relevant to external fragmentation can be found in
-pagetypeinfo and extfrag_index.
+pagetypeinfo.
 
 > cat /proc/pagetypeinfo
 Page block order: 9
@@ -652,17 +651,6 @@ unless memory has been mlock()'d. Some of the Reclaimable blocks should
 also be allocatable although a lot of filesystem metadata may have to be
 reclaimed to achieve this.
 
-> cat /proc/extfrag_index
-Node 0, zone      DMA -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.00
-Node 0, zone   Normal -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 0.954
-
-The external fragmentation index, is only meaningful if an allocation
-would fail and indicates what the failure is due to. A value of -1 such as
-in many of the examples above states that the allocation would succeed.
-If it would fail, the value is between 0 and 1. A value tending towards
-0 implies the allocation failed due to a lack of memory. A value tending
-towards 1 implies it failed due to external fragmentation.
-
 ..............................................................................
 
 meminfo:
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 582dc77..f70da05 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -522,40 +522,6 @@ int fragmentation_index(unsigned int order, struct contig_page_info *info)
 	return 1000 - div_u64( (1000+(div_u64(info->free_pages * 1000ULL, requested))), info->free_blocks_total);
 }
 
-
-static void extfrag_show_print(struct seq_file *m,
-					pg_data_t *pgdat, struct zone *zone)
-{
-	unsigned int order;
-	int index;
-
-	/* Alloc on stack as interrupts are disabled for zone walk */
-	struct contig_page_info info;
-
-	seq_printf(m, "Node %d, zone %8s ",
-				pgdat->node_id,
-				zone->name);
-	for (order = 0; order < MAX_ORDER; ++order) {
-		fill_contig_page_info(zone, order, &info);
-		index = fragmentation_index(order, &info);
-		seq_printf(m, "%d.%03d ", index / 1000, index % 1000);
-	}
-
-	seq_putc(m, '\n');
-}
-
-/*
- * Display fragmentation index for orders that allocations would fail for
- */
-static int extfrag_show(struct seq_file *m, void *arg)
-{
-	pg_data_t *pgdat = (pg_data_t *)arg;
-
-	walk_zones_in_node(m, pgdat, extfrag_show_print);
-
-	return 0;
-}
-
 static void pagetypeinfo_showfree_print(struct seq_file *m,
 					pg_data_t *pgdat, struct zone *zone)
 {
@@ -706,25 +672,6 @@ static const struct file_operations pagetypeinfo_file_ops = {
 	.release	= seq_release,
 };
 
-static const struct seq_operations extfrag_op = {
-	.start	= frag_start,
-	.next	= frag_next,
-	.stop	= frag_stop,
-	.show	= extfrag_show,
-};
-
-static int extfrag_open(struct inode *inode, struct file *file)
-{
-	return seq_open(file, &extfrag_op);
-}
-
-static const struct file_operations extfrag_file_ops = {
-	.open		= extfrag_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= seq_release,
-};
-
 #ifdef CONFIG_ZONE_DMA
 #define TEXT_FOR_DMA(xx) xx "_dma",
 #else
@@ -1069,7 +1016,6 @@ static int __init setup_vmstat(void)
 #ifdef CONFIG_PROC_FS
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
 	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
-	proc_create("extfrag_index", S_IRUGO, NULL, &extfrag_file_ops);
 	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
 	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
 #endif
@@ -1165,6 +1111,58 @@ static const struct file_operations unusable_file_ops = {
 	.release	= seq_release,
 };
 
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
 static int __init extfrag_debug_init(void)
 {
 	extfrag_debug_root = debugfs_create_dir("extfrag", NULL);
@@ -1175,6 +1173,10 @@ static int __init extfrag_debug_init(void)
 			extfrag_debug_root, NULL, &unusable_file_ops))
 		return -ENOMEM;
 
+	if (!debugfs_create_file("extfrag_index", 0444,
+			extfrag_debug_root, NULL, &extfrag_file_ops))
+		return -ENOMEM;
+
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
