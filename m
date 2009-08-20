Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 917756B004F
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 23:15:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7K3Fg1B030690
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 20 Aug 2009 12:15:42 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E6FC45DE61
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 12:15:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D2C545DE4F
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 12:15:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AF191DB803A
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 12:15:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D2E1F1DB803C
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 12:15:41 +0900 (JST)
Date: Thu, 20 Aug 2009 12:13:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: do batched scans for mem_cgroup
Message-Id: <20090820121347.8a886e4b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090820024929.GA19793@localhost>
References: <20090820024929.GA19793@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Aug 2009 10:49:29 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> For mem_cgroup, shrink_zone() may call shrink_list() with nr_to_scan=1,
> in which case shrink_list() _still_ calls isolate_pages() with the much
> larger SWAP_CLUSTER_MAX.  It effectively scales up the inactive list
> scan rate by up to 32 times.
> 
> For example, with 16k inactive pages and DEF_PRIORITY=12, (16k >> 12)=4.
> So when shrink_zone() expects to scan 4 pages in the active/inactive
> list, it will be scanned SWAP_CLUSTER_MAX=32 pages in effect.
> 
> The accesses to nr_saved_scan are not lock protected and so not 100%
> accurate, however we can tolerate small errors and the resulted small
> imbalanced scan rates between zones.
> 
> This batching won't blur up the cgroup limits, since it is driven by
> "pages reclaimed" rather than "pages scanned". When shrink_zone()
> decides to cancel (and save) one smallish scan, it may well be called
> again to accumulate up nr_saved_scan.
> 
> It could possibly be a problem for some tiny mem_cgroup (which may be
> _full_ scanned too much times in order to accumulate up nr_saved_scan).
> 
> CC: Rik van Riel <riel@redhat.com>
> CC: Minchan Kim <minchan.kim@gmail.com>
> CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---

Hmm, how about this ? 
==
Now, nr_saved_scan is tied to zone's LRU.
But, considering how vmscan works, it should be tied to reclaim_stat.

By this, memcg can make use of nr_saved_scan information seamlessly.

---
 include/linux/mmzone.h |    2 +-
 mm/vmscan.c            |   19 ++++++++++---------
 2 files changed, 11 insertions(+), 10 deletions(-)

Index: linux-2.6.31-rc6/include/linux/mmzone.h
===================================================================
--- linux-2.6.31-rc6.orig/include/linux/mmzone.h	2009-08-17 15:14:21.000000000 +0900
+++ linux-2.6.31-rc6/include/linux/mmzone.h	2009-08-20 12:10:44.000000000 +0900
@@ -269,6 +269,7 @@
 	 */
 	unsigned long		recent_rotated[2];
 	unsigned long		recent_scanned[2];
+	unsigned long nr_saved_scan[NR_LRU_LISTS];/* accumulated for batching */
 };
 
 struct zone {
@@ -323,7 +324,6 @@
 	spinlock_t		lru_lock;	
 	struct zone_lru {
 		struct list_head list;
-		unsigned long nr_saved_scan;	/* accumulated for batching */
 	} lru[NR_LRU_LISTS];
 
 	struct zone_reclaim_stat reclaim_stat;
Index: linux-2.6.31-rc6/mm/vmscan.c
===================================================================
--- linux-2.6.31-rc6.orig/mm/vmscan.c	2009-08-17 15:14:21.000000000 +0900
+++ linux-2.6.31-rc6/mm/vmscan.c	2009-08-20 12:17:47.000000000 +0900
@@ -1521,6 +1521,7 @@
 	enum lru_list l;
 	unsigned long nr_reclaimed = sc->nr_reclaimed;
 	unsigned long swap_cluster_max = sc->swap_cluster_max;
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	int noswap = 0;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
@@ -1540,12 +1541,9 @@
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
+					  &recalim_stat->nr_saved_scan[l],
+					  swap_cluster_max);
 	}
 
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
@@ -2128,6 +2126,7 @@
 {
 	struct zone *zone;
 	unsigned long nr_reclaimed = 0;
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
 	for_each_populated_zone(zone) {
 		enum lru_list l;
@@ -2144,11 +2143,13 @@
 						l == LRU_ACTIVE_FILE))
 				continue;
 
-			zone->lru[l].nr_saved_scan += (lru_pages >> prio) + 1;
-			if (zone->lru[l].nr_saved_scan >= nr_pages || pass > 3) {
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





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
