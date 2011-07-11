Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 620C26B004A
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 09:01:20 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/3] mm: vmscan: Do use use PF_SWAPWRITE from zone_reclaim
Date: Mon, 11 Jul 2011 14:01:12 +0100
Message-Id: <1310389274-13995-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1310389274-13995-1-git-send-email-mgorman@suse.de>
References: <1310389274-13995-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

Zone reclaim is similar to direct reclaim in a number of respects.
PF_SWAPWRITE is used by kswapd to avoid a write-congestion check
but it's set also set for zone_reclaim which is inappropriate.
Setting it potentially allows zone_reclaim users to cause large IO
stalls which is worse than remote memory accesses.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4f49535..ebef213 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3063,7 +3063,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	 * and we also need to be able to write out pages for RECLAIM_WRITE
 	 * and RECLAIM_SWAP.
 	 */
-	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
+	p->flags |= PF_MEMALLOC;
 	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
@@ -3116,7 +3116,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	}
 
 	p->reclaim_state = NULL;
-	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
+	current->flags &= ~PF_MEMALLOC;
 	lockdep_clear_current_reclaim_state();
 	return sc.nr_reclaimed >= nr_pages;
 }
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
