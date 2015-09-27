Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8E06B0038
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 01:51:20 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so146471001pac.2
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 22:51:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id fm3si17843305pbb.185.2015.09.26.22.51.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 26 Sep 2015 22:51:19 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: Disable preemption during OOM-kill operation.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201509191605.CAF13520.QVSFHLtFJOMOOF@I-love.SAKURA.ne.jp>
	<20150922165523.GD4027@dhcp22.suse.cz>
	<201509232326.JEB43777.SOFMJOVOLFFtQH@I-love.SAKURA.ne.jp>
	<20150923202311.GA19054@dhcp22.suse.cz>
In-Reply-To: <20150923202311.GA19054@dhcp22.suse.cz>
Message-Id: <201509271451.DEB86404.tMFFHSVQFOLOOJ@I-love.SAKURA.ne.jp>
Date: Sun, 27 Sep 2015 14:51:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org, oleg@redhat.com

(Added Oleg, for he might want to combine memory unmapper kernel thread
and this OOM killer thread shown in this post.)

Michal Hocko wrote:
> On Wed 23-09-15 23:26:35, Tetsuo Handa wrote:
> [...]
> > Sprinkling preempt_{enable,disable} all around the oom path can temporarily
> > slow down threads with higher priority. But doing so can guarantee that
> > the oom path is not delayed indefinitely. Imagine a scenario where a task
> > with idle priority called the oom path and other tasks with normal or
> > realtime priority preempt. How long will we hold oom_lock and keep the
> > system under oom?
> 
> What I've tried to say is that the OOM killer context might get priority
> boost to make sure it makes sufficient progress. This would be much more
> systematic approach IMO than sprinkling preempt_{enable,disable} all over
> the place.

Unlike boosting priority of fatal_signal_pending() OOM victim threads,
we need to undo it after returning from out_of_memory(). And the priority
of current thread which is calling out_of_memory() can be manipulated by
other threads. In order to avoid loosing new priority by restoring old
priority after returning from out_of_memory(), a dedicated kernel thread
will be needed. I think we will use a kernel thread named OOM kiiler.
So, did you mean something like below?

------------------------------------------------------------
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 03e6257..29d6190a 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -31,6 +31,13 @@ struct oom_control {
 	 * for display purposes.
 	 */
 	const int order;
+
+	/* Used for comunicating with OOM-killer kernel thread */
+	struct list_head list;
+	struct task_struct *task;
+	unsigned long totalpages;
+	int cpu;
+	bool done;
 };
 
 /*
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 03b612b..3b8edd0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -35,6 +35,8 @@
 #include <linux/freezer.h>
 #include <linux/ftrace.h>
 #include <linux/ratelimit.h>
+#include <linux/kthread.h>
+#include <linux/utsname.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
@@ -386,14 +388,23 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 static void dump_header(struct oom_control *oc, struct task_struct *p,
 			struct mem_cgroup *memcg)
 {
-	task_lock(current);
+	struct task_struct *task = oc->task;
+	task_lock(task);
 	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
 		"oom_score_adj=%hd\n",
-		current->comm, oc->gfp_mask, oc->order,
-		current->signal->oom_score_adj);
-	cpuset_print_task_mems_allowed(current);
-	task_unlock(current);
-	dump_stack();
+		task->comm, oc->gfp_mask, oc->order,
+		task->signal->oom_score_adj);
+	cpuset_print_task_mems_allowed(task);
+	task_unlock(task);
+	/* dump_lock logic is missing here. */
+	printk(KERN_DEFAULT "CPU: %d PID: %d Comm: %.20s %s %s %.*s\n",
+	       oc->cpu, task->pid, task->comm,
+	       print_tainted(), init_utsname()->release,
+	       (int)strcspn(init_utsname()->version, " "),
+	       init_utsname()->version);
+	/* "Hardware name: " line is missing here. */
+	print_worker_info(KERN_DEFAULT, task);
+	show_stack(task, NULL);
 	if (memcg)
 		mem_cgroup_print_oom_info(memcg, p);
 	else
@@ -408,7 +419,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p,
 static atomic_t oom_victims = ATOMIC_INIT(0);
 static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
 
-bool oom_killer_disabled __read_mostly;
+bool oom_killer_disabled __read_mostly = true;
 
 /**
  * mark_oom_victim - mark the given task as OOM victim
@@ -647,6 +658,68 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+static DECLARE_WAIT_QUEUE_HEAD(oom_request_wait);
+static DECLARE_WAIT_QUEUE_HEAD(oom_response_wait);
+static LIST_HEAD(oom_request_list);
+static DEFINE_SPINLOCK(oom_request_list_lock);
+
+static int oom_killer(void *unused)
+{
+	struct task_struct *p;
+	unsigned int uninitialized_var(points);
+	struct oom_control *oc;
+
+	/* Boost priority in order to send SIGKILL as soon as possible. */
+	set_user_nice(current, MIN_NICE);
+
+ start:
+	wait_event(oom_request_wait, !list_empty(&oom_request_list));
+	oc = NULL;
+	spin_lock(&oom_request_list_lock);
+	if (!list_empty(&oom_request_list))
+		oc = list_first_entry(&oom_request_list, struct oom_control, list);
+	spin_unlock(&oom_request_list_lock);
+	if (!oc)
+		goto start;
+	p = oc->task;
+
+	/* Disable preemption in order to send SIGKILL as soon as possible. */
+	preempt_disable();
+
+	if (sysctl_oom_kill_allocating_task && p->mm &&
+	    !oom_unkillable_task(p, NULL, oc->nodemask) &&
+	    p->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
+		get_task_struct(p);
+		oom_kill_process(oc, p, 0, oc->totalpages, NULL,
+				 "Out of memory (oom_kill_allocating_task)");
+		goto end;
+	}
+
+	p = select_bad_process(oc, &points, oc->totalpages);
+	/* Found nothing?!?! Either we hang forever, or we panic. */
+	if (!p && !is_sysrq_oom(oc)) {
+		dump_header(oc, NULL, NULL);
+		panic("Out of memory and no killable processes...\n");
+	}
+	if (p && p != (void *)-1UL)
+		oom_kill_process(oc, p, points, oc->totalpages, NULL,
+				 "Out of memory");
+ end:
+	preempt_enable();
+	oc->done = true;
+	wake_up_all(&oom_response_wait);
+	goto start;
+}
+
+static int __init run_oom_killer(void)
+{
+	struct task_struct *task = kthread_run(oom_killer, NULL, "OOM-killer");
+	BUG_ON(IS_ERR(task));
+	oom_killer_disabled = false;
+	return 0;
+}
+postcore_initcall(run_oom_killer);
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @oc: pointer to struct oom_control
@@ -658,10 +731,8 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
  */
 bool out_of_memory(struct oom_control *oc)
 {
-	struct task_struct *p;
 	unsigned long totalpages;
 	unsigned long freed = 0;
-	unsigned int uninitialized_var(points);
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	if (oom_killer_disabled)
@@ -672,6 +743,7 @@ bool out_of_memory(struct oom_control *oc)
 		/* Got some memory back in the last second. */
 		return true;
 
+	oc->task = current;
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
@@ -695,30 +767,23 @@ bool out_of_memory(struct oom_control *oc)
 		oc->nodemask = NULL;
 	check_panic_on_oom(oc, constraint, NULL);
 
-	if (sysctl_oom_kill_allocating_task && current->mm &&
-	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
-	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
-		get_task_struct(current);
-		oom_kill_process(oc, current, 0, totalpages, NULL,
-				 "Out of memory (oom_kill_allocating_task)");
-		return true;
-	}
-
-	p = select_bad_process(oc, &points, totalpages);
-	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!p && !is_sysrq_oom(oc)) {
-		dump_header(oc, NULL, NULL);
-		panic("Out of memory and no killable processes...\n");
-	}
-	if (p && p != (void *)-1UL) {
-		oom_kill_process(oc, p, points, totalpages, NULL,
-				 "Out of memory");
-		/*
-		 * Give the killed process a good chance to exit before trying
-		 * to allocate memory again.
-		 */
-		schedule_timeout_killable(1);
-	}
+	/* OK. Let's wait for OOM killer. */
+	oc->cpu = raw_smp_processor_id();
+	oc->totalpages = totalpages;		
+	oc->done = false;
+	spin_lock(&oom_request_list_lock);
+	list_add(&oc->list, &oom_request_list);
+	spin_unlock(&oom_request_list_lock);
+	wake_up(&oom_request_wait);
+	wait_event(oom_response_wait, oc->done);
+	spin_lock(&oom_request_list_lock);
+	list_del(&oc->list);
+	spin_unlock(&oom_request_list_lock);
+	/*
+	 * Give the killed process a good chance to exit before trying
+	 * to allocate memory again.
+	 */
+	schedule_timeout_killable(1);
 	return true;
 }
 
------------------------------------------------------------

By the way, I think that we might want to omit dump_header() call
if the OOM victim's mm was already reported by previous OOM events
because output by show_mem() and dump_tasks() in dump_header() is
noisy. All OOM events between uptime 110 and 303 of
http://I-love.SAKURA.ne.jp/tmp/serial-20150927.txt.xz are choosing
the same mm. Even if the first OOM event completed within a few
seconds by disabling preemption, subsequent OOM events which
sequentially choose OOM victims without TIF_MEMDIE consumed many
seconds after all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
