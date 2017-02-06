Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8456B0069
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 03:31:31 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r141so17984004wmg.4
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 00:31:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p184si7174575wmg.66.2017.02.06.00.31.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 00:31:29 -0800 (PST)
Date: Mon, 6 Feb 2017 09:31:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmscan: fix zone balance check in prepare_kswapd_sleep
Message-ID: <20170206083128.GC3085@dhcp22.suse.cz>
References: <719282122.1183240.1486298780546.ref@mail.yahoo.com>
 <719282122.1183240.1486298780546@mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <719282122.1183240.1486298780546@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shantanu Goel <sgoel01@yahoo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

[CC Vlastimil]

On Sun 05-02-17 12:46:20, Shantanu Goel wrote:
> Hi,
> 
> On 4.9.7 kswapd is failing to wake up kcompactd due to a mismatch in the zone balance check between balance_pgdat() and prepare_kswapd_sleep().  balance_pgdat() returns as soon as a single zone satisfies the allocation but prepare_kswapd_sleep() requires all zones to do the same.  This causes prepare_kswapd_sleep() to never succeed except in the order == 0 case and consequently, wakeup_kcompactd() is never called.  On my machine prior to apply this patch, the state of compaction from /proc/vmstat looked this way after a day and a half of uptime:
> 
> compact_migrate_scanned 240496
> compact_free_scanned 76238632
> compact_isolated 123472
> compact_stall 1791
> compact_fail 29
> compact_success 1762
> compact_daemon_wake 0
> 
> 
> After applying the patch and about 10 hours of uptime the state looks like this:
> 
> compact_migrate_scanned 59927299
> compact_free_scanned 2021075136
> compact_isolated 640926
> compact_stall 4
> compact_fail 2
> compact_success 2
> compact_daemon_wake 5160
> 
> 
> Thanks,
> Shantanu

> From 46f2e4b02ac263bf50d69cdab3bcbd7bcdea7415 Mon Sep 17 00:00:00 2001
> From: Shantanu Goel <sgoel01@yahoo.com>
> Date: Sat, 4 Feb 2017 19:07:53 -0500
> Subject: [PATCH] vmscan: fix zone balance check in prepare_kswapd_sleep
> 
> The check in prepare_kswapd_sleep needs to match the one in balance_pgdat
> since the latter will return as soon as any one of the zones in the
> classzone is above the watermark.  This is specially important for
> higher order allocations since balance_pgdat will typically reset
> the order to zero relying on compaction to create the higher order
> pages.  Without this patch, prepare_kswapd_sleep fails to wake up
> kcompactd since the zone balance check fails.
> 
> Signed-off-by: Shantanu Goel <sgoel01@yahoo.com>
> ---
>  mm/vmscan.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7682469..11899ff 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3142,11 +3142,11 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
>  		if (!managed_zone(zone))
>  			continue;
>  
> -		if (!zone_balanced(zone, order, classzone_idx))
> -			return false;
> +		if (zone_balanced(zone, order, classzone_idx))
> +			return true;
>  	}
>  
> -	return true;
> +	return false;
>  }
>  
>  /*
> -- 
> 2.7.4
> 


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
