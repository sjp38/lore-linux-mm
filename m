Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id F24A66B0003
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 06:10:53 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id w194so1417714itc.1
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 03:10:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s126si920990itd.141.2018.03.02.03.10.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Mar 2018 03:10:52 -0800 (PST)
Subject: [PATCH v3] mm,page_alloc: wait for oom_lock than back off
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201802241700.JJB51016.FQOLFJHFOOSVMt@I-love.SAKURA.ne.jp>
	<20180226092725.GB16269@dhcp22.suse.cz>
	<201802261958.JDE18780.SFHOFOMOJFQVtL@I-love.SAKURA.ne.jp>
	<20180226121933.GC16269@dhcp22.suse.cz>
	<201802262216.ADH48949.FtQLFOHJOVSOMF@I-love.SAKURA.ne.jp>
In-Reply-To: <201802262216.ADH48949.FtQLFOHJOVSOMF@I-love.SAKURA.ne.jp>
Message-Id: <201803022010.BJE26043.LtSOOVFQOMJFHF@I-love.SAKURA.ne.jp>
Date: Fri, 2 Mar 2018 20:10:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

>From e80aeb994a03c3ae108107ea4d4489bbd7d868e9 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 2 Mar 2018 19:56:50 +0900
Subject: [PATCH v3] mm,page_alloc: wait for oom_lock than back off

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

But since Michal is still worrying that adding a single synchronization
point into the OOM path is risky (without showing a real life example
where lock_killable() in the coldest OOM path hurts), changes made by
this patch will be enabled only when oom_compat_mode=0 kernel command line
parameter is specified so that users can test whether their workloads get
hurt by this patch.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h |  1 +
 mm/oom_kill.c       | 43 +++++++++++++++++----------
 mm/page_alloc.c     | 84 +++++++++++++++++++++++++++++++++++++++++------------
 3 files changed, 95 insertions(+), 33 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index d4d41c0..58bfda1 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -125,4 +125,5 @@ extern unsigned long oom_badness(struct task_struct *p,
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern int oom_compat_mode;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8219001..f3afcba 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -55,6 +55,17 @@
 
 DEFINE_MUTEX(oom_lock);
 
+int oom_compat_mode __ro_after_init = 1;
+static int __init oom_compat_mode_setup(char *str)
+{
+	int rc = kstrtoint(str, 0, &oom_compat_mode);
+
+	if (rc)
+		return rc;
+	return 1;
+}
+__setup("oom_compat_mode=", oom_compat_mode_setup);
+
 #ifdef CONFIG_NUMA
 /**
  * has_intersects_mems_allowed() - check task eligiblity for kill
@@ -492,20 +503,19 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	bool ret = true;
 
 	/*
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
+	 * We have to make sure to not cause premature new oom victim selection:
+	 * __alloc_pages_may_oom()     __oom_reap_task_mm()
+	 *   mutex_trylock(&oom_lock)   # succeeds
+	 *                               unmap_page_range() # frees some memory
+	 *   get_page_from_freelist(ALLOC_WMARK_HIGH) # fails
+	 *                               set_bit(MMF_OOM_SKIP)
+	 *   out_of_memory()
+	 *     select_bad_process()
+	 *       test_bit(MMF_OOM_SKIP) # selects new oom victim
+	 *   mutex_unlock(&oom_lock)
 	 */
-	mutex_lock(&oom_lock);
+	if (oom_compat_mode)
+		mutex_lock(&oom_lock);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
@@ -581,7 +591,8 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 	trace_finish_task_reaping(tsk->pid);
 unlock_oom:
-	mutex_unlock(&oom_lock);
+	if (oom_compat_mode)
+		mutex_unlock(&oom_lock);
 	return ret;
 }
 
@@ -1150,7 +1161,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * Give the killed process a good chance to exit before trying
 	 * to allocate memory again.
 	 */
-	if (delay)
+	if (delay && oom_compat_mode)
 		schedule_timeout_killable(1);
 
 	return !!oc->chosen_task;
@@ -1178,4 +1189,6 @@ void pagefault_out_of_memory(void)
 		return;
 	out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
+	if (!oom_compat_mode)
+		schedule_timeout_killable(1);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2836bc9..536eee9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3438,26 +3438,68 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 
 	*did_some_progress = 0;
 
-	/*
-	 * Acquire the oom lock.  If that fails, somebody else is
-	 * making progress for us.
-	 */
-	if (!mutex_trylock(&oom_lock)) {
-		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
-		return NULL;
+	if (oom_compat_mode) {
+		/*
+		 * Acquire the oom lock. If that fails, somebody else is making
+		 * progress for us. But that assumption does not hold true if
+		 * we are depriving the owner of the oom lock of the CPU
+		 * resources by retrying direct reclaim/compaction.
+		 */
+		if (!mutex_trylock(&oom_lock)) {
+			*did_some_progress = 1;
+			schedule_timeout_uninterruptible(1);
+			return NULL;
+		}
+#ifdef CONFIG_PROVE_LOCKING
+		/*
+		 * Teach the lockdep that mutex_trylock() above acts like
+		 * mutex_lock(), for we are not allowed to depend on
+		 * __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation here.
+		 */
+		mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
+		mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
+#endif
+		/*
+		 * Go through the zonelist yet one more time, keep very high
+		 * watermark here, this is only to catch a parallel oom
+		 * killing, we must fail if we're still under heavy pressure.
+		 * But make sure that this allocation attempt must not depend
+		 * on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation which
+		 * will never fail due to oom_lock already held.
+		 */
+		page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
+					      ~__GFP_DIRECT_RECLAIM, order,
+					      ALLOC_WMARK_HIGH | ALLOC_CPUSET,
+					      ac);
+	} else {
+		/*
+		 * Wait for the oom lock, in order to make sure that we won't
+		 * deprive the owner of the oom lock of CPU resources for
+		 * making progress for us.
+		 */
+		if (mutex_lock_killable(&oom_lock)) {
+			*did_some_progress = 1;
+			return NULL;
+		}
+		/*
+		 * This allocation attempt must not depend on
+		 * __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation which will
+		 * never fail due to oom_lock already held.
+		 *
+		 * Since neither the OOM reaper nor exit_mmap() waits for
+		 * oom_lock when setting MMF_OOM_SKIP on the OOM victim's mm,
+		 * we might needlessly select more OOM victims if we use
+		 * ALLOC_WMARK_HIGH here. But since this allocation attempt
+		 * does not sleep, we will not fail to invoke the OOM killer
+		 * even if we choose ALLOC_WMARK_MIN here. Thus, we use
+		 * ALLOC_WMARK_MIN here.
+		 */
+		page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
+					      ~__GFP_DIRECT_RECLAIM, order,
+					      ALLOC_WMARK_MIN | ALLOC_CPUSET,
+					      ac);
 	}
 
-	/*
-	 * Go through the zonelist yet one more time, keep very high watermark
-	 * here, this is only to catch a parallel oom killing, we must fail if
-	 * we're still under heavy pressure. But make sure that this reclaim
-	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
-	 * allocation which will never fail due to oom_lock already held.
-	 */
-	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
-				      ~__GFP_DIRECT_RECLAIM, order,
-				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
 	if (page)
 		goto out;
 
@@ -4205,6 +4247,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	/* Retry as long as the OOM killer is making progress */
 	if (did_some_progress) {
 		no_progress_loops = 0;
+		/*
+		 * This schedule_timeout_*() serves as a guaranteed sleep for
+		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
+		 */
+		if (!oom_compat_mode && !tsk_is_oom_victim(current))
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
