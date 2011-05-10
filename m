Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 87D1D6B0012
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:31:14 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p4ANVCQq027216
	for <linux-mm@kvack.org>; Tue, 10 May 2011 16:31:12 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by wpaz5.hot.corp.google.com with ESMTP id p4ANVAEG030294
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 May 2011 16:31:11 -0700
Received: by pxi10 with SMTP id 10so5095956pxi.22
        for <linux-mm@kvack.org>; Tue, 10 May 2011 16:31:10 -0700 (PDT)
Date: Tue, 10 May 2011 16:31:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/4] oom: kill younger process first
In-Reply-To: <20110510171641.16AF.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1105101629590.12477@chino.kir.corp.google.com>
References: <20110509182110.167F.A69D9226@jp.fujitsu.com> <20110510171335.16A7.A69D9226@jp.fujitsu.com> <20110510171641.16AF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Tue, 10 May 2011, KOSAKI Motohiro wrote:

> This patch introduces do_each_thread_reverse() and
> select_bad_process() uses it. The benefits are two,
> 1) oom-killer can kill younger process than older if
> they have a same oom score. Usually younger process
> is less important. 2) younger task often have PF_EXITING
> because shell script makes a lot of short lived processes.
> Reverse order search can detect it faster.
> 

I like this change, thanks!  I'm suprised we haven't needed a 
do_each_thread_reverse() in the past somewhere else in the kernel.

Could you update the comment about do_each_thread() not being break-safe 
in the second version, though?

After that:

	Acked-by: David Rientjes <rientjes@google.com>

> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  include/linux/sched.h |    6 ++++++
>  mm/oom_kill.c         |    2 +-
>  2 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 013314a..a0a8339 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2194,6 +2194,9 @@ static inline unsigned long wait_task_inactive(struct task_struct *p,
>  #define next_task(p) \
>  	list_entry_rcu((p)->tasks.next, struct task_struct, tasks)
>  
> +#define prev_task(p) \
> +	list_entry_rcu((p)->tasks.prev, struct task_struct, tasks)
> +
>  #define for_each_process(p) \
>  	for (p = &init_task ; (p = next_task(p)) != &init_task ; )
>  
> @@ -2206,6 +2209,9 @@ extern bool current_is_single_threaded(void);
>  #define do_each_thread(g, t) \
>  	for (g = t = &init_task ; (g = t = next_task(g)) != &init_task ; ) do
>  
> +#define do_each_thread_reverse(g, t) \
> +	for (g = t = &init_task ; (g = t = prev_task(g)) != &init_task ; ) do
> +
>  #define while_each_thread(g, t) \
>  	while ((t = next_thread(t)) != g)
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 118d958..0cf5091 100644
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
