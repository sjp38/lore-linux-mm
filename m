Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id BFD6C82F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 07:57:46 -0400 (EDT)
Received: by oiad129 with SMTP id d129so2702110oia.0
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 04:57:46 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o133si27219273oih.25.2015.10.28.04.57.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 Oct 2015 04:57:45 -0700 (PDT)
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20151028024114.370693277@linux.com>
	<20151028024131.719968999@linux.com>
	<20151028024350.GA10448@mtj.duckdns.org>
	<alpine.DEB.2.20.1510272202120.4647@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.20.1510272202120.4647@east.gentwo.org>
Message-Id: <201510282057.JHI87536.OMOFFFLJOHQtVS@I-love.SAKURA.ne.jp>
Date: Wed, 28 Oct 2015 20:57:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, htejun@gmail.com
Cc: akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

Christoph Lameter wrote:
> On Wed, 28 Oct 2015, Tejun Heo wrote:
> 
> > The only thing necessary here is WQ_MEM_RECLAIM.  I don't see how
> > WQ_SYSFS and WQ_FREEZABLE make sense here.
> 
I can still trigger silent livelock with this patchset applied.

----------
[  272.283217] MemAlloc-Info: 9 stalling task, 0 dying task, 0 victim task.
[  272.285089] MemAlloc: a.out(11325) gfp=0x24280ca order=0 delay=19164
[  272.286817] MemAlloc: a.out(11326) gfp=0x242014a order=0 delay=19104
[  272.288512] MemAlloc: vmtoolsd(1897) gfp=0x242014a order=0 delay=19072
[  272.290280] MemAlloc: kworker/1:3(11286) gfp=0x2400000 order=0 delay=19056
[  272.292114] MemAlloc: sshd(11202) gfp=0x242014a order=0 delay=18927
[  272.293908] MemAlloc: tuned(2073) gfp=0x242014a order=0 delay=18799
[  272.297360] MemAlloc: nmbd(4752) gfp=0x242014a order=0 delay=16532
[  272.299115] MemAlloc: auditd(529) gfp=0x242014a order=0 delay=13073
[  272.302248] MemAlloc: irqbalance(1696) gfp=0x242014a order=0 delay=10529
(...snipped...)
[  272.851035] Showing busy workqueues and worker pools:
[  272.852583] workqueue events: flags=0x0
[  272.853942]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  272.855781]     pending: vmw_fb_dirty_flush [vmwgfx]
[  272.857500]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  272.859359]     pending: vmpressure_work_fn
[  272.860840] workqueue events_freezable_power_: flags=0x84
[  272.862461]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  272.864479]     in-flight: 11286:disk_events_workfn
[  272.866065]     pending: disk_events_workfn
[  272.867587] workqueue vmstat: flags=0x8
[  272.868942]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  272.870785]     pending: vmstat_update
[  272.872248] pool 2: cpus=1 node=0 flags=0x0 nice=0 workers=4 idle: 14 218 43
----------

> 2. Create a separate workqueue so that the vmstat updater
>    is not blocked by other work requeusts. This creates a
>    new kernel thread <sigh> and avoids the issue of
>    differentials not folded in a timely fashion.

Did you really mean "the vmstat updater is not blocked by other
work requeusts"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
