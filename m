Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4ADE96B009F
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:41:08 -0400 (EDT)
Date: Fri, 21 Aug 2009 15:27:43 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH -v2 changelog updated] mm: do batched scans for mem_cgroup
Message-ID: <20090821072743.GA1808@localhost>
References: <20090820024929.GA19793@localhost> <20090820121347.8a886e4b.kamezawa.hiroyu@jp.fujitsu.com> <20090820040533.GA27540@localhost> <28c262360908202055u2744879cic989e007867d0599@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28c262360908202055u2744879cic989e007867d0599@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

For mem_cgroup, shrink_zone() may call shrink_list() with nr_to_scan=1,
in which case shrink_list() _still_ calls isolate_pages() with the much
larger SWAP_CLUSTER_MAX.  It effectively scales up the inactive list
scan rate by up to 32 times.

For example, with 16k inactive pages and DEF_PRIORITY=12, (16k >> 12)=4.
So when shrink_zone() expects to scan 4 pages in the active/inactive
list, the active list will be scanned 4 pages, while the inactive list
will be (over) scanned SWAP_CLUSTER_MAX=32 pages in effect. And that
could break the balance between the two lists.

It can further impact the scan of anon active list, due to the anon
active/inactive ratio rebalance logic in balance_pgdat()/shrink_zone():

inactive anon list over scanned => inactive_anon_is_low() == TRUE
                                => shrink_active_list()
                                => active anon list over scanned

So the end result may be

- anon inactive  => over scanned
- anon active    => over scanned (maybe not as much)
- file inactive  => over scanned
- file active    => under scanned (relatively)

The accesses to nr_saved_scan are not lock protected and so not 100%
accurate, however we can tolerate small errors and the resulted small
imbalanced scan rates between zones.

CC: Rik van Riel <riel@redhat.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/mmzone.h |    6 +++++-
 mm/page_alloc.c        |    2 +-
 mm/vmscan.c            |   20 +++++++++++---------
 3 files changed, 17 insertions(+), 11 deletions(-)

--- linux.orig/include/linux/mmzone.h	2009-08-21 15:02:50.000000000 +0800
+++ linux/include/linux/mmzone.h	2009-08-21 15:03:25.000000000 +0800
@@ -269,6 +269,11 @@ struct zone_reclaim_stat {
 	 */
 	unsigned long		recent_rotated[2];
 	unsigned long		recent_scanned[2];
+
+	/*
+	 * accumulated for batching
+	 */
+	unsigned long		nr_saved_scan[NR_LRU_LISTS];
 };
 
 struct zone {
@@ -323,7 +328,6 @@ struct zone {
 	spinlock_t		lru_lock;	
 	struct zone_lru {
 		struct list_head list;
-		unsigned long nr_saved_scan;	/* accumulated for batching */
 	} lru[NR_LRU_LISTS];
 
 	struct zone_reclaim_stat reclaim_stat;
--- linux.orig/mm/vmscan.c	2009-08-21 15:03:15.000000000 +0800
+++ linux/mm/vmscan.c	2009-08-21 15:03:25.000000000 +0800
@@ -1521,6 +1521,7 @@ static void shrink_zone(int priority, st
 	enum lru_list l;
 	unsigned long nr_reclaimed = sc->nr_reclaimed;
 	unsigned long swap_cluster_max = sc->swap_cluster_max;
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	int noswap = 0;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
@@ -1540,12 +1541,9 @@ static void shrink_zone(int priority, st
 			scan >>= priority;
 			scan = (scan * percent[file]) / 100;
 		}
-		if (scanning_global_lru(sc))
-			nr[l] = nr_scan_try_batch(scan,
-						  &zone->lru[l].nr_saved_scan,
-						  swap_cluster_max);
-		else
-			nr[l] = scan;
+		nr[l] = nr_scan_try_batch(scan,
+					  &reclaim_stat->nr_saved_scan[l],
+					  swap_cluster_max);
 	}
 
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
@@ -2128,6 +2126,7 @@ static void shrink_all_zones(unsigned lo
 {
 	struct zone *zone;
 	unsigned long nr_reclaimed = 0;
+	struct zone_reclaim_stat *reclaim_stat;
 
 	for_each_populated_zone(zone) {
 		enum lru_list l;
@@ -2144,11 +2143,14 @@ static void shrink_all_zones(unsigned lo
 						l == LRU_ACTIVE_FILE))
 				continue;
 
-			zone->lru[l].nr_saved_scan += (lru_pages >> prio) + 1;
-			if (zone->lru[l].nr_saved_scan >= nr_pages || pass > 3) {
+			reclaim_stat = get_reclaim_stat(zone, sc);
+			reclaim_stat->nr_saved_scan[l] +=
+						(lru_pages >> prio) + 1;
+			if (reclaim_stat->nr_saved_scan[l]
+						>= nr_pages || pass > 3) {
 				unsigned long nr_to_scan;
 
-				zone->lru[l].nr_saved_scan = 0;
+				reclaim_stat->nr_saved_scan[l] = 0;
 				nr_to_scan = min(nr_pages, lru_pages);
 				nr_reclaimed += shrink_list(l, nr_to_scan, zone,
 								sc, prio);
--- linux.orig/mm/page_alloc.c	2009-08-21 15:02:50.000000000 +0800
+++ linux/mm/page_alloc.c	2009-08-21 15:03:25.000000000 +0800
@@ -3734,7 +3734,7 @@ static void __paginginit free_area_init_
 		zone_pcp_init(zone);
 		for_each_lru(l) {
 			INIT_LIST_HEAD(&zone->lru[l].list);
-			zone->lru[l].nr_saved_scan = 0;
+			zone->reclaim_stat.nr_saved_scan[l] = 0;
 		}
 		zone->reclaim_stat.recent_rotated[0] = 0;
 		zone->reclaim_stat.recent_rotated[1] = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
