Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D66CD6B00A1
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 06:48:28 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/3] vmscan: Put kswapd to sleep on its own waitqueue, not congestion
Date: Mon,  8 Mar 2010 11:48:23 +0000
Message-Id: <1268048904-19397-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Nick Piggin <npiggin@suse.de>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

If kswapd is raising its priority to get the zone over the high
watermark, it may call congestion_wait() ostensibly to allow congestion
to clear. However, there is no guarantee that the queue is congested at
this point because it depends on kswapds previous actions as well as the
rest of the system. Kswapd could simply be working hard because there is
a lot of SYNC traffic in which case it shouldn't be sleeping.

Rather than waiting on congestion and potentially sleeping for longer
than it should, this patch puts kswapd back to sleep on the kswapd_wait
queue for the timeout. If direct reclaimers are in trouble, kswapd will
be rewoken as it should instead of sleeping when there is work to be
done.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4f92a48..894d366 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1955,7 +1955,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
  * interoperates with the page allocator fallback scheme to ensure that aging
  * of pages is balanced across the zones.
  */
-static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
+static unsigned long balance_pgdat(pg_data_t *pgdat, wait_queue_t *wait, int order)
 {
 	int all_zones_ok;
 	int priority;
@@ -2122,8 +2122,11 @@ loop_again:
 		if (total_scanned && (priority < DEF_PRIORITY - 2)) {
 			if (has_under_min_watermark_zone)
 				count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
-			else
-				congestion_wait(BLK_RW_ASYNC, HZ/10);
+			else {
+				prepare_to_wait(&pgdat->kswapd_wait, wait, TASK_INTERRUPTIBLE);
+				schedule_timeout(HZ/10);
+				finish_wait(&pgdat->kswapd_wait, wait);
+			}
 		}
 
 		/*
@@ -2272,7 +2275,7 @@ static int kswapd(void *p)
 		 * after returning from the refrigerator
 		 */
 		if (!ret)
-			balance_pgdat(pgdat, order);
+			balance_pgdat(pgdat, &wait, order);
 	}
 	return 0;
 }
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
