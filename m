Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3214D6B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 04:49:47 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so31002283lfg.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 01:49:47 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id k5si22608677wmc.122.2016.08.31.01.49.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 01:49:45 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 01F741DC02F
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:49:45 +0000 (UTC)
Date: Wed, 31 Aug 2016 09:49:42 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 07/34] mm, vmscan: make kswapd reclaim in terms of nodes
Message-ID: <20160831084942.GX8119@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-8-git-send-email-mgorman@techsingularity.net>
 <20160829093844.GA2592@linux.vnet.ibm.com>
 <20160830120728.GV8119@techsingularity.net>
 <20160830142508.GA10514@linux.vnet.ibm.com>
 <20160830150051.GW8119@techsingularity.net>
 <20160831060959.GA6787@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160831060959.GA6787@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>

On Wed, Aug 31, 2016 at 11:39:59AM +0530, Srikar Dronamraju wrote:
> This indeed fixes the problem.
> Please add my 
> Tested-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> 

Ok, thanks. Unfortunately we cannot do a wide conversion like this
because some users of populated_zone() really meant to check for
present_pages. In all cases, the expectation was that reserved pages
would be tiny but fadump messes that up. Can you verify this also works
please?

---8<---
mm, vmscan: Only allocate and reclaim from zones with pages managed by the buddy allocator

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
is made for managed pages -- zonelist constuction and page reclaim.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h | 11 +++++++++--
 mm/page_alloc.c        |  4 ++--
 mm/vmscan.c            | 22 +++++++++++-----------
 3 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d572b78b65e1..69f886b79656 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -828,9 +828,16 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
  */
 #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
 
-static inline int populated_zone(struct zone *zone)
+/* Returns true if a zone has pages managed by the buddy allocator */
+static inline bool managed_zone(struct zone *zone)
 {
-	return (!!zone->present_pages);
+	return zone->managed_pages;
+}
+
+/* Returns true if a zone has memory */
+static inline bool populated_zone(struct zone *zone)
+{
+	return zone->present_pages;
 }
 
 extern int movable_zone;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1c09d9f7f692..ea7558149ee5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4405,7 +4405,7 @@ static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
 	do {
 		zone_type--;
 		zone = pgdat->node_zones + zone_type;
-		if (populated_zone(zone)) {
+		if (managed_zone(zone)) {
 			zoneref_set_zone(zone,
 				&zonelist->_zonerefs[nr_zones++]);
 			check_highest_zone(zone_type);
@@ -4643,7 +4643,7 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 		for (j = 0; j < nr_nodes; j++) {
 			node = node_order[j];
 			z = &NODE_DATA(node)->node_zones[zone_type];
-			if (populated_zone(z)) {
+			if (managed_zone(z)) {
 				zoneref_set_zone(z,
 					&zonelist->_zonerefs[pos++]);
 				check_highest_zone(zone_type);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 98774f45b04a..55943a284082 100644
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
@@ -2508,7 +2508,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	/* If compaction would go ahead or the allocation would succeed, stop */
 	for (z = 0; z <= sc->reclaim_idx; z++) {
 		struct zone *zone = &pgdat->node_zones[z];
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		switch (compaction_suitable(zone, sc->order, 0, sc->reclaim_idx)) {
@@ -2835,7 +2835,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 
 	for (i = 0; i <= ZONE_NORMAL; i++) {
 		zone = &pgdat->node_zones[i];
-		if (!populated_zone(zone) ||
+		if (!managed_zone(zone) ||
 		    pgdat_reclaimable_pages(pgdat) == 0)
 			continue;
 
@@ -3136,7 +3136,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 	for (i = 0; i <= classzone_idx; i++) {
 		struct zone *zone = pgdat->node_zones + i;
 
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		if (!zone_balanced(zone, order, classzone_idx))
@@ -3164,7 +3164,7 @@ static bool kswapd_shrink_node(pg_data_t *pgdat,
 	sc->nr_to_reclaim = 0;
 	for (z = 0; z <= sc->reclaim_idx; z++) {
 		zone = pgdat->node_zones + z;
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		sc->nr_to_reclaim += max(high_wmark_pages(zone), SWAP_CLUSTER_MAX);
@@ -3237,7 +3237,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		if (buffer_heads_over_limit) {
 			for (i = MAX_NR_ZONES - 1; i >= 0; i--) {
 				zone = pgdat->node_zones + i;
-				if (!populated_zone(zone))
+				if (!managed_zone(zone))
 					continue;
 
 				sc.reclaim_idx = i;
@@ -3257,7 +3257,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 */
 		for (i = classzone_idx; i >= 0; i--) {
 			zone = pgdat->node_zones + i;
-			if (!populated_zone(zone))
+			if (!managed_zone(zone))
 				continue;
 
 			if (zone_balanced(zone, sc.order, classzone_idx))
@@ -3503,7 +3503,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	pg_data_t *pgdat;
 	int z;
 
-	if (!populated_zone(zone))
+	if (!managed_zone(zone))
 		return;
 
 	if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
@@ -3517,7 +3517,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	/* Only wake kswapd if all zones are unbalanced */
 	for (z = 0; z <= classzone_idx; z++) {
 		zone = pgdat->node_zones + z;
-		if (!populated_zone(zone))
+		if (!managed_zone(zone))
 			continue;
 
 		if (zone_balanced(zone, order, classzone_idx))

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
