Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57D676B0069
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 07:36:49 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id m189so16585089itg.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 04:36:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 29sor1804364iog.139.2017.10.09.04.36.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Oct 2017 04:36:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171009110332.GG17917@quack2.suse.cz>
References: <CALOAHbAS_DyhOarH0ZEBWfmB_3wvEV2WA_k_UzUe7b+QRAQ=6A@mail.gmail.com>
 <20171009110332.GG17917@quack2.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Mon, 9 Oct 2017 19:36:48 +0800
Message-ID: <CALOAHbBchSdqQ0ab6NMSPT+19-yR0YjUZS3Kh_9A2F=gVzNtew@mail.gmail.com>
Subject: Re: [PATCH] mm/page-writeback.c: fix bug caused by disable periodic writeback
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, Johannes Weiner <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, Theodore Ts'o <tytso@mit.edu>, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, axboe@kernel.dk

2017-10-09 19:03 GMT+08:00 Jan Kara <jack@suse.cz>:
> On Mon 09-10-17 18:44:23, Yafang Shao wrote:
>> 2017-10-09 17:56 GMT+08:00 Jan Kara <jack@suse.cz>:
>> > On Sat 07-10-17 06:58:04, Yafang Shao wrote:
>> >> After disable periodic writeback by writing 0 to
>> >> dirty_writeback_centisecs, the handler wb_workfn() will not be
>> >> entered again until the dirty background limit reaches or
>> >> sync syscall is executed or no enough free memory available or
>> >> vmscan is triggered.
>> >> So the periodic writeback can't be enabled by writing a non-zero
>> >> value to dirty_writeback_centisecs
>> >> As it can be disabled by sysctl, it should be able to enable by
>> >> sysctl as well.
>> >>
>> >> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
>> >> ---
>> >>  mm/page-writeback.c | 8 +++++++-
>> >>  1 file changed, 7 insertions(+), 1 deletion(-)
>> >>
>> >> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> >> index 0b9c5cb..e202f37 100644
>> >> --- a/mm/page-writeback.c
>> >> +++ b/mm/page-writeback.c
>> >> @@ -1972,7 +1972,13 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
>> >>  int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
>> >>       void __user *buffer, size_t *length, loff_t *ppos)
>> >>  {
>> >> -     proc_dointvec(table, write, buffer, length, ppos);
>> >> +     unsigned int old_interval = dirty_writeback_interval;
>> >> +     int ret;
>> >> +
>> >> +     ret = proc_dointvec(table, write, buffer, length, ppos);
>> >> +     if (!ret && !old_interval && dirty_writeback_interval)
>> >> +             wakeup_flusher_threads(0, WB_REASON_PERIODIC);
>> >> +
>> >
>> > I agree it is good to schedule some writeback. However Jens has some
>> > changes queued in linux-block tree in this area so your change won't apply.
>> > So please base your changes on his tree.
>> >
>>
>> Do you mean this tree
>> git://git.kernel.org/pub/scm/linux/kernel/git/axboe/linux-block.git ?
>>
>> I have checked his tree and find nothing need to change on my patch.
>
> Yes, I mean that tree. Check the wb_start_all branch.
>

Got it!
I will implement it base on this branch.

>                                                                 Honza
> --
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

Thanks
Yafang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
