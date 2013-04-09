Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id A0A696B003B
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 07:18:07 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/10] mm: vmscan: Do not allow kswapd to scan at maximum priority
Date: Tue,  9 Apr 2013 12:07:00 +0100
Message-Id: <1365505625-9460-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1365505625-9460-1-git-send-email-mgorman@suse.de>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
index a9e68b4..3d8b80a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2906,7 +2906,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		 */
 		if (raise_priority || !this_reclaimed)
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
