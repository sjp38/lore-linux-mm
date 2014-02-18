Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id A09606B0035
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:55:52 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i17so26612590qcy.39
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:55:52 -0800 (PST)
Received: from mail-qa0-x233.google.com (mail-qa0-x233.google.com [2607:f8b0:400d:c00::233])
        by mx.google.com with ESMTPS id j10si11409884qas.11.2014.02.18.14.55.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 14:55:52 -0800 (PST)
Received: by mail-qa0-f51.google.com with SMTP id f11so24073089qae.38
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:55:52 -0800 (PST)
Date: Tue, 18 Feb 2014 17:55:48 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] backing_dev: Fix hung task on sync
Message-ID: <20140218225548.GI31892@mtj.dyndns.org>
References: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Derek Basehore <dbasehore@chromium.org>
Cc: Alexander Viro <viro@zento.linux.org.uk>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bleung@chromium.org, sonnyrao@chromium.org, semenzato@chromium.org

Hello,

On Fri, Feb 14, 2014 at 08:12:17PM -0800, Derek Basehore wrote:
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

Oops.

> For the same reason, this also changes bdi_writeback_workfn to immediately
> queue the work again in the case that the work_list is not empty. The same
> problem can happen if the sync work is run on the rescue worker.
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

Can you please add some comments explaining why the specific variants
are being used here?

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

and here?

Hmmm.... but doesn't this create an opposite problem?  Now a flush
queued for an earlier time may be overridden by something scheduled
later, no?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
