Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 8DA536B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 16:55:29 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so183198qcs.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 13:55:28 -0700 (PDT)
Date: Wed, 30 May 2012 16:55:24 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH 18/35] autonuma: alloc/free/init sched_autonuma
Message-ID: <20120530205523.GD30148@localhost.localdomain>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-19-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337965359-29725-19-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Fri, May 25, 2012 at 07:02:22PM +0200, Andrea Arcangeli wrote:
> This is where the dynamically allocated sched_autonuma structure is
> being handled.
> 
> The reason for keeping this outside of the task_struct besides not
> using too much kernel stack, is to only allocate it on NUMA
> hardware. So the not NUMA hardware only pays the memory of a pointer
> in the kernel stack (which remains NULL at all times in that case).
> 
> If the kernel is compiled with CONFIG_AUTONUMA=n, not even the pointer
> is allocated on the kernel stack of course.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  kernel/fork.c |   24 ++++++++++++++----------
>  1 files changed, 14 insertions(+), 10 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 237c34e..d323eb1 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -206,6 +206,7 @@ static void account_kernel_stack(struct thread_info *ti, int account)
>  void free_task(struct task_struct *tsk)
>  {
>  	account_kernel_stack(tsk->stack, -1);
> +	free_sched_autonuma(tsk);
>  	free_thread_info(tsk->stack);
>  	rt_mutex_debug_task_free(tsk);
>  	ftrace_graph_exit_task(tsk);
> @@ -260,6 +261,8 @@ void __init fork_init(unsigned long mempages)
>  	/* do the arch specific task caches init */
>  	arch_task_cache_init();
>  
> +	sched_autonuma_init();
> +
>  	/*
>  	 * The default maximum number of threads is set to a safe
>  	 * value: the thread structures can take up at most half
> @@ -292,21 +295,21 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
>  	struct thread_info *ti;
>  	unsigned long *stackend;
>  	int node = tsk_fork_get_node(orig);
> -	int err;
>  
>  	tsk = alloc_task_struct_node(node);
> -	if (!tsk)
> +	if (unlikely(!tsk))
>  		return NULL;
>  
>  	ti = alloc_thread_info_node(tsk, node);
> -	if (!ti) {
> -		free_task_struct(tsk);
> -		return NULL;
> -	}
> +	if (unlikely(!ti))

Should those "unlikely" have their own commit? Did you
run this with the likely/unlikely tracer to confirm that it
does give a sppedup?


> +		goto out_task_struct;
>  
> -	err = arch_dup_task_struct(tsk, orig);
> -	if (err)
> -		goto out;
> +	if (unlikely(arch_dup_task_struct(tsk, orig)))
> +		goto out_thread_info;
> +
> +	if (unlikely(alloc_sched_autonuma(tsk, orig, node)))
> +		/* free_thread_info() undoes arch_dup_task_struct() too */
> +		goto out_thread_info;
>  
>  	tsk->stack = ti;
>  
> @@ -334,8 +337,9 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
>  
>  	return tsk;
>  
> -out:
> +out_thread_info:
>  	free_thread_info(ti);
> +out_task_struct:
>  	free_task_struct(tsk);
>  	return NULL;
>  }
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
