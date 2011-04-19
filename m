Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C015D8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 19:39:32 -0400 (EDT)
Date: Wed, 20 Apr 2011 01:39:05 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm/vmalloc: remove block allocation bitmap
Message-ID: <20110419233905.GA2333@cmpxchg.org>
References: <20110414211656.GB1700@cmpxchg.org>
 <20110419093118.GB23041@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419093118.GB23041@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 19, 2011 at 10:31:18AM +0100, Mel Gorman wrote:
> On Thu, Apr 14, 2011 at 05:16:56PM -0400, Johannes Weiner wrote:
> > Space in a vmap block that was once allocated is considered dirty and
> > not made available for allocation again before the whole block is
> > recycled.
> > 
> > The result is that free space within a vmap block is always contiguous
> > and the allocation bitmap can be replaced by remembering the offset of
> > free space in the block.
> > 
> > The fragmented block purging was never invoked from vb_alloc() either,
> > as it skips blocks that do not have enough free space for the
> > allocation in the first place.  According to the above, it is
> > impossible for a block to have enough free space and still fail the
> > allocation.  Thus, this dead code is removed.  Partially consumed
> > blocks will be reclaimed anyway when an attempt is made to allocate a
> > new vmap block altogether and no free space is found.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Nick Piggin <npiggin@kernel.dk>
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Cc: Hugh Dickins <hughd@google.com>
> 
> I didn't see a problem with the patch per-se but I wonder if your patch
> is the intended behaviour. It looks like the intention was that dirty
> blocks could be flushed from the TLB and made available for allocations
> leading to the possibility of fragmented vmap blocks.
>
> It's this check that is skipping over blocks without taking dirty into
> account.
> 
>   		spin_lock(&vb->lock);
>  		if (vb->free < 1UL << order)
>  			goto next;
> 
> It was introduced by [02b709d: mm: purge fragmented percpu vmap blocks]
> but is there any possibility that this is what should be fixed instead?

I would like to emphasize that the quoted check only made it clear
that the allocation bitmap is superfluous.  There is no partial
recycling of a block with live allocations, not even before this
commit.

> Do we know what the consequences of blocks only getting flushed when
> they have been fully allocated are?

Note that it can get recycled earlier if there is no outstanding
allocation on it, even if only a small amount of it is dirty (the
purge_fragmented_blocks code does this).

A single outstanding allocation prevents the block from being
recycled, blocking the reuse of the dirty area.

Theoretically, we could end up with all possible vmap blocks being
pinned by single allocations with most of their area being dirty and
not reusable.  But I believe this is unlikely to happen.

Would you be okay with printing out block usage statistics on
allocation errors for the time being, so we can identify this case if
problems show up?

And consider this patch an optimization/simplification of a status quo
that does not appear problematic?  We can still revert it and
implement live block recycling when it turns out to be necessary.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
