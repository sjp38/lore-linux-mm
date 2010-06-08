Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B2B7F6B01E8
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:03 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bg1BC014526
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:42:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BE76C45DE51
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 92BE445DE4F
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D2A71DB801A
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D9F091DB8016
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 08/18] oom: sacrifice child with highest badness score for parent
In-Reply-To: <alpine.DEB.2.00.1006061524470.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524470.32225@chino.kir.corp.google.com>
Message-Id: <20100608203443.7666.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> When a task is chosen for oom kill, the oom killer first attempts to
> sacrifice a child not sharing its parent's memory instead.  Unfortunately,
> this often kills in a seemingly random fashion based on the ordering of
> the selected task's child list.  Additionally, it is not guaranteed at all
> to free a large amount of memory that we need to prevent additional oom
> killing in the very near future.
> 
> Instead, we now only attempt to sacrifice the worst child not sharing its
> parent's memory, if one exists.  The worst child is indicated with the
> highest badness() score.  This serves two advantages: we kill a
> memory-hogging task more often, and we allow the configurable
> /proc/pid/oom_adj value to be considered as a factor in which child to
> kill.
> 
> Reviewers may observe that the previous implementation would iterate
> through the children and attempt to kill each until one was successful and
> then the parent if none were found while the new code simply kills the
> most memory-hogging task or the parent.  Note that the only time
> oom_kill_task() fails, however, is when a child does not have an mm or has
> a /proc/pid/oom_adj of OOM_DISABLE.  badness() returns 0 for both cases,
> so the final oom_kill_task() will always succeed.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Nick Piggin <npiggin@suse.de>
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |   23 +++++++++++++++++------
>  1 files changed, 17 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -441,8 +441,11 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  			    unsigned long points, struct mem_cgroup *mem,
>  			    const char *message)
>  {
> +	struct task_struct *victim = p;
>  	struct task_struct *c;
>  	struct task_struct *t = p;
> +	unsigned long victim_points = 0;
> +	struct timespec uptime;
>  
>  	if (printk_ratelimit())
>  		dump_header(p, gfp_mask, order, mem);
> @@ -456,22 +459,30 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		return 0;
>  	}
>  
> -	printk(KERN_ERR "%s: kill process %d (%s) score %li or a child\n",
> -					message, task_pid_nr(p), p->comm, points);
> +	pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
> +		message, task_pid_nr(p), p->comm, points);
>  
> -	/* Try to kill a child first */
> +	/* Try to sacrifice the worst child first */
> +	do_posix_clock_monotonic_gettime(&uptime);
>  	do {
> +		unsigned long cpoints;
> +
>  		list_for_each_entry(c, &t->children, sibling) {
>  			if (c->mm == p->mm)
>  				continue;
>  			if (mem && !task_in_mem_cgroup(c, mem))
>  				continue;
> -			if (!oom_kill_task(c))
> -				return 0;
> +
> +			/* badness() returns 0 if the thread is unkillable */
> +			cpoints = badness(c, uptime.tv_sec);
> +			if (cpoints > victim_points) {
> +				victim = c;
> +				victim_points = cpoints;
> +			}
>  		}
>  	} while_each_thread(p, t);
>  
> -	return oom_kill_task(p);
> +	return oom_kill_task(victim);
>  }
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR

better version already is there in my patch kit.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
