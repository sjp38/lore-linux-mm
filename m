Date: Wed, 1 Aug 2007 01:02:51 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: make swappiness safer to use
Message-ID: <20070731230251.GX6910@v2.random>
References: <20070731215228.GU6910@v2.random> <20070731151244.3395038e.akpm@linux-foundation.org> <20070731224052.GW6910@v2.random> <20070731155109.228b4f19.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070731155109.228b4f19.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 31, 2007 at 03:51:09PM -0700, Andrew Morton wrote:
> Yeah, I misread the paranthesisation. sorry.

never mind!

> I nice way of coding this would be:
> 
> 	/*
> 	 * comment goes here
> 	 */
> 	adjust = zone_page_state(zone, NR_ACTIVE) /
> 			(zone_page_state(zone, NR_INACTIVE) + 1);
> 
> 	/*
> 	 * comment goes here 
> 	 */
> 	adjust *= (vm_swappiness + 1) / 100;
> 
> 	/*
> 	 * comment goes here 
> 	 */
> 	adjust *= mapped_ratio / 100;
> 
> 	/*
> 	 * comment goes here
> 	 */
> 	swap_tendency += adjust;
> 
> so there's no confusion over parenthesisation or associativity, and the
> reader can see the logic as it unfolds.  The compiler should do exactly the
> same thing.
> 
> It is worth expending the extra effort and screen space for clarity in that
> part of the kernel, given the amount of trouble it causes, and the amount
> of time people spend sweating over it.   Those would want to be good 
> comments, too.

Ok.

Signed-off-by: Kurt Garloff <garloff@suse.de>
Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -879,6 +879,7 @@ static void shrink_active_list(unsigned 
 		long mapped_ratio;
 		long distress;
 		long swap_tendency;
+		long imbalance;
 
 		if (zone_is_near_oom(zone))
 			goto force_reclaim_mapped;
@@ -912,6 +913,44 @@ static void shrink_active_list(unsigned 
 		 * altogether.
 		 */
 		swap_tendency = mapped_ratio / 2 + distress + sc->swappiness;
+
+		/*
+		 * If there's huge imbalance between active and inactive
+		 * (think active 100 times larger than inactive) we should
+		 * become more permissive, or the system will take too much
+		 * cpu before it start swapping during memory pressure.
+		 * Distress is about avoiding early-oom, this is about
+		 * making swappiness graceful despite setting it to low
+		 * values.
+		 *
+		 * Avoid div by zero with nr_inactive+1, and max resulting
+		 * value is vm_total_pages.
+		 */
+		imbalance = zone_page_state(zone, NR_ACTIVE) /
+                        (zone_page_state(zone, NR_INACTIVE) + 1);
+
+		/*
+		 * Reduce the effect of imbalance if swappiness is low,
+		 * this means for a swappiness very low, the imbalance
+		 * must be much higher than 100 for this logic to make
+		 * the difference.
+		 *
+		 * Max temporary value is vm_total_pages*100.
+		 */
+		imbalance *= (vm_swappiness + 1) / 100;
+
+		/*
+		 * If not much of the ram is mapped, makes the imbalance
+		 * less relevant, it's high priority we refill the inactive
+		 * list with mapped pages only in presence of high ratio of
+		 * mapped pages.
+		 *
+		 * Max temporary value is vm_total_pages*100.
+		 */
+		imbalance *= mapped_ratio / 100;
+
+		/* apply imbalance feedback to swap_tendency */
+		swap_tendency += imbalance;
 
 		/*
 		 * Now use this metric to decide whether to start moving mapped

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
