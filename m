Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id ACFBA6B0081
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 15:27:14 -0400 (EDT)
Received: by igboe5 with SMTP id oe5so26752740igb.1
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 12:27:14 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id ky9si152662igb.49.2015.06.18.12.27.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 12:27:14 -0700 (PDT)
Received: by igbsb11 with SMTP id sb11so2647538igb.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 12:27:14 -0700 (PDT)
Date: Thu, 18 Jun 2015 12:27:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] oom: split out forced OOM killer
In-Reply-To: <1434621447-21175-3-git-send-email-mhocko@suse.cz>
Message-ID: <alpine.DEB.2.10.1506181222010.3668@chino.kir.corp.google.com>
References: <1434621447-21175-1-git-send-email-mhocko@suse.cz> <1434621447-21175-3-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 18 Jun 2015, Michal Hocko wrote:

> The forced OOM killing is currently wired into out_of_memory() call
> even though their objective is different which makes the code ugly
> and harder to follow. Generic out_of_memory path has to deal with
> configuration settings and heuristics which are completely irrelevant
> to the forced OOM killer (e.g. sysctl_oom_kill_allocating_task or
> OOM killer prevention for already dying tasks). All of them are
> either relying on explicit force_kill check or indirectly by checking
> current->mm which is always NULL for sysrq+f. This is not nice, hard
> to follow and error prone.
> 
> Let's pull forced OOM killer code out into a separate function
> (force_out_of_memory) which is really trivial now.
> As a bonus we can clearly state that this is a forced OOM killer
> in the OOM message which is helpful to distinguish it from the
> regular OOM killer.
> 

Ok, so this patch reverts _everything_ in the first patch other than the 
documentation.  Just start with this patch instead, sheesh.

> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  drivers/tty/sysrq.c |  3 +--
>  include/linux/oom.h |  3 ++-
>  mm/oom_kill.c       | 57 ++++++++++++++++++++++++++++++++---------------------
>  mm/page_alloc.c     |  2 +-
>  4 files changed, 39 insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
> index 3a42b7187b8e..06a95a8ed701 100644
> --- a/drivers/tty/sysrq.c
> +++ b/drivers/tty/sysrq.c
> @@ -356,8 +356,7 @@ static struct sysrq_key_op sysrq_term_op = {
>  static void moom_callback(struct work_struct *ignored)
>  {
>  	mutex_lock(&oom_lock);
> -	if (!out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL),
> -			   GFP_KERNEL, 0, NULL, true))
> +	if (!force_out_of_memory())
>  		pr_info("OOM request ignored because killer is disabled\n");
>  	mutex_unlock(&oom_lock);
>  }
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 7deecb7bca5e..061e0ffd3493 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -70,8 +70,9 @@ extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
>  		unsigned long totalpages, const nodemask_t *nodemask,
>  		bool force_kill);
>  
> +extern bool force_out_of_memory(void);
>  extern bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> -		int order, nodemask_t *mask, bool force_kill);
> +		int order, nodemask_t *mask);
>  
>  extern void exit_oom_victim(void);
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 0c312eaac834..050936f35944 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -635,12 +635,38 @@ int unregister_oom_notifier(struct notifier_block *nb)
>  EXPORT_SYMBOL_GPL(unregister_oom_notifier);
>  
>  /**
> - * __out_of_memory - kill the "best" process when we run out of memory
> + * force_out_of_memory - forces OOM killer

... to kill a process.

> + *
> + * External trigger for the OOM killer. The system doesn't have to be under
> + * OOM condition (e.g. sysrq+f).
> + */

I'm still not sure what you mean by external.  I assume you're referring 
to induced by userspace rather than the kernel.  I think you should use 
the word "explicit".

> +bool force_out_of_memory(void)
> +{
> +	struct zonelist *zonelist = node_zonelist(first_memory_node, GFP_KERNEL);
> +	struct task_struct *p;
> +	unsigned long totalpages;
> +	unsigned int points;
> +
> +	if (oom_killer_disabled)
> +		return false;
> +
> +	constrained_alloc(zonelist, GFP_KERNEL, NULL, &totalpages);
> +	p = select_bad_process(&points, totalpages, NULL, true);
> +	if (p != (void *)-1UL)
> +		oom_kill_process(p, GFP_KERNEL, 0, points, totalpages, NULL,
> +				 NULL, "Forced out of memory killer");
> +	else
> +		pr_warn("Forced out of memory. No killable task found...\n");

Please consider the review from the first patch about this line.

> +
> +	return true;
> +}
> +
> +/**
> + * out_of_memory - kill the "best" process when we run out of memory
>   * @zonelist: zonelist pointer
>   * @gfp_mask: memory allocation flags
>   * @order: amount of memory being requested as a power of 2
>   * @nodemask: nodemask passed to page allocator
> - * @force_kill: true if a task must be killed, even if others are exiting
>   *
>   * If we run out of memory, we have the choice between either
>   * killing a random task (bad), letting the system crash (worse)
> @@ -648,7 +674,7 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
>   * don't have to be perfect here, we just have to be good.
>   */
>  bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> -		   int order, nodemask_t *nodemask, bool force_kill)
> +		   int order, nodemask_t *nodemask)
>  {
>  	const nodemask_t *mpol_mask;
>  	struct task_struct *p;
> @@ -687,14 +713,8 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
>  						&totalpages);
>  	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
> -	/* Ignore panic_on_oom when the OOM killer is sysrq triggered */
> -	if (!force_kill)
> -		check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
> +	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
>  
> -	/*
> -	 * not affecting force_kill because sysrq triggered OOM killer runs from
> -	 * the workqueue context so current->mm will be NULL
> -	 */
>  	if (sysctl_oom_kill_allocating_task && current->mm &&
>  	    !oom_unkillable_task(current, NULL, nodemask) &&
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> @@ -705,18 +725,11 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		goto out;
>  	}
>  
> -	p = select_bad_process(&points, totalpages, mpol_mask, force_kill);
> -	/*
> -	 * Found nothing?!?! Either we hang forever, or we panic.
> -	 * Do not panic when the OOM killer is sysrq triggered.
> -	 */
> +	p = select_bad_process(&points, totalpages, mpol_mask, false);
> +	/* Found nothing?!?! Either we hang forever, or we panic. */
>  	if (!p) {
> -		if (!force_kill) {
> -			dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
> -			panic("Out of memory and no killable processes...\n");
> -		} else {
> -			pr_info("Forced out of memory. No killable task found...\n");
> -		}
> +		dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
> +		panic("Out of memory and no killable processes...\n");
>  	}
>  	if (p != (void *)-1UL) {
>  		oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,
> @@ -747,7 +760,7 @@ void pagefault_out_of_memory(void)
>  	if (!mutex_trylock(&oom_lock))
>  		return;
>  
> -	if (!out_of_memory(NULL, 0, 0, NULL, false)) {
> +	if (!out_of_memory(NULL, 0, 0, NULL)) {
>  		/*
>  		 * There shouldn't be any user tasks runnable while the
>  		 * OOM killer is disabled, so the current task has to
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1f9ffbb087cb..014806d13138 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2731,7 +2731,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  			goto out;
>  	}
>  	/* Exhausted what can be done so it's blamo time */
> -	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)
> +	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask)
>  			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
>  		*did_some_progress = 1;
>  out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
