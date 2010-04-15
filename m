Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0DFCC6B0218
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 19:40:14 -0400 (EDT)
Date: Thu, 15 Apr 2010 16:38:28 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm] vmstat: fix build errors when PROC_FS is disabled
Message-Id: <20100415163828.34f53758.randy.dunlap@oracle.com>
In-Reply-To: <201004152210.o3FMA7KV001909@imap1.linux-foundation.org>
References: <201004152210.o3FMA7KV001909@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix vmstat.c to build when CONFIG_PROC_FS is disabled
but CONFIG_DEBUG_FS is enabled.

Fixes around 25 errors.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmstat.c |  119 ++++++++++++++++++++++++--------------------------
 1 file changed, 59 insertions(+), 60 deletions(-)

--- mmotm-2010-0415-1442.orig/mm/vmstat.c
+++ mmotm-2010-0415-1442/mm/vmstat.c
@@ -16,6 +16,7 @@
 #include <linux/cpu.h>
 #include <linux/vmstat.h>
 #include <linux/sched.h>
+#include <linux/seq_file.h>
 #include <linux/math64.h>
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
@@ -380,18 +381,57 @@ void zone_statistics(struct zone *prefer
 }
 #endif
 
-#ifdef CONFIG_PROC_FS
-#include <linux/proc_fs.h>
-#include <linux/seq_file.h>
-
-static char * const migratetype_names[MIGRATE_TYPES] = {
-	"Unmovable",
-	"Reclaimable",
-	"Movable",
-	"Reserve",
-	"Isolate",
+struct contig_page_info {
+	unsigned long free_pages;
+	unsigned long free_blocks_total;
+	unsigned long free_blocks_suitable;
 };
 
+/* Walk all the zones in a node and print using a callback */
+static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
+		void (*print)(struct seq_file *m, pg_data_t *, struct zone *))
+{
+	struct zone *zone;
+	struct zone *node_zones = pgdat->node_zones;
+	unsigned long flags;
+
+	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
+		if (!populated_zone(zone))
+			continue;
+
+		spin_lock_irqsave(&zone->lock, flags);
+		print(m, pgdat, zone);
+		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+}
+
+/*
+ * A fragmentation index only makes sense if an allocation of a requested
+ * size would fail. If that is true, the fragmentation index indicates
+ * whether external fragmentation or a lack of memory was the problem.
+ * The value can be used to determine if page reclaim or compaction
+ * should be used
+ */
+int __fragmentation_index(unsigned int order, struct contig_page_info *info)
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
 static void *frag_start(struct seq_file *m, loff_t *pos)
 {
 	pg_data_t *pgdat;
@@ -416,23 +456,16 @@ static void frag_stop(struct seq_file *m
 {
 }
 
-/* Walk all the zones in a node and print using a callback */
-static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
-		void (*print)(struct seq_file *m, pg_data_t *, struct zone *))
-{
-	struct zone *zone;
-	struct zone *node_zones = pgdat->node_zones;
-	unsigned long flags;
-
-	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
-		if (!populated_zone(zone))
-			continue;
+#ifdef CONFIG_PROC_FS
+#include <linux/proc_fs.h>
 
-		spin_lock_irqsave(&zone->lock, flags);
-		print(m, pgdat, zone);
-		spin_unlock_irqrestore(&zone->lock, flags);
-	}
-}
+static char * const migratetype_names[MIGRATE_TYPES] = {
+	"Unmovable",
+	"Reclaimable",
+	"Movable",
+	"Reserve",
+	"Isolate",
+};
 
 static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 						struct zone *zone)
@@ -455,39 +488,6 @@ static int frag_show(struct seq_file *m,
 	return 0;
 }
 
-struct contig_page_info {
-	unsigned long free_pages;
-	unsigned long free_blocks_total;
-	unsigned long free_blocks_suitable;
-};
-
-/*
- * A fragmentation index only makes sense if an allocation of a requested
- * size would fail. If that is true, the fragmentation index indicates
- * whether external fragmentation or a lack of memory was the problem.
- * The value can be used to determine if page reclaim or compaction
- * should be used
- */
-int __fragmentation_index(unsigned int order, struct contig_page_info *info)
-{
-	unsigned long requested = 1UL << order;
-
-	if (!info->free_blocks_total)
-		return 0;
-
-	/* Fragmentation index only makes sense when a request would fail */
-	if (info->free_blocks_suitable)
-		return -1000;
-
-	/*
-	 * Index is between 0 and 1 so return within 3 decimal places
-	 *
-	 * 0 => allocation would fail due to lack of memory
-	 * 1 => allocation would fail due to fragmentation
-	 */
-	return 1000 - div_u64( (1000+(div_u64(info->free_pages * 1000ULL, requested))), info->free_blocks_total);
-}
-
 static void pagetypeinfo_showfree_print(struct seq_file *m,
 					pg_data_t *pgdat, struct zone *zone)
 {
@@ -1001,7 +1001,6 @@ module_init(setup_vmstat)
 
 #ifdef CONFIG_DEBUG_FS
 #include <linux/debugfs.h>
-#include <linux/seq_file.h>
 
 static struct dentry *extfrag_debug_root;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
