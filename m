Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 6FBCF6B0036
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 08:39:33 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/2] mm: vmscan: Avoid direct reclaim scanning at maximum priority
Date: Wed, 26 Jun 2013 13:39:23 +0100
Message-Id: <1372250364-20640-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1372250364-20640-1-git-send-email-mgorman@suse.de>
References: <1372250364-20640-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Page reclaim at priority 0 will scan the entire LRU as priority 0 is
considered to be a near OOM condition. Direct reclaim can reach this
priority while still making reclaim progress. This patch avoids
reclaiming at priority 0 unless no reclaim progress was made and
the page allocator would consider firing the OOM killer. The
user-visible impact is that direct reclaim will not easily reach
priority 0 and start swapping prematurely.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fe73724..65f2fbea 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2382,12 +2382,14 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
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
@@ -2442,7 +2444,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 						WB_REASON_TRY_TO_FREE_PAGES);
 			sc->may_writepage = 1;
 		}
-	} while (--sc->priority >= 0);
+	} while (--sc->priority >= min_scan_priority);
 
 out:
 	delayacct_freepages_end();
@@ -2466,6 +2468,12 @@ out:
 	if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
 		return 1;
 
+	/* If the page allocator is considering OOM, rescan at priority 0 */
+	if (min_scan_priority) {
+		min_scan_priority = 0;
+		goto rescan;
+	}
+
 	return 0;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
