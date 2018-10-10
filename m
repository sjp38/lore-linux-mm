Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C3BB76B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 17:00:59 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id m3-v6so4894790plt.9
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 14:00:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13-v6sor20036577pgm.62.2018.10.10.14.00.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 14:00:58 -0700 (PDT)
Date: Wed, 10 Oct 2018 14:00:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
In-Reply-To: <20181009225147.GD9307@redhat.com>
Message-ID: <alpine.DEB.2.21.1810101328550.231964@chino.kir.corp.google.com>
References: <20180925120326.24392-1-mhocko@kernel.org> <20180925120326.24392-2-mhocko@kernel.org> <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com> <20181005073854.GB6931@suse.de> <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
 <20181005232155.GA2298@redhat.com> <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com> <20181009094825.GC6931@suse.de> <alpine.DEB.2.21.1810091424170.57306@chino.kir.corp.google.com> <20181009225147.GD9307@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 9 Oct 2018, Andrea Arcangeli wrote:

> On Tue, Oct 09, 2018 at 03:17:30PM -0700, David Rientjes wrote:
> > causes workloads to severely regress both in fault and access latency when 
> > we know that direct reclaim is unlikely to make direct compaction free an 
> > entire pageblock.  It's more likely than not that the reclaim was 
> > pointless and the allocation will still fail.
> 
> How do you know that? If all RAM is full of filesystem cache, but it's
> not heavily fragmented by slab or other unmovable objects, compaction
> will succeed every single time after reclaim frees 2M of cache like
> it's asked to do.
> 
> reclaim succeeds every time, compaction then succeeds every time.
> 
> Not doing reclaim after COMPACT_SKIPPED is returned simply makes
> compaction unable to compact memory once all nodes are filled by
> filesystem cache.
> 

For reclaim to assist memory compaction based on compaction's current 
implementation, it would require that the freeing scanner starting at the 
end of the zone can find these reclaimed pages as migration targets and 
that compaction will be able to utilize these migration targets to make an 
entire pageblock free.

In such low on memory conditions when a node is fully saturated, it is 
much less likely that memory compaction can free an entire pageblock even 
if the freeing scanner can find these now-free pages.  More likely is that 
we have unmovable pages in MIGRATE_MOVABLE pageblocks because the 
allocator allows fallback to pageblocks of other migratetypes to return 
node local memory (because affinity matters for kernel memory as it 
matters for thp) rather than fallback to remote memory.

This has caused us significant pain where we have 1.5GB of slab, for 
example, spread over 100GB of pageblocks once the node has become 
saturated.

So reclaim is not always "pointless" as you point out, but it should at 
least only be attempted if memory compaction could free an entire 
pageblock if it had free memory to migrate to.  It's much harder to make 
sure that these freed pages can be utilized by the freeing scanner.  Based 
on how memory compaction is implemented, I do not think any guarantee can 
be made that reclaim will ever be successful in allowing it to make 
order-9 memory available, unfortunately.

> > If memory compaction were patched such that it can report that it could 
> > successfully free a page of the specified order if there were free pages 
> > at the end of the zone it could migrate to, reclaim might be helpful.  But 
> > with the current implementation, I don't think that is reliably possible.  
> > These free pages could easily be skipped over by the migration scanner 
> > because of the presence of slab pages, for example, and unavailable to the 
> > freeing scanner.
> 
> Yes there's one case where reclaim is "pointless", but it happens once
> and then COMPACT_DEFERRED is returned and __GFP_NORETRY will skip
> reclaim then.
> 
> So you're right when we hit fragmentation there's one and only one
> "pointless" reclaim invocation. And immediately after we also
> exponentially backoff on the compaction invocations with the
> compaction deferred logic.
> 

This assumes that every time we get COMPACT_SKIPPED that if we can simply 
free memory that it'll succeed and that's definitely not the case based on 
the implementation of memory compaction: compaction_alloc() needs to find 
the memory and the migration scanner needs to free an entire pageblock.  
The migration scanner doesn't even look ahead to see if that's possible 
before starting to migrate pages, it's limited to COMPACT_CLUSTER_MAX.

The scenario we have: compaction returns COMPACT_SKIPPED; reclaim 
expensively tries to reclaim memory by thrashing the local node; the 
compaction migration scanner has already passed over the now-freed pages 
so it's inaccessible; if accessible, the migration scanner migrates memory 
to the newly freed pages but fails to make a pageblock free; loop.

My contention is that the second step is only justified if we can 
guarantee the freed memory can be useful for compaction and that it can 
free an entire pageblock for the hugepage if it can migrate.  Both of 
those are not possible to determine based on the current implementation.

> > I'd appreciate if Andrea can test this patch, have a rebuttal that we 
> > should still remove __GFP_THISNODE because we don't care about locality as 
> > much as forming a hugepage, we can make that change, and then merge this 
> > instead of causing such massive fault and access latencies.
> 
> I can certainly test, but from source review I'm already convinced
> it'll solve fine the "pathological THP allocation behavior", no
> argument about that. It's certainly better and more correct your patch
> than the current upstream (no security issues with lack of permissions
> for __GFP_THISNODE anymore either).
> 
> I expect your patch will run 100% equivalent to __GFP_COMPACT_ONLY
> alternative I posted, for our testcase that hit into the "pathological
> THP allocation behavior".
> 
> Your patch encodes __GFP_COMPACT_ONLY into the __GFP_NORETRY semantics
> and hardcodes the __GFP_COMPACT_ONLY for all orders = HPAGE_PMD_SIZE
> no matter which is the caller.
> 
> As opposed I let the caller choose and left __GFP_NORETRY semantics
> alone and orthogonal to the __GFP_COMPACT_ONLY semantics. I think
> letting the caller decide instead of hardcoding it for order 9 is
> better, because __GFP_COMPACT_ONLY made sense to be set only if
> __GFP_THISNODE was also set by the caller.
> 

I've hardcoded it directly for pageblock_order because compaction works 
over pageblocks and we lack the two crucial points of information I've 
stated that determines whether direct reclaim could possibly be useful.  
(It's more correctly implemented as order >= pageblock_order as opposed 
to order == pageblock_order.)

> If a driver does an order 9 allocation with __GFP_THISNODE not set,
> your patch will prevent it to allocate remote THP if all remote nodes
> are full of cache (which is a reasonable common assumption as more THP
> are allocated over time eating in all free memory).

Iff it's using __GFP_NORETRY, yes, the allocation and remote access 
latency that is incurred is the same as for thp.  Hugetlbfs doesn't use 
__GFP_NORETRY, it uses __GFP_RETRY_MAYFAIL, so it will attempt to reclaim 
memory after my patch.

My patch is assuming that a single call to reclaim followed up by another 
attempt at compaction is not beneficial for pageblock_order sized 
allocations with __GFP_NORETRY because it's unlikely to either free an 
entire pageblock and compaction may not be able to access this memory.  
It's based on how memory compaction is implemented rather than any special 
heuristic.

I won't argue if you protect this logic with __GFP_COMPACT_ONLY, but I 
think thp allocations should always have __GFP_NORETRY based on 
compaction's implementation.

I see removing __GFP_THISNODE as a separate discussion: if, after my patch 
(perhaps with a modification for __GFP_COMPACT_ONLY on top of it), you 
still get unacceptable fault latency and can show that remote access 
latency to remotely allocated hugepage is better on some platform that 
isn't Haswell, Naples, and Rome, we can address that but it will probably 
require more work that simply unsetting __GFP_THISNODE because it will 
depend on the latency to certain remote nodes over others.
