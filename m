Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 889A56B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 05:14:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i124so23865214wmf.7
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 02:14:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l124si6290028wmg.31.2017.10.09.02.14.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 02:14:18 -0700 (PDT)
Date: Mon, 9 Oct 2017 11:14:15 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2] block/laptop_mode: Convert timers to use timer_setup()
Message-ID: <20171009091415.GD17917@quack2.suse.cz>
References: <20171005231623.GA109154@beast>
 <20171006082020.GA12192@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171006082020.GA12192@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, Jens Axboe <axboe@kernel.dk>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Nicholas Piggin <npiggin@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On Fri 06-10-17 01:20:20, Christoph Hellwig wrote:
> From 77881bd72b5fb1219fc74625b0380930f9c580df Mon Sep 17 00:00:00 2001
> From: Christoph Hellwig <hch@lst.de>
> Date: Fri, 6 Oct 2017 10:18:53 +0200
> Subject: mm: move all laptop_mode handling to backing-dev.c
> 
> It isn't block-device specific and oddly spread over multiple files
> at the moment:
> 
> TODO: audit that the unregistration changes are fine

Yeah, I'm a bit concerned about those. You cleanup the timer in
bdi_unregister() which pairs with bdi_register(). However you don't have to
call bdi_register() (and thus consequently call bdi_unregister() on
device shutdown) in order to do IO to a device. bdi_register() is only
needed to setup flusher threads and similar stuff. Also
laptop_io_completion(), which arms the timer, is called when any IO request
is completed again independently of BDI registration / unregistration.

But maybe we could just make laptop_io_completion() not arm the timer for
unregistered BDIs (calling wakeup_flusher_threads_bdi() won't have any
effect anyway) and then cleaning up the timer in bdi_unregister() would be
a safe thing to do?

								Honza
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  block/blk-core.c          |  3 ---
>  include/linux/writeback.h |  6 ------
>  mm/backing-dev.c          | 36 ++++++++++++++++++++++++++++++++++++
>  mm/page-writeback.c       | 36 ------------------------------------
>  4 files changed, 36 insertions(+), 45 deletions(-)
> 
> diff --git a/block/blk-core.c b/block/blk-core.c
> index 14f7674fa0b1..f5f916b28c40 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -662,7 +662,6 @@ void blk_cleanup_queue(struct request_queue *q)
>  	blk_flush_integrity();
>  
>  	/* @q won't process any more request, flush async actions */
> -	del_timer_sync(&q->backing_dev_info->laptop_mode_wb_timer);
>  	blk_sync_queue(q);
>  
>  	if (q->mq_ops)
> @@ -841,8 +840,6 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
>  	q->backing_dev_info->name = "block";
>  	q->node = node_id;
>  
> -	setup_timer(&q->backing_dev_info->laptop_mode_wb_timer,
> -		    laptop_mode_timer_fn, (unsigned long) q);
>  	setup_timer(&q->timeout, blk_rq_timed_out_timer, (unsigned long) q);
>  	INIT_LIST_HEAD(&q->queue_head);
>  	INIT_LIST_HEAD(&q->timeout_list);
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index 9c0091678af4..e6ba35a5e1f7 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -327,14 +327,8 @@ static inline void cgroup_writeback_umount(void)
>  /*
>   * mm/page-writeback.c
>   */
> -#ifdef CONFIG_BLOCK
>  void laptop_io_completion(struct backing_dev_info *info);
>  void laptop_sync_completion(void);
> -void laptop_mode_sync(struct work_struct *work);
> -void laptop_mode_timer_fn(unsigned long data);
> -#else
> -static inline void laptop_sync_completion(void) { }
> -#endif
>  bool node_dirty_ok(struct pglist_data *pgdat);
>  int wb_domain_init(struct wb_domain *dom, gfp_t gfp);
>  #ifdef CONFIG_CGROUP_WRITEBACK
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index e19606bb41a0..cb36f07f2af2 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -822,6 +822,38 @@ static void cgwb_remove_from_bdi_list(struct bdi_writeback *wb)
>  
>  #endif	/* CONFIG_CGROUP_WRITEBACK */
>  
> +static void laptop_mode_timer_fn(unsigned long data)
> +{
> +	struct backing_dev_info *bdi = (struct backing_dev_info *)data;
> +
> +	wakeup_flusher_threads_bdi(bdi, WB_REASON_LAPTOP_TIMER);
> +}
> +
> +/*
> + * We've spun up the disk and we're in laptop mode: schedule writeback
> + * of all dirty data a few seconds from now.  If the flush is already scheduled
> + * then push it back - the user is still using the disk.
> + */
> +void laptop_io_completion(struct backing_dev_info *bdi)
> +{
> +	mod_timer(&bdi->laptop_mode_wb_timer, jiffies + laptop_mode);
> +}
> +
> +/*
> + * We're in laptop mode and we've just synced. The sync's writes will have
> + * caused another writeback to be scheduled by laptop_io_completion.
> + * Nothing needs to be written back anymore, so we unschedule the writeback.
> + */
> +void laptop_sync_completion(void)
> +{
> +	struct backing_dev_info *bdi;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list)
> +		del_timer(&bdi->laptop_mode_wb_timer);
> +	rcu_read_unlock();
> +}
> +
>  static int bdi_init(struct backing_dev_info *bdi)
>  {
>  	int ret;
> @@ -835,6 +867,8 @@ static int bdi_init(struct backing_dev_info *bdi)
>  	INIT_LIST_HEAD(&bdi->bdi_list);
>  	INIT_LIST_HEAD(&bdi->wb_list);
>  	init_waitqueue_head(&bdi->wb_waitq);
> +	setup_timer(&bdi->laptop_mode_wb_timer,
> +		    laptop_mode_timer_fn, (unsigned long)bdi);
>  
>  	ret = cgwb_bdi_init(bdi);
>  
> @@ -916,6 +950,8 @@ EXPORT_SYMBOL(bdi_register_owner);
>   */
>  static void bdi_remove_from_list(struct backing_dev_info *bdi)
>  {
> +	del_timer_sync(&bdi->laptop_mode_wb_timer);
> +
>  	spin_lock_bh(&bdi_lock);
>  	list_del_rcu(&bdi->bdi_list);
>  	spin_unlock_bh(&bdi_lock);
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 8d1fc593bce8..f8fe90dc529d 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1976,42 +1976,6 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
>  	return 0;
>  }
>  
> -#ifdef CONFIG_BLOCK
> -void laptop_mode_timer_fn(unsigned long data)
> -{
> -	struct request_queue *q = (struct request_queue *)data;
> -
> -	wakeup_flusher_threads_bdi(q->backing_dev_info, WB_REASON_LAPTOP_TIMER);
> -}
> -
> -/*
> - * We've spun up the disk and we're in laptop mode: schedule writeback
> - * of all dirty data a few seconds from now.  If the flush is already scheduled
> - * then push it back - the user is still using the disk.
> - */
> -void laptop_io_completion(struct backing_dev_info *info)
> -{
> -	mod_timer(&info->laptop_mode_wb_timer, jiffies + laptop_mode);
> -}
> -
> -/*
> - * We're in laptop mode and we've just synced. The sync's writes will have
> - * caused another writeback to be scheduled by laptop_io_completion.
> - * Nothing needs to be written back anymore, so we unschedule the writeback.
> - */
> -void laptop_sync_completion(void)
> -{
> -	struct backing_dev_info *bdi;
> -
> -	rcu_read_lock();
> -
> -	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list)
> -		del_timer(&bdi->laptop_mode_wb_timer);
> -
> -	rcu_read_unlock();
> -}
> -#endif
> -
>  /*
>   * If ratelimit_pages is too high then we can get into dirty-data overload
>   * if a large number of processes all perform writes at the same time.
> -- 
> 2.14.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
