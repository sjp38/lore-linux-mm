Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 620E36B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 10:53:11 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id b184so1704113oih.3
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 07:53:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g131si6575809oia.477.2017.08.31.07.53.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Aug 2017 07:53:09 -0700 (PDT)
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201708292014.JHH35412.FMVFHOQOJtSLOF@I-love.SAKURA.ne.jp>
	<20170829143817.GK491396@devbig577.frc2.facebook.com>
	<20170829214104.GW491396@devbig577.frc2.facebook.com>
	<201708302251.GDI75812.OFOQSVJOFMHFLt@I-love.SAKURA.ne.jp>
	<20170831014610.GE491396@devbig577.frc2.facebook.com>
In-Reply-To: <20170831014610.GE491396@devbig577.frc2.facebook.com>
Message-Id: <201708312352.CCC87558.OFMLOVtQOFJFHS@I-love.SAKURA.ne.jp>
Date: Thu, 31 Aug 2017 23:52:57 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Tejun Heo wrote:
> 2. Somehow high memory pressure is preventing the worker to leave
>    idle.  I have no idea how this would happen but it *could* be that
>    there is somehow memory allocation dependency in the worker waking
>    up path.

So far I tested, it seems that I'm hitting this case.

I tried to enforce long schedule_timeout_*() using below patch (and
manually toggling with SysRq-7 and SysRq-9) so that memory pressure is
kept without warning messages.

----------
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3290,6 +3290,9 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 
 	*did_some_progress = 0;
 
+	while (console_loglevel == 9)
+		schedule_timeout_uninterruptible(HZ);
+
 	/*
 	 * Acquire the oom lock.  If that fails, somebody else is
 	 * making progress for us.
@@ -4002,7 +4005,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 		goto nopage;
 
 	/* Make sure we know about allocations which stall for too long */
-	if (time_after(jiffies, alloc_start + stall_timeout)) {
+	if (0 && time_after(jiffies, alloc_start + stall_timeout)) {
 		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
 			"page allocation stalls for %ums, order:%u",
 			jiffies_to_msecs(jiffies-alloc_start), order);
----------

Even without passing WQ_HIGHPRI, pending state for mm_percpu_wq was eventually
solved if I press SysRq-9 and wait.

----------
[ 1588.487142] Showing busy workqueues and worker pools:
[ 1588.487142] workqueue mm_percpu_wq: flags=0x8
[ 1588.487142]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1588.487142]     pending: drain_local_pages_wq{27930} BAR(11781){27929}
[ 1588.487142] workqueue xfs-data/sda1: flags=0xc
[ 1588.487142]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[ 1588.487142]     in-flight: 10795:xfs_end_io{1}
[ 1588.487142] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=27s workers=2 idle: 10759 10756
[ 1588.487142] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=30s workers=2 idle: 4 370
[ 1588.487142] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=17 idle: 10795 10797 9576 10755 11174 11175 11176 11177 11178 11179 11180 11181 11182 11185 11184 11183 10798
[ 1588.487142] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 18 1966
[ 1588.487142] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 10766 10769 202 9545
[ 1588.487142] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=0s workers=2 manager: 24 idle: 1910
[ 1588.487142] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=2 manager: 11048 idle: 11047
[ 1588.487142] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 30 385

[ 2003.653410] Showing busy workqueues and worker pools:
[ 2003.653410] workqueue events_freezable_power_: flags=0x84
[ 2003.653410]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 2003.653410]     in-flight: 202:disk_events_workfn{49675}
[ 2003.653410] workqueue mm_percpu_wq: flags=0x8
[ 2003.653410]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 2003.653410]     pending: drain_local_pages_wq{51051} BAR(12485){51050}
[ 2003.653410] workqueue writeback: flags=0x4e
[ 2003.653410]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[ 2003.653410]     in-flight: 11188:wb_workfn{59981} wb_workfn{59981}
[ 2003.653410] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=51s workers=7 idle: 12244 10759 12237 12236 12242 12240 10756
[ 2003.653410] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=52s workers=2 idle: 370 4
[ 2003.653410] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=3s workers=2 idle: 10795 9576
[ 2003.653410] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=18s workers=2 idle: 12243 1966
[ 2003.653410] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 10769 13270 10766
[ 2003.653410] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=47s workers=2 idle: 24 12232
[ 2003.653410] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=6 idle: 12238 13271 11047 12241 12235 11048
[ 2003.653410] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=54s workers=2 idle: 12239 30

[ 2685.996827] Showing busy workqueues and worker pools:
[ 2685.996827] workqueue mm_percpu_wq: flags=0x8
[ 2685.996827]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 2685.996827]     pending: drain_local_pages_wq{31500} BAR(13181){31500}
[ 2685.996827] workqueue writeback: flags=0x4e
[ 2685.996827]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[ 2685.996827]     in-flight: 11188:wb_workfn{415} wb_workfn{415}
[ 2685.996827] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=31s workers=5 idle: 13274 13287 12244 10759 13281
[ 2685.996827] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=38s workers=2 idle: 4 370
[ 2685.996827] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=5 idle: 10795 13288 13273 13280 13283
[ 2685.996827] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=2s workers=3 idle: 12243 13290 1966
[ 2685.996827] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 10769 13285 13284 202
[ 2685.996827] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=0s workers=3 idle: 24 13289 12232
[ 2685.996827] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 13286 12238 13271 13279
[ 2685.996827] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 30 12239

[ 2909.490137] Showing busy workqueues and worker pools:
[ 2909.490137] workqueue events_power_efficient: flags=0x80
[ 2909.490137]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[ 2909.490137]     in-flight: 12238:fb_flashcursor{5}
[ 2909.490137] workqueue events_freezable_power_: flags=0x84
[ 2909.490137]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 2909.490137]     in-flight: 13284:disk_events_workfn{29237}
[ 2909.490137] workqueue mm_percpu_wq: flags=0x8
[ 2909.490137]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 2909.490137]     pending: drain_local_pages_wq{31651} BAR(13160){31651}
[ 2909.490137] workqueue writeback: flags=0x4e
[ 2909.490137]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[ 2909.490137]     in-flight: 11188:wb_workfn{33925} wb_workfn{33925}
[ 2909.490137] workqueue xfs-data/sda1: flags=0xc
[ 2909.490137]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[ 2909.490137]     in-flight: 13286:xfs_end_io{94642}
[ 2909.490137] workqueue xfs-eofblocks/sda1: flags=0xc
[ 2909.490137]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[ 2909.490137]     in-flight: 10795:xfs_eofblocks_worker{216309}
[ 2909.490137] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=31s workers=5 idle: 13274 13287 12244 10759 13281
[ 2909.490137] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=31s workers=2 idle: 4 370
[ 2909.490137] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=17s workers=5 idle: 13288 13273 13280 13283
[ 2909.490137] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=12s workers=3 idle: 12243 13290 1966
[ 2909.490137] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 10769 13285 202
[ 2909.490137] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=25s workers=3 idle: 13289 24 12232
[ 2909.490137] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 13271 13279
[ 2909.490137] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=26s workers=3 idle: 13291 12239 30

[ 2983.903524] Showing busy workqueues and worker pools:
[ 2983.903524] workqueue events_freezable_power_: flags=0x84
[ 2983.903524]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 2983.903524]     in-flight: 13284:disk_events_workfn{96988}
[ 2983.903524] workqueue mm_percpu_wq: flags=0x8
[ 2983.903524]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 2983.903524]     pending: drain_local_pages_wq{34208} BAR(38){34207}
[ 2983.903524] workqueue writeback: flags=0x4e
[ 2983.903524]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[ 2983.903524]     in-flight: 11188:wb_workfn{101685} wb_workfn{101685}
[ 2983.903524] workqueue xfs-data/sda1: flags=0xc
[ 2983.903524]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[ 2983.903524]     in-flight: 13286:xfs_end_io{162407}
[ 2983.903524] workqueue xfs-eofblocks/sda1: flags=0xc
[ 2983.903524]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[ 2983.903524]     in-flight: 10795:xfs_eofblocks_worker{284079}
[ 2983.903524] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=34s workers=4 idle: 13274 13287 12244 10759
[ 2983.903524] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=61s workers=2 idle: 4 370
[ 2983.903524] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=17s workers=4 idle: 13288 13273 13280
[ 2983.903524] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=50s workers=2 idle: 12243 13290
[ 2983.903524] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 10769 13285
[ 2983.903524] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=67s workers=2 idle: 13289 24
[ 2983.903524] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 12238 13271
[ 2983.903524] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=94s workers=3 idle: 13291 12239 30
----------

So, this pending state seems to be caused by many concurrent allocations by !PF_WQ_WORKER
threads consuming too much CPU time (because they only yield CPU time by many cond_resched()
and one schedule_timeout_uninterruptible(1)) enough to keep schedule_timeout_uninterruptible(1)
by PF_WQ_WORKER threads away for order of minutes. A sort of memory allocation dependency
observable in the form of CPU time starvation for the worker to wake up.

If !PF_WQ_WORKER threads were calling schedule_timeout_uninterruptible(1) more frequently,
PF_WQ_WORKER threads would have gotten a chance to call schedule_timeout_uninterruptible(1)
more quickly and flush pending works via rescuer threads.

To solve this problem, we need to make sure that unlimited number of allocating threads
do not run direct reclaim concurrently. But Michal hates serialization. Hmm.....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
