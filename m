Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A56DA6B0387
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 18:15:13 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id c18so10753711ioj.3
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 15:15:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j194si1204755ioe.282.2017.08.28.15.15.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Aug 2017 15:15:12 -0700 (PDT)
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1503921210-4603-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170828121055.GI17097@dhcp22.suse.cz>
	<20170828170611.GV491396@devbig577.frc2.facebook.com>
In-Reply-To: <20170828170611.GV491396@devbig577.frc2.facebook.com>
Message-Id: <201708290715.FEI21383.HSFOQtJOMVOFFL@I-love.SAKURA.ne.jp>
Date: Tue, 29 Aug 2017 07:15:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Tejun Heo wrote:
> On Mon, Aug 28, 2017 at 02:10:56PM +0200, Michal Hocko wrote:
> > I am not sure I understand how WQ_HIGHPRI actually helps. The work item
> > will get served by a thread with higher priority and from a different
> > pool than regular WQs. But what prevents the same issue as described
> > above when the highprio pool gets congested? In other words what make
> > WQ_HIGHPRI less prone to long stalls when we are under low memory
> > situation and new workers cannot be allocated?
> 
> So, the problem wasn't new worker not getting allocated due to memory
> pressure.  Rescuer can handle that.  The problem is that the regular
> worker pool is occupied with something which is constantly in runnable
> state - most likely writeback / reclaim, so the workqueue doesn't
> schedule the other work items.
> 
> Setting WQ_HIGHPRI works as highpri worker pool isn't likely to be
> contended that way but might not be the best solution.  The right
> thing to do would be setting WQ_CPU_INTENSIVE on the work items which
> can burn a lot of CPU cycles so that it doesn't get in the way of
> other work items (workqueue should probably trigger a warning on these
> work items too).
> 
> Tetuso, can you please try to find which work items are occupying the
> worker pool for an extended period time under memory pressure and set
> WQ_CPU_INTENSIVE on them?
> 

Isn't it any work item which does __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory
allocation, for doing __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation
burns a lot of CPU cycles under memory pressure? In other words, won't we end up
with setting WQ_CPU_INTENSIVE to almost all workqueues?

----------
[  605.720125] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 208s!
[  605.736025] BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 209s!
[  605.746669] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 209s!
[  605.755091] BUG: workqueue lockup - pool cpus=3 node=0 flags=0x0 nice=0 stuck for 64s!
[  605.763390] Showing busy workqueues and worker pools:
[  605.769436] workqueue events: flags=0x0
[  605.772204]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  605.775548]     pending: console_callback{197431}, vmw_fb_dirty_flush [vmwgfx]{174896}, sysrq_reinject_alt_sysrq{174440}, push_to_pool{162245}
[  605.780761]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=3/256
[  605.783603]     pending: e1000_watchdog [e1000]{207984}, check_corruption{166511}, rht_deferred_worker{28894}
[  605.787725]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  605.790682]     pending: vmpressure_work_fn{209065}, e1000_watchdog [e1000]{207615}
[  605.794271]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  605.797150]     pending: vmstat_shepherd{208067}
[  605.799610] workqueue events_long: flags=0x0
[  605.801951]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  605.805098]     pending: gc_worker [nf_conntrack]{208961}
[  605.807976] workqueue events_freezable: flags=0x4
[  605.810391]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  605.813151]     pending: vmballoon_work [vmw_balloon]{208085}
[  605.815851] workqueue events_power_efficient: flags=0x80
[  605.818382]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  605.821124]     pending: check_lifetime{64453}
[  605.823337]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  605.826091]     pending: neigh_periodic_work{199329}
[  605.828426]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  605.831068]     pending: fb_flashcursor{209042}, do_cache_clean{201882}
[  605.833902]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  605.836545]     pending: neigh_periodic_work{195234}
[  605.838838] workqueue events_freezable_power_: flags=0x84
[  605.841295]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  605.843824]     pending: disk_events_workfn{208625}
[  605.846084] workqueue mm_percpu_wq: flags=0x8
[  605.848145]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  605.850667]     pending: drain_local_pages_wq{209047} BAR(4561){209047}
[  605.853368] workqueue writeback: flags=0x4e
[  605.855382]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=1/256
[  605.857793]     in-flight: 354:wb_workfn{182977}
[  605.860182] workqueue xfs-data/sda1: flags=0xc
[  605.862314]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=23/256 MAYDAY
[  605.865010]     in-flight: 3221:xfs_end_io [xfs]{209041}, 3212:xfs_end_io [xfs]{209158}, 29:xfs_end_io [xfs]{209200}, 3230:xfs_end_io [xfs]{209171}, 3229:xfs_end_io [xfs]{209099}, 50:xfs_end_io [xfs]{209099}, 3223:xfs_end_io [xfs]{209045}, 165:xfs_end_io [xfs]{209052}, 3215:xfs_end_io [xfs]{209046}
[  605.874362]     pending: xfs_end_io [xfs]{209011}, xfs_end_io [xfs]{209007}, xfs_end_io [xfs]{209007}, xfs_end_io [xfs]{208999}, xfs_end_io [xfs]{208977}, xfs_end_io [xfs]{208975}, xfs_end_io [xfs]{208970}, xfs_end_io [xfs]{208963}, xfs_end_io [xfs]{208963}, xfs_end_io [xfs]{208950}, xfs_end_io [xfs]{208948}, xfs_end_io [xfs]{208948}, xfs_end_io [xfs]{208946}, xfs_end_io [xfs]{30655}
[  605.886882]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=28/256 MAYDAY
[  605.889661]     in-flight: 3225:xfs_end_io [xfs]{209249}, 236:xfs_end_io [xfs]{209163}, 23:xfs_end_io [xfs]{209151}, 3228:xfs_end_io [xfs]{209151}, 4380:xfs_end_io [xfs]{209259}, 3214:xfs_end_io [xfs]{209240}, 3220:xfs_end_io [xfs]{209212}, 3227:xfs_end_io [xfs]{209233}
[  605.898706]     pending: xfs_end_io [xfs]{209159}, xfs_end_io [xfs]{209149}, xfs_end_io [xfs]{209128}, xfs_end_io [xfs]{209128}, xfs_end_io [xfs]{209128}, xfs_end_io [xfs]{209128}, xfs_end_io [xfs]{209128}, xfs_end_io [xfs]{209116}, xfs_end_io [xfs]{209110}, xfs_end_io [xfs]{209096}, xfs_end_io [xfs]{209096}, xfs_end_io [xfs]{209092}, xfs_end_io [xfs]{209082}, xfs_end_io [xfs]{209061}, xfs_end_io [xfs]{209058}, xfs_end_io [xfs]{209051}, xfs_end_io [xfs]{209040}, xfs_end_io [xfs]{209021}, xfs_end_io [xfs]{209014}, xfs_end_io [xfs]{30678}
[  605.917299]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=24/256 MAYDAY
[  605.920254]     in-flight: 375(RESCUER):xfs_end_io [xfs]{209194}, 42:xfs_end_io [xfs]{209278}, 3222:xfs_end_io [xfs]{209286}, 17:xfs_end_io [xfs]{209195}, 65:xfs_end_io [xfs]{209241}, 122:xfs_end_io [xfs]{209230}
[  605.927845]     pending: xfs_end_io [xfs]{209187}, xfs_end_io [xfs]{209154}, xfs_end_io [xfs]{209113}, xfs_end_io [xfs]{209088}, xfs_end_io [xfs]{209081}, xfs_end_io [xfs]{209071}, xfs_end_io [xfs]{209070}, xfs_end_io [xfs]{209067}, xfs_end_io [xfs]{209062}, xfs_end_io [xfs]{209053}, xfs_end_io [xfs]{209051}, xfs_end_io [xfs]{209047}, xfs_end_io [xfs]{209032}, xfs_end_io [xfs]{209027}, xfs_end_io [xfs]{209017}, xfs_end_io [xfs]{209016}, xfs_end_io [xfs]{209014}, xfs_end_io [xfs]{209011}
[  605.944773]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=13/256
[  605.947616]     in-flight: 3218:xfs_end_io [xfs]{209268}, 3216:xfs_end_io [xfs]{209265}, 3:xfs_end_io [xfs]{209223}, 33:xfs_end_io [xfs]{209181}, 101:xfs_end_io [xfs]{209159}, 4381:xfs_end_io [xfs]{209294}, 3219:xfs_end_io [xfs]{209181}
[  605.956005]     pending: xfs_end_io [xfs]{209149}, xfs_end_io [xfs]{209141}, xfs_end_io [xfs]{209133}, xfs_end_io [xfs]{209057}, xfs_end_io [xfs]{209026}, xfs_end_io [xfs]{209025}
[  605.963018] workqueue xfs-sync/sda1: flags=0x4
[  605.965455]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  605.968299]     pending: xfs_log_worker [xfs]{202031}
[  605.970872] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=209s workers=8 manager: 3224
[  605.974252] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=209s workers=6 manager: 3213
[  605.977682] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=209s workers=9 manager: 47
[  605.981015] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=64s workers=10 manager: 3217
[  605.984382] pool 128: cpus=0-63 flags=0x4 nice=0 hung=183s workers=3 idle: 355 356
----------

> > > If we do want to make
> > > sure that work items on mm_percpu_wq workqueue are executed without delays,
> > > we need to consider using kthread_workers instead of workqueue. (Or, maybe
> > > somehow we can share one kthread with constantly manipulating cpumask?)
> > 
> > Hmm, that doesn't sound like a bad idea to me. We already have a rescuer
> > thread that basically sits idle all the time so having a dedicated
> > kernel thread will not be more expensive wrt. resources. So I think this
> > is a more reasonable approach than playing with WQ_HIGHPRI which smells
> > like a quite obscure workaround than a real fix to me.
> 
> Well, there's one rescuer in the whole system and you'd need
> nr_online_cpus kthreads if you wanna avoid constant cacheline
> bouncing.

Excuse me, one rescuer kernel thread per each WQ_MEM_RECLAIM workqueue, doesn't it?

My thought is to stop using WQ_MEM_RECLAIM workqueue for mm_percpu_wq and use a
dedicated kernel thread like oom_reaper. Since the frequency of calling handler
function seems to be once per a second for each online CPU, I thought switching
cpumask for NR_CPUS times per a second is tolerable.

Or, yet another approach would be to use split counters

  Each CPU writes up-to-date values to per-CPU counters.
  The aggregator kernel thread reads up-to-date values from per-CPU counters,
  calculates diff between up-to-date values and previous values, saves up-to-date
  values as previous values, and reflects the diff to global counters.

if cost of reading per-CPU counters of online CPUs is smaller than cost of
switching cpumask for each online CPU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
