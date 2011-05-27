Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 79BD76B0011
	for <linux-mm@kvack.org>; Fri, 27 May 2011 08:32:04 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4RCVxmE013826
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:01:59 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RCVtlN4362322
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:01:59 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RCVr96003703
	for <linux-mm@kvack.org>; Fri, 27 May 2011 22:31:53 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 09/10] mm: Reflect memory region changes in zoneinfo
Date: Fri, 27 May 2011 18:01:37 +0530
Message-Id: <1306499498-14263-10-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

This patch modifies the output of /proc/zoneinfo to take the memory regions
into into account. Below is the output on the Samsung board booted with 4
regions, each of size 512MB.

# cat /proc/zoneinfo
Node 0, Region 0, zone   Normal
  pages free     124570
        min      388
        low      485
        high     582
        scanned  0
        spanned  131072
        present  130048
    nr_free_pages 124570
    nr_inactive_anon 0
    nr_active_anon 92
    nr_inactive_file 454
    nr_active_file 190
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 95
    nr_mapped    290
    nr_file_pages 647
    nr_dirty     1
    nr_writeback 0
    nr_slab_reclaimable 33
    nr_slab_unreclaimable 428
    nr_page_table_pages 4
    nr_kernel_stack 20
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     0
    nr_dirtied   12
    nr_written   11
    nr_anon_transparent_hugepages 0
        protection: (0, 0)
  pagesets
    cpu: 0
              count: 48
              high:  186
              batch: 31
  vm stats threshold: 6
  all_unreclaimable: 0
  start_pfn:         262144
  inactive_ratio:    1
Node 0, Region 1, zone   Normal
  pages free     131072
        min      388
        low      485
        high     582
        scanned  0
        spanned  131072
        present  130048
    nr_free_pages 131072
.....
Node 0, Region 2, zone   Normal
  pages free     131072
        min      388
        low      485
        high     582
        scanned  0
        spanned  131072
        present  130048
    nr_free_pages 131072
.....
Node 0, Region 3, zone   Normal
  pages free     57332
        min      170
        low      212
        high     255
        scanned  0
        spanned  57344
        present  56896
    nr_free_pages 57332
.....

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 mm/vmstat.c |   29 +++++++++++++++++------------
 1 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 542f8b6..153e25b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -179,16 +179,18 @@ static void refresh_zone_stat_thresholds(void)
 		 */
 		tolerate_drift = low_wmark_pages(zone) - min_wmark_pages(zone);
 		max_drift = num_online_cpus() * threshold;
-		if (max_drift > tolerate_drift)
+		if (max_drift > tolerate_drift) {
 			zone->percpu_drift_mark = high_wmark_pages(zone) +
 					max_drift;
+			printk("zone %s drift mark %lu \n", zone->name, 
+						zone->percpu_drift_mark);
+		}
 	}
 }
 
 void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 				int (*calculate_pressure)(struct zone *))
 {
-	struct zone *zone;
 	int cpu;
 	int threshold;
 	int i, p;
@@ -669,11 +671,12 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 
 #ifdef CONFIG_PROC_FS
 static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
-						struct zone *zone)
+					mem_region_t *mem_region, struct zone *zone)
 {
 	int order;
 
-	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	seq_printf(m, "Node %d, REG %d, zone %8s ", pgdat->node_id,
+						mem_region->region, zone->name);
 	for (order = 0; order < MAX_ORDER; ++order)
 		seq_printf(m, "%6lu ", zone->free_area[order].nr_free);
 	seq_putc(m, '\n');
@@ -689,14 +692,15 @@ static int frag_show(struct seq_file *m, void *arg)
 	return 0;
 }
 
-static void pagetypeinfo_showfree_print(struct seq_file *m,
-					pg_data_t *pgdat, struct zone *zone)
+static void pagetypeinfo_showfree_print(struct seq_file *m, pg_data_t *pgdat,
+						mem_region_t *mem_region, struct zone *zone)
 {
 	int order, mtype;
 
 	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++) {
-		seq_printf(m, "Node %4d, zone %8s, type %12s ",
+		seq_printf(m, "Node %4d, Region %d, zone %8s, type %12s ",
 					pgdat->node_id,
+					mem_region->region,
 					zone->name,
 					migratetype_names[mtype]);
 		for (order = 0; order < MAX_ORDER; ++order) {
@@ -731,8 +735,8 @@ static int pagetypeinfo_showfree(struct seq_file *m, void *arg)
 	return 0;
 }
 
-static void pagetypeinfo_showblockcount_print(struct seq_file *m,
-					pg_data_t *pgdat, struct zone *zone)
+static void pagetypeinfo_showblockcount_print(struct seq_file *m, pg_data_t *pgdat,
+							mem_region_t *mem_region, struct zone *zone)
 {
 	int mtype;
 	unsigned long pfn;
@@ -759,7 +763,7 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
 	}
 
 	/* Print counts */
-	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	seq_printf(m, "Node %d, Region %d, zone %8s ", pgdat->node_id, mem_region->region, zone->name);
 	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
 		seq_printf(m, "%12lu ", count[mtype]);
 	seq_putc(m, '\n');
@@ -969,10 +973,11 @@ static const char * const vmstat_text[] = {
 };
 
 static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
-							struct zone *zone)
+					mem_region_t *mem_region, struct zone *zone)
 {
 	int i;
-	seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
+	seq_printf(m, "Node %d, Region %d, zone %8s", pgdat->node_id,
+						mem_region->region, zone->name);
 	seq_printf(m,
 		   "\n  pages free     %lu"
 		   "\n        min      %lu"
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
