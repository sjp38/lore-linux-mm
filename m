Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0E9B16B01D1
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 13:35:47 -0400 (EDT)
Received: by gwb15 with SMTP id 15so1039621gwb.14
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 10:35:46 -0700 (PDT)
Date: Tue, 1 Jun 2010 14:35:35 -0300
From: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100601173535.GD23428@uudg.org>
References: <20100528164826.GJ11364@uudg.org>
 <20100531092133.73705339.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTikFk_HnZWPG0s_VrRkro2rruEc8OBX5KfKp_QdX@mail.gmail.com>
 <20100531140443.b36a4f02.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTil75ziCd6bivhpmwojvhaJ2LVxwEaEaBEmZf2yN@mail.gmail.com>
 <20100531145415.5e53f837.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTilcuY5e1DNmLhUWfXtiQgPUafz2zRTUuTVl-88l@mail.gmail.com>
 <20100531155102.9a122772.kamezawa.hiroyu@jp.fujitsu.com>
 <20100531135227.GC19784@uudg.org>
 <20100601085006.f732c049.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100601085006.f732c049.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 01, 2010 at 08:50:06AM +0900, KAMEZAWA Hiroyuki wrote:
| On Mon, 31 May 2010 10:52:27 -0300
| "Luis Claudio R. Goncalves" <lclaudio@uudg.org> wrote:
| 
| > | If an explanation as "acceralating all thread's priority in a process seems overkill"
| > | is given in changelog or comment, it's ok to me.
| > 
| > If my understanding of badness() is right, I wouldn't be ashamed of saying
| > that it seems to be _a bit_ overkill. But I may be wrong in my
| > interpretation.
| > 
| > While re-reading the code I noticed that in select_bad_process() we can
| > eventually bump on an already dying task, case in which we just wait for
| > the task to die and avoid killing other tasks. Maybe we could boost the
| > priority of the dying task here too.
| > 
| yes, nice catch.

Here is a more complete version of the patch, boosting priority on the
three exit points of the OOM-killer. I also avoid touching the priority if
the task is already an RT task. The patch:

 
oom-kill: give the dying task a higher priority (v5)

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
suggested on LKML using SCHED_FIFO:1, the lowest RT priority so that
this task won't interfere with any running RT task.

If the dying task is already an RT task, leave it untouched.

Another good suggestion, implemented here, was to avoid boosting the
dying task priority in case of mem_cgroup OOM.

Signed-off-by: Luis Claudio R. Goncalves <lclaudio@uudg.org>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 709aedf..67e18ca 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -52,6 +52,22 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
 	return 0;
 }
 
+/*
+ * If this is a system OOM (not a memcg OOM) and the task selected to be
+ * killed is not already running at high (RT) priorities, speed up the
+ * recovery by boosting the dying task to the lowest FIFO priority.
+ * That helps with the recovery and avoids interfering with RT tasks.
+ */
+static void boost_dying_task_prio(struct task_struct *p,
+					struct mem_cgroup *mem)
+{
+	if ((mem == NULL) && !rt_task(p)) {
+		struct sched_param param;
+		param.sched_priority = 1;
+		sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
+	}
+}
+
 /**
  * badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
@@ -277,8 +293,10 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 		 * blocked waiting for another task which itself is waiting
 		 * for memory. Is there a better alternative?
 		 */
-		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+			boost_dying_task_prio(p, mem);
 			return ERR_PTR(-1UL);
+		}
 
 		/*
 		 * This is in the process of releasing memory so wait for it
@@ -291,9 +309,10 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 		 * Otherwise we could get an easy OOM deadlock.
 		 */
 		if (p->flags & PF_EXITING) {
-			if (p != current)
+			if (p != current) {
+				boost_dying_task_prio(p, mem);
 				return ERR_PTR(-1UL);
-
+			}
 			chosen = p;
 			*ppoints = ULONG_MAX;
 		}
@@ -380,7 +399,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
  * flag though it's unlikely that  we select a process with CAP_SYS_RAW_IO
  * set.
  */
-static void __oom_kill_task(struct task_struct *p, int verbose)
+static void __oom_kill_task(struct task_struct *p, struct mem_cgroup *mem,
+								int verbose)
 {
 	if (is_global_init(p)) {
 		WARN_ON(1);
@@ -413,11 +433,11 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
 	 */
 	p->rt.time_slice = HZ;
 	set_tsk_thread_flag(p, TIF_MEMDIE);
-
 	force_sig(SIGKILL, p);
+	boost_dying_task_prio(p, mem);
 }
 
-static int oom_kill_task(struct task_struct *p)
+static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 {
 	/* WARNING: mm may not be dereferenced since we did not obtain its
 	 * value from get_task_mm(p).  This is OK since all we need to do is
@@ -430,7 +450,7 @@ static int oom_kill_task(struct task_struct *p)
 	if (!p->mm || p->signal->oom_adj == OOM_DISABLE)
 		return 1;
 
-	__oom_kill_task(p, 1);
+	__oom_kill_task(p, mem, 1);
 
 	return 0;
 }
@@ -449,7 +469,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (p->flags & PF_EXITING) {
-		__oom_kill_task(p, 0);
+		__oom_kill_task(p, mem, 0);
 		return 0;
 	}
 
@@ -462,10 +482,10 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
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
