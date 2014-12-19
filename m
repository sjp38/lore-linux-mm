Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 76C186B0071
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 08:02:16 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so4617419wiv.4
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 05:02:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cu6si3337661wib.36.2014.12.19.05.02.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 05:02:15 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/2] mm, vmscan: prevent kswapd livelock due to pfmemalloc-throttled process being killed
Date: Fri, 19 Dec 2014 14:01:55 +0100
Message-Id: <1418994116-23665-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>

Charles Shirron and Paul Cassella from Cray Inc have reported kswapd stuck
in a busy loop with nothing left to balance, but kswapd_try_to_sleep() failing
to sleep. Their analysis found the cause to be a combination of several
factors:

1. A process is waiting in throttle_direct_reclaim() on pgdat->pfmemalloc_wait

2. The process has been killed (by OOM in this case), but has not yet been
   scheduled to remove itself from the waitqueue and die.

3. kswapd checks for throttled processes in prepare_kswapd_sleep():

        if (waitqueue_active(&pgdat->pfmemalloc_wait))
                wake_up(&pgdat->pfmemalloc_wait);

   However, for a process that was already killed, wake_up() does not remove
   the process from the waitqueue, since try_to_wake_up() checks its state
   first and returns false when the process is no longer waiting.

4. kswapd is running on the same CPU as the only CPU that the process is
   allowed to run on (through cpus_allowed, or possibly single-cpu system).

5. CONFIG_PREEMPT_NONE=y kernel is used. If there's nothing to balance, kswapd
   encounters no voluntary preemption points and repeatedly fails
   prepare_kswapd_sleep(), blocking the process from running and removing
   itself from the waitqueue, which would let kswapd sleep.

This patch fixes the issue by having kswapd call schedule() in situations
where it has tried to wake up a throttled process, but the wait queue is still
active. We have to be careful to do this outside of the prepare_to_wait() -
finish_wait() scope in kswapd_try_to_sleep().

Although it would be sufficient to limit the check to !PREEMPT configurations
to prevent the bug, even with preemption enabled it's better to schedule
immediately than to busy-loop until kswapd runs out of its CPU quantum.

Also we replace wake_up() with wake_up_all(), since it's more efficient than
to loop and wake processes one by one (now also rescheduling between each
iteration). Also update the comment prepare_kswapd_sleep() to hopefully more
clearly describe the races it is preventing.

Fixes: 5515061d22f0 ("mm: throttle direct reclaimers if PF_MEMALLOC reserves
                      are low and swap is backed by network storage")
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: <stable@vger.kernel.org>   # v3.6+
Cc: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Rik van Riel <riel@redhat.com>
---
I've CC'd also Peter and Ingo, since I'm not sure if the wait queue behavior
here is a feature of a bug. Could there be more code that relies on wake_up()
removing process from the wait queue immediately?

 mm/vmscan.c | 41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bd9a72b..162c3f8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2914,23 +2914,28 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
  * Returns true if kswapd is ready to sleep
  */
 static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
-					int classzone_idx)
+				int classzone_idx, bool *woke_pfmemalloc)
 {
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
 		return false;
 
 	/*
-	 * There is a potential race between when kswapd checks its watermarks
-	 * and a process gets throttled. There is also a potential race if
-	 * processes get throttled, kswapd wakes, a large process exits therby
-	 * balancing the zones that causes kswapd to miss a wakeup. If kswapd
-	 * is going to sleep, no process should be sleeping on pfmemalloc_wait
-	 * so wake them now if necessary. If necessary, processes will wake
-	 * kswapd and get throttled again
+	 * The throttled processes are normally woken up in balance_pgdat() as
+	 * soon as pfmemalloc_watermark_ok() is true. But there is a potential
+	 * race between when kswapd checks the watermarks and a process gets
+	 * throttled. There is also a potential race if processes get
+	 * throttled, kswapd wakes, a large process exits thereby balancing the
+	 * zones, which causes kswapd to exit balance_pgdat() before reaching
+	 * the wake up checks. If kswapd is going to sleep, no process should
+	 * be sleeping on pfmemalloc_wait so wake them now if necessary. If the
+	 * wake up is premature, processes will wake kswapd and get throttled
+	 * again. Since each party wakes the other party in its own
+	 * prepare_to_wait() scope, we do not miss a wake up.
 	 */
 	if (waitqueue_active(&pgdat->pfmemalloc_wait)) {
-		wake_up(&pgdat->pfmemalloc_wait);
+		wake_up_all(&pgdat->pfmemalloc_wait);
+		*woke_pfmemalloc = true;
 		return false;
 	}
 
@@ -3220,6 +3225,7 @@ out:
 static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 {
 	long remaining = 0;
+	bool woke_pfmemalloc = false;
 	DEFINE_WAIT(wait);
 
 	if (freezing(current) || kthread_should_stop())
@@ -3228,7 +3234,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 
 	/* Try to sleep for a short interval */
-	if (prepare_kswapd_sleep(pgdat, order, remaining, classzone_idx)) {
+	if (prepare_kswapd_sleep(pgdat, order, remaining, classzone_idx,
+							&woke_pfmemalloc)) {
 		remaining = schedule_timeout(HZ/10);
 		finish_wait(&pgdat->kswapd_wait, &wait);
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
@@ -3238,7 +3245,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 	 * After a short sleep, check if it was a premature sleep. If not, then
 	 * go fully to sleep until explicitly woken up.
 	 */
-	if (prepare_kswapd_sleep(pgdat, order, remaining, classzone_idx)) {
+	if (prepare_kswapd_sleep(pgdat, order, remaining, classzone_idx,
+							&woke_pfmemalloc)) {
 		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 
 		/*
@@ -3270,6 +3278,17 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
 	}
 	finish_wait(&pgdat->kswapd_wait, &wait);
+
+	/*
+	 * If we tried to wake up processes in prepare_kswapd_sleep(), it's
+	 * possible that some process was already killed, in which case the
+	 * wake_up() does not remove it from the wait queue. It needs to have
+	 * a chance to run, but it might be constrained to the CPU we are
+	 * now using. This is fatal on non-preemptive systems, unless we
+	 * schedule.
+	 */
+	if (woke_pfmemalloc && waitqueue_active(&pgdat->pfmemalloc_wait))
+		schedule();
 }
 
 /*
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
