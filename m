From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Message-Id: <20060131023015.7915.73256.sendpatchset@debian>
In-Reply-To: <20060131023000.7915.71955.sendpatchset@debian>
References: <20060131023000.7915.71955.sendpatchset@debian>
Subject: [PATCH 3/8] Add for_each_zone_in_node macro
Date: Tue, 31 Jan 2006 11:30:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: linux-mm@kvack.org, KUROSAWA Takahiro <kurosawa@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds for_each_zone_in_node macro.  This macro iterates the
block for each zone in the specific node.

Signed-off-by: KUROSAWA Takahiro <kurosawa@valinux.co.jp>

---
 include/linux/mmzone.h |   15 +++++++++++++++
 mm/page_alloc.c        |    6 ++----
 mm/vmscan.c            |   20 ++++++--------------
 3 files changed, 23 insertions(+), 18 deletions(-)

diff -urNp a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h	2006-01-27 12:58:53.000000000 +0900
+++ b/include/linux/mmzone.h	2006-01-27 12:59:45.000000000 +0900
@@ -375,6 +375,18 @@ static inline struct zone *next_zone(str
 	return zone;
 }
 
+static inline struct zone *next_zone_in_node(struct zone *zone, int len)
+{
+	pg_data_t *pgdat = zone->zone_pgdat;
+
+	if (zone < pgdat->node_zones + len - 1)
+		zone++;
+	else
+		zone = NULL;
+
+	return zone;
+}
+
 /**
  * for_each_zone - helper macro to iterate over all memory zones
  * @zone - pointer to struct zone variable
@@ -393,6 +405,9 @@ static inline struct zone *next_zone(str
 #define for_each_zone(zone) \
 	for (zone = pgdat_list->node_zones; zone; zone = next_zone(zone))
 
+#define for_each_zone_in_node(zone, pgdat, len) \
+	for (zone = pgdat->node_zones; zone; zone = next_zone_in_node(zone, len))
+
 static inline int is_highmem_idx(int idx)
 {
 	return (idx == ZONE_HIGHMEM);
diff -urNp a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	2006-01-27 12:58:53.000000000 +0900
+++ b/mm/page_alloc.c	2006-01-27 12:59:45.000000000 +0900
@@ -2124,12 +2124,11 @@ static int frag_show(struct seq_file *m,
 {
 	pg_data_t *pgdat = (pg_data_t *)arg;
 	struct zone *zone;
-	struct zone *node_zones = pgdat->node_zones;
 	unsigned long flags;
 	int order;
 
 	read_lock_nr_zones();
-	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
+	for_each_zone_in_node(zone, pgdat, MAX_NR_ZONES) {
 		if (!zone->present_pages)
 			continue;
 
@@ -2158,11 +2157,10 @@ static int zoneinfo_show(struct seq_file
 {
 	pg_data_t *pgdat = arg;
 	struct zone *zone;
-	struct zone *node_zones = pgdat->node_zones;
 	unsigned long flags;
 
 	read_lock_nr_zones();
-	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; zone++) {
+	for_each_zone_in_node(zone, pgdat, MAX_NR_ZONES) {
 		int i;
 
 		if (!zone->present_pages)
diff -urNp a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	2006-01-27 12:58:53.000000000 +0900
+++ b/mm/vmscan.c	2006-01-27 12:59:45.000000000 +0900
@@ -1047,6 +1047,7 @@ static int balance_pgdat(pg_data_t *pgda
 	int priority;
 	int i;
 	int total_scanned, total_reclaimed;
+	struct zone *zone;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc;
 
@@ -1060,11 +1061,8 @@ loop_again:
 
 	inc_page_state(pageoutrun);
 
-	for (i = 0; i < pgdat->nr_zones; i++) {
-		struct zone *zone = pgdat->node_zones + i;
-
+	for_each_zone_in_node(zone, pgdat, pgdat->nr_zones)
 		zone->temp_priority = DEF_PRIORITY;
-	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
@@ -1102,11 +1100,8 @@ loop_again:
 			end_zone = pgdat->nr_zones - 1;
 		}
 scan:
-		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
-
+		for_each_zone_in_node(zone, pgdat, end_zone)
 			lru_pages += zone->nr_active + zone->nr_inactive;
-		}
 
 		/*
 		 * Now scan the zone in the dma->highmem direction, stopping
@@ -1117,8 +1112,7 @@ scan:
 		 * pages behind kswapd's direction of progress, which would
 		 * cause too much scanning of the lower zones.
 		 */
-		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
+		for_each_zone_in_node(zone, pgdat, end_zone) {
 			int nr_slab;
 
 			if (zone->present_pages == 0)
@@ -1183,11 +1177,9 @@ scan:
 			break;
 	}
 out:
-	for (i = 0; i < pgdat->nr_zones; i++) {
-		struct zone *zone = pgdat->node_zones + i;
-
+	for_each_zone_in_node(zone, pgdat, pgdat->nr_zones)
 		zone->prev_priority = zone->temp_priority;
-	}
+
 	if (!all_zones_ok) {
 		cond_resched();
 		goto loop_again;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
