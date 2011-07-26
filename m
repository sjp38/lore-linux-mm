Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8B11C6B0169
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 11:27:27 -0400 (EDT)
Date: Tue, 26 Jul 2011 17:27:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] oom: avoid killing kthreads if they assume the oom
 killed thread's mm
Message-ID: <20110726152724.GE17958@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1107251711460.26480@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1107251711460.26480@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Mon 25-07-11 17:12:37, David Rientjes wrote:
> After selecting a task to kill, the oom killer iterates all processes and
> kills all other threads that share the same mm_struct in different thread
> groups.  It would not otherwise be helpful to kill a thread if its memory
> would not be subsequently freed.
> 
> A kernel thread, however, may assume a user thread's mm by using
> use_mm().  This is only temporary and should not result in sending a
> SIGKILL to that kthread.

Good catch. Have you ever seen this happening?

> 
> This patch ensures that only user threads and not kthreads are sent a
> SIGKILL if they share the same mm_struct as the oom killed task.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/oom_kill.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -433,7 +433,7 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
>  	task_unlock(p);
>  
>  	/*
> -	 * Kill all processes sharing p->mm in other thread groups, if any.
> +	 * Kill all user processes sharing p->mm in other thread groups, if any.
>  	 * They don't get access to memory reserves or a higher scheduler
>  	 * priority, though, to avoid depletion of all memory or task
>  	 * starvation.  This prevents mm->mmap_sem livelock when an oom killed
> @@ -443,7 +443,8 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
>  	 * signal.
>  	 */
>  	for_each_process(q)
> -		if (q->mm == mm && !same_thread_group(q, p)) {
> +		if (q->mm == mm && !same_thread_group(q, p) &&
> +		    !(q->flags & PF_KTHREAD)) {
>  			task_lock(q);	/* Protect ->comm from prctl() */
>  			pr_err("Kill process %d (%s) sharing same memory\n",
>  				task_pid_nr(q), q->comm);
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
