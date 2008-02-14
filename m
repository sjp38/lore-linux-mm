Date: Thu, 14 Feb 2008 20:08:50 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 4/5] slub: Use __GFP_MOVABLE for slabs of HPAGE_SIZE
Message-ID: <20080214200849.GB30841@csn.ul.ie>
References: <20080214040245.915842795@sgi.com> <20080214040314.118141086@sgi.com> <20080214141442.GF17641@csn.ul.ie> <Pine.LNX.4.64.0802141110280.32613@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802141110280.32613@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (14/02/08 11:18), Christoph Lameter didst pronounce:
> On Thu, 14 Feb 2008, Mel Gorman wrote:
> 
> > The only reason to have an allocation like this set as MOVABLE is so it can
> > make use of the partition created by movablecore= which has a few specific
> > purposes. One of them is that on a shared system, a partition can be created
> > that is of the same size as the largest hugepage pool required for any job. As
> > jobs run, they can grow or shrink the pool as desired.  When the jobs complete,
> > the hugepages are no longer in use and the partition becomes essentially free.
> 
> Doesnt it mean that the allocations can occur in MAX_ORDER blocks 
> marked MOVABLE?

Blocks aren't MAX_ORDER in size, they are pageblock_order in size and that
value can be thought of as HUGETLB_PAGE_ORDER. No matter what you mark them
as, it is still one pageblock. If you leave them as RECLAIMABLE or UNMOVABLE,
a MOVABLE block may still get reclaimed and given to slab instead without
this patch. Marking them movable when no partition exists gains nothing at all.

> I thought movablecore= is no longer necessary after the 
> rest of the antifrag stuff was merged?
> 

It's still used. movablecore= provides guarantees on how many movable blocks
will exist and what size the huge page pool can be guaranteeed to be resized
to. It would be used in a situation where a workload was found to fragment
memory or in situations where the guarantee must be mode but the administrator
still needs to be able to get that memory as small pages if necessary.

I wrote this about partitioning a while ago
http://www.csn.ul.ie/~mel/docs/poolmanagement/ 

> > SLAB pages do not have the same property. Even with all processes exited,
> > there will be slab allocations lying around, probably in this partition
> > preventing the hugepage pool being resized (or memory hot-remove for that
> > matter which can work on a section-boundary on POWER).
> 
> echo 2 >/proc/sys/vm/drop_cache will usually allow a significant shrinkage
> of the slab caches. In many ways it is the same.
> 

Except it doesn't work for all slabs. As part of the highorder allocation
stress tests I run, a final part is allocating pages when no other process is
running and /proc/sys/vm/drop_cache has been used. There are still remaining
pages left in odd places.

> > If the administrator has created a partition for memory hot-remove or
> > for having a known quantity when resizing the hugepage pool, it is
> > unlikely they want SLAB pages to be allocated from the same place
> > putting a spanner in the works. Without the partition and
> > slub_min_order==hugepage_size, this patch does nothing so;
> > 
> > NACK.
> 
> This is a feature enabled by a special command line boot option. So its 
> something that the admin did *intentionally*.

Not quite. What he asked for is that slub_min_order=HUGE_PAGESIZE, not
slub_use_zone_movable. In a situation where they wanted to have a hugepage
pool that reliably resized and slub_min_order == HUGE_PAGESIZE, he would
find that they collide for no obvious reason.

If you really want to open the possibility that slub uses the movable
partition, then the parameter should indicate that.

> Slab allocation will *not* 
> take away from the huge page pool but will take pages from the page 
> allocator.
> 

I understand that.

> A system with huge amounts of memory has a large amount of huge 
> pages. It is typically at this point to have 4G per cpu in a system and we 
> may go higher. 4G means up to 2048 huge pages per cpu! Huge page 
> allocation will be quite common and its good to reduce page allocator 
> overhead.
> 

Marking them movable makes no difference to that assertion.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
