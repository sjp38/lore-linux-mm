Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AE87860023A
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 04:55:58 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o2H8tssu004009
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 09:55:54 +0100
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz5.hot.corp.google.com with ESMTP id o2H8tr47009346
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 01:55:53 -0700
Received: by pzk33 with SMTP id 33so539661pzk.5
        for <linux-mm@kvack.org>; Wed, 17 Mar 2010 01:55:52 -0700 (PDT)
Date: Wed, 17 Mar 2010 01:55:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 09/11 -mm v4] oom: remove unnecessary code and cleanup
In-Reply-To: <alpine.DEB.2.00.1003170151540.31796@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1003170154330.31796@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003170151540.31796@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove the redundancy in __oom_kill_task() since:

 - init can never be passed to this function: it will never be PF_EXITING
   or selectable from select_bad_process(), and

 - it will never be passed a task from oom_kill_task() without an ->mm
   and we're unconcerned about detachment from exiting tasks, there's no
   reason to protect them against SIGKILL or access to memory reserves.

Also moves the kernel log message to a higher level since the verbosity
is not always emitted here; we need not print an error message if an
exiting task is given a longer timeslice.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   64 ++++++++++++++------------------------------------------
 1 files changed, 16 insertions(+), 48 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -412,67 +412,35 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 		dump_tasks(mem);
 }
 
-#define K(x) ((x) << (PAGE_SHIFT-10))
-
 /*
- * Send SIGKILL to the selected  process irrespective of  CAP_SYS_RAW_IO
- * flag though it's unlikely that  we select a process with CAP_SYS_RAW_IO
- * set.
+ * Give the oom killed task high priority and access to memory reserves so that
+ * it may quickly exit and free its memory.
  */
-static void __oom_kill_task(struct task_struct *p, int verbose)
+static void __oom_kill_task(struct task_struct *p)
 {
-	if (is_global_init(p)) {
-		WARN_ON(1);
-		printk(KERN_WARNING "tried to kill init!\n");
-		return;
-	}
-
-	task_lock(p);
-	if (!p->mm) {
-		WARN_ON(1);
-		printk(KERN_WARNING "tried to kill an mm-less task %d (%s)!\n",
-			task_pid_nr(p), p->comm);
-		task_unlock(p);
-		return;
-	}
-
-	if (verbose)
-		printk(KERN_ERR "Killed process %d (%s) "
-		       "vsz:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
-		       task_pid_nr(p), p->comm,
-		       K(p->mm->total_vm),
-		       K(get_mm_counter(p->mm, MM_ANONPAGES)),
-		       K(get_mm_counter(p->mm, MM_FILEPAGES)));
-	task_unlock(p);
-
-	/*
-	 * We give our sacrificial lamb high priority and access to
-	 * all the memory it needs. That way it should be able to
-	 * exit() and clear out its resources quickly...
-	 */
 	p->rt.time_slice = HZ;
 	set_tsk_thread_flag(p, TIF_MEMDIE);
-
 	force_sig(SIGKILL, p);
 }
 
+#define K(x) ((x) << (PAGE_SHIFT-10))
 static int oom_kill_task(struct task_struct *p)
 {
-	/* WARNING: mm may not be dereferenced since we did not obtain its
-	 * value from get_task_mm(p).  This is OK since all we need to do is
-	 * compare mm to q->mm below.
-	 *
-	 * Furthermore, even if mm contains a non-NULL value, p->mm may
-	 * change to NULL at any time since we do not hold task_lock(p).
-	 * However, this is of no concern to us.
-	 */
-	if (!p->mm || p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+	task_lock(p);
+	if (!p->mm || p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+		task_unlock(p);
 		return 1;
+	}
+	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
+		task_pid_nr(p), p->comm, K(p->mm->total_vm),
+	       K(get_mm_counter(p->mm, MM_ANONPAGES)),
+	       K(get_mm_counter(p->mm, MM_FILEPAGES)));
+	task_unlock(p);
 
-	__oom_kill_task(p, 1);
-
+	__oom_kill_task(p);
 	return 0;
 }
+#undef K
 
 static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			    unsigned int points, unsigned long totalpages,
@@ -491,7 +459,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (p->flags & PF_EXITING) {
-		__oom_kill_task(p, 0);
+		__oom_kill_task(p);
 		return 0;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
