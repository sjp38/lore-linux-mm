Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 30FEE6B0038
	for <linux-mm@kvack.org>; Sun, 25 Oct 2015 06:53:18 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so166452323pac.3
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 03:53:17 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a5si4328397pbu.76.2015.10.25.03.53.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 25 Oct 2015 03:53:16 -0700 (PDT)
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable() checks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20151023083316.GB2410@dhcp22.suse.cz>
	<20151023103630.GA4170@mtj.duckdns.org>
	<20151023111145.GH2410@dhcp22.suse.cz>
	<201510232125.DAG82381.LMJtOQFOHVOSFF@I-love.SAKURA.ne.jp>
	<20151023182343.GB14610@mtj.duckdns.org>
In-Reply-To: <20151023182343.GB14610@mtj.duckdns.org>
Message-Id: <201510251952.CEF04109.OSOtLFHFVFJMQO@I-love.SAKURA.ne.jp>
Date: Sun, 25 Oct 2015 19:52:59 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, cl@linux.com, htejun@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Tejun Heo wrote:
> If this is an actual problem, a better approach would be something
> which detects the stall condition and kicks off the next work item but
> if we do that I think I'd still trigger a warning there.  I don't
> know.  Don't go busy waiting in kernel.

Busy waiting in kernel refers several cases.

  (1) Wait for something with interrupts disabled.

  (2) Wait for something with interrupts enabled but
      without calling cond_resched() etc.

  (3) Wait for something with interrupts enabled and
      with calling cond_resched() etc.

  (4) Wait for something with interrupts enabled and
      with calling schedule_timeout() etc.

Kernel code tries to minimize (1). Kernel code does (2) if they are
not allowed to sleep. But kernel code is allowed to do (3) if they
are allowed to sleep, as long as cond_resched() is sometimes called.
And currently page allocator does (3). But kernel code invoked via
workqueue is expected to do (4) than (3).

This means that any kernel code which invokes a __GFP_WAIT allocation
might fail to do (4) when invoked via workqueue, regardless of flags
passed to alloc_workqueue()?

Michal Hocko wrote:
> On Fri 23-10-15 06:42:43, Tetsuo Handa wrote:
> > Tejun Heo wrote:
> > > On Thu, Oct 22, 2015 at 05:49:22PM +0200, Michal Hocko wrote:
> > > > I am confused. What makes rescuer to not run? Nothing seems to be
> > > > hogging CPUs, we are just out of workers which are loopin in the
> > > > allocator but that is preemptible context.
> > > 
> > > It's concurrency management.  Workqueue thinks that the pool is making
> > > positive forward progress and doesn't schedule anything else for
> > > execution while that work item is burning cpu cycles.
> > 
> > Then, isn't below change easier to backport which will also alleviate
> > needlessly burning CPU cycles?
> 
> This is quite obscure. If the vmstat_update fix needs workqueue tweaks
> as well then I would vote for your original patch which is clear,
> straightforward and easy to backport.

I think that inserting a short sleep into page allocator is better
because the vmstat_update fix will not require workqueue tweaks if
we sleep inside page allocator. Also, from the point of view of
protecting page allocator from going unresponsive when hundreds of tasks
started busy-waiting at __alloc_pages_slowpath() because we can observe
that XXX value in the "MemAlloc-Info: XXX stalling task," line grows
when we are unable to make forward progress.

----------------------------------------
>From a2f34850c26b5bb124d44983f5a2020b51249d53 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 25 Oct 2015 19:42:15 +0900
Subject: [PATCH] mm,page_alloc: Insert an uninterruptible sleep before
 retrying.

Since "struct zone"->vm_stat[] is array of atomic_long_t, an effort
to reduce frequency of updating values in vm_stat[] is made by using
per cpu variables "struct per_cpu_pageset"->vm_stat_diff[].
Values in vm_stat_diff[] are merged into vm_stat[] periodically
using vmstat_update workqueue item (struct delayed_work vmstat_work).

When a task attempted to allocate memory and reached direct reclaim
path, shrink_zones() checks whether there are reclaimable pages by
calling zone_reclaimable(). zone_reclaimable() makes decision based
on values in vm_stat[] by calling zone_page_state(). This is usually
fine because values in vm_stat_diff[] are expected to be merged into
vm_stat[] shortly.

But workqueue and page allocator have different assumptions.

  (A) The workqueue defers processing of other items unless currently
      in-flight item enters into !TASK_RUNNING state.

  (B) The page allocator never enters into !TASK_RUNNING state if there
      is nothing to reclaim. (The page allocator calls cond_resched()
      via wait_iff_congested(), but cond_resched() does not make the
      task enter into !TASK_RUNNING state.)

Therefore, if a workqueue item which is processed before vmstat_update
item is processed got stuck inside memory allocation request, values in
vm_stat_diff[] cannot be merged into vm_stat[].

As a result, zone_reclaimable() continues using outdated vm_stat[] values
and the task which is doing direct reclaim path thinks that there are
still reclaimable pages and therefore continues looping.

The consequence is a silent livelock (hang up without any kernel messages)
because the OOM killer will not be invoked. We can hit such livelock by
e.g. disk_events_workfn workqueue item doing memory allocation from
bio_copy_kern().

----------------------------------------
[  255.054205] kworker/3:1     R  running task        0    45      2 0x00000008
[  255.056063] Workqueue: events_freezable_power_ disk_events_workfn
[  255.057715]  ffff88007f805680 ffff88007c55f6d0 ffffffff8116463d ffff88007c55f758
[  255.059705]  ffff88007f82b870 ffff88007c55f6e0 ffffffff811646be ffff88007c55f710
[  255.061694]  ffffffff811bdaf0 ffff88007f82b870 0000000000000400 0000000000000000
[  255.063690] Call Trace:
[  255.064664]  [<ffffffff8116463d>] ? __list_lru_count_one.isra.4+0x1d/0x80
[  255.066428]  [<ffffffff811646be>] ? list_lru_count_one+0x1e/0x20
[  255.068063]  [<ffffffff811bdaf0>] ? super_cache_count+0x50/0xd0
[  255.069666]  [<ffffffff8114ecf6>] ? shrink_slab.part.38+0xf6/0x2a0
[  255.071313]  [<ffffffff81151f78>] ? shrink_zone+0x2c8/0x2e0
[  255.072845]  [<ffffffff81152316>] ? do_try_to_free_pages+0x156/0x6d0
[  255.074527]  [<ffffffff810bc6b6>] ? mark_held_locks+0x66/0x90
[  255.076085]  [<ffffffff816ca797>] ? _raw_spin_unlock_irq+0x27/0x40
[  255.077727]  [<ffffffff810bc7d9>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[  255.079451]  [<ffffffff81152924>] ? try_to_free_pages+0x94/0xc0
[  255.081045]  [<ffffffff81145b4a>] ? __alloc_pages_nodemask+0x72a/0xdb0
[  255.082761]  [<ffffffff8118cd06>] ? alloc_pages_current+0x96/0x1b0
[  255.084407]  [<ffffffff8133985d>] ? bio_alloc_bioset+0x20d/0x2d0
[  255.086032]  [<ffffffff8133aba4>] ? bio_copy_kern+0xc4/0x180
[  255.087584]  [<ffffffff81344f20>] ? blk_rq_map_kern+0x70/0x130
[  255.089161]  [<ffffffff814a334d>] ? scsi_execute+0x12d/0x160
[  255.090696]  [<ffffffff814a3474>] ? scsi_execute_req_flags+0x84/0xf0
[  255.092466]  [<ffffffff814b55f2>] ? sr_check_events+0xb2/0x2a0
[  255.094042]  [<ffffffff814c3223>] ? cdrom_check_events+0x13/0x30
[  255.095634]  [<ffffffff814b5a35>] ? sr_block_check_events+0x25/0x30
[  255.097278]  [<ffffffff813501fb>] ? disk_check_events+0x5b/0x150
[  255.098865]  [<ffffffff81350307>] ? disk_events_workfn+0x17/0x20
[  255.100451]  [<ffffffff810890b5>] ? process_one_work+0x1a5/0x420
[  255.102046]  [<ffffffff81089051>] ? process_one_work+0x141/0x420
[  255.103625]  [<ffffffff8108944b>] ? worker_thread+0x11b/0x490
[  255.105159]  [<ffffffff816c4e95>] ? __schedule+0x315/0xac0
[  255.106643]  [<ffffffff81089330>] ? process_one_work+0x420/0x420
[  255.108217]  [<ffffffff8108f4e9>] ? kthread+0xf9/0x110
[  255.109634]  [<ffffffff8108f3f0>] ? kthread_create_on_node+0x230/0x230
[  255.111307]  [<ffffffff816cb35f>] ? ret_from_fork+0x3f/0x70
[  255.112785]  [<ffffffff8108f3f0>] ? kthread_create_on_node+0x230/0x230
(...snipped...)
[  273.930846] Showing busy workqueues and worker pools:
[  273.932299] workqueue events: flags=0x0
[  273.933465]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  273.935120]     pending: vmpressure_work_fn, vmstat_shepherd, vmstat_update, vmw_fb_dirty_flush [vmwgfx]
[  273.937489] workqueue events_freezable: flags=0x4
[  273.938795]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  273.940446]     pending: vmballoon_work [vmw_balloon]
[  273.941973] workqueue events_power_efficient: flags=0x80
[  273.943491]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  273.945167]     pending: check_lifetime
[  273.946422] workqueue events_freezable_power_: flags=0x84
[  273.947890]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  273.949579]     in-flight: 45:disk_events_workfn
[  273.951103] workqueue ipv6_addrconf: flags=0x8
[  273.952447]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/1
[  273.954121]     pending: addrconf_verify_work
[  273.955541] workqueue xfs-reclaim/sda1: flags=0x4
[  273.957036]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  273.958847]     pending: xfs_reclaim_worker
[  273.960392] pool 6: cpus=3 node=0 flags=0x0 nice=0 workers=3 idle: 186 26
----------------------------------------

Three approaches are proposed for fixing this silent livelock problem.

 (1) Use zone_page_state_snapshot() instead of zone_page_state()
     when doing zone_reclaimable() checks. This approach is clear,
     straightforward and easy to backport. So far I cannot reproduce
     this livelock using this change. But there might be more locations
     which should use zone_page_state_snapshot().

 (2) Use a dedicated workqueue for vmstat_update item which is guaranteed
     to be processed immediately. So far I cannot reproduce this livelock
     using a dedicated workqueue created with WQ_MEM_RECLAIM|WQ_HIGHPRI
     (patch proposed by Christoph Lameter). But according to Tejun Heo,
     if we want to guarantee that nobody can reproduce this livelock, we
     need to modify workqueue API because commit 3270476a6c0c ("workqueue:
     reimplement WQ_HIGHPRI using a separate worker_pool") which went to
     Linux 3.6 lost the guarantee.

 (3) Use a !TASK_RUNNING sleep inside page allocator side. This approach
     is easy to backport. So far I cannot reproduce this livelock using
     this approach. And I think that nobody can reproduce this livelock
     because this changes the page allocator to obey the workqueue's
     expectations. Even if we leave this livelock problem aside, not
     entering into !TASK_RUNNING state for too long is an exclusive
     occupation of workqueue which will make other items in the workqueue
     needlessly deferred. We don't need to defer other items which do not
     invoke a __GFP_WAIT allocation.

This patch does approach (3), by inserting an uninterruptible sleep into
page allocator side before retrying, in order to make sure that other
workqueue items (especially vmstat_update item) are given a chance to be
processed.

Although a different problem, by using approach (3), we can alleviate
needlessly burning CPU cycles even when we hit OOM-killer livelock problem
(hang up after the OOM-killer messages are printed because the OOM victim
cannot terminate due to dependency).

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c   |  8 +-------
 mm/page_alloc.c | 19 +++++++++++++++++--
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d13a339..877b5a5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -722,15 +722,9 @@ bool out_of_memory(struct oom_control *oc)
 		dump_header(oc, NULL, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (p && p != (void *)-1UL) {
+	if (p && p != (void *)-1UL)
 		oom_kill_process(oc, p, points, totalpages, NULL,
 				 "Out of memory");
-		/*
-		 * Give the killed process a good chance to exit before trying
-		 * to allocate memory again.
-		 */
-		schedule_timeout_killable(1);
-	}
 	return true;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3687f4c..047ebda 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2726,7 +2726,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	 */
 	if (!mutex_trylock(&oom_lock)) {
 		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
 
@@ -3385,6 +3384,15 @@ retry:
 	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
+		/*
+		 * Give other workqueue items (especially vmstat_update item)
+		 * a chance to be processed. There is no need to wait if I was
+		 * chosen by the OOM killer, for I will leave this function
+		 * using ALLOC_NO_WATERMARKS. But I need to wait even if I have
+		 * SIGKILL pending, for I can't leave this function.
+		 */
+		if (!test_thread_flag(TIF_MEMDIE))
+			schedule_timeout_uninterruptible(1);
 		goto retry;
 	}
 
@@ -3394,8 +3402,15 @@ retry:
 		goto got_pg;
 
 	/* Retry as long as the OOM killer is making progress */
-	if (did_some_progress)
+	if (did_some_progress) {
+		/*
+		 * Give the OOM victim a chance to leave this function
+		 * before trying to allocate memory again.
+		 */
+		if (!test_thread_flag(TIF_MEMDIE))
+			schedule_timeout_uninterruptible(1);
 		goto retry;
+	}
 
 noretry:
 	/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
