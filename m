Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD896B02ED
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 05:41:16 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u98so15346478wrb.17
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:41:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 96si2030409edr.280.2017.11.28.02.41.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 02:41:14 -0800 (PST)
Date: Tue, 28 Nov 2017 11:41:14 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
 dirtiness settings are illogical" (was: Re: [PATCH] mm: print a warning once
 the vm dirtiness settings is illogical)
Message-ID: <20171128104114.GL5977@quack2.suse.cz>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz>
 <CALOAHbDNbFs51mW0kUFXcqqyJy+ydpHPaRbvquPVrPTY5HGeRg@mail.gmail.com>
 <20171128102559.GJ5977@quack2.suse.cz>
 <CALOAHbBRiv48N_puVW18QX3MHoDU3CvMaa7BwxONAKWSOGWJcg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbBRiv48N_puVW18QX3MHoDU3CvMaa7BwxONAKWSOGWJcg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On Tue 28-11-17 18:33:02, Yafang Shao wrote:
> 2017-11-28 18:25 GMT+08:00 Jan Kara <jack@suse.cz>:
> > Hi Yafang,
> >
> > On Tue 28-11-17 11:11:40, Yafang Shao wrote:
> >> What about bellow change ?
> >> It makes the function  domain_dirty_limits() more clear.
> >> And the result will have a higher precision.
> >
> > Frankly, I don't find this any better and you've just lost the additional
> > precision of ratios computed in the "if (gdtc)" branch the multiplication by
> > PAGE_SIZE got us.
> >
> 
> What about bellow change? It won't be lost any more, becasue
> bytes and bg_bytes are both PAGE_SIZE aligned.
> 
> -       if (bytes)
> -           ratio = min(DIV_ROUND_UP(bytes, global_avail),
> -                   PAGE_SIZE);
> -       if (bg_bytes)
> -           bg_ratio = min(DIV_ROUND_UP(bg_bytes, global_avail),
> -                      PAGE_SIZE);
> +       if (bytes) {
> +           pages = DIV_ROUND_UP(bytes, PAGE_SIZE);
> +           ratio = DIV_ROUND_UP(pages * 100, global_avail);
> +
> +       }
> +
> +       if (bg_bytes) {
> +           pages = DIV_ROUND_UP(bg_bytes, PAGE_SIZE);
> +           bg_ratio = DIV_ROUND_UP(pages * 100, global_avail);
> +       }

Not better... Look, in the original code the 'ratio' and 'bg_ratio'
variables contain a number between 0 and 1 as fractions of 1/PAGE_SIZE. In
your code you have in these variables fractions of 1/100. That's certainly
less precise no matter how you get to those numbers.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
