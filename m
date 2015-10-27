Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 110E682F65
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 07:07:59 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so229661306pac.3
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 04:07:58 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id gt3si61107226pac.35.2015.10.27.04.07.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Oct 2015 04:07:56 -0700 (PDT)
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()checks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20151023083316.GB2410@dhcp22.suse.cz>
	<20151023103630.GA4170@mtj.duckdns.org>
	<20151023111145.GH2410@dhcp22.suse.cz>
	<20151023182109.GA14610@mtj.duckdns.org>
	<20151027091603.GB9891@dhcp22.suse.cz>
In-Reply-To: <20151027091603.GB9891@dhcp22.suse.cz>
Message-Id: <201510272007.HHI18717.MOOtJQHSVFOLFF@I-love.SAKURA.ne.jp>
Date: Tue, 27 Oct 2015 20:07:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, htejun@gmail.com
Cc: cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Michal Hocko wrote:
> > On Fri, Oct 23, 2015 at 01:11:45PM +0200, Michal Hocko wrote:
> > > > The problem here is not lack
> > > > of execution resource but concurrency management misunderstanding the
> > > > situation. 
> > > 
> > > And this sounds like a bug to me.
> > 
> > I don't know.  I can be argued either way, the other direction being a
> > kernel thread going RUNNING non-stop is buggy.  Given how this has
> > been a complete non-issue for all the years, I'm not sure how useful
> > plugging this is.
> 
> Well, I guess we haven't noticed because this is a pathological case. It
> also triggers OOM livelocks which were not reported in the past either.
> You do not reach this state normally unless you rely _want_ to kill your
> machine

I don't think we can say this is a pathological case. Customers' serves
might have hit this state. We have no code for warning this state.

> 
> And vmstat is not the only instance. E.g. sysrq oom trigger is known
> to stay behind in similar cases. It should be changed to a dedicated
> WQ_MEM_RECLAIM wq and it would require runnable item guarantee as well.
> 

Well, this seems to be the cause of SysRq-f being unresponsive...
http://lkml.kernel.org/r/201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp

Picking up from http://lkml.kernel.org/r/201506112212.JAG26531.FLSVFMOQJOtOHF@I-love.SAKURA.ne.jp
----------
[  515.536393] Showing busy workqueues and worker pools:
[  515.538185] workqueue events: flags=0x0
[  515.539758]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=8/256
[  515.541872]     pending: vmpressure_work_fn, console_callback, vmstat_update, flush_to_ldisc, push_to_pool, moom_callback, sysrq_reinject_alt_sysrq, fb_deferred_io_work
[  515.546684] workqueue events_power_efficient: flags=0x80
[  515.548589]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=2/256
[  515.550829]     pending: neigh_periodic_work, check_lifetime
[  515.552884] workqueue events_freezable_power_: flags=0x84
[  515.554742]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  515.556846]     in-flight: 3837:disk_events_workfn
[  515.558665] workqueue writeback: flags=0x4e
[  515.560291]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[  515.562271]     in-flight: 3812:bdi_writeback_workfn bdi_writeback_workfn
[  515.564544] workqueue xfs-data/sda1: flags=0xc
[  515.566265]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  515.568359]     in-flight: 374(RESCUER):xfs_end_io, 3759:xfs_end_io, 26:xfs_end_io, 3836:xfs_end_io
[  515.571018]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  515.573113]     in-flight: 179:xfs_end_io
[  515.574782] pool 2: cpus=1 node=0 flags=0x0 nice=0 workers=4 idle: 3790 237 3820
[  515.577230] pool 6: cpus=3 node=0 flags=0x0 nice=0 workers=5 manager: 219
[  515.579488] pool 16: cpus=0-7 flags=0x4 nice=0 workers=3 idle: 356 357
----------
We want immediate execution guarantee for not only vmstat_update and
moom_callback but also vmstat_shepherd and console_callback?

> > > Don't we have some IO related paths which would suffer from the same
> > > problem. I haven't checked all the WQ_MEM_RECLAIM users but from the
> > > name I would expect they _do_ participate in the reclaim and so they
> > > should be able to make a progress. Now if your new IMMEDIATE flag will
> > 
> > Seriously, nobody goes full-on RUNNING.
> 
> Looping with cond_resched seems like general pattern in the kernel when
> there is no clear source to wait for. We have io_schedule when we know
> we should wait for IO (in case of congestion) but this is not necessarily
> the case - as you can see here. What should we wait for? A short nap
> without actually waiting on anything sounds like a dirty workaround to
> me.

Can't we have a waitqueue like
http://lkml.kernel.org/r/201510142121.IDE86954.SOVOFFQOFMJHtL@I-love.SAKURA.ne.jp ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
