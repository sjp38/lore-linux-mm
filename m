Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 10D3A6B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:21:35 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so10472897wib.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 02:21:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fb4si18247544wib.102.2015.06.30.02.21.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jun 2015 02:21:33 -0700 (PDT)
Date: Tue, 30 Jun 2015 11:21:27 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 21/51] bdi: separate out congested state into a separate
 struct
Message-ID: <20150630092127.GG7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-22-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-22-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:13:35, Tejun Heo wrote:
> Currently, a wb's (bdi_writeback) congestion state is carried in its
> ->state field; however, cgroup writeback support will require multiple
> wb's sharing the same congestion state.  This patch separates out
> congestion state into its own struct - struct bdi_writeback_congested.
> A new field wb field, wb_congested, points to its associated congested
> struct.  The default wb, bdi->wb, always points to bdi->wb_congested.
> 
> While this patch adds a layer of indirection, it doesn't introduce any
> behavior changes.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza

> ---
>  include/linux/backing-dev-defs.h | 14 ++++++++++++--
>  include/linux/backing-dev.h      |  2 +-
>  mm/backing-dev.c                 |  7 +++++--
>  3 files changed, 18 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
> index aa18c4b..9e9eafa 100644
> --- a/include/linux/backing-dev-defs.h
> +++ b/include/linux/backing-dev-defs.h
> @@ -16,12 +16,15 @@ struct dentry;
>   * Bits in bdi_writeback.state
>   */
>  enum wb_state {
> -	WB_async_congested,	/* The async (write) queue is getting full */
> -	WB_sync_congested,	/* The sync queue is getting full */
>  	WB_registered,		/* bdi_register() was done */
>  	WB_writeback_running,	/* Writeback is in progress */
>  };
>  
> +enum wb_congested_state {
> +	WB_async_congested,	/* The async (write) queue is getting full */
> +	WB_sync_congested,	/* The sync queue is getting full */
> +};
> +
>  typedef int (congested_fn)(void *, int);
>  
>  enum wb_stat_item {
> @@ -34,6 +37,10 @@ enum wb_stat_item {
>  
>  #define WB_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))
>  
> +struct bdi_writeback_congested {
> +	unsigned long state;		/* WB_[a]sync_congested flags */
> +};
> +
>  struct bdi_writeback {
>  	struct backing_dev_info *bdi;	/* our parent bdi */
>  
> @@ -48,6 +55,8 @@ struct bdi_writeback {
>  
>  	struct percpu_counter stat[NR_WB_STAT_ITEMS];
>  
> +	struct bdi_writeback_congested *congested;
> +
>  	unsigned long bw_time_stamp;	/* last time write bw is updated */
>  	unsigned long dirtied_stamp;
>  	unsigned long written_stamp;	/* pages written at bw_time_stamp */
> @@ -84,6 +93,7 @@ struct backing_dev_info {
>  	unsigned int max_ratio, max_prop_frac;
>  
>  	struct bdi_writeback wb;  /* default writeback info for this bdi */
> +	struct bdi_writeback_congested wb_congested;
>  
>  	struct device *dev;
>  
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 7857820..bfdaa18 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -167,7 +167,7 @@ static inline int bdi_congested(struct backing_dev_info *bdi, int bdi_bits)
>  {
>  	if (bdi->congested_fn)
>  		return bdi->congested_fn(bdi->congested_data, bdi_bits);
> -	return (bdi->wb.state & bdi_bits);
> +	return (bdi->wb.congested->state & bdi_bits);
>  }
>  
>  static inline int bdi_read_congested(struct backing_dev_info *bdi)
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 805b287..5ec7658 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -383,6 +383,9 @@ int bdi_init(struct backing_dev_info *bdi)
>  	if (err)
>  		return err;
>  
> +	bdi->wb_congested.state = 0;
> +	bdi->wb.congested = &bdi->wb_congested;
> +
>  	return 0;
>  }
>  EXPORT_SYMBOL(bdi_init);
> @@ -504,7 +507,7 @@ void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
>  	wait_queue_head_t *wqh = &congestion_wqh[sync];
>  
>  	bit = sync ? WB_sync_congested : WB_async_congested;
> -	if (test_and_clear_bit(bit, &bdi->wb.state))
> +	if (test_and_clear_bit(bit, &bdi->wb.congested->state))
>  		atomic_dec(&nr_bdi_congested[sync]);
>  	smp_mb__after_atomic();
>  	if (waitqueue_active(wqh))
> @@ -517,7 +520,7 @@ void set_bdi_congested(struct backing_dev_info *bdi, int sync)
>  	enum wb_state bit;
>  
>  	bit = sync ? WB_sync_congested : WB_async_congested;
> -	if (!test_and_set_bit(bit, &bdi->wb.state))
> +	if (!test_and_set_bit(bit, &bdi->wb.congested->state))
>  		atomic_inc(&nr_bdi_congested[sync]);
>  }
>  EXPORT_SYMBOL(set_bdi_congested);
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
