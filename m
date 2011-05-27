Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 28F4E6B0023
	for <linux-mm@kvack.org>; Fri, 27 May 2011 08:32:06 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4RCW0au018271
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:02:00 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RCVrWD3879162
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:02:00 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RCVqJM003665
	for <linux-mm@kvack.org>; Fri, 27 May 2011 22:31:53 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 07/10] mm: Modify vmstat
Date: Fri, 27 May 2011 18:01:35 +0530
Message-Id: <1306499498-14263-8-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

Change the way vmstats are collected. Since the zones are now present inside
regions, scan through all the regions to obtain zone specific statistics.

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 include/linux/vmstat.h |   22 +++++++++++++++-------
 mm/vmstat.c            |   48 ++++++++++++++++++++++++++++--------------------
 2 files changed, 43 insertions(+), 27 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 2b3831b..296b9ad 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -211,20 +211,28 @@ extern unsigned long zone_reclaimable_pages(struct zone *zone);
 static inline unsigned long node_page_state(int node,
 				 enum zone_stat_item item)
 {
-	struct zone *zones = NODE_DATA(node)->node_zones;
+	int i;
+	unsigned long page_state = 0;
+
+	for_each_mem_region_in_nid(i, node) {
+		mr_data_t *mrdat = &(NODE_DATA(node)->mem_regions[i]);
+		struct zone *zones = mrdat->zones;
+		
+		page_state = 
 
-	return
 #ifdef CONFIG_ZONE_DMA
-		zone_page_state(&zones[ZONE_DMA], item) +
+			zone_page_state(&zones[ZONE_DMA], item) +
 #endif
 #ifdef CONFIG_ZONE_DMA32
-		zone_page_state(&zones[ZONE_DMA32], item) +
+			zone_page_state(&zones[ZONE_DMA32], item) +
 #endif
 #ifdef CONFIG_HIGHMEM
-		zone_page_state(&zones[ZONE_HIGHMEM], item) +
+			zone_page_state(&zones[ZONE_HIGHMEM], item) +
 #endif
-		zone_page_state(&zones[ZONE_NORMAL], item) +
-		zone_page_state(&zones[ZONE_MOVABLE], item);
+			zone_page_state(&zones[ZONE_NORMAL], item) +
+			zone_page_state(&zones[ZONE_MOVABLE], item);
+	}
+	return page_state;
 }
 
 extern void zone_statistics(struct zone *, struct zone *, gfp_t gfp);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 897ea9e..542f8b6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -191,17 +191,21 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 	struct zone *zone;
 	int cpu;
 	int threshold;
-	int i;
+	int i, p;
 
 	for (i = 0; i < pgdat->nr_zones; i++) {
-		zone = &pgdat->node_zones[i];
-		if (!zone->percpu_drift_mark)
-			continue;
-
-		threshold = (*calculate_pressure)(zone);
-		for_each_possible_cpu(cpu)
-			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
-							= threshold;
+		for_each_mem_region_in_nid(p, pgdat->node_id) {
+			mem_region_t *mem_region = &pgdat->mem_regions[p];
+			struct zone *zone = mem_region->zones + i;
+		
+			if (!zone->percpu_drift_mark)
+				continue;
+
+			threshold = (*calculate_pressure)(zone);
+			for_each_possible_cpu(cpu)
+				per_cpu_ptr(zone->pageset, cpu)->stat_threshold
+								= threshold;
+		}
 	}
 }
 
@@ -642,19 +646,23 @@ static void frag_stop(struct seq_file *m, void *arg)
 
 /* Walk all the zones in a node and print using a callback */
 static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
-		void (*print)(struct seq_file *m, pg_data_t *, struct zone *))
+		void (*print)(struct seq_file *m, pg_data_t *,
+					mem_region_t *, struct zone *))
 {
-	struct zone *zone;
-	struct zone *node_zones = pgdat->node_zones;
 	unsigned long flags;
-
-	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
-		if (!populated_zone(zone))
-			continue;
-
-		spin_lock_irqsave(&zone->lock, flags);
-		print(m, pgdat, zone);
-		spin_unlock_irqrestore(&zone->lock, flags);
+	int i, j;
+
+	for (i = 0; i < MAX_NR_ZONES; ++i) {
+		for_each_mem_region_in_nid(j, pgdat->node_id) {
+			mem_region_t *mem_region = &pgdat->mem_regions[j];
+			struct zone *zone = mem_region->zones + i;
+			if (!populated_zone(zone))
+				continue;
+
+			spin_lock_irqsave(&zone->lock, flags);
+			print(m, pgdat, mem_region, zone);
+			spin_unlock_irqrestore(&zone->lock, flags);
+		}
 	}
 }
 #endif
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
