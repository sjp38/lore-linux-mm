Date: Thu, 14 Feb 2008 12:14:27 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 4/5] slub: Use __GFP_MOVABLE for slabs of HPAGE_SIZE
In-Reply-To: <20080214200849.GB30841@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0802141209470.1041@schroedinger.engr.sgi.com>
References: <20080214040245.915842795@sgi.com> <20080214040314.118141086@sgi.com>
 <20080214141442.GF17641@csn.ul.ie> <Pine.LNX.4.64.0802141110280.32613@schroedinger.engr.sgi.com>
 <20080214200849.GB30841@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008, Mel Gorman wrote:

> > Doesnt it mean that the allocations can occur in MAX_ORDER blocks 
> > marked MOVABLE?
> 
> Blocks aren't MAX_ORDER in size, they are pageblock_order in size and that
> value can be thought of as HUGETLB_PAGE_ORDER. No matter what you mark them
> as, it is still one pageblock. If you leave them as RECLAIMABLE or UNMOVABLE,
> a MOVABLE block may still get reclaimed and given to slab instead without
> this patch. Marking them movable when no partition exists gains nothing at all.

Ok so order 9 allocs of slub could occur in pageblock_order blocks like 
what happens for huge pages today. AFAICT this makes the handling of 
slab pages consistent with huge pages?

> > echo 2 >/proc/sys/vm/drop_cache will usually allow a significant shrinkage
> > of the slab caches. In many ways it is the same.
> > 
> 
> Except it doesn't work for all slabs. As part of the highorder allocation
> stress tests I run, a final part is allocating pages when no other process is
> running and /proc/sys/vm/drop_cache has been used. There are still remaining
> pages left in odd places.

Nor does it work for huge pages which cannot be moved but they are marked 
__GFP_MOVABLE anyways.

> > This is a feature enabled by a special command line boot option. So its 
> > something that the admin did *intentionally*.
> 
> Not quite. What he asked for is that slub_min_order=HUGE_PAGESIZE, not
> slub_use_zone_movable. In a situation where they wanted to have a hugepage
> pool that reliably resized and slub_min_order == HUGE_PAGESIZE, he would
> find that they collide for no obvious reason.

Hmm.... So they would use the size of the movable area to size the hugetlb 
area? 

> > A system with huge amounts of memory has a large amount of huge 
> > pages. It is typically at this point to have 4G per cpu in a system and we 
> > may go higher. 4G means up to 2048 huge pages per cpu! Huge page 
> > allocation will be quite common and its good to reduce page allocator 
> > overhead.
> Marking them movable makes no difference to that assertion.

Hmmmm... Okay if pages are managed in pageblock_size chunks that are of 
HUGE_PAGE_SIZE then this patch makes no difference whatsoever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
