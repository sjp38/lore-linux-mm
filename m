Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 70A4E6B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 09:12:58 -0400 (EDT)
Date: Tue, 5 May 2009 21:09:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] vmscan: ZVC updates in shrink_active_list() can be
	done once
Message-ID: <20090505130923.GA25145@localhost>
References: <20090504234455.GA6324@localhost> <20090505123350.GA19060@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090505123350.GA19060@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "npiggin@suse.de" <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 05, 2009 at 08:33:50PM +0800, Johannes Weiner wrote:
> On Tue, May 05, 2009 at 07:44:55AM +0800, Wu Fengguang wrote:
> > This effectively lifts the unit of nr_inactive_* and pgdeactivate updates
> > from PAGEVEC_SIZE=14 to SWAP_CLUSTER_MAX=32.
> 
> For __zone_reclaim() it will be >= SWAP_CLUSTER_MAX, depending on the
> allocation order.

Thanks for pointing out this. Changelog updated accordingly.

I'd expect its impact to be negletable, because 1024 pages are
not extraordinary large.  But sure, that's much larger than 125 pages
- the maximum zone stats update threshold(zone_pcp->stat_threshold).

Thanks,
Fengguang
---
vmscan: ZVC updates in shrink_active_list() can be done once

This effectively lifts the unit of updates to nr_inactive_* and pgdeactivate
from PAGEVEC_SIZE=14 to SWAP_CLUSTER_MAX=32, or MAX_ORDER_NR_PAGES=1024 for
reclaim_zone().

CC: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

--- linux.orig/mm/vmscan.c
+++ linux/mm/vmscan.c
@@ -1228,7 +1228,6 @@ static void shrink_active_list(unsigned 
 			struct scan_control *sc, int priority, int file)
 {
 	unsigned long pgmoved;
-	int pgdeactivate = 0;
 	unsigned long pgscanned;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_inactive);
@@ -1257,7 +1256,7 @@ static void shrink_active_list(unsigned 
 		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
 
-	pgmoved = 0;
+	pgmoved = 0;  /* count referenced (mapping) mapped pages */
 	while (!list_empty(&l_hold)) {
 		cond_resched();
 		page = lru_to_page(&l_hold);
@@ -1291,7 +1290,7 @@ static void shrink_active_list(unsigned 
 	 */
 	reclaim_stat->recent_rotated[!!file] += pgmoved;
 
-	pgmoved = 0;
+	pgmoved = 0;  /* count pages moved to inactive list */
 	while (!list_empty(&l_inactive)) {
 		page = lru_to_page(&l_inactive);
 		prefetchw_prev_lru_page(page, &l_inactive, flags);
@@ -1304,10 +1303,7 @@ static void shrink_active_list(unsigned 
 		mem_cgroup_add_lru_list(page, lru);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
-			__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
 			spin_unlock_irq(&zone->lru_lock);
-			pgdeactivate += pgmoved;
-			pgmoved = 0;
 			if (buffer_heads_over_limit)
 				pagevec_strip(&pvec);
 			__pagevec_release(&pvec);
@@ -1315,9 +1311,8 @@ static void shrink_active_list(unsigned 
 		}
 	}
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
-	pgdeactivate += pgmoved;
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
-	__count_vm_events(PGDEACTIVATE, pgdeactivate);
+	__count_vm_events(PGDEACTIVATE, pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
 	if (buffer_heads_over_limit)
 		pagevec_strip(&pvec);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
