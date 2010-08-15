Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 536A16B01F1
	for <linux-mm@kvack.org>; Sun, 15 Aug 2010 17:28:25 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o7FLSMVG030985
	for <linux-mm@kvack.org>; Sun, 15 Aug 2010 14:28:22 -0700
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by kpbe14.cbf.corp.google.com with ESMTP id o7FLSLpd020758
	for <linux-mm@kvack.org>; Sun, 15 Aug 2010 14:28:21 -0700
Received: by pwj3 with SMTP id 3so1824916pwj.9
        for <linux-mm@kvack.org>; Sun, 15 Aug 2010 14:28:21 -0700 (PDT)
Date: Sun, 15 Aug 2010 14:28:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2] oom: kill all threads sharing oom killed task's mm
In-Reply-To: <20100815154531.GB3531@redhat.com>
Message-ID: <alpine.DEB.2.00.1008151425271.8727@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008142128050.31510@chino.kir.corp.google.com> <alpine.DEB.2.00.1008142130260.31510@chino.kir.corp.google.com> <20100815154531.GB3531@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 15 Aug 2010, Oleg Nesterov wrote:

> Again, I do not know how the code looks without the patch, but
> 

Why not?  This series is based on Linus' tree.

> >  static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
> >  {
> > +	struct task_struct *g, *q;
> > +	struct mm_struct *mm;
> > +
> >  	p = find_lock_task_mm(p);
> >  	if (!p) {
> >  		task_unlock(p);
> >  		return 1;
> >  	}
> > +
> > +	/* mm cannot be safely dereferenced after task_unlock(p) */
> 
> Yes. But also we can't trust this pointer, see below.
> 
> > +	mm = p->mm;
> > +
> >  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
> >  		task_pid_nr(p), p->comm, K(p->mm->total_vm),
> >  		K(get_mm_counter(p->mm, MM_ANONPAGES)),
> >  		K(get_mm_counter(p->mm, MM_FILEPAGES)));
> >  	task_unlock(p);
> >
> > -
> >  	set_tsk_thread_flag(p, TIF_MEMDIE);
> >  	force_sig(SIGKILL, p);
> 
> So, we killed this process. It is very possible it was the only user
> of this ->mm. exit_mm() can free this mmemory. After that another task
> execs, exec_mmap() can allocate the same memory again.
> 

Right, this was a race in the original code as well before it was removed 
in 8c5cd6f3 and existed for years.

> > @@ -438,6 +444,20 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
> >  	 */
> >  	boost_dying_task_prio(p, mem);
> >
> > +	/*
> > +	 * Kill all threads sharing p->mm in other thread groups, if any.  They
> > +	 * don't get access to memory reserves or a higher scheduler priority,
> > +	 * though, to avoid depletion of all memory or task starvation.  This
> > +	 * prevents mm->mmap_sem livelock when an oom killed task cannot exit
> > +	 * because it requires the semaphore and its contended by another
> > +	 * thread trying to allocate memory itself.  That thread will now get
> > +	 * access to memory reserves since it has a pending fatal signal.
> > +	 */
> > +	do_each_thread(g, q) {
> > +		if (q->mm == mm && !same_thread_group(q, p))
> > +			force_sig(SIGKILL, q);
> > +	} while_each_thread(g, q);
> 
> We can kill the wrong task. "q->mm == mm" doesn't necessarily mean
> we found the task which shares ->mm with p (see above).
> 
> This needs atomic_inc(mm_users). And please do not use do_each_thread.
> 

Instead of using mm_users to pin the mm, we could simply do this iteration 
with for_each_process() before sending the SIGKILL to p.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
