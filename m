Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 656F06B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:25:08 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id z8so7496451ige.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:25:08 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 9si24826147igz.69.2016.02.23.05.25.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Feb 2016 05:25:07 -0800 (PST)
Subject: Re: [PATCH] mm,oom: remove shortcuts for SIGKILL and PF_EXITING cases
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1456038869-7874-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1602221645260.4688@chino.kir.corp.google.com>
	<201602231938.IFI64693.JSQFOOFVFLHtMO@I-love.SAKURA.ne.jp>
In-Reply-To: <201602231938.IFI64693.JSQFOOFVFLHtMO@I-love.SAKURA.ne.jp>
Message-Id: <201602232224.FEJ69269.LMVJOFFOQSHtFO@I-love.SAKURA.ne.jp>
Date: Tue, 23 Feb 2016 22:24:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: mhocko@kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

Tetsuo Handa wrote:
> > No, NACK.  You cannot prohibit an exiting process from gaining access to 
> > memory reserves and randomly killing another process without additional 
> > chances of a livelock.  The goal is for an exiting or killed process to 
> > be able to exit so it can free its memory, not kill additional processes.
> 
> I know what these shortcuts are trying to do. I'm pointing out that these
> shortcuts have a chance of silent OOM livelock. If we preserve these shortcuts,
> we had better not to wait forever. We need to kill additional processes if
> exiting or killed process seems to got stuck.
> 
> Same with http://lkml.kernel.org/r/20160217143917.GP29196@dhcp22.suse.cz .
> 
Or, can we accept something like below?
--------------------------------------------------------------------------------
>From 3a9231486624ad34bbf84f9798523c05f5d401d5 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 23 Feb 2016 22:04:49 +0900
Subject: [PATCH] mm,oom: check mmap_sem lockability when using shortcuts for
 SIGKILL and PF_EXITING cases

Currently, oom_scan_process_thread() returns OOM_SCAN_ABORT when there is
a thread which is exiting. But it is possible that that thread is blocked
at down_read(&mm->mmap_sem) in exit_mm() called from do_exit() whereas
one of threads sharing that memory is doing a GFP_KERNEL allocation
between down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem)
(e.g. mmap()).

----------
T1                  T2
                    Calls mmap()
Calls _exit(0)
                    Arrives at vm_mmap_pgoff()
Arrives at do_exit()
Gets PF_EXITING via exit_signals()
                    Calls down_write(&mm->mmap_sem)
                    Calls do_mmap_pgoff()
Calls down_read(&mm->mmap_sem) from exit_mm()
                    Calls out of memory via a GFP_KERNEL allocation but
                    oom_scan_process_thread(T1) returns OOM_SCAN_ABORT
----------

down_read(&mm->mmap_sem) by T1 is waiting for up_write(&mm->mmap_sem) by
T2 while oom_scan_process_thread() by T2 is waiting for T1 to set
T1->mm = NULL. Under such situation, the OOM killer does not choose
a victim, which results in silent OOM livelock problem.

Also, sending SIGKILL to all user processes sharing the same memory is
omitted by three locations.

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

About setting TIF_MEMIE on current->mm && task_will_free_mem(current)
at out_of_memory():

  There are two thread groups named P1 and P2 that are created using
  clone(CLONE_VM). A sequence shown below is possible.

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

About setting TIF_MEMIE on p->mm && task_will_free_mem(p)
at oom_kill_process():

  There are two thread groups named P1 and P2 that are created using
  clone(CLONE_VM). A sequence shown below is possible.

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

This patch checks whether the mm of a thread which the caller of
out_of_memory() is trying to wait for termination can be locked for read,
in order to avoid silent OOM livelock.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h |  1 +
 mm/memcontrol.c     |  3 ++-
 mm/oom_kill.c       | 39 ++++++++++++++++++++++++++++++---------
 3 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 45993b8..efd7aa5 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -86,6 +86,7 @@ extern void check_panic_on_oom(struct oom_control *oc,
 			       enum oom_constraint constraint,
 			       struct mem_cgroup *memcg);
 
+extern bool task_can_read_lock_mm(struct task_struct *tsk);
 extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 		struct task_struct *task, unsigned long totalpages);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae8b81c..c0dca1b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1258,7 +1258,8 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
+	if ((fatal_signal_pending(current) || task_will_free_mem(current)) &&
+	    task_can_read_lock_mm(current)) {
 		mark_oom_victim(current);
 		goto unlock;
 	}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d7bb9c1..8a27967 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -268,6 +268,22 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 }
 #endif
 
+bool task_can_read_lock_mm(struct task_struct *tsk)
+{
+	struct mm_struct *mm;
+	bool ret = false;
+
+	task_lock(tsk);
+	mm = tsk->mm;
+	if (mm && down_read_trylock(&mm->mmap_sem)) {
+		up_read(&mm->mmap_sem);
+		ret = true;
+	}
+	task_unlock(tsk);
+	return ret;
+}
+
+
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 			struct task_struct *task, unsigned long totalpages)
 {
@@ -278,7 +294,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves.
 	 */
-	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
+	if (test_tsk_thread_flag(task, TIF_MEMDIE) &&
+	    task_can_read_lock_mm(task)) {
 		if (!is_sysrq_oom(oc))
 			return OOM_SCAN_ABORT;
 	}
@@ -292,7 +309,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	if (oom_task_origin(task))
 		return OOM_SCAN_SELECT;
 
-	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
+	if (task_will_free_mem(task) && !is_sysrq_oom(oc) &&
+	    task_can_read_lock_mm(task))
 		return OOM_SCAN_ABORT;
 
 	return OOM_SCAN_OK;
@@ -688,14 +706,16 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
-	task_lock(p);
-	if (p->mm && task_will_free_mem(p)) {
-		mark_oom_victim(p);
+	if (task_can_read_lock_mm(p)) {
+		task_lock(p);
+		if (p->mm && task_will_free_mem(p)) {
+			mark_oom_victim(p);
+			task_unlock(p);
+			put_task_struct(p);
+			return;
+		}
 		task_unlock(p);
-		put_task_struct(p);
-		return;
 	}
-	task_unlock(p);
 
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p, memcg);
@@ -868,7 +888,8 @@ bool out_of_memory(struct oom_control *oc)
 	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
 	if (current->mm &&
-	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
+	    (fatal_signal_pending(current) || task_will_free_mem(current)) &&
+	    task_can_read_lock_mm(current)) {
 		mark_oom_victim(current);
 		return true;
 	}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
