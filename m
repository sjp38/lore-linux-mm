Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C94B26B0179
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 06:39:25 -0400 (EDT)
Date: Tue, 21 Jun 2011 11:39:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: sandy bridge kswapd0 livelock with pagecache
Message-ID: <20110621103920.GF9396@suse.de>
References: <4E0069FE.4000708@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4E0069FE.4000708@draigBrady.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: P?draig Brady <P@draigBrady.com>
Cc: linux-mm@kvack.org

On Tue, Jun 21, 2011 at 10:53:02AM +0100, P?draig Brady wrote:
> I tried the 2 patches here to no avail:
> http://marc.info/?l=linux-mm&m=130503811704830&w=2
> 
> I originally logged this at:
> https://bugzilla.redhat.com/show_bug.cgi?id=712019
> 
> I can compile up and quickly test any suggestions.
> 

I recently looked through what kswapd does and there are a number
of problem areas. Unfortunately, I haven't gotten around to doing
anything about it yet or running the test cases to see if they are
really problems. In your case, the following is a strong possibility
though. This should be applied on top of the two patches merged from
that thread.

This is not tested in any way, based on 3.0-rc3

==== CUT HERE ====
mm: vmscan: Stop looping in kswapd if high-order reclaim is failing

A number of people have identified a problem whereby kswapd consumes
99% of CPU in a tight loop. It was determined that there are constant
sources of high-order allocations but in the event the allocations are
failing, kswapd continues to consume CPU and reclaim too much memory.

kswapd can and does give up costly high-order reclaim but only if it is
failing to make forward progress. This patch tracks how much memory
kswapd has reclaimed. If it reclaims 4 times the size of the allocation
request, it resets to order-0, balance for that order and will go to
sleep unless there has been continued allocation requests. "4 times" is
a tad arbitrary but it's down to
(1<<PAGE_ALLOC_COSTLY_ORDER)*4 == SWAP_CLUSTER_MAX
which is the "standard" unit of reclaim kswapd works on so scale it
similarily for the higher orders.

Not signed off by as it is barely a prototype
---
 mm/vmscan.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index faa0a08..8fb262f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2376,6 +2376,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
+	unsigned long total_reclaimed;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
@@ -2397,6 +2398,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	};
 loop_again:
 	total_scanned = 0;
+	total_reclaimed = 0;
 	sc.nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
@@ -2564,6 +2566,7 @@ loop_again:
 			break;
 	}
 out:
+	total_reclaimed += sc.nr_reclaimed;
 
 	/*
 	 * order-0: All zones must meet high watermark for a balanced node
@@ -2584,12 +2587,18 @@ out:
 		 * little point trying all over again as kswapd may
 		 * infinite loop.
 		 *
+		 * Similarly, if we have reclaimed far more pages than the
+		 * original request size, it's likely that contiguous reclaim
+		 * is not finding the pages it needs and it should give
+		 * up.
+		 *
 		 * Instead, recheck all watermarks at order-0 as they
 		 * are the most important. If watermarks are ok, kswapd will go
 		 * back to sleep. High-order users can still perform direct
 		 * reclaim if they wish.
 		 */
-		if (sc.nr_reclaimed < SWAP_CLUSTER_MAX)
+		if (sc.nr_reclaimed < SWAP_CLUSTER_MAX ||
+				(order > PAGE_ALLOC_COSTLY_ORDER && total_reclaimed > (4UL << order)) )
 			order = sc.order = 0;
 
 		goto loop_again;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
