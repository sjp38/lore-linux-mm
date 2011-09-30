Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 22E929000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 10:28:11 -0400 (EDT)
Date: Fri, 30 Sep 2011 16:28:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/5] mm: try to distribute dirty pages fairly across zones
Message-ID: <20110930142805.GC869@tiehlicka.suse.cz>
References: <1317367044-475-1-git-send-email-jweiner@redhat.com>
 <1317367044-475-4-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317367044-475-4-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Shaohua Li <shaohua.li@intel.com>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 30-09-11 09:17:22, Johannes Weiner wrote:
> The maximum number of dirty pages that exist in the system at any time
> is determined by a number of pages considered dirtyable and a
> user-configured percentage of those, or an absolute number in bytes.
> 
> This number of dirtyable pages is the sum of memory provided by all
> the zones in the system minus their lowmem reserves and high
> watermarks, so that the system can retain a healthy number of free
> pages without having to reclaim dirty pages.
> 
> But there is a flaw in that we have a zoned page allocator which does
> not care about the global state but rather the state of individual
> memory zones.  And right now there is nothing that prevents one zone
> from filling up with dirty pages while other zones are spared, which
> frequently leads to situations where kswapd, in order to restore the
> watermark of free pages, does indeed have to write pages from that
> zone's LRU list.  This can interfere so badly with IO from the flusher
> threads that major filesystems (btrfs, xfs, ext4) mostly ignore write
> requests from reclaim already, taking away the VM's only possibility
> to keep such a zone balanced, aside from hoping the flushers will soon
> clean pages from that zone.
> 
> Enter per-zone dirty limits.  They are to a zone's dirtyable memory
> what the global limit is to the global amount of dirtyable memory, and
> try to make sure that no single zone receives more than its fair share
> of the globally allowed dirty pages in the first place.  As the number
> of pages considered dirtyable exclude the zones' lowmem reserves and
> high watermarks, the maximum number of dirty pages in a zone is such
> that the zone can always be balanced without requiring page cleaning.
> 
> As this is a placement decision in the page allocator and pages are
> dirtied only after the allocation, this patch allows allocators to
> pass __GFP_WRITE when they know in advance that the page will be
> written to and become dirty soon.  The page allocator will then
> attempt to allocate from the first zone of the zonelist - which on
> NUMA is determined by the task's NUMA memory policy - that has not
> exceeded its dirty limit.
> 
> At first glance, it would appear that the diversion to lower zones can
> increase pressure on them, but this is not the case.  With a full high
> zone, allocations will be diverted to lower zones eventually, so it is
> more of a shift in timing of the lower zone allocations.  Workloads
> that previously could fit their dirty pages completely in the higher
> zone may be forced to allocate from lower zones, but the amount of
> pages that 'spill over' are limited themselves by the lower zones'
> dirty constraints, and thus unlikely to become a problem.
> 
> For now, the problem of unfair dirty page distribution remains for
> NUMA configurations where the zones allowed for allocation are in sum
> not big enough to trigger the global dirty limits, wake up the flusher
> threads and remedy the situation.  Because of this, an allocation that
> could not succeed on any of the considered zones is allowed to ignore
> the dirty limits before going into direct reclaim or even failing the
> allocation, until a future patch changes the global dirty throttling
> and flusher thread activation so that they take individual zone states
> into account.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Acked-by: Mel Gorman <mgorman@suse.de>

Nice
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/gfp.h       |    4 ++-
>  include/linux/writeback.h |    1 +
>  mm/page-writeback.c       |   83 +++++++++++++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c           |   29 ++++++++++++++++
>  4 files changed, 116 insertions(+), 1 deletions(-)
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
> index 78604a6..f60fd57 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -159,6 +159,25 @@ static struct prop_descriptor vm_dirties;
>   * We make sure that the background writeout level is below the adjusted
>   * clamping level.
>   */
> +
> +/*
> + * In a memory zone, there is a certain amount of pages we consider
> + * available for the page cache, which is essentially the number of
> + * free and reclaimable pages, minus some zone reserves to protect
> + * lowmem and the ability to uphold the zone's watermarks without
> + * requiring writeback.
> + *
> + * This number of dirtyable pages is the base value of which the
> + * user-configurable dirty ratio is the effictive number of pages that
> + * are allowed to be actually dirtied.  Per individual zone, or
> + * globally by using the sum of dirtyable pages over all zones.
> + *
> + * Because the user is allowed to specify the dirty limit globally as
> + * absolute number of bytes, calculating the per-zone dirty limit can
> + * require translating the configured limit into a percentage of
> + * global dirtyable memory first.
> + */
> +
>  static unsigned long highmem_dirtyable_memory(unsigned long total)
>  {
>  #ifdef CONFIG_HIGHMEM
> @@ -245,6 +264,70 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
>  	trace_global_dirty_state(background, dirty);
>  }
>  
> +/**
> + * zone_dirtyable_memory - number of dirtyable pages in a zone
> + * @zone: the zone
> + *
> + * Returns the zone's number of pages potentially available for dirty
> + * page cache.  This is the base value for the per-zone dirty limits.
> + */
> +static unsigned long zone_dirtyable_memory(struct zone *zone)
> +{
> +	/*
> +	 * The effective global number of dirtyable pages may exclude
> +	 * highmem as a big-picture measure to keep the ratio between
> +	 * dirty memory and lowmem reasonable.
> +	 *
> +	 * But this function is purely about the individual zone and a
> +	 * highmem zone can hold its share of dirty pages, so we don't
> +	 * care about vm_highmem_is_dirtyable here.
> +	 */
> +	return zone_page_state(zone, NR_FREE_PAGES) +
> +	       zone_reclaimable_pages(zone) -
> +	       zone->dirty_balance_reserve;
> +}
> +
> +/**
> + * zone_dirty_limit - maximum number of dirty pages allowed in a zone
> + * @zone: the zone
> + *
> + * Returns the maximum number of dirty pages allowed in a zone, based
> + * on the zone's dirtyable memory.
> + */
> +static unsigned long zone_dirty_limit(struct zone *zone)
> +{
> +	unsigned long zone_memory = zone_dirtyable_memory(zone);
> +	struct task_struct *tsk = current;
> +	unsigned long dirty;
> +
> +	if (vm_dirty_bytes)
> +		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE) *
> +			zone_memory / global_dirtyable_memory();
> +	else
> +		dirty = vm_dirty_ratio * zone_memory / 100;
> +
> +	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk))
> +		dirty += dirty / 4;
> +
> +	return dirty;
> +}
> +
> +/**
> + * zone_dirty_ok - tells whether a zone is within its dirty limits
> + * @zone: the zone to check
> + *
> + * Returns %true when the dirty pages in @zone are within the zone's
> + * dirty limit, %false if the limit is exceeded.
> + */
> +bool zone_dirty_ok(struct zone *zone)
> +{
> +	unsigned long limit = zone_dirty_limit(zone);
> +
> +	return zone_page_state(zone, NR_FILE_DIRTY) +
> +	       zone_page_state(zone, NR_UNSTABLE_NFS) +
> +	       zone_page_state(zone, NR_WRITEBACK) <= limit;
> +}
> +
>  /*
>   * couple the period to the dirty_ratio:
>   *
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f8cba89..afaf59e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1675,6 +1675,35 @@ zonelist_scan:
>  		if ((alloc_flags & ALLOC_CPUSET) &&
>  			!cpuset_zone_allowed_softwall(zone, gfp_mask))
>  				continue;
> +		/*
> +		 * When allocating a page cache page for writing, we
> +		 * want to get it from a zone that is within its dirty
> +		 * limit, such that no single zone holds more than its
> +		 * proportional share of globally allowed dirty pages.
> +		 * The dirty limits take into account the zone's
> +		 * lowmem reserves and high watermark so that kswapd
> +		 * should be able to balance it without having to
> +		 * write pages from its LRU list.
> +		 *
> +		 * This may look like it could increase pressure on
> +		 * lower zones by failing allocations in higher zones
> +		 * before they are full.  But the pages that do spill
> +		 * over are limited as the lower zones are protected
> +		 * by this very same mechanism.  It should not become
> +		 * a practical burden to them.
> +		 *
> +		 * XXX: For now, allow allocations to potentially
> +		 * exceed the per-zone dirty limit in the slowpath
> +		 * (ALLOC_WMARK_LOW unset) before going into reclaim,
> +		 * which is important when on a NUMA setup the allowed
> +		 * zones are together not big enough to reach the
> +		 * global limit.  The proper fix for these situations
> +		 * will require awareness of zones in the
> +		 * dirty-throttling and the flusher threads.
> +		 */
> +		if ((alloc_flags & ALLOC_WMARK_LOW) &&
> +		    (gfp_mask & __GFP_WRITE) && !zone_dirty_ok(zone))
> +			goto this_zone_full;
>  
>  		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
>  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
> -- 
> 1.7.6.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
