Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A0E5A6B007E
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 05:47:33 -0500 (EST)
Date: Fri, 12 Mar 2010 10:47:12 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone
	pressure
Message-ID: <20100312104712.GB18274@csn.ul.ie>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie> <20100311154124.e1e23900.akpm@linux-foundation.org> <4B99E19E.6070301@linux.vnet.ibm.com> <20100312020526.d424f2a8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100312020526.d424f2a8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 12, 2010 at 02:05:26AM -0500, Andrew Morton wrote:
> On Fri, 12 Mar 2010 07:39:26 +0100 Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com> wrote:
> 
> > 
> > 
> > Andrew Morton wrote:
> > > On Mon,  8 Mar 2010 11:48:20 +0000
> > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > >> Under memory pressure, the page allocator and kswapd can go to sleep using
> > >> congestion_wait(). In two of these cases, it may not be the appropriate
> > >> action as congestion may not be the problem.
> > > 
> > > clear_bdi_congested() is called each time a write completes and the
> > > queue is below the congestion threshold.
> > > 
> > > So if the page allocator or kswapd call congestion_wait() against a
> > > non-congested queue, they'll wake up on the very next write completion.
> > 
> > Well the issue came up in all kind of loads where you don't have any 
> > writes at all that can wake up congestion_wait.
> > Thats true for several benchmarks, but also real workload as well e.g. A 
> > backup job reading almost all files sequentially and pumping out stuff 
> > via network.
> 
> Why is reclaim going into congestion_wait() at all if there's heaps of
> clean reclaimable pagecache lying around?
> 
> (I don't thing the read side of the congestion_wqh[] has ever been used, btw)
> 

I believe it's a race albeit one that has been there a long time.

In __alloc_pages_direct_reclaim, a process does approximately the
following

1. Enters direct reclaim
2. Calls cond_reched()
3. Drain pages if necessary
4. Attempt to allocate a page

Between steps 2 and 3, it's possible to have reclaimed the pages but
another process allocate them. It then proceeds and decides try again
but calls congestion_wait() before it loops around.

Plenty of read cache reclaimed but no forward progress.

> > > Hence the above-quoted claim seems to me to be a significant mis-analysis and
> > > perhaps explains why the patchset didn't seem to help anything?
> > 
> > While I might have misunderstood you and it is a mis-analysis in your 
> > opinion, it fixes a -80% Throughput regression on sequential read 
> > workloads, thats not nothing - its more like absolutely required :-)
> > 
> > You might check out the discussion with the subject "Performance 
> > regression in scsi sequential throughput (iozone)	due to "e084b - 
> > page-allocator: preserve PFN ordering when	__GFP_COLD is set"".
> > While the original subject is misleading from todays point of view, it 
> > contains a lengthy discussion about exactly when/why/where time is lost 
> > due to congestion wait with a lot of traces, counters, data attachments 
> > and such stuff.
> 
> Well if we're not encountering lots of dirty pages in reclaim then we
> shouldn't be waiting for writes to retire, of course.
> 
> But if we're not encountering lots of dirty pages in reclaim, we should
> be reclaiming pages, normally.
> 

We probably are.

> I could understand reclaim accidentally going into congestion_wait() if
> it hit a large pile of pages which are unreclaimable for reasons other
> than being dirty, but is that happening in this case?
> 

Probably not. It's almost certainly the race I described above.

> If not, we broke it again.
> 

We were broken with respect to this in the first place. That
cond_reched() is badly placed and waiting on congestion when congestion
might not be involved is also a bit odd.

It's possible that Christian's specific problem would also be addressed
by the following patch. Christian, willing to test?

It still feels a bit unnatural though that the page allocator waits on
congestion when what it really cares about is watermarks. Even if this
patch works for Christian, I think it still has merit so will kick it a
few more times.

==== CUT HERE ====
page-allocator: Attempt page allocation immediately after direct reclaim

After a process completes direct reclaim it calls cond_resched() as
potentially it has been running a long time. When it wakes up, it
attempts to allocate a page. There is a large window during which
another process can allocate the pages reclaimed by direct reclaim. This
patch attempts to allocate a page immediately after direct reclaim but
will still go to sleep afterwards if its quantum has expired.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a8182c8..973b7fc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1721,8 +1721,6 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	lockdep_clear_current_reclaim_state();
 	p->flags &= ~PF_MEMALLOC;
 
-	cond_resched();
-
 	if (order != 0)
 		drain_all_pages();
 
@@ -1731,6 +1729,9 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 					zonelist, high_zoneidx,
 					alloc_flags, preferred_zone,
 					migratetype);
+
+	cond_resched();
+
 	return page;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
