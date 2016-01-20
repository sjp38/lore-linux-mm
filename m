Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 066F46B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:24:26 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l65so176900823wmf.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 04:24:25 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id g67si40309973wmc.46.2016.01.20.04.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 04:24:24 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id u188so3773717wmu.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 04:24:24 -0800 (PST)
Date: Wed, 20 Jan 2016 13:24:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160120122422.GD14187@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp>
 <201512282108.EDI82328.OHFLtVJOSQFMFO@I-love.SAKURA.ne.jp>
 <20151229163249.GD10321@dhcp22.suse.cz>
 <201512310005.DFJ21839.QOOSVFFHMLJOtF@I-love.SAKURA.ne.jp>
 <201601030047.HJF60980.HJOSFQOMLVFFtO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601030047.HJF60980.HJOSFQOMLVFFtO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 03-01-16 00:47:30, Tetsuo Handa wrote:
[...]
> The output showed that __zone_watermark_ok() returning false on both DMA32 and DMA
> zones is the trigger of the OOM killer invocation. Direct reclaim is constantly
> reclaiming some pages, but I guess freelist for 2 <= order < MAX_ORDER are empty.

Yes and this is to be expected. Direct reclaim doesn't guarantee any
progress for high order allocations. We might be reclaiming pages which
cannot be coalesced.

> That trigger was introduced by commit 97a16fc82a7c5b0c ("mm, page_alloc: only
> enforce watermarks for order-0 allocations"), and "mm, oom: rework oom detection"
> patch hits the trigger.
[....]
> [  154.829582] zone=DMA32 reclaimable=308907 available=312734 no_progress_loops=0 did_some_progress=50
> [  154.831562] zone=DMA reclaimable=2 available=1728 no_progress_loops=0 did_some_progress=50
> [  154.838499] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
> [  154.841167] fork cpuset=/ mems_allowed=0
[...]
> [  154.917857] Node 0 DMA32 free:17996kB min:5172kB low:6464kB high:7756kB ....
[...]
> [  154.931918] Node 0 DMA: 107*4kB (UME) 72*8kB (ME) 47*16kB (UME) 19*32kB (UME) 9*64kB (ME) 1*128kB (M) 3*256kB (M) 2*512kB (E) 2*1024kB (UM) 0*2048kB 0*4096kB = 6908kB
> [  154.937453] Node 0 DMA32: 1113*4kB (UME) 1400*8kB (UME) 116*16kB (UM) 15*32kB (UM) 1*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18052kB

It is really strange that __zone_watermark_ok claimed DMA32 unusable
here. With the target of 312734 which should easilly pass the wmark
check for the particular order and there are 116*16kB 15*32kB 1*64kB
blocks "usable" for our request because GFP_KERNEL can use both
Unmovable and Movable blocks. So it makes sense to wait for more order-0
allocations to pass the basic (NR_FREE_MEMORY) watermark and continue
with this particular allocation request.

The nr_reserved_highatomic might be too high to matter but then you see
[1] the reserce being 0. So this doesn't make much sense to me. I will
dig into it some more.

[1] http://lkml.kernel.org/r/201601161007.DDG56185.QOHMOFOLtSFJVF@I-love.SAKURA.ne.jp
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
