From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 04/10] mm: vmscan: Decide whether to compact the pgdat
 based on reclaim progress
Date: Mon, 18 Mar 2013 19:11:30 +0800
Message-ID: <39649.0668216304$1363605147@news.gmane.org>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-5-git-send-email-mgorman@suse.de>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UHXzJ-00068E-Af
	for glkm-linux-mm-2@m.gmane.org; Mon, 18 Mar 2013 12:12:21 +0100
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 423B06B004D
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 07:11:41 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 18 Mar 2013 16:37:58 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 3C99E3940058
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 16:41:34 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2IBBVb866322652
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 16:41:31 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2IBBWwn023230
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 22:11:33 +1100
Content-Disposition: inline
In-Reply-To: <1363525456-10448-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Sun, Mar 17, 2013 at 01:04:10PM +0000, Mel Gorman wrote:
>In the past, kswapd makes a decision on whether to compact memory after the
>pgdat was considered balanced. This more or less worked but it is late to
>make such a decision and does not fit well now that kswapd makes a decision
>whether to exit the zone scanning loop depending on reclaim progress.
>
>This patch will compact a pgdat if at least  the requested number of pages
>were reclaimed from unbalanced zones for a given priority. If any zone is
>currently balanced, kswapd will not call compaction as it is expected the
>necessary pages are already available.
>
>Signed-off-by: Mel Gorman <mgorman@suse.de>
>---
> mm/vmscan.c | 52 +++++++++++++++++++++-------------------------------
> 1 file changed, 21 insertions(+), 31 deletions(-)
>
>diff --git a/mm/vmscan.c b/mm/vmscan.c
>index 279d0c2..7513bd1 100644
>--- a/mm/vmscan.c
>+++ b/mm/vmscan.c
>@@ -2694,8 +2694,11 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>
> 	do {
> 		unsigned long lru_pages = 0;
>+		unsigned long nr_to_reclaim = 0;
> 		unsigned long nr_reclaimed = sc.nr_reclaimed;
>+		unsigned long this_reclaimed;
> 		bool raise_priority = true;
>+		bool pgdat_needs_compaction = true;
>
> 		/*
> 		 * Scan in the highmem->dma direction for the highest
>@@ -2743,7 +2746,17 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> 		for (i = 0; i <= end_zone; i++) {
> 			struct zone *zone = pgdat->node_zones + i;
>
>+			if (!populated_zone(zone))
>+				continue;
>+
> 			lru_pages += zone_reclaimable_pages(zone);
>+
>+			/* Check if the memory needs to be defragmented */
>+			if (order && pgdat_needs_compaction &&
>+					zone_watermark_ok(zone, order,
>+						low_wmark_pages(zone),
>+						*classzone_idx, 0))
>+				pgdat_needs_compaction = false;
> 		}
>
> 		/*
>@@ -2814,6 +2827,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> 				 */
> 				if (kswapd_shrink_zone(zone, &sc, lru_pages))
> 					raise_priority = false;
>+
>+				nr_to_reclaim += sc.nr_to_reclaim;
> 			}
>
> 			/*
>@@ -2864,46 +2879,21 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> 		if (try_to_freeze() || kthread_should_stop())
> 			break;
>
>-		/* If no reclaim progress then increase scanning priority */
>-		if (sc.nr_reclaimed - nr_reclaimed == 0)
>-			raise_priority = true;
>+		/* Compact if necessary and kswapd is reclaiming efficiently */
>+		this_reclaimed = sc.nr_reclaimed - nr_reclaimed;
>+		if (order && pgdat_needs_compaction &&
>+				this_reclaimed > nr_to_reclaim)
>+			compact_pgdat(pgdat, order);
>

Hi Mel,

If you should check compaction_suitable here to confirm it's not because
other reasons like large number of pages under writeback to avoid blind
compaction. :-)

Regards,
Wanpeng Li

> 		/*
> 		 * Raise priority if scanning rate is too low or there was no
> 		 * progress in reclaiming pages
> 		 */
>-		if (raise_priority || sc.nr_reclaimed - nr_reclaimed == 0)
>+		if (raise_priority || !this_reclaimed)
> 			sc.priority--;
> 	} while (sc.priority >= 0 &&
> 		 !pgdat_balanced(pgdat, order, *classzone_idx));
>
>-	/*
>-	 * If kswapd was reclaiming at a higher order, it has the option of
>-	 * sleeping without all zones being balanced. Before it does, it must
>-	 * ensure that the watermarks for order-0 on *all* zones are met and
>-	 * that the congestion flags are cleared. The congestion flag must
>-	 * be cleared as kswapd is the only mechanism that clears the flag
>-	 * and it is potentially going to sleep here.
>-	 */
>-	if (order) {
>-		int zones_need_compaction = 1;
>-
>-		for (i = 0; i <= end_zone; i++) {
>-			struct zone *zone = pgdat->node_zones + i;
>-
>-			if (!populated_zone(zone))
>-				continue;
>-
>-			/* Check if the memory needs to be defragmented. */
>-			if (zone_watermark_ok(zone, order,
>-				    low_wmark_pages(zone), *classzone_idx, 0))
>-				zones_need_compaction = 0;
>-		}
>-
>-		if (zones_need_compaction)
>-			compact_pgdat(pgdat, order);
>-	}
>-
> out:
> 	/*
> 	 * Return the order we were reclaiming at so prepare_kswapd_sleep()
>-- 
>1.8.1.4
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
