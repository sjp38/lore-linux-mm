Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EBB90831FA
	for <linux-mm@kvack.org>; Tue,  9 May 2017 21:04:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s62so13716312pgc.2
        for <linux-mm@kvack.org>; Tue, 09 May 2017 18:04:01 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id k6si1418726pla.11.2017.05.09.18.03.59
        for <linux-mm@kvack.org>;
        Tue, 09 May 2017 18:04:00 -0700 (PDT)
Date: Wed, 10 May 2017 10:03:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -v10 1/3] mm, THP, swap: Delay splitting THP during
 swap out
Message-ID: <20170510010357.GA23404@bbox>
References: <20170425125658.28684-1-ying.huang@intel.com>
 <20170425125658.28684-2-ying.huang@intel.com>
 <20170427053141.GA1925@bbox>
 <87mvb21fz1.fsf@yhuang-dev.intel.com>
 <20170428084044.GB19510@bbox>
 <87d1bwvi26.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d1bwvi26.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

Hi Huang,

On Fri, Apr 28, 2017 at 08:21:37PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Thu, Apr 27, 2017 at 03:12:34PM +0800, Huang, Ying wrote:
> >> Minchan Kim <minchan@kernel.org> writes:
> >> 
> >> > On Tue, Apr 25, 2017 at 08:56:56PM +0800, Huang, Ying wrote:
> >> >> From: Huang Ying <ying.huang@intel.com>
> >> >> 
> >> >> In this patch, splitting huge page is delayed from almost the first
> >> >> step of swapping out to after allocating the swap space for the
> >> >> THP (Transparent Huge Page) and adding the THP into the swap cache.
> >> >> This will batch the corresponding operation, thus improve THP swap out
> >> >> throughput.
> >> >> 
> >> >> This is the first step for the THP swap optimization.  The plan is to
> >> >> delay splitting the THP step by step and avoid splitting the THP
> >> >> finally.
> >> >> 
> >> >> The advantages of the THP swap support include:
> >> >> 
> >> >> - Batch the swap operations for the THP and reduce lock
> >> >>   acquiring/releasing, including allocating/freeing the swap space,
> >> >>   adding/deleting to/from the swap cache, and writing/reading the swap
> >> >>   space, etc.  This will help to improve the THP swap performance.
> >> >> 
> >> >> - The THP swap space read/write will be 2M sequential IO.  It is
> >> >>   particularly helpful for the swap read, which usually are 4k random
> >> >>   IO.  This will help to improve the THP swap performance.
> >> >> 
> >> >> - It will help the memory fragmentation, especially when the THP is
> >> >>   heavily used by the applications.  The 2M continuous pages will be
> >> >>   free up after the THP swapping out.
> >> >> 
> >> >> - It will improve the THP utilization on the system with the swap
> >> >>   turned on.  Because the speed for khugepaged to collapse the normal
> >> >>   pages into the THP is quite slow.  After the THP is split during the
> >> >>   swapping out, it will take quite long time for the normal pages to
> >> >>   collapse back into the THP after being swapped in.  The high THP
> >> >>   utilization helps the efficiency of the page based memory management
> >> >>   too.
> >> >> 
> >> >> There are some concerns regarding THP swap in, mainly because possible
> >> >> enlarged read/write IO size (for swap in/out) may put more overhead on
> >> >> the storage device.  To deal with that, the THP swap in should be
> >> >> turned on only when necessary.  For example, it can be selected via
> >> >> "always/never/madvise" logic, to be turned on globally, turned off
> >> >> globally, or turned on only for VMA with MADV_HUGEPAGE, etc.
> >> >> 
> >> >> In this patch, one swap cluster is used to hold the contents of each
> >> >> THP swapped out.  So, the size of the swap cluster is changed to that
> >> >> of the THP (Transparent Huge Page) on x86_64 architecture (512).  For
> >> >> other architectures which want such THP swap optimization,
> >> >> ARCH_USES_THP_SWAP_CLUSTER needs to be selected in the Kconfig file
> >> >> for the architecture.  In effect, this will enlarge swap cluster size
> >> >> by 2 times on x86_64.  Which may make it harder to find a free cluster
> >> >> when the swap space becomes fragmented.  So that, this may reduce the
> >> >> continuous swap space allocation and sequential write in theory.  The
> >> >> performance test in 0day shows no regressions caused by this.
> >> >
> >> > What about other architecures?
> >> >
> >> > I mean THP page size on every architectures would be various.
> >> > If THP page size is much bigger than 2M, the architecture should
> >> > have big swap cluster size for supporting THP swap-out feature.
> >> > It means fast empty-swap cluster consumption so that it can suffer
> >> > from fragmentation easily which causes THP swap void and swap slot
> >> > allocations slow due to not being able to use per-cpu.
> >> >
> >> > What I suggested was contiguous multiple swap cluster allocations
> >> > to meet THP page size. If some of architecure's THP size is 64M
> >> > and SWAP_CLUSTER_SIZE is 2M, it should allocate 32 contiguos
> >> > swap clusters. For that, swap layer need to manage clusters sort
> >> > in order which would be more overhead in CONFIG_THP_SWAP case
> >> > but I think it's tradeoff. With that, every architectures can
> >> > support THP swap easily without arch-specific something.
> >> 
> >> That may be a good solution for other architectures.  But I am afraid I
> >> am not the right person to work on that.  Because I don't know the
> >> requirement of other architectures, and I have no other architectures
> >> machines to work on and measure the performance.
> >
> > IMO, THP swapout is good thing for every architecture so I dobut
> > you need to know other architecture's requirement.
> >
> >> 
> >> And the swap clusters aren't sorted in order now intentionally to avoid
> >> cache line false sharing between the spinlock of struct
> >> swap_cluster_info.  If we want to sort clusters in order, we need a
> >> solution for that.
> >
> > Does it really matter for this work? IOW, if we couldn't solve it,
> > cannot we support THP swapout? I don't think so. That's the least
> > of your worries.
> > Also, if we have sorted cluster data structure, we need to change
> > current single linked list of swap cluster to other one so we would
> > need to revisit to see whether it's really problem.
> >
> >> 
> >> > If (PAGE_SIZE * 512) swap cluster size were okay for most of
> >> > architecture, just increase it. It's orthogonal work regardless of
> >> > THP swapout. Then, we don't need to manage swap clusters sort
> >> > in order in x86_64 which SWAP_CLUSTER_SIZE is equal to
> >> > THP_PAGE_SIZE. It's just a bonus by side-effect.
> >> 
> >> Andrew suggested to make swap cluster size = huge page size (or turn on
> >> THP swap optimization) only if we enabled CONFIG_THP_SWAP.  So that, THP
> >> swap optimization will not be turned on unintentionally.
> >> 
> >> We may adjust default swap cluster size, but I don't think it need to be
> >> in this patchset.
> >
> > That's it. This feature shouldn't be aware of swap cluster size. IOW,
> > it would be better to work with every swap cluster size if the align
> > between THP and swap cluster size is matched at least.
> 
> Using one swap cluster for each THP is simpler, so why not start from
> the simple design?  Complex design may be necessary in the future, but
> we can work on that at that time.

If it were really architecture specific issue, I'm okay with such simple
start with major architecture first. However, I don't think it's the case.

THP swap: I don't think it's a architecure issue. It's generally good thing
once system supports THP. It is also good thing for HDD swap as well as SSD.
(In fact, I don't understand why we should have CONFIG_THP_SWAP. I think
 it should work with CONFIG_TRANSPARENT_HUGEPAGE automatically).

Current design is selected for just *simple implementation" and put the
heavy drift to make it generalize to others in the future.
I don't think it's good thing. But others might have different opinions
so I'm not insisting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
