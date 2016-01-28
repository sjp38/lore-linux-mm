Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8BBC56B0253
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 10:48:56 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id k206so29025286oia.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 07:48:56 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p125si10851974oih.132.2016.01.28.07.48.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 07:48:55 -0800 (PST)
Subject: Re: [LTP] [BUG] oom hangs the system, NMI backtrace shows most CPUs in shrink_slab
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <569E1010.2070806@I-love.SAKURA.ne.jp>
	<56A24760.5020503@redhat.com>
	<56A724B1.3000407@redhat.com>
	<201601262346.BFB30785.VOQOFFHJLMtFSO@I-love.SAKURA.ne.jp>
	<201601272002.FFF21524.OLFVQHFSOtJFOM@I-love.SAKURA.ne.jp>
In-Reply-To: <201601272002.FFF21524.OLFVQHFSOtJFOM@I-love.SAKURA.ne.jp>
Message-Id: <201601290048.IHF21869.OSJOQVOMLFFFHt@I-love.SAKURA.ne.jp>
Date: Fri, 29 Jan 2016 00:48:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, jstancek@redhat.com
Cc: tj@kernel.org, clameter@sgi.com, js1304@gmail.com, arekm@maven.pl, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org

Tetsuo Handa wrote:
> Inviting people who involved in commit 373ccbe5927034b5 "mm, vmstat: allow
> WQ concurrency to discover memory reclaim doesn't make any progress".
> 
> In this thread, Jan hit an OOM stall where free memory does not increase
> even after OOM victim and dying tasks terminated. I'm wondering why such
> thing can happen. Jan established a reproducer and I tried it.
> 
> I'm observing vmstat_update workqueue item forever remains pending.
> Didn't we make sure that vmstat_update is processed when memory allocation
> is stalling?

I confirmed that a forced sleep patch solves this problem.

----------------------------------------
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 7340353..b986216 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -979,6 +979,12 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
 	 */
 	if (atomic_read(&nr_wb_congested[sync]) == 0 ||
 	    !test_bit(ZONE_CONGESTED, &zone->flags)) {
+		const struct memalloc_info *m = &current->memalloc;
+		if (m->valid && time_after_eq(jiffies, m->start + 30 * HZ)) {
+			pr_err("********** %s(%u) Forced sleep **********\n",
+			       current->comm, current->pid);
+			schedule_timeout_uninterruptible(HZ);
+		}
 
 		/*
 		 * Memory allocation/reclaim might be called from a WQ
----------------------------------------

----------------------------------------
[  939.038719] Showing busy workqueues and worker pools:
[  939.040519] workqueue events: flags=0x0
[  939.042142]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  939.044350]     pending: vmpressure_work_fn(delay=20659)
[  939.046302]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  939.048392]     pending: vmw_fb_dirty_flush [vmwgfx](delay=42), vmstat_shepherd(delay=10)
[  939.050946] workqueue events_power_efficient: flags=0x80
[  939.052844]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  939.054980]     pending: fb_flashcursor(delay=20573)
[  939.056939] workqueue events_freezable_power_: flags=0x84
[  939.058872]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  939.060994]     in-flight: 9571:disk_events_workfn(delay=20719)
[  939.063069] workqueue vmstat: flags=0xc
[  939.064667]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  939.066795]     pending: vmstat_update(delay=20016)
[  939.068752] workqueue xfs-eofblocks/sda1: flags=0xc
[  939.070546]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  939.072675]     pending: xfs_eofblocks_worker(delay=5574)
[  939.074660] pool 4: cpus=2 node=0 flags=0x0 nice=0 workers=8 idle: 20 10098 10100 505 10099 10364 10363
[  948.026046] ********** a.out(10423) Forced sleep **********
[  948.036318] ********** a.out(10424) Forced sleep **********
[  948.323267] ********** kworker/2:3(9571) Forced sleep **********
[  949.030045] a.out invoked oom-killer: gfp_mask=0x24280ca, order=0, oom_score_adj=0
[  949.032320] a.out cpuset=/ mems_allowed=0
[  949.033976] CPU: 3 PID: 10423 Comm: a.out Not tainted 4.4.0+ #39
----------------------------------------
[ 1255.809372] Showing busy workqueues and worker pools:
[ 1255.811163] workqueue events: flags=0x0
[ 1255.812744]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1255.814877]     pending: vmpressure_work_fn(delay=10713)
[ 1255.816837]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1255.818960]     pending: vmw_fb_dirty_flush [vmwgfx](delay=42)
[ 1255.821025] workqueue events_power_efficient: flags=0x80
[ 1255.822937]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1255.825136]     pending: fb_flashcursor(delay=20673)
[ 1255.827069] workqueue events_freezable_power_: flags=0x84
[ 1255.828953]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1255.831050]     in-flight: 20:disk_events_workfn(delay=20777)
[ 1255.833063]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1255.835168]     pending: disk_events_workfn(delay=7)
[ 1255.837084] workqueue vmstat: flags=0xc
[ 1255.838707]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1255.840827]     pending: vmstat_update(delay=19787)
[ 1255.842794] pool 4: cpus=2 node=0 flags=0x0 nice=0 workers=3 idle: 9571 10098
[ 1265.036032] ********** kworker/2:0(20) Forced sleep **********
[ 1265.038131] a.out invoked oom-killer: gfp_mask=0x24280ca, order=0, oom_score_adj=0
[ 1265.041018] a.out cpuset=/ mems_allowed=0
[ 1265.043008] CPU: 2 PID: 10622 Comm: a.out Not tainted 4.4.0+ #39
----------------------------------------

In the post "[PATCH 1/2] mm, oom: introduce oom reaper", Andrew Morton said
that "schedule_timeout() in state TASK_RUNNING doesn't do anything".

Looking at commit 373ccbe5927034b5, it is indeed using schedule_timeout(1)
instead of schedule_timeout_*(1). What!? We meant to force the kworker to
sleep but the kworker did not sleep at all? Then, that explains why the
forced sleep patch above solves the OOM livelock.

Jan, can you reproduce your problem with below patch applied?

----------
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 7340353..cbe6f0b 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -989,7 +989,7 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
 		 * here rather than calling cond_resched().
 		 */
 		if (current->flags & PF_WQ_WORKER)
-			schedule_timeout(1);
+			schedule_timeout_uninterruptible(1);
 		else
 			cond_resched();
 
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
