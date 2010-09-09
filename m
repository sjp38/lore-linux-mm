Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 781186B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 08:41:54 -0400 (EDT)
Date: Thu, 9 Sep 2010 13:41:38 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
	direct reclaim allocation fails
Message-ID: <20100909124138.GQ29263@csn.ul.ie>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie> <1283504926-2120-4-git-send-email-mel@csn.ul.ie> <20100908163956.C930.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100908163956.C930.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 08, 2010 at 04:43:03PM +0900, KOSAKI Motohiro wrote:
> > +	/*
> > +	 * If an allocation failed after direct reclaim, it could be because
> > +	 * pages are pinned on the per-cpu lists. Drain them and try again
> > +	 */
> > +	if (!page && !drained) {
> > +		drain_all_pages();
> > +		drained = true;
> > +		goto retry;
> > +	}
> 
> nit: when slub, get_page_from_freelist() failure is frequently happen
> than slab because slub try to allocate high order page at first.
> So, I guess we have to avoid drain_all_pages() if __GFP_NORETRY is passed.
> 

Old behaviour was for high-order allocations which one would assume did
not have __GFP_NORETRY specified except in very rare cases. Still, calling
drain_all_pages() raises interrupt counts and I worried that large machines
might exhibit some livelock-like problem. I'm considering the following patch,
what do you think?

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
