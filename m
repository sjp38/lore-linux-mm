Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFFE66B027C
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 01:12:16 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id g73so38328218ioj.0
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 22:12:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d13sor9234994itj.18.2017.11.27.22.12.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 22:12:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALOAHbDNbFs51mW0kUFXcqqyJy+ydpHPaRbvquPVrPTY5HGeRg@mail.gmail.com>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz> <CALOAHbDNbFs51mW0kUFXcqqyJy+ydpHPaRbvquPVrPTY5HGeRg@mail.gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 28 Nov 2017 14:12:15 +0800
Message-ID: <CALOAHbCzLYRp8G6H58vfiEJZQDxhcRx5=LqMsDc7rPQ4Erg=1w@mail.gmail.com>
Subject: Re: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
 dirtiness settings are illogical" (was: Re: [PATCH] mm: print a warning once
 the vm dirtiness settings is illogical)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>

2017-11-28 11:11 GMT+08:00 Yafang Shao <laoar.shao@gmail.com>:
> Hi Michal,
>
> What about bellow change ?
> It makes the function  domain_dirty_limits() more clear.
> And the result will have a higher precision.
>
>
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 8a15511..2b5e507 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -397,8 +397,8 @@ static void domain_dirty_limits(struct
> dirty_throttle_control *dtc)
>     unsigned long bytes = vm_dirty_bytes;
>     unsigned long bg_bytes = dirty_background_bytes;
>     /* convert ratios to per-PAGE_SIZE for higher precision */
> -   unsigned long ratio = (vm_dirty_ratio * PAGE_SIZE) / 100;
> -   unsigned long bg_ratio = (dirty_background_ratio * PAGE_SIZE) / 100;
> +   unsigned long ratio = vm_dirty_ratio;
> +   unsigned long bg_ratio = dirty_background_ratio;
>     unsigned long thresh;
>     unsigned long bg_thresh;
>     struct task_struct *tsk;
> @@ -416,28 +416,33 @@ static void domain_dirty_limits(struct
> dirty_throttle_control *dtc)
>          */
>         if (bytes)
>             ratio = min(DIV_ROUND_UP(bytes, global_avail),
> -                   PAGE_SIZE);
> +                   100);
>         if (bg_bytes)
>             bg_ratio = min(DIV_ROUND_UP(bg_bytes, global_avail),
> -                      PAGE_SIZE);
> +                      99);   /* bg_ratio should less than ratio */
>         bytes = bg_bytes = 0;
>     }


Errata:

        if (bytes)
-           ratio = min(DIV_ROUND_UP(bytes, global_avail),
-                   PAGE_SIZE);
+           ratio = min(DIV_ROUND_UP(bytes / PAGE_SIZE, global_avail),
+                   100);
        if (bg_bytes)
-           bg_ratio = min(DIV_ROUND_UP(bg_bytes, global_avail),
-                      PAGE_SIZE);
+           bg_ratio = min(DIV_ROUND_UP(bg_bytes / PAGE_SIZE, global_avail),
+                      100 - 1); /* bg_ratio should be less than ratio */
        bytes = bg_bytes = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
