Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B84046B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 05:06:49 -0500 (EST)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id o1JA6pBn001679
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 02:06:51 -0800
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by spaceape8.eur.corp.google.com with ESMTP id o1JA6nkQ023088
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 02:06:50 -0800
Received: by pxi10 with SMTP id 10so13844pxi.13
        for <linux-mm@kvack.org>; Fri, 19 Feb 2010 02:06:49 -0800 (PST)
Date: Fri, 19 Feb 2010 02:06:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
In-Reply-To: <20100219033126.GI9738@laptop>
Message-ID: <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com>
References: <20100218134921.GF9738@laptop> <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com> <20100219033126.GI9738@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Miao Xie <miaox@cn.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Feb 2010, Nick Piggin wrote:

> > guarantee_online_cpus() truly does require callback_mutex, the 
> > cgroup_scan_tasks() iterator locking can protect changes in the cgroup 
> > hierarchy but it doesn't protect a store to cs->cpus_allowed or for 
> > hotplug.
> 
> Right, but the callback_mutex was being removed by this patch.
> 

I was making the case for it to be readded :)

> > top_cpuset.cpus_allowed will always need to track cpu_active_map since 
> > those are the schedulable cpus, it looks like that's initialized for SMP 
> > and the cpu hotplug notifier does that correctly.
> > 
> > I'm not sure what the logic is doing in cpuset_attach() where cs is the 
> > cpuset to attach to:
> > 
> > 	if (cs == &top_cpuset) {
> > 		cpumask_copy(cpus_attach, cpu_possible_mask);
> > 		to = node_possible_map;
> > 	}
> > 
> > cpus_attach is properly protected by cgroup_lock, but using 
> > node_possible_map here will set task->mems_allowed to node_possible_map 
> > when the cpuset does not have memory_migrate enabled.  This is the source 
> > of your oops, I think.
> 
> Could be, yes.
> 

I'd be interested to see if you still get the same oops with the patch at 
the end of this email that fixes this logic.

> But it doesn't matter if stores are done under lock, if the loads are
> not. masks can be multiple words, so there isn't any ordering between
> reading half and old mask and half a new one that results in an invalid
> state. AFAIKS.
> 

It doesn't matter for MAX_NUMNODES > BITS_PER_LONG because 
task->mems_alllowed only gets updated via cpuset_change_task_nodemask() 
where the added nodes are set and then the removed nodes are cleared.  The 
side effect of this lockless access to task->mems_allowed means we may 
have a small race between

	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);

		and

	tsk->mems_allowed = *newmems;

but the penalty is that we get an allocation on a removed node, which 
isn't a big deal, especially since it was previously allowed.

> Well it is exported as cpuset_lock(). And the scheduler has it covered
> in all cases by the looks except for select_task_rq, which is called
> by wakeup code. We should stick WARN_ONs through the cpuset code for
> mutexes not held when they should be.
> 

A lot of the reliance on callback_mutex was removed because the strict 
hierarchy walking and task membership is now guarded by cgroup_mutex 
instead.  Some of the comments in kernel/cpuset.c weren't updated so they 
still say callback_mutex when in reality they mean cgroup_mutex.
---
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1319,7 +1319,7 @@ static int fmeter_getrate(struct fmeter *fmp)
 	return val;
 }
 
-/* Protected by cgroup_lock */
+/* Protected by cgroup_mutex held on cpuset_attach() */
 static cpumask_var_t cpus_attach;
 
 /* Called by cgroups to determine if a cpuset is usable; cgroup_mutex held */
@@ -1390,8 +1390,12 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 	struct cpuset *oldcs = cgroup_cs(oldcont);
 
 	if (cs == &top_cpuset) {
-		cpumask_copy(cpus_attach, cpu_possible_mask);
-		to = node_possible_map;
+		/*
+		 * top_cpuset.cpus_allowed and top_cpuset.mems_allowed are
+		 * protected by cgroup_lock which is already held here.
+		 */
+		cpumask_copy(cpus_attach, top_cpuset.cpus_allowed);
+		to = top_cpuset.mems_allowed;
 	} else {
 		guarantee_online_cpus(cs, cpus_attach);
 		guarantee_online_mems(cs, &to);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
