Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 7E9856B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 20:56:18 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] compaction: fix deferring compaction mistake
Date: Wed,  8 Aug 2012 09:57:44 +0900
Message-Id: <1344387464-10037-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>

[1] fixed bad deferring policy but made mistake about checking
compact_order_failed in __compact_pgdat so it can't update
compact_order_failed with new order. It ends up preventing working
of deffering policy rightly. This patch fixes it.

[1] aff62249, vmscan: only defer compaction for failed order and higher

Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/compaction.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index e78cb96..b6984e2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -861,7 +861,7 @@ static int __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 		if (cc->order > 0) {
 			int ok = zone_watermark_ok(zone, cc->order,
 						low_wmark_pages(zone), 0, 0);
-			if (ok && cc->order > zone->compact_order_failed)
+			if (ok && cc->order >= zone->compact_order_failed)
 				zone->compact_order_failed = cc->order + 1;
 			/* Currently async compaction is never deferred. */
 			else if (!ok && cc->sync)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
