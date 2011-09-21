Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 96FEF9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 19:03:35 -0400 (EDT)
Date: Wed, 21 Sep 2011 16:02:26 -0700
From: Andrew Morton <akpm@google.com>
Subject: Re: [patch 2/4] mm: writeback: distribute write pages across
 allowable zones
Message-Id: <20110921160226.1bf74494.akpm@google.com>
In-Reply-To: <1316526315-16801-3-git-send-email-jweiner@redhat.com>
References: <1316526315-16801-1-git-send-email-jweiner@redhat.com>
	<1316526315-16801-3-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, 20 Sep 2011 15:45:13 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> This patch allows allocators to pass __GFP_WRITE when they know in
> advance that the allocated page will be written to and become dirty
> soon.  The page allocator will then attempt to distribute those
> allocations across zones, such that no single zone will end up full of
> dirty, and thus more or less, unreclaimable pages.

Across all zones, or across the zones within the node or what?  Some
more description of how all this plays with NUMA is needed, please.

> The global dirty limits are put in proportion to the respective zone's
> amount of dirtyable memory

I don't know what this means.  How can a global limit be controlled by
what is happening within each single zone?  Please describe this design
concept fully.

> and allocations diverted to other zones
> when the limit is reached.

hm.

> For now, the problem remains for NUMA configurations where the zones
> allowed for allocation are in sum not big enough to trigger the global
> dirty limits, but a future approach to solve this can reuse the
> per-zone dirty limit infrastructure laid out in this patch to have
> dirty throttling and the flusher threads consider individual zones.
> 
> ...
>
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
> 
> ...
>
> +static unsigned long zone_dirtyable_memory(struct zone *zone)

Appears to return the number of pages in a particular zone which are
considered "dirtyable".  Some discussion of how this decision is made
would be illuminating.

> +{
> +	unsigned long x;
> +	/*
> +	 * To keep a reasonable ratio between dirty memory and lowmem,
> +	 * highmem is not considered dirtyable on a global level.

Whereabouts in the kernel is this policy implemented? 
determine_dirtyable_memory()?  It does (or can) consider highmem
pages?  Comment seems wrong?

Should we rename determine_dirtyable_memory() to
global_dirtyable_memory(), to get some sense of its relationship with
zone_dirtyable_memory()?

> +	 * But we allow individual highmem zones to hold a potentially
> +	 * bigger share of that global amount of dirty pages as long
> +	 * as they have enough free or reclaimable pages around.
> +	 */
> +	x = zone_page_state(zone, NR_FREE_PAGES) - zone->totalreserve_pages;
> +	x += zone_reclaimable_pages(zone);
> +	return x;
> +}
> +
> 
> ...
>
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

So passing zone==NULL alters dirty_limits()'s behaviour.  Seems that it
flips the function between global_dirty_limits and zone_dirty_limits?

Would it be better if we actually had separate global_dirty_limits()
and zone_dirty_limits() rather than a magical mode?

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
> 
> ...
>
> +bool zone_dirty_ok(struct zone *zone)

Full description of the return value, please.

> +{
> +	unsigned long background_thresh, dirty_thresh;
> +
> +	dirty_limits(zone, &background_thresh, &dirty_thresh);
> +
> +	return zone_page_state(zone, NR_FILE_DIRTY) +
> +		zone_page_state(zone, NR_UNSTABLE_NFS) +
> +		zone_page_state(zone, NR_WRITEBACK) <= dirty_thresh;
> +}

We never needed to calculate &background_thresh,.  I wonder if that
matters.

> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
