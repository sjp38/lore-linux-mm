Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED846B0253
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 04:25:03 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l68so141353673wml.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 01:25:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jt9si2613991wjc.124.2016.03.08.01.25.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 01:25:02 -0800 (PST)
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DE9A68.2010301@suse.cz>
Date: Tue, 8 Mar 2016 10:24:56 +0100
MIME-Version: 1.0
In-Reply-To: <20160307160838.GB5028@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>

On 03/07/2016 05:08 PM, Michal Hocko wrote:
> On Mon 29-02-16 22:02:13, Michal Hocko wrote:
>> Andrew,
>> could you queue this one as well, please? This is more a band aid than a
>> real solution which I will be working on as soon as I am able to
>> reproduce the issue but the patch should help to some degree at least.
> 
> Joonsoo wasn't very happy about this approach so let me try a different
> way. What do you think about the following? Hugh, Sergey does it help
> for your load? I have tested it with the Hugh's load and there was no
> major difference from the previous testing so at least nothing has blown
> up as I am not able to reproduce the issue here.
> 
> Other changes in the compaction are still needed but I would like to not
> depend on them right now.
> ---
> From 0974f127e8eb7fe53e65f3a8b398db57effe9755 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 7 Mar 2016 15:30:37 +0100
> Subject: [PATCH] mm, oom: protect !costly allocations some more
> 
> should_reclaim_retry will give up retries for higher order allocations
> if none of the eligible zones has any requested or higher order pages
> available even if we pass the watermak check for order-0. This is done
> because there is no guarantee that the reclaimable and currently free
> pages will form the required order.
> 
> This can, however, lead to situations were the high-order request (e.g.
> order-2 required for the stack allocation during fork) will trigger
> OOM too early - e.g. after the first reclaim/compaction round. Such a
> system would have to be highly fragmented and there is no guarantee
> further reclaim/compaction attempts would help but at least make sure
> that the compaction was active before we go OOM and keep retrying even
> if should_reclaim_retry tells us to oom if the last compaction round
> was either inactive (deferred, skipped or bailed out early due to
> contention) or it told us to continue.
> 
> Additionally define COMPACT_NONE which reflects cases where the
> compaction is completely disabled.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/compaction.h |  2 ++
>  mm/page_alloc.c            | 41 ++++++++++++++++++++++++-----------------
>  2 files changed, 26 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 4cd4ddf64cc7..a4cec4a03f7d 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -1,6 +1,8 @@
>  #ifndef _LINUX_COMPACTION_H
>  #define _LINUX_COMPACTION_H
>  
> +/* compaction disabled */
> +#define COMPACT_NONE		-1
>  /* Return values for compact_zone() and try_to_compact_pages() */
>  /* compaction didn't start as it was deferred due to past failures */
>  #define COMPACT_DEFERRED	0
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 269a04f20927..f89e3cbfdf90 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2819,28 +2819,22 @@ static struct page *
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  		int alloc_flags, const struct alloc_context *ac,
>  		enum migrate_mode mode, int *contended_compaction,
> -		bool *deferred_compaction)
> +		unsigned long *compact_result)
>  {
> -	unsigned long compact_result;
>  	struct page *page;
>  
> -	if (!order)
> +	if (!order) {
> +		*compact_result = COMPACT_NONE;
>  		return NULL;
> +	}
>  
>  	current->flags |= PF_MEMALLOC;
> -	compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
> +	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
>  						mode, contended_compaction);
>  	current->flags &= ~PF_MEMALLOC;
>  
> -	switch (compact_result) {
> -	case COMPACT_DEFERRED:
> -		*deferred_compaction = true;
> -		/* fall-through */
> -	case COMPACT_SKIPPED:
> +	if (*compact_result <= COMPACT_SKIPPED)

COMPACT_NONE is -1 and compact_result is unsigned long, so this won't
work as expected.

>  		return NULL;
> -	default:
> -		break;
> -	}
>  
>  	/*
>  	 * At least in one zone compaction wasn't deferred or skipped, so let's
> @@ -2875,8 +2869,9 @@ static inline struct page *
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  		int alloc_flags, const struct alloc_context *ac,
>  		enum migrate_mode mode, int *contended_compaction,
> -		bool *deferred_compaction)
> +		unsigned long *compact_result)
>  {
> +	*compact_result = COMPACT_NONE;
>  	return NULL;
>  }
>  #endif /* CONFIG_COMPACTION */
> @@ -3118,7 +3113,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	int alloc_flags;
>  	unsigned long did_some_progress;
>  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
> -	bool deferred_compaction = false;
> +	unsigned long compact_result;
>  	int contended_compaction = COMPACT_CONTENDED_NONE;
>  	int no_progress_loops = 0;
>  
> @@ -3227,7 +3222,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
>  					migration_mode,
>  					&contended_compaction,
> -					&deferred_compaction);
> +					&compact_result);
>  	if (page)
>  		goto got_pg;
>  
> @@ -3240,7 +3235,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 * to heavily disrupt the system, so we fail the allocation
>  		 * instead of entering direct reclaim.
>  		 */
> -		if (deferred_compaction)
> +		if (compact_result == COMPACT_DEFERRED)
>  			goto nopage;
>  
>  		/*
> @@ -3294,6 +3289,18 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  				 did_some_progress > 0, no_progress_loops))
>  		goto retry;
>  
> +	/*
> +	 * !costly allocations are really important and we have to make sure
> +	 * the compaction wasn't deferred or didn't bail out early due to locks
> +	 * contention before we go OOM.
> +	 */
> +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER) {
> +		if (compact_result <= COMPACT_CONTINUE)

Same here.
I was going to say that this didn't have effect on Sergey's test, but
turns out it did :)

> +			goto retry;
> +		if (contended_compaction > COMPACT_CONTENDED_NONE)
> +			goto retry;
> +	}
> +
>  	/* Reclaim has failed us, start killing things */
>  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
>  	if (page)
> @@ -3314,7 +3321,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags,
>  					    ac, migration_mode,
>  					    &contended_compaction,
> -					    &deferred_compaction);
> +					    &compact_result);
>  	if (page)
>  		goto got_pg;
>  nopage:
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
