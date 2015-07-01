Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id C2AAA6B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 03:30:55 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so49473924wid.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 00:30:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bo1si1882081wjb.27.2015.07.01.00.30.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 00:30:54 -0700 (PDT)
Date: Wed, 1 Jul 2015 09:30:50 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 37/51] writeback: remove bdi_start_writeback()
Message-ID: <20150701073050.GX7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-38-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-38-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:13:51, Tejun Heo wrote:
> bdi_start_writeback() is a thin wrapper on top of
> __wb_start_writeback() which is used only by laptop_mode_timer_fn().
> This patches removes bdi_start_writeback(), renames
> __wb_start_writeback() to wb_start_writeback() and makes
> laptop_mode_timer_fn() use it instead.
> 
> This doesn't cause any functional difference and will ease making
> laptop_mode_timer_fn() cgroup writeback aware.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza

> ---
>  fs/fs-writeback.c           | 68 +++++++++++++++++----------------------------
>  include/linux/backing-dev.h |  4 +--
>  mm/page-writeback.c         |  4 +--
>  3 files changed, 29 insertions(+), 47 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 921a9e4..79f11af 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -184,33 +184,6 @@ static void wb_queue_work(struct bdi_writeback *wb,
>  	spin_unlock_bh(&wb->work_lock);
>  }
>  
> -static void __wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
> -				 bool range_cyclic, enum wb_reason reason)
> -{
> -	struct wb_writeback_work *work;
> -
> -	if (!wb_has_dirty_io(wb))
> -		return;
> -
> -	/*
> -	 * This is WB_SYNC_NONE writeback, so if allocation fails just
> -	 * wakeup the thread for old dirty data writeback
> -	 */
> -	work = kzalloc(sizeof(*work), GFP_ATOMIC);
> -	if (!work) {
> -		trace_writeback_nowork(wb->bdi);
> -		wb_wakeup(wb);
> -		return;
> -	}
> -
> -	work->sync_mode	= WB_SYNC_NONE;
> -	work->nr_pages	= nr_pages;
> -	work->range_cyclic = range_cyclic;
> -	work->reason	= reason;
> -
> -	wb_queue_work(wb, work);
> -}
> -
>  #ifdef CONFIG_CGROUP_WRITEBACK
>  
>  /**
> @@ -240,22 +213,31 @@ EXPORT_SYMBOL_GPL(inode_congested);
>  
>  #endif	/* CONFIG_CGROUP_WRITEBACK */
>  
> -/**
> - * bdi_start_writeback - start writeback
> - * @bdi: the backing device to write from
> - * @nr_pages: the number of pages to write
> - * @reason: reason why some writeback work was initiated
> - *
> - * Description:
> - *   This does WB_SYNC_NONE opportunistic writeback. The IO is only
> - *   started when this function returns, we make no guarantees on
> - *   completion. Caller need not hold sb s_umount semaphore.
> - *
> - */
> -void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
> -			enum wb_reason reason)
> +void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
> +			bool range_cyclic, enum wb_reason reason)
>  {
> -	__wb_start_writeback(&bdi->wb, nr_pages, true, reason);
> +	struct wb_writeback_work *work;
> +
> +	if (!wb_has_dirty_io(wb))
> +		return;
> +
> +	/*
> +	 * This is WB_SYNC_NONE writeback, so if allocation fails just
> +	 * wakeup the thread for old dirty data writeback
> +	 */
> +	work = kzalloc(sizeof(*work), GFP_ATOMIC);
> +	if (!work) {
> +		trace_writeback_nowork(wb->bdi);
> +		wb_wakeup(wb);
> +		return;
> +	}
> +
> +	work->sync_mode	= WB_SYNC_NONE;
> +	work->nr_pages	= nr_pages;
> +	work->range_cyclic = range_cyclic;
> +	work->reason	= reason;
> +
> +	wb_queue_work(wb, work);
>  }
>  
>  /**
> @@ -1219,7 +1201,7 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
>  
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list)
> -		__wb_start_writeback(&bdi->wb, nr_pages, false, reason);
> +		wb_start_writeback(&bdi->wb, nr_pages, false, reason);
>  	rcu_read_unlock();
>  }
>  
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index c797980..0ff40c2 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -25,8 +25,8 @@ int bdi_register(struct backing_dev_info *bdi, struct device *parent,
>  int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev);
>  void bdi_unregister(struct backing_dev_info *bdi);
>  int __must_check bdi_setup_and_register(struct backing_dev_info *, char *);
> -void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
> -			enum wb_reason reason);
> +void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
> +			bool range_cyclic, enum wb_reason reason);
>  void bdi_start_background_writeback(struct backing_dev_info *bdi);
>  void wb_workfn(struct work_struct *work);
>  void wb_wakeup_delayed(struct bdi_writeback *wb);
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 9b55f12..6301af2 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1729,8 +1729,8 @@ void laptop_mode_timer_fn(unsigned long data)
>  	 * threshold
>  	 */
>  	if (bdi_has_dirty_io(&q->backing_dev_info))
> -		bdi_start_writeback(&q->backing_dev_info, nr_pages,
> -					WB_REASON_LAPTOP_TIMER);
> +		wb_start_writeback(&q->backing_dev_info.wb, nr_pages, true,
> +				   WB_REASON_LAPTOP_TIMER);
>  }
>  
>  /*
> -- 
> 2.4.0
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
