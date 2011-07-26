Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 763866B0169
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 10:42:51 -0400 (EDT)
Date: Tue, 26 Jul 2011 15:42:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 4/5] mm: writeback: throttle __GFP_WRITE on per-zone
 dirty limits
Message-ID: <20110726144242.GD3010@suse.de>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <1311625159-13771-5-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1311625159-13771-5-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On Mon, Jul 25, 2011 at 10:19:18PM +0200, Johannes Weiner wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> Allow allocators to pass __GFP_WRITE when they know in advance that
> the allocated page will be written to and become dirty soon.
> 
> The page allocator will then attempt to distribute those allocations
> across zones, such that no single zone will end up full of dirty and
> thus more or less unreclaimable pages.
> 

On 32-bit, this idea increases lowmem pressure. Ordinarily, this is
only a problem when the higher zone is really large and management
structures can only be allocated from the lower zones. Granted,
it is rare this is the case but in the last 6 months, I've seen at
least one bug report that could be attributed to lowmem pressure
(24G x86 machine).

A brief explanation as to why this is not a problem may be needed.

> The global dirty limits are put in proportion to the respective zone's
> amount of dirtyable memory and the allocation denied when the limit of
> that zone is reached.
> 

What are the risks of a process stalling on dirty pages in a high zone
that is very small (e.g. 64M) ?

> Before the allocation fails, the allocator slowpath has a stage before
> compaction and reclaim, where the flusher threads are kicked and the
> allocator ultimately has to wait for writeback if still none of the
> zones has become eligible for allocation again in the meantime.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/gfp.h       |    4 +-
>  include/linux/writeback.h |    3 +
>  mm/page-writeback.c       |  132 +++++++++++++++++++++++++++++++++++++++------
>  mm/page_alloc.c           |   27 +++++++++
>  4 files changed, 149 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 3a76faf..78d5338 100644
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
> +#define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Will be dirtied soon */
>  

/* May be dirtied soon */ :)

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
> index 8c63f3a..9312e25 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -93,6 +93,9 @@ void laptop_mode_timer_fn(unsigned long data);
>  static inline void laptop_sync_completion(void) { }
>  #endif
>  void throttle_vm_writeout(gfp_t gfp_mask);
> +bool zone_dirty_ok(struct zone *zone);
> +void try_to_writeback_pages(struct zonelist *zonelist, gfp_t gfp_mask,
> +			    nodemask_t *nodemask);
>  
>  /* These are exported to sysctl. */
>  extern int dirty_background_ratio;
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 41dc871..ce673ec 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -154,6 +154,18 @@ static unsigned long determine_dirtyable_memory(void)
>  	return x + 1;	/* Ensure that we never return 0 */
>  }
>  
> +static unsigned long zone_dirtyable_memory(struct zone *zone)
> +{

Terse comment there :)

> +	unsigned long x = 1; /* Ensure that we never return 0 */
> +
> +	if (is_highmem(zone) && !vm_highmem_is_dirtyable)
> +		return x;
> +
> +	x += zone_page_state(zone, NR_FREE_PAGES);
> +	x += zone_reclaimable_pages(zone);
> +	return x;
> +}

It's very similar to determine_dirtyable_memory(). Would be preferable
if the shared a core function of some sort even if that was implemented
as by "if (zone == NULL)". Otherwise, these will get out of sync
eventually.

> +
>  /*
>   * Scale the writeback cache size proportional to the relative writeout speeds.
>   *
> @@ -378,6 +390,24 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned max_ratio)
>  }
>  EXPORT_SYMBOL(bdi_set_max_ratio);
>  
> +static void sanitize_dirty_limits(unsigned long *pbackground,
> +				  unsigned long *pdirty)
> +{

Maybe a small comment saying to look at the comment in
global_dirty_limits() to see what this is doing and why.

sanitize feels like an odd name to me. The arguements are not
"objectionable" in some way that needs to be corrected.
scale_dirty_limits maybe?

> +	unsigned long background = *pbackground;
> +	unsigned long dirty = *pdirty;
> +	struct task_struct *tsk;
> +
> +	if (background >= dirty)
> +		background = dirty / 2;
> +	tsk = current;
> +	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
> +		background += background / 4;
> +		dirty += dirty / 4;
> +	}
> +	*pbackground = background;
> +	*pdirty = dirty;
> +}
> +
>  /*
>   * global_dirty_limits - background-writeback and dirty-throttling thresholds
>   *
> @@ -389,33 +419,52 @@ EXPORT_SYMBOL(bdi_set_max_ratio);
>   */
>  void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
>  {
> -	unsigned long background;
> -	unsigned long dirty;
>  	unsigned long uninitialized_var(available_memory);
> -	struct task_struct *tsk;
>  
>  	if (!vm_dirty_bytes || !dirty_background_bytes)
>  		available_memory = determine_dirtyable_memory();
>  
>  	if (vm_dirty_bytes)
> -		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> +		*pdirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
>  	else
> -		dirty = (vm_dirty_ratio * available_memory) / 100;
> +		*pdirty = vm_dirty_ratio * available_memory / 100;
>  
>  	if (dirty_background_bytes)
> -		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
> +		*pbackground = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
>  	else
> -		background = (dirty_background_ratio * available_memory) / 100;
> +		*pbackground = dirty_background_ratio * available_memory / 100;
>  
> -	if (background >= dirty)
> -		background = dirty / 2;
> -	tsk = current;
> -	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
> -		background += background / 4;
> -		dirty += dirty / 4;
> -	}
> -	*pbackground = background;
> -	*pdirty = dirty;
> +	sanitize_dirty_limits(pbackground, pdirty);
> +}
> +
> +static void zone_dirty_limits(struct zone *zone, unsigned long *pbackground,
> +			      unsigned long *pdirty)
> +{
> +	unsigned long uninitialized_var(global_memory);
> +	unsigned long zone_memory;
> +
> +	zone_memory = zone_dirtyable_memory(zone);
> +
> +	if (!vm_dirty_bytes || !dirty_background_bytes)
> +		global_memory = determine_dirtyable_memory();
> +
> +	if (vm_dirty_bytes) {
> +		unsigned long dirty_pages;
> +
> +		dirty_pages = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> +		*pdirty = zone_memory * dirty_pages / global_memory;
> +	} else
> +		*pdirty = zone_memory * vm_dirty_ratio / 100;
> +
> +	if (dirty_background_bytes) {
> +		unsigned long dirty_pages;
> +
> +		dirty_pages = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
> +		*pbackground = zone_memory * dirty_pages / global_memory;
> +	} else
> +		*pbackground = zone_memory * dirty_background_ratio / 100;
> +
> +	sanitize_dirty_limits(pbackground, pdirty);
>  }
>  

Ok, seems straight-forward enough. For *_bytes, the number of allowed
dirty pages is scaled based on global memory, otherwise the ration are
applied.

>  /*
> @@ -661,6 +710,57 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>          }
>  }
>  
> +bool zone_dirty_ok(struct zone *zone)
> +{
> +	unsigned long background_thresh, dirty_thresh;
> +	unsigned long nr_reclaimable, nr_writeback;
> +
> +	zone_dirty_limits(zone, &background_thresh, &dirty_thresh);
> +
> +	nr_reclaimable = zone_page_state(zone, NR_FILE_DIRTY) +
> +		zone_page_state(zone, NR_UNSTABLE_NFS);
> +	nr_writeback = zone_page_state(zone, NR_WRITEBACK);
> +
> +	return nr_reclaimable + nr_writeback <= dirty_thresh;
> +}
> +
> +void try_to_writeback_pages(struct zonelist *zonelist, gfp_t gfp_mask,
> +			    nodemask_t *nodemask)
> +{
> +	unsigned int nr_exceeded = 0;
> +	unsigned int nr_zones = 0;
> +	struct zoneref *z;
> +	struct zone *zone;
> +
> +	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask),
> +					nodemask) {
> +		unsigned long background_thresh, dirty_thresh;
> +		unsigned long nr_reclaimable, nr_writeback;
> +
> +		nr_zones++;
> +
> +		zone_dirty_limits(zone, &background_thresh, &dirty_thresh);
> +
> +		nr_reclaimable = zone_page_state(zone, NR_FILE_DIRTY) +
> +			zone_page_state(zone, NR_UNSTABLE_NFS);
> +		nr_writeback = zone_page_state(zone, NR_WRITEBACK);
> +
> +		if (nr_reclaimable + nr_writeback <= background_thresh)
> +			continue;
> +
> +		if (nr_reclaimable > nr_writeback)
> +			wakeup_flusher_threads(nr_reclaimable - nr_writeback);
> +

This is a potential mess. wakeup_flusher_threads() ultimately
calls "work = kzalloc(sizeof(*work), GFP_ATOMIC)" from the page
allocator. Under enough pressure, particularly if the machine has
very little memory, you may see this spewing out warning messages
which ironically will have to be written to syslog dirtying more
pages.  I know I've made the same mistake at least once by calling
wakeup_flusher_thrads() from page reclaim.

It's also still not controlling where the pages are being
written from.  On a large enough NUMA machine, there is a risk that
wakeup_flusher_treads() will be called very frequently to write pages
from remote nodes that are not in trouble.

> +		if (nr_reclaimable + nr_writeback <= dirty_thresh)
> +			continue;
> +
> +		nr_exceeded++;
> +	}
> +
> +	if (nr_zones == nr_exceeded)
> +		congestion_wait(BLK_RW_ASYNC, HZ/10);
> +}
> +

So, you congestion wait but then potentially continue on even
though it is still over the dirty limits.  Should this be more like
throttle_vm_writeout()?

>  /*
>   * sysctl handler for /proc/sys/vm/dirty_writeback_centisecs
>   */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4e8985a..1fac154 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1666,6 +1666,9 @@ zonelist_scan:
>  			!cpuset_zone_allowed_softwall(zone, gfp_mask))
>  				goto try_next_zone;
>  
> +		if ((gfp_mask & __GFP_WRITE) && !zone_dirty_ok(zone))
> +			goto this_zone_full;
> +

So this part needs to explain why using the lower zones does not
potentially cause lowmem pressure on 32-bit. It's not a show stopper
as such but it shouldn't be ignored either.

>  		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
>  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
>  			unsigned long mark;
> @@ -1863,6 +1866,22 @@ out:
>  	return page;
>  }
>  
> +static struct page *
> +__alloc_pages_writeback(gfp_t gfp_mask, unsigned int order,
> +			struct zonelist *zonelist, enum zone_type high_zoneidx,
> +			nodemask_t *nodemask, int alloc_flags,
> +			struct zone *preferred_zone, int migratetype)
> +{
> +	if (!(gfp_mask & __GFP_WRITE))
> +		return NULL;
> +
> +	try_to_writeback_pages(zonelist, gfp_mask, nodemask);
> +
> +	return get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
> +				      high_zoneidx, alloc_flags,
> +				      preferred_zone, migratetype);
> +}
> +
>  #ifdef CONFIG_COMPACTION
>  /* Try memory compaction for high-order allocations before reclaim */
>  static struct page *
> @@ -2135,6 +2154,14 @@ rebalance:
>  	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
>  		goto nopage;
>  
> +	/* Try writing back pages if per-zone dirty limits are reached */
> +	page = __alloc_pages_writeback(gfp_mask, order, zonelist,
> +				       high_zoneidx, nodemask,
> +				       alloc_flags, preferred_zone,
> +				       migratetype);
> +	if (page)
> +		goto got_pg;
> +

I like the general idea but we are still not controlling where
pages are being written from, the potential lowmem pressure problem
needs to be addressed and care needs to be taken with the frequency
wakeup_flusher_threads is called due to it using kmalloc.

I suspect where the performance gain is being seen is due to
the flusher threads being woken earlier, more frequently and are
aggressively writing due to wakeup_flusher_threads() passing in loads
of requests. As you are seeing a performance gain, that is interesting
in itself if it is true.

>  	/*
>  	 * Try direct compaction. The first pass is asynchronous. Subsequent
>  	 * attempts after direct reclaim are synchronous
> -- 
> 1.7.6
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
