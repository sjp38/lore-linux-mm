Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id E5D786B005A
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 23:49:28 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D0C793EE0AE
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:49:26 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B92D245DE5E
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:49:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EE6345DE5D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:49:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FDA31DB8053
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:49:26 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 40DC51DB8043
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:49:26 +0900 (JST)
Date: Thu, 12 Jan 2012 13:48:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/3] mm, oom: fold oom_kill_task into oom_kill_process
Message-Id: <20120112134814.a24fda31.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1201111923490.3982@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1201111922500.3982@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1201111923490.3982@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, 11 Jan 2012 19:24:24 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> oom_kill_task() has a single caller, so fold it into its parent function,
> oom_kill_process().  Slightly reduces the number of lines in the oom
> killer.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/oom_kill.c |   87 ++++++++++++++++++++++++++------------------------------
>  1 files changed, 40 insertions(+), 47 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -434,52 +434,6 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>  }
>  
>  #define K(x) ((x) << (PAGE_SHIFT-10))
> -static void oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
> -{
> -	struct task_struct *q;
> -	struct mm_struct *mm;
> -
> -	p = find_lock_task_mm(p);
> -	if (!p)
> -		return;
> -
> -	/* mm cannot be safely dereferenced after task_unlock(p) */
> -	mm = p->mm;
> -
> -	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
> -		task_pid_nr(p), p->comm, K(p->mm->total_vm),
> -		K(get_mm_counter(p->mm, MM_ANONPAGES)),
> -		K(get_mm_counter(p->mm, MM_FILEPAGES)));
> -	task_unlock(p);
> -
> -	/*
> -	 * Kill all user processes sharing p->mm in other thread groups, if any.
> -	 * They don't get access to memory reserves or a higher scheduler
> -	 * priority, though, to avoid depletion of all memory or task
> -	 * starvation.  This prevents mm->mmap_sem livelock when an oom killed
> -	 * task cannot exit because it requires the semaphore and its contended
> -	 * by another thread trying to allocate memory itself.  That thread will
> -	 * now get access to memory reserves since it has a pending fatal
> -	 * signal.
> -	 */
> -	for_each_process(q)
> -		if (q->mm == mm && !same_thread_group(q, p) &&
> -		    !(q->flags & PF_KTHREAD)) {
> -			if (q->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> -				continue;
> -
> -			task_lock(q);	/* Protect ->comm from prctl() */
> -			pr_err("Kill process %d (%s) sharing same memory\n",
> -				task_pid_nr(q), q->comm);
> -			task_unlock(q);
> -			force_sig(SIGKILL, q);
> -		}
> -
> -	set_tsk_thread_flag(p, TIF_MEMDIE);
> -	force_sig(SIGKILL, p);
> -}
> -#undef K
> -
>  static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  			     unsigned int points, unsigned long totalpages,
>  			     struct mem_cgroup *mem, nodemask_t *nodemask,
> @@ -488,6 +442,7 @@ static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	struct task_struct *victim = p;
>  	struct task_struct *child;
>  	struct task_struct *t = p;
> +	struct mm_struct *mm;
>  	unsigned int victim_points = 0;
>  
>  	if (printk_ratelimit())
> @@ -531,8 +486,46 @@ static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		}
>  	} while_each_thread(p, t);
>  
> -	oom_kill_task(victim, mem);
> +	victim = find_lock_task_mm(victim);
> +	if (!victim)
> +		return;
> +
> +	/* mm cannot be safely dereferenced after task_unlock(p) */
> +	mm = victim->mm;
> +
> +	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
> +		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
> +		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> +		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
> +	task_unlock(victim);
> +
> +	/*
> +	 * Kill all user processes sharing victim->mm in other thread groups, if 
> +	 * any.  They don't get access to memory reserves or a higher scheduler
> +	 * priority, though, to avoid depletion of all memory or task
> +	 * starvation.  This prevents mm->mmap_sem livelock when an oom killed
> +	 * task cannot exit because it requires the semaphore and its contended
> +	 * by another thread trying to allocate memory itself.  That thread will
> +	 * now get access to memory reserves since it has a pending fatal
> +	 * signal.
> +	 */
> +	for_each_process(p)
> +		if (p->mm == mm && !same_thread_group(p, victim) &&
> +		    !(p->flags & PF_KTHREAD)) {
> +			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> +				continue;
> +
> +			task_lock(p);	/* Protect ->comm from prctl() */
> +			pr_err("Kill process %d (%s) sharing same memory\n",
> +				task_pid_nr(p), p->comm);
> +			task_unlock(p);
> +			force_sig(SIGKILL, p);
> +		}
> +
> +	set_tsk_thread_flag(victim, TIF_MEMDIE);
> +	force_sig(SIGKILL, victim);
>  }
> +#undef K
>  
>  /*
>   * Determines whether the kernel must panic because of the panic_on_oom sysctl.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
