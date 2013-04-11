Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 2CA8B6B0039
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 15:58:15 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/10] mm: vmscan: Do not allow kswapd to scan at maximum priority
Date: Thu, 11 Apr 2013 20:57:53 +0100
Message-Id: <1365710278-6807-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1365710278-6807-1-git-send-email-mgorman@suse.de>
References: <1365710278-6807-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Page reclaim at priority 0 will scan the entire LRU as priority 0 is
considered to be a near OOM condition. Kswapd can reach priority 0 quite
easily if it is encountering a large number of pages it cannot reclaim
such as pages under writeback. When this happens, kswapd reclaims very
aggressively even though there may be no real risk of allocation failure
or OOM.

This patch prevents kswapd reaching priority 0 and trying to reclaim
the world. Direct reclaimers will still reach priority 0 in the event
of an OOM situation.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 25d89af..bc4c2a7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2918,7 +2918,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		 */
 		if (raise_priority || !sc.nr_reclaimed)
 			sc.priority--;
-	} while (sc.priority >= 0 &&
+	} while (sc.priority >= 1 &&
 		 !pgdat_balanced(pgdat, order, *classzone_idx));
 
 out:
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
