Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C53783090
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 02:50:29 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s2so172925043iod.0
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 23:50:29 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id hf4si14906428igb.39.2016.04.20.23.50.27
        for <linux-mm@kvack.org>;
        Wed, 20 Apr 2016 23:50:28 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org> <1461181647-8039-8-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461181647-8039-8-git-send-email-mhocko@kernel.org>
Subject: Re: [PATCH 07/14] mm, compaction: Simplify __alloc_pages_direct_compact feedback interface
Date: Thu, 21 Apr 2016 14:50:08 +0800
Message-ID: <02cd01d19b9a$0b676790$223636b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'Joonsoo Kim' <js1304@gmail.com>, 'Vlastimil Babka' <vbabka@suse.cz>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

> 
> From: Michal Hocko <mhocko@suse.com>
> 
> __alloc_pages_direct_compact communicates potential back off by two
> variables:
> 	- deferred_compaction tells that the compaction returned
> 	  COMPACT_DEFERRED
> 	- contended_compaction is set when there is a contention on
> 	  zone->lock resp. zone->lru_lock locks
> 
> __alloc_pages_slowpath then backs of for THP allocation requests to
> prevent from long stalls. This is rather messy and it would be much
> cleaner to return a single compact result value and hide all the nasty
> details into __alloc_pages_direct_compact.
> 
> This patch shouldn't introduce any functional changes.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/page_alloc.c | 67 ++++++++++++++++++++++++++-------------------------------
>  1 file changed, 31 insertions(+), 36 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 06af8a757d52..350d13f3709b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2944,29 +2944,21 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  static struct page *
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  		int alloc_flags, const struct alloc_context *ac,
> -		enum migrate_mode mode, int *contended_compaction,
> -		bool *deferred_compaction)
> +		enum migrate_mode mode, enum compact_result *compact_result)
>  {
> -	enum compact_result compact_result;
>  	struct page *page;
> +	int contended_compaction;
> 
>  	if (!order)
>  		return NULL;
> 
>  	current->flags |= PF_MEMALLOC;
> -	compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
> -						mode, contended_compaction);
> +	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
> +						mode, &contended_compaction);
>  	current->flags &= ~PF_MEMALLOC;
> 
> -	switch (compact_result) {
> -	case COMPACT_DEFERRED:
> -		*deferred_compaction = true;
> -		/* fall-through */
> -	case COMPACT_SKIPPED:
> +	if (*compact_result <= COMPACT_INACTIVE)
>  		return NULL;
> -	default:
> -		break;
> -	}
> 
>  	/*
>  	 * At least in one zone compaction wasn't deferred or skipped, so let's
> @@ -2992,6 +2984,24 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	 */
>  	count_vm_event(COMPACTFAIL);
> 
> +	/*
> +	 * In all zones where compaction was attempted (and not
> +	 * deferred or skipped), lock contention has been detected.
> +	 * For THP allocation we do not want to disrupt the others
> +	 * so we fallback to base pages instead.
> +	 */
> +	if (contended_compaction == COMPACT_CONTENDED_LOCK)
> +		*compact_result = COMPACT_CONTENDED;
> +
> +	/*
> +	 * If compaction was aborted due to need_resched(), we do not
> +	 * want to further increase allocation latency, unless it is
> +	 * khugepaged trying to collapse.
> +	 */
> +	if (contended_compaction == COMPACT_CONTENDED_SCHED
> +		&& !(current->flags & PF_KTHREAD))
> +		*compact_result = COMPACT_CONTENDED;
> +
>  	cond_resched();
> 
>  	return NULL;
> @@ -3000,8 +3010,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  static inline struct page *
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  		int alloc_flags, const struct alloc_context *ac,
> -		enum migrate_mode mode, int *contended_compaction,
> -		bool *deferred_compaction)
> +		enum migrate_mode mode, enum compact_result *compact_result)
>  {
>  	return NULL;
>  }
> @@ -3146,8 +3155,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	unsigned long pages_reclaimed = 0;
>  	unsigned long did_some_progress;
>  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
> -	bool deferred_compaction = false;
> -	int contended_compaction = COMPACT_CONTENDED_NONE;
> +	enum compact_result compact_result;
> 
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3245,8 +3253,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 */
>  	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
>  					migration_mode,
> -					&contended_compaction,
> -					&deferred_compaction);
> +					&compact_result);
>  	if (page)
>  		goto got_pg;
> 
> @@ -3259,25 +3266,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 * to heavily disrupt the system, so we fail the allocation
>  		 * instead of entering direct reclaim.
>  		 */
> -		if (deferred_compaction)
> -			goto nopage;
> -
> -		/*
> -		 * In all zones where compaction was attempted (and not
> -		 * deferred or skipped), lock contention has been detected.
> -		 * For THP allocation we do not want to disrupt the others
> -		 * so we fallback to base pages instead.
> -		 */
> -		if (contended_compaction == COMPACT_CONTENDED_LOCK)
> +		if (compact_result == COMPACT_DEFERRED)
>  			goto nopage;
> 
>  		/*
> -		 * If compaction was aborted due to need_resched(), we do not
> -		 * want to further increase allocation latency, unless it is
> -		 * khugepaged trying to collapse.
> +		 * Compaction is contended so rather back off than cause
> +		 * excessive stalls.
>  		 */
> -		if (contended_compaction == COMPACT_CONTENDED_SCHED
> -			&& !(current->flags & PF_KTHREAD))
> +		if(compact_result == COMPACT_CONTENDED)
>  			goto nopage;
>  	}
> 
> @@ -3325,8 +3321,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 */
>  	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags,
>  					    ac, migration_mode,
> -					    &contended_compaction,
> -					    &deferred_compaction);
> +					    &compact_result);
>  	if (page)
>  		goto got_pg;
>  nopage:
> --
> 2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
