Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAD76B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 22:09:45 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 80so44946225pfy.2
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 19:09:45 -0800 (PST)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id y87si27166777pff.250.2017.02.03.19.09.42
        for <linux-mm@kvack.org>;
        Fri, 03 Feb 2017 19:09:44 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170203203222.gq7hk66yc36lpgtb@suse.de>
In-Reply-To: <20170203203222.gq7hk66yc36lpgtb@suse.de>
Subject: Re: [PATCH] mm, vmscan: Clear PGDAT_WRITEBACK when zone is balanced
Date: Sat, 04 Feb 2017 11:09:27 +0800
Message-ID: <007701d27e94$18ea17e0$4abe47a0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@suse.de>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Michal Hocko' <mhocko@suse.com>, 'Minchan Kim' <minchan.kim@gmail.com>, 'Rik van Riel' <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On February 04, 2017 4:32 AM Mel Gorman wrote: 
> 
> Hillf Danton pointed out that since commit 1d82de618dd ("mm, vmscan:
> make kswapd reclaim in terms of nodes") that PGDAT_WRITEBACK is no longer
> cleared. It was not noticed as triggering it requires pages under writeback
> to cycle twice through the LRU and before kswapd gets stalled. Historically,
> such issues tended to occur on small machines writing heavily to slow
> storage such as a USB stick. Once kswapd stalls, direct reclaim stalls may
> be higher but due to the fact that memory pressure is requires, it would not
> be very noticable. Michal Hocko suggested removing the flag entirely but
> the conservative fix is to restore the intended PGDAT_WRITEBACK behaviour
> and clear the flag when a suitable zone is balanced.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/vmscan.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 532a2a750952..3379fa5ce6d8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3103,6 +3103,7 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
>  	 */
>  	clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
>  	clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
> +	clear_bit(PGDAT_WRITEBACK, &zone->zone_pgdat->flags);
> 
>  	return true;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
