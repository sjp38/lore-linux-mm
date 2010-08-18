Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EBCFA6B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 22:12:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7I2Cc2W018815
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 18 Aug 2010 11:12:38 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0507645DE51
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:12:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D113745DE4F
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:12:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B8DE81DB803A
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:12:37 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 642A41DB803C
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:12:37 +0900 (JST)
Date: Wed, 18 Aug 2010 11:07:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch v2 1/2] oom: avoid killing a task if a thread sharing
 its mm cannot be killed
Message-Id: <20100818110746.5c030b34.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1008161810420.26680@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008161810420.26680@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 2010 18:15:57 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> The oom killer's goal is to kill a memory-hogging task so that it may
> exit, free its memory, and allow the current context to allocate the
> memory that triggered it in the first place.  Thus, killing a task is
> pointless if other threads sharing its mm cannot be killed because of its
> /proc/pid/oom_adj or /proc/pid/oom_score_adj value.
> 
> This patch checks all user threads on the system to determine whether
> oom_badness(p) should return 0 for p, which means it should not be killed.
> If a thread shares p's mm and is unkillable, p is considered to be
> unkillable as well.
> 
> Kthreads are not considered toward this rule since they only temporarily
> assume a task's mm via use_mm().
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thank you. BTW, do you have good idea for speed-up ?
This code seems terribly slow when a system has many processes.



> ---
>  v2: change do_each_thread() to for_each_process() as suggested by Oleg.
> 
>  It's actually not possible to move this logic to oom_kill_task() because
>  it's racy: oom_badness() is not a constant score and depends on the state 
>  of the VM when it is called.  This leads to unnecessarily panicking the 
>  machine in that case as wel as when the same child to sacrifice is 
>  repeatedly selected in oom_kill_process() based on the parent's badness 
>  score.
> 
>  mm/oom_kill.c |   28 +++++++++++++++++++++-------
>  1 files changed, 21 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -83,6 +83,25 @@ static bool has_intersects_mems_allowed(struct task_struct *tsk,
>  #endif /* CONFIG_NUMA */
>  
>  /*
> + * Determines whether an mm is unfreeable since a user thread attached to
> + * it cannot be killed.  Kthreads only temporarily assume a thread's mm,
> + * so they are not considered.
> + *
> + * mm need not be protected by task_lock() since it will not be
> + * dereferened.
> + */
> +static bool is_mm_unfreeable(struct mm_struct *mm)
> +{
> +	struct task_struct *p;
> +
> +	for_each_process(p)
> +		if (p->mm == mm && !(p->flags & PF_KTHREAD) &&
> +		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> +			return true;
> +	return false;
> +}
> +
> +/*
>   * If this is a system OOM (not a memcg OOM) and the task selected to be
>   * killed is not already running at high (RT) priorities, speed up the
>   * recovery by boosting the dying task to the lowest FIFO priority.
> @@ -160,12 +179,7 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  	p = find_lock_task_mm(p);
>  	if (!p)
>  		return 0;
> -
> -	/*
> -	 * Shortcut check for OOM_SCORE_ADJ_MIN so the entire heuristic doesn't
> -	 * need to be executed for something that cannot be killed.
> -	 */
> -	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> +	if (is_mm_unfreeable(p->mm)) {
>  		task_unlock(p);
>  		return 0;
>  	}
> @@ -675,7 +689,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	read_lock(&tasklist_lock);
>  	if (sysctl_oom_kill_allocating_task &&
>  	    !oom_unkillable_task(current, NULL, nodemask) &&
> -	    (current->signal->oom_adj != OOM_DISABLE)) {
> +	    !is_mm_unfreeable(current->mm)) {
>  		/*
>  		 * oom_kill_process() needs tasklist_lock held.  If it returns
>  		 * non-zero, current could not be killed so we must fallback to
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
