Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E28B16B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 02:01:47 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id e70so203460464ioi.3
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 23:01:47 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d7si4056420ioe.164.2016.08.15.23.01.46
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 23:01:47 -0700 (PDT)
Date: Tue, 16 Aug 2016 15:07:37 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 06/11] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160816060737.GC17448@js1304-P5Q-DELUXE>
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-7-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160810091226.6709-7-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 10, 2016 at 11:12:21AM +0200, Vlastimil Babka wrote:
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

The only difference that this patch makes is increasing priority when
COMPACT_PARTIAL(COMPACTION_SUCCESS) returns. In that case, we can
usually allocate high-order freepage so we would not enter here. Am I
missing something? Is it really needed behaviour change?

Thanks.

> 
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

The only difference that this patch makes is increasing priority when
COMPACT_PARTIAL(COMPACTION_SUCCESS) returns. In that case, we can
usually allocate high-order freepage so we would not enter here. Am I
missing something? Is it really needed behaviour change?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
