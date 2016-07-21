Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE686B0261
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:39:38 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id q83so144761542iod.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 01:39:38 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id p184si4407777iod.238.2016.07.21.01.39.36
        for <linux-mm@kvack.org>;
        Thu, 21 Jul 2016 01:39:37 -0700 (PDT)
Date: Thu, 21 Jul 2016 17:39:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/5] Candidate fixes for premature OOM kills with
 node-lru v1
Message-ID: <20160721083956.GB8356@bbox>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
 <20160721073156.GC27554@js1304-P5Q-DELUXE>
MIME-Version: 1.0
In-Reply-To: <20160721073156.GC27554@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2016 at 04:31:56PM +0900, Joonsoo Kim wrote:
> On Wed, Jul 20, 2016 at 04:21:46PM +0100, Mel Gorman wrote:
> > Both Joonsoo Kim and Minchan Kim have reported premature OOM kills on
> > a 32-bit platform. The common element is a zone-constrained high-order
> > allocation failing. Two factors appear to be at fault -- pgdat being
> > considered unreclaimable prematurely and insufficient rotation of the
> > active list.
> > 
> > Unfortunately to date I have been unable to reproduce this with a variety
> > of stress workloads on a 2G 32-bit KVM instance. It's not clear why as
> > the steps are similar to what was described. It means I've been unable to
> > determine if this series addresses the problem or not. I'm hoping they can
> > test and report back before these are merged to mmotm. What I have checked
> > is that a basic parallel DD workload completed successfully on the same
> > machine I used for the node-lru performance tests. I'll leave the other
> > tests running just in case anything interesting falls out.
> 
> Hello, Mel.
> 
> I tested this series and it doesn't solve my problem. But, with this
> series and one change below, my problem is solved.
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f5ab357..d451c29 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1819,7 +1819,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
>  
>                 nr_pages = hpage_nr_pages(page);
>                 update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
> -               list_move(&page->lru, &lruvec->lists[lru]);
> +               list_move_tail(&page->lru, &lruvec->lists[lru]);
>                 pgmoved += nr_pages;
>  
>                 if (put_page_testzero(page)) {
> 
> It is brain-dead work-around so it is better you to find a better solution.

I tested below patch roughly and it enhanced performance a lot.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index cd68a18..9061e5a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1809,7 +1809,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 static void move_active_pages_to_lru(struct lruvec *lruvec,
 				     struct list_head *list,
 				     struct list_head *pages_to_free,
-				     enum lru_list lru)
+				     enum lru_list lru,
+				     bool tail)
 {
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	unsigned long pgmoved = 0;
@@ -1825,7 +1826,10 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 
 		nr_pages = hpage_nr_pages(page);
 		update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
-		list_move(&page->lru, &lruvec->lists[lru]);
+		if (!tail)
+			list_move(&page->lru, &lruvec->lists[lru]);
+		else
+			list_move_tail(&page->lru, &lruvec->lists[lru]);
 		pgmoved += nr_pages;
 
 		if (put_page_testzero(page)) {
@@ -1847,6 +1851,47 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
 
+static bool inactive_list_is_extreme_low(struct lruvec *lruvec, bool file,
+						struct scan_control *sc)
+{
+	unsigned long inactive;
+
+	/*
+	 * If we don't have swap space, anonymous page deactivation
+	 * is pointless.
+	 */
+	if (!file && !total_swap_pages)
+		return false;
+
+	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
+
+	/*
+	 * For global reclaim on zone-constrained allocations, it is necessary
+	 * to check if rotations are required for lowmem to be reclaimed. This
+	 * calculates the inactive/active pages available in eligible zones.
+	 */
+	if (global_reclaim(sc)) {
+		struct pglist_data *pgdat = lruvec_pgdat(lruvec);
+		int zid;
+
+		for (zid = sc->reclaim_idx + 1; zid < MAX_NR_ZONES; zid++) {
+			struct zone *zone = &pgdat->node_zones[zid];
+			unsigned long inactive_zone;
+
+			if (!populated_zone(zone))
+				continue;
+
+			inactive_zone = zone_page_state(zone,
+					NR_ZONE_LRU_BASE + (file * LRU_FILE));
+
+			inactive -= min(inactive, inactive_zone);
+		}
+	}
+
+
+	return inactive <= (SWAP_CLUSTER_MAX * num_online_cpus());
+}
+
 static void shrink_active_list(unsigned long nr_to_scan,
 			       struct lruvec *lruvec,
 			       struct scan_control *sc,
@@ -1937,9 +1982,11 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 * get_scan_count.
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
+	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru, false);
+	move_active_pages_to_lru(lruvec, &l_inactive,
+		&l_hold, lru - LRU_ACTIVE,
+		inactive_list_is_extreme_low(lruvec, is_file_lru(lru), sc));
 
-	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
-	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
