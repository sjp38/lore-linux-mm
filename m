Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 29DCD6B0256
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 08:53:51 -0500 (EST)
Received: by lffu14 with SMTP id u14so21370467lff.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:53:50 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 79si12410348lfs.4.2015.11.24.05.53.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 05:53:49 -0800 (PST)
Date: Tue, 24 Nov 2015 16:53:35 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/2] mm, vmscan: consider isolated pages in
 zone_reclaimable_pages
Message-ID: <20151124135335.GI29014@esperanza>
References: <1448366100-11023-1-git-send-email-mhocko@kernel.org>
 <1448366100-11023-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1448366100-11023-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Nov 24, 2015 at 12:54:59PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> zone_reclaimable_pages counts how many pages are reclaimable in
> the given zone. This currently includes all pages on file lrus and
> anon lrus if there is an available swap storage. We do not consider
> NR_ISOLATED_{ANON,FILE} counters though which is not correct because
> these counters reflect temporarily isolated pages which are still
> reclaimable because they either get back to their LRU or get freed
> either by the page reclaim or page migration.
> 
> The number of these pages might be sufficiently high to confuse users of
> zone_reclaimable_pages (e.g. mbind can migrate large ranges of memory at
> once).

Sounds reasonable to me.

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks,
Vladimir

> 
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/vmscan.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a4507ecaefbf..946d348f5040 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -197,11 +197,13 @@ static unsigned long zone_reclaimable_pages(struct zone *zone)
>  	unsigned long nr;
>  
>  	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
> -	     zone_page_state(zone, NR_INACTIVE_FILE);
> +	     zone_page_state(zone, NR_INACTIVE_FILE) +
> +	     zone_page_state(zone, NR_ISOLATED_FILE);
>  
>  	if (get_nr_swap_pages() > 0)
>  		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
> -		      zone_page_state(zone, NR_INACTIVE_ANON);
> +		      zone_page_state(zone, NR_INACTIVE_ANON) +
> +		      zone_page_state(zone, NR_ISOLATED_ANON);
>  
>  	return nr;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
