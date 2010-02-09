Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ADDD96001DA
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 04:36:03 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o199Zwsg032034
	for <linux-mm@kvack.org>; Tue, 9 Feb 2010 09:35:58 GMT
Received: from pxi28 (pxi28.prod.google.com [10.243.27.28])
	by kpbe16.cbf.corp.google.com with ESMTP id o199Zt8C024730
	for <linux-mm@kvack.org>; Tue, 9 Feb 2010 01:35:56 -0800
Received: by pxi28 with SMTP id 28so4668620pxi.7
        for <linux-mm@kvack.org>; Tue, 09 Feb 2010 01:35:55 -0800 (PST)
Date: Tue, 9 Feb 2010 01:35:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
 cgroup v2
In-Reply-To: <20100209182235.0b8ad018.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002090133470.9056@chino.kir.corp.google.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com> <28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com> <20100209120209.686c348c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002082328370.19744@chino.kir.corp.google.com>
 <20100209170228.ecee0963.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002090018540.1119@chino.kir.corp.google.com> <20100209182235.0b8ad018.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > > > > -	task_lock(task);
> > > > > +	/*
> > > > > + 	 * The task's task->mm pointer is guarded by task_lock() but it's
> > > > > + 	 * risky to take task_lock in oom kill situaion. Oom-killer may
> > > > > + 	 * kill a task which is in unknown status and cause siginificant delay
> > > > > + 	 * or deadlock.
> > > > > + 	 * So, we use some loose way. Because we're under taslist lock, "task"
> > > > > + 	 * pointer is always safe and we can access it. So, accessing mem_cgroup
> > > > > + 	 * via task struct is safe. To check the task is mm owner, we do loose
> > > > > + 	 * check. And this is enough.
> > > > > + 	 * There is small race at updating mm->onwer but we can ignore it.
> > > > > + 	 * A problematic race here means that oom-selection logic by walking
> > > > > + 	 * task list itself is racy. We can't make any strict guarantee between
> > > > > + 	 * task's cgroup status and oom-killer selection, anyway. And, in real
> > > > > + 	 * world, this will be no problem.
> > > > > + 	 */
> > > > > +	mm = task->mm;
> > > > > +	if (!mm || mm->owner != task)
> > > > > +		return 0;
> > > > 
> > > > You can't dereference task->mm->owner without holding task_lock(task), but 
> > > > I don't see why you need to even deal with task->mm.  All callers to this 
> > > > function will check for !task->mm either during their iterations or with 
> > > > oom_kill_task() returning 0.
> > > > 
> > > Just for being careful. We don't hold task_lock(), which guards task->mm in
> > > callers.
> > > 
> > 
> > The callers don't care if it disappears out from under us since we never 
> > dereference it, it's just a sanity check to ensure we don't pick a 
> > kthread or an exiting task that won't free any memory. 
> 
> But we need the guarantee that it's safe to access mm->owner in this code.
> It's possible task->mm is set to be NULL while we come here.
> Hmm. taking task_lock() is better, finally ?
> 

That was my original point when I said you can't dereference 
task->mm->owner without task_lock(task), but I don't see why you need that 
check to begin with.

> But I don't like taking such a lock here to do easy checks..
> *maybe* I'll postpone this updates and just post original fix again.
> 

Feel free to add my

	Acked-by: David Rientjes <rientjes@google.com>

since it's a much-needed fix for memcg both in mainline and in -stable.

> There are task_lock() and task_unlock() but task_trylock() is not implemented.
> I think I shouldn't add a new trylock.

task_trylock() isn't appropriate for this usecase because it would exclude 
tasks from the iteration in select_bad_process() if its contended, i.e. we 
could panic the machine unnecessary simply because the lock is taken.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
