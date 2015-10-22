Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 609FB6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 07:37:45 -0400 (EDT)
Received: by oiad129 with SMTP id d129so45673057oia.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 04:37:45 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id dy6si5371166oeb.54.2015.10.22.04.37.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 Oct 2015 04:37:44 -0700 (PDT)
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable() checks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org>
	<20151021143337.GD8805@dhcp22.suse.cz>
	<alpine.DEB.2.20.1510210948460.6898@east.gentwo.org>
	<20151021145505.GE8805@dhcp22.suse.cz>
	<alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
Message-Id: <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
Date: Thu, 22 Oct 2015 20:37:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Christoph Lameter wrote:
> On Wed, 21 Oct 2015, Michal Hocko wrote:
> 
> > I am not sure how to achieve that. Requiring non-sleeping worker would
> > work out but do we have enough users to add such an API?
> >
> > I would rather see vmstat using dedicated kernel thread(s) for this this
> > purpose. We have discussed that in the past but it hasn't led anywhere.
> 
> How about this one? I really would like to have the vm statistics work as
> designed and apparently they no longer work right with the existing
> workqueue mechanism.

No, it won't help. Adding a dedicated workqueue for vmstat_update job
merely moves that job from "events" to "vmstat" workqueue. The "vmstat"
workqueue after all appears in the list of busy workqueues.

The problem is that all workqueues are assigned the same CPU (cpus=2 in
below example tested on a 4 CPUs VM) and therefore only one job is
in-flight state. All other jobs are waiting for the in-flight job to
complete in the pending list while the in-flight job is blocked at memory
allocation.

The problem would be that the "struct task_struct" to execute vmstat_update
job does not exist, and will not be able to create one on demand because we
are stuck at __GFP_WAIT allocation. Therefore adding a dedicated kernel
thread for vmstat_update job would work. But ...

------------------------------------------------------------
[  133.132322] Showing busy workqueues and worker pools:
[  133.133878] workqueue events: flags=0x0
[  133.135215]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  133.137076]     pending: vmpressure_work_fn, vmw_fb_dirty_flush [vmwgfx]
[  133.139075] workqueue events_freezable_power_: flags=0x84
[  133.140745]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  133.142638]     in-flight: 20:disk_events_workfn
[  133.144199]     pending: disk_events_workfn
[  133.145699] workqueue vmstat: flags=0xc
[  133.147055]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  133.148910]     pending: vmstat_update
[  133.150354] pool 4: cpus=2 node=0 flags=0x0 nice=0 workers=4 idle: 43 189 183
[  133.174523] DMA32 zone_reclaimable: reclaim:2(30186,30162,2) free:11163(25154,-20) min:11163 pages_scanned:0(30158,0) prio:12
[  133.177264] DMA32 zone_reclaimable: reclaim:2(30189,30165,2) free:11163(25157,-20) min:11163 pages_scanned:0(30161,0) prio:11
[  133.180139] DMA32 zone_reclaimable: reclaim:2(30191,30167,2) free:11163(25159,-20) min:11163 pages_scanned:0(30163,0) prio:10
[  133.182847] DMA32 zone_reclaimable: reclaim:2(30194,30170,2) free:11163(25162,-20) min:11163 pages_scanned:0(30166,0) prio:9
[  133.207048] DMA32 zone_reclaimable: reclaim:2(30219,30195,2) free:11163(25187,-20) min:11163 pages_scanned:0(30191,0) prio:8
[  133.209770] DMA32 zone_reclaimable: reclaim:2(30221,30197,2) free:11163(25189,-20) min:11163 pages_scanned:0(30193,0) prio:7
[  133.212470] DMA32 zone_reclaimable: reclaim:2(30224,30200,2) free:11163(25192,-20) min:11163 pages_scanned:0(30196,0) prio:6
[  133.215149] DMA32 zone_reclaimable: reclaim:2(30227,30203,2) free:11163(25195,-20) min:11163 pages_scanned:0(30199,0) prio:5
[  133.239013] DMA32 zone_reclaimable: reclaim:2(30251,30227,2) free:11163(25219,-20) min:11163 pages_scanned:0(30223,0) prio:4
[  133.241688] DMA32 zone_reclaimable: reclaim:2(30253,30229,2) free:11163(25221,-20) min:11163 pages_scanned:0(30225,0) prio:3
[  133.244332] DMA32 zone_reclaimable: reclaim:2(30256,30232,2) free:11163(25224,-20) min:11163 pages_scanned:0(30228,0) prio:2
[  133.246919] DMA32 zone_reclaimable: reclaim:2(30258,30234,2) free:11163(25226,-20) min:11163 pages_scanned:0(30230,0) prio:1
[  133.270967] DMA32 zone_reclaimable: reclaim:2(30283,30259,2) free:11163(25251,-20) min:11163 pages_scanned:0(30255,0) prio:0
[  133.273587] DMA32 zone_reclaimable: reclaim:2(30285,30261,2) free:11163(25253,-20) min:11163 pages_scanned:0(30257,0) prio:12
[  133.276224] DMA32 zone_reclaimable: reclaim:2(30287,30263,2) free:11163(25255,-20) min:11163 pages_scanned:0(30259,0) prio:11
[  133.278852] DMA32 zone_reclaimable: reclaim:2(30290,30266,2) free:11163(25258,-20) min:11163 pages_scanned:0(30262,0) prio:10
[  133.302964] DMA32 zone_reclaimable: reclaim:2(30315,30291,2) free:11163(25283,-20) min:11163 pages_scanned:0(30287,0) prio:9
[  133.305518] DMA32 zone_reclaimable: reclaim:2(30317,30293,2) free:11163(25285,-20) min:11163 pages_scanned:0(30289,0) prio:8
[  133.308095] DMA32 zone_reclaimable: reclaim:2(30319,30295,2) free:11163(25287,-20) min:11163 pages_scanned:0(30291,0) prio:7
[  133.310683] DMA32 zone_reclaimable: reclaim:2(30322,30298,2) free:11163(25290,-20) min:11163 pages_scanned:0(30294,0) prio:6
[  133.334904] DMA32 zone_reclaimable: reclaim:2(30347,30323,2) free:11163(25315,-20) min:11163 pages_scanned:0(30319,0) prio:5
[  133.337590] DMA32 zone_reclaimable: reclaim:2(30349,30325,2) free:11163(25317,-20) min:11163 pages_scanned:0(30321,0) prio:4
[  133.340147] DMA32 zone_reclaimable: reclaim:2(30351,30327,2) free:11163(25319,-20) min:11163 pages_scanned:0(30323,0) prio:3
[  133.343436] DMA32 zone_reclaimable: reclaim:2(30355,30331,2) free:11163(25323,-20) min:11163 pages_scanned:0(30327,0) prio:2
[  133.367531] DMA32 zone_reclaimable: reclaim:2(30379,30355,2) free:11163(25347,-20) min:11163 pages_scanned:0(30351,0) prio:1
[  133.370261] DMA32 zone_reclaimable: reclaim:2(30382,30358,2) free:11163(25350,-20) min:11163 pages_scanned:0(30354,0) prio:0
[  133.372786] did_some_progress=1 at line 3380
[  143.153205] MemAlloc-Info: 10 stalling task, 0 dying task, 0 victim task.
[  143.154981] MemAlloc: a.out(11052) gfp=0x24280ca order=0 delay=40104
[  143.156698] MemAlloc: abrt-watch-log(1708) gfp=0x242014a order=0 delay=39655
[  143.158527] MemAlloc: kworker/2:0(20) gfp=0x2400000 order=0 delay=39627
[  143.160247] MemAlloc: tuned(2076) gfp=0x242014a order=0 delay=39625
[  143.161920] MemAlloc: rngd(1703) gfp=0x242014a order=0 delay=38870
[  143.163618] MemAlloc: systemd-journal(471) gfp=0x242014a order=0 delay=38135
[  143.165435] MemAlloc: crond(1720) gfp=0x242014a order=0 delay=36330
[  143.167095] MemAlloc: vmtoolsd(1900) gfp=0x242014a order=0 delay=36136
[  143.168936] MemAlloc: irqbalance(1702) gfp=0x242014a order=0 delay=31584
[  143.170656] MemAlloc: nmbd(4791) gfp=0x242014a order=0 delay=30483
[  143.213896] Showing busy workqueues and worker pools:
[  143.215429] workqueue events: flags=0x0
[  143.216763]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=3/256
[  143.218542]     pending: vmpressure_work_fn, vmw_fb_dirty_flush [vmwgfx], console_callback
[  143.220785] workqueue events_freezable_power_: flags=0x84
[  143.222438]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  143.224239]     in-flight: 20:disk_events_workfn
[  143.225644]     pending: disk_events_workfn
[  143.227032] workqueue vmstat: flags=0xc
[  143.228303]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  143.229996]     pending: vmstat_update
[  143.231396] pool 4: cpus=2 node=0 flags=0x0 nice=0 workers=4 idle: 43 189 183
[  144.023799] sysrq: SysRq : Kill All Tasks
------------------------------------------------------------

do we need to use a dedicated kernel thread for vmstat_update job?
It seems to me that refresh_cpu_vm_stats() will not sleep if we remove
cond_resched(). If vmstat_update job does not need to sleep, why can't
we do that job from timer interrupts? We have add_timer_on() which the
workqueue is also using.

Moreover, do we need to use atomic_long_t counters from the beginning?
Can't we do something like

 (1) Each CPU updates its own per CPU counter ("struct per_cpu_pageset"
     ->vm_stat_diff[] ?).
 (2) Only one thread periodically reads snapshot of all per CPU counters
     and adds diff values between the latest snapshot and previous snapshot
     to global counters ("struct zone"->vm_stat[] ?), and save the latest
     snapshot as previous snapshot.
 (3) Anyone can read global counters at any time.

which would not use atomic operations at all because only one task updates
global counters while each CPU continues using per CPU counters.



Linus Torvalds wrote (off-list due to mobile post):
> Side note: it would probably be interesting to see exactly *what*
> allocation ends up screwing up using just a regular workqueue. I bet
> there are lots of other workqueue users where timelineness can be a
> big deal - they continue to work, but perhaps they cause bad
> performance if there are allocators in other workqueues that end up
> delaying them.

We might want to favor kernel threads and dying threads over normal threads.
It helps reducing TIF_MEMDIE stalls if the dependency is limited to tasks
sharing the same memory.
http://lkml.kernel.org/r/201509102318.GHG18789.OHMSLFJOQFOtFV@I-love.SAKURA.ne.jp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
