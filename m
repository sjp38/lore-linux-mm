Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5BE316B00F5
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:15:46 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so401400wah.22
        for <linux-mm@kvack.org>; Thu, 14 May 2009 07:16:00 -0700 (PDT)
Date: Thu, 14 May 2009 23:15:55 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: [PATCH] mmtom: Prevent shrinking of active anon lru list in case of
 no swap space V3
Message-Id: <20090514231555.f52c81eb.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Changelog since V3
 o Remove can_reclaim_anon. 
 o Add nr_swap_page > 0 in only shrink_zone - By Rik's advise.
 o Change patch description.

Changelog since V2
 o Add new function - can_reclaim_anon : it tests anon_list can be reclaim.

Changelog since V1
 o Use nr_swap_pages <= 0 in shrink_active_list to prevent scanning  of active anon list.

Now shrink_zone can deactivate active anon pages even if we don't have a swap device. 
Many embedded products don't have a swap device. So the deactivation of anon pages is unnecessary. 

This patch prevents unnecessary deactivation of anon lru pages.
But, it don't prevent aging of anon pages to swap out.

Thanks for good review. Rik and Kosaki.  

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>

---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2f9d555..621708f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1577,7 +1577,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_anon_is_low(zone, sc))
+	if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);
-- 
1.5.4.3


-- 
Kinds Regards,
Minchan Kim 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
