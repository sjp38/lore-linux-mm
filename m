Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 0554B6B0033
	for <linux-mm@kvack.org>; Thu, 30 May 2013 14:04:34 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 01/10] mm: page_alloc: zone round-robin allocator
Date: Thu, 30 May 2013 14:03:57 -0400
Message-Id: <1369937046-27666-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
References: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, metin d <metdos@yahoo.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Each zone that holds pages of one workload must be aged at a speed
proportional to the zone size.  Otherwise, the time an individual page
gets to stay in memory depends on the zone it happened to be allocated
in.  Asymmetry in the zone aging creates rather unpredictable aging
behavior and results in the wrong pages being reclaimed, activated
etc.

But exactly this happens right now because of the way the page
allocator and kswapd interact.  The page allocator uses per-node lists
of all zones in the system, ordered by preference, when allocating a
new page.  When the first iteration does not yield any results, kswapd
is woken up and the allocator retries.  Due to the way kswapd reclaims
zones below the high watermark but a zone can be allocated from when
it is above the low watermark, the allocator may keep kswapd running
while kswapd reclaim ensures that the page allocator can keep
allocating from the first zone in the zonelist for extended periods of
time.  Meanwhile the other zones rarely see new allocations and thus
get aged much slower in comparison.

The result is that the occasional page placed in lower zones gets
relatively more time in memory, even get promoted to the active list
after its peers have long been evicted.  Meanwhile, the bulk of the
working set may be thrashing on the preferred zone even though there
may be significant amounts of memory available in the lower zones.

Even the most basic test -- repeatedly reading a file slightly bigger
than memory -- shows how broken the zone aging is.  In this scenario,
no single page should be able stay in memory long enough to get
referenced twice and activated, but activation happens in spades:

  $ grep active_file /proc/zoneinfo
      nr_inactive_file 0
      nr_active_file 0
      nr_inactive_file 0
      nr_active_file 8
      nr_inactive_file 1582
      nr_active_file 11994
  $ cat data data data data >/dev/null
  $ grep active_file /proc/zoneinfo
      nr_inactive_file 0
      nr_active_file 70
      nr_inactive_file 258753
      nr_active_file 443214
      nr_inactive_file 149793
      nr_active_file 12021

This problem will be more pronounced when subsequent patches base list
rebalancing decisions on the time between the eviction of pages and
their refault into memory, as the measured time values might be
heavily skewed by the aging speed imbalances.

Fix this with a very simple round-robin allocator.  Each zone is
allowed a batch of allocations that is proportional to the zone's
size, after which it is treated as full.  The batch counters are reset
when all zones have been tried and kswapd is woken up.

  $ grep active_file /proc/zoneinfo
      nr_inactive_file 0
      nr_active_file 0
      nr_inactive_file 174
      nr_active_file 4865
      nr_inactive_file 53
      nr_active_file 860
  $ cat data data data data >/dev/null
  $ grep active_file /proc/zoneinfo
      nr_inactive_file 0
      nr_active_file 0
      nr_inactive_file 666622
      nr_active_file 4988
      nr_inactive_file 190969
      nr_active_file 937

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |  3 +++
 mm/page_alloc.c        | 32 +++++++++++++++++++++++++++++---
 2 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c74092e..370a35f 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -367,6 +367,9 @@ struct zone {
 #endif
 	struct free_area	free_area[MAX_ORDER];
 
+	/* zone round-robin allocator batch */
+	atomic_t		alloc_batch;
+
 #ifndef CONFIG_SPARSEMEM
 	/*
 	 * Flags for a pageblock_nr_pages block. See pageblock-flags.h.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fcced7..a64d786 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1896,6 +1896,14 @@ zonelist_scan:
 		    (gfp_mask & __GFP_WRITE) && !zone_dirty_ok(zone))
 			goto this_zone_full;
 
+		/*
+		 * XXX: Ensure similar zone aging speeds by
+		 * round-robin allocating through the zonelist.
+		 */
+		if (atomic_read(&zone->alloc_batch) >
+		    high_wmark_pages(zone) - low_wmark_pages(zone))
+			goto this_zone_full;
+
 		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
 			unsigned long mark;
@@ -1906,6 +1914,21 @@ zonelist_scan:
 				    classzone_idx, alloc_flags))
 				goto try_this_zone;
 
+			/*
+			 * XXX: With multiple nodes, kswapd balancing
+			 * is not synchronized with the round robin
+			 * allocation quotas.  If kswapd of a node
+			 * goes to sleep at the wrong time, a zone
+			 * might reach the low watermark while there
+			 * is still allocation quota left.  Kick
+			 * kswapd in this situation to ensure the
+			 * aging speed of the zone.  It's got to be
+			 * rebalanced anyway...
+			 */
+			if (!(gfp_mask & __GFP_NO_KSWAPD))
+				wakeup_kswapd(zone, order,
+					      zone_idx(preferred_zone));
+
 			if (IS_ENABLED(CONFIG_NUMA) &&
 					!did_zlc_setup && nr_online_nodes > 1) {
 				/*
@@ -1962,7 +1985,8 @@ this_zone_full:
 		goto zonelist_scan;
 	}
 
-	if (page)
+	if (page) {
+		atomic_add(1 << order, &zone->alloc_batch);
 		/*
 		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
 		 * necessary to allocate the page. The expectation is
@@ -1971,7 +1995,7 @@ this_zone_full:
 		 * for !PFMEMALLOC purposes.
 		 */
 		page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
-
+	}
 	return page;
 }
 
@@ -2303,8 +2327,10 @@ void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
 	struct zoneref *z;
 	struct zone *zone;
 
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+		atomic_set(&zone->alloc_batch, 0);
 		wakeup_kswapd(zone, order, classzone_idx);
+	}
 }
 
 static inline int
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
