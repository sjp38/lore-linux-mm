Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 899586B002C
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 23:20:01 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p983JuNI025939
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 20:19:59 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by hpaq3.eem.corp.google.com with ESMTP id p983JFNN013487
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 20:19:55 -0700
Received: by pzk33 with SMTP id 33so16397579pzk.4
        for <linux-mm@kvack.org>; Fri, 07 Oct 2011 20:19:54 -0700 (PDT)
Date: Fri, 7 Oct 2011 20:19:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2]vmscan: correctly detect GFP_ATOMIC allocation
 failure
In-Reply-To: <1318043674.22361.38.camel@sli10-conroe>
Message-ID: <alpine.DEB.2.00.1110072014040.13992@chino.kir.corp.google.com>
References: <1317108187.29510.201.camel@sli10-conroe> <20110927112810.GA3897@tiehlicka.suse.cz> <1317170933.22361.5.camel@sli10-conroe> <20110928092751.GA15062@tiehlicka.suse.cz> <1318043674.22361.38.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, MinchanKim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>

On Sat, 8 Oct 2011, Shaohua Li wrote:

> has_under_min_watermark_zone is used to detect if there is GFP_ATOMIC allocation
> failure risk. For a high end_zone, if any zone below or equal to it has min
> matermark ok, we have no risk. But current logic is any zone has min watermark
> not ok, then we have risk. This is wrong to me.
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

bool

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

Ignore checking the min watermark for a moment and consider if all zones 
are above the high watermark (a situation where kswapd does not need to 
do aggressive reclaim), then has_under_min_watermark_zone doesn't get 
cleared and never actually stalls on congestion_wait().  Notice this is 
congestion_wait() and not wait_iff_congested(), so the clearing of 
ZONE_CONGESTED doesn't prevent this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
