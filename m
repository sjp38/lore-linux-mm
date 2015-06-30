Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 04C976B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 10:50:49 -0400 (EDT)
Received: by wgck11 with SMTP id k11so12066732wgc.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 07:50:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k16si71994288wjr.0.2015.06.30.07.50.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jun 2015 07:50:47 -0700 (PDT)
Date: Tue, 30 Jun 2015 16:50:41 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 27/51] writeback: make congestion functions per
 bdi_writeback
Message-ID: <20150630145041.GM7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-28-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-28-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:13:41, Tejun Heo wrote:
> Currently, all congestion functions take bdi (backing_dev_info) and
> always operate on the root wb (bdi->wb) and the congestion state from
> the block layer is propagated only for the root blkcg.  This patch
> introduces {set|clear}_wb_congested() and wb_congested() which take a
> bdi_writeback_congested and bdi_writeback respectively.  The bdi
> counteparts are now wrappers invoking the wb based functions on
> @bdi->wb.
> 
> While converting clear_bdi_congested() to clear_wb_congested(), the
> local variable declaration order between @wqh and @bit is swapped for
> cosmetic reason.
> 
> This patch just adds the new wb based functions.  The following
> patches will apply them.

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza

> 
> v2: Updated for bdi_writeback_congested.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Cc: Jens Axboe <axboe@kernel.dk>
> ---
>  include/linux/backing-dev-defs.h | 14 +++++++++++--
>  include/linux/backing-dev.h      | 45 +++++++++++++++++++++++-----------------
>  mm/backing-dev.c                 | 22 ++++++++++----------
>  3 files changed, 49 insertions(+), 32 deletions(-)
> 
> diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
> index a1e9c40..eb38676 100644
> --- a/include/linux/backing-dev-defs.h
> +++ b/include/linux/backing-dev-defs.h
> @@ -163,7 +163,17 @@ enum {
>  	BLK_RW_SYNC	= 1,
>  };
>  
> -void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
> -void set_bdi_congested(struct backing_dev_info *bdi, int sync);
> +void clear_wb_congested(struct bdi_writeback_congested *congested, int sync);
> +void set_wb_congested(struct bdi_writeback_congested *congested, int sync);
> +
> +static inline void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
> +{
> +	clear_wb_congested(bdi->wb.congested, sync);
> +}
> +
> +static inline void set_bdi_congested(struct backing_dev_info *bdi, int sync)
> +{
> +	set_wb_congested(bdi->wb.congested, sync);
> +}
>  
>  #endif	/* __LINUX_BACKING_DEV_DEFS_H */
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 8ae59df..2c498a2 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -167,27 +167,13 @@ static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
>  	return sb->s_bdi;
>  }
>  
> -static inline int bdi_congested(struct backing_dev_info *bdi, int bdi_bits)
> +static inline int wb_congested(struct bdi_writeback *wb, int cong_bits)
>  {
> -	if (bdi->congested_fn)
> -		return bdi->congested_fn(bdi->congested_data, bdi_bits);
> -	return (bdi->wb.congested->state & bdi_bits);
> -}
> -
> -static inline int bdi_read_congested(struct backing_dev_info *bdi)
> -{
> -	return bdi_congested(bdi, 1 << WB_sync_congested);
> -}
> -
> -static inline int bdi_write_congested(struct backing_dev_info *bdi)
> -{
> -	return bdi_congested(bdi, 1 << WB_async_congested);
> -}
> +	struct backing_dev_info *bdi = wb->bdi;
>  
> -static inline int bdi_rw_congested(struct backing_dev_info *bdi)
> -{
> -	return bdi_congested(bdi, (1 << WB_sync_congested) |
> -				  (1 << WB_async_congested));
> +	if (bdi->congested_fn)
> +		return bdi->congested_fn(bdi->congested_data, cong_bits);
> +	return wb->congested->state & cong_bits;
>  }
>  
>  long congestion_wait(int sync, long timeout);
> @@ -454,4 +440,25 @@ static inline void wb_blkcg_offline(struct blkcg *blkcg)
>  
>  #endif	/* CONFIG_CGROUP_WRITEBACK */
>  
> +static inline int bdi_congested(struct backing_dev_info *bdi, int cong_bits)
> +{
> +	return wb_congested(&bdi->wb, cong_bits);
> +}
> +
> +static inline int bdi_read_congested(struct backing_dev_info *bdi)
> +{
> +	return bdi_congested(bdi, 1 << WB_sync_congested);
> +}
> +
> +static inline int bdi_write_congested(struct backing_dev_info *bdi)
> +{
> +	return bdi_congested(bdi, 1 << WB_async_congested);
> +}
> +
> +static inline int bdi_rw_congested(struct backing_dev_info *bdi)
> +{
> +	return bdi_congested(bdi, (1 << WB_sync_congested) |
> +				  (1 << WB_async_congested));
> +}
> +
>  #endif	/* _LINUX_BACKING_DEV_H */
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 4c9386c..5029c4a 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -896,31 +896,31 @@ static wait_queue_head_t congestion_wqh[2] = {
>  		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[0]),
>  		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
>  	};
> -static atomic_t nr_bdi_congested[2];
> +static atomic_t nr_wb_congested[2];
>  
> -void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
> +void clear_wb_congested(struct bdi_writeback_congested *congested, int sync)
>  {
> -	enum wb_state bit;
>  	wait_queue_head_t *wqh = &congestion_wqh[sync];
> +	enum wb_state bit;
>  
>  	bit = sync ? WB_sync_congested : WB_async_congested;
> -	if (test_and_clear_bit(bit, &bdi->wb.congested->state))
> -		atomic_dec(&nr_bdi_congested[sync]);
> +	if (test_and_clear_bit(bit, &congested->state))
> +		atomic_dec(&nr_wb_congested[sync]);
>  	smp_mb__after_atomic();
>  	if (waitqueue_active(wqh))
>  		wake_up(wqh);
>  }
> -EXPORT_SYMBOL(clear_bdi_congested);
> +EXPORT_SYMBOL(clear_wb_congested);
>  
> -void set_bdi_congested(struct backing_dev_info *bdi, int sync)
> +void set_wb_congested(struct bdi_writeback_congested *congested, int sync)
>  {
>  	enum wb_state bit;
>  
>  	bit = sync ? WB_sync_congested : WB_async_congested;
> -	if (!test_and_set_bit(bit, &bdi->wb.congested->state))
> -		atomic_inc(&nr_bdi_congested[sync]);
> +	if (!test_and_set_bit(bit, &congested->state))
> +		atomic_inc(&nr_wb_congested[sync]);
>  }
> -EXPORT_SYMBOL(set_bdi_congested);
> +EXPORT_SYMBOL(set_wb_congested);
>  
>  /**
>   * congestion_wait - wait for a backing_dev to become uncongested
> @@ -979,7 +979,7 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
>  	 * encountered in the current zone, yield if necessary instead
>  	 * of sleeping on the congestion queue
>  	 */
> -	if (atomic_read(&nr_bdi_congested[sync]) == 0 ||
> +	if (atomic_read(&nr_wb_congested[sync]) == 0 ||
>  	    !test_bit(ZONE_CONGESTED, &zone->flags)) {
>  		cond_resched();
>  
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
