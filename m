Date: Tue, 4 Mar 2008 12:20:08 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 0/8] slub: Fallback to order 0 and variable order slab support
Message-ID: <20080304122008.GB19606@csn.ul.ie>
References: <20080229044803.482012397@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080229044803.482012397@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (28/02/08 20:48), Christoph Lameter didst pronounce:
> This is the patchset that was posted two weeks ago modified according
> to the feedback that Pekka gave. I would like to put these patches
> into mm.
> 

I haven't reviewed the patches properly but I put them through a quick test
against 2.6.25-rc3 to see what the performnace was like and the superpage
allocation success rates were like. Performance wise, it looked like

				Loss	to	Gain
Kernbench Elapsed time		 -0.64%		0.32%
Kernbench Total time		 -0.61%		0.48%
Hackbench sockets-12 clients	 -2.95%		5.13%
Hackbench pipes-12 clients	-16.95%		9.27%
TBench 4 clients		 -1.98%		8.2%
DBench 4 clients (ext2)		 -5.9%		7.99%

So, running with the high orders is not a clear-cut win to my eyes. What
did you test to show that it was a general win justifying a high-order by
default? From looking through, tbench seems to be the only obvious one to
gain but the rest, it is not clear at all. I'll try give sysbench a spin
later to see if it is clear-cut.

However, in *all* cases, superpage allocations were less successful and in
some cases it was severely regressed (one machine went from 81% success rate
to 36%). Sufficient statistics are not gathered to see why this happened
in retrospect but my suspicion would be that high-order RECLAIMABLE and
UNMOVABLE slub allocations routinely fall back to the less fragmented
MOVABLE pageblocks with these patches - something that is normally a very
rare event. This change in assumption hurts fragmentation avoidance and
chances are the long-term behaviour of these patches is not great.

If this guess is correct, using a high-order size by default is a bad plan
and it should only be set when it is known that the target workload benefits
and superpage allocations are not a concern. Alternative, set high-order by
default only for a limited number of caches that are RECLAIMABLE (or better
yet ones we know can be directly reclaimed with the slub-defrag patches).

As it is, this is painful from a fragmentation perspective and the
performance win is not clear-cut.

> This patchset makes slub capable of handling arbitrary sizes of pages.
> This means that a slab cache that currently uses order 1 because of
> packing density issues can fallback to order 0 allocations if memory
> becomes fragmented. All allocations for objects <= PAGE_SIZE can fall
> back like that. So a single slab may contain various sizes of pages
> that may contain more or less objects.
> 
> On the other hand it also enables slub to use larger page orders by
> default since it is now no problem to fall back to an order 0 alloc.
> The default max order is set to 4 which means that 64K compound pages
> can beused in some situations for large objects that do not fit into smaller
> pages. This in turn increases the number of times slub can use its
> fastpath before a fallback to the page allocator has to occur.
> 
> The patchset realizes the initial intend of providing a feature
> comparable with the per cpu queue size in slab. The order for
> each slab cache can be configured from user space while the system
> is running. Increasing the default allocation order can be used to
> tune slub like slab.
> 
> The allocated sizes can then also be effectively controlled via boot
> parameters (slub_min_order and slub_max_order).
> 
> The patchset is also available via git
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git slab-mm
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
