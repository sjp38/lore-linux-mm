Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 228146B0072
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 12:12:18 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id a1so1934669wgh.10
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 09:12:17 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id n9si3351465eey.98.2014.02.26.09.12.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 09:12:15 -0800 (PST)
Date: Wed, 26 Feb 2014 12:12:06 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] mm: page_alloc: reset aging cycle with GFP_THISNODE
Message-ID: <20140226171206.GU6963@cmpxchg.org>
References: <1393360022-22566-1-git-send-email-hannes@cmpxchg.org>
 <20140226095422.GY6732@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140226095422.GY6732@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Stancek <jstancek@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 26, 2014 at 09:54:22AM +0000, Mel Gorman wrote:
> On Tue, Feb 25, 2014 at 03:27:01PM -0500, Johannes Weiner wrote:
> > Jan Stancek reports manual page migration encountering allocation
> > failures after some pages when there is still plenty of memory free,
> > and bisected the problem down to 81c0a2bb515f ("mm: page_alloc: fair
> > zone allocator policy").
> > 
> > The problem is that page migration uses GFP_THISNODE and this makes
> > the page allocator bail out before entering the slowpath entirely,
> > without resetting the zone round-robin batches.  A string of such
> > allocations will fail long before the node's free memory is exhausted.
> > 
> > GFP_THISNODE is a special flag for callsites that implement their own
> > clever node fallback and so no direct reclaim should be invoked.  But
> > if the allocations fail, the fair allocation batches should still be
> > reset, and if the node is full, it should be aged in the background.
> > 
> > Make GFP_THISNODE wake up kswapd and reset the zone batches, but bail
> > out before entering direct reclaim to not stall the allocating task.
> > 
> > Reported-by: Jan Stancek <jstancek@redhat.com>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: <stable@kernel.org> # 3.12+
> > ---
> >  mm/page_alloc.c | 24 ++++++++++++------------
> >  1 file changed, 12 insertions(+), 12 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index e3758a09a009..b92f66e78ec1 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2493,18 +2493,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		return NULL;
> >  	}
> >  
> > -	/*
> > -	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
> > -	 * __GFP_NOWARN set) should not cause reclaim since the subsystem
> > -	 * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim
> > -	 * using a larger set of nodes after it has established that the
> > -	 * allowed per node queues are empty and that nodes are
> > -	 * over allocated.
> > -	 */
> 
> By moving this past prepare_slowpath, the comment is no longer accurate.
> It says it "should not cause reclaim" but a consequence of this patch is
> that we wake kswapd if the allocation failed due to memory exhaustion and
> attempt an allocation at a different watermark.  Your changelog calls this
> out the kswapd part but it's actually a pretty significant change to do
> as part of this bug fix. kswapd potentially reclaims within a node when
> the caller was potentially happy to retry on remote nodes without reclaiming.
> 
> The bug report states that "manual page migration encountering allocation
> failures after some pages when there is still plenty of memory free". Plenty
> of memory was free, yet with this patch applied we will attempt to wake
> kswapd. Granted, the zone_balanced() check should prevent kswapd being
> actually woken up but it's wasteful.

Yes, slab has its own fallback implementation and is willing to
sacrifice some locality for allocation latency, but once the fallbacks
are exhausted it will also have to enter reclaim.  By waking kswapd in
this case, future fallbacks can be prevented and allocation latency
reduced.  Not just for slab allocations, but for all order-0 requests.
And at near-nil cost to the allocating task.

Most other allocations will wake kswapd anyway, this report came from
a testcase that didn't run anything else on the machine.  The current
behavior seems more like an implementation glitch in this special
case, rather than intentional design.

> How about special casing the (alloc_flags & ALLOC_WMARK_LOW) check in
> get_page_from_freelist to also ignore GFP_THISNODE? The NR_ALLOC_BATCH
> will go further negative if there are storms of GFP_THISNODE allocations
> forcing other allocations into the slow path doing multiple calls to
> prepare_slowpath but it would be closer to current behaviour and avoid
> weirdness with kswapd.

I think the result would be much uglier.  The allocations wouldn't
participate in the fairness protocol, and they'd create work for
kswapd without waking it up, diminishing the latency reduction for
which we have kswapd in the first place.

If kswapd wakeups should be too aggressive, I'd rather we ratelimit
them in some way rather than exempting random order-0 allocation types
as a moderation measure.  Exempting higher order wakeups, like THP
does is one thing, but we want order-0 watermarks to be met at all
times anyway, so it would make sense to me to nudge kswapd for every
failing order-0 request.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
