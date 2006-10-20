Message-Id: <200610201953.k9KJreja032327@shell0.pdx.osdl.net>
Subject: [patch 2/4] vmscan: temp_priority comments
From: akpm@osdl.org
Date: Fri, 20 Oct 2006 12:53:40 -0700
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@osdl.org>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, clameter@engr.sgi.com, mbligh@mbligh.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Attempt to clarify what's going on in there.

note: __zone_reclaim() appears to be borked: it won't reclaim mapped pages for
the first few scanning passes.

Cc: Martin Bligh <mbligh@mbligh.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@engr.sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 mm/vmscan.c |   32 ++++++++++++++++++++++++++++----
 1 files changed, 28 insertions(+), 4 deletions(-)

diff -puN mm/vmscan.c~vmscan-fix-temp_priority-race-comments mm/vmscan.c
--- a/mm/vmscan.c~vmscan-fix-temp_priority-race-comments
+++ a/mm/vmscan.c
@@ -723,6 +723,20 @@ done:
 	return nr_reclaimed;
 }
 
+/*
+ * We are about to scan this zone at a certain priority level.  If that priority
+ * level is smaller (ie: more urgent) than the previous priority, then note
+ * that priority level within the zone.  This is done so that when the next
+ * process comes in to scan this zone, it will immediately start out at this
+ * priority level rather than having to build up its own scanning priority.
+ * Here, this priority affects only the reclaim-mapped threshold.
+ */
+static inline void note_zone_scanning_priority(struct zone *zone, int priority)
+{
+	if (priority < zone->prev_priority)
+		zone->prev_priority = priority;
+}
+
 static inline int zone_is_near_oom(struct zone *zone)
 {
 	return zone->pages_scanned >= (zone->nr_active + zone->nr_inactive)*3;
@@ -972,8 +986,7 @@ static unsigned long shrink_zones(int pr
 		if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))
 			continue;
 
-		if (zone->prev_priority > priority)
-			zone->prev_priority = priority;
+		note_zone_scanning_priority(zone, priority);
 
 		if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 			continue;	/* Let kswapd poll it */
@@ -1063,6 +1076,13 @@ unsigned long try_to_free_pages(struct z
 	if (!sc.all_unreclaimable)
 		ret = 1;
 out:
+	/*
+	 * Now that we've scanned all the zones at this priority level, note
+	 * that level within the zone so that the next thread which performs
+	 * scanning of this zone will immediately start out at this priority
+	 * level.  This affects only the decision whether or not to bring
+	 * mapped pages onto the inactive list.
+	 */
 	if (priority < 0)
 		priority = 0;
 	for (i = 0; zones[i] != 0; i++) {
@@ -1186,9 +1206,8 @@ scan:
 					       end_zone, 0))
 				all_zones_ok = 0;
 			temp_priority[i] = priority;
-			if (zone->prev_priority > priority)
-				zone->prev_priority = priority;
 			sc.nr_scanned = 0;
+			note_zone_scanning_priority(zone, priority);
 			nr_reclaimed += shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
@@ -1228,6 +1247,11 @@ scan:
 			break;
 	}
 out:
+	/*
+	 * Note within each zone the priority level at which this zone was
+	 * brought into a happy state.  So that the next thread which scans this
+	 * zone will start out at that priority level.
+	 */
 	for (i = 0; i < pgdat->nr_zones; i++) {
 		struct zone *zone = pgdat->node_zones + i;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
