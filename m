Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 3B5356B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 07:12:13 -0400 (EDT)
Date: Thu, 20 Jun 2013 12:12:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5] Soft limit rework
Message-ID: <20130620111206.GA14809@suse.de>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

On Tue, Jun 18, 2013 at 02:09:39PM +0200, Michal Hocko wrote:
> base is mmotm-2013-05-09-15-57
> baserebase is mmotm-2013-06-05-17-24-63 + patches from the current mmots
> without slab shrinkers patchset.
> reworkrebase all patches 8 applied on top of baserebase
> 
> * No-limit
> User
> base: min: 1164.94 max: 1169.75 avg: 1168.31 std: 1.57 runs: 6
> baserebase: min: 1169.46 [100.4%] max: 1176.07 [100.5%] avg: 1172.49 [100.4%] std: 2.38 runs: 6
> reworkrebase: min: 1172.58 [100.7%] max: 1177.43 [100.7%] avg: 1175.53 [100.6%] std: 1.91 runs: 6
> System
> base: min: 242.55 max: 245.36 avg: 243.92 std: 1.17 runs: 6
> baserebase: min: 235.36 [97.0%] max: 238.52 [97.2%] avg: 236.70 [97.0%] std: 1.04 runs: 6
> reworkrebase: min: 236.21 [97.4%] max: 239.46 [97.6%] avg: 237.55 [97.4%] std: 1.05 runs: 6
> Elapsed
> base: min: 596.81 max: 620.04 avg: 605.52 std: 7.56 runs: 6
> baserebase: min: 666.45 [111.7%] max: 710.89 [114.7%] avg: 690.62 [114.1%] std: 13.85 runs: 6
> reworkrebase: min: 664.05 [111.3%] max: 701.06 [113.1%] avg: 689.29 [113.8%] std: 12.36 runs: 6
> 
> Elapsed time regressed by 13% wrt. base but it seems that this came from
> baserebase which regressed by the same amount.
> 

boo-urns

> Page fault statistics tell us at least part of the story:
> Minor
> base: min: 35941845.00 max: 36029788.00 avg: 35986860.17 std: 28288.66 runs: 6
> baserebase: min: 35852414.00 [99.8%] max: 35899605.00 [99.6%] avg: 35874906.83 [99.7%] std: 18722.59 runs: 6
> reworkrebase: min: 35538346.00 [98.9%] max: 35584907.00 [98.8%] avg: 35562362.17 [98.8%] std: 18921.74 runs: 6
> Major
> base: min: 25390.00 max: 33132.00 avg: 29961.83 std: 2476.58 runs: 6
> baserebase: min: 34224.00 [134.8%] max: 45674.00 [137.9%] avg: 41556.83 [138.7%] std: 3595.39 runs: 6
> reworkrebase: min: 277.00 [1.1%] max: 480.00 [1.4%] avg: 384.67 [1.3%] std: 74.67 runs: 6

Can you try this monolithic patch please?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fe73724..f677780 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1477,25 +1477,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * as there is no guarantee the dirtying process is throttled in the
 	 * same way balance_dirty_pages() manages.
 	 *
-	 * This scales the number of dirty pages that must be under writeback
-	 * before a zone gets flagged ZONE_WRITEBACK. It is a simple backoff
-	 * function that has the most effect in the range DEF_PRIORITY to
-	 * DEF_PRIORITY-2 which is the priority reclaim is considered to be
-	 * in trouble and reclaim is considered to be in trouble.
-	 *
-	 * DEF_PRIORITY   100% isolated pages must be PageWriteback to throttle
-	 * DEF_PRIORITY-1  50% must be PageWriteback
-	 * DEF_PRIORITY-2  25% must be PageWriteback, kswapd in trouble
-	 * ...
-	 * DEF_PRIORITY-6 For SWAP_CLUSTER_MAX isolated pages, throttle if any
-	 *                     isolated page is PageWriteback
-	 *
 	 * Once a zone is flagged ZONE_WRITEBACK, kswapd will count the number
 	 * of pages under pages flagged for immediate reclaim and stall if any
 	 * are encountered in the nr_immediate check below.
 	 */
-	if (nr_writeback && nr_writeback >=
-			(nr_taken >> (DEF_PRIORITY - sc->priority)))
+	if (nr_writeback && nr_writeback == nr_taken)
 		zone_set_flag(zone, ZONE_WRITEBACK);
 
 	/*
@@ -2382,12 +2368,14 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	struct zone *zone;
 	unsigned long writeback_threshold;
 	bool aborted_reclaim;
+	int min_scan_priority = 1;
 
 	delayacct_freepages_start();
 
 	if (global_reclaim(sc))
 		count_vm_event(ALLOCSTALL);
 
+rescan:
 	do {
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
 				sc->priority);
@@ -2442,7 +2430,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 						WB_REASON_TRY_TO_FREE_PAGES);
 			sc->may_writepage = 1;
 		}
-	} while (--sc->priority >= 0);
+	} while (--sc->priority >= min_scan_priority);
 
 out:
 	delayacct_freepages_end();
@@ -2466,6 +2454,12 @@ out:
 	if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
 		return 1;
 
+	/* If the page allocator is going to consider OOM, rescan at priority 0 */
+	if (min_scan_priority) {
+		min_scan_priority = 0;
+		goto rescan;
+	}
+
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
