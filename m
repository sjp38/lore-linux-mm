Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7B53D6B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 08:42:52 -0400 (EDT)
Date: Tue, 13 Apr 2010 13:42:26 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 05/14] Export unusable free space index via
	/proc/unusable_index
Message-ID: <20100413124226.GV25756@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-6-git-send-email-mel@csn.ul.ie> <20100406170537.c84f54b7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170537.c84f54b7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:05:37PM -0700, Andrew Morton wrote:
> <SNIP>
> 
> All this code will be bloat for most people, I suspect.  Can we find a
> suitable #ifdef wrapper to keep my cellphone happy?
> 

==== CUT HERE ====
mm,compaction: Move unusable_index to debugfs

unusable_index can be worked out from userspace but for debugging and tuning
compaction, it'd be best for all users to have the same information. This
patch moves extfrag_index to debugfs where it is both easier to configure
out and remove at some future date.

This is a fix to the patch "Export unusable free space index via
/proc/unusable_index"

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 Documentation/filesystems/proc.txt |   13 +---
 mm/vmstat.c                        |  183 ++++++++++++++++++++----------------
 2 files changed, 105 insertions(+), 91 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index e87775a..74d2605 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -453,7 +453,6 @@ Table 1-5: Kernel info in /proc
  sys         See chapter 2                                     
  sysvipc     Info of SysVIPC Resources (msg, sem, shm)		(2.4)
  tty	     Info of tty drivers
- unusable_index Additional page allocator information (see text)(2.5)
  uptime      System uptime                                     
  version     Kernel version                                    
  video	     bttv info of video resources			(2.4)
@@ -611,7 +610,7 @@ ZONE_DMA, 4 chunks of 2^1*PAGE_SIZE in ZONE_DMA, 101 chunks of 2^4*PAGE_SIZE
 available in ZONE_NORMAL, etc... 
 
 More information relevant to external fragmentation can be found in
-pagetypeinfo and unusable_index
+pagetypeinfo.
 
 > cat /proc/pagetypeinfo
 Page block order: 9
@@ -652,16 +651,6 @@ unless memory has been mlock()'d. Some of the Reclaimable blocks should
 also be allocatable although a lot of filesystem metadata may have to be
 reclaimed to achieve this.
 
-> cat /proc/unusable_index
-Node 0, zone      DMA 0.000 0.000 0.000 0.001 0.005 0.013 0.021 0.037 0.037 0.101 0.230
-Node 0, zone   Normal 0.000 0.000 0.000 0.001 0.002 0.002 0.005 0.015 0.028 0.028 0.054
-
-The unusable free space index measures how much of the available free
-memory cannot be used to satisfy an allocation of a given size and is a
-value between 0 and 1. The higher the value, the more of free memory is
-unusable and by implication, the worse the external fragmentation is. This
-can be expressed as a percentage by multiplying by 100.
-
 ..............................................................................
 
 meminfo:
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 2fb4986..0dcf08d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -453,7 +453,6 @@ static int frag_show(struct seq_file *m, void *arg)
 	return 0;
 }
 
-
 struct contig_page_info {
 	unsigned long free_pages;
 	unsigned long free_blocks_total;
@@ -495,64 +494,6 @@ static void fill_contig_page_info(struct zone *zone,
 	}
 }
 
-/*
- * Return an index indicating how much of the available free memory is
- * unusable for an allocation of the requested size.
- */
-static int unusable_free_index(unsigned int order,
-				struct contig_page_info *info)
-{
-	/* No free memory is interpreted as all free memory is unusable */
-	if (info->free_pages == 0)
-		return 1000;
-
-	/*
-	 * Index should be a value between 0 and 1. Return a value to 3
-	 * decimal places.
-	 *
-	 * 0 => no fragmentation
-	 * 1 => high fragmentation
-	 */
-	return div_u64((info->free_pages - (info->free_blocks_suitable << order)) * 1000ULL, info->free_pages);
-
-}
-
-static void unusable_show_print(struct seq_file *m,
-					pg_data_t *pgdat, struct zone *zone)
-{
-	unsigned int order;
-	int index;
-	struct contig_page_info info;
-
-	seq_printf(m, "Node %d, zone %8s ",
-				pgdat->node_id,
-				zone->name);
-	for (order = 0; order < MAX_ORDER; ++order) {
-		fill_contig_page_info(zone, order, &info);
-		index = unusable_free_index(order, &info);
-		seq_printf(m, "%d.%03d ", index / 1000, index % 1000);
-	}
-
-	seq_putc(m, '\n');
-}
-
-/*
- * Display unusable free space index
- * XXX: Could be a lot more efficient, but it's not a critical path
- */
-static int unusable_show(struct seq_file *m, void *arg)
-{
-	pg_data_t *pgdat = (pg_data_t *)arg;
-
-	/* check memoryless node */
-	if (!node_state(pgdat->node_id, N_HIGH_MEMORY))
-		return 0;
-
-	walk_zones_in_node(m, pgdat, unusable_show_print);
-
-	return 0;
-}
-
 static void pagetypeinfo_showfree_print(struct seq_file *m,
 					pg_data_t *pgdat, struct zone *zone)
 {
@@ -703,25 +644,6 @@ static const struct file_operations pagetypeinfo_file_ops = {
 	.release	= seq_release,
 };
 
-static const struct seq_operations unusable_op = {
-	.start	= frag_start,
-	.next	= frag_next,
-	.stop	= frag_stop,
-	.show	= unusable_show,
-};
-
-static int unusable_open(struct inode *inode, struct file *file)
-{
-	return seq_open(file, &unusable_op);
-}
-
-static const struct file_operations unusable_file_ops = {
-	.open		= unusable_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= seq_release,
-};
-
 #ifdef CONFIG_ZONE_DMA
 #define TEXT_FOR_DMA(xx) xx "_dma",
 #else
@@ -1066,10 +988,113 @@ static int __init setup_vmstat(void)
 #ifdef CONFIG_PROC_FS
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
 	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
-	proc_create("unusable_index", S_IRUGO, NULL, &unusable_file_ops);
 	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
 	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
 #endif
 	return 0;
 }
 module_init(setup_vmstat)
+
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
