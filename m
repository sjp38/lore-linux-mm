Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C719A6B0069
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 08:04:33 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id f9so170688wra.2
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 05:04:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h40si12523731edh.210.2017.11.28.05.04.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 05:04:32 -0800 (PST)
Date: Tue, 28 Nov 2017 14:04:30 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/3] mm,oom: Move last second allocation to inside the
 OOM killer.
Message-ID: <20171128130430.vfap5cdc2zt6iw7s@dhcp22.suse.cz>
References: <1511607169-5084-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511607169-5084-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Sat 25-11-17 19:52:47, Tetsuo Handa wrote:
> Since selecting an OOM victim can take quite some time and the OOM
> situation might be resolved meanwhile, sometimes doing last second
> allocation attempt after selecting an OOM victim can succeed.
> 
> Therefore, this patch moves last second allocation attempt to after
> selecting an OOM victim. This patch is expected to reduce the time
> window for potentially pre-mature OOM killing considerably.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/oom.h | 13 +++++++++++++
>  mm/oom_kill.c       | 14 ++++++++++++++
>  mm/page_alloc.c     | 44 ++++++++++++++++++++++++++------------------
>  3 files changed, 53 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 01c91d8..27cd36b 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -14,6 +14,8 @@
>  struct notifier_block;
>  struct mem_cgroup;
>  struct task_struct;
> +struct alloc_context;
> +struct page;
>  
>  /*
>   * Details of the page allocation that triggered the oom killer that are used to
> @@ -38,6 +40,15 @@ struct oom_control {
>  	 */
>  	const int order;
>  
> +	/* Context for really last second allocation attempt. */
> +	const struct alloc_context *ac;
> +	/*
> +	 * Set by the OOM killer if ac != NULL and last second allocation
> +	 * attempt succeeded. If ac != NULL, the caller must check for
> +	 * page != NULL.
> +	 */
> +	struct page *page;
> +
>  	/* Used by oom implementation, do not set */
>  	unsigned long totalpages;
>  	struct task_struct *chosen;
> @@ -102,6 +113,8 @@ extern unsigned long oom_badness(struct task_struct *p,
>  
>  extern struct task_struct *find_lock_task_mm(struct task_struct *p);
>  
> +extern struct page *alloc_pages_before_oomkill(const struct oom_control *oc);
> +
>  /* sysctls */
>  extern int sysctl_oom_dump_tasks;
>  extern int sysctl_oom_kill_allocating_task;
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index c957be3..348ec5a 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1061,6 +1061,9 @@ bool out_of_memory(struct oom_control *oc)
>  	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
>  	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> +		oc->page = alloc_pages_before_oomkill(oc);
> +		if (oc->page)
> +			return true;
>  		get_task_struct(current);
>  		oc->chosen = current;
>  		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
> @@ -1068,6 +1071,17 @@ bool out_of_memory(struct oom_control *oc)
>  	}
>  
>  	select_bad_process(oc);
> +	/*
> +	 * Try really last second allocation attempt after we selected an OOM
> +	 * victim, for somebody might have managed to free memory while we were
> +	 * selecting an OOM victim which can take quite some time.
> +	 */
> +	oc->page = alloc_pages_before_oomkill(oc);
> +	if (oc->page) {
> +		if (oc->chosen && oc->chosen != (void *)-1UL)
> +			put_task_struct(oc->chosen);
> +		return true;
> +	}
>  	/* Found nothing?!?! Either we hang forever, or we panic. */
>  	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
>  		dump_header(oc, NULL);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 48b5b01..7fa95ea 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3325,8 +3325,9 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  		.memcg = NULL,
>  		.gfp_mask = gfp_mask,
>  		.order = order,
> +		.ac = ac,
>  	};
> -	struct page *page;
> +	struct page *page = NULL;
>  
>  	*did_some_progress = 0;
>  
> @@ -3340,19 +3341,6 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  		return NULL;
>  	}
>  
> -	/*
> -	 * Go through the zonelist yet one more time, keep very high watermark
> -	 * here, this is only to catch a parallel oom killing, we must fail if
> -	 * we're still under heavy pressure. But make sure that this reclaim
> -	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> -	 * allocation which will never fail due to oom_lock already held.
> -	 */
> -	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
> -				      ~__GFP_DIRECT_RECLAIM, order,
> -				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
> -	if (page)
> -		goto out;
> -
>  	/* Coredumps can quickly deplete all memory reserves */
>  	if (current->flags & PF_DUMPCORE)
>  		goto out;
> @@ -3387,16 +3375,18 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  		goto out;
>  
>  	/* Exhausted what can be done so it's blamo time */
> -	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> +	if (out_of_memory(&oc)) {
> +		*did_some_progress = 1;
> +		page = oc.page;
> +	} else if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
>  		*did_some_progress = 1;
>  
>  		/*
>  		 * Help non-failing allocations by giving them access to memory
>  		 * reserves
>  		 */
> -		if (gfp_mask & __GFP_NOFAIL)
> -			page = __alloc_pages_cpuset_fallback(gfp_mask, order,
> -					ALLOC_NO_WATERMARKS, ac);
> +		page = __alloc_pages_cpuset_fallback(gfp_mask, order,
> +						     ALLOC_NO_WATERMARKS, ac);
>  	}
>  out:
>  	mutex_unlock(&oom_lock);
> @@ -4156,6 +4146,24 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	return page;
>  }
>  
> +struct page *alloc_pages_before_oomkill(const struct oom_control *oc)
> +{
> +	/*
> +	 * Go through the zonelist yet one more time, keep very high watermark
> +	 * here, this is only to catch a parallel oom killing, we must fail if
> +	 * we're still under heavy pressure. But make sure that this reclaim
> +	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> +	 * allocation which will never fail due to oom_lock already held.
> +	 */
> +	int alloc_flags = ALLOC_CPUSET | ALLOC_WMARK_HIGH;
> +	gfp_t gfp_mask = oc->gfp_mask | __GFP_HARDWALL;
> +
> +	if (!oc->ac)
> +		return NULL;
> +	gfp_mask &= ~__GFP_DIRECT_RECLAIM;
> +	return get_page_from_freelist(gfp_mask, oc->order, alloc_flags, oc->ac);
> +}
> +
>  static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
>  		int preferred_nid, nodemask_t *nodemask,
>  		struct alloc_context *ac, gfp_t *alloc_mask,
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
