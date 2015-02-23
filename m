Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 93F256B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 02:32:42 -0500 (EST)
Received: by padhz1 with SMTP id hz1so25423718pad.9
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 23:32:42 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id sy7si6452872pbc.64.2015.02.22.23.32.39
        for <linux-mm@kvack.org>;
        Sun, 22 Feb 2015 23:32:41 -0800 (PST)
Date: Mon, 23 Feb 2015 18:32:35 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150223073235.GT4251@dastard>
References: <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150222172930.6586516d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Sun, Feb 22, 2015 at 05:29:30PM -0800, Andrew Morton wrote:
> On Mon, 23 Feb 2015 11:45:21 +1100 Dave Chinner <david@fromorbit.com> wrote:
> 
> > > > I really don't care about the OOM Killer corner cases - it's
> > > > completely the wrong way line of development to be spending time on
> > > > and you aren't going to convince me otherwise. The OOM killer a
> > > > crutch used to justify having a memory allocation subsystem that
> > > > can't provide forward progress guarantee mechanisms to callers that
> > > > need it.
> > > 
> > > We can provide this.  Are all these callers able to preallocate?
> > 
> > Anything that allocates in transaction context (and therefor is
> > GFP_NOFS by definition) can preallocate at transaction reservation
> > time. However, preallocation is dumb, complex, CPU and memory
> > intensive and will have a *massive* impact on performance.
> > Allocating 10-100 pages to a reserve which we will almost *never
> > use* and then free them again *on every single transaction* is a lot
> > of unnecessary additional fast path overhead.  Hence a "preallocate
> > for every context" reserve pool is not a viable solution.
> 
> Yup.
> 
> > Reservations are simply an *accounting* of the maximum amount of a
> > reserve required by an operation to guarantee forwards progress. In
> > filesystems, we do this for log space (transactions) and some do it
> > for filesystem space (e.g. delayed allocation needs correct ENOSPC
> > detection so we don't overcommit disk space).  The VM already has
> > such concepts (e.g. watermarks and things like min_free_kbytes) that
> > it uses to ensure that there are sufficient reserves for certain
> > types of allocations to succeed.
> 
> Yes, as we do for __GFP_HIGH and PF_MEMALLOC etc.  Add a dynamic
> reserve.  So to reserve N pages we increase the page allocator dynamic
> reserve by N, do some reclaim if necessary then deposit N tokens into
> the caller's task_struct (it'll be a set of zone/nr-pages tuples I
> suppose).
> 
> When allocating pages the caller should drain its reserves in
> preference to dipping into the regular freelist.  This guy has already
> done his reclaim and shouldn't be penalised a second time.  I guess
> Johannes's preallocation code should switch to doing this for the same
> reason, plus the fact that snipping a page off
> task_struct.prealloc_pages is super-fast and needs to be done sometime
> anyway so why not do it by default.

That is at odds with the requirements of demand paging, which
allocate for objects that are reclaimable within the course of the
transaction. The reserve is there to ensure forward progress for
allocations for objects that aren't freed until after the
transaction completes, but if we drain it for reclaimable objects we
then have nothing left in the reserve pool when we actually need it.

We do not know ahead of time if the object we are allocating is
going to modified and hence locked into the transaction. Hence we
can't say "use the reserve for this *specific* allocation", and so
the only guidance we can really give is "we will to allocate and
*permanently consume* this much memory", and the reserve pool needs
to cover that consumption to guarantee forwards progress.

Forwards progress for all other allocations is guaranteed because
they are reclaimable objects - they either freed directly back to
their source (slab, heap, page lists) or they are freed by shrinkers
once they have been released from the transaction.

Hence we need allocations to come from the free list and trigger
reclaim, regardless of the fact there is a reserve pool there. The
reserve pool needs to be a last resort once there are no other
avenues to allocate memory. i.e. it would be used to replace the OOM
killer for GFP_NOFAIL allocations.

> Both reservation and preallocation are vulnerable to deadlocks - 10,000
> tasks all trying to reserve/prealloc 100 pages, they all have 50 pages
> and we ran out of memory.  Whoops.

Yes, that's the big problem with preallocation, as well as your
proposed "depelete the reserved memory first" approach. They
*require* up front "preallocation" of free memory, either directly
by the application, or internally by the mm subsystem.

Hence my comments about appropriate classification of "reserved
memory". Reserved memory does not necessarily need to be on the free
list. It could be "immediately reclaimable" memory, so that
reserving memory doesn't need to immediately reclaim memory, but can
it can be pulled from the reclaimable memory reserves when
memory pressure occurs. If there is no memory pressure, we do
nothing beause we have no need to do anything....

> We can undeadlock by returning ENOMEM but I suspect there will
> still be problematic situations where massive numbers of pages are
> temporarily AWOL.  Perhaps some form of queuing and throttling
> will be needed,

Yes, think that is necessary, but I don't see it as necessary in the
MM subsystem. XFS already has a ticket-based queue mechanisms for
throttling concurrent access to ensure we don't overcommit log space
and I'd want to tie the two together...

> to limit the peak number of reserved pages.  Per
> zone, I guess.

Internal implementation issue that I don't really care about.
When it comes to guaranteeing memory allocation, global context
is all I care about. Locality of allocation simple doesn't matter;
we want that page we reserved, no matter wher eit is located.

> And it'll be a huge pain handling order>0 pages.  I'd be inclined
> to make it order-0 only, and tell the lamer callers that
> vmap-is-thattaway.  Alas, one lame caller is slub.

Sure, but vmap requires GFP_KERNEL memory allocation and we're
talking about allocation in transactions, which are GFP_NOFS.

I've lost count of the number of times we've asked for that problem
to be fixed. Refusing to fix it has simply lead to the growing use
of ugly hacks around that problem (i.e. memalloc_noio_save() and
friends).

> But the biggest issue is how the heck does a caller work out how
> many pages to reserve/prealloc?  Even a single sb_bread() - it's
> sitting on loop on a sparse NTFS file on loop on a five-deep DM
> stack on a six-deep MD stack on loop on NFS on an eleventy-deep
> networking stack. 

Each subsystem needs to take care of itself first, then we can worry
about esoteric stacking requirements.

Besides, stacking requirements through the IO layer is still pretty
trivial - we only need to guarantee single IO progress from the
highest layer as it can be recycled again and again for every IO
that needs to be done.

And, because mempools already give that guarantee to most block
devices and drivers, we won't need to reserve memory for most block
devices to make forwards progress. It's only crazy "recurse through
filesystem" configurations where this will be an issue.

> And then there will be an unknown number of
> slab allocations of unknown size with unknown slabs-per-page rules
> - how many pages needed for them?

However many pages needed to allocate the number of objects we'll
consume from the slab.

> And to make it much worse, how
> many pages of which orders?  Bless its heart, slub will go and use
> a 1-order page for allocations which should have been in 0-order
> pages..

The majority of allocations will be order-0, though if we know that
they are going to be significant numbers of high order allocations,
then it should be simple enough to tell the mm subsystem "need a
reserve of 32 order-0, 4 order-1 and 1 order-3 allocations" and have
memory compaction just do it's stuff. But, IMO, we should cross that
bridge when somebody actually needs reservations to be that
specific....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
