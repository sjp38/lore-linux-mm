Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 98CC5900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:01:52 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p5MN1iZg018438
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:01:44 -0700
Received: from pve37 (pve37.prod.google.com [10.241.210.37])
	by hpaq14.eem.corp.google.com with ESMTP id p5MN1HKN025939
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:01:42 -0700
Received: by pve37 with SMTP id 37so1113143pve.21
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:01:37 -0700 (PDT)
Date: Wed, 22 Jun 2011 16:01:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/6] oom: kill younger process first
In-Reply-To: <4E01C84A.60400@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1106221600050.11759@chino.kir.corp.google.com>
References: <4E01C7D5.3060603@jp.fujitsu.com> <4E01C84A.60400@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, caiqian@redhat.com, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Oleg Nesterov <oleg@redhat.com>

On Wed, 22 Jun 2011, KOSAKI Motohiro wrote:

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index e4e6d7b..392ff30 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2257,6 +2257,9 @@ static inline unsigned long wait_task_inactive(struct task_struct *p,
>  #define next_task(p) \
>  	list_entry_rcu((p)->tasks.next, struct task_struct, tasks)
> 
> +#define prev_task(p) \
> +	list_entry((p)->tasks.prev, struct task_struct, tasks)
> +
>  #define for_each_process(p) \
>  	for (p = &init_task ; (p = next_task(p)) != &init_task ; )
> 
> @@ -2269,6 +2272,14 @@ extern bool current_is_single_threaded(void);
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

I've already ack'd the patch, but if there is another version posted as a 
result of our discussion of using euid in the heuristic, I think it would 
be helpful to reiterate in this comment that, like do_each_thread(), 
do_each_thread_reverse() is not break-safe either.  It might end up 
preventing a bug down the road.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
