Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA466007C1
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 07:43:43 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 06/14] vmscan: kill prev_priority completely
Date: Tue, 29 Jun 2010 12:34:40 +0100
Message-Id: <1277811288-5195-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Since 2.6.28 zone->prev_priority is unused. Then it can be removed
safely. It reduce stack usage slightly.

Now I have to say that I'm sorry. 2 years ago, I thought prev_priority
can be integrate again, it's useful. but four (or more) times trying
haven't got good performance number. Thus I give up such approach.

The rest of this changelog is notes on prev_priority and why it existed in
the first place and why it might be not necessary any more. This information
is based heavily on discussions between Andrew Morton, Rik van Riel and
Kosaki Motohiro who is heavily quotes from.

Historically prev_priority was important because it determined when the VM
would start unmapping PTE pages. i.e. there are no balances of note within
the VM, Anon vs File and Mapped vs Unmapped. Without prev_priority, there
is a potential risk of unnecessarily increasing minor faults as a large
amount of read activity of use-once pages could push mapped pages to the
end of the LRU and get unmapped.

There is no proof this is still a problem but currently it is not considered
to be. Active files are not deactivated if the active file list is smaller
than the inactive list reducing the liklihood that file-mapped pages are
being pushed off the LRU and referenced executable pages are kept on the
active list to avoid them getting pushed out by read activity.

Even if it is a problem, prev_priority prev_priority wouldn't works
nowadays. First of all, current vmscan still a lot of UP centric code. it
expose some weakness on some dozens CPUs machine. I think we need more and
more improvement.

The problem is, current vmscan mix up per-system-pressure, per-zone-pressure
and per-task-pressure a bit. example, prev_priority try to boost priority to
other concurrent priority. but if the another task have mempolicy restriction,
it is unnecessary, but also makes wrong big latency and exceeding reclaim.
per-task based priority + prev_priority adjustment make the emulation of
per-system pressure. but it have two issue 1) too rough and brutal emulation
2) we need per-zone pressure, not per-system.

Another example, currently DEF_PRIORITY is 12. it mean the lru rotate about
2 cycle (1/4096 + 1/2048 + 1/1024 + .. + 1) before invoking OOM-Killer.
but if 10,0000 thrreads enter DEF_PRIORITY reclaim at the same time, the
system have higher memory pressure than priority==0 (1/4096*10,000 > 2).
prev_priority can't solve such multithreads workload issue. In other word,
prev_priority concept assume the sysmtem don't have lots threads."

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/memcontrol.h |    5 ----
 include/linux/mmzone.h     |   15 -----------
 mm/memcontrol.c            |   31 ------------------------
 mm/page_alloc.c            |    2 -
 mm/vmscan.c                |   57 --------------------------------------------
 mm/vmstat.c                |    2 -
 6 files changed, 0 insertions(+), 112 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9411d32..9f1afd3 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -98,11 +98,6 @@ extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
 /*
  * For memory reclaim.
  */
-extern int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem);
-extern void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem,
-							int priority);
-extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
-							int priority);
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b4d109e..b578eee 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -348,21 +348,6 @@ struct zone {
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
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c6ece0a..7557f66 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -211,8 +211,6 @@ struct mem_cgroup {
 	*/
 	spinlock_t reclaim_param_lock;
 
-	int	prev_priority;	/* for recording reclaim priority */
-
 	/*
 	 * While reclaiming in a hierarchy, we cache the last child we
 	 * reclaimed from.
@@ -858,35 +856,6 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
 	return ret;
 }
 
-/*
- * prev_priority control...this will be used in memory reclaim path.
- */
-int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem)
-{
-	int prev_priority;
-
-	spin_lock(&mem->reclaim_param_lock);
-	prev_priority = mem->prev_priority;
-	spin_unlock(&mem->reclaim_param_lock);
-
-	return prev_priority;
-}
-
-void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem, int priority)
-{
-	spin_lock(&mem->reclaim_param_lock);
-	if (priority < mem->prev_priority)
-		mem->prev_priority = priority;
-	spin_unlock(&mem->reclaim_param_lock);
-}
-
-void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem, int priority)
-{
-	spin_lock(&mem->reclaim_param_lock);
-	mem->prev_priority = priority;
-	spin_unlock(&mem->reclaim_param_lock);
-}
-
 static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_pages)
 {
 	unsigned long active;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 431214b..0b0b629 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4081,8 +4081,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
-		zone->prev_priority = DEF_PRIORITY;
-
 		zone_pcp_init(zone);
 		for_each_lru(l) {
 			INIT_LIST_HEAD(&zone->lru[l].list);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 20160c7..f3d95c6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1286,20 +1286,6 @@ done:
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
@@ -1762,17 +1748,8 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
 		if (scanning_global_lru(sc)) {
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
-			note_zone_scanning_priority(zone, priority);
-
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
-		} else {
-			/*
-			 * Ignore cpuset limitation here. We just want to reduce
-			 * # of used pages by us regardless of memory shortage.
-			 */
-			mem_cgroup_note_reclaim_priority(sc->mem_cgroup,
-							priority);
 		}
 
 		shrink_zone(priority, zone, sc);
@@ -1878,17 +1855,6 @@ out:
 	if (priority < 0)
 		priority = 0;
 
-	if (scanning_global_lru(sc)) {
-		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
-
-			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
-				continue;
-
-			zone->prev_priority = priority;
-		}
-	} else
-		mem_cgroup_record_reclaim_priority(sc->mem_cgroup, priority);
-
 	delayacct_freepages_end();
 	put_mems_allowed();
 
@@ -2054,22 +2020,12 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 		.order = order,
 		.mem_cgroup = NULL,
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
@@ -2137,9 +2093,7 @@ loop_again:
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;
 
-			temp_priority[i] = priority;
 			sc.nr_scanned = 0;
-			note_zone_scanning_priority(zone, priority);
 
 			nid = pgdat->node_id;
 			zid = zone_idx(zone);
@@ -2212,16 +2166,6 @@ loop_again:
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
 
@@ -2641,7 +2585,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 */
 		priority = ZONE_RECLAIM_PRIORITY;
 		do {
-			note_zone_scanning_priority(zone, priority);
 			shrink_zone(priority, zone, &sc);
 			priority--;
 		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7759941..5c0b1b6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -853,11 +853,9 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
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
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
