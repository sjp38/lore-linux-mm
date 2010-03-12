Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E624B6B010F
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 21:39:34 -0500 (EST)
Date: Fri, 12 Mar 2010 11:30:28 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 1/3] memcg: wake up filter in oom waitqueue
Message-Id: <20100312113028.1449915f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100311165559.3f9166b2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100311165315.c282d6d2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311165559.3f9166b2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, kirill@shutemov.name, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Mar 2010 16:55:59 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> memcg's oom waitqueue is a system-wide wait_queue (for handling hierarchy.)
> So, it's better to add custom wake function and do flitering in wake up path.
> 
> This patch adds a filtering feature for waking up oom-waiters.
> Hierarchy is properly handled.
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   61 ++++++++++++++++++++++++++++++++++++++++----------------
>  1 file changed, 44 insertions(+), 17 deletions(-)
> 
> Index: mmotm-2.6.34-Mar9/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.34-Mar9.orig/mm/memcontrol.c
> +++ mmotm-2.6.34-Mar9/mm/memcontrol.c
> @@ -1293,14 +1293,54 @@ static void mem_cgroup_oom_unlock(struct
>  static DEFINE_MUTEX(memcg_oom_mutex);
>  static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
>  
> +struct oom_wait_info {
> +	struct mem_cgroup *mem;
> +	wait_queue_t	wait;
> +};
> +
> +static int memcg_oom_wake_function(wait_queue_t *wait,
> +	unsigned mode, int sync, void *arg)
> +{
> +	struct mem_cgroup *wake_mem = (struct mem_cgroup *)arg;
> +	struct oom_wait_info *oom_wait_info;
> +
> +	/* both of oom_wait_info->mem and wake_mem are stable under us */
> +	oom_wait_info = container_of(wait, struct oom_wait_info, wait);
> +
> +	if (oom_wait_info->mem == wake_mem)
> +		goto wakeup;
> +	/* if no hierarchy, no match */
> +	if (!oom_wait_info->mem->use_hierarchy || !wake_mem->use_hierarchy)
> +		return 0;
> +	/* check hierarchy */
> +	if (!css_is_ancestor(&oom_wait_info->mem->css, &wake_mem->css) &&
> +	    !css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css))
> +		return 0;
> +
I think these conditions are wrong.
This can wake up tasks in oom_wait_info->mem when:

  00/ <- wake_mem: use_hierarchy == false
    aa/ <- oom_wait_info->mem: use_hierarchy == true;

It should be:

	if((oom_wait_info->mem->use_hierarchy &&
		css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css)) ||
	   (wake_mem->use_hierarchy &&
		css_is_ancestor(&oom_wait_info->mem->css, &wake_mem->css)))
		goto wakeup;

	return 0;

But I like the goal of this patch.

Thanks,
Daisuke Nishimura.

> +wakeup:
> +	return autoremove_wake_function(wait, mode, sync, arg);
> +}
> +
> +static void memcg_wakeup_oom(struct mem_cgroup *mem)
> +{
> +	/* for filtering, pass "mem" as argument. */
> +	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, mem);
> +}
> +
>  /*
>   * try to call OOM killer. returns false if we should exit memory-reclaim loop.
>   */
>  bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>  {
> -	DEFINE_WAIT(wait);
> +	struct oom_wait_info owait;
>  	bool locked;
>  
> +	owait.mem = mem;
> +	owait.wait.flags = 0;
> +	owait.wait.func = memcg_oom_wake_function;
> +	owait.wait.private = current;
> +	INIT_LIST_HEAD(&owait.wait.task_list);
> +
>  	/* At first, try to OOM lock hierarchy under mem.*/
>  	mutex_lock(&memcg_oom_mutex);
>  	locked = mem_cgroup_oom_lock(mem);
> @@ -1310,31 +1350,18 @@ bool mem_cgroup_handle_oom(struct mem_cg
>  	 * under OOM is always welcomed, use TASK_KILLABLE here.
>  	 */
>  	if (!locked)
> -		prepare_to_wait(&memcg_oom_waitq, &wait, TASK_KILLABLE);
> +		prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
>  	mutex_unlock(&memcg_oom_mutex);
>  
>  	if (locked)
>  		mem_cgroup_out_of_memory(mem, mask);
>  	else {
>  		schedule();
> -		finish_wait(&memcg_oom_waitq, &wait);
> +		finish_wait(&memcg_oom_waitq, &owait.wait);
>  	}
>  	mutex_lock(&memcg_oom_mutex);
>  	mem_cgroup_oom_unlock(mem);
> -	/*
> -	 * Here, we use global waitq .....more fine grained waitq ?
> -	 * Assume following hierarchy.
> -	 * A/
> -	 *   01
> -	 *   02
> -	 * assume OOM happens both in A and 01 at the same time. Tthey are
> -	 * mutually exclusive by lock. (kill in 01 helps A.)
> -	 * When we use per memcg waitq, we have to wake up waiters on A and 02
> -	 * in addtion to waiters on 01. We use global waitq for avoiding mess.
> -	 * It will not be a big problem.
> -	 * (And a task may be moved to other groups while it's waiting for OOM.)
> -	 */
> -	wake_up_all(&memcg_oom_waitq);
> +	memcg_wakeup_oom(mem);
>  	mutex_unlock(&memcg_oom_mutex);
>  
>  	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
