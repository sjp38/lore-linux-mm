Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id D81016B005A
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 19:39:15 -0500 (EST)
Received: by yhoo21 with SMTP id o21so643068yho.14
        for <linux-mm@kvack.org>; Fri, 13 Jan 2012 16:39:15 -0800 (PST)
Date: Fri, 13 Jan 2012 16:39:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 2/3] mm, oom: fold oom_kill_task into oom_kill_process
In-Reply-To: <alpine.DEB.2.00.1201131638020.9310@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1201131638280.9310@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1201111922500.3982@chino.kir.corp.google.com> <alpine.DEB.2.00.1201131638020.9310@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

oom_kill_task() has a single caller, so fold it into its parent function,
oom_kill_process().  Slightly reduces the number of lines in the oom
killer.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   85 +++++++++++++++++++++++++-------------------------------
 1 files changed, 38 insertions(+), 47 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -434,52 +434,6 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
-static void oom_kill_task(struct task_struct *p)
-{
-	struct task_struct *q;
-	struct mm_struct *mm;
-
-	p = find_lock_task_mm(p);
-	if (!p)
-		return;
-
-	/* mm cannot be safely dereferenced after task_unlock(p) */
-	mm = p->mm;
-
-	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
-		task_pid_nr(p), p->comm, K(p->mm->total_vm),
-		K(get_mm_counter(p->mm, MM_ANONPAGES)),
-		K(get_mm_counter(p->mm, MM_FILEPAGES)));
-	task_unlock(p);
-
-	/*
-	 * Kill all user processes sharing p->mm in other thread groups, if any.
-	 * They don't get access to memory reserves or a higher scheduler
-	 * priority, though, to avoid depletion of all memory or task
-	 * starvation.  This prevents mm->mmap_sem livelock when an oom killed
-	 * task cannot exit because it requires the semaphore and its contended
-	 * by another thread trying to allocate memory itself.  That thread will
-	 * now get access to memory reserves since it has a pending fatal
-	 * signal.
-	 */
-	for_each_process(q)
-		if (q->mm == mm && !same_thread_group(q, p) &&
-		    !(q->flags & PF_KTHREAD)) {
-			if (q->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-				continue;
-
-			task_lock(q);	/* Protect ->comm from prctl() */
-			pr_err("Kill process %d (%s) sharing same memory\n",
-				task_pid_nr(q), q->comm);
-			task_unlock(q);
-			force_sig(SIGKILL, q);
-		}
-
-	set_tsk_thread_flag(p, TIF_MEMDIE);
-	force_sig(SIGKILL, p);
-}
-#undef K
-
 static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			     unsigned int points, unsigned long totalpages,
 			     struct mem_cgroup *memcg, nodemask_t *nodemask,
@@ -488,6 +442,7 @@ static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	struct task_struct *victim = p;
 	struct task_struct *child;
 	struct task_struct *t = p;
+	struct mm_struct *mm;
 	unsigned int victim_points = 0;
 
 	if (printk_ratelimit())
@@ -531,8 +486,44 @@ static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		}
 	} while_each_thread(p, t);
 
-	oom_kill_task(victim);
+	victim = find_lock_task_mm(victim);
+	if (!victim)
+		return;
+
+	/* mm cannot safely be dereferenced after task_unlock(victim) */
+	mm = victim->mm;
+	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
+		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
+		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
+		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
+	task_unlock(victim);
+
+	/*
+	 * Kill all user processes sharing victim->mm in other thread groups, if
+	 * any.  They don't get access to memory reserves, though, to avoid
+	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
+	 * oom killed thread cannot exit because it requires the semaphore and
+	 * its contended by another thread trying to allocate memory itself.
+	 * That thread will now get access to memory reserves since it has a
+	 * pending fatal signal.
+	 */
+	for_each_process(p)
+		if (p->mm == mm && !same_thread_group(p, victim) &&
+		    !(p->flags & PF_KTHREAD)) {
+			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+				continue;
+
+			task_lock(p);	/* Protect ->comm from prctl() */
+			pr_err("Kill process %d (%s) sharing same memory\n",
+				task_pid_nr(p), p->comm);
+			task_unlock(p);
+			force_sig(SIGKILL, p);
+		}
+
+	set_tsk_thread_flag(victim, TIF_MEMDIE);
+	force_sig(SIGKILL, victim);
 }
+#undef K
 
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
