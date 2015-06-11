Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id B78F36B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 09:12:52 -0400 (EDT)
Received: by oiha141 with SMTP id a141so3750553oih.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 06:12:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id mk10si435440obc.44.2015.06.11.06.12.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 06:12:50 -0700 (PDT)
Subject: Re: [RFC] panic_on_oom_timeout
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150609170310.GA8990@dhcp22.suse.cz>
	<201506102120.FEC87595.OQSJLOVtMFOHFF@I-love.SAKURA.ne.jp>
	<20150610142801.GD4501@dhcp22.suse.cz>
In-Reply-To: <20150610142801.GD4501@dhcp22.suse.cz>
Message-Id: <201506112212.JAG26531.FLSVFMOQJOtOHF@I-love.SAKURA.ne.jp>
Date: Thu, 11 Jun 2015 22:12:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > > The feature is implemented as a delayed work which is scheduled when
> > > the OOM condition is declared for the first time (oom_victims is still
> > > zero) in out_of_memory and it is canceled in exit_oom_victim after
> > > the oom_victims count drops down to zero. For this time period OOM
> > > killer cannot kill new tasks and it only allows exiting or killed
> > > tasks to access memory reserves (and increase oom_victims counter via
> > > mark_oom_victim) in order to make a progress so it is reasonable to
> > > consider the elevated oom_victims count as an ongoing OOM condition
> > 
> > By the way, what guarantees that the panic_on_oom_work is executed under
> > OOM condition?
> 
> Tejun would be much better to explain this but my understanding of the
> delayed workqueue code is that it doesn't depend on memory allocations.
> 

Thanks to Tejun's commit 3494fc30846d("workqueue: dump workqueues on
sysrq-t") for allowing us to confirm that moom_work is staying on the
"workqueue events: flags=0x0" (shown below).

> > The moom_work used by SysRq-f sometimes cannot be executed
> > because some work which is processed before the moom_work is processed is
> > stalled for unbounded amount of time due to looping inside the memory
> > allocator.
> 
> Wouldn't wq code pick up another worker thread to execute the work.
> There is also a rescuer thread as the last resort AFAIR.
> 

Below is an example of moom_work lockup in v4.1-rc7 from
http://I-love.SAKURA.ne.jp/tmp/serial-20150611.txt.xz

----------
[  171.710406] sysrq: SysRq : Manual OOM execution
[  171.720193] kworker/2:9 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
[  171.722699] kworker/2:9 cpuset=/ mems_allowed=0
[  171.724603] CPU: 2 PID: 11016 Comm: kworker/2:9 Not tainted 4.1.0-rc7 #3
[  171.726817] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  171.729727] Workqueue: events moom_callback
(...snipped...)
[  258.302016] sysrq: SysRq : Manual OOM execution
[  258.311360] kworker/2:9 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
[  258.313340] kworker/2:9 cpuset=/ mems_allowed=0
[  258.314809] CPU: 2 PID: 11016 Comm: kworker/2:9 Not tainted 4.1.0-rc7 #3
[  258.316579] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  258.319083] Workqueue: events moom_callback
(...snipped...)
[  301.362635] Showing busy workqueues and worker pools:
[  301.364421] workqueue events: flags=0x0
[  301.365988]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=4/256
[  301.368753]     pending: vmstat_shepherd, vmstat_update, fb_deferred_io_work, vmpressure_work_fn
[  301.371402]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[  301.373460]     pending: e1000_watchdog [e1000], vmstat_update, push_to_pool
[  301.375757] workqueue events_power_efficient: flags=0x80
[  301.377563]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  301.379625]     pending: fb_flashcursor
[  301.381236]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  301.383271]     pending: neigh_periodic_work
[  301.384951] workqueue events_freezable_power_: flags=0x84
[  301.386792]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  301.388880]     in-flight: 62:disk_events_workfn
[  301.390634] workqueue writeback: flags=0x4e
[  301.392200]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[  301.394137]     in-flight: 358:bdi_writeback_workfn bdi_writeback_workfn
[  301.396272] workqueue xfs-data/sda1: flags=0xc
[  301.397903]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=10/256
[  301.400013]     in-flight: 7733:xfs_end_io, 26:xfs_end_io, 7729:xfs_end_io, 2737:xfs_end_io, 7731:xfs_end_io, 423:xfs_end_io, 7734:xfs_end_io, 7732:xfs_end_io, 7735:xfs_end_io, 65:xfs_end_io
[  301.405064]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=8/256 MAYDAY
[  301.407320]     in-flight: 134:xfs_end_io, 10998:xfs_end_io, 11007:xfs_end_io, 20:xfs_end_io, 448:xfs_end_io, 11005:xfs_end_io, 232:xfs_end_io, 10997:xfs_end_io
[  301.411922]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=56/256 MAYDAY
[  301.414122]     in-flight: 10999:xfs_end_io, 11004:xfs_end_io, 11018:xfs_end_io, 11025:xfs_end_io, 11001:xfs_end_io, 11020:xfs_end_io, 7728:xfs_end_io, 7730:xfs_end_io, 11011:xfs_end_io, 215:xfs_end_io, 11023:xfs_end_io, 11003:xfs_end_io, 11024:xfs_end_io, 10995:xfs_end_io, 11000:xfs_end_io, 11017:xfs_end_io, 11010:xfs_end_io, 43:xfs_end_io, 11015:xfs_end_io, 11009:xfs_end_io, 10996:xfs_end_io, 14:xfs_end_io, 11026:xfs_end_io, 371(RESCUER):xfs_end_io xfs_end_io xfs_end_io, 11006:xfs_end_io, 11014:xfs_end_io, 11022:xfs_end_io, 11002:xfs_end_io, 11019:xfs_end_io, 11008:xfs_end_io, 11012:xfs_end_io, 11021:xfs_end_io
[  301.428743]     pending: xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io
[  301.436022] workqueue xfs-cil/sda1: flags=0xc
[  301.437850]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  301.440083]     pending: xlog_cil_push_work BAR(5327)
[  301.442106] workqueue xfs-log/sda1: flags=0x14
[  301.444250]   pwq 1: cpus=0 node=0 flags=0x0 nice=-20 active=1/256
[  301.446479]     in-flight: 5327:xfs_log_worker
[  301.448327] pool 0: cpus=0 node=0 flags=0x0 nice=0 workers=4 idle: 173 64 4
[  301.450865] pool 1: cpus=0 node=0 flags=0x0 nice=-20 workers=3 idle: 2016 5
[  301.453311] pool 2: cpus=1 node=0 flags=0x0 nice=0 workers=32 manager: 11027
[  301.455735] pool 4: cpus=2 node=0 flags=0x0 nice=0 workers=10 manager: 11013 idle: 11016
[  301.458373] pool 6: cpus=3 node=0 flags=0x0 nice=0 workers=13 idle: 7736 7738 7737
[  301.460919] pool 16: cpus=0-7 flags=0x4 nice=0 workers=32 idle: 357 356 355 354 353 352 351 350 349 348 347 346 345 344 343 342 341 340 339 338 337 336 335 334 263 269 264 60 6 360 359
[  417.532993] sysrq: SysRq : Manual OOM execution
[  437.388767] sysrq: SysRq : Manual OOM execution
[  455.257690] sysrq: SysRq : Manual OOM execution
[  458.381422] sysrq: SysRq : Manual OOM execution
[  463.411448] sysrq: SysRq : Show State
(...snipped...)
[  464.441490] kswapd0         D 0000000000000002     0    45      2 0x00000000
[  464.444050]  ffff88007cdecf50 ffffea0000118a00 ffff880078798000 ffff88007fc8eb00
[  464.446114]  ffff88007fc8eb00 0000000100027b48 ffff88007fac39a0 0000000000000017
[  464.448212]  ffffffff8161d37a ffff880078797a68 ffffffff8161fa83 0000000000000005
[  464.450265] Call Trace:
[  464.451304]  [<ffffffff8161d37a>] ? schedule+0x2a/0x80
[  464.452928]  [<ffffffff8161fa83>] ? schedule_timeout+0x113/0x1b0
[  464.454609]  [<ffffffff810c2b10>] ? migrate_timer_list+0x60/0x60
[  464.456297]  [<ffffffff8161ca89>] ? io_schedule_timeout+0x99/0x100
[  464.458031]  [<ffffffff8112df99>] ? congestion_wait+0x79/0xd0
[  464.459670]  [<ffffffff810a31c0>] ? wait_woken+0x80/0x80
[  464.461224]  [<ffffffff8112396b>] ? shrink_inactive_list+0x4bb/0x530
[  464.463011]  [<ffffffff811243a1>] ? shrink_lruvec+0x571/0x780
[  464.464636]  [<ffffffff811246a2>] ? shrink_zone+0xf2/0x300
[  464.466230]  [<ffffffff8112572d>] ? kswapd+0x50d/0x940
[  464.467752]  [<ffffffff81125220>] ? mem_cgroup_shrink_node_zone+0xd0/0xd0
[  464.469565]  [<ffffffff81084658>] ? kthread+0xc8/0xe0
[  464.471053]  [<ffffffff81084590>] ? kthread_create_on_node+0x190/0x190
[  464.472810]  [<ffffffff81620f62>] ? ret_from_fork+0x42/0x70
[  464.474395]  [<ffffffff81084590>] ? kthread_create_on_node+0x190/0x190
(...snipped...)
[  466.620387] xfs-data/sda1   D ffff88007fc56700     0   371      2 0x00000000
[  466.622286] Workqueue: xfs-data/sda1 xfs_end_io
[  466.623683]  ffff8800775b69c0 ffff88007fcd6700 ffff880035448000 ffff8800775b69c0
[  466.625720]  ffff88007b582ca8 ffffffff00000000 fffffffe00000001 0000000000000002
[  466.628214]  ffffffff8161d37a ffff88007b582c90 ffffffff8161f79d ffff88007fbf1f00
[  466.630233] Call Trace:
[  466.631241]  [<ffffffff8161d37a>] ? schedule+0x2a/0x80
[  466.632745]  [<ffffffff8161f79d>] ? rwsem_down_write_failed+0x20d/0x3c0
[  466.634520]  [<ffffffff8130ce63>] ? call_rwsem_down_write_failed+0x13/0x20
[  466.636387]  [<ffffffff8161ef64>] ? down_write+0x24/0x40
[  466.637912]  [<ffffffff8122bb50>] ? xfs_setfilesize+0x20/0xa0
[  466.639506]  [<ffffffff8122bcbc>] ? xfs_end_io+0x5c/0x90
[  466.641088]  [<ffffffff8107ef51>] ? process_one_work+0x131/0x350
[  466.642737]  [<ffffffff8107f834>] ? rescuer_thread+0x194/0x3d0
[  466.644360]  [<ffffffff8107f6a0>] ? worker_thread+0x530/0x530
[  466.646023]  [<ffffffff81084658>] ? kthread+0xc8/0xe0
[  466.647516]  [<ffffffff81084590>] ? kthread_create_on_node+0x190/0x190
[  466.649269]  [<ffffffff81620f62>] ? ret_from_fork+0x42/0x70
[  466.650848]  [<ffffffff81084590>] ? kthread_create_on_node+0x190/0x190
(...snipped...)
[  472.440941] Showing busy workqueues and worker pools:
[  472.442719] workqueue events: flags=0x0
[  472.444290]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=6/256
[  472.446497]     pending: vmstat_update, console_callback, flush_to_ldisc, moom_callback, sysrq_reinject_alt_sysrq, push_to_pool
[  472.449749]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=4/256
[  472.451860]     pending: vmstat_shepherd, vmstat_update, fb_deferred_io_work, vmpressure_work_fn
[  472.454529]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  472.456602]     pending: vmstat_update, e1000_watchdog [e1000]
[  472.458743] workqueue events_freezable: flags=0x4
[  472.460456]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  472.462526]     pending: vmballoon_work [vmw_balloon]
[  472.464896] workqueue events_power_efficient: flags=0x80
[  472.466700]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  472.468884]     pending: fb_flashcursor
[  472.470482]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  472.472605]     pending: neigh_periodic_work
[  472.474316] workqueue events_freezable_power_: flags=0x84
[  472.476126]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  472.478274]     in-flight: 62:disk_events_workfn
[  472.480016] workqueue writeback: flags=0x4e
[  472.481679]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[  472.483606]     in-flight: 358:bdi_writeback_workfn bdi_writeback_workfn
[  472.485733] workqueue xfs-data/sda1: flags=0xc
[  472.487382]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=10/256
[  472.489442]     in-flight: 7733:xfs_end_io, 26:xfs_end_io, 7729:xfs_end_io, 2737:xfs_end_io, 7731:xfs_end_io, 423:xfs_end_io, 7734:xfs_end_io, 7732:xfs_end_io, 7735:xfs_end_io, 65:xfs_end_io
[  472.494498]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=8/256 MAYDAY
[  472.496662]     in-flight: 134:xfs_end_io, 10998:xfs_end_io, 11007:xfs_end_io, 20:xfs_end_io, 448:xfs_end_io, 11005:xfs_end_io, 232:xfs_end_io, 10997:xfs_end_io
[  472.501281]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=56/256 MAYDAY
[  472.503479]     in-flight: 10999:xfs_end_io, 11004:xfs_end_io, 11018:xfs_end_io, 11038:xfs_end_io, 11025:xfs_end_io, 11001:xfs_end_io, 11020:xfs_end_io, 7728:xfs_end_io, 7730:xfs_end_io, 11027:xfs_end_io, 11011:xfs_end_io, 215:xfs_end_io, 11035:xfs_end_io, 11023:xfs_end_io, 11003:xfs_end_io, 11032:xfs_end_io, 11024:xfs_end_io, 10995:xfs_end_io, 11036:xfs_end_io, 11000:xfs_end_io, 11017:xfs_end_io, 11028:xfs_end_io, 11010:xfs_end_io, 43:xfs_end_io, 11015:xfs_end_io, 11034:xfs_end_io, 11030:xfs_end_io, 11009:xfs_end_io, 10996:xfs_end_io, 14:xfs_end_io, 11026:xfs_end_io, 371(RESCUER):xfs_end_io xfs_end_io xfs_end_io, 11037:xfs_end_io, 11006:xfs_end_io, 11014:xfs_end_io, 11022:xfs_end_io, 11002:xfs_end_io, 11019:xfs_end_io, 11033:xfs_end_io, 11031:xfs_end_io, 11008:xfs_end_io, 11012:xfs_end_io, 11021:xfs_end_io
[  472.523473]     pending: xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io
[  472.527333] workqueue xfs-cil/sda1: flags=0xc
[  472.529211]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  472.531450]     pending: xlog_cil_push_work BAR(5327)
[  472.533532] workqueue xfs-log/sda1: flags=0x14
[  472.535342]   pwq 1: cpus=0 node=0 flags=0x0 nice=-20 active=1/256
[  472.537617]     in-flight: 5327:xfs_log_worker
[  472.539663] workqueue xfs-eofblocks/sda1: flags=0x4
[  472.541540]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  472.543880]     in-flight: 11029:xfs_eofblocks_worker
[  472.545912] pool 0: cpus=0 node=0 flags=0x0 nice=0 workers=3 idle: 173 64
[  472.548397] pool 1: cpus=0 node=0 flags=0x0 nice=-20 workers=3 idle: 2016 5
[  472.550855] pool 2: cpus=1 node=0 flags=0x0 nice=0 workers=43 manager: 11039
[  472.553317] pool 4: cpus=2 node=0 flags=0x0 nice=0 workers=11 idle: 11013 11016
[  472.555879] pool 6: cpus=3 node=0 flags=0x0 nice=0 workers=13 idle: 7736 7738 7737
[  472.558907] pool 16: cpus=0-7 flags=0x4 nice=0 workers=3 idle: 357 356
[  522.490286] sysrq: SysRq : Manual OOM execution
[  525.045576] sysrq: SysRq : Manual OOM execution
[  527.096215] sysrq: SysRq : Manual OOM execution
[  529.154109] sysrq: SysRq : Manual OOM execution
[  531.284654] sysrq: SysRq : Manual OOM execution
[  593.591208] sysrq: SysRq : Show State
(...snipped...)
[  594.564502] kswapd0         D 0000000000000003     0    45      2 0x00000000
[  594.566443]  ffff88007cdecf50 ffffea000117f540 ffff880078798000 ffff88007fcceb00
[  594.568680]  ffff88007fcceb00 0000000100047b1c ffff88007fac39a0 0000000000000017
[  594.570753]  ffffffff8161d37a ffff880078797a68 ffffffff8161fa83 0000000000000005
[  594.572826] Call Trace:
[  594.573882]  [<ffffffff8161d37a>] ? schedule+0x2a/0x80
[  594.575433]  [<ffffffff8161fa83>] ? schedule_timeout+0x113/0x1b0
[  594.577136]  [<ffffffff810c2b10>] ? migrate_timer_list+0x60/0x60
[  594.578828]  [<ffffffff8161ca89>] ? io_schedule_timeout+0x99/0x100
[  594.580553]  [<ffffffff8112df99>] ? congestion_wait+0x79/0xd0
[  594.582194]  [<ffffffff810a31c0>] ? wait_woken+0x80/0x80
[  594.583760]  [<ffffffff8112396b>] ? shrink_inactive_list+0x4bb/0x530
[  594.585557]  [<ffffffff811243a1>] ? shrink_lruvec+0x571/0x780
[  594.587182]  [<ffffffff8100c671>] ? __switch_to+0x201/0x540
[  594.588796]  [<ffffffff8100c671>] ? __switch_to+0x201/0x540
[  594.590387]  [<ffffffff811246a2>] ? shrink_zone+0xf2/0x300
[  594.591956]  [<ffffffff8112572d>] ? kswapd+0x50d/0x940
[  594.593450]  [<ffffffff81125220>] ? mem_cgroup_shrink_node_zone+0xd0/0xd0
[  594.595277]  [<ffffffff81084658>] ? kthread+0xc8/0xe0
[  594.596761]  [<ffffffff81084590>] ? kthread_create_on_node+0x190/0x190
[  594.598509]  [<ffffffff81620f62>] ? ret_from_fork+0x42/0x70
[  594.600105]  [<ffffffff81084590>] ? kthread_create_on_node+0x190/0x190
(...snipped...)
[  596.773310] xfs-data/sda1   D ffff88007fc56700     0   371      2 0x00000000
[  596.775200] Workqueue: xfs-data/sda1 xfs_end_io
[  596.776610]  ffff8800775b69c0 ffff88007fcd6700 ffff880035448000 ffff8800775b69c0
[  596.778636]  ffff88007b582ca8 ffffffff00000000 fffffffe00000001 0000000000000002
[  596.780652]  ffffffff8161d37a ffff88007b582c90 ffffffff8161f79d ffff88007fbf1f00
[  596.782772] Call Trace:
[  596.783780]  [<ffffffff8161d37a>] ? schedule+0x2a/0x80
[  596.785277]  [<ffffffff8161f79d>] ? rwsem_down_write_failed+0x20d/0x3c0
[  596.787034]  [<ffffffff8130ce63>] ? call_rwsem_down_write_failed+0x13/0x20
[  596.788875]  [<ffffffff8161ef64>] ? down_write+0x24/0x40
[  596.790398]  [<ffffffff8122bb50>] ? xfs_setfilesize+0x20/0xa0
[  596.792010]  [<ffffffff8122bcbc>] ? xfs_end_io+0x5c/0x90
[  596.793577]  [<ffffffff8107ef51>] ? process_one_work+0x131/0x350
[  596.795231]  [<ffffffff8107f834>] ? rescuer_thread+0x194/0x3d0
[  596.796854]  [<ffffffff8107f6a0>] ? worker_thread+0x530/0x530
[  596.798473]  [<ffffffff81084658>] ? kthread+0xc8/0xe0
[  596.799956]  [<ffffffff81084590>] ? kthread_create_on_node+0x190/0x190
[  596.801704]  [<ffffffff81620f62>] ? ret_from_fork+0x42/0x70
[  596.803290]  [<ffffffff81084590>] ? kthread_create_on_node+0x190/0x190
(...snipped...)
[  602.433643] Showing busy workqueues and worker pools:
[  602.435435] workqueue events: flags=0x0
[  602.436985]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=6/256
[  602.439035]     pending: vmstat_update, console_callback, flush_to_ldisc, moom_callback, sysrq_reinject_alt_sysrq, push_to_pool
[  602.442192]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=4/256
[  602.444276]     pending: vmstat_shepherd, vmstat_update, fb_deferred_io_work, vmpressure_work_fn
[  602.446899]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  602.448983]     pending: vmstat_update, e1000_watchdog [e1000]
[  602.451019] workqueue events_freezable: flags=0x4
[  602.452741]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  602.454894]     pending: vmballoon_work [vmw_balloon]
[  602.456739] workqueue events_power_efficient: flags=0x80
[  602.458558]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  602.460611]     pending: fb_flashcursor
[  602.462207]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  602.464257]     pending: neigh_periodic_work
[  602.465957] workqueue events_freezable_power_: flags=0x84
[  602.467766]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  602.469802]     in-flight: 62:disk_events_workfn
[  602.471535] workqueue writeback: flags=0x4e
[  602.473167]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[  602.475070]     in-flight: 358:bdi_writeback_workfn bdi_writeback_workfn
[  602.477233] workqueue xfs-data/sda1: flags=0xc
[  602.478832]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=10/256
[  602.480845]     in-flight: 7733:xfs_end_io, 26:xfs_end_io, 7729:xfs_end_io, 2737:xfs_end_io, 7731:xfs_end_io, 423:xfs_end_io, 7734:xfs_end_io, 7732:xfs_end_io, 7735:xfs_end_io, 65:xfs_end_io
[  602.486167]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=8/256 MAYDAY
[  602.488307]     in-flight: 134:xfs_end_io, 10998:xfs_end_io, 11007:xfs_end_io, 20:xfs_end_io, 448:xfs_end_io, 11005:xfs_end_io, 232:xfs_end_io, 10997:xfs_end_io
[  602.492909]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=56/256 MAYDAY
[  602.495132]     in-flight: 10999:xfs_end_io, 11004:xfs_end_io, 11018:xfs_end_io, 11038:xfs_end_io, 11025:xfs_end_io, 11001:xfs_end_io, 11020:xfs_end_io, 7728:xfs_end_io, 7730:xfs_end_io, 11027:xfs_end_io, 11011:xfs_end_io, 215:xfs_end_io, 11035:xfs_end_io, 11023:xfs_end_io, 11003:xfs_end_io, 11032:xfs_end_io, 11024:xfs_end_io, 10995:xfs_end_io, 11036:xfs_end_io, 11000:xfs_end_io, 11017:xfs_end_io, 11028:xfs_end_io, 11010:xfs_end_io, 43:xfs_end_io, 11015:xfs_end_io, 11034:xfs_end_io, 11030:xfs_end_io, 11009:xfs_end_io, 10996:xfs_end_io, 14:xfs_end_io, 11026:xfs_end_io, 371(RESCUER):xfs_end_io xfs_end_io xfs_end_io, 11037:xfs_end_io, 11006:xfs_end_io, 11014:xfs_end_io, 11022:xfs_end_io, 11002:xfs_end_io, 11019:xfs_end_io, 11033:xfs_end_io, 11031:xfs_end_io, 11008:xfs_end_io, 11012:xfs_end_io, 11021:xfs_end_io
[  602.515036]     pending: xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io
[  602.519005]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  602.521255]     pending: xfs_end_io
[  602.522969] workqueue xfs-cil/sda1: flags=0xc
[  602.524847]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  602.527565]     pending: xlog_cil_push_work BAR(5327)
[  602.529603] workqueue xfs-log/sda1: flags=0x14
[  602.531414]   pwq 1: cpus=0 node=0 flags=0x0 nice=-20 active=1/256
[  602.533669]     in-flight: 5327:xfs_log_worker
[  602.535572] workqueue xfs-eofblocks/sda1: flags=0x4
[  602.537513]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  602.539703]     in-flight: 11029:xfs_eofblocks_worker
[  602.541740] pool 0: cpus=0 node=0 flags=0x0 nice=0 workers=3 idle: 173 64
[  602.544233] pool 1: cpus=0 node=0 flags=0x0 nice=-20 workers=3 idle: 2016 5
[  602.546746] pool 2: cpus=1 node=0 flags=0x0 nice=0 workers=43 manager: 11039
[  602.549164] pool 4: cpus=2 node=0 flags=0x0 nice=0 workers=11 idle: 11013 11016
[  602.551756] pool 6: cpus=3 node=0 flags=0x0 nice=0 workers=13 idle: 7736 7738 7737
[  602.554295] pool 16: cpus=0-7 flags=0x4 nice=0 workers=3 idle: 357 356
(...snipped...)
[  682.791133] kswapd0         D 0000000000000002     0    45      2 0x00000000
[  682.793129]  ffff88007cdecf50 ffffea0001e98d00 ffff880078798000 ffff88007fc8eb00
[  682.795229]  ffff88007fc8eb00 000000010005cf73 ffff88007fac39a0 0000000000000017
[  682.797305]  ffffffff8161d37a ffff880078797a68 ffffffff8161fa83 0000000000000005
[  682.799379] Call Trace:
[  682.800437]  [<ffffffff8161d37a>] ? schedule+0x2a/0x80
[  682.801976]  [<ffffffff8161fa83>] ? schedule_timeout+0x113/0x1b0
[  682.803677]  [<ffffffff810c2b10>] ? migrate_timer_list+0x60/0x60
[  682.805379]  [<ffffffff8161ca89>] ? io_schedule_timeout+0x99/0x100
[  682.807110]  [<ffffffff8112df99>] ? congestion_wait+0x79/0xd0
[  682.808752]  [<ffffffff810a31c0>] ? wait_woken+0x80/0x80
[  682.810318]  [<ffffffff8112396b>] ? shrink_inactive_list+0x4bb/0x530
[  682.812073]  [<ffffffff811243a1>] ? shrink_lruvec+0x571/0x780
[  682.813721]  [<ffffffff8100c671>] ? __switch_to+0x201/0x540
[  682.815324]  [<ffffffff8100c671>] ? __switch_to+0x201/0x540
[  682.816966]  [<ffffffff811246a2>] ? shrink_zone+0xf2/0x300
[  682.818536]  [<ffffffff8112572d>] ? kswapd+0x50d/0x940
[  682.820027]  [<ffffffff81125220>] ? mem_cgroup_shrink_node_zone+0xd0/0xd0
[  682.821847]  [<ffffffff81084658>] ? kthread+0xc8/0xe0
[  682.823331]  [<ffffffff81084590>] ? kthread_create_on_node+0x190/0x190
[  682.825072]  [<ffffffff81620f62>] ? ret_from_fork+0x42/0x70
[  682.826649]  [<ffffffff81084590>] ? kthread_create_on_node+0x190/0x190
(...snipped...)
[  685.013561] xfs-data/sda1   D ffff88007fc56700     0   371      2 0x00000000
[  685.015492] Workqueue: xfs-data/sda1 xfs_end_io
[  685.016894]  ffff8800775b69c0 ffff88007fcd6700 ffff880035448000 ffff8800775b69c0
[  685.018898]  ffff88007b582ca8 ffffffff00000000 fffffffe00000001 0000000000000002
[  685.020943]  ffffffff8161d37a ffff88007b582c90 ffffffff8161f79d ffff88007fbf1f00
[  685.022936] Call Trace:
[  685.023945]  [<ffffffff8161d37a>] ? schedule+0x2a/0x80
[  685.025459]  [<ffffffff8161f79d>] ? rwsem_down_write_failed+0x20d/0x3c0
[  685.027232]  [<ffffffff8130ce63>] ? call_rwsem_down_write_failed+0x13/0x20
[  685.029035]  [<ffffffff8161ef64>] ? down_write+0x24/0x40
[  685.030566]  [<ffffffff8122bb50>] ? xfs_setfilesize+0x20/0xa0
[  685.032195]  [<ffffffff8122bcbc>] ? xfs_end_io+0x5c/0x90
[  685.033760]  [<ffffffff8107ef51>] ? process_one_work+0x131/0x350
[  685.035400]  [<ffffffff8107f834>] ? rescuer_thread+0x194/0x3d0
[  685.037046]  [<ffffffff8107f6a0>] ? worker_thread+0x530/0x530
[  685.038663]  [<ffffffff81084658>] ? kthread+0xc8/0xe0
[  685.040142]  [<ffffffff81084590>] ? kthread_create_on_node+0x190/0x190
[  685.041883]  [<ffffffff81620f62>] ? ret_from_fork+0x42/0x70
[  685.043466]  [<ffffffff81084590>] ? kthread_create_on_node+0x190/0x190
(...snipped...)
[  690.761839] Showing busy workqueues and worker pools:
[  690.763617] workqueue events: flags=0x0
[  690.765158]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=6/256
[  690.767223]     pending: vmstat_update, console_callback, flush_to_ldisc, moom_callback, sysrq_reinject_alt_sysrq, push_to_pool
[  690.770382]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=4/256
[  690.772458]     pending: vmstat_shepherd, vmstat_update, fb_deferred_io_work, vmpressure_work_fn
[  690.775199]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  690.777285]     pending: vmstat_update, e1000_watchdog [e1000]
[  690.779309] workqueue events_freezable: flags=0x4
[  690.781031]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  690.783117]     pending: vmballoon_work [vmw_balloon]
[  690.784964] workqueue events_power_efficient: flags=0x80
[  690.786755]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  690.788835]     pending: fb_flashcursor
[  690.790445]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  690.792508]     pending: neigh_periodic_work
[  690.794188] workqueue events_freezable_power_: flags=0x84
[  690.795981]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  690.798029]     in-flight: 62:disk_events_workfn
[  690.799767] workqueue writeback: flags=0x4e
[  690.801324]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[  690.803281]     in-flight: 358:bdi_writeback_workfn bdi_writeback_workfn
[  690.805415] workqueue xfs-data/sda1: flags=0xc
[  690.807041]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=10/256
[  690.809080]     in-flight: 7733:xfs_end_io, 26:xfs_end_io, 7729:xfs_end_io, 2737:xfs_end_io, 7731:xfs_end_io, 423:xfs_end_io, 7734:xfs_end_io, 7732:xfs_end_io, 7735:xfs_end_io, 65:xfs_end_io
[  690.814195]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=8/256 MAYDAY
[  690.816359]     in-flight: 134:xfs_end_io, 10998:xfs_end_io, 11007:xfs_end_io, 20:xfs_end_io, 448:xfs_end_io, 11005:xfs_end_io, 232:xfs_end_io, 10997:xfs_end_io
[  690.820985]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=56/256 MAYDAY
[  690.823218]     in-flight: 10999:xfs_end_io, 11004:xfs_end_io, 11018:xfs_end_io, 11038:xfs_end_io, 11025:xfs_end_io, 11001:xfs_end_io, 11020:xfs_end_io, 7728:xfs_end_io, 7730:xfs_end_io, 11027:xfs_end_io, 11011:xfs_end_io, 215:xfs_end_io, 11035:xfs_end_io, 11023:xfs_end_io, 11003:xfs_end_io, 11032:xfs_end_io, 11024:xfs_end_io, 10995:xfs_end_io, 11036:xfs_end_io, 11000:xfs_end_io, 11017:xfs_end_io, 11028:xfs_end_io, 11010:xfs_end_io, 43:xfs_end_io, 11015:xfs_end_io, 11034:xfs_end_io, 11030:xfs_end_io, 11009:xfs_end_io, 10996:xfs_end_io, 14:xfs_end_io, 11026:xfs_end_io, 371(RESCUER):xfs_end_io xfs_end_io xfs_end_io, 11037:xfs_end_io, 11006:xfs_end_io, 11014:xfs_end_io, 11022:xfs_end_io, 11002:xfs_end_io, 11019:xfs_end_io, 11033:xfs_end_io, 11031:xfs_end_io, 11008:xfs_end_io, 11012:xfs_end_io, 11021:xfs_end_io
[  690.843071]     pending: xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io
[  690.846995]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  690.849221]     pending: xfs_end_io
[  690.850963] workqueue xfs-cil/sda1: flags=0xc
[  690.852757]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  690.855025]     pending: xlog_cil_push_work BAR(5327)
[  690.857038] workqueue xfs-log/sda1: flags=0x14
[  690.858847]   pwq 1: cpus=0 node=0 flags=0x0 nice=-20 active=1/256
[  690.861085]     in-flight: 5327:xfs_log_worker
[  690.862980] workqueue xfs-eofblocks/sda1: flags=0x4
[  690.864859]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  690.867052]     in-flight: 11029:xfs_eofblocks_worker
[  690.869050] pool 0: cpus=0 node=0 flags=0x0 nice=0 workers=3 idle: 173 64
[  690.871468] pool 1: cpus=0 node=0 flags=0x0 nice=-20 workers=3 idle: 2016 5
[  690.873964] pool 2: cpus=1 node=0 flags=0x0 nice=0 workers=43 manager: 11039
[  690.876395] pool 4: cpus=2 node=0 flags=0x0 nice=0 workers=11 idle: 11013 11016
[  690.878886] pool 6: cpus=3 node=0 flags=0x0 nice=0 workers=13 idle: 7736 7738 7737
[  690.881421] pool 16: cpus=0-7 flags=0x4 nice=0 workers=3 idle: 357 356
[  707.584171] sysrq: SysRq : Resetting
----------

using a reproducer shown below.

----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>

static int file_writer(void *unused)
{
        static char buffer[1048576] = { };
        const int fd = open("/tmp/file",
                            O_WRONLY | O_CREAT | O_APPEND, 0600);
        while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
        return 0;
}

static int memory_consumer(void *unused)
{
        const int fd = open("/dev/zero", O_RDONLY);
        unsigned long size;
        char *buf = NULL;
        sleep(3);
        for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size >>= 1;
                        break;
                }
                buf = cp;
        }
        read(fd, buf, size); /* Will cause OOM due to overcommit */
        return 0;
}

int main(int argc, char *argv[])
{
        clone(file_writer, malloc(4 * 1024) + 4 * 1024, CLONE_SIGHAND | CLONE_VM, NULL);
        clone(file_writer, malloc(4 * 1024) + 4 * 1024, CLONE_SIGHAND | CLONE_VM, NULL);
        clone(memory_consumer, malloc(4 * 1024) + 4 * 1024, CLONE_SIGHAND | CLONE_VM, NULL);
        pause();
        return 0;
}
----------

FYI, similar moom_work lockup in 4.1.0-rc3+ can be found from
http://I-love.SAKURA.ne.jp/tmp/serial-20150516-1.txt.xz .

----------
[  463.070568] sysrq: SysRq : Manual OOM execution
[  469.189784] sysrq: SysRq : Show Blocked State
(...snipped...)
[  469.305369] kswapd0         D ffff88007fc96480     0    45      2 0x00000000
[  469.307259]  ffff88007cde4f50 ffffea00014a6cc0 ffff880078774000 ffff88007fc8e8c0
[  469.309273]  ffff88007fc8e8c0 00000001000291e6 ffff88007fac39a0 0000000000000017
[  469.311419]  ffffffff8160e92a ffff880078773a68 ffffffff81611033 0000000000000015
[  469.313475] Call Trace:
[  469.314537]  [<ffffffff8160e92a>] ? schedule+0x2a/0x80
[  469.316090]  [<ffffffff81611033>] ? schedule_timeout+0x113/0x1b0
[  469.317775]  [<ffffffff810c2990>] ? migrate_timer_list+0x60/0x60
[  469.319470]  [<ffffffff8160e01f>] ? io_schedule_timeout+0x9f/0x120
[  469.321189]  [<ffffffff8112db49>] ? congestion_wait+0x79/0xd0
[  469.322827]  [<ffffffff810a3040>] ? wait_woken+0x80/0x80
[  469.324378]  [<ffffffff811234fb>] ? shrink_inactive_list+0x4bb/0x530
[  469.326122]  [<ffffffff81123f31>] ? shrink_lruvec+0x571/0x780
[  469.327745]  [<ffffffff8100c671>] ? __switch_to+0x201/0x540
[  469.329343]  [<ffffffff8100c671>] ? __switch_to+0x201/0x540
[  469.330917]  [<ffffffff81124232>] ? shrink_zone+0xf2/0x300
[  469.332481]  [<ffffffff811252bd>] ? kswapd+0x50d/0x940
[  469.333981]  [<ffffffff81124db0>] ? mem_cgroup_shrink_node_zone+0xd0/0xd0
[  469.335794]  [<ffffffff81084588>] ? kthread+0xc8/0xe0
[  469.337280]  [<ffffffff810844c0>] ? kthread_create_on_node+0x190/0x190
[  469.339069]  [<ffffffff816124e2>] ? ret_from_fork+0x42/0x70
[  469.340658]  [<ffffffff810844c0>] ? kthread_create_on_node+0x190/0x190
(...snipped...)
[  469.409864] xfs-data/sda1   D 0000000000000003     0   374      2 0x00000000
[  469.411722] Workqueue: xfs-data/sda1 xfs_end_io
[  469.413083]  ffff880077565820 ffff88007fc56480 ffff8800001bc000 ffff880077565820
[  469.415097]  ffff88007b9d20a8 ffffffff00000000 fffffffe00000001 0000000000000002
[  469.417032]  ffffffff8160e92a ffff88007b9d2090 ffffffff81610d4d ffff88007fbf1d80
[  469.419083] Call Trace:
[  469.420159]  [<ffffffff8160e92a>] ? schedule+0x2a/0x80
[  469.421722]  [<ffffffff81610d4d>] ? rwsem_down_write_failed+0x20d/0x3c0
[  469.423520]  [<ffffffff812feb03>] ? call_rwsem_down_write_failed+0x13/0x20
[  469.425370]  [<ffffffff81610514>] ? down_write+0x24/0x40
[  469.426915]  [<ffffffff8122b720>] ? xfs_setfilesize+0x20/0xa0
[  469.428562]  [<ffffffff8122b88c>] ? xfs_end_io+0x5c/0x90
[  469.430202]  [<ffffffff8107ee81>] ? process_one_work+0x131/0x350
[  469.431864]  [<ffffffff8107f764>] ? rescuer_thread+0x194/0x3d0
[  469.433497]  [<ffffffff8107f5d0>] ? worker_thread+0x530/0x530
[  469.435106]  [<ffffffff81084588>] ? kthread+0xc8/0xe0
[  469.436574]  [<ffffffff810844c0>] ? kthread_create_on_node+0x190/0x190
[  469.438331]  [<ffffffff816124e2>] ? ret_from_fork+0x42/0x70
[  469.439935]  [<ffffffff810844c0>] ? kthread_create_on_node+0x190/0x190
(...snipped...)
[  496.158109] sysrq: SysRq : Manual OOM execution
[  500.707551] sysrq: SysRq : Manual OOM execution
[  501.965086] sysrq: SysRq : Manual OOM execution
[  505.905775] sysrq: SysRq : Manual OOM execution
[  507.051127] sysrq: SysRq : Manual OOM execution
[  508.556863] sysrq: SysRq : Show State
(...snipped...)
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
(...snipped...)
[  574.910809] Showing busy workqueues and worker pools:
[  574.912540] workqueue events: flags=0x0
[  574.914048]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=8/256
[  574.916022]     pending: vmpressure_work_fn, console_callback, vmstat_update, flush_to_ldisc, push_to_pool, moom_callback, sysrq_reinject_alt_sysrq, fb_deferred_io_work
[  574.920570] workqueue events_power_efficient: flags=0x80
[  574.922458]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=2/256
[  574.924436]     pending: neigh_periodic_work, check_lifetime
[  574.926362] workqueue events_freezable_power_: flags=0x84
[  574.928083]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  574.930102]     in-flight: 3837:disk_events_workfn
[  574.931957] workqueue writeback: flags=0x4e
[  574.933755]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[  574.935876]     in-flight: 3812:bdi_writeback_workfn bdi_writeback_workfn
[  574.938001] workqueue xfs-data/sda1: flags=0xc
[  574.939621]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  574.941571]     in-flight: 374(RESCUER):xfs_end_io, 3759:xfs_end_io, 26:xfs_end_io, 3836:xfs_end_io
[  574.944138]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  574.946216]     in-flight: 179:xfs_end_io
[  574.947863] pool 2: cpus=1 node=0 flags=0x0 nice=0 workers=4 idle: 3790 237 3820
[  574.950170] pool 6: cpus=3 node=0 flags=0x0 nice=0 workers=5 manager: 219
[  574.952372] pool 16: cpus=0-7 flags=0x4 nice=0 workers=3 idle: 356 357
[  618.816885] sysrq: SysRq : Resetting
----------

> > Therefore, my version used DEFINE_TIMER() than
> > DECLARE_DELAYED_WORK() in order to make sure that the callback shall be
> > called as soon as timeout expires.
> 
> I do not care that much whether it is timer or delayed work which would
> be used.
> 

I do care that SysRq-f's moom_work work is unable to call moom_callback()
as well as out_of_memory(true) by moom_callback() is failing to choose another
mm struct. This forces administrators to use SysRq-{i,c,b} like I explained
in my version.

I think that the basic rule for handling OOM condition is that "Do not trust
anybody, for even the kswapd and rescuer threads can be waiting for lock or
allocation. Decide when to give up at administrator's own risk, and choose
another mm struct or call panic()".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
