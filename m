Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 3A54B6B0062
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:42:34 -0500 (EST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 01:12:31 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JgS8761538444
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 01:12:28 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA71C8Au001555
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 12:12:09 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 07/10] mm: Modify vmstat
Date: Wed, 07 Nov 2012 01:11:24 +0530
Message-ID: <20121106194120.6560.73221.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
References: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Ankita Garg <gargankita@gmail.com>

Change the way vmstats are collected. Since the zones are now present inside
regions, scan through all the regions to obtain zone specific statistics.

Signed-off-by: Ankita Garg <gargankita@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/vmstat.h |   21 ++++++++++++++-------
 mm/vmstat.c            |   40 ++++++++++++++++++++++++----------------
 2 files changed, 38 insertions(+), 23 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 92a86b2..a782f05 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -151,20 +151,27 @@ extern unsigned long zone_reclaimable_pages(struct zone *zone);
 static inline unsigned long node_page_state(int node,
 				 enum zone_stat_item item)
 {
-	struct zone *zones = NODE_DATA(node)->node_zones;
+	unsigned long page_state = 0;
+	struct mem_region *region;
+
+	for_each_mem_region_in_node(region, node) {
+		struct zone *zones = region->region_zones;
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
index c737057..86a92a6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -188,20 +188,24 @@ void refresh_zone_stat_thresholds(void)
 void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 				int (*calculate_pressure)(struct zone *))
 {
+	struct mem_region *region;
 	struct zone *zone;
 	int cpu;
 	int threshold;
 	int i;
 
 	for (i = 0; i < pgdat->nr_zones; i++) {
-		zone = &pgdat->node_zones[i];
-		if (!zone->percpu_drift_mark)
-			continue;
+		for_each_mem_region_in_node(region, pgdat->node_id) {
+			struct zone *zone = region->region_zones + i;
 
-		threshold = (*calculate_pressure)(zone);
-		for_each_possible_cpu(cpu)
-			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
-							= threshold;
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
 
@@ -657,19 +661,23 @@ static void frag_stop(struct seq_file *m, void *arg)
 
 /* Walk all the zones in a node and print using a callback */
 static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
-		void (*print)(struct seq_file *m, pg_data_t *, struct zone *))
+			       void (*print)(struct seq_file *m, pg_data_t *,
+		               struct mem_region *, struct zone *))
 {
-	struct zone *zone;
-	struct zone *node_zones = pgdat->node_zones;
+	int i;
 	unsigned long flags;
+	struct mem_region *region;
 
-	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
-		if (!populated_zone(zone))
-			continue;
+	for (i = 0; i < MAX_NR_ZONES; ++i) {
+		for_each_mem_region_in_node(region, pgdat->node_id) {
+			struct zone *zone = region->region_zones + i;
+			if (!populated_zone(zone))
+				continue;
 
-		spin_lock_irqsave(&zone->lock, flags);
-		print(m, pgdat, zone);
-		spin_unlock_irqrestore(&zone->lock, flags);
+			spin_lock_irqsave(&zone->lock, flags);
+			print(m, pgdat, region, zone);
+			spin_unlock_irqrestore(&zone->lock, flags);
+		}
 	}
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
