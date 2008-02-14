Date: Thu, 14 Feb 2008 11:18:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 4/5] slub: Use __GFP_MOVABLE for slabs of HPAGE_SIZE
In-Reply-To: <20080214141442.GF17641@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0802141110280.32613@schroedinger.engr.sgi.com>
References: <20080214040245.915842795@sgi.com> <20080214040314.118141086@sgi.com>
 <20080214141442.GF17641@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008, Mel Gorman wrote:

> The only reason to have an allocation like this set as MOVABLE is so it can
> make use of the partition created by movablecore= which has a few specific
> purposes. One of them is that on a shared system, a partition can be created
> that is of the same size as the largest hugepage pool required for any job. As
> jobs run, they can grow or shrink the pool as desired.  When the jobs complete,
> the hugepages are no longer in use and the partition becomes essentially free.

Doesnt it mean that the allocations can occur in MAX_ORDER blocks 
marked MOVABLE? I thought movablecore= is no longer necessary after the 
rest of the antifrag stuff was merged?

> SLAB pages do not have the same property. Even with all processes exited,
> there will be slab allocations lying around, probably in this partition
> preventing the hugepage pool being resized (or memory hot-remove for that
> matter which can work on a section-boundary on POWER).

echo 2 >/proc/sys/vm/drop_cache will usually allow a significant shrinkage
of the slab caches. In many ways it is the same.

> If the administrator has created a partition for memory hot-remove or
> for having a known quantity when resizing the hugepage pool, it is
> unlikely they want SLAB pages to be allocated from the same place
> putting a spanner in the works. Without the partition and
> slub_min_order==hugepage_size, this patch does nothing so;
> 
> NACK.

This is a feature enabled by a special command line boot option. So its 
something that the admin did *intentionally*. Slab allocation will *not* 
take away from the huge page pool but will take pages from the page 
allocator.

A system with huge amounts of memory has a large amount of huge 
pages. It is typically at this point to have 4G per cpu in a system and we 
may go higher. 4G means up to 2048 huge pages per cpu! Huge page 
allocation will be quite common and its good to reduce page allocator 
overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
