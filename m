Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id A38816B0037
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 11:51:22 -0400 (EDT)
Date: Thu, 1 Aug 2013 17:51:11 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130801155111.GO25926@redhat.com>
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org>
 <1374267325-22865-4-git-send-email-hannes@cmpxchg.org>
 <20130801025636.GC19540@bbox>
 <51F9E4A6.2090909@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F9E4A6.2090909@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 01, 2013 at 12:31:34AM -0400, Rik van Riel wrote:
> On 07/31/2013 10:56 PM, Minchan Kim wrote:
> 
> > Yes, it's not really slow path because it could return to normal status
> > without calling significant slow functions by reset batchcount of
> > prepare_slowpath.
> >
> > I think it's tradeoff and I am biased your approach although we would
> > lose a little performance because fair aging would recover the loss by
> > fastpath's overhead. But who knows? Someone has a concern.
> >
> > So we should mention about such problems.
> 
> If the atomic operation in the fast path turns out to be a problem,
> I suspect we may be able to fix it by using per-cpu counters, and
> consolidating those every once in a while.
> 
> However, it may be good to see whether there is a problem in the
> first place, before adding complexity.

prepare_slowpath is racy anyway, so I don't see the point in wanting
to do atomic ops in the first place.

Much better to do the increment in assembly in a single insn to reduce
the window, but there's no point in using the lock prefix when
atomic_set will screw it over while somebody does atomic_dec under it
anyway. atomic_set cannot be atomic, so it'll screw over any
perfectly accurate accounted atomic_dec anyway.

I think it should be done in C without atomic_dec or by introducing an
__atomic_dec that isn't using the lock prefix and just tries to do the
dec in a single (or as few as possible) asm insn.

And because the whole thing is racy, after prepare_slowpath (which I
think is a too generic name and should be renamed
reset_zonelist_alloc_batch), this last attempt before invoking
reclaim:

	/* This is the last chance, in general, before the goto nopage. */
	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
			preferred_zone, migratetype);

which is trying again with the MIN wmark, should be also altered so
that we do one pass totally disregarding alloc_batch, just before
declaring MIN-wmark failure in the allocation, and invoking direct
reclaim.

Either we add a (alloc_flags | ALLOC_NO_ALLOC_BATCH) to the above
alloc_flags in the above call, or we run a second
get_page_from_freelist if the above one fails with
ALLOC_NO_ALLOC_BATCH set.

Otherwise because of the inherent racy behavior of the alloc_batch
logic, what will happen is that we'll eventually have enough hugepage
allocations in enough CPUs to hit the alloc_batch limit again in
between the prepare_slowpath and the above get_page_from_freelist,
that will lead us to call spurious direct_reclaim invocations, when it
was just a false negative of alloc_batch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
