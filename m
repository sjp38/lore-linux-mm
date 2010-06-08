Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CAC2A6B01DD
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 17:08:26 -0400 (EDT)
Date: Tue, 8 Jun 2010 14:08:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 09/18] oom: select task from tasklist for mempolicy ooms
Message-Id: <20100608140818.b413c335.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061525000.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061525000.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:31 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> The oom killer presently kills current whenever there is no more memory
> free or reclaimable on its mempolicy's nodes.  There is no guarantee that
> current is a memory-hogging task or that killing it will free any
> substantial amount of memory, however.
> 
> In such situations, it is better to scan the tasklist for nodes that are
> allowed to allocate on current's set of nodes and kill the task with the
> highest badness() score.  This ensures that the most memory-hogging task,
> or the one configured by the user with /proc/pid/oom_adj, is always
> selected in such scenarios.
> 
>
> ...
>
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -27,6 +27,7 @@
>  #include <linux/module.h>
>  #include <linux/notifier.h>
>  #include <linux/memcontrol.h>
> +#include <linux/mempolicy.h>
>  #include <linux/security.h>
>  
>  int sysctl_panic_on_oom;
> @@ -36,20 +37,36 @@ static DEFINE_SPINLOCK(zone_scan_lock);
>  /* #define DEBUG */
>  
>  /*
> - * Is all threads of the target process nodes overlap ours?
> + * Do all threads of the target process overlap our allowed nodes?
> + * @tsk: task struct of which task to consider
> + * @mask: nodemask passed to page allocator for mempolicy ooms

The comment uses kerneldoc annotation but isn't a kerneldoc comment.

>   */
> -static int has_intersects_mems_allowed(struct task_struct *tsk)
> +static bool has_intersects_mems_allowed(struct task_struct *tsk,
> +					const nodemask_t *mask)
>  {
> -	struct task_struct *t;
> +	struct task_struct *start = tsk;
>  
> -	t = tsk;
>  	do {
> -		if (cpuset_mems_allowed_intersects(current, t))
> -			return 1;
> -		t = next_thread(t);
> -	} while (t != tsk);
> -
> -	return 0;
> +		if (mask) {
> +			/*
> +			 * If this is a mempolicy constrained oom, tsk's
> +			 * cpuset is irrelevant.  Only return true if its
> +			 * mempolicy intersects current, otherwise it may be
> +			 * needlessly killed.
> +			 */
> +			if (mempolicy_nodemask_intersects(tsk, mask))
> +				return true;

The comment refers to `current' but the code does not?

> +		} else {
> +			/*
> +			 * This is not a mempolicy constrained oom, so only
> +			 * check the mems of tsk's cpuset.
> +			 */

The comment doesn't refer to `current', but the code does.  Confused.

> +			if (cpuset_mems_allowed_intersects(current, tsk))
> +				return true;
> +		}
> +		tsk = next_thread(tsk);

hm, next_thread() uses list_entry_rcu().  What are the locking rules
here?  It's one of both of rcu_read_lock() and read_lock(&tasklist_lock),
I think?

> +	} while (tsk != start);
> +	return false;
>  }

This is all bloat and overhead for non-NUMA builds.  I doubt if gcc is
able to eliminate the task_struct walk (although I didn't check).

The function isn't oom-killer-specific at all - give it a better name
then move it to mempolicy.c or similar?  If so, the text "oom"
shouldn't appear in the comments.

>
> ...
>
> @@ -676,24 +699,19 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	 */
>  	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
>  	read_lock(&tasklist_lock);
> -
> -	switch (constraint) {
> -	case CONSTRAINT_MEMORY_POLICY:
> -		oom_kill_process(current, gfp_mask, order, 0, NULL,
> -				"No available memory (MPOL_BIND)");
> -		break;
> -
> -	case CONSTRAINT_NONE:
> -		if (sysctl_panic_on_oom) {
> +	if (unlikely(sysctl_panic_on_oom)) {
> +		/*
> +		 * panic_on_oom only affects CONSTRAINT_NONE, the kernel
> +		 * should not panic for cpuset or mempolicy induced memory
> +		 * failures.
> +		 */

This wasn't changelogged?

> +		if (constraint == CONSTRAINT_NONE) {
>  			dump_header(NULL, gfp_mask, order, NULL);
> -			panic("out of memory. panic_on_oom is selected\n");
> +			read_unlock(&tasklist_lock);
> +			panic("Out of memory: panic_on_oom is enabled\n");
>  		}
> -		/* Fall-through */
> -	case CONSTRAINT_CPUSET:
> -		__out_of_memory(gfp_mask, order);
> -		break;
>  	}
> -
> +	__out_of_memory(gfp_mask, order, constraint, nodemask);
>  	read_unlock(&tasklist_lock);
>  
>  	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
