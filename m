Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 983466B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 17:49:01 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id e65so183258245pfe.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:49:01 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id z12si5739200pas.77.2016.01.19.14.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 14:49:00 -0800 (PST)
Received: by mail-pa0-x22b.google.com with SMTP id yy13so365927993pab.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:49:00 -0800 (PST)
Date: Tue, 19 Jan 2016 14:48:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm, oom: rework oom detection
In-Reply-To: <201601161007.DDG56185.QOHMOFOLtSFJVF@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1601191444520.7346@chino.kir.corp.google.com>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <1450203586-10959-2-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1601141436410.22665@chino.kir.corp.google.com> <201601161007.DDG56185.QOHMOFOLtSFJVF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

On Sat, 16 Jan 2016, Tetsuo Handa wrote:

> > Tetsuo's log of an early oom in this thread shows that this check is 
> > wrong.  The allocation in question is an order-2 GFP_KERNEL on a system 
> > with only ZONE_DMA and ZONE_DMA32:
> > 
> > 	zone=DMA32 reclaimable=308907 available=312734 no_progress_loops=0 did_some_progress=50
> > 	zone=DMA reclaimable=2 available=1728 no_progress_loops=0 did_some_progress=50
> > 
> > and the watermarks:
> > 
> > 	Node 0 DMA free:6908kB min:44kB low:52kB high:64kB ...
> > 	lowmem_reserve[]: 0 1714 1714 1714
> > 	Node 0 DMA32 free:17996kB min:5172kB low:6464kB high:7756kB  ...
> > 	lowmem_reserve[]: 0 0 0 0
> > 
> > and the scary thing is that this triggers when no_progress_loops == 0, so 
> > this is the first time trying the allocation after progress has been made.
> > 
> > Watermarks clearly indicate that memory is available, the problem is 
> > fragmentation for the order-2 allocation.  This is not a situation where 
> > we want to immediately call the oom killer to solve since we have no 
> > guarantee it is going to free contiguous memory (in fact it wouldn't be 
> > used at all for PAGE_ALLOC_COSTLY_ORDER).
> > 
> > There is order-2 memory available however:
> > 
> > 	Node 0 DMA32: 1113*4kB (UME) 1400*8kB (UME) 116*16kB (UM) 15*32kB (UM) 1*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18052kB
> > 
> > The failure for ZONE_DMA makes sense for the lowmem_reserve ratio, it's 
> > oom for this allocation.  ZONE_DMA32 is not, however.
> > 
> > I'm wondering if this has to do with the z->nr_reserved_highatomic 
> > estimate.  ZONE_DMA32 present pages is 2080640kB, so this would be limited 
> > to 1%, or 20806kB.  That failure would make sense if free is 17996kB.
> > 
> > Tetsuo, would it be possible to try your workload with just this match and 
> > also show z->nr_reserved_highatomic?
> 
> I don't know what "try your workload with just this match" expects, but
> zone->nr_reserved_highatomic is always 0.
> 

My point about z->nr_reserved_highatomic still stands, specifically that 
pageblocks may be reserved from allocation and __zone_watermark_ok() may 
fail, which would cause a premature oom condition, for this patch's 
calculation of "available".  It may not have caused a problem on your 
specific workload, however.

Are you able to precisely identify why __zone_watermark_ok() is failing 
and triggering the oom in the log you posted January 3?

[  154.829582] zone=DMA32 reclaimable=308907 available=312734 no_progress_loops=0 did_some_progress=50
[  154.831562] zone=DMA reclaimable=2 available=1728 no_progress_loops=0 did_some_progress=50
// here //
[  154.838499] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[  154.841167] fork cpuset=/ mems_allowed=0
[  154.842348] CPU: 1 PID: 9599 Comm: fork Tainted: G        W       4.4.0-rc7-next-20151231+ #273
...
[  154.852386] Call Trace:
[  154.853350]  [<ffffffff81398b83>] dump_stack+0x4b/0x68
[  154.854731]  [<ffffffff811bc81c>] dump_header+0x5b/0x3b0
[  154.856309]  [<ffffffff810bdd79>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[  154.858046]  [<ffffffff810bde4d>] ? trace_hardirqs_on+0xd/0x10
[  154.859593]  [<ffffffff81143d36>] oom_kill_process+0x366/0x540
[  154.861142]  [<ffffffff8114414f>] out_of_memory+0x1ef/0x5a0
[  154.862655]  [<ffffffff8114420d>] ? out_of_memory+0x2ad/0x5a0
[  154.864194]  [<ffffffff81149c72>] __alloc_pages_nodemask+0xda2/0xde0
[  154.865852]  [<ffffffff810bdd00>] ? trace_hardirqs_on_caller+0x80/0x1c0
[  154.867844]  [<ffffffff81149e6c>] alloc_kmem_pages_node+0x4c/0xc0
[  154.868726] zone=DMA32 reclaimable=309003 available=312677 no_progress_loops=0 did_some_progress=48
[  154.868727] zone=DMA reclaimable=2 available=1728 no_progress_loops=0 did_some_progress=48
// and also here, if we didn't serialize the oom killer //

I think that would help in fixing the issue you reported.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
