Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9826B0047
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 08:53:28 -0500 (EST)
Date: Mon, 1 Feb 2010 13:53:10 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 25 of 31] transparent hugepage core
Message-ID: <20100201135310.GA26480@csn.ul.ie>
References: <patchbomb.1264689194@v2.random> <ac9bbf9e2c95840eb237.1264689219@v2.random> <20100128175753.GF7139@csn.ul.ie> <20100128223653.GL1217@random.random> <20100129152939.GI7139@csn.ul.ie> <20100201132704.GG12034@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100201132704.GG12034@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <hch@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 01, 2010 at 02:27:04PM +0100, Andrea Arcangeli wrote:
> On Fri, Jan 29, 2010 at 03:29:39PM +0000, Mel Gorman wrote:
> > In fact kswapd will get woken up if you fail a GFP_ATOMIC allocation.
> > What I would expect to to happen is the first allocation would fail but
> > kswapd would wake up and start reclaiming for order-9 (i.e. the huge page
> > size). This might be a more hit-and-miss affair than you'd like though and
> > would make performance predictions that bit harder.
> 
> yeah, it turns out the kswapd behavior breaks it. In short you get
> huge swap storms even without __GFP_IO/FS/WAIT in the direct
> reclaim. So I had to add this:
> 

That's pretty much what I was expecting. Even if the caller does not
allow IO, FS or WAIT, that doesn't stop kswapd doing all the work
indirectly.

> Subject: _GFP_NO_KSWAPD
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Transparent hugepage allocations must be allowed not to invoke kswapd or any
> other kind of indirect reclaim (especially when the defrag sysfs is control
> disabled). It's unacceptable to swap out anonymous pages (potentially
> anonymous transparent hugepages) in order to create new transparent hugepages.
> This is true for the MADV_HUGEPAGE areas too (swapping out a kvm virtual
> machine and so having it suffer an unbearable slowdown, so another one with
> guest physical memory marked MADV_HUGEPAGE can run 30% faster if it is running
> memory intensive workloads, makes no sense). If a transparent hugepage
> allocation fails the slowdown is minor and there is total fallback, so kswapd
> should never be asked to swapout memory to allow the high order allocation to
> succeed.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -59,13 +59,15 @@ struct vm_area_struct;
>  #define __GFP_NOTRACK	((__force gfp_t)0)
>  #endif
>  
> +#define __GFP_NO_KSWAPD	((__force gfp_t)0x400000u)
> +
>  /*
>   * This may seem redundant, but it's a way of annotating false positives vs.
>   * allocations that simply cannot be supported (e.g. page tables).
>   */
>  #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
>  
> -#define __GFP_BITS_SHIFT 22	/* Room for 22 __GFP_FOO bits */
> +#define __GFP_BITS_SHIFT 23	/* Room for 23 __GFP_FOO bits */
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>  
>  /* This equals 0, but use constants in case they ever change */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1829,7 +1829,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, u
>  		goto nopage;
>  
>  restart:
> -	wake_all_kswapd(order, zonelist, high_zoneidx);
> +	if (!(gfp_mask & __GFP_NO_KSWAPD))
> +		wake_all_kswapd(order, zonelist, high_zoneidx);
>  
>  	/*
>  	 * OK, we're below the kswapd watermark and have kicked background
> 
> 
> 
> I also added this for safety, because I don't want hugepage allocation
> to eat from the reserved pfmemalloc pool:
> 
> Subject: don't alloc harder for gfp nomemalloc even if nowait
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Not worth throwing away the precious reserved free memory pool for allocations
> that can fail gracefully (either through mempool or because they're transhuge
> allocations later falling back to 4k allocations).
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1773,7 +1773,11 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  	 */
>  	alloc_flags |= (gfp_mask & __GFP_HIGH);
>  
> -	if (!wait) {
> +	/*
> +	 * Not worth trying to allocate harder for __GFP_NOMEMALLOC
> +	 * even if it can't schedule.
> +	 */
> +	if (!wait && !(gfp_mask & __GFP_NOMEMALLOC)) {
>  		alloc_flags |= ALLOC_HARDER;
>  		/*
>  		 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
> 
> 
> With these two patches and this:
> 
> #define GFP_TRANSHUGE  (__GFP_HARDWALL | __GFP_HIGHMEM |  \
> 	 __GFP_MOVABLE | __GFP_COMP | __GFP_NOMEMALLOC | \
> 	 __GFP_NORETRY | __GFP_NOWARN | __GFP_NO_KSWAPD)
> 
> static inline struct page *alloc_hugepage(void)
> {
> 	int defrag = transparent_hugepage_defrag();
> 	return alloc_pages(GFP_TRANSHUGE | (defrag ? __GFP_WAIT : 0),
> 			   HPAGE_PMD_ORDER);
> }
> 
> 
> It seems leaving defrag off by default is much faster to allocate when
> there is total fragmentation, as with NOWAIT we won't get into cache
> reclaim. I also removed the differentiation between madvise/always in
> the "defrag" knob because what is not ok for madvise is also not ok
> for full transparency. It's not ok of VM takes a lot to startup etc...
> If something we could have khugepaged default to defrag like in my
> previous versions but I don't want to risk shrinking cache for no good
> so for now they all use the above alloc_hugepage as main and only
> allocation method for transhuge pages. This default now works fluid
> all the time and no apparent VM behavior change in my laptop with
> "always" enabling (and the apps gets the hugepages sometime).
> 
> 	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.33-rc6/transparent_hugepage-10
> 	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.33-rc6/transparent_hugepage-10.gz
> 

Will take a closer look again during the next round of review but glancing
through these patches, nothing other bad things related to kswapd spring
to mind.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
