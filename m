Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BF3706B007B
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 19:16:09 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C0G6ZL013464
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 09:16:06 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 20CDB45DE4F
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 09:16:06 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 058B445DE4E
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 09:16:06 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D35561DB8037
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 09:16:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DE731DB803F
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 09:16:05 +0900 (JST)
Date: Fri, 12 Feb 2010 09:12:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 7/7 -mm] oom: remove unnecessary code and cleanup
Message-Id: <20100212091237.adb94384.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002100230010.8001@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002100230010.8001@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Feb 2010 08:32:24 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> Remove the redundancy in __oom_kill_task() since:
> 
>  - init can never be passed to this function: it will never be PF_EXITING
>    or selectable from select_bad_process(), and
> 
>  - it will never be passed a task from oom_kill_task() without an ->mm
>    and we're unconcerned about detachment from exiting tasks, there's no
>    reason to protect them against SIGKILL or access to memory reserves.
> 
> Also moves the kernel log message to a higher level since the verbosity
> is not always emitted here; we need not print an error message if an
> exiting task is given a longer timeslice.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

If you say "never", it's better to add BUG_ON() rather than 
if (!p->mm)...

But yes, this patch seesm to remove unnecessary codes.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/oom_kill.c |   64 ++++++++++++++------------------------------------------
>  1 files changed, 16 insertions(+), 48 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -400,67 +400,35 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>  		dump_tasks(mem);
>  }
>  
> -#define K(x) ((x) << (PAGE_SHIFT-10))
> -
>  /*
> - * Send SIGKILL to the selected  process irrespective of  CAP_SYS_RAW_IO
> - * flag though it's unlikely that  we select a process with CAP_SYS_RAW_IO
> - * set.
> + * Give the oom killed task high priority and access to memory reserves so that
> + * it may quickly exit and free its memory.
>   */
> -static void __oom_kill_task(struct task_struct *p, int verbose)
> +static void __oom_kill_task(struct task_struct *p)
>  {
> -	if (is_global_init(p)) {
> -		WARN_ON(1);
> -		printk(KERN_WARNING "tried to kill init!\n");
> -		return;
> -	}
> -
> -	task_lock(p);
> -	if (!p->mm) {
> -		WARN_ON(1);
> -		printk(KERN_WARNING "tried to kill an mm-less task %d (%s)!\n",
> -			task_pid_nr(p), p->comm);
> -		task_unlock(p);
> -		return;
> -	}
> -
> -	if (verbose)
> -		printk(KERN_ERR "Killed process %d (%s) "
> -		       "vsz:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
> -		       task_pid_nr(p), p->comm,
> -		       K(p->mm->total_vm),
> -		       K(get_mm_counter(p->mm, MM_ANONPAGES)),
> -		       K(get_mm_counter(p->mm, MM_FILEPAGES)));
> -	task_unlock(p);
> -
> -	/*
> -	 * We give our sacrificial lamb high priority and access to
> -	 * all the memory it needs. That way it should be able to
> -	 * exit() and clear out its resources quickly...
> -	 */
>  	p->rt.time_slice = HZ;
>  	set_tsk_thread_flag(p, TIF_MEMDIE);
> -
>  	force_sig(SIGKILL, p);
>  }
>  
> +#define K(x) ((x) << (PAGE_SHIFT-10))
>  static int oom_kill_task(struct task_struct *p)
>  {
> -	/* WARNING: mm may not be dereferenced since we did not obtain its
> -	 * value from get_task_mm(p).  This is OK since all we need to do is
> -	 * compare mm to q->mm below.
> -	 *
> -	 * Furthermore, even if mm contains a non-NULL value, p->mm may
> -	 * change to NULL at any time since we do not hold task_lock(p).
> -	 * However, this is of no concern to us.
> -	 */
> -	if (!p->mm || p->signal->oom_adj == OOM_DISABLE)
> +	task_lock(p);
> +	if (!p->mm || p->signal->oom_adj == OOM_DISABLE) {
> +		task_unlock(p);
>  		return 1;
> +	}
> +	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
> +		task_pid_nr(p), p->comm, K(p->mm->total_vm),
> +	       K(get_mm_counter(p->mm, MM_ANONPAGES)),
> +	       K(get_mm_counter(p->mm, MM_FILEPAGES)));
> +	task_unlock(p);
>  
> -	__oom_kill_task(p, 1);
> -
> +	__oom_kill_task(p);
>  	return 0;
>  }
> +#undef K
>  
>  static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  			    unsigned int points, unsigned long totalpages,
> @@ -479,7 +447,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>  	 */
>  	if (p->flags & PF_EXITING) {
> -		__oom_kill_task(p, 0);
> +		__oom_kill_task(p);
>  		return 0;
>  	}
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
