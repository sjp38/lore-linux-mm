Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 875406B02E2
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 05:09:50 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b202so63862wmb.9
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:09:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34si263943edj.475.2017.11.28.02.09.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 02:09:49 -0800 (PST)
Date: Tue, 28 Nov 2017 11:09:46 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
 dirtiness settings are illogical" (was: Re: [PATCH] mm: print a warning once
 the vm dirtiness settings is illogical)
Message-ID: <20171128100946.GI5977@quack2.suse.cz>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz>
 <CALOAHbDNbFs51mW0kUFXcqqyJy+ydpHPaRbvquPVrPTY5HGeRg@mail.gmail.com>
 <CALOAHbCzLYRp8G6H58vfiEJZQDxhcRx5=LqMsDc7rPQ4Erg=1w@mail.gmail.com>
 <20171128074506.bw5r2wzt3pooyu22@dhcp22.suse.cz>
 <CALOAHbDBgU8d-n9rseeWUyAiYn9YOjL02VMZw1Xt0XhZhWq4-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbDBgU8d-n9rseeWUyAiYn9YOjL02VMZw1Xt0XhZhWq4-A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>

On Tue 28-11-17 15:52:50, Yafang Shao wrote:
> 2017-11-28 15:45 GMT+08:00 Michal Hocko <mhocko@suse.com>:
> > On Tue 28-11-17 14:12:15, Yafang Shao wrote:
> >> 2017-11-28 11:11 GMT+08:00 Yafang Shao <laoar.shao@gmail.com>:
> >> > Hi Michal,
> >> >
> >> > What about bellow change ?
> >> > It makes the function  domain_dirty_limits() more clear.
> >> > And the result will have a higher precision.
> >> >
> >> >
> >> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> >> > index 8a15511..2b5e507 100644
> >> > --- a/mm/page-writeback.c
> >> > +++ b/mm/page-writeback.c
> >> > @@ -397,8 +397,8 @@ static void domain_dirty_limits(struct
> >> > dirty_throttle_control *dtc)
> >> >     unsigned long bytes = vm_dirty_bytes;
> >> >     unsigned long bg_bytes = dirty_background_bytes;
> >> >     /* convert ratios to per-PAGE_SIZE for higher precision */
> >> > -   unsigned long ratio = (vm_dirty_ratio * PAGE_SIZE) / 100;
> >> > -   unsigned long bg_ratio = (dirty_background_ratio * PAGE_SIZE) / 100;
> >> > +   unsigned long ratio = vm_dirty_ratio;
> >> > +   unsigned long bg_ratio = dirty_background_ratio;
> >> >     unsigned long thresh;
> >> >     unsigned long bg_thresh;
> >> >     struct task_struct *tsk;
> >> > @@ -416,28 +416,33 @@ static void domain_dirty_limits(struct
> >> > dirty_throttle_control *dtc)
> >> >          */
> >> >         if (bytes)
> >> >             ratio = min(DIV_ROUND_UP(bytes, global_avail),
> >> > -                   PAGE_SIZE);
> >> > +                   100);
> >> >         if (bg_bytes)
> >> >             bg_ratio = min(DIV_ROUND_UP(bg_bytes, global_avail),
> >> > -                      PAGE_SIZE);
> >> > +                      99);   /* bg_ratio should less than ratio */
> >> >         bytes = bg_bytes = 0;
> >> >     }
> >>
> >>
> >> Errata:
> >>
> >>         if (bytes)
> >> -           ratio = min(DIV_ROUND_UP(bytes, global_avail),
> >> -                   PAGE_SIZE);
> >> +           ratio = min(DIV_ROUND_UP(bytes / PAGE_SIZE, global_avail),
> >> +                   100);
> >>         if (bg_bytes)
> >> -           bg_ratio = min(DIV_ROUND_UP(bg_bytes, global_avail),
> >> -                      PAGE_SIZE);
> >> +           bg_ratio = min(DIV_ROUND_UP(bg_bytes / PAGE_SIZE, global_avail),
> >> +                      100 - 1); /* bg_ratio should be less than ratio */
> >>         bytes = bg_bytes = 0;
> >
> > And you really think this makes code easier to follow? I am somehow not
> > conviced...
> >
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

But that's not a bug in domain_dirty_limits(). It is more a design issue of
the dirty_bytes interface - i.e., if you tell the system that 512M of dirty
pages is fine, then it is fine even if you have only 400M of page cache -
i.e., 100% of page cache can be dirty and that's what the function
computes.  Bad luck if you don't like that but that's how the interface was
(mis)designed. We can talk about changes to what dirty_bytes mean under a
situation when there is low amount of page cache but that will be a
userspace visible change and we will have to be *very* careful not to break
current users.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
