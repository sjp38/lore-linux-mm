Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9516B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 11:57:51 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id d49so5126874eek.20
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 08:57:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x43si5037506eey.82.2014.02.13.08.57.48
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 08:57:49 -0800 (PST)
Message-ID: <52FCEE74.9010602@redhat.com>
Date: Thu, 13 Feb 2014 11:10:28 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm/vmscan: restore sc->gfp_mask after promoting it
 to __GFP_HIGHMEM
References: <000001cf2865$0aa2c0c0$1fe84240$%yang@samsung.com>
In-Reply-To: <000001cf2865$0aa2c0c0$1fe84240$%yang@samsung.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>, 'Mel Gorman' <mgorman@suse.de>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, weijie.yang.kh@gmail.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

On 02/12/2014 09:39 PM, Weijie Yang wrote:

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2298,14 +2298,17 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  	unsigned long nr_soft_reclaimed;
>  	unsigned long nr_soft_scanned;
>  	bool aborted_reclaim = false;
> +	bool promoted_mask = false;
>  
>  	/*
>  	 * If the number of buffer_heads in the machine exceeds the maximum
>  	 * allowed level, force direct reclaim to scan the highmem zone as
>  	 * highmem pages could be pinning lowmem pages storing buffer_heads
>  	 */
> -	if (buffer_heads_over_limit)
> +	if (buffer_heads_over_limit) {

It took me a minute to figure out why you are doing things this way,
so maybe this could use a comment, or maybe it could be done in a
simpler way, by simply saving and restoring the original mask?

		orig_mask = sc->gfp_mask;

> +		promoted_mask = !(sc->gfp_mask & __GFP_HIGHMEM);
>  		sc->gfp_mask |= __GFP_HIGHMEM;
> +	}
>  
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  					gfp_zone(sc->gfp_mask), sc->nodemask) {
> @@ -2354,6 +2357,9 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  		shrink_zone(zone, sc);
>  	}
>  
> +	if (promoted_mask)
		sc->gfp_mask = orig_mask;

> +		sc->gfp_mask &= ~__GFP_HIGHMEM;
> +
>  	return aborted_reclaim;
>  }
>  
> 


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
