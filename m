Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 326089000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 10:30:29 -0400 (EDT)
Date: Wed, 21 Sep 2011 15:30:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 2/4] mm: writeback: distribute write pages across
 allowable zones
Message-ID: <20110921143020.GH4849@suse.de>
References: <1316526315-16801-1-git-send-email-jweiner@redhat.com>
 <1316526315-16801-3-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1316526315-16801-3-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 20, 2011 at 03:45:13PM +0200, Johannes Weiner wrote:
> This patch allows allocators to pass __GFP_WRITE when they know in
> advance that the allocated page will be written to and become dirty
> soon.  The page allocator will then attempt to distribute those
> allocations across zones, such that no single zone will end up full of
> dirty, and thus more or less, unreclaimable pages.
> 

I know this came up the last time but an explanation why lowmem
pressure is not expected to be a problem should be in the changelog.

"At first glance, it would appear that there is a lowmem pressure risk
but it is not the case. Highmem is not considered dirtyable memory.
Hence, if highmem is very large, the global amount of dirty memory
will fit in the highmem zone without falling back to the lower zones
and causing lowmem pressure. If highmem is small then the amount of
pages that 'spill over' to lower zones is limited and no likely to
significantly increase the risk of lowmem pressure due to things like
pagetable page allocations for example. In other words, the timing of
when lowmem pressure happens changes but overall the pressure is roughly
the same".

or something.

> The global dirty limits are put in proportion to the respective zone's
> amount of dirtyable memory and allocations diverted to other zones
> when the limit is reached.
> 
> For now, the problem remains for NUMA configurations where the zones
> allowed for allocation are in sum not big enough to trigger the global
> dirty limits, but a future approach to solve this can reuse the
> per-zone dirty limit infrastructure laid out in this patch to have
> dirty throttling and the flusher threads consider individual zones.
> 

While I think this particular point is important, I don't think it
should be a show stopped for the series.

I'm going to steal Andrew's line here as well - you explain what you are
doing in the patch leader but not why.

> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> ---
>  include/linux/gfp.h       |    4 ++-
>  include/linux/writeback.h |    1 +
>  mm/page-writeback.c       |   66 +++++++++++++++++++++++++++++++++++++-------
>  mm/page_alloc.c           |   22 ++++++++++++++-
>  4 files changed, 80 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 3a76faf..50efc7e 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -36,6 +36,7 @@ struct vm_area_struct;
>  #endif
>  #define ___GFP_NO_KSWAPD	0x400000u
>  #define ___GFP_OTHER_NODE	0x800000u
> +#define ___GFP_WRITE		0x1000000u
>  
>  /*
>   * GFP bitmasks..
> @@ -85,6 +86,7 @@ struct vm_area_struct;
>  
>  #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
>  #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
> +#define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
>  
>  /*
>   * This may seem redundant, but it's a way of annotating false positives vs.
> @@ -92,7 +94,7 @@ struct vm_area_struct;
>   */
>  #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
>  
> -#define __GFP_BITS_SHIFT 24	/* Room for N __GFP_FOO bits */
> +#define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>  
>  /* This equals 0, but use constants in case they ever change */
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index a5f495f..c96ee0c 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -104,6 +104,7 @@ void laptop_mode_timer_fn(unsigned long data);
>  static inline void laptop_sync_completion(void) { }
>  #endif
>  void throttle_vm_writeout(gfp_t gfp_mask);
> +bool zone_dirty_ok(struct zone *zone);
>  
>  extern unsigned long global_dirty_limit;
>  
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 9f896db..1fc714c 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -142,6 +142,22 @@ unsigned long global_dirty_limit;
>  static struct prop_descriptor vm_completions;
>  static struct prop_descriptor vm_dirties;
>  
> +static unsigned long zone_dirtyable_memory(struct zone *zone)
> +{
> +	unsigned long x;
> +	/*
> +	 * To keep a reasonable ratio between dirty memory and lowmem,
> +	 * highmem is not considered dirtyable on a global level.
> +	 *
> +	 * But we allow individual highmem zones to hold a potentially
> +	 * bigger share of that global amount of dirty pages as long
> +	 * as they have enough free or reclaimable pages around.
> +	 */
> +	x = zone_page_state(zone, NR_FREE_PAGES) - zone->totalreserve_pages;
> +	x += zone_reclaimable_pages(zone);
> +	return x;
> +}
> +
>  /*
>   * Work out the current dirty-memory clamping and background writeout
>   * thresholds.
> @@ -417,7 +433,7 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
>  }
>  
>  /*
> - * global_dirty_limits - background-writeback and dirty-throttling thresholds
> + * dirty_limits - background-writeback and dirty-throttling thresholds
>   *
>   * Calculate the dirty thresholds based on sysctl parameters
>   * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
> @@ -425,24 +441,35 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
>   * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
>   * real-time tasks.
>   */
> -void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
> +static void dirty_limits(struct zone *zone,
> +			 unsigned long *pbackground,
> +			 unsigned long *pdirty)
>  {
> +	unsigned long uninitialized_var(zone_memory);
> +	unsigned long available_memory;
> +	unsigned long global_memory;
>  	unsigned long background;
> -	unsigned long dirty;
> -	unsigned long uninitialized_var(available_memory);
>  	struct task_struct *tsk;
> +	unsigned long dirty;
>  
> -	if (!vm_dirty_bytes || !dirty_background_bytes)
> -		available_memory = determine_dirtyable_memory();
> +	global_memory = determine_dirtyable_memory();
> +	if (zone)
> +		available_memory = zone_memory = zone_dirtyable_memory(zone);
> +	else
> +		available_memory = global_memory;
>  
> -	if (vm_dirty_bytes)
> +	if (vm_dirty_bytes) {
>  		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> -	else
> +		if (zone)
> +			dirty = dirty * zone_memory / global_memory;
> +	} else
>  		dirty = (vm_dirty_ratio * available_memory) / 100;
>  
> -	if (dirty_background_bytes)
> +	if (dirty_background_bytes) {
>  		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
> -	else
> +		if (zone)
> +			background = background * zone_memory / global_memory;
> +	} else
>  		background = (dirty_background_ratio * available_memory) / 100;
>  
>  	if (background >= dirty)
> @@ -452,9 +479,15 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
>  		background += background / 4;
>  		dirty += dirty / 4;
>  	}
> +	if (!zone)
> +		trace_global_dirty_state(background, dirty);
>  	*pbackground = background;
>  	*pdirty = dirty;
> -	trace_global_dirty_state(background, dirty);
> +}
> +
> +void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
> +{
> +	dirty_limits(NULL, pbackground, pdirty);
>  }
>  
>  /**
> @@ -875,6 +908,17 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>          }
>  }
>  
> +bool zone_dirty_ok(struct zone *zone)
> +{
> +	unsigned long background_thresh, dirty_thresh;
> +
> +	dirty_limits(zone, &background_thresh, &dirty_thresh);
> +
> +	return zone_page_state(zone, NR_FILE_DIRTY) +
> +		zone_page_state(zone, NR_UNSTABLE_NFS) +
> +		zone_page_state(zone, NR_WRITEBACK) <= dirty_thresh;
> +}
> +
>  /*
>   * sysctl handler for /proc/sys/vm/dirty_writeback_centisecs
>   */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7e8e2ee..3cca043 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1368,6 +1368,7 @@ failed:
>  #define ALLOC_HARDER		0x10 /* try to alloc harder */
>  #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
>  #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
> +#define ALLOC_SLOWPATH		0x80 /* allocator retrying */
>  
>  #ifdef CONFIG_FAIL_PAGE_ALLOC
>  
> @@ -1667,6 +1668,25 @@ zonelist_scan:
>  		if ((alloc_flags & ALLOC_CPUSET) &&
>  			!cpuset_zone_allowed_softwall(zone, gfp_mask))
>  				continue;
> +		/*
> +		 * This may look like it would increase pressure on
> +		 * lower zones by failing allocations in higher zones
> +		 * before they are full.  But once they are full, the
> +		 * allocations fall back to lower zones anyway, and
> +		 * then this check actually protects the lower zones
> +		 * from a flood of dirty page allocations.
> +		 *
> +		 * XXX: Allow allocations to potentially exceed the
> +		 * per-zone dirty limit in the slowpath before going
> +		 * into reclaim, which is important when NUMA nodes
> +		 * are not big enough to reach the global limit.  The
> +		 * proper fix on these setups will require awareness
> +		 * of zones in the dirty-throttling and the flusher
> +		 * threads.
> +		 */

Here would be a good reason to explain why we sometimes allow
__GFP_WRITE pages to fall back to lower zones. As it is, the reader
is required to remember that this affects LRU ordering and when/if
reclaim tries to write back the page.

> +		if (!(alloc_flags & ALLOC_SLOWPATH) &&
> +		    (gfp_mask & __GFP_WRITE) && !zone_dirty_ok(zone))
> +			goto this_zone_full;
>  
>  		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
>  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
> @@ -2111,7 +2131,7 @@ restart:
>  	 * reclaim. Now things get more complex, so set up alloc_flags according
>  	 * to how we want to proceed.
>  	 */
> -	alloc_flags = gfp_to_alloc_flags(gfp_mask);
> +	alloc_flags = gfp_to_alloc_flags(gfp_mask) | ALLOC_SLOWPATH;
>  

Instead of adding ALLOC_SLOWPATH, check for ALLOC_WMARK_LOW which is
only set in the fast path.

>  	/*
>  	 * Find the true preferred zone if the allocation is unconstrained by

Functionally, I did not find a problem with the patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
