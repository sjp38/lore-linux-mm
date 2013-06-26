Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 6AEC56B0032
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 08:39:33 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/2] mm: vmscan: Do not scale writeback pages when deciding whether to set ZONE_WRITEBACK
Date: Wed, 26 Jun 2013 13:39:24 +0100
Message-Id: <1372250364-20640-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1372250364-20640-1-git-send-email-mgorman@suse.de>
References: <1372250364-20640-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

After the patch "mm: vmscan: Flatten kswapd priority loop" was merged the
scanning priority of kswapd changed. The priority now raises until it is
scanning enough pages to meet the high watermark.  shrink_inactive_list sets
ZONE_WRITEBACK if a number of pages were encountered under writeback but
this value is scaled based on the priority. As kswapd frequently scans with
a higher priority now it is relatively easy to set ZONE_WRITEBACK. This
patch removes the scaling and treates writeback pages similar to how it
treats unqueued dirty pages and congested pages.  The user-visible effect
should be that kswapd will writeback fewer pages from reclaim context.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 65f2fbea..f677780 100644
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
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
