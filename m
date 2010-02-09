Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3299A6B007D
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 03:21:41 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o198La2q025223
	for <linux-mm@kvack.org>; Tue, 9 Feb 2010 08:21:37 GMT
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by kpbe17.cbf.corp.google.com with ESMTP id o198LFRN002103
	for <linux-mm@kvack.org>; Tue, 9 Feb 2010 00:21:35 -0800
Received: by pxi1 with SMTP id 1so198011pxi.25
        for <linux-mm@kvack.org>; Tue, 09 Feb 2010 00:21:35 -0800 (PST)
Date: Tue, 9 Feb 2010 00:21:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
 cgroup v2
In-Reply-To: <20100209170228.ecee0963.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002090018540.1119@chino.kir.corp.google.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com> <28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com> <20100209120209.686c348c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002082328370.19744@chino.kir.corp.google.com>
 <20100209170228.ecee0963.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > This is only called from the oom killer, so I'm not sure this needs to 
> > be renamed.  
> Why I renamed this is "be careful when a new user calls this".
> 

It would still be good to document the function as requiring a readlock on 
tasklist_lock.

> > > Index: mmotm-2.6.33-Feb06/mm/memcontrol.c
> > > ===================================================================
> > > --- mmotm-2.6.33-Feb06.orig/mm/memcontrol.c
> > > +++ mmotm-2.6.33-Feb06/mm/memcontrol.c
> > > @@ -781,16 +781,40 @@ void mem_cgroup_move_lists(struct page *
> > >  	mem_cgroup_add_lru_list(page, to);
> > >  }
> > >  
> > > -int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
> > > +/*
> > > + * This function is called from OOM Killer. This checks the task is mm_owner
> > > + * and checks it's mem_cgroup is under oom.
> > > + */
> > > +int task_in_oom_mem_cgroup(struct task_struct *task,
> > > +		const struct mem_cgroup *mem)
> > >  {
> > > +	struct mm_struct *mm;
> > >  	int ret;
> > >  	struct mem_cgroup *curr = NULL;
> > >  
> > > -	task_lock(task);
> > > +	/*
> > > + 	 * The task's task->mm pointer is guarded by task_lock() but it's
> > > + 	 * risky to take task_lock in oom kill situaion. Oom-killer may
> > > + 	 * kill a task which is in unknown status and cause siginificant delay
> > > + 	 * or deadlock.
> > > + 	 * So, we use some loose way. Because we're under taslist lock, "task"
> > > + 	 * pointer is always safe and we can access it. So, accessing mem_cgroup
> > > + 	 * via task struct is safe. To check the task is mm owner, we do loose
> > > + 	 * check. And this is enough.
> > > + 	 * There is small race at updating mm->onwer but we can ignore it.
> > > + 	 * A problematic race here means that oom-selection logic by walking
> > > + 	 * task list itself is racy. We can't make any strict guarantee between
> > > + 	 * task's cgroup status and oom-killer selection, anyway. And, in real
> > > + 	 * world, this will be no problem.
> > > + 	 */
> > > +	mm = task->mm;
> > > +	if (!mm || mm->owner != task)
> > > +		return 0;
> > 
> > You can't dereference task->mm->owner without holding task_lock(task), but 
> > I don't see why you need to even deal with task->mm.  All callers to this 
> > function will check for !task->mm either during their iterations or with 
> > oom_kill_task() returning 0.
> > 
> Just for being careful. We don't hold task_lock(), which guards task->mm in
> callers.
> 

The callers don't care if it disappears out from under us since we never 
dereference it, it's just a sanity check to ensure we don't pick a 
kthread or an exiting task that won't free any memory.  One of my patches 
to do the oom killer rewrite that I'll propose tomorrow actually removes a 
lot of that redundancy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
