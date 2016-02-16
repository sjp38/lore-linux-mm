Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1A36B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 10:19:52 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id g62so157549419wme.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 07:19:52 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id t12si49468639wju.76.2016.02.16.07.19.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 07:19:50 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id g62so157548263wme.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 07:19:50 -0800 (PST)
Date: Tue, 16 Feb 2016 16:19:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160216151947.GA23437@dhcp22.suse.cz>
References: <20160204125700.GA14425@dhcp22.suse.cz>
 <201602042210.BCG18704.HOMFFJOStQFOLV@I-love.SAKURA.ne.jp>
 <20160204133905.GB14425@dhcp22.suse.cz>
 <201602071309.EJD59750.FOVMSFOOFHtJQL@I-love.SAKURA.ne.jp>
 <20160215200603.GA9223@dhcp22.suse.cz>
 <201602162210.DJH39596.OSHQFtFLFOMVOJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602162210.DJH39596.OSHQFtFLFOMVOJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 16-02-16 22:10:01, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sun 07-02-16 13:09:33, Tetsuo Handa wrote:
> > [...]
> > > FYI, I again hit unexpected OOM-killer during genxref on linux-4.5-rc2 source.
> > > I think current patchset is too fragile to merge.
> > > ----------------------------------------
> > > [ 3101.626995] smbd invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
> > > [ 3101.629148] smbd cpuset=/ mems_allowed=0
> > [...]
> > > [ 3101.705887] Node 0 DMA: 75*4kB (UME) 69*8kB (UME) 43*16kB (UM) 23*32kB (UME) 8*64kB (UM) 4*128kB (UME) 2*256kB (UM) 0*512kB 1*1024kB (U) 1*2048kB (M) 0*4096kB = 6884kB
> > > [ 3101.710581] Node 0 DMA32: 4513*4kB (UME) 15*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18172kB
> > 
> > How come this is an unexpected OOM? There is clearly no order-2+ page
> > available for the allocation request.
> 
> I used "unexpected" because there were only 35 userspace processes and
> genxref was the only process which did a lot of memory allocation
> (modulo kernel threads woken by file I/O) and most memory is reclaimable.

The memory is reclaimable but that doesn't mean that order-2 page block
will get formed even if all of it gets reclaimed. The memory is simply
too fragmented. That is why I think the OOM makes sense.

> > > > Something like the following:
> > > Yes, I do think we need something like it.
> > 
> > Was the patch applied?
> 
> No for above result.
> 
> A result with the patch (20160204142400.GC14425@dhcp22.suse.cz) applied on
> today's linux-next is shown below. It seems that protection is not enough.
> 
> ----------
> [  118.584571] fork invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[...]
> [  118.664704] Node 0 DMA: 83*4kB (ME) 51*8kB (UME) 9*16kB (UME) 2*32kB (UM) 1*64kB (M) 4*128kB (UME) 5*256kB (UME) 2*512kB (UM) 1*1024kB (E) 1*2048kB (M) 0*4096kB = 6900kB
> [  118.670166] Node 0 DMA32: 2327*4kB (ME) 621*8kB (M) 1*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 14292kB
[...]
> [  120.117093] fork invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[...]
> [  120.117238] Node 0 DMA: 46*4kB (UME) 82*8kB (ME) 37*16kB (UME) 13*32kB (M) 3*64kB (UM) 2*128kB (ME) 2*256kB (ME) 2*512kB (UM) 1*1024kB (E) 1*2048kB (M) 0*4096kB = 6904kB
> [  120.117242] Node 0 DMA32: 709*4kB (UME) 2374*8kB (UME) 0*16kB 10*32kB (E) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 22148kB
[...]
> [  126.034913] fork invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[...]
> [  126.035000] Node 0 DMA: 70*4kB (UME) 16*8kB (UME) 59*16kB (UME) 34*32kB (ME) 14*64kB (UME) 2*128kB (UE) 1*256kB (E) 2*512kB (M) 2*1024kB (ME) 0*2048kB 0*4096kB = 6920kB
> [  126.035005] Node 0 DMA32: 2372*4kB (UME) 290*8kB (UM) 3*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 11856kB

As you can see, in all cases we had order-2 requests and no order-2+
free blocks even after all the retries. I think the OOM is appropriate
at that time. We could have tried N+1 times but we have to draw a line
at some point of time. The reason why we do not have any high order
block available is a completely different question IMO. Maybe the
compaction just gets deferred and doesn't do anything. This would be
interesting to investigate further of course. Anyway my point is
that going OOM with the current fragmentation is simply the only choice.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
