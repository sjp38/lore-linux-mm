Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D99A56B01F5
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 04:10:39 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7J8Aaqd006922
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 19 Aug 2010 17:10:37 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B4FF45DE56
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 17:10:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3576A45DE50
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 17:10:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 030791DB8018
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 17:10:36 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 741E71DB8017
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 17:10:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch v2 2/2] oom: kill all threads sharing oom killed task's mm
In-Reply-To: <alpine.DEB.2.00.1008190057450.3737@chino.kir.corp.google.com>
References: <20100819142444.5F91.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1008190057450.3737@chino.kir.corp.google.com>
Message-Id: <20100819170642.5FAE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 19 Aug 2010 17:10:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 19 Aug 2010, KOSAKI Motohiro wrote:
> 
> > > This is especially necessary to solve an mm->mmap_sem livelock issue
> > > whereas an oom killed thread must acquire the lock in the exit path while
> > > another thread is holding it in the page allocator while trying to
> > > allocate memory itself (and will preempt the oom killer since a task was
> > > already killed).  Since tasks with pending fatal signals are now granted
> > > access to memory reserves, the thread holding the lock may quickly
> > > allocate and release the lock so that the oom killed task may exit.
> > 
> > I can't understand this sentence. mm sharing is happen when vfork, That
> > said, parent process is always sleeping. why do we need to worry that parent
> > process is holding mmap_sem?
> > 
> 
> No, I'm talking about threads with CLONE_VM and not CLONE_THREAD (or 
> CLONE_VFORK, in your example).  They share the same address space but are 
> in different tgid's and may sit holding mm->mmap_sem looping in the page 
> allocator while we know we're oom and there's no chance of freeing any 
> more memory since the oom killer doesn't kill will other tasks have yet to 
> exit.

Why don't you use pthread library? Is there any good reason? That said,
If you are trying to optimize neither thread nor vfork case, I'm not charmed
this because 99.99% user don't use it. but even though every user will get 
performance degression. Can you please consider typical use case optimization?



> 
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -414,17 +414,37 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
> > >  #define K(x) ((x) << (PAGE_SHIFT-10))
> > >  static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
> > >  {
> > > +	struct task_struct *q;
> > > +	struct mm_struct *mm;
> > > +
> > >  	p = find_lock_task_mm(p);
> > >  	if (!p) {
> > >  		task_unlock(p);
> > >  		return 1;
> > >  	}
> > > +
> > > +	/* mm cannot be safely dereferenced after task_unlock(p) */
> > > +	mm = p->mm;
> > > +
> > >  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
> > >  		task_pid_nr(p), p->comm, K(p->mm->total_vm),
> > >  		K(get_mm_counter(p->mm, MM_ANONPAGES)),
> > >  		K(get_mm_counter(p->mm, MM_FILEPAGES)));
> > >  	task_unlock(p);
> > >  
> > > +	/*
> > > +	 * Kill all processes sharing p->mm in other thread groups, if any.
> > > +	 * They don't get access to memory reserves or a higher scheduler
> > > +	 * priority, though, to avoid depletion of all memory or task
> > > +	 * starvation.  This prevents mm->mmap_sem livelock when an oom killed
> > > +	 * task cannot exit because it requires the semaphore and its contended
> > > +	 * by another thread trying to allocate memory itself.  That thread will
> > > +	 * now get access to memory reserves since it has a pending fatal
> > > +	 * signal.
> > > +	 */
> > > +	for_each_process(q)
> > > +		if (q->mm == mm && !same_thread_group(q, p))
> > > +			force_sig(SIGKILL, q);
> > 
> > This makes silent process kill when vfork() is used. right?
> > If so, it is wrong idea. instead, can you please write "which process was killed" log
> > on each process?
> > 
> 
> Sure, I'll add a pr_err() for these kills as well.

ok, thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
