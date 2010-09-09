Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A253A6B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 08:39:26 -0400 (EDT)
Date: Thu, 9 Sep 2010 13:39:10 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
	direct reclaim allocation fails
Message-ID: <20100909123910.GP29263@csn.ul.ie>
References: <20100904081414.GF705@dastard> <20100905015400.GA10714@localhost> <20100905021555.GG705@dastard> <20100905060539.GA17450@localhost> <20100905131447.GJ705@dastard> <20100905134554.GA7083@localhost> <20100906040243.GA7362@dastard> <20100906084015.GJ8384@csn.ul.ie> <20100906215023.GC7362@dastard> <20100908084923.GW705@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100908084923.GW705@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 08, 2010 at 06:49:23PM +1000, Dave Chinner wrote:
> On Tue, Sep 07, 2010 at 07:50:23AM +1000, Dave Chinner wrote:
> > On Mon, Sep 06, 2010 at 09:40:15AM +0100, Mel Gorman wrote:
> > > On Mon, Sep 06, 2010 at 02:02:43PM +1000, Dave Chinner wrote:
> > > > I just went to grab the CAL counters, and found the system in
> > > > another livelock.  This time I managed to start the sysrq-trigger
> > > > dump while the livelock was in progress - I bas??cally got one shot
> > > > at a command before everything stopped responding. Now I'm waiting
> > > > for the livelock to pass.... 5min.... the fs_mark workload
> > > > has stopped (ctrl-c finally responded), still livelocked....
> > > > 10min.... 15min.... 20min.... OK, back now.
> > > > 
> > > > Interesting - all the fs_mark processes are in D state waiting on IO
> > > > completion processing.
> > > 
> > > Very interesting, maybe they are all stuck in congestion_wait() this
> > > time? There are a few sources where that is possible.
> > 
> > No, they are waiting on log IO completion, not doing allocation or
> > in the VM at all.  They stuck in xlog_get_iclog_state() waiting for
> > all the log IO buffers to be processed which are stuck behind the
> > inode buffer IO completions in th kworker threads that I posted. 
> > 
> > This potentially is caused by the kworker thread consolidation - log
> > IO completion processing used to be in a separate workqueue for
> > processing latency and deadlock prevention reasons - the data and
> > metadata IO completion can block, whereas we need the log IO
> > completion to occur as quickly as possible. I've seen one deadlock
> > that the separate work queues solved w.r.t. loop devices, and I
> > suspect that part of the problem here is that transaction completion
> > cannot occur (and free the memory it and the CIL holds) because log IO
> > completion processing is being delayed significantly by metadata IO
> > completion...
> .....
> > > > Which shows that this wasn't an IPI storm that caused this
> > > > particular livelock.
> > > 
> > > No, but it's possible we got stuck somewhere like too_many_isolated() or
> > > in congestion_wait. One thing at a time though, would you mind testing
> > > the following patch? I haven't tested this *at all* but it should reduce
> > > the number of times drain_all_pages() are called further while not
> > > eliminating them entirely.
> > 
> > Ok, I'll try it later today, but first I think I need to do some
> > deeper investigation on the kworker thread behaviour....
> 
> Ok, so an update is needed here. I have confirmed that the above
> livelock was caused by the kworker thread consolidation, and I have
> a fix for it (make the log IO completion processing queue WQ_HIGHPRI
> so it gets queued ahead of the data/metadata IO completions), and
> I've been able to create over a billion inodes now without a
> livelock occurring. See the thread titled "[2.6.36-rc3] Workqueues,
> XFS, dependencies and deadlock" if you want more details.
> 

Good stuff. I read through the thread and it seemed reasonable.

> To make sure I've been seeing two different livelocks, I removed
> Mel's series from my tree (which still contained the above workqueue
> fix), and I started seeing short memory allocation livelocks (10-15s
> at most) with abnormal increases in CAL counts indication an
> increase in IPIs during the short livelocks.  IOWs, the livelock
> was't as severe as before the workqueue fix, but still present.
> Hence the workqueue issue was definitely a contributing factor to
> the severity of the memory allocation triggered issue.
> 

Good. Considering that this class of bugs in either the page allocator
or page reclaim can be down to timing, it makes sense that a big change
in ordering of events could compound problems in the VM.

> It is clear that there have been two different livelocks with
> different caused by the same test, which has led to a lot of
> confusion in this thread. It appears that Mel's patch series as
> originally posted in this thread is all that is necessary to avoid
> the memory allocation livelock issue I was seeing. The workqueue
> fix solves the other livelock I was seeing once Mel's patches were
> in place.
> 
> Thanks to everyone for helping me track these livelocks down and
> providing lots of suggestions for things to try. I'll keep testing
> and looking for livelocks, but my confidence is increasing that
> we've got to the root of them now. 
> 

It has been pointed out that the fix potentially increases the number of
IPIs sent. On larger machines, I worry that these delays could be severe
and we'll see other problems down the line. Hence, I'd like to reduce
the number of calls to drain_all_pages() without eliminating them
entirely. I'm currently in the process of testing the following patch
but can you try it as well please?

In particular, I am curious to see if the performance of fs_mark
improves any and if the interrupt counts drop as a result of the patch.

Thanks

==== CUT HERE ====
mm: page allocator: Reduce the instances where drain_all_pages() is called

When a page allocation fails after direct reclaim, the per-cpu lists are
drained and another attempt made to allocate. On larger systems,
this can cause IPI storms in low-memory situations with latencies
increasing the more CPUs there are on the system. In extreme situations,
it is suspected it could cause livelock-like situations.

This patch restores older behaviour to call drain_all_pages() after direct
reclaim fails only for high-order allocations. As there is an expectation
that lower-orders will free naturally, the drain only occurs for order >
PAGE_ALLOC_COSTLY_ORDER. The reasoning is that the allocation is already
expected to be very expensive and rare so there will not be a resulting IPI
storm. drain_all_pages() called are not eliminated as it is still the case
that an allocation can fail because the necessary pages are pinned in the
per-cpu list. After this patch, the lists are only drained as a last-resort
before calling the OOM killer.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 750e1dc..16f516c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1737,6 +1737,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	int migratetype)
 {
 	struct page *page;
+	bool drained = false;
 
 	/* Acquire the OOM killer lock for the zones in zonelist */
 	if (!try_set_zonelist_oom(zonelist, gfp_mask)) {
@@ -1744,6 +1745,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 	}
 
+retry:
 	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
 	 * here, this is only to catch a parallel oom killing, we must fail if
@@ -1773,6 +1775,18 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		if (gfp_mask & __GFP_THISNODE)
 			goto out;
 	}
+
+	/*
+	 * If an allocation failed, it could be because pages are pinned on
+	 * the per-cpu lists. Before resorting to the OOM killer, try
+	 * draining 
+	 */
+	if (!drained) {
+		drain_all_pages();
+		drained = true;
+		goto retry;
+	}
+
 	/* Exhausted what can be done so it's blamo time */
 	out_of_memory(zonelist, gfp_mask, order, nodemask);
 
@@ -1876,10 +1890,13 @@ retry:
 					migratetype);
 
 	/*
-	 * If an allocation failed after direct reclaim, it could be because
-	 * pages are pinned on the per-cpu lists. Drain them and try again
+	 * If a high-order allocation failed after direct reclaim, it could
+	 * be because pages are pinned on the per-cpu lists. However, only
+	 * do it for PAGE_ALLOC_COSTLY_ORDER as the cost of the IPI needed
+	 * to drain the pages is itself high. Assume that lower orders
+	 * will naturally free without draining.
 	 */
-	if (!page && !drained) {
+	if (!page && !drained && order > PAGE_ALLOC_COSTLY_ORDER) {
 		drain_all_pages();
 		drained = true;
 		goto retry;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
