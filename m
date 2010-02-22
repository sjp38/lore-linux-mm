Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F2C5E6B0078
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 17:06:32 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o1MM6UvK020877
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 14:06:30 -0800
Received: from pzk31 (pzk31.prod.google.com [10.243.19.159])
	by wpaz37.hot.corp.google.com with ESMTP id o1MM5gLs032213
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 14:06:29 -0800
Received: by pzk31 with SMTP id 31so823329pzk.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2010 14:06:29 -0800 (PST)
Date: Mon, 22 Feb 2010 14:06:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
In-Reply-To: <4B827043.3060305@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002221339160.14426@chino.kir.corp.google.com>
References: <20100218134921.GF9738@laptop> <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com> <20100219033126.GI9738@laptop> <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com> <4B827043.3060305@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Feb 2010, Miao Xie wrote:

> >>> guarantee_online_cpus() truly does require callback_mutex, the 
> >>> cgroup_scan_tasks() iterator locking can protect changes in the cgroup 
> >>> hierarchy but it doesn't protect a store to cs->cpus_allowed or for 
> >>> hotplug.
> >>
> >> Right, but the callback_mutex was being removed by this patch.
> >>
> > 
> > I was making the case for it to be readded :)
> 
> But cgroup_mutex is held when someone changes cs->cpus_allowed or doing hotplug,
> so I think callback_mutex is not necessary in this case.
> 

Then why is it taken in update_cpumask()?

> I think this patch can't fix this bug, because mems_allowed of tasks in the
> top group is set to node_possible_map by default, not when the task is 
> attached.
> 

Ok, I thought that all tasks get their ->attach() function called whenever 
their cgroup is mounted.

> I made a new patch at the end of this email to fix it, but I have no machine
> to test it now. who can test it for me.
> 
> ---
> diff --git a/init/main.c b/init/main.c
> index 4cb47a1..512ba15 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -846,7 +846,7 @@ static int __init kernel_init(void * unused)
>  	/*
>  	 * init can allocate pages on any node
>  	 */
> -	set_mems_allowed(node_possible_map);
> +	set_mems_allowed(node_states[N_HIGH_MEMORY]);
>  	/*
>  	 * init can run on any cpu.
>  	 */
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index ba401fa..e29b440 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -935,10 +935,12 @@ static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
>  	struct task_struct *tsk = current;
>  
>  	tsk->mems_allowed = *to;
> +	wmb();
>  
>  	do_migrate_pages(mm, from, to, MPOL_MF_MOVE_ALL);
>  
>  	guarantee_online_mems(task_cs(tsk),&tsk->mems_allowed);
> +	wmb();
>  }
>  
>  /*
> @@ -1391,11 +1393,10 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
>  
>  	if (cs == &top_cpuset) {
>  		cpumask_copy(cpus_attach, cpu_possible_mask);
> -		to = node_possible_map;
>  	} else {
>  		guarantee_online_cpus(cs, cpus_attach);
> -		guarantee_online_mems(cs, &to);
>  	}
> +	guarantee_online_mems(cs, &to);
>  
>  	/* do per-task migration stuff possibly for each in the threadgroup */
>  	cpuset_attach_task(tsk, &to, cs);

Do we need to set cpus_attach to cpu_possible_mask?  Why won't 
cpu_active_mask suffice?

> @@ -2090,15 +2091,19 @@ static int cpuset_track_online_cpus(struct notifier_block *unused_nb,
>  static int cpuset_track_online_nodes(struct notifier_block *self,
>  				unsigned long action, void *arg)
>  {
> +	nodemask_t oldmems;

Is it possible to use NODEMASK_ALLOC() instead?

> +
>  	cgroup_lock();
>  	switch (action) {
>  	case MEM_ONLINE:
> -	case MEM_OFFLINE:
> +		oldmems = top_cpuset.mems_allowed;
>  		mutex_lock(&callback_mutex);
>  		top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
>  		mutex_unlock(&callback_mutex);
> -		if (action == MEM_OFFLINE)
> -			scan_for_empty_cpusets(&top_cpuset);
> +		update_tasks_nodemask(&top_cpuset, &oldmems, NULL);
> +		break;
> +	case MEM_OFFLINE:
> +		scan_for_empty_cpusets(&top_cpuset);
>  		break;
>  	default:
>  		break;

Looks good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
