Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D6E366B01F1
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 00:13:22 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F4DIMm030678
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 13:13:18 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F86545DE70
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:13:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AA6945DE6E
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:13:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 442731DB8037
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:13:18 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DBC151DB803F
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:13:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/4] vmscan: kill prev_priority completely
In-Reply-To: <20100415130212.D16E.A69D9226@jp.fujitsu.com>
References: <20100415013436.GO2493@dastard> <20100415130212.D16E.A69D9226@jp.fujitsu.com>
Message-Id: <20100415131139.D177.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 15 Apr 2010 13:13:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch is not related the patch series directly.
but [4/4] depend on scan_control has `priority' member.
then, I'm include this.

=============================================
Since 2.6.28 zone->prev_priority is unused. Then it can be removed
safely. It reduce stack usage slightly.

Now I have to say that I'm sorry. 2 years ago, I thghout prev_priority
can be integrate again, it's useful. but four (or more) times trying
haven't got good performance number. thus I give up such approach.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/mmzone.h |   15 -------------
 mm/page_alloc.c        |    2 -
 mm/vmscan.c            |   54 ++---------------------------------------------
 mm/vmstat.c            |    2 -
 4 files changed, 3 insertions(+), 70 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index cf9e458..ad76962 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -339,21 +339,6 @@ struct zone {
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
 
 	/*
-	 * prev_priority holds the scanning priority for this zone.  It is
-	 * defined as the scanning priority at which we achieved our reclaim
-	 * target at the previous try_to_free_pages() or balance_pgdat()
-	 * invocation.
-	 *
-	 * We use prev_priority as a measure of how much stress page reclaim is
-	 * under - it drives the swappiness decision: whether to unmap mapped
-	 * pages.
-	 *
-	 * Access to both this field is quite racy even on uniprocessor.  But
-	 * it is expected to average out OK.
-	 */
-	int prev_priority;
-
-	/*
 	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
 	 * this zone's LRU.  Maintained by the pageout code.
 	 */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d03c946..88513c0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3862,8 +3862,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
-		zone->prev_priority = DEF_PRIORITY;
-
 		zone_pcp_init(zone);
 		for_each_lru(l) {
 			INIT_LIST_HEAD(&zone->lru[l].list);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d392a50..dadb461 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1284,20 +1284,6 @@ done:
 }
 
 /*
- * We are about to scan this zone at a certain priority level.  If that priority
- * level is smaller (ie: more urgent) than the previous priority, then note
- * that priority level within the zone.  This is done so that when the next
- * process comes in to scan this zone, it will immediately start out at this
- * priority level rather than having to build up its own scanning priority.
- * Here, this priority affects only the reclaim-mapped threshold.
- */
-static inline void note_zone_scanning_priority(struct zone *zone, int priority)
-{
-	if (priority < zone->prev_priority)
-		zone->prev_priority = priority;
-}
-
-/*
  * This moves pages from the active list to the inactive list.
  *
  * We move them the other way if the page is referenced by one or more
@@ -1733,20 +1719,15 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 		if (scanning_global_lru(sc)) {
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
-			note_zone_scanning_priority(zone, priority);
-
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
 			sc->all_unreclaimable = 0;
-		} else {
+		} else
 			/*
 			 * Ignore cpuset limitation here. We just want to reduce
 			 * # of used pages by us regardless of memory shortage.
 			 */
 			sc->all_unreclaimable = 0;
-			mem_cgroup_note_reclaim_priority(sc->mem_cgroup,
-							priority);
-		}
 
 		shrink_zone(priority, zone, sc);
 	}
@@ -1852,17 +1833,11 @@ out:
 	if (priority < 0)
 		priority = 0;
 
-	if (scanning_global_lru(sc)) {
-		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
-
+	if (scanning_global_lru(sc))
+		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
 
-			zone->prev_priority = priority;
-		}
-	} else
-		mem_cgroup_record_reclaim_priority(sc->mem_cgroup, priority);
-
 	delayacct_freepages_end();
 
 	return ret;
@@ -2015,22 +1990,12 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 		.mem_cgroup = NULL,
 		.isolate_pages = isolate_pages_global,
 	};
-	/*
-	 * temp_priority is used to remember the scanning priority at which
-	 * this zone was successfully refilled to
-	 * free_pages == high_wmark_pages(zone).
-	 */
-	int temp_priority[MAX_NR_ZONES];
-
 loop_again:
 	total_scanned = 0;
 	sc.nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
 
-	for (i = 0; i < pgdat->nr_zones; i++)
-		temp_priority[i] = DEF_PRIORITY;
-
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 		unsigned long lru_pages = 0;
@@ -2098,9 +2063,7 @@ loop_again:
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;
 
-			temp_priority[i] = priority;
 			sc.nr_scanned = 0;
-			note_zone_scanning_priority(zone, priority);
 
 			nid = pgdat->node_id;
 			zid = zone_idx(zone);
@@ -2173,16 +2136,6 @@ loop_again:
 			break;
 	}
 out:
-	/*
-	 * Note within each zone the priority level at which this zone was
-	 * brought into a happy state.  So that the next thread which scans this
-	 * zone will start out at that priority level.
-	 */
-	for (i = 0; i < pgdat->nr_zones; i++) {
-		struct zone *zone = pgdat->node_zones + i;
-
-		zone->prev_priority = temp_priority[i];
-	}
 	if (!all_zones_ok) {
 		cond_resched();
 
@@ -2600,7 +2553,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 */
 		priority = ZONE_RECLAIM_PRIORITY;
 		do {
-			note_zone_scanning_priority(zone, priority);
 			shrink_zone(priority, zone, &sc);
 			priority--;
 		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index fa12ea3..2db0a0f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -761,11 +761,9 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 	}
 	seq_printf(m,
 		   "\n  all_unreclaimable: %u"
-		   "\n  prev_priority:     %i"
 		   "\n  start_pfn:         %lu"
 		   "\n  inactive_ratio:    %u",
 		   zone->all_unreclaimable,
-		   zone->prev_priority,
 		   zone->zone_start_pfn,
 		   zone->inactive_ratio);
 	seq_putc(m, '\n');
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
