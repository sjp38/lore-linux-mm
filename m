Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9599E8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 07:18:27 -0400 (EDT)
Date: Tue, 19 Apr 2011 10:31:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm/vmalloc: remove block allocation bitmap
Message-ID: <20110419093118.GB23041@csn.ul.ie>
References: <20110414211656.GB1700@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110414211656.GB1700@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 14, 2011 at 05:16:56PM -0400, Johannes Weiner wrote:
> Space in a vmap block that was once allocated is considered dirty and
> not made available for allocation again before the whole block is
> recycled.
> 
> The result is that free space within a vmap block is always contiguous
> and the allocation bitmap can be replaced by remembering the offset of
> free space in the block.
> 
> The fragmented block purging was never invoked from vb_alloc() either,
> as it skips blocks that do not have enough free space for the
> allocation in the first place.  According to the above, it is
> impossible for a block to have enough free space and still fail the
> allocation.  Thus, this dead code is removed.  Partially consumed
> blocks will be reclaimed anyway when an attempt is made to allocate a
> new vmap block altogether and no free space is found.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Hugh Dickins <hughd@google.com>

I didn't see a problem with the patch per-se but I wonder if your patch
is the intended behaviour. It looks like the intention was that dirty
blocks could be flushed from the TLB and made available for allocations
leading to the possibility of fragmented vmap blocks.

It's this check that is skipping over blocks without taking dirty into
account.

  		spin_lock(&vb->lock);
 		if (vb->free < 1UL << order)
 			goto next;

It was introduced by [02b709d: mm: purge fragmented percpu vmap blocks]
but is there any possibility that this is what should be fixed instead?
Do we know what the consequences of blocks only getting flushed when
they have been fully allocated are?

> <SNIP>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
