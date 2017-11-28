Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 61A636B02DB
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 04:43:19 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id x13so138187iti.0
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 01:43:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n88sor14281905ioo.193.2017.11.28.01.43.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 01:43:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALOAHbDBgU8d-n9rseeWUyAiYn9YOjL02VMZw1Xt0XhZhWq4-A@mail.gmail.com>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz> <CALOAHbDNbFs51mW0kUFXcqqyJy+ydpHPaRbvquPVrPTY5HGeRg@mail.gmail.com>
 <CALOAHbCzLYRp8G6H58vfiEJZQDxhcRx5=LqMsDc7rPQ4Erg=1w@mail.gmail.com>
 <20171128074506.bw5r2wzt3pooyu22@dhcp22.suse.cz> <CALOAHbDBgU8d-n9rseeWUyAiYn9YOjL02VMZw1Xt0XhZhWq4-A@mail.gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 28 Nov 2017 17:43:17 +0800
Message-ID: <CALOAHbBEaMoh_jfjTHt-7uj-Ft4-1nNa8eua1VjCrV0JhnDrew@mail.gmail.com>
Subject: Re: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
 dirtiness settings are illogical" (was: Re: [PATCH] mm: print a warning once
 the vm dirtiness settings is illogical)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>

2017-11-28 15:52 GMT+08:00 Yafang Shao <laoar.shao@gmail.com>:
> 2017-11-28 15:45 GMT+08:00 Michal Hocko <mhocko@suse.com>:
>> On Tue 28-11-17 14:12:15, Yafang Shao wrote:
>>> 2017-11-28 11:11 GMT+08:00 Yafang Shao <laoar.shao@gmail.com>:
>>> > Hi Michal,
>>> >
>>> > What about bellow change ?
>>> > It makes the function  domain_dirty_limits() more clear.
>>> > And the result will have a higher precision.
>>> >
>>> >
>>> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>>> > index 8a15511..2b5e507 100644
>>> > --- a/mm/page-writeback.c
>>> > +++ b/mm/page-writeback.c
>>> > @@ -397,8 +397,8 @@ static void domain_dirty_limits(struct
>>> > dirty_throttle_control *dtc)
>>> >     unsigned long bytes = vm_dirty_bytes;
>>> >     unsigned long bg_bytes = dirty_background_bytes;
>>> >     /* convert ratios to per-PAGE_SIZE for higher precision */
>>> > -   unsigned long ratio = (vm_dirty_ratio * PAGE_SIZE) / 100;
>>> > -   unsigned long bg_ratio = (dirty_background_ratio * PAGE_SIZE) / 100;
>>> > +   unsigned long ratio = vm_dirty_ratio;
>>> > +   unsigned long bg_ratio = dirty_background_ratio;
>>> >     unsigned long thresh;
>>> >     unsigned long bg_thresh;
>>> >     struct task_struct *tsk;
>>> > @@ -416,28 +416,33 @@ static void domain_dirty_limits(struct
>>> > dirty_throttle_control *dtc)
>>> >          */
>>> >         if (bytes)
>>> >             ratio = min(DIV_ROUND_UP(bytes, global_avail),
>>> > -                   PAGE_SIZE);
>>> > +                   100);
>>> >         if (bg_bytes)
>>> >             bg_ratio = min(DIV_ROUND_UP(bg_bytes, global_avail),
>>> > -                      PAGE_SIZE);
>>> > +                      99);   /* bg_ratio should less than ratio */
>>> >         bytes = bg_bytes = 0;
>>> >     }
>>>
>>>
>>> Errata:
>>>
>>>         if (bytes)
>>> -           ratio = min(DIV_ROUND_UP(bytes, global_avail),
>>> -                   PAGE_SIZE);
>>> +           ratio = min(DIV_ROUND_UP(bytes / PAGE_SIZE, global_avail),
>>> +                   100);
>>>         if (bg_bytes)
>>> -           bg_ratio = min(DIV_ROUND_UP(bg_bytes, global_avail),
>>> -                      PAGE_SIZE);
>>> +           bg_ratio = min(DIV_ROUND_UP(bg_bytes / PAGE_SIZE, global_avail),
>>> +                      100 - 1); /* bg_ratio should be less than ratio */
>>>         bytes = bg_bytes = 0;
>>
>> And you really think this makes code easier to follow? I am somehow not
>> conviced...
>>
>
> There's hidden bug in the original code, because it is too complex to
> clearly understand.
> See bellow,
>
> ratio = min(DIV_ROUND_UP(bytes, global_avail),
>                     PAGE_SIZE)
>
> Suppose the vm_dirty_bytes is set to 512M (this is a reasonable
> value), and the global_avail is only 10000 pages (this is not low),
> then DIV_ROUND_UP(bytes, global_avail) is 53688, which is bigger than
> 4096, so the ratio will be 4096.
> That's unreasonable.
>

Besides, when  gdtc is NULL(meaning not for  memcg),  bg_thresh and
thresh could both be bigger than available_memory when
available_memory is very low.
So what is your opinion on that confused code ?

My opinion is when available_memory is very low, don't wake up
for_background writeback, just let the  for_kupdate writeback flush
the dirty data.

Thanks
Yafang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
