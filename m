Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 93EA96B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:36:48 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id y7-v6so542610plt.17
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:36:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v129-v6sor738011pgv.164.2018.06.20.15.36.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 15:36:47 -0700 (PDT)
Date: Wed, 20 Jun 2018 15:36:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
In-Reply-To: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed, 20 Jun 2018, Tetsuo Handa wrote:

> Sleeping with oom_lock held can cause AB-BA lockup bug because
> __alloc_pages_may_oom() does not wait for oom_lock. Since
> blocking_notifier_call_chain() in out_of_memory() might sleep, sleeping
> with oom_lock held is currently an unavoidable problem.
> 
> As a preparation for not to sleep with oom_lock held, this patch brings
> OOM notifier callbacks to outside of OOM killer, with two small behavior
> changes explained below.
> 
> One is that this patch makes it impossible for SysRq-f and PF-OOM to
> reclaim via OOM notifier. But such change should be tolerable because
> "we unlikely try to use SysRq-f for reclaiming memory via OOM notifier
> callbacks" and "pagefault_out_of_memory() will be called when OOM killer
> selected current thread as an OOM victim after OOM notifier callbacks
> already failed to reclaim memory".
> 
> The other is that this patch makes it possible to reclaim memory via OOM
> notifier after OOM killer is disabled (that is, suspend/hibernate is in
> progress). But such change should be safe because of pm_suspended_storage()
> check.
> 

Makes sense in general and I don't think that getting around these two 
caveats is problematic.  We should be handling everything that can free 
memory to preempt an oom kill in the page allocator and get rid of the 
notion that this is "oom notification" when in reality it is intended as 
the last form of reclaim prior to oom kill.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  include/linux/oom.h |  1 +
>  mm/oom_kill.c       | 35 ++++++++++++++++++------
>  mm/page_alloc.c     | 76 +++++++++++++++++++++++++++++++----------------------
>  3 files changed, 73 insertions(+), 39 deletions(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 6adac11..085b033 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -101,6 +101,7 @@ extern unsigned long oom_badness(struct task_struct *p,
>  		struct mem_cgroup *memcg, const nodemask_t *nodemask,
>  		unsigned long totalpages);
>  
> +extern unsigned long try_oom_notifier(void);
>  extern bool out_of_memory(struct oom_control *oc);
>  
>  extern void exit_oom_victim(void);
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 84081e7..2ff5db2 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1010,6 +1010,33 @@ int unregister_oom_notifier(struct notifier_block *nb)
>  EXPORT_SYMBOL_GPL(unregister_oom_notifier);
>  
>  /**
> + * try_oom_notifier - Try to reclaim memory from OOM notifier list.
> + *
> + * Returns non-zero if notifier callbacks released something, zero otherwise.
> + */
> +unsigned long try_oom_notifier(void)

It certainly is tried, but based on its usage it would probably be better 
to describe what is being returned (it's going to set *did_some_progress, 
which is a page count).

That makes me think that "oom_notify_list" isn't very intuitive: it can 
free memory as a last step prior to oom kill.  OOM notify, to me, sounds 
like its only notifying some callbacks about the condition.  Maybe 
oom_reclaim_list and then rename this to oom_reclaim_pages()?

> +{
> +	static DEFINE_MUTEX(oom_notifier_lock);
> +	unsigned long freed = 0;
> +
> +	/*
> +	 * Since OOM notifier callbacks must not depend on __GFP_DIRECT_RECLAIM
> +	 * && !__GFP_NORETRY memory allocation, waiting for mutex here is safe.
> +	 * If lockdep reports possible deadlock dependency, it will be a bug in
> +	 * OOM notifier callbacks.
> +	 *
> +	 * If SIGKILL is pending, it is likely that current thread was selected
> +	 * as an OOM victim. In that case, current thread should return as soon
> +	 * as possible using memory reserves.
> +	 */
> +	if (mutex_lock_killable(&oom_notifier_lock))
> +		return 0;
> +	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> +	mutex_unlock(&oom_notifier_lock);
> +	return freed;
> +}

If __blocking_notifier_call_chain() used down_read_killable(), could we 
eliminate oom_notifier_lock?

> +
> +/**
>   * out_of_memory - kill the "best" process when we run out of memory
>   * @oc: pointer to struct oom_control
>   *
> @@ -1020,19 +1047,11 @@ int unregister_oom_notifier(struct notifier_block *nb)
>   */
>  bool out_of_memory(struct oom_control *oc)
>  {
> -	unsigned long freed = 0;
>  	enum oom_constraint constraint = CONSTRAINT_NONE;
>  
>  	if (oom_killer_disabled)
>  		return false;
>  
> -	if (!is_memcg_oom(oc)) {
> -		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> -		if (freed > 0)
> -			/* Got some memory back in the last second. */
> -			return true;
> -	}
> -
>  	/*
>  	 * If current has a pending SIGKILL or is exiting, then automatically
>  	 * select it.  The goal is to allow it to allocate so that it may
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1521100..c72ef1e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3447,10 +3447,50 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  	return page;
>  }
>  
> +static inline bool can_oomkill(gfp_t gfp_mask, unsigned int order,
> +			       const struct alloc_context *ac)

I'd suggest a more mm/page_alloc.c friendly name, something like 
oom_kill_allowed().

> +{
> +	/* Coredumps can quickly deplete all memory reserves */
> +	if (current->flags & PF_DUMPCORE)
> +		return false;
> +	/* The OOM killer will not help higher order allocs */
> +	if (order > PAGE_ALLOC_COSTLY_ORDER)
> +		return false;
> +	/*
> +	 * We have already exhausted all our reclaim opportunities without any
> +	 * success so it is time to admit defeat. We will skip the OOM killer
> +	 * because it is very likely that the caller has a more reasonable
> +	 * fallback than shooting a random task.
> +	 */
> +	if (gfp_mask & __GFP_RETRY_MAYFAIL)
> +		return false;
> +	/* The OOM killer does not needlessly kill tasks for lowmem */
> +	if (ac->high_zoneidx < ZONE_NORMAL)
> +		return false;
> +	if (pm_suspended_storage())
> +		return false;
> +	/*
> +	 * XXX: GFP_NOFS allocations should rather fail than rely on
> +	 * other request to make a forward progress.
> +	 * We are in an unfortunate situation where out_of_memory cannot
> +	 * do much for this context but let's try it to at least get
> +	 * access to memory reserved if the current task is killed (see
> +	 * out_of_memory). Once filesystems are ready to handle allocation
> +	 * failures more gracefully we should just bail out here.
> +	 */
> +
> +	/* The OOM killer may not free memory on a specific node */
> +	if (gfp_mask & __GFP_THISNODE)
> +		return false;
> +
> +	return true;
> +}
> +
>  static inline struct page *
>  __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	const struct alloc_context *ac, unsigned long *did_some_progress)
>  {
> +	const bool oomkill = can_oomkill(gfp_mask, order, ac);
>  	struct oom_control oc = {
>  		.zonelist = ac->zonelist,
>  		.nodemask = ac->nodemask,
> @@ -3462,6 +3502,10 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  
>  	*did_some_progress = 0;
>  
> +	/* Try to reclaim via OOM notifier callback. */
> +	if (oomkill)
> +		*did_some_progress = try_oom_notifier();
> +
>  	/*
>  	 * Acquire the oom lock.  If that fails, somebody else is
>  	 * making progress for us.

*did_some_progress = oom_kill_allowed ? oom_reclaim_pages() : 0;

This patch is certainly an improvement because it does the last 
get_page_from_freelist() call after invoking the oom notifiers that can 
free memory and we've otherwise pointlessly redirected it elsewhere.

> @@ -3485,37 +3529,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  	if (page)
>  		goto out;
>  
> -	/* Coredumps can quickly deplete all memory reserves */
> -	if (current->flags & PF_DUMPCORE)
> -		goto out;
> -	/* The OOM killer will not help higher order allocs */
> -	if (order > PAGE_ALLOC_COSTLY_ORDER)
> -		goto out;
> -	/*
> -	 * We have already exhausted all our reclaim opportunities without any
> -	 * success so it is time to admit defeat. We will skip the OOM killer
> -	 * because it is very likely that the caller has a more reasonable
> -	 * fallback than shooting a random task.
> -	 */
> -	if (gfp_mask & __GFP_RETRY_MAYFAIL)
> -		goto out;
> -	/* The OOM killer does not needlessly kill tasks for lowmem */
> -	if (ac->high_zoneidx < ZONE_NORMAL)
> -		goto out;
> -	if (pm_suspended_storage())
> -		goto out;
> -	/*
> -	 * XXX: GFP_NOFS allocations should rather fail than rely on
> -	 * other request to make a forward progress.
> -	 * We are in an unfortunate situation where out_of_memory cannot
> -	 * do much for this context but let's try it to at least get
> -	 * access to memory reserved if the current task is killed (see
> -	 * out_of_memory). Once filesystems are ready to handle allocation
> -	 * failures more gracefully we should just bail out here.
> -	 */
> -
> -	/* The OOM killer may not free memory on a specific node */
> -	if (gfp_mask & __GFP_THISNODE)
> +	if (!oomkill)
>  		goto out;
>  
>  	/* Exhausted what can be done so it's blame time */
