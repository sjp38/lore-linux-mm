Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 93E2682F64
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 08:07:57 -0500 (EST)
Received: by lfaz4 with SMTP id z4so19696637lfa.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:07:56 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id r190si12217242lfd.110.2015.11.24.05.07.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 05:07:55 -0800 (PST)
Date: Tue, 24 Nov 2015 16:07:40 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 2/2] mm, vmscan: do not overestimate anonymous
 reclaimable pages
Message-ID: <20151124130740.GG29014@esperanza>
References: <1448366100-11023-1-git-send-email-mhocko@kernel.org>
 <1448366100-11023-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1448366100-11023-3-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Nov 24, 2015 at 12:55:00PM +0100, Michal Hocko wrote:
> zone_reclaimable_pages considers all anonymous pages on LRUs reclaimable
> if there is at least one entry on the swap storage left. This can be
> really misleading when the swap is short on space and skew reclaim
> decisions based on zone_reclaimable_pages. Fix this by clamping the
> number to the minimum of the available swap space and anon LRU pages.

Suppose there's 100M of swap and 1G of anon pages. This patch makes
zone_reclaimable_pages return 100M instead of 1G in this case. If you
rotate 600M of oldest anon pages, which is quite possible,
zone_reclaimable will start returning false, which is wrong, because
there are still 400M pages that were not even scanned, besides those
600M of rotated pages could have become reclaimable after their ref bits
got cleared.

I think it is the name of zone_reclaimable_pages which is misleading. It
should be called something like "zone_scannable_pages" judging by how it
is used in zone_reclaimable.

Thanks,
Vladimir

> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/vmscan.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 946d348f5040..646001a1f279 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -195,15 +195,20 @@ static bool sane_reclaim(struct scan_control *sc)
>  static unsigned long zone_reclaimable_pages(struct zone *zone)
>  {
>  	unsigned long nr;
> +	long nr_swap = get_nr_swap_pages();
>  
>  	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
>  	     zone_page_state(zone, NR_INACTIVE_FILE) +
>  	     zone_page_state(zone, NR_ISOLATED_FILE);
>  
> -	if (get_nr_swap_pages() > 0)
> -		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
> -		      zone_page_state(zone, NR_INACTIVE_ANON) +
> -		      zone_page_state(zone, NR_ISOLATED_ANON);
> +	if (nr_swap > 0) {
> +		unsigned long anon;
> +
> +		anon = zone_page_state(zone, NR_ACTIVE_ANON) +
> +		       zone_page_state(zone, NR_INACTIVE_ANON) +
> +		       zone_page_state(zone, NR_ISOLATED_ANON);
> +		nr += min_t(unsigned long, nr_swap, anon);
> +	}
>  
>  	return nr;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
