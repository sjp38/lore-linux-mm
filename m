Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9A06B0260
	for <linux-mm@kvack.org>; Sat, 30 Jul 2016 04:20:43 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id g62so24329813ith.0
        for <linux-mm@kvack.org>; Sat, 30 Jul 2016 01:20:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c10si15539045otc.14.2016.07.30.01.20.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 30 Jul 2016 01:20:42 -0700 (PDT)
Subject: Re: [PATCH 08/10] exit, oom: postpone exit_oom_victim to later
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
	<1469734954-31247-9-git-send-email-mhocko@kernel.org>
In-Reply-To: <1469734954-31247-9-git-send-email-mhocko@kernel.org>
Message-Id: <201607301720.GHG43737.JLVtHOOSQOFFMF@I-love.SAKURA.ne.jp>
Date: Sat, 30 Jul 2016 17:20:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mhocko@suse.com

Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> exit_oom_victim was called after mmput because it is expected that
> address space of the victim would get released by that time and there is
> no reason to hold off the oom killer from selecting another task should
> that be insufficient to handle the oom situation. In order to catch
> post exit_mm() allocations we used to check for PF_EXITING but this
> got removed by 6a618957ad17 ("mm: oom_kill: don't ignore oom score on
> exiting tasks") because this check was lockup prone.
> 
> It seems that we have all needed pieces ready now and can finally
> fix this properly (at least for CONFIG_MMU cases where we have the
> oom_reaper).  Since "oom: keep mm of the killed task available" we have
> a reliable way to ignore oom victims which are no longer interesting
> because they either were reaped and do not sit on a lot of memory or
> they are not reapable for some reason and it is safer to ignore them
> and move on to another victim. That means that we can safely postpone
> exit_oom_victim to closer to the final schedule.

I don't like this patch. The advantage of this patch will be that we can
avoid selecting next OOM victim when only OOM victims need to allocate
memory after they left exit_mm(). But the disadvantage of this patch will
be that we increase the possibility of depleting 100% of memory reserves
by allowing them to allocate using ALLOC_NO_WATERMARKS after they left
exit_mm(). It is possible that a user creates a process with 10000 threads
and let that process be OOM-killed. Then, this patch allows 10000 threads
to start consuming memory reserves after they left exit_mm(). OOM victims
are not the only threads who need to allocate memory for termination. Non
OOM victims might need to allocate memory at exit_task_work() in order to
allow OOM victims to make forward progress. I think that allocations from
do_exit() are important for terminating cleanly (from the point of view of
filesystem integrity and kernel object management) and such allocations
should not be given up simply because ALLOC_NO_WATERMARKS allocations
failed.

> 
> There is possible advantages of this because we are reducing chances
> of further interference of the oom victim with the rest of the system
> after oom_killer_disable(). Strictly speaking this is possible right
> now because there are indeed allocations possible past exit_mm() and
> who knows whether some of them can trigger IO. I haven't seen this in
> practice though.

I don't know which I/O oom_killer_disable() must act as a hard barrier.
But safer way is to get rid of TIF_MEMDIE's triple meanings. The first
one which prevents the OOM killer from selecting next OOM victim was
removed by replacing TIF_MEMDIE test in oom_scan_process_thread() with
tsk_is_oom_victim(). The second one which allows the OOM victims to
deplete 100% of memory reserves wants some changes in order not to
block memory allocations by non OOM victims (e.g. GFP_ATOMIC allocations
by interrupt handlers, GFP_NOIO / GFP_NOFS allocations by subsystems
which are needed for making forward progress of threads in do_exit())
by consuming too much of memory reserves. The third one which blocks
oom_killer_disable() can be removed by replacing TIF_MEMDIE test in
exit_oom_victim() with PFA_OOM_WAITING test like below patch. (If
oom_killer_disable() were specific to CONFIG_MMU=y kernels, I think
that not thawing OOM victims will be simpler because the OOM reaper
can reclaim memory without thawing OOM victims.)

---
 include/linux/oom.h   | 2 +-
 include/linux/sched.h | 4 ++++
 kernel/exit.c         | 4 +++-
 kernel/freezer.c      | 2 +-
 mm/oom_kill.c         | 7 +++----
 5 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 22e18c4..69d56c5 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -102,7 +102,7 @@ extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 
 extern bool out_of_memory(struct oom_control *oc);
 
-extern void exit_oom_victim(void);
+extern void unmark_oom_victim(void);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 32212e9..7f624d1 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2290,6 +2290,7 @@ static inline void memalloc_noio_restore(unsigned int flags)
 #define PFA_SPREAD_PAGE  1      /* Spread page cache over cpuset */
 #define PFA_SPREAD_SLAB  2      /* Spread some slab caches over cpuset */
 #define PFA_LMK_WAITING  3      /* Lowmemorykiller is waiting */
+#define PFA_OOM_WAITING  4      /* Freezer is waiting for OOM killer */
 
 
 #define TASK_PFA_TEST(name, func)					\
@@ -2316,6 +2317,9 @@ TASK_PFA_CLEAR(SPREAD_SLAB, spread_slab)
 TASK_PFA_TEST(LMK_WAITING, lmk_waiting)
 TASK_PFA_SET(LMK_WAITING, lmk_waiting)
 
+TASK_PFA_TEST(OOM_WAITING, oom_waiting)
+TASK_PFA_SET(OOM_WAITING, oom_waiting)
+
 /*
  * task->jobctl flags
  */
diff --git a/kernel/exit.c b/kernel/exit.c
index e9bca29..b19dbfd 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -511,7 +511,7 @@ static void exit_mm(struct task_struct *tsk)
 	mm_update_next_owner(mm);
 	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
-		exit_oom_victim();
+		clear_thread_flag(TIF_MEMDIE);
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
@@ -902,6 +902,8 @@ void do_exit(long code)
 	smp_mb();
 	raw_spin_unlock_wait(&tsk->pi_lock);
 
+	if (task_oom_waiting(tsk))
+		unmark_oom_victim();
 	/* causes final put_task_struct in finish_task_switch(). */
 	tsk->state = TASK_DEAD;
 	tsk->flags |= PF_NOFREEZE;	/* tell freezer to ignore us */
diff --git a/kernel/freezer.c b/kernel/freezer.c
index 6f56a9e..306270d 100644
--- a/kernel/freezer.c
+++ b/kernel/freezer.c
@@ -42,7 +42,7 @@ bool freezing_slow_path(struct task_struct *p)
 	if (p->flags & (PF_NOFREEZE | PF_SUSPEND_TASK))
 		return false;
 
-	if (test_tsk_thread_flag(p, TIF_MEMDIE))
+	if (task_oom_waiting(p))
 		return false;
 
 	if (pm_nosig_freezing || cgroup_freezing(p))
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ca1cc24..c7ae974 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -644,17 +644,16 @@ void mark_oom_victim(struct task_struct *tsk)
 	 * any memory and livelock. freezing_slow_path will tell the freezer
 	 * that TIF_MEMDIE tasks should be ignored.
 	 */
+	task_set_oom_waiting(tsk);
 	__thaw_task(tsk);
 	atomic_inc(&oom_victims);
 }
 
 /**
- * exit_oom_victim - note the exit of an OOM victim
+ * unmark_oom_victim - note the exit of an OOM victim
  */
-void exit_oom_victim(void)
+void unmark_oom_victim(void)
 {
-	clear_thread_flag(TIF_MEMDIE);
-
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
