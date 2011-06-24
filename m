Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 77EFA900235
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 09:43:25 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/4] mm: vmscan: Correct check for kswapd sleeping in sleeping_prematurely
Date: Fri, 24 Jun 2011 14:43:15 +0100
Message-Id: <1308922998-15529-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1308922998-15529-1-git-send-email-mgorman@suse.de>
References: <1308922998-15529-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?P=C3=A1draig=20Brady?= <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

During allocator-intensive workloads, kswapd will be woken frequently
causing free memory to oscillate between the high and min watermark.
This is expected behaviour.

A problem occurs if the highest zone is small.  balance_pgdat()
only considers unreclaimable zones when priority is DEF_PRIORITY
but sleeping_prematurely considers all zones. It's possible for this
sequence to occur

  1. kswapd wakes up and enters balance_pgdat()
  2. At DEF_PRIORITY, marks highest zone unreclaimable
  3. At DEF_PRIORITY-1, ignores highest zone setting end_zone
  4. At DEF_PRIORITY-1, calls shrink_slab freeing memory from
        highest zone, clearing all_unreclaimable. Highest zone
        is still unbalanced
  5. kswapd returns and calls sleeping_prematurely
  6. sleeping_prematurely looks at *all* zones, not just the ones
     being considered by balance_pgdat. The highest small zone
     has all_unreclaimable cleared but but the zone is not
     balanced. all_zones_ok is false so kswapd stays awake

This patch corrects the behaviour of sleeping_prematurely to check
the zones balance_pgdat() checked.

Reported-and-tested-by: PA!draig Brady <P@draigBrady.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8ff834e..841e3bf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2323,7 +2323,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 		return true;
 
 	/* Check the watermark levels */
-	for (i = 0; i < pgdat->nr_zones; i++) {
+	for (i = 0; i <= classzone_idx; i++) {
 		struct zone *zone = pgdat->node_zones + i;
 
 		if (!populated_zone(zone))
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
