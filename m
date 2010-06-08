Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 599D56B01D9
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 16:34:17 -0400 (EDT)
Date: Tue, 8 Jun 2010 13:33:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 08/18] oom: sacrifice child with highest badness score
 for parent
Message-Id: <20100608133356.6e941d20.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061524470.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061524470.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:28 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

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

fyi, access to another task's ->comm is racy against prctl().  Fixable
with get_task_comm().  But that takes task_lock(), which is risky in
this code.  The world wouldn't end if we didn't fix this ;)

> -	/* Try to kill a child first */
> +	/* Try to sacrifice the worst child first */
> +	do_posix_clock_monotonic_gettime(&uptime);
>  	do {
> +		unsigned long cpoints;

This could be local to the list_for_each_entry() block.

What does "cpoints" mean?

>  		list_for_each_entry(c, &t->children, sibling) {

I'm surprised we don't have a sched.h helper for this.  Maybe it's not
a very common thing to do.

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

And this function is secretly called under tasklist_lock, which is what
pins *victim, yes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
