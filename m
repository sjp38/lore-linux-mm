Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CCAC36B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 20:11:43 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] vmscan: fix missing place to check nr_swap_pages.
Date: Thu, 26 Aug 2010 17:11:37 -0700
Message-Id: <1282867897-31201-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: minchan.kim@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fix a missed place where checks nr_swap_pages to do shrink_active_list. Make the
change that moves the check to common function inactive_anon_is_low.

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/vmscan.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3109ff7..c7923e7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1605,6 +1605,9 @@ static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc)
 {
 	int low;
 
+	if (nr_swap_pages <= 0)
+		return 0;
+
 	if (scanning_global_lru(sc))
 		low = inactive_anon_is_low_global(zone);
 	else
@@ -1856,7 +1859,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
+	if (inactive_anon_is_low(zone, sc))
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
