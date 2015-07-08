Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id CAA816B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 04:24:59 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so336981251wiw.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 01:24:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f2si1884191wix.93.2015.07.08.01.24.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 01:24:58 -0700 (PDT)
Date: Wed, 8 Jul 2015 10:24:53 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH block/for-4.3] writeback: remove
 wb_writeback_work->single_wait/done
Message-ID: <20150708082453.GC725@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-46-git-send-email-tj@kernel.org>
 <20150701190735.GI7252@quack.suse.cz>
 <20150703221223.GH5273@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150703221223.GH5273@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 03-07-15 18:12:23, Tejun Heo wrote:
> Hello, Jan.
> 
> So, something like the following.  It depends on other changes so
> won't apply as-is.  I'll repost it as part of a patchset once -rc1
> drops.
> 
> Thanks!
> 
> ------ 8< ------
> wb_writeback_work->single_wait/done are used for the wait mechanism
> for synchronous wb_work (wb_writeback_work) items which are issued
> when bdi_split_work_to_wbs() fails to allocate memory for asynchronous
> wb_work items; however, there's no reason to use a separate wait
> mechanism for this.  bdi_split_work_to_wbs() can simply use on-stack
> fallback wb_work item and separate wb_completion to wait for it.
> 
> This patch removes wb_work->single_wait/done and the related code and
> make bdi_split_work_to_wbs() use on-stack fallback wb_work and
> wb_completion instead.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Suggested-by: Jan Kara <jack@suse.cz>

Thanks! The patch looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza

> ---
>  fs/fs-writeback.c |  116 +++++++++++++-----------------------------------------
>  1 file changed, 30 insertions(+), 86 deletions(-)
> 
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -53,8 +53,6 @@ struct wb_writeback_work {
>  	unsigned int for_background:1;
>  	unsigned int for_sync:1;	/* sync(2) WB_SYNC_ALL writeback */
>  	unsigned int auto_free:1;	/* free on completion */
> -	unsigned int single_wait:1;
> -	unsigned int single_done:1;
>  	enum wb_reason reason;		/* why was writeback initiated? */
>  
>  	struct list_head list;		/* pending work list */
> @@ -181,11 +179,8 @@ static void wb_queue_work(struct bdi_wri
>  	trace_writeback_queue(wb->bdi, work);
>  
>  	spin_lock_bh(&wb->work_lock);
> -	if (!test_bit(WB_registered, &wb->state)) {
> -		if (work->single_wait)
> -			work->single_done = 1;
> +	if (!test_bit(WB_registered, &wb->state))
>  		goto out_unlock;
> -	}
>  	if (work->done)
>  		atomic_inc(&work->done->cnt);
>  	list_add_tail(&work->list, &wb->work_list);
> @@ -737,32 +732,6 @@ int inode_congested(struct inode *inode,
>  EXPORT_SYMBOL_GPL(inode_congested);
>  
>  /**
> - * wb_wait_for_single_work - wait for completion of a single bdi_writeback_work
> - * @bdi: bdi the work item was issued to
> - * @work: work item to wait for
> - *
> - * Wait for the completion of @work which was issued to one of @bdi's
> - * bdi_writeback's.  The caller must have set @work->single_wait before
> - * issuing it.  This wait operates independently fo
> - * wb_wait_for_completion() and also disables automatic freeing of @work.
> - */
> -static void wb_wait_for_single_work(struct backing_dev_info *bdi,
> -				    struct wb_writeback_work *work)
> -{
> -	if (WARN_ON_ONCE(!work->single_wait))
> -		return;
> -
> -	wait_event(bdi->wb_waitq, work->single_done);
> -
> -	/*
> -	 * Paired with smp_wmb() in wb_do_writeback() and ensures that all
> -	 * modifications to @work prior to assertion of ->single_done is
> -	 * visible to the caller once this function returns.
> -	 */
> -	smp_rmb();
> -}
> -
> -/**
>   * wb_split_bdi_pages - split nr_pages to write according to bandwidth
>   * @wb: target bdi_writeback to split @nr_pages to
>   * @nr_pages: number of pages to write for the whole bdi
> @@ -791,38 +760,6 @@ static long wb_split_bdi_pages(struct bd
>  }
>  
>  /**
> - * wb_clone_and_queue_work - clone a wb_writeback_work and issue it to a wb
> - * @wb: target bdi_writeback
> - * @base_work: source wb_writeback_work
> - *
> - * Try to make a clone of @base_work and issue it to @wb.  If cloning
> - * succeeds, %true is returned; otherwise, @base_work is issued directly
> - * and %false is returned.  In the latter case, the caller is required to
> - * wait for @base_work's completion using wb_wait_for_single_work().
> - *
> - * A clone is auto-freed on completion.  @base_work never is.
> - */
> -static bool wb_clone_and_queue_work(struct bdi_writeback *wb,
> -				    struct wb_writeback_work *base_work)
> -{
> -	struct wb_writeback_work *work;
> -
> -	work = kmalloc(sizeof(*work), GFP_ATOMIC);
> -	if (work) {
> -		*work = *base_work;
> -		work->auto_free = 1;
> -		work->single_wait = 0;
> -	} else {
> -		work = base_work;
> -		work->auto_free = 0;
> -		work->single_wait = 1;
> -	}
> -	work->single_done = 0;
> -	wb_queue_work(wb, work);
> -	return work != base_work;
> -}
> -
> -/**
>   * bdi_split_work_to_wbs - split a wb_writeback_work to all wb's of a bdi
>   * @bdi: target backing_dev_info
>   * @base_work: wb_writeback_work to issue
> @@ -837,7 +774,6 @@ static void bdi_split_work_to_wbs(struct
>  				  struct wb_writeback_work *base_work,
>  				  bool skip_if_busy)
>  {
> -	long nr_pages = base_work->nr_pages;
>  	int next_memcg_id = 0;
>  	struct bdi_writeback *wb;
>  	struct wb_iter iter;
> @@ -849,17 +785,39 @@ static void bdi_split_work_to_wbs(struct
>  restart:
>  	rcu_read_lock();
>  	bdi_for_each_wb(wb, bdi, &iter, next_memcg_id) {
> +		DEFINE_WB_COMPLETION_ONSTACK(fallback_work_done);
> +		struct wb_writeback_work fallback_work;
> +		struct wb_writeback_work *work;
> +		long nr_pages;
> +
>  		if (!wb_has_dirty_io(wb) ||
>  		    (skip_if_busy && writeback_in_progress(wb)))
>  			continue;
>  
> -		base_work->nr_pages = wb_split_bdi_pages(wb, nr_pages);
> -		if (!wb_clone_and_queue_work(wb, base_work)) {
> -			next_memcg_id = wb->memcg_css->id + 1;
> -			rcu_read_unlock();
> -			wb_wait_for_single_work(bdi, base_work);
> -			goto restart;
> +		nr_pages = wb_split_bdi_pages(wb, base_work->nr_pages);
> +
> +		work = kmalloc(sizeof(*work), GFP_ATOMIC);
> +		if (work) {
> +			*work = *base_work;
> +			work->nr_pages = nr_pages;
> +			work->auto_free = 1;
> +			wb_queue_work(wb, work);
> +			continue;
>  		}
> +
> +		/* alloc failed, execute synchronously using on-stack fallback */
> +		work = &fallback_work;
> +		*work = *base_work;
> +		work->nr_pages = nr_pages;
> +		work->auto_free = 0;
> +		work->done = &fallback_work_done;
> +
> +		wb_queue_work(wb, work);
> +
> +		next_memcg_id = wb->memcg_css->id + 1;
> +		rcu_read_unlock();
> +		wb_wait_for_completion(bdi, &fallback_work_done);
> +		goto restart;
>  	}
>  	rcu_read_unlock();
>  }
> @@ -901,8 +859,6 @@ static void bdi_split_work_to_wbs(struct
>  	if (bdi_has_dirty_io(bdi) &&
>  	    (!skip_if_busy || !writeback_in_progress(&bdi->wb))) {
>  		base_work->auto_free = 0;
> -		base_work->single_wait = 0;
> -		base_work->single_done = 0;
>  		wb_queue_work(&bdi->wb, base_work);
>  	}
>  }
> @@ -1793,26 +1749,14 @@ static long wb_do_writeback(struct bdi_w
>  	set_bit(WB_writeback_running, &wb->state);
>  	while ((work = get_next_work_item(wb)) != NULL) {
>  		struct wb_completion *done = work->done;
> -		bool need_wake_up = false;
>  
>  		trace_writeback_exec(wb->bdi, work);
>  
>  		wrote += wb_writeback(wb, work);
>  
> -		if (work->single_wait) {
> -			WARN_ON_ONCE(work->auto_free);
> -			/* paired w/ rmb in wb_wait_for_single_work() */
> -			smp_wmb();
> -			work->single_done = 1;
> -			need_wake_up = true;
> -		} else if (work->auto_free) {
> +		if (work->auto_free)
>  			kfree(work);
> -		}
> -
>  		if (done && atomic_dec_and_test(&done->cnt))
> -			need_wake_up = true;
> -
> -		if (need_wake_up)
>  			wake_up_all(&wb->bdi->wb_waitq);
>  	}
>  
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
