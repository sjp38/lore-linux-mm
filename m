Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1FF6B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 07:36:58 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k101so830127iod.1
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 04:36:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p194sor2465464itc.1.2017.09.18.04.36.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Sep 2017 04:36:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170918102244.GJ32516@quack2.suse.cz>
References: <1505669968-12593-1-git-send-email-laoar.shao@gmail.com> <20170918102244.GJ32516@quack2.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Mon, 18 Sep 2017 19:36:56 +0800
Message-ID: <CALOAHbDe+k9Wh401bDh_ZsvFDr22kWPNJfMrfg_Xcy_RBSYFxg@mail.gmail.com>
Subject: Re: [PATCH] mm: introduce sanity check on dirty ratio sysctl value
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, mhocko@suse.com, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, Theodore Ts'o <tytso@mit.edu>, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2017-09-18 18:22 GMT+08:00 Jan Kara <jack@suse.cz>:
> On Mon 18-09-17 01:39:28, Yafang Shao wrote:
>> we can find the logic in domain_dirty_limits() that
>> when dirty bg_thresh is bigger than dirty thresh,
>> bg_thresh will be set as thresh * 1 / 2.
>>       if (bg_thresh >= thresh)
>>               bg_thresh = thresh / 2;
>>
>> But actually we can set dirty_background_raio bigger than
>> dirty_ratio successfully. This behavior may mislead us.
>> So we should do this sanity check at the beginning.
>>
>> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
>
> ...
>
>>  {
>> +     int old_ratio = dirty_background_ratio;
>> +     unsigned long bytes;
>>       int ret;
>>
>>       ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
>> -     if (ret == 0 && write)
>> -             dirty_background_bytes = 0;
>> +
>> +     if (ret == 0 && write) {
>> +             if (vm_dirty_ratio > 0) {
>> +                     if (dirty_background_ratio >= vm_dirty_ratio)
>> +                             ret = -EINVAL;
>> +             } else if (vm_dirty_bytes > 0) {
>> +                     bytes = global_dirtyable_memory() * PAGE_SIZE *
>> +                                     dirty_background_ratio / 100;
>> +                     if (bytes >= vm_dirty_bytes)
>> +                             ret = -EINVAL;
>> +             }
>> +
>> +             if (ret == 0)
>> +                     dirty_background_bytes = 0;
>> +             else
>> +                     dirty_background_ratio = old_ratio;
>> +     }
>> +
>
> How about implementing something like
>
> bool vm_dirty_settings_valid(void)
>
> helper which would validate whether current dirtiness settings are
> consistent. That way we would not have to repeat very similar checks four
> times.

That seems a smarter way.

> Also the arithmetics in:
>
> global_dirtyable_memory() * PAGE_SIZE * dirty_background_ratio / 100
>
> could overflow so I'd prefer to first divide by 100 and then multiply by
> dirty_background_ratio...
>
Oh, yes. It could overflow.

>                                                                 Honza
> --
> Jan Kara <jack@suse.com>
> SUSE Labs, CR


I will reimplement it and submit a new patch.

Thanks
Yafang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
