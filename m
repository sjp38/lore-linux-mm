Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7E16B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 15:26:25 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k135so80557383lfb.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 12:26:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v7si32817260wjm.289.2016.08.01.12.26.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 12:26:23 -0700 (PDT)
Date: Mon, 1 Aug 2016 21:26:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160801192620.GD31957@dhcp22.suse.cz>
References: <d8f3adcc-3607-1ef6-9ec5-82b2e125eef2@quantum.com>
 <20160801061625.GA11623@dhcp22.suse.cz>
 <b1a39756-a0b5-1900-6575-d6e1f502cb26@Quantum.com>
 <20160801182358.GB31957@dhcp22.suse.cz>
 <30dbabc4-585c-55a5-9f3a-4e243c28356a@Quantum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <30dbabc4-585c-55a5-9f3a-4e243c28356a@Quantum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

[re-adding linux-mm mailing list - please always use reply-to-all
 also CCing Vlastimil who can help with the compaction debugging]

On Mon 01-08-16 11:48:53, Ralf-Peter Rohbeck wrote:
> See the messages log attached. It has several OOM killer entries.
> Let me know if there's anything else I can do. I'll try the disk erasing on
> 4.6 and on 4.7.

Jul 31 17:17:05 fs kernel: [11918.534744] x2golistsession invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[...]
Jul 31 17:17:05 fs kernel: [11918.557356] Mem-Info:
Jul 31 17:17:05 fs kernel: [11918.558268] active_anon:7856 inactive_anon:21924 isolated_anon:0
Jul 31 17:17:05 fs kernel: [11918.558268]  active_file:70925 inactive_file:1796707 isolated_file:0
Jul 31 17:17:05 fs kernel: [11918.558268]  unevictable:0 dirty:277675 writeback:57117 unstable:0
Jul 31 17:17:05 fs kernel: [11918.558268]  slab_reclaimable:75821 slab_unreclaimable:9490
Jul 31 17:17:05 fs kernel: [11918.558268]  mapped:12014 shmem:2414 pagetables:1497 bounce:0
Jul 31 17:17:05 fs kernel: [11918.558268]  free:37021 free_pcp:89 free_cma:0
[...]
Jul 31 17:17:05 fs kernel: [11918.578836] Node 0 DMA32: 2137*4kB (UME) 5043*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 48892kB
Jul 31 17:17:05 fs kernel: [11918.580370] Node 0 Normal: 2663*4kB (UME) 7452*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 70268kB

The above process is trying to allocate the kernel stack which is
order-2 (16kB) of physically contiguous memory which is clearly
not available as you can see. Memory compaction (assuming you have
CONFIG_COMPACTION enabled) which is a part of the oom reclaim process
should help to form such blocks but those retries are bound and if
there is not much hope left we eventually hit the OOM killer. If you
look at the above counters there is a lot of memory dirty and under the
writeback (1.3G), this suggests that the IO is quite slow wrt. writers.
Anyway there is a lot of anonymous memory which should be a good
candidate for compaction.

But the IO doesn't seem to be the main factor I guess. Later OOM
invocations have a slightly different pattern (let's take the last one):

Aug  1 06:30:45 fs kernel: [59536.957034] x2golistsession invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[...]
Aug  1 06:30:45 fs kernel: [59536.976467] Mem-Info:
Aug  1 06:30:45 fs kernel: [59536.977442] active_anon:16045 inactive_anon:20473 isolated_anon:0
Aug  1 06:30:45 fs kernel: [59536.977442]  active_file:169767 inactive_file:1727008 isolated_file:0
Aug  1 06:30:45 fs kernel: [59536.977442]  unevictable:0 dirty:32734 writeback:0 unstable:0
Aug  1 06:30:45 fs kernel: [59536.977442]  slab_reclaimable:41953 slab_unreclaimable:7507
Aug  1 06:30:45 fs kernel: [59536.977442]  mapped:10619 shmem:2443 pagetables:1971 bounce:0
Aug  1 06:30:45 fs kernel: [59536.977442]  free:36686 free_pcp:119 free_cma:0
[...]
Aug  1 06:30:45 fs kernel: [59536.996407] Node 0 DMA32: 5909*4kB (UME) 3800*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 54036kB
Aug  1 06:30:45 fs kernel: [59536.997846] Node 0 Normal: 4041*4kB (UME) 6799*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 70556kB

the amount of dirty pages is much smaller as well as the anonymous
memory. The biggest portion seems to be in the page cache. The memory
is till hugely fragmented though. In fact if we check all the OOM
invocations the only consistent thing is that the memory is fragmented
and the compaction cannot make sufficient progress consistently. We can
assume that the situation actually gets better because there are some
holes between those OOMs so we can assume that something has unpinned a
larger amount memory and allowed the compaction to make further progress
or that the load has strong peaks. We would need more information from
the compaction to know better. Vlastimil will surely tell you which
tracepoints to enable.

Jul 31 17:17:05 fs kernel: [11918.578836] Node 0 DMA32: 2137*4kB (UME) 5043*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 48892kB
Jul 31 17:17:05 fs kernel: [11918.580370] Node 0 Normal: 2663*4kB (UME) 7452*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 70268kB
Jul 31 20:17:51 fs kernel: [22764.494449] Node 0 DMA32: 2568*4kB (UME) 5472*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 54048kB
Jul 31 20:17:51 fs kernel: [22764.495510] Node 0 Normal: 6109*4kB (UME) 6651*8kB (UM) 1*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 77660kB
Jul 31 20:57:18 fs kernel: [25131.260737] Node 0 DMA32: 2139*4kB (UME) 5114*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 49468kB
Jul 31 20:57:18 fs kernel: [25131.262060] Node 0 Normal: 3611*4kB (UME) 7312*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 72940kB
Jul 31 23:36:25 fs kernel: [34677.849133] Node 0 DMA32: 10276*4kB (UME) 3565*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 69624kB
Jul 31 23:36:25 fs kernel: [34677.850547] Node 0 Normal: 19080*4kB (UE) 1361*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 87208kB
Jul 31 23:36:35 fs kernel: [34688.300852] Node 0 DMA32: 2291*4kB (UME) 5208*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 50828kB
Jul 31 23:36:35 fs kernel: [34688.301959] Node 0 Normal: 5519*4kB (UME) 7338*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 80780kB
Jul 31 23:36:40 fs kernel: [34692.902932] Node 0 DMA32: 3163*4kB (UE) 4566*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 49180kB
Jul 31 23:36:40 fs kernel: [34692.904897] Node 0 Normal: 5833*4kB (UE) 6387*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 74428kB
Jul 31 23:36:47 fs kernel: [34699.517079] Node 0 DMA32: 3068*4kB (UME) 4889*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 51384kB
Jul 31 23:36:47 fs kernel: [34699.518537] Node 0 Normal: 5935*4kB (UME) 7324*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 82332kB
Jul 31 23:36:50 fs kernel: [34702.755342] Node 0 DMA32: 4975*4kB (UME) 4500*8kB (UM) 3*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 55948kB
Jul 31 23:36:50 fs kernel: [34702.757018] Node 0 Normal: 7171*4kB (UE) 6047*8kB (U) 1*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 77076kB
Jul 31 23:39:39 fs kernel: [34871.854243] Node 0 DMA32: 14269*4kB (UME) 1547*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 69452kB
Jul 31 23:39:39 fs kernel: [34871.855525] Node 0 Normal: 19081*4kB (UME) 28*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 76548kB
Jul 31 23:39:44 fs kernel: [34876.491809] Node 0 DMA32: 11368*4kB (UME) 4265*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 79592kB
Jul 31 23:39:44 fs kernel: [34876.493233] Node 0 Normal: 20088*4kB (UME) 236*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 82240kB
Jul 31 23:39:53 fs kernel: [34885.459361] Node 0 DMA32: 13302*4kB (UME) 2180*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 70648kB
Jul 31 23:39:53 fs kernel: [34885.461011] Node 0 Normal: 18393*4kB (UE) 512*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 77668kB
Jul 31 23:39:55 fs kernel: [34887.848712] Node 0 DMA32: 14180*4kB (UE) 1690*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 70240kB
Jul 31 23:39:55 fs kernel: [34887.850194] Node 0 Normal: 19598*4kB (UM) 21*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 78560kB
Aug  1 06:30:42 fs kernel: [59534.373842] Node 0 DMA32: 4458*4kB (UME) 4252*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 51848kB
Aug  1 06:30:42 fs kernel: [59534.375266] Node 0 Normal: 2265*4kB (U) 7168*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 66404kB
Aug  1 06:30:45 fs kernel: [59536.996407] Node 0 DMA32: 5909*4kB (UME) 3800*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 54036kB
Aug  1 06:30:45 fs kernel: [59536.997846] Node 0 Normal: 4041*4kB (UME) 6799*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 70556kB
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
