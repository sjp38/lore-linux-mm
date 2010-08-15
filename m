Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7E2BB6B01F1
	for <linux-mm@kvack.org>; Sun, 15 Aug 2010 11:48:19 -0400 (EDT)
Date: Sun, 15 Aug 2010 17:45:31 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch 2/2] oom: kill all threads sharing oom killed task's mm
Message-ID: <20100815154531.GB3531@redhat.com>
References: <alpine.DEB.2.00.1008142128050.31510@chino.kir.corp.google.com> <alpine.DEB.2.00.1008142130260.31510@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1008142130260.31510@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Again, I do not know how the code looks without the patch, but

On 08/14, David Rientjes wrote:
>
>  static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
>  {
> +	struct task_struct *g, *q;
> +	struct mm_struct *mm;
> +
>  	p = find_lock_task_mm(p);
>  	if (!p) {
>  		task_unlock(p);
>  		return 1;
>  	}
> +
> +	/* mm cannot be safely dereferenced after task_unlock(p) */

Yes. But also we can't trust this pointer, see below.

> +	mm = p->mm;
> +
>  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
>  		task_pid_nr(p), p->comm, K(p->mm->total_vm),
>  		K(get_mm_counter(p->mm, MM_ANONPAGES)),
>  		K(get_mm_counter(p->mm, MM_FILEPAGES)));
>  	task_unlock(p);
>
> -
>  	set_tsk_thread_flag(p, TIF_MEMDIE);
>  	force_sig(SIGKILL, p);

So, we killed this process. It is very possible it was the only user
of this ->mm. exit_mm() can free this mmemory. After that another task
execs, exec_mmap() can allocate the same memory again.

Now,

> @@ -438,6 +444,20 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
>  	 */
>  	boost_dying_task_prio(p, mem);
>
> +	/*
> +	 * Kill all threads sharing p->mm in other thread groups, if any.  They
> +	 * don't get access to memory reserves or a higher scheduler priority,
> +	 * though, to avoid depletion of all memory or task starvation.  This
> +	 * prevents mm->mmap_sem livelock when an oom killed task cannot exit
> +	 * because it requires the semaphore and its contended by another
> +	 * thread trying to allocate memory itself.  That thread will now get
> +	 * access to memory reserves since it has a pending fatal signal.
> +	 */
> +	do_each_thread(g, q) {
> +		if (q->mm == mm && !same_thread_group(q, p))
> +			force_sig(SIGKILL, q);
> +	} while_each_thread(g, q);

We can kill the wrong task. "q->mm == mm" doesn't necessarily mean
we found the task which shares ->mm with p (see above).

This needs atomic_inc(mm_users). And please do not use do_each_thread.


David, I apologize in advance if I won't reply to your futher emails.
I don't have the time for the kernel hacking at all.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
