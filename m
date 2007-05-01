Date: Tue, 1 May 2007 11:16:51 +0100
Subject: fragmentation avoidance Re: 2.6.22 -mm merge plans
Message-ID: <20070501101651.GA29957@skynet.ie>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org, clameter@sgi.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On (30/04/07 16:20), Andrew Morton didst pronounce:
>  add-apply_to_page_range-which-applies-a-function-to-a-pte-range.patch
>  add-apply_to_page_range-which-applies-a-function-to-a-pte-range-fix.patch
>  safer-nr_node_ids-and-nr_node_ids-determination-and-initial.patch
>  use-zvc-counters-to-establish-exact-size-of-dirtyable-pages.patch
>  proper-prototype-for-hugetlb_get_unmapped_area.patch
>  mm-remove-gcc-workaround.patch
>  slab-ensure-cache_alloc_refill-terminates.patch
>  mm-more-rmap-checking.patch
>  mm-make-read_cache_page-synchronous.patch
>  fs-buffer-dont-pageuptodate-without-page-locked.patch
>  allow-oom_adj-of-saintly-processes.patch
>  introduce-config_has_dma.patch
>  mm-slabc-proper-prototypes.patch
>  mm-detach_vmas_to_be_unmapped-fix.patch
> 
> Misc MM things.  Will merge.

After Andy's mail, I am guessing that the patch below is also going here
in the stack as a cleanup.

add-pfn_valid_within-helper-for-sub-max_order-hole-detection.patch

>  add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages.patch
>  add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated.patch
>  split-the-free-lists-for-movable-and-unmovable-allocations.patch
>  choose-pages-from-the-per-cpu-list-based-on-migration-type.patch
>  add-a-configure-option-to-group-pages-by-mobility.patch
>  drain-per-cpu-lists-when-high-order-allocations-fail.patch
>  move-free-pages-between-lists-on-steal.patch
>  group-short-lived-and-reclaimable-kernel-allocations.patch
>  group-high-order-atomic-allocations.patch
>  do-not-group-pages-by-mobility-type-on-low-memory-systems.patch
>  bias-the-placement-of-kernel-pages-at-lower-pfns.patch
>  be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback.patch
>  fix-corruption-of-memmap-on-ia64-sparsemem-when-mem_section-is-not-a-power-of-2.patch

Plus the patch below from Andy's pfn_valid_within() series would be here:

   anti-fragmentation-switch-over-to-pfn_valid_within.patch

These patches are the grouping pages by mobility patches. They get tested
every time someone boots the machine from the perspective that they affect
the page allocator. It is working to keep fragmentation problems to a
minimum and being exercised.  We have beaten it heavily here on tests
with a variety of machines using the system that drives test.kernel.org
for both functionality and performance testing. That covers x86, x86_64,
ppc64 and occasionally IA64. Granted, there are corner-case machines out
there or we'd never receive bug reports at all.

They are currently being reviewed by Christoph Lameter. His feedback in
the linux-mm thread "Antifrag patchset comments" has given me a TODO list
which I'm currently working through. So far, there has been no fundamental
mistake in my opinion and the additional work is logical extensions.

The closest thing to a fundamental mistake was grouping pages by
MAX_ORDER_NR_PAGES instead of an arbitrary order. What I did was fine for
x86_64, i386 and ppc64 but not as useful for IA64 with 1GB worth of memory
in MAX_ORDER_NR_PAGES. I also missed some temporary allocations as picked
up in Christophs review.

>  create-the-zone_movable-zone.patch
>  allow-huge-page-allocations-to-use-gfp_high_movable.patch
>  x86-specify-amount-of-kernel-memory-at-boot-time.patch
>  ppc-and-powerpc-specify-amount-of-kernel-memory-at-boot-time.patch
>  x86_64-specify-amount-of-kernel-memory-at-boot-time.patch
>  ia64-specify-amount-of-kernel-memory-at-boot-time.patch
>  add-documentation-for-additional-boot-parameter-and-sysctl.patch
>  handle-kernelcore=-boot-parameter-in-common-code-to-avoid-boot-problem-on-ia64.patch
> 
> Mel's moveable-zone work.

These patches are what creates ZONE_MOVABLE. The last 6 patches should be
collapsed into a single patch:

	handle-kernelcore=-generic

I believe Yasunori Goto is looking at these from the perspective of memory
hot-remove and has caught a few bugs in the past. Goto-san may be able to
comment on whether they have been reviewed recently.

The main complexity is in one function in patch one which determines where
the PFN is in each node for ZONE_MOVABLE. Getting that right so that the
requested amount of kernel memory spread as evenly as possible is just
not straight-forward.

> I don't believe that this has had sufficient review and I'm sure that it
> hasn't had sufficient third-party testing.  Most of the approbations thus far
> have consisted of people liking the overall idea, based on the changelogs and
> multi-year-old discussions.
> 
> For such a large and core change I'd have expected more detailed reviewing
> effort and more third-party testing.  And I STILL haven't made time to review
> the code in detail myself.
> 
> So I'm a bit uncomfortable with moving ahead with these changes.
> 

Ok. It is getting reviewed by Christoph and I'm going through the TODO items
it yielded. Andy has also been regularly reviewing them which is probably
why they have had less public errors than you might expect from something
like this. Christoph may like to comment more here.

> <snip>
> 
>  lumpy-reclaim-v4.patch

And I guess this patch also moves here

lumpy-move-to-using-pfn_valid_within.patch

> 
> This is in a similar situation to the moveable-zone work.  Sounds great on
> paper, but it needs considerable third-party testing and review.  It is a
> major change to core MM and, we hope, a significant advance.  On paper.

Andy will probably comment more here. Like the fragmentation stuff, we have
beaten this heavily in tests.

I'm not sure of it's review situation.

> More Mel things, and linkage between Mel-things and lumpy reclaim.  It's here
> where the patch ordering gets into a mess and things won't improve if
> moveable-zones and lumpy-reclaim get deferred.  Such a deferral would limit my
> ability to queue more MM changes for 2.6.23.
> 

This is where the three patches were originally. From the other thread,
I am assuming these are sorted out.

> <snip>
> 
>  bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks.patch
>  remove-page_group_by_mobility.patch
>  dont-group-high-order-atomic-allocations.patch
> 
> More moveable-zone work.
> 

This is the MIGRATE_RESERVE patch and two patches that back out parts of the
grouping pages by mobility stack. If possible, these patches should move to
the end of that stack. To fix the ordering, would it be helpful to provide
a fresh stack based on 2.6.21? That would delete 4 patches in all. The two
that introduce configuration items and highorder atomic groupings and these
two patches that subsequently remove them.

> <SNIP>
> 
>  slub-exploit-page-mobility-to-increase-allocation-order.patch
> 
> Slub entanglement with moveable-zones.  Will merge if moveable-zones is merged.
> 

Well, grouping pages by mobility is what it really depends on. The
ZONE_MOVABLE is not required for SLUB. However, I get the point and agree
with it. If the rest of SLUB gets merged, this patch could be moved to the
end of the grouping by mobility stack.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
