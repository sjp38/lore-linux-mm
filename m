Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 91F556B0078
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 19:03:41 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C03dZF008301
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 09:03:39 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D2BEA45DE55
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 09:03:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B09F745DE4E
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 09:03:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 922351DB803B
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 09:03:38 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E3FD1DB8038
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 09:03:38 +0900 (JST)
Date: Fri, 12 Feb 2010 09:00:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/7 -mm] oom: sacrifice child with highest badness score
 for parent
Message-Id: <20100212090009.3e5b8738.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002100228240.8001@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002100228240.8001@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Feb 2010 08:32:10 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> When a task is chosen for oom kill, the oom killer first attempts to
> sacrifice a child not sharing its parent's memory instead.
> Unfortunately, this often kills in a seemingly random fashion based on
> the ordering of the selected task's child list.  Additionally, it is not
> guaranteed at all to free a large amount of memory that we need to
> prevent additional oom killing in the very near future.
> 
> Instead, we now only attempt to sacrifice the worst child not sharing its
> parent's memory, if one exists.  The worst child is indicated with the
> highest badness() score.  This serves two advantages: we kill a
> memory-hogging task more often, and we allow the configurable
> /proc/pid/oom_adj value to be considered as a factor in which child to
> kill.
> 
> Reviewers may observe that the previous implementation would iterate
> through the children and attempt to kill each until one was successful
> and then the parent if none were found while the new code simply kills
> the most memory-hogging task or the parent.  Note that the only time
> oom_kill_task() fails, however, is when a child does not have an mm or
> has a /proc/pid/oom_adj of OOM_DISABLE.  badness() returns 0 for both
> cases, so the final oom_kill_task() will always succeed.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Maybe better than current logic..but I'm not sure why we have to check children ;)

BTW,
==
        list_for_each_entry(child, &p->children, sibling) {
                task_lock(child);
                if (child->mm != mm && child->mm)
                        points += child->mm->total_vm/2 + 1;
                task_unlock(child);
        }
==
I wonder this part should be
	points += (child->total_vm/2) >> child->signal->oom_adj + 1

If not, in following situation,
==
	parent (oom_adj = 0)
	  -> child (oom_adj=-15, very big memory user)
==
the child may be killd at first, anyway. Today, I have to explain customers
"When you set oom_adj to a process, please set the same value to all ancestors.
 Otherwise, your oom_adj value will be ignored."

No ? 

Thanks,
-Kame

> ---
>  mm/oom_kill.c |   23 +++++++++++++++++------
>  1 files changed, 17 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -432,7 +432,10 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  			    unsigned long points, struct mem_cgroup *mem,
>  			    const char *message)
>  {
> +	struct task_struct *victim = p;
>  	struct task_struct *c;
> +	unsigned long victim_points = 0;
> +	struct timespec uptime;
>  
>  	if (printk_ratelimit())
>  		dump_header(p, gfp_mask, order, mem);
> @@ -446,17 +449,25 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		return 0;
>  	}
>  
> -	printk(KERN_ERR "%s: kill process %d (%s) score %li or a child\n",
> -					message, task_pid_nr(p), p->comm, points);
> +	pr_err("%s: Kill process %d (%s) with score %lu or sacrifice child\n",
> +		message, task_pid_nr(p), p->comm, points);
>  
> -	/* Try to kill a child first */
> +	/* Try to sacrifice the worst child first */
> +	do_posix_clock_monotonic_gettime(&uptime);
>  	list_for_each_entry(c, &p->children, sibling) {
> +		unsigned long cpoints;
> +
>  		if (c->mm == p->mm)
>  			continue;
> -		if (!oom_kill_task(c))
> -			return 0;
> +
> +		/* badness() returns 0 if the thread is unkillable */
> +		cpoints = badness(c, uptime.tv_sec);
> +		if (cpoints > victim_points) {
> +			victim = c;
> +			victim_points = cpoints;
> +		}
>  	}
> -	return oom_kill_task(p);
> +	return oom_kill_task(victim);
>  }
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
