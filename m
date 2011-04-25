Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 26A938D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 07:09:00 -0400 (EDT)
Date: Mon, 25 Apr 2011 12:08:47 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm/vmalloc: remove block allocation bitmap
Message-ID: <20110425110847.GA4969@csn.ul.ie>
References: <20110414211656.GB1700@cmpxchg.org>
 <20110419093118.GB23041@csn.ul.ie>
 <20110419233905.GA2333@cmpxchg.org>
 <20110420094647.GB1306@csn.ul.ie>
 <20110423020835.GM2333@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110423020835.GM2333@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Apr 23, 2011 at 04:08:35AM +0200, Johannes Weiner wrote:
> On Wed, Apr 20, 2011 at 10:46:47AM +0100, Mel Gorman wrote:
> > On Wed, Apr 20, 2011 at 01:39:05AM +0200, Johannes Weiner wrote:
> > > On Tue, Apr 19, 2011 at 10:31:18AM +0100, Mel Gorman wrote:
> > > > On Thu, Apr 14, 2011 at 05:16:56PM -0400, Johannes Weiner wrote:
> > > > > Space in a vmap block that was once allocated is considered dirty and
> > > > > not made available for allocation again before the whole block is
> > > > > recycled.
> > > > > 
> > > > > The result is that free space within a vmap block is always contiguous
> > > > > and the allocation bitmap can be replaced by remembering the offset of
> > > > > free space in the block.
> > > > > 
> > > > > The fragmented block purging was never invoked from vb_alloc() either,
> > > > > as it skips blocks that do not have enough free space for the
> > > > > allocation in the first place.  According to the above, it is
> > > > > impossible for a block to have enough free space and still fail the
> > > > > allocation.  Thus, this dead code is removed.  Partially consumed
> > > > > blocks will be reclaimed anyway when an attempt is made to allocate a
> > > > > new vmap block altogether and no free space is found.
> > > > > 
> > > > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > > > Cc: Nick Piggin <npiggin@kernel.dk>
> > > > > Cc: Mel Gorman <mel@csn.ul.ie>
> > > > > Cc: Hugh Dickins <hughd@google.com>
> > > > 
> > > > I didn't see a problem with the patch per-se but I wonder if your patch
> > > > is the intended behaviour. It looks like the intention was that dirty
> > > > blocks could be flushed from the TLB and made available for allocations
> > > > leading to the possibility of fragmented vmap blocks.
> > > >
> > > > It's this check that is skipping over blocks without taking dirty into
> > > > account.
> > > > 
> > > >   		spin_lock(&vb->lock);
> > > >  		if (vb->free < 1UL << order)
> > > >  			goto next;
> > > > 
> > > > It was introduced by [02b709d: mm: purge fragmented percpu vmap blocks]
> > > > but is there any possibility that this is what should be fixed instead?
> > > 
> > > I would like to emphasize that the quoted check only made it clear
> > > that the allocation bitmap is superfluous.  There is no partial
> > > recycling of a block with live allocations, not even before this
> > > commit.
> > 
> > You're right in that the allocation bitmap does look superfluous. I was
> > wondering if it was meant to be doing something useful.
> 
> Ok, just wanted to make sure we are on the same page.
> 
> > > Theoretically, we could end up with all possible vmap blocks being
> > > pinned by single allocations with most of their area being dirty and
> > > not reusable.  But I believe this is unlikely to happen.
> > > 
> > > Would you be okay with printing out block usage statistics on
> > > allocation errors for the time being, so we can identify this case if
> > > problems show up?
> > 
> > It'd be interesting but for the purposes of this patch I think it
> > would be more useful to see the results of some benchmark that is vmap
> > intensive. Something directory intensive running on XFS should do the
> > job just to confirm no regression, right? A profile might indicate
> > how often we end up scanning the full list, finding it dirty and
> > calling new_vmap_block but even if something odd showed up there,
> > it would be a new patch.
> 
> Ok, I am still a bit confused.  You say 'regression' in the overall
> flow of vmap block allocation, but my patch does not change that.
> Which kernel versions do you want to have compared?
> 

I should have been clearer. I was checking to see if we spend
much time scanning to find a clean block or allocating new blocks
and if that overhead could be reduced by flushing the TLB sooner
(obvious the savings would have to exceed the cost of the TLB flush
itself). If flushing sooner would help then we want the alloc bitmap
to hang around.

> Profiling the algorithm in general sounds like a good idea and I shall
> give it a go.
> 
> > > And consider this patch an optimization/simplification of a status quo
> > > that does not appear problematic?  We can still revert it and
> > > implement live block recycling when it turns out to be necessary.
> > 
> > I see no problem with your patch so;
> > 
> > Acked-by: Mel Gorman <mel@csn.ul.ie>
> 
> Thanks!
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
