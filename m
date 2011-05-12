Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 920B36B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 20:59:30 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 747C93EE0C1
	for <linux-mm@kvack.org>; Thu, 12 May 2011 09:59:26 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5958145DE61
	for <linux-mm@kvack.org>; Thu, 12 May 2011 09:59:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3675545DD74
	for <linux-mm@kvack.org>; Thu, 12 May 2011 09:59:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 29D181DB803F
	for <linux-mm@kvack.org>; Thu, 12 May 2011 09:59:26 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D78C21DB802C
	for <linux-mm@kvack.org>; Thu, 12 May 2011 09:59:25 +0900 (JST)
Date: Thu, 12 May 2011 09:52:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] oom: kill younger process first
Message-Id: <20110512095243.c57e3e83.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110510171641.16AF.A69D9226@jp.fujitsu.com>
References: <20110509182110.167F.A69D9226@jp.fujitsu.com>
	<20110510171335.16A7.A69D9226@jp.fujitsu.com>
	<20110510171641.16AF.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Tue, 10 May 2011 17:15:01 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> This patch introduces do_each_thread_reverse() and
> select_bad_process() uses it. The benefits are two,
> 1) oom-killer can kill younger process than older if
> they have a same oom score. Usually younger process
> is less important. 2) younger task often have PF_EXITING
> because shell script makes a lot of short lived processes.
> Reverse order search can detect it faster.
> 
> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

IIUC, for_each_thread() can be called under rcu_read_lock() but 
for_each_thread_reverse() must be under tasklist_lock.

Could you add some comment ? and prev_task() should use list_entry()
not list_entry_rcu().

Thanks,
-Kame

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
> -- 
> 1.7.3.1
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
