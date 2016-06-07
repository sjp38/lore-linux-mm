Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07E706B025E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 08:11:26 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id d191so108374611oig.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 05:11:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h8si11440743ote.89.2016.06.07.05.11.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Jun 2016 05:11:25 -0700 (PDT)
Subject: Re: [RFC PATCH 1/2] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_HARD with more useful semantic
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
 <1465212736-14637-2-git-send-email-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <7fb7e035-7795-839b-d1b0-4a68fcf8e9c9@I-love.SAKURA.ne.jp>
Date: Tue, 7 Jun 2016 21:11:03 +0900
MIME-Version: 1.0
In-Reply-To: <1465212736-14637-2-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 2016/06/06 20:32, Michal Hocko wrote:
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 669fef1e2bb6..a4b0f18a69ab 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -707,7 +707,7 @@ static int vhost_memory_reg_sort_cmp(const void *p1, const void *p2)
>  
>  static void *vhost_kvzalloc(unsigned long size)
>  {
> -	void *n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
> +	void *n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_HARD);

Remaining __GFP_REPEAT users are not always doing costly allocations.
Sometimes they pass __GFP_REPEAT because the size is given from userspace.
Thus, unconditional s/__GFP_REPEAT/__GFP_RETRY_HARD/g is not good.

What I think more important is hearing from __GFP_REPEAT users how hard they
want to retry. It is possible that they want to retry unless SIGKILL is
delivered, but passing __GFP_NOFAIL is too hard, and therefore __GFP_REPEAT
is used instead. It is possible that they use __GFP_NOFAIL || __GFP_KILLABLE
if __GFP_KILLABLE were available. In my module (though I'm not using
__GFP_REPEAT), I want to retry unless SIGKILL is delivered.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 180f5afc5a1f..faa3d4a27850 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3262,7 +3262,7 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  		return compaction_zonelist_suitable(ac, order, alloc_flags);
>  
>  	/*
> -	 * !costly requests are much more important than __GFP_REPEAT
> +	 * !costly requests are much more important than __GFP_RETRY_HARD
>  	 * costly ones because they are de facto nofail and invoke OOM
>  	 * killer to move on while costly can fail and users are ready
>  	 * to cope with that. 1/4 retries is rather arbitrary but we
> @@ -3550,6 +3550,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	enum compact_result compact_result;
>  	int compaction_retries = 0;
>  	int no_progress_loops = 0;
> +	bool passed_oom = false;
>  
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3680,9 +3681,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  
>  	/*
>  	 * Do not retry costly high order allocations unless they are
> -	 * __GFP_REPEAT
> +	 * __GFP_RETRY_HARD
>  	 */
> -	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
> +	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_RETRY_HARD))
>  		goto noretry;
>  
>  	/*
> @@ -3711,6 +3712,17 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  				compaction_retries))
>  		goto retry;
>  
> +	/*
> +	 * We have already exhausted all our reclaim opportunities including
> +	 * the OOM killer without any success so it is time to admit defeat.
> +	 * We do not care about the order because we want all orders to behave
> +	 * consistently including !costly ones. costly are handled in
> +	 * __alloc_pages_may_oom and will bail out even before the first OOM
> +	 * killer invocation
> +	 */
> +	if (passed_oom && (gfp_mask & __GFP_RETRY_HARD))
> +		goto nopage;
> +

If __GFP_REPEAT was passed because the size is not known at compile time, this
will break "!costly allocations will retry unless TIF_MEMDIE is set" behavior.

>  	/* Reclaim has failed us, start killing things */
>  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
>  	if (page)
> @@ -3719,6 +3731,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	/* Retry as long as the OOM killer is making progress */
>  	if (did_some_progress) {
>  		no_progress_loops = 0;
> +		passed_oom = true;

This is too premature. did_some_progress != 0 after returning from
__alloc_pages_may_oom() does not mean the OOM killer was invoked. It only means
that mutex_trylock(&oom_lock) was attempted. It is possible that somebody else
is on the way to call out_of_memory(). It is possible that the OOM reaper is
about to start reaping memory. Giving up after 1 jiffie of sleep is too fast.

>  		goto retry;
>  	}
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
