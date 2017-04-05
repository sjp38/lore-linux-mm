Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86FA96B0390
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 01:05:35 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id h58so544836uaa.8
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 22:05:35 -0700 (PDT)
Received: from mail-vk0-x242.google.com (mail-vk0-x242.google.com. [2607:f8b0:400c:c05::242])
        by mx.google.com with ESMTPS id 22si5679917uas.127.2017.04.04.22.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 22:05:34 -0700 (PDT)
Received: by mail-vk0-x242.google.com with SMTP id d188so161317vka.3
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 22:05:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87wpazh3rl.fsf@notabene.neil.brown.name>
References: <871staffus.fsf@notabene.neil.brown.name> <87wpazh3rl.fsf@notabene.neil.brown.name>
From: Ming Lei <tom.leiming@gmail.com>
Date: Wed, 5 Apr 2017 13:05:33 +0800
Message-ID: <CACVXFVPLoKM3-eY7MHx7o1fcmsvc84xMxY+Ns9QO3POd9+NP8Q@mail.gmail.com>
Subject: Re: [PATCH v2] loop: Add PF_LESS_THROTTLE to block/loop device thread.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Jens Axboe <axboe@fb.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 5, 2017 at 12:33 PM, NeilBrown <neilb@suse.com> wrote:
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

Reviewed-by: Ming Lei <tom.leiming@gmail.com>

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
>         if (IS_ERR(lo->worker_task))
>                 return -ENOMEM;
>         set_user_nice(lo->worker_task, MIN_NICE);
> +       lo->worker_task->flags |= PF_LESS_THROTTLE;
>         return 0;
>  }
>
> --
> 2.12.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
