Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 33B596B0268
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 05:10:40 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so8370185lfg.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 02:10:40 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 204si29098765wmk.76.2016.08.18.02.10.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 02:10:38 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i138so4220392wmf.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 02:10:38 -0700 (PDT)
Date: Thu, 18 Aug 2016 11:10:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 06/11] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160818091036.GF30162@dhcp22.suse.cz>
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-7-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160810091226.6709-7-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 10-08-16 11:12:21, Vlastimil Babka wrote:
> During reclaim/compaction loop, compaction priority can be increased by the
> should_compact_retry() function, but the current code is not optimal. Priority
> is only increased when compaction_failed() is true, which means that compaction
> has scanned the whole zone. This may not happen even after multiple attempts
> with a lower priority due to parallel activity, so we might needlessly
> struggle on the lower priorities and possibly run out of compaction retry
> attempts in the process.
> 
> After this patch we are guaranteed at least one attempt at the highest
> compaction priority even if we exhaust all retries at the lower priorities.

I expect we will tend to do some special handling at the highest
priority so guaranteeing at least one run with that prio seems sensible to me. The only
question is whether we really want to enforce the highest priority for
costly orders as well. I think we want to reserve the highest (maybe add
one more) prio for !costly orders as those invoke the OOM killer and the
failure are quite disruptive.

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/page_alloc.c | 18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index fb975cec3518..b28517b918b0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3155,13 +3155,8 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  	 * so it doesn't really make much sense to retry except when the
>  	 * failure could be caused by insufficient priority
>  	 */
> -	if (compaction_failed(compact_result)) {
> -		if (*compact_priority > MIN_COMPACT_PRIORITY) {
> -			(*compact_priority)--;
> -			return true;
> -		}
> -		return false;
> -	}
> +	if (compaction_failed(compact_result))
> +		goto check_priority;
>  
>  	/*
>  	 * make sure the compaction wasn't deferred or didn't bail out early
> @@ -3185,6 +3180,15 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  	if (compaction_retries <= max_retries)
>  		return true;
>  
> +	/*
> +	 * Make sure there is at least one attempt at the highest priority
> +	 * if we exhausted all retries at the lower priorities
> +	 */
> +check_priority:
> +	if (*compact_priority > MIN_COMPACT_PRIORITY) {
> +		(*compact_priority)--;
> +		return true;
> +	}
>  	return false;
>  }
>  #else
> -- 
> 2.9.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
