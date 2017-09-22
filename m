Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64DD26B0033
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 09:17:03 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m127so1405072wmm.3
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 06:17:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si2520758edc.221.2017.09.22.06.17.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Sep 2017 06:17:02 -0700 (PDT)
Date: Fri, 22 Sep 2017 15:17:01 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/7] fs-writeback: move nr_pages == 0 logic to one
 location
Message-ID: <20170922131701.GC22455@quack2.suse.cz>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
 <1505921582-26709-7-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505921582-26709-7-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On Wed 20-09-17 09:33:01, Jens Axboe wrote:
> Now that we have no external callers of wb_start_writeback(), we
> can shuffle the passing in of 'nr_pages'. Everybody passes in 0
> at this point, so just kill the argument and move the dirty
> count retrieval to that function.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Tested-by: Chris Mason <clm@fb.com>
> Signed-off-by: Jens Axboe <axboe@kernel.dk>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

										Honza

> ---
>  fs/fs-writeback.c | 42 ++++++++++++++++++------------------------
>  1 file changed, 18 insertions(+), 24 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index ecbd26d1121d..3916ea2484ae 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -933,8 +933,19 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
>  
>  #endif	/* CONFIG_CGROUP_WRITEBACK */
>  
> -static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
> -			       bool range_cyclic, enum wb_reason reason)
> +/*
> + * Add in the number of potentially dirty inodes, because each inode
> + * write can dirty pagecache in the underlying blockdev.
> + */
> +static unsigned long get_nr_dirty_pages(void)
> +{
> +	return global_node_page_state(NR_FILE_DIRTY) +
> +		global_node_page_state(NR_UNSTABLE_NFS) +
> +		get_nr_dirty_inodes();
> +}
> +
> +static void wb_start_writeback(struct bdi_writeback *wb, bool range_cyclic,
> +			       enum wb_reason reason)
>  {
>  	struct wb_writeback_work *work;
>  
> @@ -954,7 +965,7 @@ static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  	}
>  
>  	work->sync_mode	= WB_SYNC_NONE;
> -	work->nr_pages	= nr_pages;
> +	work->nr_pages	= wb_split_bdi_pages(wb, get_nr_dirty_pages());
>  	work->range_cyclic = range_cyclic;
>  	work->reason	= reason;
>  	work->auto_free	= 1;
> @@ -1814,17 +1825,6 @@ static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
>  	return work;
>  }
>  
> -/*
> - * Add in the number of potentially dirty inodes, because each inode
> - * write can dirty pagecache in the underlying blockdev.
> - */
> -static unsigned long get_nr_dirty_pages(void)
> -{
> -	return global_node_page_state(NR_FILE_DIRTY) +
> -		global_node_page_state(NR_UNSTABLE_NFS) +
> -		get_nr_dirty_inodes();
> -}
> -
>  static long wb_check_background_flush(struct bdi_writeback *wb)
>  {
>  	if (wb_over_bg_thresh(wb)) {
> @@ -1951,7 +1951,7 @@ void wb_workfn(struct work_struct *work)
>   * write back the whole world.
>   */
>  static void __wakeup_flusher_threads_bdi(struct backing_dev_info *bdi,
> -					 long nr_pages, enum wb_reason reason)
> +					 enum wb_reason reason)
>  {
>  	struct bdi_writeback *wb;
>  
> @@ -1959,17 +1959,14 @@ static void __wakeup_flusher_threads_bdi(struct backing_dev_info *bdi,
>  		return;
>  
>  	list_for_each_entry_rcu(wb, &bdi->wb_list, bdi_node)
> -		wb_start_writeback(wb, wb_split_bdi_pages(wb, nr_pages),
> -					   false, reason);
> +		wb_start_writeback(wb, false, reason);
>  }
>  
>  void wakeup_flusher_threads_bdi(struct backing_dev_info *bdi,
>  				enum wb_reason reason)
>  {
> -	long nr_pages = get_nr_dirty_pages();
> -
>  	rcu_read_lock();
> -	__wakeup_flusher_threads_bdi(bdi, nr_pages, reason);
> +	__wakeup_flusher_threads_bdi(bdi, reason);
>  	rcu_read_unlock();
>  }
>  
> @@ -1979,7 +1976,6 @@ void wakeup_flusher_threads_bdi(struct backing_dev_info *bdi,
>  void wakeup_flusher_threads(enum wb_reason reason)
>  {
>  	struct backing_dev_info *bdi;
> -	long nr_pages;
>  
>  	/*
>  	 * If we are expecting writeback progress we must submit plugged IO.
> @@ -1987,11 +1983,9 @@ void wakeup_flusher_threads(enum wb_reason reason)
>  	if (blk_needs_flush_plug(current))
>  		blk_schedule_flush_plug(current);
>  
> -	nr_pages = get_nr_dirty_pages();
> -
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list)
> -		__wakeup_flusher_threads_bdi(bdi, nr_pages, reason);
> +		__wakeup_flusher_threads_bdi(bdi, reason);
>  	rcu_read_unlock();
>  }
>  
> -- 
> 2.7.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
