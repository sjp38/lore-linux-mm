Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E24236B01D4
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:33:27 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U9XP4s018185
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 18:33:25 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 45A8E45DE6F
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:33:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 18B6345DE60
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:33:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E97011DB8044
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:33:24 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 807EB1DB8041
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:33:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 10/11] oom: give the dying task a higher priority
In-Reply-To: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
Message-Id: <20100630183243.AA65.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Jun 2010 18:33:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

From: Luis Claudio R. Goncalves <lclaudio@uudg.org>

In a system under heavy load it was observed that even after the
oom-killer selects a task to die, the task may take a long time to die.

Right after sending a SIGKILL to the task selected by the oom-killer
this task has it's priority increased so that it can exit() exit soon,
freeing memory. That is accomplished by:

        /*
         * We give our sacrificial lamb high priority and access to
         * all the memory it needs. That way it should be able to
         * exit() and clear out its resources quickly...
         */
 	p->rt.time_slice = HZ;
 	set_tsk_thread_flag(p, TIF_MEMDIE);

It sounds plausible giving the dying task an even higher priority to be
sure it will be scheduled sooner and free the desired memory. It was
suggested on LKML using SCHED_FIFO:1, the lowest RT priority so that
this task won't interfere with any running RT task.

If the dying task is already an RT task, leave it untouched.
Another good suggestion, implemented here, was to avoid boosting the
dying task priority in case of mem_cgroup OOM.

Signed-off-by: Luis Claudio R. Goncalves <lclaudio@uudg.org>
Cc: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   34 +++++++++++++++++++++++++++++++---
 1 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b5678bf..0858b18 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -82,6 +82,24 @@ static bool has_intersects_mems_allowed(struct task_struct *tsk,
 #endif /* CONFIG_NUMA */
 
 /*
+ * If this is a system OOM (not a memcg OOM) and the task selected to be
+ * killed is not already running at high (RT) priorities, speed up the
+ * recovery by boosting the dying task to the lowest FIFO priority.
+ * That helps with the recovery and avoids interfering with RT tasks.
+ */
+static void boost_dying_task_prio(struct task_struct *p,
+				  struct mem_cgroup *mem)
+{
+	struct sched_param param = { .sched_priority = 1 };
+
+	if (mem)
+		return;
+
+	if (!rt_task(p))
+		sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
+}
+
+/*
  * The process p may have detached its own ->mm while exiting or through
  * use_mm(), but one or more of its subthreads may still have a valid
  * pointer.  Return p, or any of its subthreads with a valid ->mm, with
@@ -421,7 +439,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
-static int oom_kill_task(struct task_struct *p)
+static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 {
 	p = find_lock_task_mm(p);
 	if (!p) {
@@ -434,9 +452,17 @@ static int oom_kill_task(struct task_struct *p)
 		K(get_mm_counter(p->mm, MM_FILEPAGES)));
 	task_unlock(p);
 
-	p->rt.time_slice = HZ;
+
 	set_tsk_thread_flag(p, TIF_MEMDIE);
 	force_sig(SIGKILL, p);
+
+	/*
+	 * We give our sacrificial lamb high priority and access to
+	 * all the memory it needs. That way it should be able to
+	 * exit() and clear out its resources quickly...
+	 */
+	boost_dying_task_prio(p, mem);
+
 	return 0;
 }
 #undef K
@@ -460,6 +486,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 */
 	if (p->flags & PF_EXITING) {
 		set_tsk_thread_flag(p, TIF_MEMDIE);
+		boost_dying_task_prio(p, mem);
 		return 0;
 	}
 
@@ -489,7 +516,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		}
 	} while_each_thread(p, t);
 
-	return oom_kill_task(victim);
+	return oom_kill_task(victim, mem);
 }
 
 /*
@@ -670,6 +697,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 */
 	if (fatal_signal_pending(current)) {
 		set_thread_flag(TIF_MEMDIE);
+		boost_dying_task_prio(current, NULL);
 		return;
 	}
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
