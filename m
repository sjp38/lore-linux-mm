Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id BCE5E6B006E
	for <linux-mm@kvack.org>; Sun, 31 May 2015 07:10:27 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so25758982pdb.2
        for <linux-mm@kvack.org>; Sun, 31 May 2015 04:10:27 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c4si16695010pdf.49.2015.05.31.04.10.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 31 May 2015 04:10:26 -0700 (PDT)
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201505280659.HBE69765.SOtQMJLVFHFFOO@I-love.SAKURA.ne.jp>
	<20150528180524.GB2321@dhcp22.suse.cz>
	<201505292140.JHE18273.SFFMJFHOtQLOVO@I-love.SAKURA.ne.jp>
	<20150529144922.GE22728@dhcp22.suse.cz>
	<201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
In-Reply-To: <201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
Message-Id: <201505312010.JJJ26561.FJOOVSQHLFOtMF@I-love.SAKURA.ne.jp>
Date: Sun, 31 May 2015 20:10:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> So I think, but I have to think more about this, a proper way to handle
> this would be something like the following. The patch is obviously
> incomplete because memcg OOM killer would need the same treatment which
> calls for a common helper etc...

I believe that current out_of_memory() code is too optimistic about exiting
task. Current code can easily result in either

  (1) silent hang up due to reporting nothing upon OOM deadlock
  (2) very noisy oom_kill_process() due to re-reporting the same mm struct

because we set TIF_MEMDIE to only one thread.

To avoid (1), we should remove

	/*
	 * If current has a pending SIGKILL or is exiting, then automatically
	 * select it.  The goal is to allow it to allocate so that it may
	 * quickly exit and free its memory.
	 *
	 * But don't select if current has already released its mm and cleared
	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
	 */
	if (current->mm &&
	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
		mark_oom_victim(current);
		goto out;
	}

in out_of_memory() and

	/*
	 * If the task is already exiting, don't alarm the sysadmin or kill
	 * its children or threads, just set TIF_MEMDIE so it can die quickly
	 */
	task_lock(p);
	if (p->mm && task_will_free_mem(p)) {
		mark_oom_victim(p);
		task_unlock(p);
		put_task_struct(p);
		return;
	}
	task_unlock(p);

in oom_kill_process() which set TIF_MEMDIE to only one thread.
Removing the former chunk helps when check_panic_on_oom() is configured to
call panic() (i.e. /proc/sys/vm/panic_on_oom is not 0) and then the system
fell into TIF_MEMDIE deadlock, for their systems will be rebooted
automatically than entering into silent hang up loop upon OOM condition.

To avoid (2), we should consider either

  (a) Add a bool to "struct mm_struct" and set that bool to true when that
      mm struct was chosen for the first time. Set TIF_MEMDIE to next thread
      without calling printk() unless that mm was chosen for the first time.

  (b) Set TIF_MEMDIE to all threads in all processes sharing the same mm
      struct, making oom_scan_process_thread() return OOM_SCAN_ABORT as
      long as there is a TIF_MEMDIE thread.

Untested patch for (a) would look like
------------------------------------------------------------
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2836da7..b43e523 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -495,6 +495,7 @@ struct mm_struct {
 	/* address of the bounds directory */
 	void __user *bd_addr;
 #endif
+	bool oom_report_done;
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dff991e..bb31a11 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -497,6 +497,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	struct task_struct *t;
 	struct mm_struct *mm;
 	unsigned int victim_points = 0;
+	bool silent;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 
@@ -513,6 +514,12 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	}
 	task_unlock(p);
 
+	task_lock(p);
+	silent = (p->mm && p->mm->oom_report_done);
+	task_unlock(p);
+	if (silent)
+		goto silent_mode;
+
 	if (__ratelimit(&oom_rs))
 		dump_header(p, gfp_mask, order, memcg, nodemask);
 
@@ -521,6 +528,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		message, task_pid_nr(p), p->comm, points);
 	task_unlock(p);
 
+ silent_mode:
 	/*
 	 * If any of p's children has a different mm and is eligible for kill,
 	 * the one with the highest oom_badness() score is sacrificed for its
@@ -561,6 +569,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
+	mm->oom_report_done = true;
 	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
@@ -584,10 +593,12 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 				continue;
 
-			task_lock(p);	/* Protect ->comm from prctl() */
-			pr_err("Kill process %d (%s) sharing same memory\n",
-				task_pid_nr(p), p->comm);
-			task_unlock(p);
+			if (!silent) {
+				task_lock(p);	/* Protect ->comm from prctl() */
+				pr_err("Kill process %d (%s) sharing same memory\n",
+				       task_pid_nr(p), p->comm);
+				task_unlock(p);
+			}
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 		}
 	rcu_read_unlock();
------------------------------------------------------------

Untested patch for (b) would look like
------------------------------------------------------------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dff991e..8e47a1c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -581,6 +581,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	for_each_process(p)
 		if (p->mm == mm && !same_thread_group(p, victim) &&
 		    !(p->flags & PF_KTHREAD)) {
+			struct task_struct *t;
+
 			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 				continue;
 
@@ -589,6 +591,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 				task_pid_nr(p), p->comm);
 			task_unlock(p);
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+			for_each_thread(p, t)
+				mark_oom_victim(t);
 		}
 	rcu_read_unlock();
 
------------------------------------------------------------

If we forget about complete depletion of all memory, (b) is preferable from
the point of view of reducing the possibility of falling into TIF_MEMDIE
deadlock.

The TIF_MEMDIE is meant to facilitate setting tsk->mm = NULL so that memory
associated with the TIF_MEMDIE thread's mm struct is released soon. But the
algorithm for choosing a thread does not (more precisely, can not) take lock
dependency into account. There are locations where down_read(&tsk->mm->mmap_sem)
and up_read(&tsk->mm->mmap_sem) are called between getting PF_EXITING and
setting tsk->mm = NULL. Also, there are locations where memory allocations
are done between down_write(&current->mm->mmap_sem) and
up_write(&current->mm->mmap_sem). As a result, TIF_MEMDIE can be set to
a thread which is waiting at e.g. down_read(&current->mm->mmap_sem) when one
of threads sharing the same mm struct is doing memory allocations between
down_write(&current->mm->mmap_sem) and up_write(&current->mm->mmap_sem).
When such case occurred, the TIF_MEMDIE thread can not be terminated because
memory allocation by non-TIF_MEMDIE thread cannot complete until
non-TIF_MEMDIE thread gets TIF_MEMDIE (assuming that the "too small to fail"
memory-allocation rule remains due to reasons explained at
http://marc.info/?l=linux-mm&m=143239200805478 ). It seems to me that the
description

  This prevents mm->mmap_sem livelock when an oom killed thread cannot exit
  because it requires the semaphore and its contended by another thread
  trying to allocate memory itself.

is not true, for sending SIGKILL cannot make another thread to return from
memory allocation attempt.



By the way, I got two mumbles.

Is "If any of p's children has a different mm and is eligible for kill," logic
in oom_kill_process() really needed? Didn't select_bad_process() which was
called proior to calling oom_kill_process() already choose a best victim
using for_each_process_thread() ?

Is "/* mm cannot safely be dereferenced after task_unlock(victim) */" true?
It seems to me that it should be "/* mm cannot safely be compared after
task_unlock(victim) */" because it is theoretically possible to have

  CPU 0                         CPU 1                   CPU 2
  task_unlock(victim);
                                victim exits and releases mm.
                                Usage count of the mm becomes 0 and thus released.
                                                        New mm is allocated and assigned to some thread.
  (p->mm == mm) matches the recreated mm and kill unrelated p.

sequence. We need to either get a reference to victim's mm before
task_unlock(victim) or do comparison before task_unlock(victim).

Below is just a guess which incorporated all changes described above.

------------------------------------------------------------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dff991e..9bf9370 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -487,67 +487,20 @@ void oom_killer_enable(void)
  * Must be called while holding a reference to p, which will be released upon
  * returning.
  */
-void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
+void oom_kill_process(struct task_struct *victim, gfp_t gfp_mask, int order,
 		      unsigned int points, unsigned long totalpages,
 		      struct mem_cgroup *memcg, nodemask_t *nodemask,
 		      const char *message)
 {
-	struct task_struct *victim = p;
-	struct task_struct *child;
+	struct task_struct *p;
 	struct task_struct *t;
+	unsigned int killed = 0;
 	struct mm_struct *mm;
-	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 
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
-		dump_header(p, gfp_mask, order, memcg, nodemask);
-
-	task_lock(p);
-	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
-		message, task_pid_nr(p), p->comm, points);
-	task_unlock(p);
-
-	/*
-	 * If any of p's children has a different mm and is eligible for kill,
-	 * the one with the highest oom_badness() score is sacrificed for its
-	 * parent.  This attempts to lose the minimal amount of work done while
-	 * still freeing memory.
-	 */
-	read_lock(&tasklist_lock);
-	for_each_thread(p, t) {
-		list_for_each_entry(child, &t->children, sibling) {
-			unsigned int child_points;
-
-			if (child->mm == p->mm)
-				continue;
-			/*
-			 * oom_badness() returns 0 if the thread is unkillable
-			 */
-			child_points = oom_badness(child, memcg, nodemask,
-								totalpages);
-			if (child_points > victim_points) {
-				put_task_struct(victim);
-				victim = child;
-				victim_points = child_points;
-				get_task_struct(victim);
-			}
-		}
-	}
-	read_unlock(&tasklist_lock);
+		dump_header(victim, gfp_mask, order, memcg, nodemask);
 
 	p = find_lock_task_mm(victim);
 	if (!p) {
@@ -558,41 +511,24 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		put_task_struct(victim);
 		victim = p;
 	}
-
-	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
-	mark_oom_victim(victim);
-	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
-		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
-		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
-	task_unlock(victim);
-
-	/*
-	 * Kill all user processes sharing victim->mm in other thread groups, if
-	 * any.  They don't get access to memory reserves, though, to avoid
-	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
-	 * oom killed thread cannot exit because it requires the semaphore and
-	 * its contended by another thread trying to allocate memory itself.
-	 * That thread will now get access to memory reserves since it has a
-	 * pending fatal signal.
-	 */
 	rcu_read_lock();
 	for_each_process(p)
-		if (p->mm == mm && !same_thread_group(p, victim) &&
-		    !(p->flags & PF_KTHREAD)) {
-			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-				continue;
-
-			task_lock(p);	/* Protect ->comm from prctl() */
-			pr_err("Kill process %d (%s) sharing same memory\n",
-				task_pid_nr(p), p->comm);
-			task_unlock(p);
+		if (p->mm == mm && !(p->flags & PF_KTHREAD) &&
+		    p->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+			killed++;
+			for_each_thread(p, t)
+				mark_oom_victim(t);
 		}
 	rcu_read_unlock();
-
-	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
+	pr_err("%s: Kill process %d (%s) score %u, total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
+	       message, task_pid_nr(p), p->comm, points, K(mm->total_vm),
+	       K(get_mm_counter(mm, MM_ANONPAGES)),
+	       K(get_mm_counter(mm, MM_FILEPAGES)));
+	if (killed > 1)
+		pr_err("Killed %u processes sharing same memory\n", killed);
+	task_unlock(victim);
 	put_task_struct(victim);
 }
 #undef K
@@ -667,20 +603,6 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		goto out;
 
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
-		goto out;
-	}
-
-	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
------------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
