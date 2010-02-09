Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B1E886B0078
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 03:05:57 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1985rbE024112
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Feb 2010 17:05:53 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA7AF45DE4F
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 17:05:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 78C9945DD6D
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 17:05:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EB6BE38002
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 17:05:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 11CD11DB803F
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 17:05:52 +0900 (JST)
Date: Tue, 9 Feb 2010 17:02:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
 cgroup v2
Message-Id: <20100209170228.ecee0963.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002082328370.19744@chino.kir.corp.google.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
	<20100209120209.686c348c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002082328370.19744@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Feb 2010 23:50:12 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 9 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > Index: mmotm-2.6.33-Feb06/include/linux/memcontrol.h
> > ===================================================================
> > --- mmotm-2.6.33-Feb06.orig/include/linux/memcontrol.h
> > +++ mmotm-2.6.33-Feb06/include/linux/memcontrol.h
> > @@ -71,7 +71,8 @@ extern unsigned long mem_cgroup_isolate_
> >  					struct mem_cgroup *mem_cont,
> >  					int active, int file);
> >  extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
> > -int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
> > +int task_in_oom_mem_cgroup(struct task_struct *task,
> > +	const struct mem_cgroup *mem);
> 
> This is only called from the oom killer, so I'm not sure this needs to 
> be renamed.  
Why I renamed this is "be careful when a new user calls this".

> It seems like any caller of this function, present or future, 
> would be doing a tasklist iteration while holding a readlock on 
> tasklist_lock, so perhaps just document that task_in_mem_cgroup() requires 
> that?

Hmm. ok. I avoid this rename. It will make the patch smaller.


> 
> >  
> >  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
> >  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> > @@ -215,7 +216,7 @@ static inline int mm_match_cgroup(struct
> >  	return 1;
> >  }
> >  
> > -static inline int task_in_mem_cgroup(struct task_struct *task,
> > +static inline int task_in_oom_mem_cgroup(struct task_struct *task,
> >  				     const struct mem_cgroup *mem)
> >  {
> >  	return 1;
> > Index: mmotm-2.6.33-Feb06/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.33-Feb06.orig/mm/memcontrol.c
> > +++ mmotm-2.6.33-Feb06/mm/memcontrol.c
> > @@ -781,16 +781,40 @@ void mem_cgroup_move_lists(struct page *
> >  	mem_cgroup_add_lru_list(page, to);
> >  }
> >  
> > -int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
> > +/*
> > + * This function is called from OOM Killer. This checks the task is mm_owner
> > + * and checks it's mem_cgroup is under oom.
> > + */
> > +int task_in_oom_mem_cgroup(struct task_struct *task,
> > +		const struct mem_cgroup *mem)
> >  {
> > +	struct mm_struct *mm;
> >  	int ret;
> >  	struct mem_cgroup *curr = NULL;
> >  
> > -	task_lock(task);
> > +	/*
> > + 	 * The task's task->mm pointer is guarded by task_lock() but it's
> > + 	 * risky to take task_lock in oom kill situaion. Oom-killer may
> > + 	 * kill a task which is in unknown status and cause siginificant delay
> > + 	 * or deadlock.
> > + 	 * So, we use some loose way. Because we're under taslist lock, "task"
> > + 	 * pointer is always safe and we can access it. So, accessing mem_cgroup
> > + 	 * via task struct is safe. To check the task is mm owner, we do loose
> > + 	 * check. And this is enough.
> > + 	 * There is small race at updating mm->onwer but we can ignore it.
> > + 	 * A problematic race here means that oom-selection logic by walking
> > + 	 * task list itself is racy. We can't make any strict guarantee between
> > + 	 * task's cgroup status and oom-killer selection, anyway. And, in real
> > + 	 * world, this will be no problem.
> > + 	 */
> > +	mm = task->mm;
> > +	if (!mm || mm->owner != task)
> > +		return 0;
> 
> You can't dereference task->mm->owner without holding task_lock(task), but 
> I don't see why you need to even deal with task->mm.  All callers to this 
> function will check for !task->mm either during their iterations or with 
> oom_kill_task() returning 0.
> 
Just for being careful. We don't hold task_lock(), which guards task->mm in
callers.



> >  	rcu_read_lock();
> > -	curr = try_get_mem_cgroup_from_mm(task->mm);
> > +	curr = mem_cgroup_from_task(task);
> > +	if (!css_tryget(&curr->css));
> > +		curr = NULL;
> 
> We can always dereference p because of tasklist_lock, there should be no 
> need to do rcu_read_lock() or any rcu dereference, so you should be able 
> to just do this:
> 
> 	do {
> 		curr = mem_cgroup_from_task(task);
> 		if (!curr)
> 			break;
> 	} while (!css_tryget(&curr->css));
> 
Ok, I missed that. thank you. I'll use this code.

> If you like that better, I suggest sending your original two-liner fix 
> using task_in_mem_cgroup() while taking task_lock(p) to stable and then 
> improving on it with a follow-up patch for mainline to do this refcount 
> variation.
> 
Hmm. ok. I'll devide the patch into 2 parts. Thank you for review.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
