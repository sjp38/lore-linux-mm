Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94F516B04E0
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 06:51:22 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 188so21912192itx.9
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 03:51:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s198si1295822itb.61.2017.07.11.03.51.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 03:51:21 -0700 (PDT)
Subject: Re: mm: Why WQ_MEM_RECLAIM workqueue remains pending?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201706291957.JGH39511.tQMOFSLOFJVHOF@I-love.SAKURA.ne.jp>
	<201707071927.IGG34813.tSQOMJFOHOFVLF@I-love.SAKURA.ne.jp>
	<20170710181214.GD1305447@devbig577.frc2.facebook.com>
In-Reply-To: <20170710181214.GD1305447@devbig577.frc2.facebook.com>
Message-Id: <201707111951.IHA98084.OHQtVOFJMLOSFF@I-love.SAKURA.ne.jp>
Date: Tue, 11 Jul 2017 19:51:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: mgorman@techsingularity.net, vbabka@suse.cz, linux-mm@kvack.org, hillf.zj@alibaba-inc.com, brouer@redhat.com

Tejun Heo wrote:
> Hello, Tetsuo.
> 
> I went through the logs and it doesn't look like the mm workqueue
> actually stalled, it was just slow to make progress.  Please see
> below.
> 
> On Fri, Jul 07, 2017 at 07:27:06PM +0900, Tetsuo Handa wrote:
> > Since drain_local_pages_wq work was stalling for 144 seconds as of uptime = 541,
> > drain_local_pages_wq work was queued around uptime = 397 (which is about 6 seconds
> > since the OOM killer/reaper reclaimed some memory for the last time). 
> > 
> > But as far as I can see from traces, the mm_percpu_wq thread as of uptime = 444 was
> > idle, while drain_local_pages_wq work was pending from uptime = 541 to uptime = 605.
> > This means that the mm_percpu_wq thread did not start processing drain_local_pages_wq
> > work immediately. (I don't know what made drain_local_pages_wq work be processed.)
> > 
> > Why? Is this a workqueue implementation bug? Is this a workqueue usage bug?
> 
> So, rescuer doesn't kick as soon as the workqueue becomes slow.  It
> kicks in if the worker pool that the workqueue is associated with
> hangs.  That is, if you have other work items actively running, e.g.,
> for reclaim on the pool, the pool isn't stalled and rescuers won't be
> woken up.  IOW, having a rescuer prevents a workqueue from deadlocking
> due to resource starvation but it doesn't necessarily make it go
> faster.  It's a deadlock prevention mechanism, not a priority raising
> one.  If the work items need preferential execution, it should use
> WQ_HIGHPRI.

Thank you for explanation.

I tried below change. It indeed reduced delays, but even with WQ_HIGHPRI, up to a
few seconds of delay is unavoidable? I wished it is processed within a few jiffies.

----------
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9a4441b..c099ebf 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1768,7 +1768,8 @@ void __init init_mm_internals(void)
 {
 	int ret __maybe_unused;
 
-	mm_percpu_wq = alloc_workqueue("mm_percpu_wq", WQ_MEM_RECLAIM, 0);
+	mm_percpu_wq = alloc_workqueue("mm_percpu_wq",
+				       WQ_MEM_RECLAIM | WQ_HIGHPRI, 0);
 
 #ifdef CONFIG_SMP
 	ret = cpuhp_setup_state_nocalls(CPUHP_MM_VMSTAT_DEAD, "mm/vmstat:dead",
----------

Before:
----------
[  906.781160] Showing busy workqueues and worker pools:
[  906.789620] workqueue events: flags=0x0
[  906.796439]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=7/256
[  906.805291]     in-flight: 99:vmw_fb_dirty_flush [vmwgfx]{513504}
[  906.809676]     pending: vmpressure_work_fn{571835}, e1000_watchdog [e1000]{571413}, vmstat_shepherd{571093}, vmw_fb_dirty_flush [vmwgfx]{513504}, free_work{50571}, free_obj_work{50546}
[  906.821048] workqueue events_power_efficient: flags=0x80
[  906.825113]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[  906.829567]     pending: fb_flashcursor{571684}, do_cache_clean{566868}, neigh_periodic_work{564836}
[  906.835508] workqueue events_freezable_power_: flags=0x84
[  906.838162]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  906.840906]     in-flight: 200:disk_events_workfn{571819}
[  906.843485] workqueue mm_percpu_wq: flags=0x8
[  906.845675]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  906.848754]     pending: drain_local_pages_wq{50498} BAR(2104){50498}
[  906.851717] workqueue writeback: flags=0x4e
[  906.853841]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[  906.856556]     in-flight: 354:wb_workfn{571030} wb_workfn{571030}
[  906.859881] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=571s workers=2 manager: 33
[  906.863663] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=7s workers=3 idle: 29 1548
[  906.867153] pool 128: cpus=0-63 flags=0x4 nice=0 hung=43s workers=3 idle: 355 2115
----------

After:
----------
[  778.377896] Showing busy workqueues and worker pools:
[  778.380129] workqueue events: flags=0x0
[  778.381879]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=4/256
[  778.384371]     pending: vmpressure_work_fn{117854}, free_work{117845}, e1000_watchdog [e1000]{117406}, e1000_watchdog [e1000]{117406}
[  778.389198]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  778.391732]     in-flight: 1635:vmw_fb_dirty_flush [vmwgfx]{154837} vmw_fb_dirty_flush [vmwgfx]{154837}
[  778.395522] workqueue events_power_efficient: flags=0x80
[  778.397828]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  778.400385]     pending: do_cache_clean{96351}
[  778.402395] workqueue events_freezable_power_: flags=0x84
[  778.404734]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  778.407360]     in-flight: 185:disk_events_workfn{156895}
[  778.409902] workqueue mm_percpu_wq: flags=0x18
[  778.412035]   pwq 7: cpus=3 node=0 flags=0x0 nice=-20 active=1/256
[  778.414675]     pending: vmstat_update{5644}
[  778.416681] workqueue writeback: flags=0x4e
[  778.418701]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[  778.421210]     in-flight: 358:wb_workfn{546} wb_workfn{546}
[  778.424101] workqueue xfs-eofblocks/sda1: flags=0xc
[  778.426304]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  778.429112]     in-flight: 52:xfs_eofblocks_worker [xfs]{117964}
[  778.431749] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=2 manager: 231 idle: 3
[  778.435105] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 1606 49
[  778.438235] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=117s workers=2 manager: 215
[  778.441389] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=6s workers=3 idle: 63 29
[  778.444882] pool 128: cpus=0-63 flags=0x4 nice=0 hung=0s workers=3 idle: 2449 360
----------

By the way, I think it might be useful if delay of each work item is printed together...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
