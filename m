Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 891856B0047
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 06:54:16 -0500 (EST)
Message-ID: <4B827043.3060305@cn.fujitsu.com>
Date: Mon, 22 Feb 2010 19:53:39 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time (58568d2)
References: <20100218134921.GF9738@laptop> <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com> <20100219033126.GI9738@laptop> <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

I'm sorry for replying this late.

on 2010-2-19 18:06, David Rientjes wrote:
> On Fri, 19 Feb 2010, Nick Piggin wrote:
> 
>>> guarantee_online_cpus() truly does require callback_mutex, the 
>>> cgroup_scan_tasks() iterator locking can protect changes in the cgroup 
>>> hierarchy but it doesn't protect a store to cs->cpus_allowed or for 
>>> hotplug.
>>
>> Right, but the callback_mutex was being removed by this patch.
>>
> 
> I was making the case for it to be readded :)

But cgroup_mutex is held when someone changes cs->cpus_allowed or doing hotplug,
so I think callback_mutex is not necessary in this case.

> 
>>> top_cpuset.cpus_allowed will always need to track cpu_active_map since 
>>> those are the schedulable cpus, it looks like that's initialized for SMP 
>>> and the cpu hotplug notifier does that correctly.
>>>
>>> I'm not sure what the logic is doing in cpuset_attach() where cs is the 
>>> cpuset to attach to:
>>>
>>> 	if (cs == &top_cpuset) {
>>> 		cpumask_copy(cpus_attach, cpu_possible_mask);
>>> 		to = node_possible_map;
>>> 	}
>>>
>>> cpus_attach is properly protected by cgroup_lock, but using 
>>> node_possible_map here will set task->mems_allowed to node_possible_map 
>>> when the cpuset does not have memory_migrate enabled.  This is the source 
>>> of your oops, I think.
>>
>> Could be, yes.
>>
> 
> I'd be interested to see if you still get the same oops with the patch at 
> the end of this email that fixes this logic.

I think this patch can't fix this bug, because mems_allowed of tasks in the
top group is set to node_possible_map by default, not when the task is 
attached.

I made a new patch at the end of this email to fix it, but I have no machine
to test it now. who can test it for me.

---
diff --git a/init/main.c b/init/main.c
index 4cb47a1..512ba15 100644
--- a/init/main.c
+++ b/init/main.c
@@ -846,7 +846,7 @@ static int __init kernel_init(void * unused)
 	/*
 	 * init can allocate pages on any node
 	 */
-	set_mems_allowed(node_possible_map);
+	set_mems_allowed(node_states[N_HIGH_MEMORY]);
 	/*
 	 * init can run on any cpu.
 	 */
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index ba401fa..e29b440 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -935,10 +935,12 @@ static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
 	struct task_struct *tsk = current;
 
 	tsk->mems_allowed = *to;
+	wmb();
 
 	do_migrate_pages(mm, from, to, MPOL_MF_MOVE_ALL);
 
 	guarantee_online_mems(task_cs(tsk),&tsk->mems_allowed);
+	wmb();
 }
 
 /*
@@ -1391,11 +1393,10 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 
 	if (cs == &top_cpuset) {
 		cpumask_copy(cpus_attach, cpu_possible_mask);
-		to = node_possible_map;
 	} else {
 		guarantee_online_cpus(cs, cpus_attach);
-		guarantee_online_mems(cs, &to);
 	}
+	guarantee_online_mems(cs, &to);
 
 	/* do per-task migration stuff possibly for each in the threadgroup */
 	cpuset_attach_task(tsk, &to, cs);
@@ -2090,15 +2091,19 @@ static int cpuset_track_online_cpus(struct notifier_block *unused_nb,
 static int cpuset_track_online_nodes(struct notifier_block *self,
 				unsigned long action, void *arg)
 {
+	nodemask_t oldmems;
+
 	cgroup_lock();
 	switch (action) {
 	case MEM_ONLINE:
-	case MEM_OFFLINE:
+		oldmems = top_cpuset.mems_allowed;
 		mutex_lock(&callback_mutex);
 		top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
 		mutex_unlock(&callback_mutex);
-		if (action == MEM_OFFLINE)
-			scan_for_empty_cpusets(&top_cpuset);
+		update_tasks_nodemask(&top_cpuset, &oldmems, NULL);
+		break;
+	case MEM_OFFLINE:
+		scan_for_empty_cpusets(&top_cpuset);
 		break;
 	default:
 		break;
diff --git a/kernel/kthread.c b/kernel/kthread.c
index fbb6222..84c7f99 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -219,7 +219,7 @@ int kthreadd(void *unused)
 	set_task_comm(tsk, "kthreadd");
 	ignore_signals(tsk);
 	set_cpus_allowed_ptr(tsk, cpu_all_mask);
-	set_mems_allowed(node_possible_map);
+	set_mems_allowed(node_states[N_HIGH_MEMORY]);
 
 	current->flags |= PF_NOFREEZE | PF_FREEZER_NOSIG;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
