Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D4F876B01C1
	for <linux-mm@kvack.org>; Sun, 30 May 2010 22:16:10 -0400 (EDT)
Received: by pvc21 with SMTP id 21so1476521pvc.14
        for <linux-mm@kvack.org>; Sun, 30 May 2010 19:16:09 -0700 (PDT)
Date: Sun, 30 May 2010 23:15:59 -0300
From: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100531021559.GA19784@uudg.org>
References: <20100528154549.GC12035@barrios-desktop>
 <20100528164826.GJ11364@uudg.org>
 <20100529125136.62CA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100529125136.62CA.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Sat, May 29, 2010 at 12:59:09PM +0900, KOSAKI Motohiro wrote:
| Hi
| 
| > oom-killer: give the dying task rt priority (v3)
| > 
| > Give the dying task RT priority so that it can be scheduled quickly and die,
| > freeing needed memory.
| > 
| > Signed-off-by: Luis Claudio R. Goncalves <lgoncalv@redhat.com>
| 
| Almostly acceptable to me. but I have two requests, 
| 
| - need 1) force_sig() 2)sched_setscheduler() order as Oleg mentioned
| - don't boost priority if it's in mem_cgroup_out_of_memory()
| 
| Can you accept this? if not, can you please explain the reason?
| 
| Thanks.

The last patch I posted was the wrong patch from my queue. Sorry for the
confusion. Here is the last version of the patch, including the suggestions
from Oleg, Peter and Kosaki Motohiro:


oom-kill: give the dying task a higher priority (v4)

In a system under heavy load it was observed that even after the
oom-killer selects a task to die, the task may take a long time to die.

Right before sending a SIGKILL to the task selected by the oom-killer
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
suggested on LKML using SCHED_FIFO:1, the lowest RT priority so that this
task won't interfere with any running RT task.

Another good suggestion, implemented here, was to avoid boosting the dying
task priority in case of mem_cgroup OOM.

Signed-off-by: Luis Claudio R. Goncalves <lclaudio@uudg.org>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 709aedf..6a25293 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -380,7 +380,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
  * flag though it's unlikely that  we select a process with CAP_SYS_RAW_IO
  * set.
  */
-static void __oom_kill_task(struct task_struct *p, int verbose)
+static void __oom_kill_task(struct task_struct *p, struct mem_cgroup *mem,
+								int verbose)
 {
 	if (is_global_init(p)) {
 		WARN_ON(1);
@@ -413,11 +414,20 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
 	 */
 	p->rt.time_slice = HZ;
 	set_tsk_thread_flag(p, TIF_MEMDIE);
-
 	force_sig(SIGKILL, p);
+	/*
+	 * If this is a system OOM (not a memcg OOM), speed up the recovery
+	 * by boosting the dying task priority to the lowest FIFO priority.
+	 * That helps with the recovery and avoids interfering with RT tasks.
+	 */
+	if (mem == NULL) {
+		struct sched_param param;
+		param.sched_priority = 1;
+		sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
+	}
 }
 
-static int oom_kill_task(struct task_struct *p)
+static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 {
 	/* WARNING: mm may not be dereferenced since we did not obtain its
 	 * value from get_task_mm(p).  This is OK since all we need to do is
@@ -430,7 +440,7 @@ static int oom_kill_task(struct task_struct *p)
 	if (!p->mm || p->signal->oom_adj == OOM_DISABLE)
 		return 1;
 
-	__oom_kill_task(p, 1);
+	__oom_kill_task(p, mem, 1);
 
 	return 0;
 }
@@ -449,7 +459,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (p->flags & PF_EXITING) {
-		__oom_kill_task(p, 0);
+		__oom_kill_task(p, mem, 0);
 		return 0;
 	}
 
@@ -462,10 +472,10 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			continue;
 		if (mem && !task_in_mem_cgroup(c, mem))
 			continue;
-		if (!oom_kill_task(c))
+		if (!oom_kill_task(c, mem))
 			return 0;
 	}
-	return oom_kill_task(p);
+	return oom_kill_task(p, mem);
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR

-- 
[ Luis Claudio R. Goncalves                    Bass - Gospel - RT ]
[ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9  2696 7203 D980 A448 C8F8 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
