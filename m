Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 243E86B0003
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 03:01:11 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id v137so5100359oif.3
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 00:01:11 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a3si1366643otc.121.2018.02.24.00.01.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 24 Feb 2018 00:01:09 -0800 (PST)
Subject: [PATCH v2] mm,page_alloc: wait for oom_lock than back off
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201802132058.HAG51540.QFtSLOJFOOFVMH@I-love.SAKURA.ne.jp>
	<201802202232.IEC26597.FOQtMFOFJHOSVL@I-love.SAKURA.ne.jp>
	<20180220144920.GB21134@dhcp22.suse.cz>
	<201802212327.CAB51013.FOStFVLHFJMOOQ@I-love.SAKURA.ne.jp>
	<20180221145437.GI2231@dhcp22.suse.cz>
In-Reply-To: <20180221145437.GI2231@dhcp22.suse.cz>
Message-Id: <201802241700.JJB51016.FQOLFJHFOOSVMt@I-love.SAKURA.ne.jp>
Date: Sat, 24 Feb 2018 17:00:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

>From d922dd170c2bed01a775e8cca0871098aecc253d Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 24 Feb 2018 16:49:21 +0900
Subject: [PATCH v2] mm,page_alloc: wait for oom_lock than back off

This patch fixes a bug which is essentially same with a bug fixed by
commit 400e22499dd92613 ("mm: don't warn about allocations which stall for
too long").

Currently __alloc_pages_may_oom() is using mutex_trylock(&oom_lock) based
on an assumption that the owner of oom_lock is making progress for us. But
it is possible to trigger OOM lockup when many threads concurrently called
__alloc_pages_slowpath() because all CPU resources are wasted for pointless
direct reclaim efforts. That is, schedule_timeout_uninterruptible(1) in
__alloc_pages_may_oom() does not always give enough CPU resource to the
owner of the oom_lock.

It is possible that the owner of oom_lock is preempted by other threads.
Preemption makes the OOM situation much worse. But the page allocator is
not responsible about wasting CPU resource for something other than memory
allocation request. Wasting CPU resource for memory allocation request
without allowing the owner of oom_lock to make forward progress is a page
allocator's bug.

Therefore, this patch changes to wait for oom_lock in order to guarantee
that no thread waiting for the owner of oom_lock to make forward progress
will not consume CPU resources for pointless direct reclaim efforts.

We know printk() from OOM situation where a lot of threads are doing almost
busy-looping is a nightmare. As a side effect of this patch, printk() with
oom_lock held can start utilizing CPU resources saved by this patch (and
reduce preemption during printk(), making printk() complete faster).

By changing !mutex_trylock(&oom_lock) with mutex_lock_killable(&oom_lock),
it is possible that many threads prevent the OOM reaper from making forward
progress. Thus, this patch removes mutex_lock(&oom_lock) from the OOM
reaper.

Also, since nobody uses oom_lock serialization when setting MMF_OOM_SKIP
and we don't try last second allocation attempt after confirming that there
is no !MMF_OOM_SKIP OOM victim, the possibility of needlessly selecting
more OOM victims will be increased if we continue using ALLOC_WMARK_HIGH.
Thus, this patch changes to use ALLOC_MARK_MIN.

Also, since we don't want to sleep with oom_lock held so that we can allow
threads waiting at mutex_lock_killable(&oom_lock) to try last second
allocation attempt (because the OOM reaper starts reclaiming memory without
waiting for oom_lock) and start selecting next OOM victim if necessary,
this patch changes the location of the short sleep from inside of oom_lock
to outside of oom_lock.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c   | 35 +++--------------------------------
 mm/page_alloc.c | 30 ++++++++++++++++++------------
 2 files changed, 21 insertions(+), 44 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8219001..802214f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -491,22 +491,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	bool ret = true;
 
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * __oom_reap_task_mm		exit_mm
-	 *   mmget_not_zero
-	 *				  mmput
-	 *				    atomic_dec_and_test
-	 *				  exit_oom_victim
-	 *				[...]
-	 *				out_of_memory
-	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
-	 */
-	mutex_lock(&oom_lock);
-
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
 		trace_skip_task_reaping(tsk->pid);
@@ -581,7 +565,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 	trace_finish_task_reaping(tsk->pid);
 unlock_oom:
-	mutex_unlock(&oom_lock);
 	return ret;
 }
 
@@ -1078,7 +1061,6 @@ bool out_of_memory(struct oom_control *oc)
 {
 	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
-	bool delay = false; /* if set, delay next allocation attempt */
 
 	if (oom_killer_disabled)
 		return false;
@@ -1128,10 +1110,8 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
-	if (mem_cgroup_select_oom_victim(oc) && oom_kill_memcg_victim(oc)) {
-		delay = true;
+	if (mem_cgroup_select_oom_victim(oc) && oom_kill_memcg_victim(oc))
 		goto out;
-	}
 
 	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
@@ -1139,20 +1119,10 @@ bool out_of_memory(struct oom_control *oc)
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (oc->chosen_task && oc->chosen_task != INFLIGHT_VICTIM) {
+	if (oc->chosen_task && oc->chosen_task != INFLIGHT_VICTIM)
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
 				 "Memory cgroup out of memory");
-		delay = true;
-	}
-
 out:
-	/*
-	 * Give the killed process a good chance to exit before trying
-	 * to allocate memory again.
-	 */
-	if (delay)
-		schedule_timeout_killable(1);
-
 	return !!oc->chosen_task;
 }
 
@@ -1178,4 +1148,5 @@ void pagefault_out_of_memory(void)
 		return;
 	out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
+	schedule_timeout_killable(1);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2836bc9..23d1769 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3438,26 +3438,26 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 
 	*did_some_progress = 0;
 
-	/*
-	 * Acquire the oom lock.  If that fails, somebody else is
-	 * making progress for us.
-	 */
-	if (!mutex_trylock(&oom_lock)) {
+	if (mutex_lock_killable(&oom_lock)) {
 		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
 
 	/*
-	 * Go through the zonelist yet one more time, keep very high watermark
-	 * here, this is only to catch a parallel oom killing, we must fail if
-	 * we're still under heavy pressure. But make sure that this reclaim
-	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
-	 * allocation which will never fail due to oom_lock already held.
+	 * This allocation attempt must not depend on __GFP_DIRECT_RECLAIM &&
+	 * !__GFP_NORETRY allocation which will never fail due to oom_lock
+	 * already held.
+	 *
+	 * Since neither the OOM reaper nor exit_mmap() waits for oom_lock when
+	 * setting MMF_OOM_SKIP on the OOM victim's mm, we might needlessly
+	 * select more OOM victims if we use ALLOC_WMARK_HIGH here. But since
+	 * this allocation attempt does not sleep, we will not fail to invoke
+	 * the OOM killer even if we choose ALLOC_WMARK_MIN here. Thus, we use
+	 * ALLOC_WMARK_MIN here.
 	 */
 	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
 				      ~__GFP_DIRECT_RECLAIM, order,
-				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
+				      ALLOC_WMARK_MIN | ALLOC_CPUSET, ac);
 	if (page)
 		goto out;
 
@@ -4205,6 +4205,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	/* Retry as long as the OOM killer is making progress */
 	if (did_some_progress) {
 		no_progress_loops = 0;
+		/*
+		 * This schedule_timeout_*() serves as a guaranteed sleep for
+		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
+		 */
+		if (!tsk_is_oom_victim(current))
+			schedule_timeout_uninterruptible(1);
 		goto retry;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
