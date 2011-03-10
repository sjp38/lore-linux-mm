Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BF4068D003B
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 05:11:41 -0500 (EST)
Date: Thu, 10 Mar 2011 10:11:08 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] remove compaction from kswapd
Message-ID: <20110310101107.GA32302@csn.ul.ie>
References: <AANLkTingkWo6dx=0sGdmz9qNp+_TrQnKXnmASwD8LhV4@mail.gmail.com> <20110301223954.GI19057@random.random> <AANLkTim7tcPTxG9hyFiSnQ7rqfMdoUhL1wrmqNAXAvEK@mail.gmail.com> <20110301164143.e44e5699.akpm@linux-foundation.org> <20110302043856.GB23911@random.random> <20110301205324.f0daaf86.akpm@linux-foundation.org> <20110302055221.GD23911@random.random> <20110302142542.GE14162@csn.ul.ie> <20110309141718.93db5ea5.akpm@linux-foundation.org> <20110309235040.GJ2141@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110309235040.GJ2141@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, stable@kernel.org

On Thu, Mar 10, 2011 at 12:50:40AM +0100, Andrea Arcangeli wrote:
> Hi Andrew,
> 
> On Wed, Mar 09, 2011 at 02:17:18PM -0800, Andrew Morton wrote:
> > On Wed, 2 Mar 2011 14:25:42 +0000
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > mm: compaction: Prevent kswapd compacting memory to reduce CPU usage
> > > 
> > > This patch reverts [5a03b051: thp: use compaction in kswapd for GFP_ATOMIC
> > > order > 0] due to reports stating that kswapd CPU usage was higher
> > > and IRQs were being disabled more frequently. This was reported at
> > > http://www.spinics.net/linux/fedora/alsa-user/msg09885.html .
> > 
> > OK, I grabbed this.
> > 
> > I made a number of changelog changes:
> > 
> > - Rewrote it as From: Andrea (correct?)
> > 
> > - Replaced your acked-by with signed-off-by, as you were on the
> >   delivery path
> > 
> > - Hunted down Arthur's email address and added his reported-by and
> >   tested-by.
> 
> So far so good.
> 
> > - Added cc:stable, as it's a bit late for 2.6.38.  The intention
> >   being that we put this into 2.6.38.1 after it has cooked in 2.6.39-rcX
> >   for a while.  OK?
> 
> That's ok with me. It's unfortunate the only two workloads that
> triggers this weren't trivial setups and it was found after quite some
> time after being introduced (if it was obvious for all workloads, it
> wouldn't have gotten there after all, but this also makes it no big
> deal if this is only applied in 2.6.38.1 for the same reason).
> 
> I think the fundamental issue with compaction is that its searches are
> not SWAP_CLUSTER_MAX things, but it goes all the way through the zone
> from top to bottom and bottom to top, until the two scans meet in the
> middle.

Not necessary but yes, it can happen if it's a full compaction triggered
from /proc or because it failed to free up a a page of a suitable size which
kswapd could be hitting on a semi-regular basis. The exit conditions are
controlled by compact_finished() and could be improved upon.

> So invoking it just once for allocation in direct compaction
> (during alloc_pages slow path) is enough. Keeping invoking it in
> kswapd (even if at lower rate with my last patch as an attempt to fix
> it without removing compaction from kswapd) is probably being
> overkill. Maybe kswapd should have a comapction "incremental" mode
> that does a SWAP_CLUSTER_MAX thing. Maybe we shouldn't do it from
> kswapd either.
> 

In the ideal case, direct compaction is short in duration because it only
compacts as much as necessary to satisfy the allocation. That said, you're
right in that incremental compaction from kswapd may be better than what it
currently does - i.e. compacting a little but keeping the compact_control
structure around to be reused in the future.

In many respects the hardest part of this is deciding when compaction is
really a help and when its a hindrance :/.

> We clearly we need a bit more time to sort this out, and in the
> meantime returning to the 2.6.37 logic in kswapd of 2.6.38.1 is good
> idea and safe.
> 
> As opposed we could retain commit
> c5a73c3d55be1faadba35b41a862e036a3b12ddb introduced together with the
> problematic commit. Commit c5a73c3d55be1faadba35b41a862e036a3b12ddb
> should help with the kernel stack allocation during high VM pressure,
> without apparently hurting anything. That is somewhat safer than the
> kswapd part because it doesn't affect kswapd globally but just the
> thread allocating and it's surely not going to insist much invoking
> compaction in the background.
> 

It should help and it's somewhere on the todo list to see if it really
makes a measurable difference. Recording allocation latency is trivial,
setting up a realistic situation that is both fork heavy and under VM
load is less so.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
