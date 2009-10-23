Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E84E16B004D
	for <linux-mm@kvack.org>; Fri, 23 Oct 2009 13:31:01 -0400 (EDT)
Date: Fri, 23 Oct 2009 10:52:42 -0700 (PDT)
From: Vincent Li <root@brc.ubc.ca>
Subject: Re: [PATCH 3/5] vmscan: Force kswapd to take notice faster when
 high-order watermarks are being hit
In-Reply-To: <1256221356-26049-4-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.00.0910231042090.22373@mail.selltech.ca>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-4-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org\"" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


I trimmed out most CC recipients while replying this message cause I don't 
want to fill out everybody's mailbox with my noise. :-)

On Thu, 22 Oct 2009, Mel Gorman wrote:

> When a high-order allocation fails, kswapd is kicked so that it reclaims
> at a higher-order to avoid direct reclaimers stall and to help GFP_ATOMIC
> allocations. Something has changed in recent kernels that affect the timing
> where high-order GFP_ATOMIC allocations are now failing with more frequency,
> particularly under pressure. This patch forces kswapd to notice sooner that
> high-order allocations are occuring.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/vmscan.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 64e4388..cd68109 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2016,6 +2016,15 @@ loop_again:
>  					priority != DEF_PRIORITY)
>  				continue;
>  
> +			/*
> +			 * Exit quickly to restart if it has been indicated
                           ^^^^^^^^^^^^^^^^^^^^^^^ meaning exit to 
lable loop_again in balance_pgdat ?

> +			 * that higher orders are required
> +			 */
> +			if (pgdat->kswapd_max_order > order) {
> +				all_zones_ok = 1;
> +				goto out;
> +			}

If exit quickly to loop_again, shouldn't all_zones_ok be 0 instead of 1?

> +
>  			if (!zone_watermark_ok(zone, order,
>  					high_wmark_pages(zone), end_zone, 0))
>  				all_zones_ok = 0;
> -- 
> 1.6.3.3
> 

Thanks for clarification in advance.

Vincent

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
