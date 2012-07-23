Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 5A4B66B0071
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:38:53 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/34] vmscan: clear ZONE_CONGESTED for zone with good watermark
Date: Mon, 23 Jul 2012 14:38:18 +0100
Message-Id: <1343050727-3045-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Shaohua Li <shaohua.li@intel.com>

commit 439423f6894aa0dec22187526827456f5004baed upstream.

Stable note: Not tracked in Bugzilla. kswapd is responsible for clearing
	ZONE_CONGESTED after it balances a zone and this patch fixes a bug
	where that was failing to happen. Without this patch, processes
	can stall in wait_iff_congested unnecessarily. For users, this can
	look like an interactivity stall but some workloads would see it
	as sudden drop in throughput.

ZONE_CONGESTED is only cleared in kswapd, but pages can be freed in any
task.  It's possible ZONE_CONGESTED isn't cleared in some cases:

 1. the zone is already balanced just entering balance_pgdat() for
    order-0 because concurrent tasks free memory.  In this case, later
    check will skip the zone as it's balanced so the flag isn't cleared.

 2. high order balance fallbacks to order-0.  quote from Mel: At the
    end of balance_pgdat(), kswapd uses the following logic;

	If reclaiming at high order {
		for each zone {
			if all_unreclaimable
				skip
			if watermark is not met
				order = 0
				loop again

			/* watermark is met */
			clear congested
		}
	}

    i.e. it clears ZONE_CONGESTED if it the zone is balanced.  if not,
    it restarts balancing at order-0.  However, if the higher zones are
    balanced for order-0, kswapd will miss clearing ZONE_CONGESTED as
    that only happens after a zone is shrunk.  This can mean that
    wait_iff_congested() stalls unnecessarily.

This patch makes kswapd clear ZONE_CONGESTED during its initial
highmem->dma scan for zones that are already balanced.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bdfdec3..72340b84 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2456,6 +2456,9 @@ loop_again:
 					high_wmark_pages(zone), 0, 0)) {
 				end_zone = i;
 				break;
+			} else {
+				/* If balanced, clear the congested flag */
+				zone_clear_flag(zone, ZONE_CONGESTED);
 			}
 		}
 		if (i < 0)
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
