Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1FDF6B0038
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 05:22:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id k126so1461516wmd.5
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 02:22:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t33si5362895edd.129.2017.11.22.02.22.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 02:22:01 -0800 (PST)
Date: Wed, 22 Nov 2017 11:21:59 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 06/10] writeback: add counters for metadata usage
Message-ID: <20171122102159.GC11233@quack2.suse.cz>
References: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
 <1510696616-8489-6-git-send-email-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510696616-8489-6-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Tue 14-11-17 16:56:52, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> Btrfs has no bounds except memory on the amount of dirty memory that we have in
> use for metadata.  Historically we have used a special inode so we could take
> advantage of the balance_dirty_pages throttling that comes with using pagecache.
> However as we'd like to support different blocksizes it would be nice to not
> have to rely on pagecache, but still get the balance_dirty_pages throttling
> without having to do it ourselves.
> 
> So introduce *METADATA_DIRTY_BYTES and *METADATA_WRITEBACK_BYTES.  These are
> zone and bdi_writeback counters to keep track of how many bytes we have in
> flight for METADATA.  We need to count in bytes as blocksizes could be
> percentages of pagesize.  We simply convert the bytes to number of pages where
> it is needed for the throttling.
> 
> Also introduce NR_METADATA_BYTES so we can keep track of the total amount of
> pages used for metadata on the system.  This is also needed so things like dirty
> throttling know that this is dirtyable memory as well and easily reclaimed.

NR_METADATA_BYTES never gets set in the patch set. Either remove this or
implement it properly. Also for memory reclaim properties we already have
NR_SLAB_RECLAIMABLE so you should make sure your metadata buffers are not
double accounted.

Another catch is that node and zone counters are kept in longs. So on
32-bit archs you will overflow the counters if number of metadata (or dirty
metadata) ever exceeds 2GB. That should be rare but still possible. Not
sure what the right answer to this is... Account in 512-byte units?

> @@ -1549,12 +1579,17 @@ static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
>  	 * deltas.
>  	 */
>  	if (dtc->wb_thresh < 2 * wb_stat_error(wb)) {
> -		wb_reclaimable = wb_stat_sum(wb, WB_RECLAIMABLE);
> -		dtc->wb_dirty = wb_reclaimable + wb_stat_sum(wb, WB_WRITEBACK);
> +		wb_reclaimable = wb_stat_sum(wb, WB_RECLAIMABLE) +
> +			(wb_stat_sum(wb, WB_METADATA_DIRTY_BYTES) >> PAGE_SHIFT);
> +		wb_writeback = wb_stat_sum(wb, WB_WRITEBACK) +
> +			(wb_stat_sum(wb, WB_METADATA_WRITEBACK_BYTES) >> PAGE_SHIFT);
>  	} else {
> -		wb_reclaimable = wb_stat(wb, WB_RECLAIMABLE);
> -		dtc->wb_dirty = wb_reclaimable + wb_stat(wb, WB_WRITEBACK);
> +		wb_reclaimable = wb_stat(wb, WB_RECLAIMABLE) +
> +			(wb_stat(wb, WB_METADATA_DIRTY_BYTES) >> PAGE_SHIFT);
> +		wb_writeback = wb_stat(wb, WB_WRITEBACK) +
> +			(wb_stat(wb, WB_METADATA_WRITEBACK_BYTES) >> PAGE_SHIFT);
>  	}
> +	dtc->wb_dirty = wb_reclaimable + wb_writeback;
>  }

Use BtoP here as well? You have it defined anyway...

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 13d711dd8776..415b003e475c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -225,7 +225,8 @@ unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
>  
>  	nr = node_page_state_snapshot(pgdat, NR_ACTIVE_FILE) +
>  	     node_page_state_snapshot(pgdat, NR_INACTIVE_FILE) +
> -	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE);
> +	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE) +
> +	     (node_page_state_snapshot(pgdat, NR_METADATA_BYTES) >> PAGE_SHIFT);
>  
>  	if (get_nr_swap_pages() > 0)
>  		nr += node_page_state_snapshot(pgdat, NR_ACTIVE_ANON) +

This function never gets called in current kernel. I'll send a patch to
remove it.

> @@ -3812,6 +3813,7 @@ static inline unsigned long node_unmapped_file_pages(struct pglist_data *pgdat)
>  static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
>  {
>  	unsigned long nr_pagecache_reclaimable;
> +	unsigned long nr_metadata_reclaimable;
>  	unsigned long delta = 0;
>  
>  	/*
> @@ -3833,7 +3835,20 @@ static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
>  	if (unlikely(delta > nr_pagecache_reclaimable))
>  		delta = nr_pagecache_reclaimable;
>  
> -	return nr_pagecache_reclaimable - delta;
> +	nr_metadata_reclaimable =
> +		node_page_state(pgdat, NR_METADATA_BYTES) >> PAGE_SHIFT;
> +	/*
> +	 * We don't do writeout through the shrinkers so subtract any
> +	 * dirty/writeback metadata bytes from the reclaimable count.
> +	 */
> +	if (nr_metadata_reclaimable) {
> +		unsigned long unreclaimable =
> +			node_page_state(pgdat, NR_METADATA_DIRTY_BYTES) +
> +			node_page_state(pgdat, NR_METADATA_WRITEBACK_BYTES);
> +		unreclaimable >>= PAGE_SHIFT;
> +		nr_metadata_reclaimable -= unreclaimable;
> +	}
> +	return nr_metadata_reclaimable + nr_pagecache_reclaimable - delta;
>  }

So I've checked both places that use this function and I think they are fine
with the change. However it would still be good to get someone more
knowledgeable of reclaim paths to have a look at this patch.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
