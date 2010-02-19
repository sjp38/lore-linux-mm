Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2FDD46B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 22:31:45 -0500 (EST)
Date: Fri, 19 Feb 2010 14:31:26 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
Message-ID: <20100219033126.GI9738@laptop>
References: <20100218134921.GF9738@laptop>
 <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Miao Xie <miaox@cn.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 18, 2010 at 01:38:11PM -0800, David Rientjes wrote:
> On Fri, 19 Feb 2010, Nick Piggin wrote:
> 
> > Hi,
> > 
> > The patch cpuset,mm: update tasks' mems_allowed in time (58568d2) causes
> > a regression uncovered by SGI. Basically it is allowing possible but not
> > online nodes in the task_struct.mems_allowed nodemask (which is contrary
> > to several comments still in kernel/cpuset.c), and that causes
> > cpuset_mem_spread_node() to return an offline node to slab, causing an
> > oops.
> > 
> > Easy to reproduce if you have a machine with !online nodes.
> > 
> >         - mkdir /dev/cpuset
> >         - mount cpuset -t cpuset /dev/cpuset
> >         - echo 1 > /dev/cpuset/memory_spread_slab
> > 
> > kernel BUG at
> > /usr/src/packages/BUILD/kernel-default-2.6.32/linux-2.6.32/mm/slab.c:3271!
> > bash[6885]: bugcheck! 0 [1]
> > Pid: 6885, CPU 5, comm:                 bash
> > psr : 00001010095a2010 ifs : 800000000000038b ip  : [<a00000010020cf00>]
> > Tainted: G        W    (2.6.32-0.6.8-default)
> > ip is at ____cache_alloc_node+0x440/0x500
> 
> It seems like current->mems_allowed is not properly initialized, although 
> task_cs(current)->mems_allowed is to node_states[N_HIGH_MEMORY].  See 
> below.
> 
> > A simple bandaid is to skip !online nodes in cpuset_mem_spread_node().
> > However I'm a bit worried about 58568d2.
> > 
> > It is doing a lot of stuff. It is removing the callback_mutex from
> > around several seemingly unrelated places (eg. from around
> > guarnatee_online_cpus, which explicitly asks to be called with that
> > lock held), and other places, so I don't know how it is not racy
> > with hotplug.
> > 
> 
> guarantee_online_cpus() truly does require callback_mutex, the 
> cgroup_scan_tasks() iterator locking can protect changes in the cgroup 
> hierarchy but it doesn't protect a store to cs->cpus_allowed or for 
> hotplug.

Right, but the callback_mutex was being removed by this patch.

> 
> top_cpuset.cpus_allowed will always need to track cpu_active_map since 
> those are the schedulable cpus, it looks like that's initialized for SMP 
> and the cpu hotplug notifier does that correctly.
> 
> I'm not sure what the logic is doing in cpuset_attach() where cs is the 
> cpuset to attach to:
> 
> 	if (cs == &top_cpuset) {
> 		cpumask_copy(cpus_attach, cpu_possible_mask);
> 		to = node_possible_map;
> 	}
> 
> cpus_attach is properly protected by cgroup_lock, but using 
> node_possible_map here will set task->mems_allowed to node_possible_map 
> when the cpuset does not have memory_migrate enabled.  This is the source 
> of your oops, I think.

Could be, yes.

 
> > Then it also says that the fastpath doesn't use any locking, so the
> > update-path first adds the newly allowed nodes, then removes the
> > newly prohibited nodes. Unfortunately there are no barriers apparent
> > (and none added), and cpumask/nodemask can be larger than one word,
> > so it seems there could be races.
> > 
> 
> We can remove the store to tsk->mems_allowed in cpuset_migrate_mm() 
> because cpuset_change_task_nodemask() already does it under 
> task_lock(tsk).

But it doesn't matter if stores are done under lock, if the loads are
not. masks can be multiple words, so there isn't any ordering between
reading half and old mask and half a new one that results in an invalid
state. AFAIKS.

> 
> cpuset_migrate_mm() looks to be subsequently updating the cpuset_attach() 
> nodemask when moving to top_cpuset so it doesn't get stuck with 
> node_possible_map, but that's not called unless memory_migrate is enabled.
> 
> > It also seems like the exported cpuset_mems_allowed and
> > cpuset_cpus_allowed APIs are just broken wrt hotplug because the
> > hotplug lock is dropped before returning.
> > 
> 
> The usage of cpuset_cpus_allowed_locked() looks wrong in the scheduler, as 
> well: it can't hold callback_mutex since it is only declared at file scope 
> in the cpuset code.

Well it is exported as cpuset_lock(). And the scheduler has it covered
in all cases by the looks except for select_task_rq, which is called
by wakeup code. We should stick WARN_ONs through the cpuset code for
mutexes not held when they should be.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
