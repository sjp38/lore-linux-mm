Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8D56B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 08:13:59 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id n5so28677142wmn.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 05:13:59 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 67si40508869wmf.30.2016.01.20.05.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 05:13:57 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id b14so4077646wmb.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 05:13:57 -0800 (PST)
Date: Wed, 20 Jan 2016 14:13:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, oom: rework oom detection
Message-ID: <20160120131355.GE14187@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <1450203586-10959-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1601141436410.22665@chino.kir.corp.google.com>
 <201601161007.DDG56185.QOHMOFOLtSFJVF@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1601191444520.7346@chino.kir.corp.google.com>
 <201601202013.EHC65659.QOtOHLOFJVFFSM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601202013.EHC65659.QOtOHLOFJVFFSM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 20-01-16 20:13:32, Tetsuo Handa wrote:
[...]
> Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160120.txt.xz .

> [  141.987548] zone=DMA32 reclaimable=367085 available=371232 no_progress_loops=0 did_some_progress=60 nr_reserved_highatomic=0 no_free=1

Ok, so we really do not have _any_ pages on the order 2+ free lists and
that is why __zone_watermark_ok failed.

> [  141.990091] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=60 nr_reserved_highatomic=0 no_free=0

DMA zone is not even interesting because it is fully protected by the
lowmem reserves.

> [  141.997360] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[...]
> [  142.086897] Node 0 DMA32: 1796*4kB (M) 763*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 13288kB

And indeed we still do not have any order-2+ available. OOM seems
reasonable.

> [  142.914557] zone=DMA32 reclaimable=345975 available=348821 no_progress_loops=0 did_some_progress=58 nr_reserved_highatomic=0 no_free=1
> [  142.914558] zone=DMA reclaimable=2 available=1980 no_progress_loops=0 did_some_progress=58 nr_reserved_highatomic=0 no_free=0
> [  142.921113] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[...]
> [  142.921192] Node 0 DMA32: 1794*4kB (UME) 464*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10888kB

Ditto

> [  153.615466] zone=DMA32 reclaimable=385567 available=389678 no_progress_loops=0 did_some_progress=36 nr_reserved_highatomic=0 no_free=1
> [  153.615467] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=36 nr_reserved_highatomic=0 no_free=0
> [  153.620507] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[...]
> [  153.620582] Node 0 DMA32: 1241*4kB (UME) 1280*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15204kB

Ditto

> [  153.658621] zone=DMA32 reclaimable=384064 available=388833 no_progress_loops=0 did_some_progress=37 nr_reserved_highatomic=0 no_free=1
> [  153.658623] zone=DMA reclaimable=2 available=1983 no_progress_loops=0 did_some_progress=37 nr_reserved_highatomic=0 no_free=0
> [  153.663401] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[...]
> [  153.663480] Node 0 DMA32: 554*4kB (UME) 2148*8kB (UM) 3*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 19448kB

Now we have __zone_watermark_ok claiming no order 2+ blocks available
but oom report little bit later sees 3 blocks. This would suggest that
this is just a matter of timing when the children exit and free their
stacks which are order-2.

> [  159.614894] zone=DMA32 reclaimable=356635 available=361925 no_progress_loops=0 did_some_progress=32 nr_reserved_highatomic=0 no_free=1
> [  159.614895] zone=DMA reclaimable=2 available=1983 no_progress_loops=0 did_some_progress=32 nr_reserved_highatomic=0 no_free=0
> [  159.622374] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[...]
> [  159.622451] Node 0 DMA32: 2141*4kB (UM) 1435*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 20044kB

Again no high order pages.

> [  164.781516] zone=DMA32 reclaimable=393457 available=397561 no_progress_loops=0 did_some_progress=40 nr_reserved_highatomic=0 no_free=1
> [  164.781518] zone=DMA reclaimable=1 available=1983 no_progress_loops=0 did_some_progress=40 nr_reserved_highatomic=0 no_free=0
> [  164.786560] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[...]
> [  164.786643] Node 0 DMA32: 2961*4kB (UME) 432*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15300kB

Ditto

> [  184.631660] zone=DMA32 reclaimable=356652 available=359338 no_progress_loops=0 did_some_progress=60 nr_reserved_highatomic=0 no_free=1
> [  184.634207] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=60 nr_reserved_highatomic=0 no_free=0
> [  184.642800] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[...]
> [  184.728695] Node 0 DMA32: 3144*4kB (UME) 971*8kB (UME) 43*16kB (UM) 3*32kB (M) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 21128kB

Again we have order >=2 pages available here after the allocator has
seen none earlier. And the pattern repeats later on. So I would say
that in this particular load it is a timing which plays the role. I
am not sure we can tune for such a load beause any difference in the
timing would result in a different behavior and basically breaking such
a tuning.

The current heuristic is based on an assumption that retrying for high
order allocations only makes sense if they are hidden behind the min
watermark and the currently reclaimable pages would get us above the
watermark. We cannot assume that the order-0 reclaimable pages will form
the required high order blocks because there is no such guarantee.  I
think such a heuristic makes sense because we have passed the direct
reclaim and also compaction at the time when we check for the retry
so chances to get the required block from the reclaim are not that high.

So I am not really sure what to do here now. On one hand the previous
heuristic would happen to work here probably better because we would be
looping in the allocator, exiting processes would rest the counter and
keep the retries and sooner or later the fork would be lucky and see its
order-2 block and continue. We could starve in this state for basically
unbounded amount of time though which is excatly what I would like to
get rid of. I guess we might want to give few attempts to retry for
all order>0. Let me think about it some more.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
