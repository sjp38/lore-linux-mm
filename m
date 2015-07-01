Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4216B006E
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 03:50:16 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so37100059wib.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 00:50:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ht6si2568230wib.102.2015.07.01.00.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 00:50:13 -0700 (PDT)
Date: Wed, 1 Jul 2015 09:50:09 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 40/51] writeback: make bdi_start_background_writeback()
 take bdi_writeback instead of backing_dev_info
Message-ID: <20150701075009.GA7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-41-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-41-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:13:54, Tejun Heo wrote:
> bdi_start_background_writeback() currently takes @bdi and kicks the
> root wb (bdi_writeback).  In preparation for cgroup writeback support,
> make it take wb instead.
> 
> This patch doesn't make any functional difference.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>
> ---
>  fs/fs-writeback.c           | 12 ++++++------
>  include/linux/backing-dev.h |  2 +-
>  mm/page-writeback.c         |  4 ++--
>  3 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 45baf6c..92aaf64 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -228,23 +228,23 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  }
>  
>  /**
> - * bdi_start_background_writeback - start background writeback
> - * @bdi: the backing device to write from
> + * wb_start_background_writeback - start background writeback
> + * @wb: bdi_writback to write from
>   *
>   * Description:
>   *   This makes sure WB_SYNC_NONE background writeback happens. When
> - *   this function returns, it is only guaranteed that for given BDI
> + *   this function returns, it is only guaranteed that for given wb
>   *   some IO is happening if we are over background dirty threshold.
>   *   Caller need not hold sb s_umount semaphore.
>   */
> -void bdi_start_background_writeback(struct backing_dev_info *bdi)
> +void wb_start_background_writeback(struct bdi_writeback *wb)
>  {
>  	/*
>  	 * We just wake up the flusher thread. It will perform background
>  	 * writeback as soon as there is no other work to do.
>  	 */
> -	trace_writeback_wake_background(bdi);
> -	wb_wakeup(&bdi->wb);
> +	trace_writeback_wake_background(wb->bdi);
> +	wb_wakeup(wb);

Can we add a memcg id of the wb to the tracepoint please? Because just bdi
needn't be enough when debugging stuff...

Otherwise the patch looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza
>  }
>  
>  /*
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index f04956c..9cc11e5 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -27,7 +27,7 @@ void bdi_unregister(struct backing_dev_info *bdi);
>  int __must_check bdi_setup_and_register(struct backing_dev_info *, char *);
>  void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  			bool range_cyclic, enum wb_reason reason);
> -void bdi_start_background_writeback(struct backing_dev_info *bdi);
> +void wb_start_background_writeback(struct bdi_writeback *wb);
>  void wb_workfn(struct work_struct *work);
>  void wb_wakeup_delayed(struct bdi_writeback *wb);
>  
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index e3b5c1d..70cf98d 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1456,7 +1456,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		}
>  
>  		if (unlikely(!writeback_in_progress(wb)))
> -			bdi_start_background_writeback(bdi);
> +			wb_start_background_writeback(wb);
>  
>  		if (!strictlimit)
>  			wb_dirty_limits(wb, dirty_thresh, background_thresh,
> @@ -1588,7 +1588,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		return;
>  
>  	if (nr_reclaimable > background_thresh)
> -		bdi_start_background_writeback(bdi);
> +		wb_start_background_writeback(wb);
>  }
>  
>  static DEFINE_PER_CPU(int, bdp_ratelimits);
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
