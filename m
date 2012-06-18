Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 4E95A6B006C
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 12:47:33 -0400 (EDT)
Received: by ggmi2 with SMTP id i2so450285ggm.2
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 09:47:32 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V5 4/5] mm, vmscan: fix do_try_to_free_pages() livelock
Date: Mon, 18 Jun 2012 09:47:30 -0700
Message-Id: <1340038051-29502-4-git-send-email-yinghan@google.com>
In-Reply-To: <1340038051-29502-1-git-send-email-yinghan@google.com>
References: <1340038051-29502-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Currently, do_try_to_free_pages() can enter livelock. Because of,
now vmscan has two conflicted policies.

1) kswapd sleep when it couldn't reclaim any page even though
   reach priority 0. This is because to avoid kswapd() infinite
   loop. That said, kswapd assume direct reclaim makes enough
   free pages either regular page reclaim or oom-killer.
   This logic makes kswapd -> direct-reclaim dependency.
2) direct reclaim continue to reclaim without oom-killer until
   kswapd turn on zone->all_unreclaimble. This is because
   to avoid too early oom-kill.
   This logic makes direct-reclaim -> kswapd dependency.

In worst case, direct-reclaim may continue to page reclaim forever
when kswapd is slept and any other thread don't wakeup kswapd.

We can't turn on zone->all_unreclaimable because this is racy.
direct reclaim path don't take any lock. Thus this patch removes
zone->all_unreclaimable field completely and recalculates every
time.

Note: we can't take the idea that direct-reclaim see zone->pages_scanned
directly and kswapd continue to use zone->all_unreclaimable. Because,
it is racy. commit 929bea7c71 (vmscan: all_unreclaimable() use
zone->all_unreclaimable as a name) describes the detail.

Reported-by: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Reported-by: Ying Han <yinghan@google.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mm_inline.h |   19 ++++++++++++++++
 include/linux/mmzone.h    |    2 +-
 include/linux/vmstat.h    |    1 -
 mm/page-writeback.c       |    2 +
 mm/page_alloc.c           |    5 +--
 mm/vmscan.c               |   51 +++++++++++++-------------------------------
 mm/vmstat.c               |    3 +-
 7 files changed, 41 insertions(+), 42 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 1397ccf..5cb796c 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -2,6 +2,7 @@
 #define LINUX_MM_INLINE_H
 
 #include <linux/huge_mm.h>
+#include <linux/swap.h>
 
 /**
  * page_is_file_cache - should the page be on a file LRU or anon LRU?
@@ -99,4 +100,22 @@ static __always_inline enum lru_list page_lru(struct page *page)
 	return lru;
 }
 
+static inline unsigned long zone_reclaimable_pages(struct zone *zone)
+{
+	int nr;
+
+	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
+	     zone_page_state(zone, NR_INACTIVE_FILE);
+
+	if (nr_swap_pages > 0)
+		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
+		      zone_page_state(zone, NR_INACTIVE_ANON);
+
+		return nr;
+}
+
+static inline bool zone_reclaimable(struct zone *zone)
+{
+	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
+}
 #endif
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0ee785d..b380ec3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -343,7 +343,7 @@ struct zone {
 	 * free areas of different sizes
 	 */
 	spinlock_t		lock;
-	int                     all_unreclaimable; /* All pages pinned */
+
 #ifdef CONFIG_MEMORY_HOTPLUG
 	/* see spanned/present_pages for more description */
 	seqlock_t		span_seqlock;
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 65efb92..9607256 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -140,7 +140,6 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
 }
 
 extern unsigned long global_reclaimable_pages(void);
-extern unsigned long zone_reclaimable_pages(struct zone *zone);
 
 #ifdef CONFIG_NUMA
 /*
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 26adea8..e869f8a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -34,6 +34,8 @@
 #include <linux/syscalls.h>
 #include <linux/buffer_head.h> /* __set_page_dirty_buffers */
 #include <linux/pagevec.h>
+#include <linux/mm_inline.h>
+
 #include <trace/events/writeback.h>
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 164a6d2..aec24de 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -58,6 +58,7 @@
 #include <linux/memcontrol.h>
 #include <linux/prefetch.h>
 #include <linux/page-debug-flags.h>
+#include <linux/mm_inline.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -637,7 +638,6 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	int to_free = count;
 
 	spin_lock(&zone->lock);
-	zone->all_unreclaimable = 0;
 	zone->pages_scanned = 0;
 
 	while (to_free) {
@@ -679,7 +679,6 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
 				int migratetype)
 {
 	spin_lock(&zone->lock);
-	zone->all_unreclaimable = 0;
 	zone->pages_scanned = 0;
 
 	__free_one_page(page, zone, order, migratetype);
@@ -2814,7 +2813,7 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_BOUNCE)),
 			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			zone->pages_scanned,
-			(zone->all_unreclaimable ? "yes" : "no")
+			(zone_reclaimable(zone) ? "yes" : "no")
 			);
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 51f8cc9..b95344c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1592,7 +1592,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	 * latencies, so it's better to scan a minimum amount there as
 	 * well.
 	 */
-	if (current_is_kswapd() && zone->all_unreclaimable)
+	if (current_is_kswapd() && !zone_reclaimable(zone))
 		force_scan = true;
 	if (!global_reclaim(sc))
 		force_scan = true;
@@ -1962,8 +1962,8 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		if (global_reclaim(sc)) {
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
-			if (zone->all_unreclaimable &&
-					sc->priority != DEF_PRIORITY)
+			if (!zone_reclaimable(zone) &&
+			    sc->priority != DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
 			if (COMPACTION_BUILD) {
 				/*
@@ -1989,11 +1989,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	return aborted_reclaim;
 }
 
-static bool zone_reclaimable(struct zone *zone)
-{
-	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
-}
-
 /* All zones in zonelist are unreclaimable? */
 static bool all_unreclaimable(struct zonelist *zonelist,
 		struct scan_control *sc)
@@ -2007,7 +2002,7 @@ static bool all_unreclaimable(struct zonelist *zonelist,
 			continue;
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 			continue;
-		if (!zone->all_unreclaimable)
+		if (zone_reclaimable(zone))
 			return false;
 	}
 
@@ -2274,7 +2269,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 		 * they must be considered balanced here as well if kswapd
 		 * is to sleep
 		 */
-		if (zone->all_unreclaimable) {
+		if (zone_reclaimable(zone)) {
 			balanced += zone->present_pages;
 			continue;
 		}
@@ -2366,8 +2361,8 @@ loop_again:
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone->all_unreclaimable &&
-			    sc.priority != DEF_PRIORITY)
+			if (!zone_reclaimable(zone) &&
+					sc.priority != DEF_PRIORITY)
 				continue;
 
 			/*
@@ -2416,14 +2411,14 @@ loop_again:
 		 */
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
-			int nr_slab, testorder;
+			int testorder;
 			unsigned long balance_gap;
 
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone->all_unreclaimable &&
-			    sc.priority != DEF_PRIORITY)
+			if (!zone_reclaimable(zone) &&
+					sc.priority != DEF_PRIORITY)
 				continue;
 
 			sc.nr_scanned = 0;
@@ -2460,12 +2455,10 @@ loop_again:
 				shrink_zone(zone, &sc);
 
 				reclaim_state->reclaimed_slab = 0;
-				nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
+				shrink_slab(&shrink, sc.nr_scanned, lru_pages);
 				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 				total_scanned += sc.nr_scanned;
 
-				if (nr_slab == 0 && !zone_reclaimable(zone))
-					zone->all_unreclaimable = 1;
 			}
 
 			/*
@@ -2477,7 +2470,7 @@ loop_again:
 			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
 				sc.may_writepage = 1;
 
-			if (zone->all_unreclaimable) {
+			if (!zone_reclaimable(zone)) {
 				if (end_zone && end_zone == i)
 					end_zone--;
 				continue;
@@ -2579,8 +2572,8 @@ out:
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone->all_unreclaimable &&
-			    sc.priority != DEF_PRIORITY)
+			if (!zone_reclaimable(zone) &&
+					sc.priority != DEF_PRIORITY)
 				continue;
 
 			/* Would compaction fail due to lack of free memory? */
@@ -2813,20 +2806,6 @@ unsigned long global_reclaimable_pages(void)
 	return nr;
 }
 
-unsigned long zone_reclaimable_pages(struct zone *zone)
-{
-	int nr;
-
-	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
-	     zone_page_state(zone, NR_INACTIVE_FILE);
-
-	if (nr_swap_pages > 0)
-		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
-		      zone_page_state(zone, NR_INACTIVE_ANON);
-
-	return nr;
-}
-
 #ifdef CONFIG_HIBERNATION
 /*
  * Try to free `nr_to_reclaim' of memory, system-wide, and return the number of
@@ -3121,7 +3100,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	    zone_page_state(zone, NR_SLAB_RECLAIMABLE) <= zone->min_slab_pages)
 		return ZONE_RECLAIM_FULL;
 
-	if (zone->all_unreclaimable)
+	if (!zone_reclaimable(zone))
 		return ZONE_RECLAIM_FULL;
 
 	/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7db1b9b..f6800a1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -19,6 +19,7 @@
 #include <linux/math64.h>
 #include <linux/writeback.h>
 #include <linux/compaction.h>
+#include <linux/mm_inline.h>
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
@@ -1019,7 +1020,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n  all_unreclaimable: %u"
 		   "\n  start_pfn:         %lu"
 		   "\n  inactive_ratio:    %u",
-		   zone->all_unreclaimable,
+		   !zone_reclaimable(zone),
 		   zone->zone_start_pfn,
 		   zone->inactive_ratio);
 	seq_putc(m, '\n');
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
