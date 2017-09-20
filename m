Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B0F846B0033
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 10:19:58 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u138so3002274wmu.2
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 07:19:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v29si1852610edc.490.2017.09.20.07.19.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Sep 2017 07:19:57 -0700 (PDT)
Date: Wed, 20 Sep 2017 16:19:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/6] fs-writeback: provide a wakeup_flusher_threads_bdi()
Message-ID: <20170920141957.GC11106@quack2.suse.cz>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-3-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505850787-18311-3-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On Tue 19-09-17 13:53:03, Jens Axboe wrote:
> Similar to wakeup_flusher_threads(), except that we only wake
> up the flusher threads on the specified backing device.
> 
> No functional changes in this patch.
> 
> Signed-off-by: Jens Axboe <axboe@kernel.dk>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/fs-writeback.c         | 40 ++++++++++++++++++++++++++++++----------
>  include/linux/writeback.h |  2 ++
>  2 files changed, 32 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 245c430a2e41..03fda0830bf8 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -1947,6 +1947,34 @@ void wb_workfn(struct work_struct *work)
>  }
>  
>  /*
> + * Start writeback of `nr_pages' pages on this bdi. If `nr_pages' is zero,
> + * write back the whole world.
> + */
> +static void __wakeup_flusher_threads_bdi(struct backing_dev_info *bdi,
> +					 long nr_pages, enum wb_reason reason)
> +{
> +	struct bdi_writeback *wb;
> +
> +	if (!bdi_has_dirty_io(bdi))
> +		return;
> +
> +	list_for_each_entry_rcu(wb, &bdi->wb_list, bdi_node)
> +		wb_start_writeback(wb, wb_split_bdi_pages(wb, nr_pages),
> +					   false, reason);
> +}
> +
> +void wakeup_flusher_threads_bdi(struct backing_dev_info *bdi, long nr_pages,
> +				enum wb_reason reason)
> +{
> +	if (!nr_pages)
> +		nr_pages = get_nr_dirty_pages();
> +
> +	rcu_read_lock();
> +	__wakeup_flusher_threads_bdi(bdi, nr_pages, reason);
> +	rcu_read_unlock();
> +}
> +
> +/*
>   * Start writeback of `nr_pages' pages.  If `nr_pages' is zero, write back
>   * the whole world.
>   */
> @@ -1964,16 +1992,8 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
>  		nr_pages = get_nr_dirty_pages();
>  
>  	rcu_read_lock();
> -	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
> -		struct bdi_writeback *wb;
> -
> -		if (!bdi_has_dirty_io(bdi))
> -			continue;
> -
> -		list_for_each_entry_rcu(wb, &bdi->wb_list, bdi_node)
> -			wb_start_writeback(wb, wb_split_bdi_pages(wb, nr_pages),
> -					   false, reason);
> -	}
> +	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list)
> +		__wakeup_flusher_threads_bdi(bdi, nr_pages, reason);
>  	rcu_read_unlock();
>  }
>  
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index d5815794416c..5a7ed74d1f6f 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -190,6 +190,8 @@ bool try_to_writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
>  				   enum wb_reason reason);
>  void sync_inodes_sb(struct super_block *);
>  void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
> +void wakeup_flusher_threads_bdi(struct backing_dev_info *bdi, long nr_pages,
> +				enum wb_reason reason);
>  void inode_wait_for_writeback(struct inode *inode);
>  
>  /* writeback.h requires fs.h; it, too, is not included from here. */
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
