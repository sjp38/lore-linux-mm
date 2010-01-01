Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 34BDB60021B
	for <linux-mm@kvack.org>; Fri,  1 Jan 2010 04:54:08 -0500 (EST)
Received: by iwn41 with SMTP id 41so9199428iwn.12
        for <linux-mm@kvack.org>; Fri, 01 Jan 2010 01:54:06 -0800 (PST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm, lockdep: annotate reclaim context to zone reclaim too
Date: Fri,  1 Jan 2010 18:45:41 +0900
Message-Id: <1262339141-4682-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Commit cf40bd16fd (lockdep: annotate reclaim context) introduced reclaim
context annotation. But it didn't annotate zone reclaim. This patch do it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2bbee91..a039e78 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2547,6 +2547,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	 * and RECLAIM_SWAP.
 	 */
 	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
+	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
@@ -2590,6 +2591,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
 	p->reclaim_state = NULL;
 	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
+	lockdep_clear_current_reclaim_state();
 	return sc.nr_reclaimed >= nr_pages;
 }
 
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
