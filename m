Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B4E126B00F4
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 14:24:04 -0500 (EST)
Date: Wed, 25 Feb 2009 20:25:50 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: don't free swap slots on page deactivation
Message-ID: <20090225192550.GA5645@cmpxchg.org>
References: <20090225023830.GA1611@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090225023830.GA1611@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The pagevec_swap_free() at the end of shrink_active_list() was
introduced in 68a22394 "vmscan: free swap space on swap-in/activation"
when shrink_active_list() was still rotating referenced active pages.

In 7e9cd48 "vmscan: fix pagecache reclaim referenced bit check" this
was changed, the rotating removed but the pagevec_swap_free() after
the rotation loop was forgotten, applying now to the pagevec of the
deactivation loop instead.

Now swap space is freed for deactivated pages.  And only for those
that happen to be on the pagevec after the deactivation loop.

Complete 7e9cd48 and remove the rest of the swap freeing.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |    3 ---
 1 file changed, 3 deletions(-)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1303,9 +1303,6 @@ static void shrink_active_list(unsigned 
 	spin_unlock_irq(&zone->lru_lock);
 	if (buffer_heads_over_limit)
 		pagevec_strip(&pvec);
-	if (vm_swap_full())
-		pagevec_swap_free(&pvec);
-
 	pagevec_release(&pvec);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
