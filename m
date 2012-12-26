Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id A6C0E6B002B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 10:07:15 -0500 (EST)
Date: Wed, 26 Dec 2012 16:07:10 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <50D24AF3.1050809@iskon.hr> <20121220111208.GD10819@suse.de> <20121220125802.23e9b22d.akpm@linux-foundation.org> <50D601C9.9060803@iskon.hr> <50D71166.6030608@iskon.hr>
In-Reply-To: <50D71166.6030608@iskon.hr>
Message-ID: <50DB129E.7010000@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Subject: [PATCH] mm: avoid calling pgdat_balanced() needlessly
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Now that balance_pgdat() is slightly tidied up, thanks to more capable
pgdat_balanced(), it's become obvious that pgdat_balanced() is called
to check the status, then break the loop if pgdat is balanced, just to
be immediately called again. The second call is completely unnecessary,
of course.

The patch introduces pgdat_is_balanced boolean, which helps resolve the
above suboptimal behavior, with the added benefit of slightly better
documenting one other place in the function where we jump and skip lots
of code.

Signed-off-by: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
---
 mm/vmscan.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 23291b9..02bcfa3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2564,6 +2564,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 							int *classzone_idx)
 {
+	bool pgdat_is_balanced = false;
 	struct zone *unbalanced_zone;
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
@@ -2638,8 +2639,11 @@ loop_again:
 				zone_clear_flag(zone, ZONE_CONGESTED);
 			}
 		}
-		if (i < 0)
+
+		if (i < 0) {
+			pgdat_is_balanced = true;
 			goto out;
+		}
 
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
@@ -2766,8 +2770,11 @@ loop_again:
 				pfmemalloc_watermark_ok(pgdat))
 			wake_up(&pgdat->pfmemalloc_wait);
 
-		if (pgdat_balanced(pgdat, order, *classzone_idx))
+		if (pgdat_balanced(pgdat, order, *classzone_idx)) {
+			pgdat_is_balanced = true;
 			break;		/* kswapd: all done */
+		}
+
 		/*
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
 		 * another pass across the zones.
@@ -2788,9 +2795,9 @@ loop_again:
 		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
 			break;
 	} while (--sc.priority >= 0);
-out:
 
-	if (!pgdat_balanced(pgdat, order, *classzone_idx)) {
+out:
+	if (!pgdat_is_balanced) {
 		cond_resched();
 
 		try_to_freeze();
-- 
1.8.1.rc0

-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
