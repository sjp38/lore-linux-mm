Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1DF6B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 10:03:02 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c143so3477089wmd.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 07:03:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s136si7265928wmd.98.2017.03.01.07.03.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 07:03:00 -0800 (PST)
Date: Wed, 1 Mar 2017 16:02:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/9] mm: fix check for reclaimable pages in PF_MEMALLOC
 reclaim throttling
Message-ID: <20170301150259.GB11730@dhcp22.suse.cz>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-3-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228214007.5621-3-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 28-02-17 16:40:00, Johannes Weiner wrote:
> PF_MEMALLOC direct reclaimers get throttled on a node when the sum of
> all free pages in each zone fall below half the min watermark. During
> the summation, we want to exclude zones that don't have reclaimables.
> Checking the same pgdat over and over again doesn't make sense.
> 
> Fixes: 599d0c954f91 ("mm, vmscan: move LRU lists to node")
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 407b27831ff7..f006140f58c6 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2838,8 +2838,10 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
>  
>  	for (i = 0; i <= ZONE_NORMAL; i++) {
>  		zone = &pgdat->node_zones[i];
> -		if (!managed_zone(zone) ||
> -		    pgdat_reclaimable_pages(pgdat) == 0)
> +		if (!managed_zone(zone))
> +			continue;
> +
> +		if (!zone_reclaimable_pages(zone))
>  			continue;
>  
>  		pfmemalloc_reserve += min_wmark_pages(zone);
> -- 
> 2.11.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
