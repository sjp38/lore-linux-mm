Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5156B0298
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 08:06:34 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p17so12979034pfh.18
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 05:06:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u10si236684pgc.32.2017.12.04.05.06.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 05:06:33 -0800 (PST)
Date: Mon, 4 Dec 2017 14:06:30 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 06/11] writeback: add counters for metadata usage
Message-ID: <20171204130630.GB17047@quack2.suse.cz>
References: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
 <1511385366-20329-7-git-send-email-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511385366-20329-7-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Wed 22-11-17 16:16:01, Josef Bacik wrote:
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

I'll defer to mm guys for final decision but the fact is the memory for
metadata is likely to be allocated from some slab cache and that actually
goes against the 'easily reclaimed' statement. Granted these are going to
be relatively large objects (1k at least I assume) so fragmentation issues
are not as bad but still getting actual free pages out of slab cache isn't
that easy... More on this below.

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 356a814e7c8e..fd516a0f0bfe 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -179,6 +179,9 @@ enum node_stat_item {
>  	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
>  	NR_DIRTIED,		/* page dirtyings since bootup */
>  	NR_WRITTEN,		/* page writings since bootup */
> +	NR_METADATA_DIRTY_BYTES,	/* Metadata dirty bytes */
> +	NR_METADATA_WRITEBACK_BYTES,	/* Metadata writeback bytes */
> +	NR_METADATA_BYTES,	/* total metadata bytes in use. */
>  	NR_VM_NODE_STAT_ITEMS
>  };

I think you didn't address my comment from last version of the series.

1) Per-cpu node-stat batching will be basically useless for these counters
as the batch size is <128. Maybe we don't care but it would deserve a
comment.

2) These counters are tracked in atomic_long_t type. That means max 2GB of
metadata on 32-bit machines. I *guess* that should be OK since you would
not be able to address that much of slab cache on such machine anyway but 
still worth a comment I think.

> diff --git a/mm/util.c b/mm/util.c
> index 34e57fae959d..681d62631ee0 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -616,6 +616,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
>  		free = global_zone_page_state(NR_FREE_PAGES);
>  		free += global_node_page_state(NR_FILE_PAGES);
> +		free += global_node_page_state(NR_METADATA_BYTES) >> PAGE_SHIFT;


I'm not really sure this is OK. It depends on whether mm is really able to
reclaim these pages easily enough... Summon mm people for help :)

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

Just drop this hunk. The function is going away (and is currently unused).

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

Ditto as with __vm_enough_memory(). In particular I'm unsure whether the
watermarks like min_unmapped_pages or min_slab_pages would still work as
designed.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
