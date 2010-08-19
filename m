Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D077B6B01F5
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 04:03:10 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o7J837D7017736
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 01:03:07 -0700
Received: from pwi2 (pwi2.prod.google.com [10.241.219.2])
	by hpaq3.eem.corp.google.com with ESMTP id o7J835L3025366
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 01:03:06 -0700
Received: by pwi2 with SMTP id 2so678058pwi.4
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 01:03:05 -0700 (PDT)
Date: Thu, 19 Aug 2010 01:03:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 2/2] oom: kill all threads sharing oom killed task's
 mm
In-Reply-To: <20100819142444.5F91.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008190057450.3737@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008161810420.26680@chino.kir.corp.google.com> <alpine.DEB.2.00.1008161814450.26680@chino.kir.corp.google.com> <20100819142444.5F91.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, KOSAKI Motohiro wrote:

> > This is especially necessary to solve an mm->mmap_sem livelock issue
> > whereas an oom killed thread must acquire the lock in the exit path while
> > another thread is holding it in the page allocator while trying to
> > allocate memory itself (and will preempt the oom killer since a task was
> > already killed).  Since tasks with pending fatal signals are now granted
> > access to memory reserves, the thread holding the lock may quickly
> > allocate and release the lock so that the oom killed task may exit.
> 
> I can't understand this sentence. mm sharing is happen when vfork, That
> said, parent process is always sleeping. why do we need to worry that parent
> process is holding mmap_sem?
> 

No, I'm talking about threads with CLONE_VM and not CLONE_THREAD (or 
CLONE_VFORK, in your example).  They share the same address space but are 
in different tgid's and may sit holding mm->mmap_sem looping in the page 
allocator while we know we're oom and there's no chance of freeing any 
more memory since the oom killer doesn't kill will other tasks have yet to 
exit.

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -414,17 +414,37 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
> >  #define K(x) ((x) << (PAGE_SHIFT-10))
> >  static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
> >  {
> > +	struct task_struct *q;
> > +	struct mm_struct *mm;
> > +
> >  	p = find_lock_task_mm(p);
> >  	if (!p) {
> >  		task_unlock(p);
> >  		return 1;
> >  	}
> > +
> > +	/* mm cannot be safely dereferenced after task_unlock(p) */
> > +	mm = p->mm;
> > +
> >  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
> >  		task_pid_nr(p), p->comm, K(p->mm->total_vm),
> >  		K(get_mm_counter(p->mm, MM_ANONPAGES)),
> >  		K(get_mm_counter(p->mm, MM_FILEPAGES)));
> >  	task_unlock(p);
> >  
> > +	/*
> > +	 * Kill all processes sharing p->mm in other thread groups, if any.
> > +	 * They don't get access to memory reserves or a higher scheduler
> > +	 * priority, though, to avoid depletion of all memory or task
> > +	 * starvation.  This prevents mm->mmap_sem livelock when an oom killed
> > +	 * task cannot exit because it requires the semaphore and its contended
> > +	 * by another thread trying to allocate memory itself.  That thread will
> > +	 * now get access to memory reserves since it has a pending fatal
> > +	 * signal.
> > +	 */
> > +	for_each_process(q)
> > +		if (q->mm == mm && !same_thread_group(q, p))
> > +			force_sig(SIGKILL, q);
> 
> This makes silent process kill when vfork() is used. right?
> If so, it is wrong idea. instead, can you please write "which process was killed" log
> on each process?
> 

Sure, I'll add a pr_err() for these kills as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
