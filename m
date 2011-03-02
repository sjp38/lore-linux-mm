Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9128D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 09:26:14 -0500 (EST)
Date: Wed, 2 Mar 2011 14:25:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] remove compaction from kswapd
Message-ID: <20110302142542.GE14162@csn.ul.ie>
References: <20110228222138.GP22700@random.random> <AANLkTingkWo6dx=0sGdmz9qNp+_TrQnKXnmASwD8LhV4@mail.gmail.com> <20110301223954.GI19057@random.random> <AANLkTim7tcPTxG9hyFiSnQ7rqfMdoUhL1wrmqNAXAvEK@mail.gmail.com> <20110301164143.e44e5699.akpm@linux-foundation.org> <20110302043856.GB23911@random.random> <20110301205324.f0daaf86.akpm@linux-foundation.org> <20110302055221.GD23911@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110302055221.GD23911@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

On Wed, Mar 02, 2011 at 06:52:21AM +0100, Andrea Arcangeli wrote:
> On Tue, Mar 01, 2011 at 08:53:24PM -0800, Andrew Morton wrote:
> > The original patch description didn't explain this.
> 
> Right, I should have added one line saying it was a revert of commit
> 5a03b051ed87e72b959f32a86054e1142ac4cf55 sorry. Mel knew it well, I
> thought it was well known but it was better to specify it.
> 
> Minchan also noted I didn't remove compact_mode from the
> compact_control structure but that's entirely harmless.
> 
> All we need is to run `git show
> 5a03b051ed87e72b959f32a86054e1142ac4cf55|patch -p1 -R` except it's not
> going to apply clean so I had to create a patch for that.
> 
> > And no patch is "zero risk", especially at -rc6.
> 
> Well sure, but I see little chance for this to give unexpected
> troubles (also CONFIG_COMPACTION remains an option default to N).
> 
> > And we have no useful information about benchmark results.
> 
> I've been discussing with Mel to write a simulator with some dummy
> kernel module that floods the kernel with order 2 allocations. We need
> that before we can try to readd this. So we can have real sure
> benchmarks and we can reproduce easily.

The best so far that came out of that effort was a systemtap script that
generates periodic and bursty atomic allocations up to a maximum of 0.5M worth
of pages at a time. It's woefully primitive and nor represenative or any real
usage but early indications are that it can at least force some of the worst
situations to occur.  What it doesn't do is give any real data on how real
applications behave though so I didn't want to use it for patch justifications.

> The multimedia setup and the
> network jumbo frame benchmarks are not the simplest way to reproduce.
> 

And I don't have the necessary hardware. Keeping an eye on ebay to see
if something pops up!

> > What change?  Commit ID?  What testing returned -EFAIL?  That's
> > different from slower benchmark results.
> 
> I meant testing showed a definitive regression on two absolutely
> different workload (but that they both had compound allocation in
> drivers, and both bisected down to that specific compaction-kswapd
> code), no syscall really returned -EFAULT. I posted commit id above.
> 
> > *What* two patches???  I don't have a clue which patches you're referring to. 
> > Patches have names, please use them.
> 
> These are the other two patches that are needed for both workloads to
> be better than before.
> 
> mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-pages-for-migration
> mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-free-pages
> 
> These two are important too because even the NMI watchdog triggered
> once without these. But this irq latency problem in compaction was
> shown by commit 5a03b051ed87e72b959f32a86054e1142ac4cf55 that made
> compaction run too much. These are separate problems.
> 

I don't recall the NMI watchdog problem but I know Andrea is aware of more
reports related to commit 5a03b051e so I wasn't surprised either. What I was
mainly aware of and led to the "minise the time irqs are disabled" is this
thread http://www.spinics.net/linux/fedora/alsa-user/msg09885.html

In it, an ALSA user complained that MIDI playback had slowed considerably
and kswapd was consuming far too much CPU. The hardware he was using
depended heavily on interrupts being delivered on time and without major
disruption. The primary source of this disruption was IRQs being disabled
by kswapd running compaction.

I wasn't able to directly reproduce this due to lack of hardware doing atomic
allocations which is why I didn't mention it in the leader but I was able to
reproduce IRQs being disabled for a long time - 8ms on a semi-normal machine
running a mean but not entirely unreasonable workload. This length disabling
will cause any number of problems - not least that the RT people like Peter,
Ingo, Thomas et al will spit their coffee all over the keyboard. The two
patches I sent you fix this.

So, my justification for those patches being merged for 2.6.38 is that IRQs
being disabled in low-memory situation for milliseconds at a time is going
to produce some strange bug reports from vaguely unhappy users with jittery
desktops (haven't seen this particular sympton myself but my machine is
rarely stressed and when it is, I'm off somewhere else). It'll be very hard to
diagnose what went wrong unless someone uses the irqs-off function tracer to
point the finger at kswapd running compaction. What is more likely to happen
is that we'll see "low memory" and think it's another writeback-related
problem. Granted, it should get fixed up in 2.6.39-rc1 or 2.6.38.1 but we
might have a lot of useless bug reports by then covering over other problems.

> > This is just hopeless.  Please, just send the thing again and this time
> > include a *full* description of what it does and why it does it.
> 
> Ok the thing is I'm being quite busy and wifi coverage isn't full, I'm
> writing this in some lobby where I pick up the connection, but I tried
> to get it submitted anyway because I liked to revert the feature ASAP
> as I didn't want to risk regressions because of this one. I'll give it
> another shot now, but if it isn't ok let me know and I'll try again
> tomorrow afternoon. (also note this isn't related to THP, THP uses
> __GFP_NO_KSWAPD, it's for the other users of compound pages). This is
> one case where we thought it was a good idea, but in practice it
> didn't payoff the way we thought.
> 
> I initially asked Mel to submit the patch as I hoped he had more time
> than me this week, but he suggested me to send it, so I did. But I
> didn't intend to cause this confusion, sorry Andrew!
> 

My apologies as well. I wasn't able to reproduce the kswapd problem so the
results I had were ambigious at best. I suggested Andrea post the patch
because I thought he had far better data on why it should be merged this
close to 2.6.38.

> My rationale is that even assuming the benchmarking is absolutely
> wrong and commit 5a03b051ed87e72b959f32a86054e1142ac4cf55 improved
> latency and througput (almost impossible considering that two people
> running different workloads sent me bugreports bisecting down to that
> exact same commit showing both bad irq latencies showing kswapd
> overwork in the profiling or top) to me it's still safer to revert it
> in doubt (considering it's not very important) and re-evaluate it
> fully for 2.6.39. This is really all about going safe. This is about
> not risking to introduce a regression. Unfortunately it was reported
> only late that this patch caused trouble, if they reported it before I
> would have never submitted commit
> 5a03b051ed87e72b959f32a86054e1142ac4cf55 in the first place.
> 

Agreed.

> <SNIP>
>
> ===
> Subject: compaction: fix high compaction latencies and remove compaction-kswapd
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> This reverts commit 5a03b051ed87e72b959f32a86054e1142ac4cf55 which is causing
> latency problems and higher kswapd cpu utilization. Reverting that commit that
> adds the compaction-in-kswapd feature is safer than trying to fix it to return
> to 2.6.37 status.
> 
> NOTE: this is not related to THP (THP allocations uses __GFP_NO_KSWAPD), this
> is only related to frequent and small order allocations that make kswapd go
> wild with compaction.
> 
> v2: removed compact_mode from compact_control (noticed by Minchan Kim).
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

In light of this thread, I'm going to revise this changelog
with some additional information and will strip out a piece of
mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-pages-for-migration
that strayed in by accident. I still haven't been able to prove on my own
machines that it really helps unfortunately but Andrea and Arthur both
seem sure.

==== CUT HERE ====
mm: compaction: Prevent kswapd compacting memory to reduce CPU usage

This patch reverts [5a03b051: thp: use compaction in kswapd for GFP_ATOMIC
order > 0] due to reports stating that kswapd CPU usage was higher
and IRQs were being disabled more frequently. This was reported at
http://www.spinics.net/linux/fedora/alsa-user/msg09885.html .

Without this patch applied, CPU usage by kswapd hovers
around the 20% mark according to the tester (Arthur Marsh:
http://www.spinics.net/linux/fedora/alsa-user/msg09899.html). With this
patch applied, it's around 2%.

The problem is not related to THP which specifies __GFP_NO_KSWAPD but is
triggered by high-order allocations hitting the low watermark for their
order and waking kswapd on kernels with CONFIG_COMPACTION set. The most
common trigger for this is network cards configured for jumbo frames but
it's also possible it'll be triggered by fork-heavy workloads (order-1)
and some wireless cards which depend on order-1 allocations.

The symptoms for the user will be high CPU usage by kswapd in low-memory
situations which could be confused with another writeback problem.  While a
patch like 5a03b051 may be reintroduced in the future, this patch plays it
safe for now and reverts it.

[mel@csn.ul.ie: Beefed up the changelog]
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/compaction.h |    9 ++-------
 mm/compaction.c            |   24 +++---------------------
 mm/vmscan.c                |   18 +-----------------
 3 files changed, 6 insertions(+), 45 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index dfa2ed4..cc9f7a4 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -11,9 +11,6 @@
 /* The full zone was compacted */
 #define COMPACT_COMPLETE	3
 
-#define COMPACT_MODE_DIRECT_RECLAIM	0
-#define COMPACT_MODE_KSWAPD		1
-
 #ifdef CONFIG_COMPACTION
 extern int sysctl_compact_memory;
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
@@ -28,8 +25,7 @@ extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			bool sync);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 extern unsigned long compact_zone_order(struct zone *zone, int order,
-					gfp_t gfp_mask, bool sync,
-					int compact_mode);
+					gfp_t gfp_mask, bool sync);
 
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
@@ -74,8 +70,7 @@ static inline unsigned long compaction_suitable(struct zone *zone, int order)
 }
 
 static inline unsigned long compact_zone_order(struct zone *zone, int order,
-					       gfp_t gfp_mask, bool sync,
-					       int compact_mode)
+					       gfp_t gfp_mask, bool sync)
 {
 	return COMPACT_CONTINUE;
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index ec9eb0f..094cc53 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -42,8 +42,6 @@ struct compact_control {
 	unsigned int order;		/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
-
-	int compact_mode;
 };
 
 static unsigned long release_freepages(struct list_head *freelist)
@@ -423,10 +421,7 @@ static int compact_finished(struct zone *zone,
 		return COMPACT_COMPLETE;
 
 	/* Compaction run is not finished if the watermark is not met */
-	if (cc->compact_mode != COMPACT_MODE_KSWAPD)
-		watermark = low_wmark_pages(zone);
-	else
-		watermark = high_wmark_pages(zone);
+	watermark = low_wmark_pages(zone);
 	watermark += (1 << cc->order);
 
 	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
@@ -439,15 +434,6 @@ static int compact_finished(struct zone *zone,
 	if (cc->order == -1)
 		return COMPACT_CONTINUE;
 
-	/*
-	 * Generating only one page of the right order is not enough
-	 * for kswapd, we must continue until we're above the high
-	 * watermark as a pool for high order GFP_ATOMIC allocations
-	 * too.
-	 */
-	if (cc->compact_mode == COMPACT_MODE_KSWAPD)
-		return COMPACT_CONTINUE;
-
 	/* Direct compactor: Is a suitable page free? */
 	for (order = cc->order; order < MAX_ORDER; order++) {
 		/* Job done if page is free of the right migratetype */
@@ -569,8 +555,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
-				 bool sync,
-				 int compact_mode)
+				 bool sync)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -579,7 +564,6 @@ unsigned long compact_zone_order(struct zone *zone,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
 		.sync = sync,
-		.compact_mode = compact_mode,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -625,8 +609,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 								nodemask) {
 		int status;
 
-		status = compact_zone_order(zone, order, gfp_mask, sync,
-					    COMPACT_MODE_DIRECT_RECLAIM);
+		status = compact_zone_order(zone, order, gfp_mask, sync);
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
@@ -657,7 +640,6 @@ static int compact_node(int nid)
 			.nr_freepages = 0,
 			.nr_migratepages = 0,
 			.order = -1,
-			.compact_mode = COMPACT_MODE_DIRECT_RECLAIM,
 		};
 
 		zone = &pgdat->node_zones[zoneid];
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1c71d0f..b0e442f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2397,7 +2397,6 @@ loop_again:
 		 * cause too much scanning of the lower zones.
 		 */
 		for (i = 0; i <= end_zone; i++) {
-			int compaction;
 			struct zone *zone = pgdat->node_zones + i;
 			int nr_slab;
 			unsigned long balance_gap;
@@ -2438,24 +2437,9 @@ loop_again:
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 
-			compaction = 0;
-			if (order &&
-			    zone_watermark_ok(zone, 0,
-					       high_wmark_pages(zone),
-					      end_zone, 0) &&
-			    !zone_watermark_ok(zone, order,
-					       high_wmark_pages(zone),
-					       end_zone, 0)) {
-				compact_zone_order(zone,
-						   order,
-						   sc.gfp_mask, false,
-						   COMPACT_MODE_KSWAPD);
-				compaction = 1;
-			}
-
 			if (zone->all_unreclaimable)
 				continue;
-			if (!compaction && nr_slab == 0 &&
+			if (nr_slab == 0 &&
 			    !zone_reclaimable(zone))
 				zone->all_unreclaimable = 1;
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
