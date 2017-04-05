Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94AEE6B0390
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 03:19:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u2so350576wmu.18
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 00:19:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a37si23956564wra.282.2017.04.05.00.19.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 00:19:30 -0700 (PDT)
Date: Wed, 5 Apr 2017 09:19:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] loop: Add PF_LESS_THROTTLE to block/loop device
 thread.
Message-ID: <20170405071927.GA7258@dhcp22.suse.cz>
References: <871staffus.fsf@notabene.neil.brown.name>
 <87wpazh3rl.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87wpazh3rl.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Jens Axboe <axboe@fb.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ming Lei <tom.leiming@gmail.com>

On Wed 05-04-17 14:33:50, NeilBrown wrote:
> 
> When a filesystem is mounted from a loop device, writes are
> throttled by balance_dirty_pages() twice: once when writing
> to the filesystem and once when the loop_handle_cmd() writes
> to the backing file.  This double-throttling can trigger
> positive feedback loops that create significant delays.  The
> throttling at the lower level is seen by the upper level as
> a slow device, so it throttles extra hard.
> 
> The PF_LESS_THROTTLE flag was created to handle exactly this
> circumstance, though with an NFS filesystem mounted from a
> local NFS server.  It reduces the throttling on the lower
> layer so that it can proceed largely unthrottled.
> 
> To demonstrate this, create a filesystem on a loop device
> and write (e.g. with dd) several large files which combine
> to consume significantly more than the limit set by
> /proc/sys/vm/dirty_ratio or dirty_bytes.  Measure the total
> time taken.
> 
> When I do this directly on a device (no loop device) the
> total time for several runs (mkfs, mount, write 200 files,
> umount) is fairly stable: 28-35 seconds.
> When I do this over a loop device the times are much worse
> and less stable.  52-460 seconds.  Half below 100seconds,
> half above.
> When I apply this patch, the times become stable again,
> though not as fast as the no-loop-back case: 53-72 seconds.
> 
> There may be room for further improvement as the total overhead still
> seems too high, but this is a big improvement.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> I moved where the flag is set, thanks to suggestion from
> Ming Lei.
> I've preserved the *-by: tags I was offered despite the code
> being different, as the concept is identical.
> 
> Thanks,
> NeilBrown
> 
> 
>  drivers/block/loop.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/block/loop.c b/drivers/block/loop.c
> index 0ecb6461ed81..44b3506fd086 100644
> --- a/drivers/block/loop.c
> +++ b/drivers/block/loop.c
> @@ -852,6 +852,7 @@ static int loop_prepare_queue(struct loop_device *lo)
>  	if (IS_ERR(lo->worker_task))
>  		return -ENOMEM;
>  	set_user_nice(lo->worker_task, MIN_NICE);
> +	lo->worker_task->flags |= PF_LESS_THROTTLE;
>  	return 0;

As mentioned elsewhere, PF flags should be updated only on the current
task otherwise there is potential rmw race. Is this safe? The code runs
concurrently with the worker thread.


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
