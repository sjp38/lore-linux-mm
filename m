Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id EFB6F6B0271
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:06:21 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id n186so53760379wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 07:06:21 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id qs3si32543414wjc.230.2016.02.29.07.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 07:06:20 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id l68so40950240wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 07:06:20 -0800 (PST)
Date: Mon, 29 Feb 2016 16:06:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] writeback: move list_lock down into the for loop
Message-ID: <20160229150618.GA16939@dhcp22.suse.cz>
References: <1456505185-21566-1-git-send-email-yang.shi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456505185-21566-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: tj@kernel.org, jack@suse.cz, axboe@fb.com, fengguang.wu@intel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Fri 26-02-16 08:46:25, Yang Shi wrote:
> The list_lock was moved outside the for loop by commit
> e8dfc30582995ae12454cda517b17d6294175b07 ("writeback: elevate queue_io()
> into wb_writeback())", however, the commit log says "No behavior change", so
> it sounds safe to have the list_lock acquired inside the for loop as it did
> before.
> Leave tracepoints outside the critical area since tracepoints already have
> preempt disabled.

The patch says what but it completely misses the why part.

> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---
> Tested with ltp on 8 cores Cortex-A57 machine.
> 
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
> -- 
> 2.0.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
