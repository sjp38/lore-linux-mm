Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id D43446B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 04:00:31 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id q190so16796322vkd.20
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 01:00:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e27sor2435403iod.32.2017.10.10.01.00.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 01:00:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171009154212.bdf3645a2dce5d540657914b@linux-foundation.org>
References: <1507330684-2205-1-git-send-email-laoar.shao@gmail.com> <20171009154212.bdf3645a2dce5d540657914b@linux-foundation.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 10 Oct 2017 16:00:29 +0800
Message-ID: <CALOAHbBRxYqhoeqzDiCNcpA6PG9ysAknaRBseCEYLoV1M9MyHA@mail.gmail.com>
Subject: Re: [PATCH] mm/page-writeback.c: fix bug caused by disable periodic writeback
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, mhocko@suse.com, Johannes Weiner <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, Theodore Ts'o <tytso@mit.edu>, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>

2017-10-10 6:42 GMT+08:00 Andrew Morton <akpm@linux-foundation.org>:
> On Sat,  7 Oct 2017 06:58:04 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:
>
>> After disable periodic writeback by writing 0 to
>> dirty_writeback_centisecs, the handler wb_workfn() will not be
>> entered again until the dirty background limit reaches or
>> sync syscall is executed or no enough free memory available or
>> vmscan is triggered.
>> So the periodic writeback can't be enabled by writing a non-zero
>> value to dirty_writeback_centisecs
>> As it can be disabled by sysctl, it should be able to enable by
>> sysctl as well.
>>
>> ...
>>
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -1972,7 +1972,13 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
>>  int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
>>       void __user *buffer, size_t *length, loff_t *ppos)
>>  {
>> -     proc_dointvec(table, write, buffer, length, ppos);
>> +     unsigned int old_interval = dirty_writeback_interval;
>> +     int ret;
>> +
>> +     ret = proc_dointvec(table, write, buffer, length, ppos);
>> +     if (!ret && !old_interval && dirty_writeback_interval)
>> +             wakeup_flusher_threads(0, WB_REASON_PERIODIC);
>> +
>>       return 0;
>
> We could do with a code comment here, explaining why this code exists.
>

OK. I will comment here.

> And...  I'm not sure it works correctly?  For example, if a device
> doesn't presently have bdi_has_dirty_io() then wakeup_flusher_threads()
> will skip it and the periodic writeback still won't be started?
>

That's an issue.
The periodic writeback won't be started.

Maybe we'd better call  wb_wakeup_delayed(wb) here to bypass the
bdi_has_dirty_io() check ?
But then I find another issue exisit in the periodic writeback, in
function wb_workfn().

    } else if (wb_has_dirty_io(wb) && dirty_writeback_interval) {
        wb_wakeup_delayed(wb);
    }

>From the above code, we can find that if wb_has_dirty_io return false,
then bdi_writeback will not be wakeup until some other conditions
happen.
Seems we have to check periodically no matther whether there's dirty
IO or not ?

But then, introduce another issue,
If there's no dirty IO but we wakeup the bdi_writeback periodically or
do some other periodic check, there will be  performance hit .

Per my understanding, maybe the periodic writeback needs reimplement.

> (why does the dirty_writeback_interval==0 special case exist, btw?
> Seems to be a strange thing to do).
>

I agree with you.
we'd better impelment as bellow?
    if (!ret && write && dirty_writeback_interval &&
dirty_writeback_interval != old_interva)
        do_something();

> (and what happens if the interval was set to 1 hour and the user
> rewrites that to 1 second?  Does that change take 1 hour to take
> effect?)
>

If we rewirte it as above.
It will wakeup the bdi_writeback immdiately, see bellow:
    wakeup_flusher_threads
        mod_delayed_work(bdi_wq, &wb->dwork, 0);   <<< here's 0.
Next time, it will run periodically.

But is this a good implementation ?
Should we wakeup the bdi_writeback after the interval that we set?
That means, using  wb_wakeup_delayed() instead of
wakeup_flusher_threads(), that's I prefer to.

Thanks
Yafang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
