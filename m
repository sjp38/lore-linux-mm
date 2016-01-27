Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3957E828E2
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 18:18:14 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id uo6so12407947pac.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 15:18:14 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id rt5si12324008pab.98.2016.01.27.15.18.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 15:18:13 -0800 (PST)
Received: by mail-pa0-x22d.google.com with SMTP id ho8so12136282pac.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 15:18:13 -0800 (PST)
Date: Wed, 27 Jan 2016 15:18:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
In-Reply-To: <20160120122422.GD14187@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1601271513310.1248@chino.kir.corp.google.com>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp> <201512282108.EDI82328.OHFLtVJOSQFMFO@I-love.SAKURA.ne.jp> <20151229163249.GD10321@dhcp22.suse.cz> <201512310005.DFJ21839.QOOSVFFHMLJOtF@I-love.SAKURA.ne.jp>
 <201601030047.HJF60980.HJOSFQOMLVFFtO@I-love.SAKURA.ne.jp> <20160120122422.GD14187@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 20 Jan 2016, Michal Hocko wrote:

> > That trigger was introduced by commit 97a16fc82a7c5b0c ("mm, page_alloc: only
> > enforce watermarks for order-0 allocations"), and "mm, oom: rework oom detection"
> > patch hits the trigger.
> [....]
> > [  154.829582] zone=DMA32 reclaimable=308907 available=312734 no_progress_loops=0 did_some_progress=50
> > [  154.831562] zone=DMA reclaimable=2 available=1728 no_progress_loops=0 did_some_progress=50
> > [  154.838499] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
> > [  154.841167] fork cpuset=/ mems_allowed=0
> [...]
> > [  154.917857] Node 0 DMA32 free:17996kB min:5172kB low:6464kB high:7756kB ....
> [...]
> > [  154.931918] Node 0 DMA: 107*4kB (UME) 72*8kB (ME) 47*16kB (UME) 19*32kB (UME) 9*64kB (ME) 1*128kB (M) 3*256kB (M) 2*512kB (E) 2*1024kB (UM) 0*2048kB 0*4096kB = 6908kB
> > [  154.937453] Node 0 DMA32: 1113*4kB (UME) 1400*8kB (UME) 116*16kB (UM) 15*32kB (UM) 1*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18052kB
> 
> It is really strange that __zone_watermark_ok claimed DMA32 unusable
> here. With the target of 312734 which should easilly pass the wmark
> check for the particular order and there are 116*16kB 15*32kB 1*64kB
> blocks "usable" for our request because GFP_KERNEL can use both
> Unmovable and Movable blocks. So it makes sense to wait for more order-0
> allocations to pass the basic (NR_FREE_MEMORY) watermark and continue
> with this particular allocation request.
> 
> The nr_reserved_highatomic might be too high to matter but then you see
> [1] the reserce being 0. So this doesn't make much sense to me. I will
> dig into it some more.
> 
> [1] http://lkml.kernel.org/r/201601161007.DDG56185.QOHMOFOLtSFJVF@I-love.SAKURA.ne.jp

There's another issue in the use of zone_reclaimable_pages().  I think 
should_reclaim_retry() using zone_page_state_snapshot() is approrpriate, 
as I indicated before, but notice that zone_reclaimable_pages() only uses 
zone_page_state().  It means that the heuristic is based on some 
up-to-date members and some stale members.  If we are relying on 
NR_ISOLATED_* to be accurate, for example, in zone_reclaimable_pages(), 
then it may take up to 1s for that to actually occur and may quickly 
exhaust the retry counter in should_reclaim_retry() before that happens.

This is the same issue that Joonsoo reported with the use of 
zone_page_state(NR_ISOLATED_*) in the too_many_isolated() loops of reclaim 
and compaction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
