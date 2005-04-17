From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16994.40502.570586.277989@gargle.gargle.HOWL>
Date: Sun, 17 Apr 2005 21:34:46 +0400
Subject: [PATCH]: VM 1/8 /proc/zoneinfo 
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <AKPM@Osdl.ORG>
List-ID: <linux-mm.kvack.org>

Add /proc/zoneinfo file to display information about memory zones. Useful to
analyze VM behaviour.

Signed-off-by: Nikita Danilov <nikita@clusterfs.com>


 fs/proc/proc_misc.c |   15 ++++++
 mm/page_alloc.c     |  130 +++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 133 insertions(+), 12 deletions(-)

diff -puN fs/proc/proc_misc.c~zoneinfo fs/proc/proc_misc.c
--- bk-linux/fs/proc/proc_misc.c~zoneinfo	2005-04-17 17:52:48.000000000 +0400
+++ bk-linux-nikita/fs/proc/proc_misc.c	2005-04-17 17:52:48.000000000 +0400
@@ -214,6 +214,20 @@ static struct file_operations fragmentat
 	.release	= seq_release,
 };
 
+extern struct seq_operations zoneinfo_op;
+static int zoneinfo_open(struct inode *inode, struct file *file)
+{
+	(void)inode;
+	return seq_open(file, &zoneinfo_op);
+}
+
+static struct file_operations proc_zoneinfo_file_operations = {
+	.open		= zoneinfo_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 static int version_read_proc(char *page, char **start, off_t off,
 				 int count, int *eof, void *data)
 {
@@ -584,6 +598,7 @@ void __init proc_misc_init(void)
 	create_seq_entry("slabinfo",S_IWUSR|S_IRUGO,&proc_slabinfo_operations);
 	create_seq_entry("buddyinfo",S_IRUGO, &fragmentation_file_operations);
 	create_seq_entry("vmstat",S_IRUGO, &proc_vmstat_file_operations);
+	create_seq_entry("zoneinfo",S_IRUGO, &proc_zoneinfo_file_operations);
 	create_seq_entry("diskstats", 0, &proc_diskstats_operations);
 #ifdef CONFIG_MODULES
 	create_seq_entry("modules", 0, &proc_modules_operations);
diff -puN mm/page_alloc.c~zoneinfo mm/page_alloc.c
--- bk-linux/mm/page_alloc.c~zoneinfo	2005-04-17 17:52:48.000000000 +0400
+++ bk-linux-nikita/mm/page_alloc.c	2005-04-17 17:52:48.000000000 +0400
@@ -1836,6 +1836,112 @@ struct seq_operations fragmentation_op =
 	.show	= frag_show,
 };
 
+/*
+ * Output information about zones in @pgdat.
+ */
+static int zoneinfo_show(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+	struct zone *zone;
+	struct zone *node_zones = pgdat->node_zones;
+	unsigned long flags;
+
+	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
+		int i;
+
+		if (!zone->present_pages)
+			continue;
+
+		spin_lock_irqsave(&zone->lock, flags);
+		seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
+		seq_printf(m,
+			   "\n  pages free     %lu"
+			   "\n        min      %lu"
+			   "\n        low      %lu"
+			   "\n        high     %lu"
+			   "\n        active   %lu"
+			   "\n        inactive %lu"
+			   "\n        scanned  %lu (a: %lu i: %lu)"
+			   "\n        spanned  %lu"
+			   "\n        present  %lu",
+			   zone->free_pages,
+			   zone->pages_min,
+			   zone->pages_low,
+			   zone->pages_high,
+			   zone->nr_active,
+			   zone->nr_inactive,
+			   zone->pages_scanned,
+			   zone->nr_scan_active, zone->nr_scan_inactive,
+			   zone->spanned_pages,
+			   zone->present_pages);
+		seq_printf(m,
+			   "\n        protection: (%lu",
+			   zone->lowmem_reserve[0]);
+		for (i = 1; i < ARRAY_SIZE(zone->lowmem_reserve); ++ i)
+			seq_printf(m, ", %lu", zone->lowmem_reserve[i]);
+		seq_printf(m,
+			   ")"
+			   "\n  pagesets");
+		for (i = 0; i < ARRAY_SIZE(zone->pageset); ++ i) {
+			struct per_cpu_pageset *pageset;
+			int j;
+
+			pageset = &zone->pageset[i];
+			if (pageset->pcp[0].count == 0 &&
+			    pageset->pcp[1].count == 0)
+				continue;
+			for (j = 0; j < ARRAY_SIZE(pageset->pcp); ++ j) {
+				seq_printf(m,
+					   "\n    cpu: %i pcp: %i"
+					   "\n              count: %i"
+					   "\n              low:   %i"
+					   "\n              high:  %i"
+					   "\n              batch: %i",
+					   i, j,
+					   pageset->pcp[j].count,
+					   pageset->pcp[j].low,
+					   pageset->pcp[j].high,
+					   pageset->pcp[j].batch);
+			}
+#ifdef CONFIG_NUMA
+			seq_printf(m,
+				   "\n            numa_hit:       %lu"
+				   "\n            numa_miss:      %lu"
+				   "\n            numa_foreign:   %lu"
+				   "\n            interleave_hit: %lu"
+				   "\n            local_node:     %lu"
+				   "\n            other_node:     %lu",
+				   pageset->numa_hit,
+				   pageset->numa_miss,
+				   pageset->numa_foreign,
+				   pageset->interleave_hit,
+				   pageset->local_node,
+				   pageset->other_node);
+#endif
+		}
+		seq_printf(m,
+			   "\n  all_unreclaimable: %u"
+			   "\n  prev_priority:     %i"
+			   "\n  temp_priority:     %i"
+			   "\n  start_pfn:         %lu",
+			   zone->all_unreclaimable,
+			   zone->prev_priority,
+			   zone->temp_priority,
+			   zone->zone_start_pfn);
+		spin_unlock_irqrestore(&zone->lock, flags);
+		seq_putc(m, '\n');
+	}
+	return 0;
+}
+
+struct seq_operations zoneinfo_op = {
+	.start	= frag_start, /* iterate over all zones. The same as in
+			       * fragmentation. */
+	.next	= frag_next,
+	.stop	= frag_stop,
+	.show	= zoneinfo_show,
+};
+
 static char *vmstat_text[] = {
 	"nr_dirty",
 	"nr_writeback",
@@ -2040,10 +2146,10 @@ static void setup_per_zone_pages_min(voi
 				min_pages = 128;
 			zone->pages_min = min_pages;
 		} else {
-			/* if it's a lowmem zone, reserve a number of pages 
+			/* if it's a lowmem zone, reserve a number of pages
 			 * proportionate to the zone's size.
 			 */
-			zone->pages_min = (pages_min * zone->present_pages) / 
+			zone->pages_min = (pages_min * zone->present_pages) /
 			                   lowmem_pages;
 		}
 

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
