Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6996B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 21:40:46 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id g6so4988377igt.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 18:40:46 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.232])
        by mx.google.com with ESMTP id u72si7111644ioi.167.2016.02.24.18.40.45
        for <linux-mm@kvack.org>;
        Wed, 24 Feb 2016 18:40:45 -0800 (PST)
Date: Wed, 24 Feb 2016 21:40:42 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] writeback: call writeback tracepoints withoud holding
 list_lock in wb_writeback()
Message-ID: <20160224214042.71c3493b@grimm.local.home>
In-Reply-To: <1456354043-31420-1-git-send-email-yang.shi@linaro.org>
References: <1456354043-31420-1-git-send-email-yang.shi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: tj@kernel.org, jack@suse.cz, axboe@fb.com, fengguang.wu@intel.com, tglx@linutronix.de, bigeasy@linutronix.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linaro-kernel@lists.linaro.org

On Wed, 24 Feb 2016 14:47:23 -0800
Yang Shi <yang.shi@linaro.org> wrote:

> commit 5634cc2aa9aebc77bc862992e7805469dcf83dac ("writeback: update writeback
> tracepoints to report cgroup") made writeback tracepoints report cgroup
> writeback, but it may trigger the below bug on -rt kernel due to the list_lock
> held for the for loop in wb_writeback().

list_lock is a sleeping mutex, it's not disabling preemption. Moving it
doesn't make a difference.

> 
> BUG: sleeping function called from invalid context at kernel/locking/rtmutex.c:930
> in_atomic(): 1, irqs_disabled(): 0, pid: 625, name: kworker/u16:3

Something else disabled preemption. And note, nothing in the tracepoint
should have called a sleeping function.


> INFO: lockdep is turned off.
> Preemption disabled at:[<ffffffc000374a5c>] wb_writeback+0xec/0x830
> 
> CPU: 7 PID: 625 Comm: kworker/u16:3 Not tainted 4.4.1-rt5 #20
> Hardware name: Freescale Layerscape 2085a RDB Board (DT)
> Workqueue: writeback wb_workfn (flush-7:0)
> Call trace:
> [<ffffffc00008d708>] dump_backtrace+0x0/0x200
> [<ffffffc00008d92c>] show_stack+0x24/0x30
> [<ffffffc0007b0f40>] dump_stack+0x88/0xa8
> [<ffffffc000127d74>] ___might_sleep+0x2ec/0x300
> [<ffffffc000d5d550>] rt_spin_lock+0x38/0xb8
> [<ffffffc0003e0548>] kernfs_path_len+0x30/0x90
> [<ffffffc00036b360>] trace_event_raw_event_writeback_work_class+0xe8/0x2e8

How accurate is this trace back? Here's the code that is executed in
this tracepoint:

	TP_fast_assign(
		struct device *dev = bdi->dev;
		if (!dev)
			dev = default_backing_dev_info.dev;
		strncpy(__entry->name, dev_name(dev), 32);
		__entry->nr_pages = work->nr_pages;
		__entry->sb_dev = work->sb ? work->sb->s_dev : 0;
		__entry->sync_mode = work->sync_mode;
		__entry->for_kupdate = work->for_kupdate;
		__entry->range_cyclic = work->range_cyclic;
		__entry->for_background	= work->for_background;
		__entry->reason = work->reason;
	),

See anything that would sleep?

> [<ffffffc000374f90>] wb_writeback+0x620/0x830
> [<ffffffc000376224>] wb_workfn+0x61c/0x950
> [<ffffffc000110adc>] process_one_work+0x3ac/0xb30
> [<ffffffc0001112fc>] worker_thread+0x9c/0x7a8
> [<ffffffc00011a9e8>] kthread+0x190/0x1b0
> [<ffffffc000086ca0>] ret_from_fork+0x10/0x30
> 
> The list_lock was moved outside the for loop by commit
> e8dfc30582995ae12454cda517b17d6294175b07 ("writeback: elevate queue_io()
> into wb_writeback())", however, the commit log says "No behavior change", so
> it sounds safe to have the list_lock acquired inside the for loop as it did
> before.
> 
> Just acquire list_lock at the necessary points and keep all writeback
> tracepoints outside the critical area protected by list_lock in
> wb_writeback().

But list_lock itself is a sleeping lock. This doesn't make sense.

This is not the bug you are looking for.

-- Steve

> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---
>  fs/fs-writeback.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 1f76d89..9b7b5f6 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -1623,7 +1623,6 @@ static long wb_writeback(struct bdi_writeback *wb,
>  	work->older_than_this = &oldest_jif;
>  
>  	blk_start_plug(&plug);
> -	spin_lock(&wb->list_lock);
>  	for (;;) {
>  		/*
>  		 * Stop writeback when nr_pages has been consumed
> @@ -1661,15 +1660,19 @@ static long wb_writeback(struct bdi_writeback *wb,
>  			oldest_jif = jiffies;
>  
>  		trace_writeback_start(wb, work);
> +
> +		spin_lock(&wb->list_lock);
>  		if (list_empty(&wb->b_io))
>  			queue_io(wb, work);
>  		if (work->sb)
>  			progress = writeback_sb_inodes(work->sb, wb, work);
>  		else
>  			progress = __writeback_inodes_wb(wb, work);
> -		trace_writeback_written(wb, work);
>  
>  		wb_update_bandwidth(wb, wb_start);
> +		spin_unlock(&wb->list_lock);
> +
> +		trace_writeback_written(wb, work);
>  
>  		/*
>  		 * Did we write something? Try for more
> @@ -1693,15 +1696,14 @@ static long wb_writeback(struct bdi_writeback *wb,
>  		 */
>  		if (!list_empty(&wb->b_more_io))  {
>  			trace_writeback_wait(wb, work);
> +			spin_lock(&wb->list_lock);
>  			inode = wb_inode(wb->b_more_io.prev);
> -			spin_lock(&inode->i_lock);
>  			spin_unlock(&wb->list_lock);
> +			spin_lock(&inode->i_lock);
>  			/* This function drops i_lock... */
>  			inode_sleep_on_writeback(inode);
> -			spin_lock(&wb->list_lock);
>  		}
>  	}
> -	spin_unlock(&wb->list_lock);
>  	blk_finish_plug(&plug);
>  
>  	return nr_pages - work->nr_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
