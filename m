Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A6B9F6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 04:17:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so8446591wmz.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 01:17:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d23si1882231wmh.91.2016.09.09.01.17.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 01:17:50 -0700 (PDT)
Date: Fri, 9 Sep 2016 10:17:43 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/3] writeback: allow for dirty metadata accounting
Message-ID: <20160909081743.GC22777@quack2.suse.cz>
References: <1471887302-12730-1-git-send-email-jbacik@fb.com>
 <1471887302-12730-3-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471887302-12730-3-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <jbacik@fb.com>
Cc: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org

On Mon 22-08-16 13:35:01, Josef Bacik wrote:
> Provide a mechanism for file systems to indicate how much dirty metadata they
> are holding.  This introduces a few things
> 
> 1) Zone stats for dirty metadata, which is the same as the NR_FILE_DIRTY.
> 2) WB stat for dirty metadata.  This way we know if we need to try and call into
> the file system to write out metadata.  This could potentially be used in the
> future to make balancing of dirty pages smarter.

So I'm curious about one thing: In the previous posting you have mentioned
that the main motivation for this work is to have a simple support for
sub-pagesize dirty metadata blocks that need tracking in btrfs. However you
do the dirty accounting at page granularity. What are your plans to handle
this mismatch?

The thing is you actually shouldn't miscount by too much as that could
upset some checks in mm checking how much dirty pages a node has directing
how reclaim should be done... But it's a question whether NR_METADATA_DIRTY
should be actually used in the checks in node_limits_ok() or in
node_pagecache_reclaimable() at all because once you start accounting dirty
slab objects, you are really on a thin ice...

> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 56c8fda..d329f89 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -1809,6 +1809,7 @@ static unsigned long get_nr_dirty_pages(void)
>  {
>  	return global_node_page_state(NR_FILE_DIRTY) +
>  		global_node_page_state(NR_UNSTABLE_NFS) +
> +		global_node_page_state(NR_METADATA_DIRTY) +
>  		get_nr_dirty_inodes();

With my question is also connected this - when we have NR_METADATA_DIRTY,
we could just account dirty inodes there and get rid of this
get_nr_dirty_inodes() hack...

But actually getting this to work right to be able to track dirty inodes would
be useful on its own - some throlling of creation of dirty inodes would be
useful for several filesystems (ext4, xfs, ...).

> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 121a6e3..6a52723 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -506,6 +506,7 @@ bool node_dirty_ok(struct pglist_data *pgdat)
>  	nr_pages += node_page_state(pgdat, NR_FILE_DIRTY);
>  	nr_pages += node_page_state(pgdat, NR_UNSTABLE_NFS);
>  	nr_pages += node_page_state(pgdat, NR_WRITEBACK);
> +	nr_pages += node_page_state(pgdat, NR_METADATA_DIRTY);
>  
>  	return nr_pages <= limit;
>  }
> @@ -1595,7 +1596,8 @@ static void balance_dirty_pages(struct bdi_writeback *wb,
>  		 * been flushed to permanent storage.
>  		 */
>  		nr_reclaimable = global_node_page_state(NR_FILE_DIRTY) +
> -					global_node_page_state(NR_UNSTABLE_NFS);
> +				global_node_page_state(NR_UNSTABLE_NFS) +
> +				global_node_page_state(NR_METADATA_DIRTY);
>  		gdtc->avail = global_dirtyable_memory();
>  		gdtc->dirty = nr_reclaimable + global_node_page_state(NR_WRITEBACK);
>  
> @@ -1935,7 +1937,8 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
>  	 */
>  	gdtc->avail = global_dirtyable_memory();
>  	gdtc->dirty = global_node_page_state(NR_FILE_DIRTY) +
> -		      global_node_page_state(NR_UNSTABLE_NFS);
> +		      global_node_page_state(NR_UNSTABLE_NFS) +
> +		      global_node_page_state(NR_METADATA_DIRTY);
>  	domain_dirty_limits(gdtc);
>  
>  	if (gdtc->dirty > gdtc->bg_thresh)
> @@ -2009,7 +2012,8 @@ void laptop_mode_timer_fn(unsigned long data)
>  {
>  	struct request_queue *q = (struct request_queue *)data;
>  	int nr_pages = global_node_page_state(NR_FILE_DIRTY) +
> -		global_node_page_state(NR_UNSTABLE_NFS);
> +		global_node_page_state(NR_UNSTABLE_NFS) +
> +		global_node_page_state(NR_METADATA_DIRTY);
>  	struct bdi_writeback *wb;
>  
>  	/*
> @@ -2473,6 +2477,96 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
>  EXPORT_SYMBOL(account_page_dirtied);
>  
>  /*
> + * account_metadata_dirtied
> + * @page - the page being dirited
> + * @bdi - the bdi that owns this page
> + *
> + * Do the dirty page accounting for metadata pages that aren't backed by an
> + * address_space.
> + */
> +void account_metadata_dirtied(struct page *page, struct backing_dev_info *bdi)
> +{
> +	unsigned long flags;
> +

A bdi_cap_account_dirty() check here and in following functions?

> +	local_irq_save(flags);
> +	__inc_node_page_state(page, NR_METADATA_DIRTY);
> +	__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
> +	__inc_node_page_state(page, NR_DIRTIED);
> +	__inc_wb_stat(&bdi->wb, WB_RECLAIMABLE);
> +	__inc_wb_stat(&bdi->wb, WB_DIRTIED);
> +	__inc_wb_stat(&bdi->wb, WB_METADATA_DIRTY);
> +	current->nr_dirtied++;
> +	task_io_account_write(PAGE_SIZE);
> +	this_cpu_inc(bdp_ratelimits);
> +	local_irq_restore(flags);
> +}
> +EXPORT_SYMBOL(account_metadata_dirtied);
> +
> +/*
> + * account_metadata_cleaned
> + * @page - the page being cleaned
> + * @bdi - the bdi that owns this page
> + *
> + * Called on a no longer dirty metadata page.
> + */
> +void account_metadata_cleaned(struct page *page, struct backing_dev_info *bdi)
> +{
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +	__dec_node_page_state(page, NR_METADATA_DIRTY);
> +	__dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
> +	__dec_wb_stat(&bdi->wb, WB_RECLAIMABLE);
> +	__dec_wb_stat(&bdi->wb, WB_METADATA_DIRTY);
> +	task_io_account_cancelled_write(PAGE_SIZE);
> +	local_irq_restore(flags);
> +}
> +EXPORT_SYMBOL(account_metadata_cleaned);
> +
> +/*
> + * account_metadata_writeback
> + * @page - the page being marked as writeback
> + * @bdi - the bdi that owns this page
> + *
> + * Called on a metadata page that has been marked writeback.
> + */
> +void account_metadata_writeback(struct page *page,
> +				struct backing_dev_info *bdi)
> +{
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +	__inc_wb_stat(&bdi->wb, WB_WRITEBACK);
> +	__inc_node_page_state(page, NR_WRITEBACK);
> +	__dec_node_page_state(page, NR_METADATA_DIRTY);
> +	__dec_wb_stat(&bdi->wb, WB_METADATA_DIRTY);
> +	__dec_wb_stat(&bdi->wb, WB_RECLAIMABLE);
> +	local_irq_restore(flags);
> +}
> +EXPORT_SYMBOL(account_metadata_writeback);
> +
> +/*
> + * account_metadata_end_writeback
> + * @page - the page we are ending writeback on
> + * @bdi - the bdi that owns this page
> + *
> + * Called on a metadata page that has completed writeback.
> + */
> +void account_metadata_end_writeback(struct page *page,
> +				    struct backing_dev_info *bdi)
> +{
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +	__dec_wb_stat(&bdi->wb, WB_WRITEBACK);
> +	__dec_node_page_state(page, NR_WRITEBACK);
> +	__dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
> +	__inc_node_page_state(page, NR_WRITTEN);
> +	local_irq_restore(flags);
> +}
> +EXPORT_SYMBOL(account_metadata_end_writeback);
> +
> +/*
>   * Helper function for deaccounting dirty page without writeback.
>   *
>   * Caller must hold lock_page_memcg().
...
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 374d95d..fb3eb62 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3714,7 +3714,8 @@ static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
>  
>  	/* If we can't clean pages, remove dirty pages from consideration */
>  	if (!(node_reclaim_mode & RECLAIM_WRITE))
> -		delta += node_page_state(pgdat, NR_FILE_DIRTY);
> +		delta += node_page_state(pgdat, NR_FILE_DIRTY) +
> +			node_page_state(pgdat, NR_METADATA_DIRTY);
>  
>  	/* Watch for any possible underflows due to delta */
>  	if (unlikely(delta > nr_pagecache_reclaimable))

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
