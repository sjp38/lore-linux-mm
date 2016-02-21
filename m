Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7E36E6B0005
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 02:15:47 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id q63so74917225pfb.0
        for <linux-mm@kvack.org>; Sat, 20 Feb 2016 23:15:47 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o12si29995101pfi.251.2016.02.20.23.15.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 20 Feb 2016 23:15:46 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: remove shortcuts for SIGKILL and PF_EXITING cases
Date: Sun, 21 Feb 2016 16:14:29 +0900
Message-Id: <1456038869-7874-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, hannes@cmpxchg.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Currently, sending SIGKILL to all user processes sharing the same memory
is omitted by three locations. But they should be removed due to possible
OOM livelock sequence shown below.

About setting TIF_MEMIE on current->mm && fatal_signal_pending(current)
at out_of_memory():

  There are two thread groups named P1 and P2 that are created using
  clone(!CLONE_SIGHAND && CLONE_VM) and one independent thread group
  named P3. A sequence shown below is possible.

  ----------
  P1             P2             P3
  Do something that invokes a __GFP_FS memory allocation (e.g. page fault).
                 Calls mmap().
                                Calls kill(P1, SIGKILL).
                 Arrives at vm_mmap_pgoff().
                 Calls down_write(&mm->mmap_sem).
                                Sends SIGKILL to P1.
  fatal_signal_pending(P1) becomes true.
                 Calls do_mmap_pgoff().
  Calls out_of_memory().
  Gets TIF_MEMDIE.
                 Calls out_of_memory().
                 oom_scan_process_thread() returns OOM_SCAN_ABORT.
  Arrives at do_exit().
  Calls down_read(&mm->mmap_sem) at exit_mm().
                 oom_scan_process_thread() still returns OOM_SCAN_ABORT.
  ----------

  P1 is waiting for P2 to call up_write(&mm->mmap_sem) but P2 won't
  give up memory allocation because fatal_signal_pending(P2) is false.
  This race condition can be avoided if P1 sent SIGKILL to P2 when
  P1 called out_of_memory().

About setting TIF_MEMIE on current->mm && task_will_free_mem(current)
at out_of_memory():

  There are two thread groups named P1 and P2 that are created using
  clone(!CLONE_SIGHAND && CLONE_VM). A sequence shown below is possible.

  ----------
  P1             P2
  Calls _exit(0).
                 Calls mmap().
                 Arrives at vm_mmap_pgoff().
                 Calls down_write(&mm->mmap_sem).
  Arrives at do_exit().
  Gets PF_EXITING via exit_signals().
  Calls tty_audit_exit().
  Do a GFP_KERNEL allocation from tty_audit_log().
  Calls out_of_memory().
  Gets TIF_MEMDIE.
                 Calls out_of_memory().
                 oom_scan_process_thread() returns OOM_SCAN_ABORT.
  Calls down_read(&mm->mmap_sem) at exit_mm().
                 oom_scan_process_thread() still returns OOM_SCAN_ABORT.
  ----------

  P1 is waiting for P2 to call up_write(&mm->mmap_sem) but P2 won't
  give up memory allocation because fatal_signal_pending(P2) is false.
  This race condition can be avoided if P1 sent SIGKILL to P2 when
  P1 called out_of_memory().

About setting TIF_MEMIE on p->mm && task_will_free_mem(p)
at oom_kill_process():

  There are two thread groups named P1 and P2 that are created using
  clone(!CLONE_SIGHAND && CLONE_VM) and one independent thread group
  named P3. A sequence shown below is possible.

  ----------
  P1             P2
  Calls _exit(0).
                 Calls mmap().
                 Arrives at vm_mmap_pgoff().
                 Calls down_write(&mm->mmap_sem).
  Arrives at do_exit().
  Gets PF_EXITING via exit_signals().
  Calls down_read(&mm->mmap_sem) at exit_mm().
                 Calls do_mmap_pgoff().
                 Calls out_of_memory().
                 select_bad_process() returns P1.
                 oom_kill_process() sets TIF_MEMDIE on P1.
                 oom_scan_process_thread() returns OOM_SCAN_ABORT.
  ----------

  P1 is waiting for P2 to call up_write(&mm->mmap_sem) but P2 won't
  give up memory allocation because fatal_signal_pending(P2) is false.
  This race condition can be avoided if P2 sent SIGKILL to P2 when
  P2 called out_of_memory().

About setting TIF_MEMIE on fatal_signal_pending(current)
at mem_cgroup_out_of_memory():

  mem_cgroup_out_of_memory() is called from a lockless context via
  mem_cgroup_oom_synchronize() called from pagefault_out_of_memory()
  is talking about only current thread. If global OOM condition follows
  before memcg OOM condition is solved, the same problem will occur.

About setting TIF_MEMIE on task_will_free_mem(current)
at mem_cgroup_out_of_memory():

  I don't know whether it is possible to call mem_cgroup_out_of_memory()
  between getting PF_EXITING and doing current->mm = NULL. But if it is
  possible to call, then the same problem will occur.

And since removing these shortcuts breaks a wrong and optimistic
assumption in oom_kill_process()

  /*
   * Kill all user processes sharing victim->mm in other thread groups, if
   * any.  They don't get access to memory reserves, though, to avoid
   * depletion of all memory.  This prevents mm->mmap_sem livelock when an
   * oom killed thread cannot exit because it requires the semaphore and
   * its contended by another thread trying to allocate memory itself.
   * That thread will now get access to memory reserves since it has a
   * pending fatal signal.
   */

set TIF_MEMDIE on all threads in thread groups which got SIGKILL by
the OOM killer. This will help getting threads doing !__GFP_FS allocations
which are not allowed to call out_of_memory() (which will set TIF_MEMDIE
via current->mm && fatal_signal_pending(current) case).

Ideally p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN thread groups
need to get SIGKILL and TIF_MEMDIE as well because it is possible that
one of threads in such thread groups are holding mm->mmap_sem lock for
write.

Of course, situations described in this patch are corner cases. But
since we are not going to add memory allocation watchdog mechanism nor
timeout based next OOM victim selection logic, we need to eliminate
all possible corner cases. Silent OOM livelock is really annoying.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/memcontrol.c | 10 ----------
 mm/oom_kill.c   | 46 ++++++++++------------------------------------
 2 files changed, 10 insertions(+), 46 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae8b81c..390ec2c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1253,16 +1253,6 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 	mutex_lock(&oom_lock);
 
-	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
-	 * select it.  The goal is to allow it to allocate so that it may
-	 * quickly exit and free its memory.
-	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		goto unlock;
-	}
-
 	check_panic_on_oom(&oc, CONSTRAINT_MEMCG, memcg);
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d7bb9c1..5e8563a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -684,19 +684,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap = true;
 
-	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
-	 */
-	task_lock(p);
-	if (p->mm && task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		task_unlock(p);
-		put_task_struct(p);
-		return;
-	}
-	task_unlock(p);
-
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p, memcg);
 
@@ -759,20 +746,15 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	task_unlock(victim);
 
 	/*
-	 * Kill all user processes sharing victim->mm in other thread groups, if
-	 * any.  They don't get access to memory reserves, though, to avoid
-	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
-	 * oom killed thread cannot exit because it requires the semaphore and
-	 * its contended by another thread trying to allocate memory itself.
-	 * That thread will now get access to memory reserves since it has a
-	 * pending fatal signal.
+	 * Kill all user processes sharing victim->mm. This reduces possibility
+	 * of hitting mm->mmap_sem livelock when an oom killed thread cannot
+	 * exit because it requires the semaphore and its contended by another
+	 * thread trying to allocate memory itself.
 	 */
 	rcu_read_lock();
 	for_each_process(p) {
 		if (!process_shares_mm(p, mm))
 			continue;
-		if (same_thread_group(p, victim))
-			continue;
 		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
 		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
 			/*
@@ -784,6 +766,12 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		}
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+		for_each_thread(p, t) {
+			task_lock(t);
+			if (t->mm)
+				mark_oom_victim(t);
+			task_unlock(t);
+		}
 	}
 	rcu_read_unlock();
 
@@ -860,20 +848,6 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 
 	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
-	 * select it.  The goal is to allow it to allocate so that it may
-	 * quickly exit and free its memory.
-	 *
-	 * But don't select if current has already released its mm and cleared
-	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
-	 */
-	if (current->mm &&
-	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
-		mark_oom_victim(current);
-		return true;
-	}
-
-	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
