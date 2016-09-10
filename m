Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B48826B025E
	for <linux-mm@kvack.org>; Sat, 10 Sep 2016 08:56:29 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 188so24973127iti.1
        for <linux-mm@kvack.org>; Sat, 10 Sep 2016 05:56:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a64si5573702oii.256.2016.09.10.05.56.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 10 Sep 2016 05:56:29 -0700 (PDT)
Subject: Re: [RFC 3/4] mm, oom: do not rely on TIF_MEMDIE for exit_oom_victim
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
	<1472723464-22866-4-git-send-email-mhocko@kernel.org>
	<201609041050.BFG65134.OHVFQJOOSLMtFF@I-love.SAKURA.ne.jp>
	<20160909140851.GP4844@dhcp22.suse.cz>
	<201609101529.GCI12481.VOtOLHJQFOSMFF@I-love.SAKURA.ne.jp>
In-Reply-To: <201609101529.GCI12481.VOtOLHJQFOSMFF@I-love.SAKURA.ne.jp>
Message-Id: <201609102155.AHJ57859.SOFHQFOtOFLJVM@I-love.SAKURA.ne.jp>
Date: Sat, 10 Sep 2016 21:55:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com, viro@zeniv.linux.org.uk

Tetsuo Handa wrote:
> > > Do we want to thaw OOM victims from the beginning? If the freezer
> > > depends on CONFIG_MMU=y , we don't need to thaw OOM victims.
> > 
> > We want to thaw them, at least at this stage, because the task might be
> > sitting on a memory which is not reclaimable by the oom reaper (e.g.
> > different buffers of file descriptors etc.).

I haven't heard an answer to the question whether the freezer depends on
CONFIG_MMU=y. But I assume the answer is yes here.

> 
> If you worry about tasks which are sitting on a memory which is not
> reclaimable by the oom reaper, why you don't worry about tasks which
> share mm and do not share signal (i.e. clone(CLONE_VM && !CLONE_SIGHAND)
> tasks) ? Thawing only tasks which share signal is a halfway job.
> 

Here is a different approach which does not thaw tasks as of mark_oom_victim()
but thaws tasks as of oom_killer_disable(). I think that we don't need to
distinguish OOM victims and killed/exiting tasks when we disable the OOM
killer, for trying to reclaim as much memory as possible is preferable for
reducing the possibility of memory allocation failure after the OOM killer
is disabled.

Compared to your approach

>  include/linux/sched.h |  2 +-
>  kernel/exit.c         | 38 ++++++++++++++++++++++++++++----------
>  kernel/freezer.c      |  3 ++-
>  mm/oom_kill.c         | 29 +++++++++++++++++------------
>  4 files changed, 48 insertions(+), 24 deletions(-)

, my approach does not touch exit logic.

 include/linux/sched.h |    4 ++
 kernel/freezer.c      |    2 -
 mm/oom_kill.c         |   75 ++++++++++++++++++++++++++++++++------------------
 3 files changed, 54 insertions(+), 27 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index af39baf..4c8278f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2308,6 +2308,7 @@ static inline void memalloc_noio_restore(unsigned int flags)
 #define PFA_SPREAD_PAGE  1      /* Spread page cache over cpuset */
 #define PFA_SPREAD_SLAB  2      /* Spread some slab caches over cpuset */
 #define PFA_LMK_WAITING  3      /* Lowmemorykiller is waiting */
+#define PFA_THAW_WAITING 4      /* A thawed thread waiting for termination */
 
 
 #define TASK_PFA_TEST(name, func)					\
@@ -2334,6 +2335,9 @@ TASK_PFA_CLEAR(SPREAD_SLAB, spread_slab)
 TASK_PFA_TEST(LMK_WAITING, lmk_waiting)
 TASK_PFA_SET(LMK_WAITING, lmk_waiting)
 
+TASK_PFA_TEST(THAW_WAITING, thaw_waiting)
+TASK_PFA_SET(THAW_WAITING, thaw_waiting)
+
 /*
  * task->jobctl flags
  */
diff --git a/kernel/freezer.c b/kernel/freezer.c
index 6f56a9e..5a80d4d 100644
--- a/kernel/freezer.c
+++ b/kernel/freezer.c
@@ -42,7 +42,7 @@ bool freezing_slow_path(struct task_struct *p)
 	if (p->flags & (PF_NOFREEZE | PF_SUSPEND_TASK))
 		return false;
 
-	if (test_tsk_thread_flag(p, TIF_MEMDIE))
+	if (task_thaw_waiting(p))
 		return false;
 
 	if (pm_nosig_freezing || cgroup_freezing(p))
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f284e92..599e256 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -419,12 +419,6 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 		dump_tasks(oc->memcg, oc->nodemask);
 }
 
-/*
- * Number of OOM victims in flight
- */
-static atomic_t oom_victims = ATOMIC_INIT(0);
-static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
-
 static bool oom_killer_disabled __read_mostly;
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
@@ -658,15 +652,6 @@ static void mark_oom_victim(struct task_struct *tsk)
 	/* oom_mm is bound to the signal struct life time. */
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
 		atomic_inc(&tsk->signal->oom_mm->mm_count);
-
-	/*
-	 * Make sure that the task is woken up from uninterruptible sleep
-	 * if it is frozen because OOM killer wouldn't be able to free
-	 * any memory and livelock. freezing_slow_path will tell the freezer
-	 * that TIF_MEMDIE tasks should be ignored.
-	 */
-	__thaw_task(tsk);
-	atomic_inc(&oom_victims);
 }
 
 /**
@@ -675,9 +660,6 @@ static void mark_oom_victim(struct task_struct *tsk)
 void exit_oom_victim(void)
 {
 	clear_thread_flag(TIF_MEMDIE);
-
-	if (!atomic_dec_return(&oom_victims))
-		wake_up_all(&oom_victims_wait);
 }
 
 /**
@@ -705,7 +687,9 @@ void oom_killer_enable(void)
  */
 bool oom_killer_disable(signed long timeout)
 {
-	signed long ret;
+	struct task_struct *p;
+	struct task_struct *t;
+	bool busy = false;
 
 	/*
 	 * Make sure to not race with an ongoing OOM killer. Check that the
@@ -716,14 +700,53 @@ bool oom_killer_disable(signed long timeout)
 	oom_killer_disabled = true;
 	mutex_unlock(&oom_lock);
 
-	ret = wait_event_interruptible_timeout(oom_victims_wait,
-			!atomic_read(&oom_victims), timeout);
-	if (ret <= 0) {
-		oom_killer_enable();
-		return false;
+	/*
+	 * Thaw all killed/exiting threads and wait for them to reach final
+	 * schedule() in do_exit() in order to reclaim as much memory as
+	 * possible and make sure that OOM victims no longer try to trigger
+	 * I/O.
+	 */
+	rcu_read_lock();
+	for_each_process_thread(p, t) {
+		if (frozen(t) &&
+		    (fatal_signal_pending(t) || (t->flags & PF_EXITING))) {
+			task_set_thaw_waiting(t);
+			/*
+			 * Thaw the task because it is frozen.
+			 * freezing_slow_path() will tell the freezer that
+			 * PFA_THAW_WAIT tasks should leave from
+			 * __refrigerator().
+			 */
+			__thaw_task(t);
+			busy = true;
+		}
 	}
-
-	return true;
+	rcu_read_unlock();
+	if (likely(!busy))
+		return true;
+	timeout += jiffies;
+	while (time_before(jiffies, (unsigned long) timeout)) {
+		busy = false;
+		rcu_read_lock();
+		for_each_process_thread(p, t) {
+			if (task_thaw_waiting(t) && t->state != TASK_DEAD) {
+				busy = true;
+				goto out;
+			}
+		}
+out:
+		rcu_read_unlock();
+		if (!busy)
+			return true;
+		schedule_timeout_killable(HZ / 10);
+	}
+	/*
+	 * We thawed at least one killed/exiting threads but failed to wait for
+	 * them to reach final schedule() in do_exit(). Abort operation because
+	 * they might try to trigger I/O.
+	 */
+	oom_killer_enable();
+	return false;
 }
 
 static inline bool __task_will_free_mem(struct task_struct *task)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
