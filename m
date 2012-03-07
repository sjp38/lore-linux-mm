Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id CC0B86B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 04:17:27 -0500 (EST)
Message-ID: <4F572730.8000000@cn.fujitsu.com>
Date: Wed, 07 Mar 2012 17:15:28 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier related
 damage v2
References: <20120306132735.GA2855@suse.de>
In-Reply-To: <20120306132735.GA2855@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 6 Mar 2012 13:27:35 +0000, Mel Gorman wrote:
[skip]
> @@ -964,7 +964,6 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
>  {
>  	bool need_loop;
>  
> -repeat:
>  	/*
>  	 * Allow tasks that have access to memory reserves because they have
>  	 * been OOM killed to get memory anywhere.
> @@ -983,45 +982,19 @@ repeat:
>  	 */
>  	need_loop = task_has_mempolicy(tsk) ||
>  			!nodes_intersects(*newmems, tsk->mems_allowed);
> -	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
> -	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP1);
>  
> -	/*
> -	 * ensure checking ->mems_allowed_change_disable after setting all new
> -	 * allowed nodes.
> -	 *
> -	 * the read-side task can see an nodemask with new allowed nodes and
> -	 * old allowed nodes. and if it allocates page when cpuset clears newly
> -	 * disallowed ones continuous, it can see the new allowed bits.
> -	 *
> -	 * And if setting all new allowed nodes is after the checking, setting
> -	 * all new allowed nodes and clearing newly disallowed ones will be done
> -	 * continuous, and the read-side task may find no node to alloc page.
> -	 */
> -	smp_mb();
> +	if (need_loop)
> +		write_seqcount_begin(&tsk->mems_allowed_seq);
>  
> -	/*
> -	 * Allocation of memory is very fast, we needn't sleep when waiting
> -	 * for the read-side.
> -	 */
> -	while (need_loop && ACCESS_ONCE(tsk->mems_allowed_change_disable)) {
> -		task_unlock(tsk);
> -		if (!task_curr(tsk))
> -			yield();
> -		goto repeat;
> -	}
> -
> -	/*
> -	 * ensure checking ->mems_allowed_change_disable before clearing all new
> -	 * disallowed nodes.
> -	 *
> -	 * if clearing newly disallowed bits before the checking, the read-side
> -	 * task may find no node to alloc page.
> -	 */
> -	smp_mb();
> +	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
> +	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP1);
>  
>  	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP2);
>  	tsk->mems_allowed = *newmems;
> +
> +	if (need_loop)
> +		write_seqcount_end(&tsk->mems_allowed_seq);
> +
>  	task_unlock(tsk);
>  }

With this patch, we needn't break the nodemask update into two steps.

Beside that, we need deal with fork() carefully, or it is possible that the child
task will be set to a wrong nodemask.

Thanks
Miao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
