Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4163B6B037C
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 05:49:10 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7M9n6ZN026283
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 22 Aug 2010 18:49:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 269D945DE4F
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 18:49:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EF05F45DE4E
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 18:49:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D493C1DB8038
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 18:49:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CD811DB8037
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 18:49:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 2/3 v3] oom: avoid killing a task if a thread sharing its mm cannot be killed
In-Reply-To: <alpine.DEB.2.00.1008201541000.9201@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com> <alpine.DEB.2.00.1008201541000.9201@chino.kir.corp.google.com>
Message-Id: <20100822184526.600F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 22 Aug 2010 18:49:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> The oom killer's goal is to kill a memory-hogging task so that it may
> exit, free its memory, and allow the current context to allocate the
> memory that triggered it in the first place.  Thus, killing a task is
> pointless if other threads sharing its mm cannot be killed because of its
> /proc/pid/oom_adj or /proc/pid/oom_score_adj value.
> 
> This patch checks whether any other thread sharing p->mm has an
> oom_score_adj of OOM_SCORE_ADJ_MIN.  If so, the thread cannot be killed
> and oom_badness(p) returns 0, meaning it's unkillable.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -162,10 +162,11 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  		return 0;
>  
>  	/*
> -	 * Shortcut check for OOM_SCORE_ADJ_MIN so the entire heuristic doesn't
> -	 * need to be executed for something that cannot be killed.
> +	 * Shortcut check for a thread sharing p->mm that is OOM_SCORE_ADJ_MIN
> +	 * so the entire heuristic doesn't need to be executed for something
> +	 * that cannot be killed.
>  	 */
> -	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> +	if (atomic_read(&p->mm->oom_disable_count)) {
>  		task_unlock(p);
>  		return 0;
>  	}
> @@ -675,7 +676,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	read_lock(&tasklist_lock);
>  	if (sysctl_oom_kill_allocating_task &&
>  	    !oom_unkillable_task(current, NULL, nodemask) &&
> -	    (current->signal->oom_adj != OOM_DISABLE)) {
> +	    current->mm && !atomic_read(&current->mm->oom_disable_count)) {
>  		/*
>  		 * oom_kill_process() needs tasklist_lock held.  If it returns
>  		 * non-zero, current could not be killed so we must fallback to

This seems significantly cleaner than previous. Of cource, even though I need 
to review [1/3] carefully. Unfortunatelly I'm very busy in this week, then
my responce might late a while. but it's not mean silinetly nak.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
