Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 03B906B0282
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:45:10 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o20so8842680wro.8
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:45:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e11si2469261eda.52.2017.11.27.23.45.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 23:45:07 -0800 (PST)
Date: Tue, 28 Nov 2017 08:45:06 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
 dirtiness settings are illogical" (was: Re: [PATCH] mm: print a warning once
 the vm dirtiness settings is illogical)
Message-ID: <20171128074506.bw5r2wzt3pooyu22@dhcp22.suse.cz>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz>
 <CALOAHbDNbFs51mW0kUFXcqqyJy+ydpHPaRbvquPVrPTY5HGeRg@mail.gmail.com>
 <CALOAHbCzLYRp8G6H58vfiEJZQDxhcRx5=LqMsDc7rPQ4Erg=1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbCzLYRp8G6H58vfiEJZQDxhcRx5=LqMsDc7rPQ4Erg=1w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>

On Tue 28-11-17 14:12:15, Yafang Shao wrote:
> 2017-11-28 11:11 GMT+08:00 Yafang Shao <laoar.shao@gmail.com>:
> > Hi Michal,
> >
> > What about bellow change ?
> > It makes the function  domain_dirty_limits() more clear.
> > And the result will have a higher precision.
> >
> >
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index 8a15511..2b5e507 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -397,8 +397,8 @@ static void domain_dirty_limits(struct
> > dirty_throttle_control *dtc)
> >     unsigned long bytes = vm_dirty_bytes;
> >     unsigned long bg_bytes = dirty_background_bytes;
> >     /* convert ratios to per-PAGE_SIZE for higher precision */
> > -   unsigned long ratio = (vm_dirty_ratio * PAGE_SIZE) / 100;
> > -   unsigned long bg_ratio = (dirty_background_ratio * PAGE_SIZE) / 100;
> > +   unsigned long ratio = vm_dirty_ratio;
> > +   unsigned long bg_ratio = dirty_background_ratio;
> >     unsigned long thresh;
> >     unsigned long bg_thresh;
> >     struct task_struct *tsk;
> > @@ -416,28 +416,33 @@ static void domain_dirty_limits(struct
> > dirty_throttle_control *dtc)
> >          */
> >         if (bytes)
> >             ratio = min(DIV_ROUND_UP(bytes, global_avail),
> > -                   PAGE_SIZE);
> > +                   100);
> >         if (bg_bytes)
> >             bg_ratio = min(DIV_ROUND_UP(bg_bytes, global_avail),
> > -                      PAGE_SIZE);
> > +                      99);   /* bg_ratio should less than ratio */
> >         bytes = bg_bytes = 0;
> >     }
> 
> 
> Errata:
> 
>         if (bytes)
> -           ratio = min(DIV_ROUND_UP(bytes, global_avail),
> -                   PAGE_SIZE);
> +           ratio = min(DIV_ROUND_UP(bytes / PAGE_SIZE, global_avail),
> +                   100);
>         if (bg_bytes)
> -           bg_ratio = min(DIV_ROUND_UP(bg_bytes, global_avail),
> -                      PAGE_SIZE);
> +           bg_ratio = min(DIV_ROUND_UP(bg_bytes / PAGE_SIZE, global_avail),
> +                      100 - 1); /* bg_ratio should be less than ratio */
>         bytes = bg_bytes = 0;

And you really think this makes code easier to follow? I am somehow not
conviced...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
