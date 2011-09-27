Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 706E79000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 07:28:16 -0400 (EDT)
Date: Tue, 27 Sep 2011 13:28:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2]vmscan: correctly detect GFP_ATOMIC allocation failure
Message-ID: <20110927112810.GA3897@tiehlicka.suse.cz>
References: <1317108187.29510.201.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317108187.29510.201.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@google.com>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue 27-09-11 15:23:07, Shaohua Li wrote:
> has_under_min_watermark_zone is used to detect if there is GFP_ATOMIC allocation
> failure risk. For a high end_zone, if any zone below or equal to it has min
> matermark ok, we have no risk. But current logic is any zone has min watermark
> not ok, then we have risk. This is wrong to me.

This, however, means that we skip congestion_wait more often as ZONE_DMA
tend to be mostly balanced, right? This would mean that kswapd could hog
CPU more.
Does this fix any particular problem you are seeing?

> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> ---
>  mm/vmscan.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> Index: linux/mm/vmscan.c
> ===================================================================
> --- linux.orig/mm/vmscan.c	2011-09-27 15:09:29.000000000 +0800
> +++ linux/mm/vmscan.c	2011-09-27 15:14:45.000000000 +0800
> @@ -2463,7 +2463,7 @@ loop_again:
>  
>  	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
>  		unsigned long lru_pages = 0;
> -		int has_under_min_watermark_zone = 0;
> +		int has_under_min_watermark_zone = 1;
>  
>  		/* The swap token gets in the way of swapout... */
>  		if (!priority)
> @@ -2594,9 +2594,10 @@ loop_again:
>  				 * means that we have a GFP_ATOMIC allocation
>  				 * failure risk. Hurry up!
>  				 */
> -				if (!zone_watermark_ok_safe(zone, order,
> +				if (has_under_min_watermark_zone &&
> +					    zone_watermark_ok_safe(zone, order,
>  					    min_wmark_pages(zone), end_zone, 0))
> -					has_under_min_watermark_zone = 1;
> +					has_under_min_watermark_zone = 0;
>  			} else {
>  				/*
>  				 * If a zone reaches its high watermark,
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
