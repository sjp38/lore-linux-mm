Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 574986B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 20:24:58 -0500 (EST)
Received: by mail-da0-f53.google.com with SMTP id x6so510964dac.12
        for <linux-mm@kvack.org>; Thu, 10 Jan 2013 17:24:57 -0800 (PST)
Message-ID: <1357867501.6568.19.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH] mm: wait for congestion to clear on all zones
From: Simon Jeons <simon.jeons@gmail.com>
Date: Thu, 10 Jan 2013 19:25:01 -0600
In-Reply-To: <50EDE41C.7090107@iskon.hr>
References: <50EDE41C.7090107@iskon.hr>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 2013-01-09 at 22:41 +0100, Zlatko Calusic wrote:
> From: Zlatko Calusic <zlatko.calusic@iskon.hr>
> 
> Currently we take a short nap (HZ/10) and wait for congestion to clear
> before taking another pass with lower priority in balance_pgdat(). But
> we do that only for the highest zone that we encounter is unbalanced
> and congested.
> 
> This patch changes that to wait on all congested zones in a single
> pass in the hope that it will save us some scanning that way. Also we
> take a nap as soon as congested zone is encountered and sc.priority <
> DEF_PRIORITY - 2 (aka kswapd in trouble).

But you still didn't explain what's the problem you meat and what
scenario can get benefit from your change.

> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Zlatko Calusic <zlatko.calusic@iskon.hr>
> ---
> The patch is against the mm tree. Make sure that
> mm-avoid-calling-pgdat_balanced-needlessly.patch is applied first (not
> yet in the mmotm tree). Tested on half a dozen systems with different
> workloads for the last few days, working really well!
> 
>  mm/vmscan.c | 35 ++++++++++++-----------------------
>  1 file changed, 12 insertions(+), 23 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 002ade6..1c5d38a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2565,7 +2565,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  							int *classzone_idx)
>  {
>  	bool pgdat_is_balanced = false;
> -	struct zone *unbalanced_zone;
>  	int i;
>  	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
>  	unsigned long total_scanned;
> @@ -2596,9 +2595,6 @@ loop_again:
>  
>  	do {
>  		unsigned long lru_pages = 0;
> -		int has_under_min_watermark_zone = 0;
> -
> -		unbalanced_zone = NULL;
>  
>  		/*
>  		 * Scan in the highmem->dma direction for the highest
> @@ -2739,15 +2735,20 @@ loop_again:
>  			}
>  
>  			if (!zone_balanced(zone, testorder, 0, end_zone)) {
> -				unbalanced_zone = zone;
> -				/*
> -				 * We are still under min water mark.  This
> -				 * means that we have a GFP_ATOMIC allocation
> -				 * failure risk. Hurry up!
> -				 */
> +			    if (total_scanned && sc.priority < DEF_PRIORITY - 2) {
> +				/* OK, kswapd is getting into trouble. */
>  				if (!zone_watermark_ok_safe(zone, order,
>  					    min_wmark_pages(zone), end_zone, 0))
> -					has_under_min_watermark_zone = 1;
> +				    /*
> +				     * We are still under min water mark.
> +				     * This means that we have a GFP_ATOMIC
> +				     * allocation failure risk. Hurry up!
> +				     */
> +				    count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
> +				else
> +				    /* Take a nap if a zone is congested. */
> +				    wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> +			    }
>  			} else {
>  				/*
>  				 * If a zone reaches its high watermark,
> @@ -2758,7 +2759,6 @@ loop_again:
>  				 */
>  				zone_clear_flag(zone, ZONE_CONGESTED);
>  			}
> -
>  		}
>  
>  		/*
> @@ -2776,17 +2776,6 @@ loop_again:
>  		}
>  
>  		/*
> -		 * OK, kswapd is getting into trouble.  Take a nap, then take
> -		 * another pass across the zones.
> -		 */
> -		if (total_scanned && (sc.priority < DEF_PRIORITY - 2)) {
> -			if (has_under_min_watermark_zone)
> -				count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
> -			else if (unbalanced_zone)
> -				wait_iff_congested(unbalanced_zone, BLK_RW_ASYNC, HZ/10);
> -		}
> -
> -		/*
>  		 * We do this so kswapd doesn't build up large priorities for
>  		 * example when it is freeing in parallel with allocators. It
>  		 * matches the direct reclaim path behaviour in terms of impact
> -- 
> 1.8.1
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
