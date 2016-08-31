Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9A66B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 15:51:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d196so24647376wmd.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 12:51:08 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id yb9si1656188wjc.58.2016.08.31.12.51.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 12:51:06 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 209331C26CC
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 20:51:06 +0100 (IST)
Date: Wed, 31 Aug 2016 20:51:04 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, vmscan: Only allocate and reclaim from zones with pages
 managed by the buddy allocator
Message-ID: <20160831195104.GB8119@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Firmware Assisted Dump (FA_DUMP) on ppc64 reserves substantial amounts
of memory when booting a secondary kernel. Srikar Dronamraju reported that
multiple nodes may have no memory managed by the buddy allocator but still
return true for populated_zone().

Commit 1d82de618ddd ("mm, vmscan: make kswapd reclaim in terms of nodes")
was reported to cause kswapd to spin at 100% CPU usage when fadump was
enabled. The old code happened to deal with the situation of a populated
node with zero free pages by co-incidence but the current code tries to
reclaim populated zones without realising that is impossible.

We cannot just convert populated_zone() as many existing users really
need to check for present_pages. This patch introduces a managed_zone()
helper and uses it in the few cases where it is critical that the check
is made for managed pages -- zonelist construction and page reclaim.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Reported-and-tested-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmzone.h | 16 ++++++++++++++--
 mm/page_alloc.c        |  4 ++--
 mm/vmscan.c            | 22 +++++++++++-----------
 3 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d572b78b65e1..7f2ae99e5daf 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -828,9 +828,21 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
  */
 #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
 
-static inline int populated_zone(struct zone *zone)
+/*
+ * Returns true if a zone has pages managed by the buddy allocator.
+ * All the reclaim decisions have to use this function rather than
+ * populated_zone(). If the whole zone is reserved then we can easily
+ * end up with populated_zone() && !managed_zone().
+ */
+static inline bool managed_zone(struct zone *zone)
+{
+	return zone->managed_pages;
+}
+
+/* Returns true if a zone has memory */
+static inline bool populated_zone(struct zone *zone)
 {
-	return (!!zone->present_pages);
+	return zone->present_pages;
 }
 
 extern int movable_zone;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3fbe73a6fe4b..9930fa748ae3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4407,7 +4407,7 @@ static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
 	do {
 		zone_type--;
 		zone = pgdat->node_zones + zone_type;
-		if (populated_zone(zone)) {
+		if (managed_zone(zone)) {
 			zoneref_set_zone(zone,
 				&zonelist->_zonerefs[nr_zones++]);
 			check_highest_zone(zone_type);
@@ -4645,7 +4645,7 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 		for (j = 0; j < nr_nodes; j++) {
 			node = node_order[j];
 			z = &NODE_DATA(node)->node_zones[zone_type];
-			if (populated_zone(z)) {
+			if (managed_zone(z)) {
 				zoneref_set_zone(z,
 					&zonelist->_zonerefs[pos++]);
 				check_highest_zone(zone_type);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 374d95d04178..b1e12a1ea9cf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1665,7 +1665,7 @@ static bool inactive_reclaimable_pages(struct lruvec *lruvec,
 
 	for (zid = sc->reclaim_idx; zid >= 0; zid--) {
 		zone = &pgdat->node_zones[zid];
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		if (zone_page_state_snapshot(zone, NR_ZONE_LRU_BASE +
@@ -2036,7 +2036,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 		struct zone *zone = &pgdat->node_zones[zid];
 		unsigned long inactive_zone, active_zone;
 
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		inactive_zone = zone_page_state(zone,
@@ -2171,7 +2171,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 
 		for (z = 0; z < MAX_NR_ZONES; z++) {
 			struct zone *zone = &pgdat->node_zones[z];
-			if (!populated_zone(zone))
+			if (!managed_zone(zone))
 				continue;
 
 			total_high_wmark += high_wmark_pages(zone);
@@ -2510,7 +2510,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	/* If compaction would go ahead or the allocation would succeed, stop */
 	for (z = 0; z <= sc->reclaim_idx; z++) {
 		struct zone *zone = &pgdat->node_zones[z];
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		switch (compaction_suitable(zone, sc->order, 0, sc->reclaim_idx)) {
@@ -2840,7 +2840,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 
 	for (i = 0; i <= ZONE_NORMAL; i++) {
 		zone = &pgdat->node_zones[i];
-		if (!populated_zone(zone) ||
+		if (!managed_zone(zone) ||
 		    pgdat_reclaimable_pages(pgdat) == 0)
 			continue;
 
@@ -3141,7 +3141,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 	for (i = 0; i <= classzone_idx; i++) {
 		struct zone *zone = pgdat->node_zones + i;
 
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		if (!zone_balanced(zone, order, classzone_idx))
@@ -3169,7 +3169,7 @@ static bool kswapd_shrink_node(pg_data_t *pgdat,
 	sc->nr_to_reclaim = 0;
 	for (z = 0; z <= sc->reclaim_idx; z++) {
 		zone = pgdat->node_zones + z;
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		sc->nr_to_reclaim += max(high_wmark_pages(zone), SWAP_CLUSTER_MAX);
@@ -3242,7 +3242,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		if (buffer_heads_over_limit) {
 			for (i = MAX_NR_ZONES - 1; i >= 0; i--) {
 				zone = pgdat->node_zones + i;
-				if (!populated_zone(zone))
+				if (!managed_zone(zone))
 					continue;
 
 				sc.reclaim_idx = i;
@@ -3262,7 +3262,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 */
 		for (i = classzone_idx; i >= 0; i--) {
 			zone = pgdat->node_zones + i;
-			if (!populated_zone(zone))
+			if (!managed_zone(zone))
 				continue;
 
 			if (zone_balanced(zone, sc.order, classzone_idx))
@@ -3508,7 +3508,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	pg_data_t *pgdat;
 	int z;
 
-	if (!populated_zone(zone))
+	if (!managed_zone(zone))
 		return;
 
 	if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
@@ -3522,7 +3522,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	/* Only wake kswapd if all zones are unbalanced */
 	for (z = 0; z <= classzone_idx; z++) {
 		zone = pgdat->node_zones + z;
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		if (zone_balanced(zone, order, classzone_idx))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
