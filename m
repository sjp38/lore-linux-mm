Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8770E6B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 23:10:17 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id t127so2813539ywg.0
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 20:10:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x5sor349651ywl.87.2017.09.19.20.10.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 20:10:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1505850787-18311-7-git-send-email-axboe@kernel.dk>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk> <1505850787-18311-7-git-send-email-axboe@kernel.dk>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 20 Sep 2017 06:10:14 +0300
Message-ID: <CAOQ4uxjxgtNvNFh936SK2+kbPvj5zDR_tx66u2s6jiOTSrRLUQ@mail.gmail.com>
Subject: Re: [PATCH 6/6] fs-writeback: only allow one inflight and pending
 !nr_pages flush
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, hannes@cmpxchg.org, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>

On Tue, Sep 19, 2017 at 10:53 PM, Jens Axboe <axboe@kernel.dk> wrote:
> A few callers pass in nr_pages == 0 when they wakeup the flusher
> threads, which means that the flusher should just flush everything
> that was currently dirty. If we are tight on memory, we can get
> tons of these queued from kswapd/vmscan. This causes (at least)
> two problems:
>
> 1) We consume a ton of memory just allocating writeback work items.
> 2) We spend so much time processing these work items, that we
>    introduce a softlockup in writeback processing.
>
> Fix this by adding a 'zero_pages' bit to the writeback structure,
> and set that when someone queues a nr_pages==0 flusher thread
> wakeup. The bit is cleared when we start writeback on that work
> item. If the bit is already set when we attempt to queue !nr_pages
> writeback, then we simply ignore it.
>
> This provides us one of full flush in flight, with one pending as
> well, and makes for more efficient handling of this type of
> writeback.
>
> Signed-off-by: Jens Axboe <axboe@kernel.dk>
> ---
>  fs/fs-writeback.c                | 30 ++++++++++++++++++++++++++++--
>  include/linux/backing-dev-defs.h |  1 +
>  2 files changed, 29 insertions(+), 2 deletions(-)
>
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index a9a86644cb9f..e0240110b36f 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -53,6 +53,7 @@ struct wb_writeback_work {
>         unsigned int for_background:1;
>         unsigned int for_sync:1;        /* sync(2) WB_SYNC_ALL writeback */
>         unsigned int auto_free:1;       /* free on completion */
> +       unsigned int zero_pages:1;      /* nr_pages == 0 writeback */

Suggest: use a name that describes the intention (e.g. WB_everything)

>         enum wb_reason reason;          /* why was writeback initiated? */
>
>         struct list_head list;          /* pending work list */
> @@ -948,15 +949,25 @@ static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>                                bool range_cyclic, enum wb_reason reason)
>  {
>         struct wb_writeback_work *work;
> +       bool zero_pages = false;
>
>         if (!wb_has_dirty_io(wb))
>                 return;
>
>         /*
> -        * If someone asked for zero pages, we write out the WORLD
> +        * If someone asked for zero pages, we write out the WORLD.
> +        * Places like vmscan and laptop mode want to queue a wakeup to
> +        * the flusher threads to clean out everything. To avoid potentially
> +        * having tons of these pending, ensure that we only allow one of
> +        * them pending and inflight at the time
>          */
> -       if (!nr_pages)
> +       if (!nr_pages) {
> +               if (test_bit(WB_zero_pages, &wb->state))
> +                       return;
> +               set_bit(WB_zero_pages, &wb->state);

Shouldn't this be test_and_set? not the worst outcome if you have more
than one pending work item, but still.

>                 nr_pages = get_nr_dirty_pages();
> +               zero_pages = true;
> +       }
>
>         /*
>          * This is WB_SYNC_NONE writeback, so if allocation fails just
> @@ -975,6 +986,7 @@ static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>         work->range_cyclic = range_cyclic;
>         work->reason    = reason;
>         work->auto_free = 1;
> +       work->zero_pages = zero_pages;
>
>         wb_queue_work(wb, work);
>  }
> @@ -1828,6 +1840,14 @@ static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
>                 list_del_init(&work->list);
>         }
>         spin_unlock_bh(&wb->work_lock);
> +
> +       /*
> +        * Once we start processing a work item that had !nr_pages,
> +        * clear the wb state bit for that so we can allow more.
> +        */
> +       if (work && work->zero_pages && test_bit(WB_zero_pages, &wb->state))
> +               clear_bit(WB_zero_pages, &wb->state);

nit: should not need to test_bit

> +
>         return work;
>  }
>
> @@ -1896,6 +1916,12 @@ static long wb_do_writeback(struct bdi_writeback *wb)
>                 trace_writeback_exec(wb, work);
>                 wrote += wb_writeback(wb, work);
>                 finish_writeback_work(wb, work);
> +
> +               /*
> +                * If we have a lot of pending work, make sure we take
> +                * an occasional breather, if needed.
> +                */
> +               cond_resched();

Probably ought to be in a separate patch.

>         }
>
>         /*
> diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
> index 866c433e7d32..7494f6a75458 100644
> --- a/include/linux/backing-dev-defs.h
> +++ b/include/linux/backing-dev-defs.h
> @@ -24,6 +24,7 @@ enum wb_state {
>         WB_shutting_down,       /* wb_shutdown() in progress */
>         WB_writeback_running,   /* Writeback is in progress */
>         WB_has_dirty_io,        /* Dirty inodes on ->b_{dirty|io|more_io} */
> +       WB_zero_pages,          /* nr_pages == 0 flush pending */

same suggestion: WB_everything

Cheers,
Amir.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
