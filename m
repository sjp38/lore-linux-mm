Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 56DE66B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 18:21:15 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p4NML2hg029837
	for <linux-mm@kvack.org>; Mon, 23 May 2011 15:21:04 -0700
Received: from pve37 (pve37.prod.google.com [10.241.210.37])
	by wpaz29.hot.corp.google.com with ESMTP id p4NMKbX1031965
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 15:20:56 -0700
Received: by pve37 with SMTP id 37so3950291pve.35
        for <linux-mm@kvack.org>; Mon, 23 May 2011 15:20:56 -0700 (PDT)
Date: Mon, 23 May 2011 15:20:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] oom: kill younger process first
In-Reply-To: <4DD62007.6020600@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1105231516420.17840@chino.kir.corp.google.com>
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD62007.6020600@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

On Fri, 20 May 2011, KOSAKI Motohiro wrote:

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 013314a..3698379 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2194,6 +2194,9 @@ static inline unsigned long wait_task_inactive(struct task_struct *p,
>  #define next_task(p) \
>  	list_entry_rcu((p)->tasks.next, struct task_struct, tasks)
> 
> +#define prev_task(p) \
> +	list_entry((p)->tasks.prev, struct task_struct, tasks)
> +
>  #define for_each_process(p) \
>  	for (p = &init_task ; (p = next_task(p)) != &init_task ; )
> 
> @@ -2206,6 +2209,14 @@ extern bool current_is_single_threaded(void);
>  #define do_each_thread(g, t) \
>  	for (g = t = &init_task ; (g = t = next_task(g)) != &init_task ; ) do
> 
> +/*
> + * Similar to do_each_thread(). but two difference are there.
> + *  - traverse tasks reverse order (i.e. younger to older)
> + *  - caller must hold tasklist_lock. rcu_read_lock isn't enough
> +*/
> +#define do_each_thread_reverse(g, t) \
> +	for (g = t = &init_task ; (g = t = prev_task(g)) != &init_task ; ) do
> +
>  #define while_each_thread(g, t) \
>  	while ((t = next_thread(t)) != g)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 43d32ae..e6a6c6f 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -282,7 +282,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  	struct task_struct *chosen = NULL;
>  	*ppoints = 0;
> 
> -	do_each_thread(g, p) {
> +	do_each_thread_reverse(g, p) {
>  		unsigned int points;
> 
>  		if (!p->mm)

Same response as when you initially proposed this patch: the comment needs 
to explicitly state that it is not break-safe just like do_each_thread().  
See http://marc.info/?l=linux-mm&m=130507027312785

A comment such as

	/*
	 * Reverse of do_each_thread(); still not break-safe.
	 * Must hold tasklist_lock.
	 */

would suffice.  There are no "callers" to a macro.

After that:

	Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
