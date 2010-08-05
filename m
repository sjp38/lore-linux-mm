Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A52A16B02A8
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 02:15:18 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o756FTZn002393
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 5 Aug 2010 15:15:29 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F1F0145DE60
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:15:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CFC3745DE4D
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:15:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B913F1DB8037
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:15:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 458751DB803A
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:15:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 6/7] vmscan: remove PF_SWAPWRITE from __zone_reclaim()
In-Reply-To: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
Message-Id: <20100805151448.31C9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  5 Aug 2010 15:15:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

When zone_reclaim() was merged at first, It always order-0
allocation with PF_SWAPWRITE flag. (probably they are both
unintional).

Former was fixed commit bd2f6199cf (vmscan: respect higher
order in zone_reclaim()). However it expose latter mistake
because !order-0 reclaim often cause dirty pages isolation
and large latency.

Now, we have good opportunity to fix latter too.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f21dbeb..e043e97 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2663,7 +2663,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	 * and we also need to be able to write out pages for RECLAIM_WRITE
 	 * and RECLAIM_SWAP.
 	 */
-	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
+	p->flags |= PF_MEMALLOC;
 	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
@@ -2716,7 +2716,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	}
 
 	p->reclaim_state = NULL;
-	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
+	current->flags &= ~PF_MEMALLOC;
 	lockdep_clear_current_reclaim_state();
 	return sc.nr_reclaimed >= nr_pages;
 }
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
