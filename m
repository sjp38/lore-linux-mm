Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 553BB6B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 03:17:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so68782418wmr.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 00:17:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gt10si2816284wjb.124.2016.06.30.00.17.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Jun 2016 00:17:22 -0700 (PDT)
Subject: Re: [patch for-4.7] mm, compaction: prevent VM_BUG_ON when
 terminating freeing scanner
References: <alpine.DEB.2.10.1606291436300.145590@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7ecb4f2d-724f-463f-961f-efba1bdb63d2@suse.cz>
Date: Thu, 30 Jun 2016 09:17:17 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1606291436300.145590@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@techsingularity.net, minchan@kernel.org, stable@vger.kernel.org

On 06/29/2016 11:47 PM, David Rientjes wrote:
> It's possible to isolate some freepages in a pageblock and then fail
> split_free_page() due to the low watermark check.  In this case, we hit
> VM_BUG_ON() because the freeing scanner terminated early without a
> contended lock or enough freepages.
>
> This should never have been a VM_BUG_ON() since it's not a fatal
> condition.  It should have been a VM_WARN_ON() at best, or even handled
> gracefully.
>
> Regardless, we need to terminate anytime the full pageblock scan was not
> done.  The logic belongs in isolate_freepages_block(), so handle its state
> gracefully by terminating the pageblock loop and making a note to restart
> at the same pageblock next time since it was not possible to complete the
> scan this time.
>
> Reported-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Note: I really dislike the low watermark check in split_free_page() and
>  consider it poor software engineering.  The function should split a free
>  page, nothing more.  Terminating memory compaction because of a low
>  watermark check when we're simply trying to migrate memory seems like an
>  arbitrary heuristic.  There was an objection to removing it in the first
>  proposed patch, but I think we should really consider removing that
>  check so this is simpler.

There's a patch changing it to min watermark (you were CC'd on the 
series). We could argue whether it belongs to split_free_page() or some 
wrapper of it, but I don't think removing it completely should be done. 
If zone is struggling with order-0 pages, a functionality for making 
higher-order pages shouldn't make it even worse. It's also not that 
arbitrary, even if we succeeded the migration and created a high-order 
page, the higher-order allocation would still fail due to watermark 
checks. Worse, __compact_finished() would keep telling the compaction to 
continue, creating an even longer lag, which is also against your recent 
patches.

>  mm/compaction.c | 37 +++++++++++++++----------------------
>  1 file changed, 15 insertions(+), 22 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1009,8 +1009,6 @@ static void isolate_freepages(struct compact_control *cc)
>  				block_end_pfn = block_start_pfn,
>  				block_start_pfn -= pageblock_nr_pages,
>  				isolate_start_pfn = block_start_pfn) {
> -		unsigned long isolated;
> -
>  		/*
>  		 * This can iterate a massively long zone without finding any
>  		 * suitable migration targets, so periodically check if we need
> @@ -1034,36 +1032,31 @@ static void isolate_freepages(struct compact_control *cc)
>  			continue;
>
>  		/* Found a block suitable for isolating free pages from. */
> -		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
> -						block_end_pfn, freelist, false);
> -		/* If isolation failed early, do not continue needlessly */
> -		if (!isolated && isolate_start_pfn < block_end_pfn &&
> -		    cc->nr_migratepages > cc->nr_freepages)
> -			break;
> +		isolate_freepages_block(cc, &isolate_start_pfn, block_end_pfn,
> +					freelist, false);
>
>  		/*
> -		 * If we isolated enough freepages, or aborted due to async
> -		 * compaction being contended, terminate the loop.
> -		 * Remember where the free scanner should restart next time,
> -		 * which is where isolate_freepages_block() left off.
> -		 * But if it scanned the whole pageblock, isolate_start_pfn
> -		 * now points at block_end_pfn, which is the start of the next
> -		 * pageblock.
> -		 * In that case we will however want to restart at the start
> -		 * of the previous pageblock.
> +		 * If we isolated enough freepages, or aborted due to lock
> +		 * contention, terminate.
>  		 */
>  		if ((cc->nr_freepages >= cc->nr_migratepages)
>  							|| cc->contended) {
> -			if (isolate_start_pfn >= block_end_pfn)
> +			if (isolate_start_pfn >= block_end_pfn) {
> +				/*
> +				 * Restart at previous pageblock if more
> +				 * freepages can be isolated next time.
> +				 */

That's not as explanatory as before :/ oh well...

>  				isolate_start_pfn =
>  					block_start_pfn - pageblock_nr_pages;
> +			}
>  			break;
> -		} else {
> +		} else if (isolate_start_pfn < block_end_pfn) {
>  			/*
> -			 * isolate_freepages_block() should not terminate
> -			 * prematurely unless contended, or isolated enough
> +			 * If isolation failed early, do not continue
> +			 * needlessly.
>  			 */
> -			VM_BUG_ON(isolate_start_pfn < block_end_pfn);
> +			isolate_start_pfn = block_start_pfn;

Note that this reset shouldn't be in fact necessary - without it, next 
attempt would restart exactly at the pfn that we failed to split due to 
watermark checks. But not a big deal.

> +			break;
>  		}
>  	}
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
