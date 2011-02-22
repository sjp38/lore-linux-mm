Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B247D8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 15:30:24 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p1MKUJwQ025090
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 12:30:19 -0800
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by kpbe14.cbf.corp.google.com with ESMTP id p1MKUHsT007808
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 12:30:18 -0800
Received: by pzk3 with SMTP id 3so871229pzk.18
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 12:30:17 -0800 (PST)
Date: Tue, 22 Feb 2011 12:30:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] cpuset: Fix unchecked calls to NODEMASK_ALLOC()
In-Reply-To: <4D631C54.1080703@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1102221219101.5929@chino.kir.corp.google.com>
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7ED1.2070601@cn.fujitsu.com> <alpine.DEB.2.00.1102191745180.27722@chino.kir.corp.google.com> <4D61DA04.4060007@cn.fujitsu.com> <alpine.DEB.2.00.1102211617510.23557@chino.kir.corp.google.com>
 <4D631C54.1080703@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, miaox@cn.fujitsu.com, linux-mm@kvack.org

On Tue, 22 Feb 2011, Li Zefan wrote:

> [PATCH 3/4] cpuset: Fix unchecked calls to NODEMASK_ALLOC()
> 
> Those functions that use NODEMASK_ALLOC() can't propogate errno
> to users, so might fail silently.
> 
> Fix it by using one static nodemask_t variable for each function, and
> those variables are protected by cgroup_mutex.
> 

I think there would also be incentive to do the same thing for 
update_nodemask() even though its caller can handle -ENOMEM.  Imagine 
current being out of memory and the NODEMASK_ALLOC() subsequently failing 
because it is oom yet it may be trying to give itself more memory.  It's 
also protected by cgroup_mutex so the only thing we're sacrificing is 8 
bytes on the defconfig and 256 bytes even with CONFIG_NODES_SHIFT == 10.  
On machines that large, this seems like an acceptable cost to ensure we 
can give ourselves more memory :)

> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> ---
>  kernel/cpuset.c |   50 ++++++++++++++++----------------------------------
>  1 files changed, 16 insertions(+), 34 deletions(-)
> 
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 8fef8c6..073ce91 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1015,17 +1015,12 @@ static void cpuset_change_nodemask(struct task_struct *p,
>  	struct cpuset *cs;
>  	int migrate;
>  	const nodemask_t *oldmem = scan->data;
> -	NODEMASK_ALLOC(nodemask_t, newmems, GFP_KERNEL);
> -
> -	if (!newmems)
> -		return;
> +	static nodemask_t newmems;	/* protected by cgroup_mutex */
>  
>  	cs = cgroup_cs(scan->cg);
> -	guarantee_online_mems(cs, newmems);
> -
> -	cpuset_change_task_nodemask(p, newmems);
> +	guarantee_online_mems(cs, &newmems);

The newmems nodemask is going to be persistant across calls since it is 
static, so we have to be careful that nothing depends on it being 
NODE_MASK_NONE.  Indeed, NODEMASK_ALLOC() with just GFP_KERNEL doesn't 
guarantee anything different.  guarantee_online_mems() sets the nodemask, 
so this looks good.

>  
> -	NODEMASK_FREE(newmems);
> +	cpuset_change_task_nodemask(p, &newmems);
>  
>  	mm = get_task_mm(p);
>  	if (!mm)
> @@ -1438,41 +1433,35 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
>  	struct mm_struct *mm;
>  	struct cpuset *cs = cgroup_cs(cont);
>  	struct cpuset *oldcs = cgroup_cs(oldcont);
> -	NODEMASK_ALLOC(nodemask_t, to, GFP_KERNEL);
> -
> -	if (to == NULL)
> -		goto alloc_fail;
> +	static nodemask_t to;		/* protected by cgroup_mutex */
>  
>  	if (cs == &top_cpuset) {
>  		cpumask_copy(cpus_attach, cpu_possible_mask);
>  	} else {
>  		guarantee_online_cpus(cs, cpus_attach);
>  	}
> -	guarantee_online_mems(cs, to);
> +	guarantee_online_mems(cs, &to);
>  
>  	/* do per-task migration stuff possibly for each in the threadgroup */
> -	cpuset_attach_task(tsk, to, cs);
> +	cpuset_attach_task(tsk, &to, cs);
>  	if (threadgroup) {
>  		struct task_struct *c;
>  		rcu_read_lock();
>  		list_for_each_entry_rcu(c, &tsk->thread_group, thread_group) {
> -			cpuset_attach_task(c, to, cs);
> +			cpuset_attach_task(c, &to, cs);
>  		}
>  		rcu_read_unlock();
>  	}
>  
>  	/* change mm; only needs to be done once even if threadgroup */
> -	*to = cs->mems_allowed;
> +	to = cs->mems_allowed;
>  	mm = get_task_mm(tsk);
>  	if (mm) {
> -		mpol_rebind_mm(mm, to);
> +		mpol_rebind_mm(mm, &to);
>  		if (is_memory_migrate(cs))
> -			cpuset_migrate_mm(mm, &oldcs->mems_allowed, to);
> +			cpuset_migrate_mm(mm, &oldcs->mems_allowed, &to);
>  		mmput(mm);
>  	}
> -
> -alloc_fail:
> -	NODEMASK_FREE(to);
>  }
>  
>  /* The various types of files and directories in a cpuset file system */
> @@ -2051,10 +2040,7 @@ static void scan_for_empty_cpusets(struct cpuset *root)
>  	struct cpuset *cp;	/* scans cpusets being updated */
>  	struct cpuset *child;	/* scans child cpusets of cp */
>  	struct cgroup *cont;
> -	NODEMASK_ALLOC(nodemask_t, oldmems, GFP_KERNEL);
> -
> -	if (oldmems == NULL)
> -		return;
> +	static nodemask_t oldmems;	/* protected by cgroup_mutex */
>  
>  	list_add_tail((struct list_head *)&root->stack_list, &queue);
>  
> @@ -2071,7 +2057,7 @@ static void scan_for_empty_cpusets(struct cpuset *root)
>  		    nodes_subset(cp->mems_allowed, node_states[N_HIGH_MEMORY]))
>  			continue;
>  
> -		*oldmems = cp->mems_allowed;
> +		oldmems = cp->mems_allowed;
>  
>  		/* Remove offline cpus and mems from this cpuset. */
>  		mutex_lock(&callback_mutex);
> @@ -2087,10 +2073,9 @@ static void scan_for_empty_cpusets(struct cpuset *root)
>  			remove_tasks_in_empty_cpuset(cp);
>  		else {
>  			update_tasks_cpumask(cp, NULL);
> -			update_tasks_nodemask(cp, oldmems, NULL);
> +			update_tasks_nodemask(cp, &oldmems, NULL);
>  		}
>  	}
> -	NODEMASK_FREE(oldmems);
>  }
>  
>  /*
> @@ -2132,19 +2117,16 @@ void cpuset_update_active_cpus(void)
>  static int cpuset_track_online_nodes(struct notifier_block *self,
>  				unsigned long action, void *arg)
>  {
> -	NODEMASK_ALLOC(nodemask_t, oldmems, GFP_KERNEL);
> -
> -	if (oldmems == NULL)
> -		return NOTIFY_DONE;
> +	static nodemask_t oldmems;	/* protected by cgroup_mutex */
>  
>  	cgroup_lock();
>  	switch (action) {
>  	case MEM_ONLINE:
> -		*oldmems = top_cpuset.mems_allowed;
> +		oldmems = top_cpuset.mems_allowed;
>  		mutex_lock(&callback_mutex);
>  		top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
>  		mutex_unlock(&callback_mutex);
> -		update_tasks_nodemask(&top_cpuset, oldmems, NULL);
> +		update_tasks_nodemask(&top_cpuset, &oldmems, NULL);
>  		break;
>  	case MEM_OFFLINE:
>  		/*

The NODEMASK_FREE() wasn't removed from cpuset_track_online_nodes().  
After that's fixed:

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
