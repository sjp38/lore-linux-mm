Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DFB768D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 20:21:26 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 45EA03EE0BD
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:20:31 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 12F8C45DE5E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:20:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D29A445DE5A
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:20:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B79A2E08001
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:20:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 656D7E18004
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:20:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
In-Reply-To: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com>
Message-Id: <20110303100030.B936.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Mar 2011 10:20:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Hi

> This patch revents unnecessary oom kills or kernel panics by reverting
> two commits:
> 
> 	495789a5 (oom: make oom_score to per-process value)
> 	cef1d352 (oom: multi threaded process coredump don't make deadlock)
> 
> First, 495789a5 (oom: make oom_score to per-process value) ignores the
> fact that all threads in a thread group do not necessarily exit at the
> same time.
> 
> It is imperative that select_bad_process() detect threads that are in the
> exit path, specifically those with PF_EXITING set, to prevent needlessly
> killing additional tasks.  

to prevent? No, it is not a reason of PF_EXITING exist.


> If a process is oom killed and the thread
> group leader exits, select_bad_process() cannot detect the other threads
> that are PF_EXITING by iterating over only processes.  Thus, it currently
> chooses another task unnecessarily for oom kill or panics the machine
> when nothing else is eligible.
> 
> By iterating over threads instead, it is possible to detect threads that
> are exiting and nominate them for oom kill so they get access to memory
> reserves.

In fact, PF_EXITING is a sing of *THREAD* exiting, not process. Therefore
PF_EXITING is not a sign of memory freeing in nearly future. If other
CPUs don't try to free memory, prevent oom and waiting makes deadlock.

Thus, I suggest to remove PF_EXITING check completely.

> 
> Second, cef1d352 (oom: multi threaded process coredump don't make
> deadlock) erroneously avoids making the oom killer a no-op when an
> eligible thread other than current isfound to be exiting.  We want to
> detect this situation so that we may allow that exiting thread time to
> exit and free its memory; if it is able to exit on its own, that should
> free memory so current is no loner oom.  If it is not able to exit on its
> own, the oom killer will nominate it for oom kill which, in this case,
> only means it will get access to memory reserves.
> 
> Without this change, it is easy for the oom killer to unnecessarily
> target tasks when all threads of a victim don't exit before the thread
> group leader or, in the worst case, panic the machine.
> 

You missed deadlock is more worse than panic. And again, task overkill
is a part of OOM killer design. it is necessary to avoid deadlock. If
you want to change this spec, you need to remove deadlock change at first.


> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -292,11 +292,11 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		unsigned long totalpages, struct mem_cgroup *mem,
>  		const nodemask_t *nodemask)
>  {
> -	struct task_struct *p;
> +	struct task_struct *g, *p;
>  	struct task_struct *chosen = NULL;
>  	*ppoints = 0;
>  
> -	for_each_process(p) {
> +	do_each_thread(g, p) {
>  		unsigned int points;
>  
>  		if (oom_unkillable_task(p, mem, nodemask))
> @@ -324,7 +324,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		 * the process of exiting and releasing its resources.
>  		 * Otherwise we could get an easy OOM deadlock.
>  		 */
> -		if (thread_group_empty(p) && (p->flags & PF_EXITING) && p->mm) {
> +		if ((p->flags & PF_EXITING) && p->mm) {
>
>  			if (p != current)
>  				return ERR_PTR(-1UL);
>  
> @@ -337,7 +337,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  			chosen = p;
>  			*ppoints = points;
>  		}
> -	}
> +	} while_each_thread(g, p);
>  
>  	return chosen;
>  }



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
