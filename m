Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ED54D6B0085
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 04:27:31 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id o199RSKD025300
	for <linux-mm@kvack.org>; Tue, 9 Feb 2010 20:27:28 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o199MLW11617990
	for <linux-mm@kvack.org>; Tue, 9 Feb 2010 20:22:21 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o199RRq8023997
	for <linux-mm@kvack.org>; Tue, 9 Feb 2010 20:27:27 +1100
Date: Tue, 9 Feb 2010 14:57:22 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
 cgroup v2
Message-ID: <20100209092722.GE3290@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
 <28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
 <20100209120209.686c348c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100209120209.686c348c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-02-09 12:02:09]:

> How about this ?
> Passed simple oom-kill test on mmotom-Feb06
> ==
> Now, oom-killer kills process's chidlren at first. But this means
> a child in other cgroup can be killed. But it's not checked now.
> 
> This patch fixes that.
> 
> It's pointed out that task_lock in task_in_mem_cgroup is bad at
> killing a task in oom-killer.

I'll dig the earlier thread to see what you mean.

 It can cause siginificant delay or
> deadlock. For removing unnecessary task_lock under oom-killer, we use
> use some loose way. Considering oom-killer and task-walk in the tasklist, 
> checking "task is in mem_cgroup" itself includes some race and we don't
> have to do strict check, here.
> (IOW, we can't do it.)
> 
> Changelog: 2009/02/09
>  - modified task_in_mem_cgroup to be lockless.
> 
> CC: Minchan Kim <minchan.kim@gmail.com>
> CC: David Rientjes <rientjes@google.com>
> CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |    5 +++--
>  mm/memcontrol.c            |   32 ++++++++++++++++++++++++++++----
>  mm/oom_kill.c              |    6 ++++--
>  3 files changed, 35 insertions(+), 8 deletions(-)
> 
> Index: mmotm-2.6.33-Feb06/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-2.6.33-Feb06.orig/include/linux/memcontrol.h
> +++ mmotm-2.6.33-Feb06/include/linux/memcontrol.h
> @@ -71,7 +71,8 @@ extern unsigned long mem_cgroup_isolate_
>  					struct mem_cgroup *mem_cont,
>  					int active, int file);
>  extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
> -int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
> +int task_in_oom_mem_cgroup(struct task_struct *task,
> +	const struct mem_cgroup *mem);
> 
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> @@ -215,7 +216,7 @@ static inline int mm_match_cgroup(struct
>  	return 1;
>  }
> 
> -static inline int task_in_mem_cgroup(struct task_struct *task,
> +static inline int task_in_oom_mem_cgroup(struct task_struct *task,
>  				     const struct mem_cgroup *mem)
>  {
>  	return 1;
> Index: mmotm-2.6.33-Feb06/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.33-Feb06.orig/mm/memcontrol.c
> +++ mmotm-2.6.33-Feb06/mm/memcontrol.c
> @@ -781,16 +781,40 @@ void mem_cgroup_move_lists(struct page *
>  	mem_cgroup_add_lru_list(page, to);
>  }
> 
> -int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
> +/*
> + * This function is called from OOM Killer. This checks the task is mm_owner
> + * and checks it's mem_cgroup is under oom.
> + */
> +int task_in_oom_mem_cgroup(struct task_struct *task,
> +		const struct mem_cgroup *mem)
>  {
> +	struct mm_struct *mm;
>  	int ret;
>  	struct mem_cgroup *curr = NULL;
> 
> -	task_lock(task);
> +	/*
> + 	 * The task's task->mm pointer is guarded by task_lock() but it's
> + 	 * risky to take task_lock in oom kill situaion. Oom-killer may
> + 	 * kill a task which is in unknown status and cause siginificant delay
> + 	 * or deadlock.

task->mm is protected by task_lock() for several reasons including
race with exec() and exit(). The task structure itself is protected via RCU, so
task->task_lock. The OOM kill process should happen only when the
signal is delivered (at context switch back to user space). I don't
understand the race during OOM kill.

> + 	 * So, we use some loose way. Because we're under taslist lock, "task"
> + 	 * pointer is always safe and we can access it. So, accessing mem_cgroup
> + 	 * via task struct is safe. To check the task is mm owner, we do loose
> + 	 * check. And this is enough.
> + 	 * There is small race at updating mm->onwer but we can ignore it.
> + 	 * A problematic race here means that oom-selection logic by walking
> + 	 * task list itself is racy. We can't make any strict guarantee between
> + 	 * task's cgroup status and oom-killer selection, anyway. And, in real
> + 	 * world, this will be no problem.
> + 	 */
> +	mm = task->mm;

With the task_lock() gone, I'm afraid we might find the wrong task for
OOM killing, specifically if the task is moving.

> +	if (!mm || mm->owner != task)
> +		return 0;
>  	rcu_read_lock();
> -	curr = try_get_mem_cgroup_from_mm(task->mm);
> +	curr = mem_cgroup_from_task(task);
> +	if (!css_tryget(&curr->css));
> +		curr = NULL;
>  	rcu_read_unlock();
> -	task_unlock(task);
>  	if (!curr)
>  		return 0;
>  	/*
> Index: mmotm-2.6.33-Feb06/mm/oom_kill.c
> ===================================================================
> --- mmotm-2.6.33-Feb06.orig/mm/oom_kill.c
> +++ mmotm-2.6.33-Feb06/mm/oom_kill.c
> @@ -264,7 +264,7 @@ static struct task_struct *select_bad_pr
>  		/* skip the init task */
>  		if (is_global_init(p))
>  			continue;
> -		if (mem && !task_in_mem_cgroup(p, mem))
> +		if (mem && !task_in_oom_mem_cgroup(p, mem))
>  			continue;
> 
>  		/*
> @@ -332,7 +332,7 @@ static void dump_tasks(const struct mem_
>  	do_each_thread(g, p) {
>  		struct mm_struct *mm;
> 
> -		if (mem && !task_in_mem_cgroup(p, mem))
> +		if (mem && !task_in_oom_mem_cgroup(p, mem))
>  			continue;
>  		if (!thread_group_leader(p))
>  			continue;
> @@ -459,6 +459,8 @@ static int oom_kill_process(struct task_
>  	list_for_each_entry(c, &p->children, sibling) {
>  		if (c->mm == p->mm)
>  			continue;
> +		if (mem && !task_in_oom_mem_cgroup(c, mem))
> +			continue;
>  		if (!oom_kill_task(c))
>  			return 0;
>  	}
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
