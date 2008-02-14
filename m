Date: Thu, 14 Feb 2008 20:25:30 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 4/5] slub: Use __GFP_MOVABLE for slabs of HPAGE_SIZE
Message-ID: <20080214202530.GD30841@csn.ul.ie>
References: <20080214040245.915842795@sgi.com> <20080214040314.118141086@sgi.com> <20080214141442.GF17641@csn.ul.ie> <Pine.LNX.4.64.0802141110280.32613@schroedinger.engr.sgi.com> <20080214200849.GB30841@csn.ul.ie> <Pine.LNX.4.64.0802141209470.1041@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802141209470.1041@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (14/02/08 12:14), Christoph Lameter didst pronounce:
> On Thu, 14 Feb 2008, Mel Gorman wrote:
> 
> > > Doesnt it mean that the allocations can occur in MAX_ORDER blocks 
> > > marked MOVABLE?
> > 
> > Blocks aren't MAX_ORDER in size, they are pageblock_order in size and that
> > value can be thought of as HUGETLB_PAGE_ORDER. No matter what you mark them
> > as, it is still one pageblock. If you leave them as RECLAIMABLE or UNMOVABLE,
> > a MOVABLE block may still get reclaimed and given to slab instead without
> > this patch. Marking them movable when no partition exists gains nothing at all.
> 
> Ok so order 9 allocs of slub could occur in pageblock_order blocks like 
> what happens for huge pages today. AFAICT this makes the handling of 
> slab pages consistent with huge pages?
> 

No. Huge pages are not marked MOVABLE unless it is specifically requested
for the situation where the partition is being used to guarantee the hugepage
pool can grow to that size.

        if (hugepages_treat_as_movable)
                htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
        else
                htlb_alloc_mask = GFP_HIGHUSER;

> > > echo 2 >/proc/sys/vm/drop_cache will usually allow a significant shrinkage
> > > of the slab caches. In many ways it is the same.
> > > 
> > 
> > Except it doesn't work for all slabs. As part of the highorder allocation
> > stress tests I run, a final part is allocating pages when no other process is
> > running and /proc/sys/vm/drop_cache has been used. There are still remaining
> > pages left in odd places.
> 
> Nor does it work for huge pages which cannot be moved but they are marked 
> __GFP_MOVABLE anyways.
> 

They are marked when it is specifically requested.

> > > This is a feature enabled by a special command line boot option. So its 
> > > something that the admin did *intentionally*.
> > 
> > Not quite. What he asked for is that slub_min_order=HUGE_PAGESIZE, not
> > slub_use_zone_movable. In a situation where they wanted to have a hugepage
> > pool that reliably resized and slub_min_order == HUGE_PAGESIZE, he would
> > find that they collide for no obvious reason.
> 
> Hmm.... So they would use the size of the movable area to size the hugetlb 
> area? 
> 

I'm not sure what you mean by that question. The situation is simple;

If an administrator knows that they need to have a pool of 200 huge pages
at some unknown time in the future, he can say movablecore=N (where N ==
200 hugepages worth of bytes) and set hugepages_treat_as_movable and they
can be reasonable sure it'll work (mlock being the obvious problem as memory
compaction was not merged)

If you wanted to have something similar available for SLUB for some reason,
then the parameter should be similarly named and obvious.

> > > A system with huge amounts of memory has a large amount of huge 
> > > pages. It is typically at this point to have 4G per cpu in a system and we 
> > > may go higher. 4G means up to 2048 huge pages per cpu! Huge page 
> > > allocation will be quite common and its good to reduce page allocator 
> > > overhead.
> > Marking them movable makes no difference to that assertion.
> 
> Hmmmm... Okay if pages are managed in pageblock_size chunks that are of 
> HUGE_PAGE_SIZE then this patch makes no difference whatsoever.
> 

Yes it does - it means that slub pages can be allocated from the movablecore=
partition if slub_min_order is set to a magic value. What it does not do at
all is help SLUB in a meaningful fashion.

Still NACK.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
