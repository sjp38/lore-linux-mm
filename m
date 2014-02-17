Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3D96C6B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 04:21:00 -0500 (EST)
Received: by mail-we0-f173.google.com with SMTP id x48so4663804wes.4
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 01:20:59 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5si9912216wjq.135.2014.02.17.01.20.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Feb 2014 01:20:58 -0800 (PST)
Date: Mon, 17 Feb 2014 10:20:54 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] backing_dev: Fix hung task on sync
Message-ID: <20140217092054.GA3686@quack.suse.cz>
References: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Derek Basehore <dbasehore@chromium.org>
Cc: Alexander Viro <viro@zento.linux.org.uk>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bleung@chromium.org, sonnyrao@chromium.org, semenzato@chromium.org

On Fri 14-02-14 20:12:17, Derek Basehore wrote:
> bdi_wakeup_thread_delayed used the mod_delayed_work function to schedule work
> to writeback dirty inodes. The problem with this is that it can delay work that
> is scheduled for immediate execution, such as the work from sync_inodes_sb.
> This can happen since mod_delayed_work can now steal work from a work_queue.
> This fixes the problem by using queue_delayed_work instead. This is a
> regression from the move to the bdi workqueue design.
> 
> The reason that this causes a problem is that laptop-mode will change the
> delay, dirty_writeback_centisecs, to 60000 (10 minutes) by default. In the case
> that bdi_wakeup_thread_delayed races with sync_inodes_sb, sync will be stopped
> for 10 minutes and trigger a hung task. Even if dirty_writeback_centisecs is
> not long enough to cause a hung task, we still don't want to delay sync for
> that long.
> 
> For the same reason, this also changes bdi_writeback_workfn to immediately
> queue the work again in the case that the work_list is not empty. The same
> problem can happen if the sync work is run on the rescue worker.
  The patch looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

  I'd also suggest to push this to stable kernels.

								Honza

> 
> Signed-off-by: Derek Basehore <dbasehore@chromium.org>
> ---
>  fs/fs-writeback.c | 5 +++--
>  mm/backing-dev.c  | 2 +-
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index e0259a1..95b7b8c 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -1047,8 +1047,9 @@ void bdi_writeback_workfn(struct work_struct *work)
>  		trace_writeback_pages_written(pages_written);
>  	}
>  
> -	if (!list_empty(&bdi->work_list) ||
> -	    (wb_has_dirty_io(wb) && dirty_writeback_interval))
> +	if (!list_empty(&bdi->work_list))
> +		mod_delayed_work(bdi_wq, &wb->dwork, 0);
> +	else if (wb_has_dirty_io(wb) && dirty_writeback_interval)
>  		queue_delayed_work(bdi_wq, &wb->dwork,
>  			msecs_to_jiffies(dirty_writeback_interval * 10));
>  
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index ce682f7..3fde024 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -294,7 +294,7 @@ void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi)
>  	unsigned long timeout;
>  
>  	timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
> -	mod_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);
> +	queue_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);
>  }
>  
>  /*
> -- 
> 1.9.0.rc1.175.g0b1dcb5
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
