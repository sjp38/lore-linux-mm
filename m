Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 20EF76B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 03:09:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so6592668wmz.2
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 00:09:02 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id e18si7109195wjz.212.2016.08.24.00.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 00:09:00 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i138so1264145wmf.3
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 00:09:00 -0700 (PDT)
Date: Wed, 24 Aug 2016 09:08:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [wrecked]
 mm-compaction-more-reliably-increase-direct-compaction-priority.patch
 removed from -mm tree
Message-ID: <20160824070859.GC31179@dhcp22.suse.cz>
References: <57bcb948./5Xz5gcuIQjtLmuG%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57bcb948./5Xz5gcuIQjtLmuG%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, riel@redhat.com, rientjes@google.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

Hi Andrew,
I guess the reason this patch has been dropped is due to
mm-oom-prevent-pre-mature-oom-killer-invocation-for-high-order-request.patch.

I guess we will wait for the above patch to get to Linus, revert it in mmotm
and re-apply
mm-compaction-more-reliably-increase-direct-compaction-priority.patch
again, right?

On Tue 23-08-16 13:59:52, Andrew Morton wrote:
> 
> The patch titled
>      Subject: mm, compaction: more reliably increase direct compaction priority
> has been removed from the -mm tree.  Its filename was
>      mm-compaction-more-reliably-increase-direct-compaction-priority.patch
> 
> This patch was dropped because other changes were merged, which wrecked this patch
> 
> ------------------------------------------------------
> From: Vlastimil Babka <vbabka@suse.cz>
> Subject: mm, compaction: more reliably increase direct compaction priority
> 
> During reclaim/compaction loop, compaction priority can be increased by
> the should_compact_retry() function, but the current code is not optimal. 
> Priority is only increased when compaction_failed() is true, which means
> that compaction has scanned the whole zone.  This may not happen even
> after multiple attempts with a lower priority due to parallel activity, so
> we might needlessly struggle on the lower priorities and possibly run out
> of compaction retry attempts in the process.
> 
> After this patch we are guaranteed at least one attempt at the highest
> compaction priority even if we exhaust all retries at the lower
> priorities.
> 
> Link: http://lkml.kernel.org/r/20160810091226.6709-7-vbabka@suse.cz
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/page_alloc.c |   18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)
> 
> diff -puN mm/page_alloc.c~mm-compaction-more-reliably-increase-direct-compaction-priority mm/page_alloc.c
> --- a/mm/page_alloc.c~mm-compaction-more-reliably-increase-direct-compaction-priority
> +++ a/mm/page_alloc.c
> @@ -3153,13 +3153,8 @@ should_compact_retry(struct alloc_contex
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
> @@ -3183,6 +3178,15 @@ should_compact_retry(struct alloc_contex
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
> _
> 
> Patches currently in -mm which might be from vbabka@suse.cz are
> 
> mm-compaction-make-whole_zone-flag-ignore-cached-scanner-positions.patch
> mm-compaction-cleanup-unused-functions.patch
> mm-compaction-rename-compact_partial-to-compact_success.patch
> mm-compaction-dont-recheck-watermarks-after-compact_success.patch
> mm-compaction-add-the-ultimate-direct-compaction-priority.patch
> mm-compaction-add-the-ultimate-direct-compaction-priority-fix.patch
> mm-compaction-use-correct-watermark-when-checking-compaction-success.patch
> mm-compaction-create-compact_gap-wrapper.patch
> mm-compaction-create-compact_gap-wrapper-fix.patch
> mm-compaction-use-proper-alloc_flags-in-__compaction_suitable.patch
> mm-compaction-require-only-min-watermarks-for-non-costly-orders.patch
> mm-compaction-require-only-min-watermarks-for-non-costly-orders-fix.patch
> mm-vmscan-make-compaction_ready-more-accurate-and-readable.patch

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
