Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB0426B0033
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 00:13:30 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i130so3159104pgc.5
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 21:13:30 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t5sor378350plj.93.2017.09.19.21.13.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 21:13:29 -0700 (PDT)
Subject: Re: [PATCH 6/6] fs-writeback: only allow one inflight and pending
 !nr_pages flush
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-7-git-send-email-axboe@kernel.dk>
 <CAOQ4uxjxgtNvNFh936SK2+kbPvj5zDR_tx66u2s6jiOTSrRLUQ@mail.gmail.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <eebaf6e6-63be-2759-67b2-62d980cdd8f8@kernel.dk>
Date: Tue, 19 Sep 2017 22:13:25 -0600
MIME-Version: 1.0
In-Reply-To: <CAOQ4uxjxgtNvNFh936SK2+kbPvj5zDR_tx66u2s6jiOTSrRLUQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, hannes@cmpxchg.org, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>

On 09/19/2017 09:10 PM, Amir Goldstein wrote:
> On Tue, Sep 19, 2017 at 10:53 PM, Jens Axboe <axboe@kernel.dk> wrote:
>> A few callers pass in nr_pages == 0 when they wakeup the flusher
>> threads, which means that the flusher should just flush everything
>> that was currently dirty. If we are tight on memory, we can get
>> tons of these queued from kswapd/vmscan. This causes (at least)
>> two problems:
>>
>> 1) We consume a ton of memory just allocating writeback work items.
>> 2) We spend so much time processing these work items, that we
>>    introduce a softlockup in writeback processing.
>>
>> Fix this by adding a 'zero_pages' bit to the writeback structure,
>> and set that when someone queues a nr_pages==0 flusher thread
>> wakeup. The bit is cleared when we start writeback on that work
>> item. If the bit is already set when we attempt to queue !nr_pages
>> writeback, then we simply ignore it.
>>
>> This provides us one of full flush in flight, with one pending as
>> well, and makes for more efficient handling of this type of
>> writeback.
>>
>> Signed-off-by: Jens Axboe <axboe@kernel.dk>
>> ---
>>  fs/fs-writeback.c                | 30 ++++++++++++++++++++++++++++--
>>  include/linux/backing-dev-defs.h |  1 +
>>  2 files changed, 29 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
>> index a9a86644cb9f..e0240110b36f 100644
>> --- a/fs/fs-writeback.c
>> +++ b/fs/fs-writeback.c
>> @@ -53,6 +53,7 @@ struct wb_writeback_work {
>>         unsigned int for_background:1;
>>         unsigned int for_sync:1;        /* sync(2) WB_SYNC_ALL writeback */
>>         unsigned int auto_free:1;       /* free on completion */
>> +       unsigned int zero_pages:1;      /* nr_pages == 0 writeback */
> 
> Suggest: use a name that describes the intention (e.g. WB_everything)

Agree, the name isn't the best. WB_everything isn't great either, though,
since this isn't an integrity write. WB_start_all would be better,
I'll make that change.

>>         enum wb_reason reason;          /* why was writeback initiated? */
>>
>>         struct list_head list;          /* pending work list */
>> @@ -948,15 +949,25 @@ static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>>                                bool range_cyclic, enum wb_reason reason)
>>  {
>>         struct wb_writeback_work *work;
>> +       bool zero_pages = false;
>>
>>         if (!wb_has_dirty_io(wb))
>>                 return;
>>
>>         /*
>> -        * If someone asked for zero pages, we write out the WORLD
>> +        * If someone asked for zero pages, we write out the WORLD.
>> +        * Places like vmscan and laptop mode want to queue a wakeup to
>> +        * the flusher threads to clean out everything. To avoid potentially
>> +        * having tons of these pending, ensure that we only allow one of
>> +        * them pending and inflight at the time
>>          */
>> -       if (!nr_pages)
>> +       if (!nr_pages) {
>> +               if (test_bit(WB_zero_pages, &wb->state))
>> +                       return;
>> +               set_bit(WB_zero_pages, &wb->state);
> 
> Shouldn't this be test_and_set? not the worst outcome if you have more
> than one pending work item, but still.

If the frequency of these is high, and they were to trigger the bad
conditions we saw, then a split test + set is faster as it won't
keep re-dirtying the same cacheline from multiple locations. It's
better to leave it a little racy, but faster.

>> @@ -1828,6 +1840,14 @@ static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
>>                 list_del_init(&work->list);
>>         }
>>         spin_unlock_bh(&wb->work_lock);
>> +
>> +       /*
>> +        * Once we start processing a work item that had !nr_pages,
>> +        * clear the wb state bit for that so we can allow more.
>> +        */
>> +       if (work && work->zero_pages && test_bit(WB_zero_pages, &wb->state))
>> +               clear_bit(WB_zero_pages, &wb->state);
> 
> nit: should not need to test_bit

True, we can drop it for this case, as it'll be the common condition
anyway. I'll make that change.

>> @@ -1896,6 +1916,12 @@ static long wb_do_writeback(struct bdi_writeback *wb)
>>                 trace_writeback_exec(wb, work);
>>                 wrote += wb_writeback(wb, work);
>>                 finish_writeback_work(wb, work);
>> +
>> +               /*
>> +                * If we have a lot of pending work, make sure we take
>> +                * an occasional breather, if needed.
>> +                */
>> +               cond_resched();
> 
> Probably ought to be in a separate patch.

Yeah, it probably should be. It's not strictly needed with the other
change anyway, I will just drop it.

New version:

http://git.kernel.dk/cgit/linux-block/commit/?h=writeback-fixup&id=338a69c217cdaaffda93f3cc9a364a347f782adb

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
