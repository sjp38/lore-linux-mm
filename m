Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5BA856B0082
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 04:26:06 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o199Q3HO022603
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Feb 2010 18:26:03 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 41D3545DE55
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 18:26:03 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0111045DE5B
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 18:26:03 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C32CB1DB8045
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 18:26:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B0B621DB8042
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 18:26:00 +0900 (JST)
Date: Tue, 9 Feb 2010 18:22:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
 cgroup v2
Message-Id: <20100209182235.0b8ad018.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002090018540.1119@chino.kir.corp.google.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
	<20100209120209.686c348c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002082328370.19744@chino.kir.corp.google.com>
	<20100209170228.ecee0963.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002090018540.1119@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Feb 2010 00:21:32 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:
> > > > -	task_lock(task);
> > > > +	/*
> > > > + 	 * The task's task->mm pointer is guarded by task_lock() but it's
> > > > + 	 * risky to take task_lock in oom kill situaion. Oom-killer may
> > > > + 	 * kill a task which is in unknown status and cause siginificant delay
> > > > + 	 * or deadlock.
> > > > + 	 * So, we use some loose way. Because we're under taslist lock, "task"
> > > > + 	 * pointer is always safe and we can access it. So, accessing mem_cgroup
> > > > + 	 * via task struct is safe. To check the task is mm owner, we do loose
> > > > + 	 * check. And this is enough.
> > > > + 	 * There is small race at updating mm->onwer but we can ignore it.
> > > > + 	 * A problematic race here means that oom-selection logic by walking
> > > > + 	 * task list itself is racy. We can't make any strict guarantee between
> > > > + 	 * task's cgroup status and oom-killer selection, anyway. And, in real
> > > > + 	 * world, this will be no problem.
> > > > + 	 */
> > > > +	mm = task->mm;
> > > > +	if (!mm || mm->owner != task)
> > > > +		return 0;
> > > 
> > > You can't dereference task->mm->owner without holding task_lock(task), but 
> > > I don't see why you need to even deal with task->mm.  All callers to this 
> > > function will check for !task->mm either during their iterations or with 
> > > oom_kill_task() returning 0.
> > > 
> > Just for being careful. We don't hold task_lock(), which guards task->mm in
> > callers.
> > 
> 
> The callers don't care if it disappears out from under us since we never 
> dereference it, it's just a sanity check to ensure we don't pick a 
> kthread or an exiting task that won't free any memory. 

But we need the guarantee that it's safe to access mm->owner in this code.
It's possible task->mm is set to be NULL while we come here.
Hmm. taking task_lock() is better, finally ?

But I don't like taking such a lock here to do easy checks..
*maybe* I'll postpone this updates and just post original fix again.

There are task_lock() and task_unlock() but task_trylock() is not implemented.
I think I shouldn't add a new trylock.

For mm, I'll consinder some better way to ignore mm->owner.
Maybe we can set some flag as "the task is mm_owner!" in the task struct..
it will allow us to remove task_lock here.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
