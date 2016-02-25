Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB686B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 04:27:42 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id a4so18650307wme.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:27:42 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id x64si3090483wmx.5.2016.02.25.01.27.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 01:27:41 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id a4so2328482wme.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:27:41 -0800 (PST)
Date: Thu, 25 Feb 2016 10:27:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160225092739.GE17573@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225064845.GA505@swordfish>
 <000001d16fad$63fff840$2bffe8c0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001d16fad$63fff840$2bffe8c0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Sergey Senozhatsky' <sergey.senozhatsky.work@gmail.com>, 'Hugh Dickins' <hughd@google.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@i-love.sakura.ne.jp>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>

On Thu 25-02-16 17:17:45, Hillf Danton wrote:
[...]
> > OOM example:
> > 
> > [ 2392.663170] zram-test.sh invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2,  oom_score_adj=0
[...]
> > [ 2392.663260] DMA: 4*4kB (M) 1*8kB (M) 4*16kB (ME) 1*32kB (M) 2*64kB (UE) 2*128kB (UE) 3*256kB (UME) 3*512kB (UME) 2*1024kB (ME) 1*2048kB (E) 2*4096kB (M) = 15096kB
> > [ 2392.663284] DMA32: 5809*4kB (UME) 3*8kB (M) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 23260kB
> > [ 2392.663293] Normal: 1515*4kB (UME) 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6060kB

[...]
> > [ 2400.152464] zram-test.sh invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[...]
> > [ 2400.152558] DMA: 4*4kB (M) 1*8kB (M) 4*16kB (ME) 1*32kB (M) 2*64kB (UE) 2*128kB (UE) 3*256kB (UME) 3*512kB (UME)  2*1024kB (ME) 1*2048kB (E) 2*4096kB (M) = 15096kB
> > [ 2400.152573] DMA32: 7835*4kB (UME) 55*8kB (M) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 31780kB
> > [ 2400.152582] Normal: 1383*4kB (UM) 22*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =  5708kB
[...]
> Thanks for your info.
> 
> Can you please schedule a run for the diff attached, in which 
> non-expensive allocators are allowed to burn more CPU cycles.

I do not think your patch will help. As you can see, both OOMs were for
order-2 and there simply are no order-2+ free blocks usable for the
allocation request so the watermark check will fail for all eligible
zones and no_progress_loops is simply ignored. This is what I've tried
to address by patch I have just posted as a reply to Hugh's email
http://lkml.kernel.org/r/20160225092315.GD17573@dhcp22.suse.cz

> --- a/mm/page_alloc.c	Thu Feb 25 15:43:18 2016
> +++ b/mm/page_alloc.c	Thu Feb 25 16:46:05 2016
> @@ -3113,6 +3113,8 @@ should_reclaim_retry(gfp_t gfp_mask, uns
>  	struct zone *zone;
>  	struct zoneref *z;
>  
> +	if (order <= PAGE_ALLOC_COSTLY_ORDER)
> +		no_progress_loops /= 2;
>  	/*
>  	 * Make sure we converge to OOM if we cannot make any progress
>  	 * several times in the row.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
