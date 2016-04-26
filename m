Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 060586B0272
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 09:41:26 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k200so13601201lfg.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 06:41:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b20si25036135wmd.15.2016.04.26.06.41.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 06:41:24 -0700 (PDT)
Subject: Re: [PATCH 15/28] mm, page_alloc: Move might_sleep_if check to the
 allocator slowpath
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-3-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F7002.5030602@suse.cz>
Date: Tue, 26 Apr 2016 15:41:22 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-3-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> There is a debugging check for callers that specify __GFP_DIRECT_RECLAIM
> from a context that cannot sleep. Triggering this is almost certainly
> a bug but it's also overhead in the fast path.

For CONFIG_DEBUG_ATOMIC_SLEEP, enabling is asking for the overhead. But for 
CONFIG_PREEMPT_VOLUNTARY which turns it into _cond_resched(), I guess it's not.

> Move the check to the slow
> path. It'll be harder to trigger as it'll only be checked when watermarks
> are depleted but it'll also only be checked in a path that can sleep.

Hmm what about zone_reclaim_mode=1, should the check be also duplicated to that 
part of get_page_from_freelist()?

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>   mm/page_alloc.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 21aaef6ddd7a..9ef2f4ab9ca5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3176,6 +3176,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>   		return NULL;
>   	}
>
> +	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
> +
>   	/*
>   	 * We also sanity check to catch abuse of atomic reserves being used by
>   	 * callers that are not in atomic context.
> @@ -3369,8 +3371,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>
>   	lockdep_trace_alloc(gfp_mask);
>
> -	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
> -
>   	if (should_fail_alloc_page(gfp_mask, order))
>   		return NULL;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
