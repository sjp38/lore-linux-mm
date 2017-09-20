Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9506B0038
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:35:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p87so4666531pfj.4
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 05:35:34 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e11sor2072784pgp.354.2017.09.20.05.35.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 05:35:32 -0700 (PDT)
Subject: Re: [PATCH 6/6] fs-writeback: only allow one inflight and pending
 !nr_pages flush
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-7-git-send-email-axboe@kernel.dk>
 <CAOQ4uxjxgtNvNFh936SK2+kbPvj5zDR_tx66u2s6jiOTSrRLUQ@mail.gmail.com>
 <eebaf6e6-63be-2759-67b2-62d980cdd8f8@kernel.dk>
 <CAOQ4uxhwX-r_aVGUuvyxb6GsjJJ5hMOfHyw=oEYM87mxDEnznA@mail.gmail.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <21979d59-24c9-1146-0139-feb47d50db89@kernel.dk>
Date: Wed, 20 Sep 2017 06:35:28 -0600
MIME-Version: 1.0
In-Reply-To: <CAOQ4uxhwX-r_aVGUuvyxb6GsjJJ5hMOfHyw=oEYM87mxDEnznA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, hannes@cmpxchg.org, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>

On 09/20/2017 12:05 AM, Amir Goldstein wrote:
> On Wed, Sep 20, 2017 at 7:13 AM, Jens Axboe <axboe@kernel.dk> wrote:
>> On 09/19/2017 09:10 PM, Amir Goldstein wrote:
>>> On Tue, Sep 19, 2017 at 10:53 PM, Jens Axboe <axboe@kernel.dk> wrote:
>>>> A few callers pass in nr_pages == 0 when they wakeup the flusher
>>>> threads, which means that the flusher should just flush everything
>>>> that was currently dirty. If we are tight on memory, we can get
>>>> tons of these queued from kswapd/vmscan. This causes (at least)
>>>> two problems:
>>>>
>>>> 1) We consume a ton of memory just allocating writeback work items.
>>>> 2) We spend so much time processing these work items, that we
>>>>    introduce a softlockup in writeback processing.
>>>>
>>>> Fix this by adding a 'zero_pages' bit to the writeback structure,
>>>> and set that when someone queues a nr_pages==0 flusher thread
>>>> wakeup. The bit is cleared when we start writeback on that work
>>>> item. If the bit is already set when we attempt to queue !nr_pages
>>>> writeback, then we simply ignore it.
>>>>
>>>> This provides us one of full flush in flight, with one pending as
>>>> well, and makes for more efficient handling of this type of
>>>> writeback.
>>>>
>>>> Signed-off-by: Jens Axboe <axboe@kernel.dk>
>>>> ---
>>>>  fs/fs-writeback.c                | 30 ++++++++++++++++++++++++++++--
>>>>  include/linux/backing-dev-defs.h |  1 +
>>>>  2 files changed, 29 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
>>>> index a9a86644cb9f..e0240110b36f 100644
>>>> --- a/fs/fs-writeback.c
>>>> +++ b/fs/fs-writeback.c
>>>> @@ -53,6 +53,7 @@ struct wb_writeback_work {
>>>>         unsigned int for_background:1;
>>>>         unsigned int for_sync:1;        /* sync(2) WB_SYNC_ALL writeback */
>>>>         unsigned int auto_free:1;       /* free on completion */
>>>> +       unsigned int zero_pages:1;      /* nr_pages == 0 writeback */
>>>
>>> Suggest: use a name that describes the intention (e.g. WB_everything)
>>
>> Agree, the name isn't the best. WB_everything isn't great either, though,
>> since this isn't an integrity write. WB_start_all would be better,
>> I'll make that change.
>>
>>>>         enum wb_reason reason;          /* why was writeback initiated? */
>>>>
>>>>         struct list_head list;          /* pending work list */
>>>> @@ -948,15 +949,25 @@ static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>>>>                                bool range_cyclic, enum wb_reason reason)
>>>>  {
>>>>         struct wb_writeback_work *work;
>>>> +       bool zero_pages = false;
>>>>
>>>>         if (!wb_has_dirty_io(wb))
>>>>                 return;
>>>>
>>>>         /*
>>>> -        * If someone asked for zero pages, we write out the WORLD
>>>> +        * If someone asked for zero pages, we write out the WORLD.
>>>> +        * Places like vmscan and laptop mode want to queue a wakeup to
>>>> +        * the flusher threads to clean out everything. To avoid potentially
>>>> +        * having tons of these pending, ensure that we only allow one of
>>>> +        * them pending and inflight at the time
>>>>          */
>>>> -       if (!nr_pages)
>>>> +       if (!nr_pages) {
>>>> +               if (test_bit(WB_zero_pages, &wb->state))
>>>> +                       return;
>>>> +               set_bit(WB_zero_pages, &wb->state);
>>>
>>> Shouldn't this be test_and_set? not the worst outcome if you have more
>>> than one pending work item, but still.
>>
>> If the frequency of these is high, and they were to trigger the bad
>> conditions we saw, then a split test + set is faster as it won't
>> keep re-dirtying the same cacheline from multiple locations. It's
>> better to leave it a little racy, but faster.
>>
> 
> Fare enough, but then better change the language of the commit message and
> comment above not to claim that there can be only one pending work item.

That's unchanged, the commit message should be fine. We clear the
bit when we start the work item, so we can have one in flight and
one pending.

But it does reference 'zero_pages', I'll update that.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
