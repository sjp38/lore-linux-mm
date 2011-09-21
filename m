Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CE2B19000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 09:35:29 -0400 (EDT)
Date: Wed, 21 Sep 2011 15:35:04 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 2/4] mm: writeback: distribute write pages across
 allowable zones
Message-ID: <20110921133504.GC22516@redhat.com>
References: <1316526315-16801-1-git-send-email-jweiner@redhat.com>
 <1316526315-16801-3-git-send-email-jweiner@redhat.com>
 <1316603068.2001.3.camel@shli-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1316603068.2001.3.camel@shli-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Sep 21, 2011 at 07:04:28PM +0800, Shaohua Li wrote:
> On Tue, 2011-09-20 at 21:45 +0800, Johannes Weiner wrote:
> > This patch allows allocators to pass __GFP_WRITE when they know in
> > advance that the allocated page will be written to and become dirty
> > soon.  The page allocator will then attempt to distribute those
> > allocations across zones, such that no single zone will end up full of
> > dirty, and thus more or less, unreclaimable pages.
> > 
> > The global dirty limits are put in proportion to the respective zone's
> > amount of dirtyable memory and allocations diverted to other zones
> > when the limit is reached.
> > 
> > For now, the problem remains for NUMA configurations where the zones
> > allowed for allocation are in sum not big enough to trigger the global
> > dirty limits, but a future approach to solve this can reuse the
> > per-zone dirty limit infrastructure laid out in this patch to have
> > dirty throttling and the flusher threads consider individual zones.
> > 
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> > ---
> >  include/linux/gfp.h       |    4 ++-
> >  include/linux/writeback.h |    1 +
> >  mm/page-writeback.c       |   66 +++++++++++++++++++++++++++++++++++++-------
> >  mm/page_alloc.c           |   22 ++++++++++++++-
> >  4 files changed, 80 insertions(+), 13 deletions(-)
> > 
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 3a76faf..50efc7e 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -36,6 +36,7 @@ struct vm_area_struct;
> >  #endif
> >  #define ___GFP_NO_KSWAPD	0x400000u
> >  #define ___GFP_OTHER_NODE	0x800000u
> > +#define ___GFP_WRITE		0x1000000u
> >  
> >  /*
> >   * GFP bitmasks..
> > @@ -85,6 +86,7 @@ struct vm_area_struct;
> >  
> >  #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
> >  #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
> > +#define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
> >  
> >  /*
> >   * This may seem redundant, but it's a way of annotating false positives vs.
> > @@ -92,7 +94,7 @@ struct vm_area_struct;
> >   */
> >  #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
> >  
> > -#define __GFP_BITS_SHIFT 24	/* Room for N __GFP_FOO bits */
> > +#define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
> >  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
> >  
> >  /* This equals 0, but use constants in case they ever change */
> > diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> > index a5f495f..c96ee0c 100644
> > --- a/include/linux/writeback.h
> > +++ b/include/linux/writeback.h
> > @@ -104,6 +104,7 @@ void laptop_mode_timer_fn(unsigned long data);
> >  static inline void laptop_sync_completion(void) { }
> >  #endif
> >  void throttle_vm_writeout(gfp_t gfp_mask);
> > +bool zone_dirty_ok(struct zone *zone);
> >  
> >  extern unsigned long global_dirty_limit;
> >  
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index 9f896db..1fc714c 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -142,6 +142,22 @@ unsigned long global_dirty_limit;
> >  static struct prop_descriptor vm_completions;
> >  static struct prop_descriptor vm_dirties;
> >  
> > +static unsigned long zone_dirtyable_memory(struct zone *zone)
> > +{
> > +	unsigned long x;
> > +	/*
> > +	 * To keep a reasonable ratio between dirty memory and lowmem,
> > +	 * highmem is not considered dirtyable on a global level.
> > +	 *
> > +	 * But we allow individual highmem zones to hold a potentially
> > +	 * bigger share of that global amount of dirty pages as long
> > +	 * as they have enough free or reclaimable pages around.
> > +	 */
> > +	x = zone_page_state(zone, NR_FREE_PAGES) - zone->totalreserve_pages;
> > +	x += zone_reclaimable_pages(zone);
> > +	return x;
> > +}
> > +
> >  /*
> >   * Work out the current dirty-memory clamping and background writeout
> >   * thresholds.
> > @@ -417,7 +433,7 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
> >  }
> >  
> >  /*
> > - * global_dirty_limits - background-writeback and dirty-throttling thresholds
> > + * dirty_limits - background-writeback and dirty-throttling thresholds
> >   *
> >   * Calculate the dirty thresholds based on sysctl parameters
> >   * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
> > @@ -425,24 +441,35 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
> >   * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
> >   * real-time tasks.
> >   */
> > -void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
> > +static void dirty_limits(struct zone *zone,
> > +			 unsigned long *pbackground,
> > +			 unsigned long *pdirty)
> >  {
> > +	unsigned long uninitialized_var(zone_memory);
> > +	unsigned long available_memory;
> > +	unsigned long global_memory;
> >  	unsigned long background;
> > -	unsigned long dirty;
> > -	unsigned long uninitialized_var(available_memory);
> >  	struct task_struct *tsk;
> > +	unsigned long dirty;
> >  
> > -	if (!vm_dirty_bytes || !dirty_background_bytes)
> > -		available_memory = determine_dirtyable_memory();
> > +	global_memory = determine_dirtyable_memory();
> > +	if (zone)
> > +		available_memory = zone_memory = zone_dirtyable_memory(zone);
> > +	else
> > +		available_memory = global_memory;
> >  
> > -	if (vm_dirty_bytes)
> > +	if (vm_dirty_bytes) {
> >  		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> > -	else
> > +		if (zone)
> > +			dirty = dirty * zone_memory / global_memory;
> > +	} else
> >  		dirty = (vm_dirty_ratio * available_memory) / 100;
> >  
> > -	if (dirty_background_bytes)
> > +	if (dirty_background_bytes) {
> >  		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
> > -	else
> > +		if (zone)
> > +			background = background * zone_memory / global_memory;
> > +	} else
> >  		background = (dirty_background_ratio * available_memory) / 100;
> >  
> >  	if (background >= dirty)
> > @@ -452,9 +479,15 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
> >  		background += background / 4;
> >  		dirty += dirty / 4;
> >  	}
> > +	if (!zone)
> > +		trace_global_dirty_state(background, dirty);
> >  	*pbackground = background;
> >  	*pdirty = dirty;
> > -	trace_global_dirty_state(background, dirty);
> > +}
> > +
> > +void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
> > +{
> > +	dirty_limits(NULL, pbackground, pdirty);
> >  }
> >  
> >  /**
> > @@ -875,6 +908,17 @@ void throttle_vm_writeout(gfp_t gfp_mask)
> >          }
> >  }
> >  
> > +bool zone_dirty_ok(struct zone *zone)
> > +{
> > +	unsigned long background_thresh, dirty_thresh;
> > +
> > +	dirty_limits(zone, &background_thresh, &dirty_thresh);
> > +
> > +	return zone_page_state(zone, NR_FILE_DIRTY) +
> > +		zone_page_state(zone, NR_UNSTABLE_NFS) +
> > +		zone_page_state(zone, NR_WRITEBACK) <= dirty_thresh;
> > +}
> > +
> >  /*
> >   * sysctl handler for /proc/sys/vm/dirty_writeback_centisecs
> >   */
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 7e8e2ee..3cca043 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1368,6 +1368,7 @@ failed:
> >  #define ALLOC_HARDER		0x10 /* try to alloc harder */
> >  #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
> >  #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
> > +#define ALLOC_SLOWPATH		0x80 /* allocator retrying */
> >  
> >  #ifdef CONFIG_FAIL_PAGE_ALLOC
> >  
> > @@ -1667,6 +1668,25 @@ zonelist_scan:
> >  		if ((alloc_flags & ALLOC_CPUSET) &&
> >  			!cpuset_zone_allowed_softwall(zone, gfp_mask))
> >  				continue;
> > +		/*
> > +		 * This may look like it would increase pressure on
> > +		 * lower zones by failing allocations in higher zones
> > +		 * before they are full.  But once they are full, the
> > +		 * allocations fall back to lower zones anyway, and
> > +		 * then this check actually protects the lower zones
> > +		 * from a flood of dirty page allocations.
> if increasing pressure on lower zones isn't a problem since higher zones
> will eventually be full, how about a workload without too many writes,
> so higher zones will not be full. In such case, increasing low zone
> pressure sounds not good.

While there is a shift of dirty pages possible in workloads that were
able to completely fit those pages in the highest zone, the extent of
that shift is limited, which should prevent it from becoming a
practical burden for the lower zones.

Because the number of dirtyable pages does include neither a zone's
lowmem reserves, nor the watermarks, nor kernel allocations, a lower
zone does not receive a bigger share than it can afford when the
allocations are diverted from the higher zones.

To put it into perspective: with these patches there could be an
increased allocation latency for a workload with a writer of fixed
size fitting into the Normal zone and an allocator that suddenly
requires more than 3G (~ DMA32 size minus the 20% allowable dirty
pages) DMA32 memory.  That sounds a bit artificial, to me at least.
And without these patches, we encounter exactly those allocation
latencies on a regular basis when writing files larger than memory.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
