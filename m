Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 700AD6B020D
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 22:06:32 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id o2U26RUC032217
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 07:36:27 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2U26RFI3530850
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 07:36:27 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2U26RZ8004583
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:06:27 +1100
Date: Tue, 30 Mar 2010 07:36:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] memcg documentaion update
Message-ID: <20100330020623.GZ3308@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100329154245.455227d9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100329154245.455227d9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-29 15:42:45]:

> At reading Documentation/cgroup/memory.txt, I felt
> 
>  - old
>  - hard to find it's supported what I want to do
> 
> Hmm..maybe some rewrite will be necessary.
> 
> ==
> Documentation update. We have too much files now....
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/memory.txt |   48 ++++++++++++++++++++++++++++++---------
>  1 file changed, 38 insertions(+), 10 deletions(-)
> 
> Index: mmotm-2.6.34-Mar24/Documentation/cgroups/memory.txt
> ===================================================================
> --- mmotm-2.6.34-Mar24.orig/Documentation/cgroups/memory.txt
> +++ mmotm-2.6.34-Mar24/Documentation/cgroups/memory.txt
> @@ -4,16 +4,6 @@ NOTE: The Memory Resource Controller has
>  to as the memory controller in this document. Do not confuse memory controller
>  used here with the memory controller that is used in hardware.
> 
> -Salient features
> -
> -a. Enable control of Anonymous, Page Cache (mapped and unmapped) and
> -   Swap Cache memory pages.
> -b. The infrastructure allows easy addition of other types of memory to control
> -c. Provides *zero overhead* for non memory controller users
> -d. Provides a double LRU: global memory pressure causes reclaim from the
> -   global LRU; a cgroup on hitting a limit, reclaims from the per
> -   cgroup LRU
> -
>  Benefits and Purpose of the memory controller
> 
>  The memory controller isolates the memory behaviour of a group of tasks
> @@ -33,6 +23,44 @@ d. A CD/DVD burner could control the amo
>  e. There are several other use cases, find one or use the controller just
>     for fun (to learn and hack on the VM subsystem).
> 
> +Current Status: linux-2.6.34-mmotom(2010/March)
> +
> +Features:
> + - accounting anonymous pages, file caches, swap caches usage and limit them.
> + - private LRU and reclaim routine. (system's global LRU and private LRU
> +   work independently from each other)
> + - optionaly, memory+swap usage
> + - hierarchical accounting
> + - softlimit
> + - moving(recharging) account at moving a task
> + - usage threshold notifier
> + - oom-killer disable and oom-notifier
> + - Root cgroup has no limit controls.
> +

Good updates, I saw that you got good review comments already on this.
In the internals section at some point we need to document new
page_cgroup changes, changes to accounting, etc.

> + Kernel memory and Hugepages are not under control yet. We just manage
> + pages on LRU. To add more controls, we have to take care of performance.
> +
> +Brief summary of control files.
> +
> + tasks				# attach a task(thread)
> + cgroup.procs			# attach a process(all threads under it)
> + cgroup.event_control		# an interface for event_fd()
> + memory.usage_in_bytes		# show current memory(RSS+Cache) usage.
> + memory.memsw.usage_in_bytes	# show current memory+Swap usage.
> + memory.limit_in_bytes		# set/show limit of memory usage
> + memory.memsw.limit_in_bytes	# set/show limit of memory+Swap usage.
> + memory.failcnt			# show the number of memory usage hit limits.
> + memory.memsw.failcnt		# show the number of memory+Swap hit limits.
> + memory.max_usage_in_bytes	# show max memory usage recorded.
> + memory.memsw.usage_in_bytes	# show max memory+Swap usage recorded.
> + memory.stat			# show various statistics.
> + memory.use_hierarchy		# set/show hierarchical account enabled.
> + memory.force_empty		# trigger forced move charge to parent.
> + memory.swappiness		# set/show swappiness parameter of vmscan
> + 				  (See sysctl's vm.swappiness)
> + memory.move_charge_at_immigrate# set/show controls of moving charges
> + memory.oom_control		# set/show oom controls.
> +
>  1. History
> 
>  The memory controller has a long history. A request for comments for the memory
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
