Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9B076B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 07:23:11 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r71so28037443wrb.17
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 04:23:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w82si19409448wmb.41.2017.04.04.04.23.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 04:23:10 -0700 (PDT)
Date: Tue, 4 Apr 2017 13:23:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] loop: Add PF_LESS_THROTTLE to block/loop device thread.
Message-ID: <20170404112307.GA15490@dhcp22.suse.cz>
References: <871staffus.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871staffus.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Jens Axboe <axboe@fb.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 03-04-17 11:18:51, NeilBrown wrote:
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

Yes this makes sense to me

> Signed-off-by: NeilBrown <neilb@suse.com>

Acked-by: Michal Hocko <mhocko@suse.com>

one nit below

> ---
>  drivers/block/loop.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/block/loop.c b/drivers/block/loop.c
> index 0ecb6461ed81..a7e1dd215fc2 100644
> --- a/drivers/block/loop.c
> +++ b/drivers/block/loop.c
> @@ -1694,8 +1694,11 @@ static void loop_queue_work(struct kthread_work *work)
>  {
>  	struct loop_cmd *cmd =
>  		container_of(work, struct loop_cmd, work);
> +	int oldflags = current->flags & PF_LESS_THROTTLE;
>  
> +	current->flags |= PF_LESS_THROTTLE;
>  	loop_handle_cmd(cmd);
> +	current->flags = (current->flags & ~PF_LESS_THROTTLE) | oldflags;

we have a helper for this tsk_restore_flags(). It is not used
consistently and maybe we want a dedicated api like we have for the
scope NOIO/NOFS but that is a separate thing. I would find
tsk_restore_flags easier to read.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
