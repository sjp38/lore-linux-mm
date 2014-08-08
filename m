Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 248286B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 11:27:21 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so1201594wib.10
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 08:27:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lj18si3669366wic.98.2014.08.08.08.27.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 08 Aug 2014 08:27:17 -0700 (PDT)
Message-ID: <53E4EC53.1050904@suse.cz>
Date: Fri, 08 Aug 2014 17:27:15 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] mm: page_alloc: Reduce cost of the fair zone allocation
 policy
References: <1404893588-21371-1-git-send-email-mgorman@suse.de> <1404893588-21371-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1404893588-21371-7-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On 07/09/2014 10:13 AM, Mel Gorman wrote:
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1604,6 +1604,9 @@ again:
>  	}
>  
>  	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));

This can underflow zero, right?

> +	if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&

AFAICS, zone_page_state will correct negative values to zero only for
CONFIG_SMP. Won't this check be broken on !CONFIG_SMP?

I just stumbled upon this when trying to optimize the function. I didn't check
how rest of the design copes with negative NR_ALLOC_BATCH values.

> +	    !zone_is_fair_depleted(zone))
> +		zone_set_flag(zone, ZONE_FAIR_DEPLETED);
>  
>  	__count_zone_vm_events(PGALLOC, zone, 1 << order);
>  	zone_statistics(preferred_zone, zone, gfp_flags);
> @@ -1915,6 +1918,18 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
>  
>  #endif	/* CONFIG_NUMA */
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
