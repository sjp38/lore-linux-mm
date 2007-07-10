Date: Tue, 10 Jul 2007 11:20:43 +0100
Subject: Re: -mm merge plans -- anti-fragmentation
Message-ID: <20070710102043.GA20303@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@suse.de, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl,
y-goto@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Bcc: 
Subject: Re: -mm merge plans for 2.6.23
Reply-To: 
In-Reply-To: <20070710013152.ef2cd200.akpm@linux-foundation.org>

Hi

On (10/07/07 01:31), Andrew Morton didst pronounce:

> <SNIP>
>
> add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages.patch
> add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated.patch

The add-__grp_movable patch here is also needed for zone movable patches
below. I'm pointing it out because it's possible grouping pages by
mobility and the zone movable stuff are effectively 
independent and could be merged separately.

> split-the-free-lists-for-movable-and-unmovable-allocations.patch
> choose-pages-from-the-per-cpu-list-based-on-migration-type.patch
> add-a-configure-option-to-group-pages-by-mobility.patch
> drain-per-cpu-lists-when-high-order-allocations-fail.patch
> move-free-pages-between-lists-on-steal.patch
> group-short-lived-and-reclaimable-kernel-allocations.patch
> group-high-order-atomic-allocations.patch
> do-not-group-pages-by-mobility-type-on-low-memory-systems.patch
> bias-the-placement-of-kernel-pages-at-lower-pfns.patch
> be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback.patch
> fix-corruption-of-memmap-on-ia64-sparsemem-when-mem_section-is-not-a-power-of-2.patch
> bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks.patch
> remove-page_group_by_mobility.patch
> dont-group-high-order-atomic-allocations.patch
> fix-calculation-in-move_freepages_block-for-counting-pages.patch
> breakout-page_order-to-internalh-to-avoid-special-knowledge-of-the-buddy-allocator.patch
> do-not-depend-on-max_order-when-grouping-pages-by-mobility.patch
> print-out-statistics-in-relation-to-fragmentation-avoidance-to-proc-pagetypeinfo.patch
> 
>  Mel's page allocator work.  Might merge this, but I'm still not hearing
>  sufficiently convincing noises from a sufficient number of people over this.
> 

This is a long on-going story. It bounces between people who say it's not a
complete solution and everything should have the 100% ability to defragment
and the people on the other side that say it goes a long way to solving their
problem. I've cc'd some of the parties that have expressed any interest in
the last year.

I want this mainly for reducing restrictions on the sizing of the hugepage
pool. Outside of that in the short-term it has some application for using
higher-order pages with SLUB although the patches to do that probably need
more work. In the longer-term, Kamezawa's memory hot-remove patches are
simplier if these patches are in place. In the past, it was known that
these patches helped the unplugging of 16MB sections on PPC64 which has
an application with DLPARs on that platform. In the slightly longer-term,
there are the memory compaction patches which trigger when there is enough
free memory but it's not contiguous enough.

On a slightly more left of centre tact, these patches *may* help fsblock with
large blocks although I would like to hear Nick's confirming/denying this.
Currently if fsblock wants to work with large blocks, it uses a vmap to map
discontiguous pages so they are virtually contiguous for the filesystem. The
use of VMAP is never cheap, though how much of an overhead in this case is
unknown.  If these patches were in place, fsblock could optimisically allocate
the higher-order page and use it without vmap if it succeeded. If it fails,
it would use vmap as a lower-performance-but-still-works fallback. This
may tie in better with what Christoph is doing with large blocks as well
as it may be a compromise solution between their proposals - I'm not 100%
sure so he's cc'd as well for comment.

The patches have been reviewed heavily recently by Christoph and Andy has
looked through them as well. They've been tested for a long time in -mm so
I would expect they not regress functionality. I've maintained that having
the 100% ability to defragment will cost too much in terms of performance
and would be blocked by the fact that the device driver model would have to
be updated to never use physical addresses - a massive undertaking. I think
this approach is more pragmatic and working on making more types of memory
(like page tables) migratable is at least piecemeal as opposed to turning
everything on it's head.

As has happened in the past, I'm not sure what else I can say here to
convince you.

> create-the-zone_movable-zone.patch
> allow-huge-page-allocations-to-use-gfp_high_movable.patch
> handle-kernelcore=-generic.patch
> 
>  Mel's moveable-zone work.  In a similar situation.  We need to stop whatever
>  we're doing and get down and work out what we're going to do with all this
>  stuff.
> 

Whatever about grouping pages by mobility, I would like to see these go
through. They have a real application for hugetlb pool resizing where the
administrator knows the range of hugepages that will be required but doesn't
want to waste memory when the required number of hugepages is small. I've
cc'd Kenneth Chen as I believe he has run into this problem recently where
I believe partitioning memory would have helped. He'll either confirm or deny.

> lumpy-reclaim-v4.patch

This patch is really what lumpy reclaim is. I believe Peter has looked
at this and was happy enough at the time although he is cc'd here again
in case this has changed. This is mainly useful with either grouping
pages by mobility or the ZONE_MOVABLE stuff. However, at the time the
patch was proposed, there was a feeling that it might help jumbo frame
allocation on e1000's and maybe if fsblock optimistically uses
contiguous pages it would have an application. I would like to see it go
through to see does it help e1000 at least.

There has been little noise here because there is little to say once it
went through it's initial review. Testing with anti-fragmentation
patches implies it works. Data on how well it works on it's own is
spotty but it will not regress functionality.

> have-kswapd-keep-a-minimum-order-free-other-than-order-0.patch
> only-check-absolute-watermarks-for-alloc_high-and-alloc_harder-allocations.patch
> 

These two patches are placed a little strangely as they are in relation
to slub using higher orders which comes later in the series. These were
contentious and needed to be revisited. It hasn't happened yet because
without grouping pages by mobility - the point is meaningless anyway. Right
now, these should not be going anywhere.

> slub-exploit-page-mobility-to-increase-allocation-order.patch
> slub-reduce-antifrag-max-order.patch
> 
>  These are slub changes which are dependent on Mel's stuff, and I have a note
>  here that there were reports of page allocation failures with these.  What's
>  up with that?
> 

These is where the
have-kswapd-keep-a-minimum-order-free-other-than-order-0.patch and
only-check-absolute-watermarks-for-alloc_high-and-alloc_harder-allocations.patch
patches should be. There were page allocation failure reports without these
patches but Nick felt they were not the correct solution and I tend to agree
with him on this matter. I haven't put a massive amount of thought into it
yet because without grouping pages by mobility, the question is pointless.

>  Maybe I should just drop the 100-odd marginal-looking MM patches?  We're
>  simply not showing compelling reasons for merging them and quite a lot of them
>  are stuck in a 90% complete state.
> 

While I cannot speak for all the patches that might fall into
this category, I would agree with the sentiment for the
have-kswapd-keep-a-minimum-order-free-other-than-order-0.patch and friends
patches.

However, it is totally unclear from my perspective what can be done with
grouping pages by mobility or ZONE_MOVABLE that would aid their stalled
status. Prehaps this thread will nudge it a bit.

> memory-unplug-v7-migration-by-kernel.patch
> memory-unplug-v7-isolate_lru_page-fix.patch
> memory-unplug-v7-memory-hotplug-cleanup.patch
> memory-unplug-v7-page-isolation.patch
> memory-unplug-v7-page-offline.patch
> memory-unplug-v7-ia64-interface.patch
> 
>  These are new, and are dependent on Mel's stuff.  Not for 2.6.23.
> 

Specifically, they depend on grouping pages by mobility for the page
isolation patch. Without grouping pages by mobility, that patch gets
pretty messy. For the operation to succeed at all, it benefits from the
ZONE_MOVABLE patches. Kamezawa is cc'd so he might comment further.

> <SNIP>

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
