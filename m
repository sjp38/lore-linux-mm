Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 19B816B0033
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 05:44:27 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id jz4so2992813wjb.5
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 02:44:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e56si28062048wre.332.2017.02.02.02.44.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Feb 2017 02:44:25 -0800 (PST)
Date: Thu, 2 Feb 2017 11:44:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2 v3] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170202104422.GF22806@dhcp22.suse.cz>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
 <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, minchan@kernel.org, shashim@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 31-01-17 14:32:08, Vinayak Menon wrote:
> During global reclaim, the nr_reclaimed passed to vmpressure
> includes the pages reclaimed from slab. But the corresponding
> scanned slab pages is not passed. This can cause total reclaimed
> pages to be greater than scanned, causing an unsigned underflow
> in vmpressure resulting in a critical event being sent to root
> cgroup. So do not consider reclaimed slab pages for vmpressure
> calculation. The reclaimed pages from slab can be excluded because
> the freeing of a page by slab shrinking depends on each slab's
> object population, making the cost model (i.e. scan:free) different
> from that of LRU.

This might be true but what happens if the slab reclaim contributes
significantly to the overal reclaim? This would be quite rare but not
impossible.

I am wondering why we cannot simply make cap nr_reclaimed to nr_scanned
and be done with this all? Sure it will be imprecise but the same will
be true with this approach.

> Also, not every shrinker accounts the pages it
> reclaims. This is a regression introduced by commit 6b4f7799c6a5
> ("mm: vmscan: invoke slab shrinkers from shrink_zone()").

We usually refer to the culprit comment as
Fixes: 6b4f7799c6a5 ("mm: vmscan: invoke slab shrinkers from shrink_zone()")
 
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> ---
>  mm/vmscan.c | 17 ++++++++++++-----
>  1 file changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 947ab6f..8969f8e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2594,16 +2594,23 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  				    sc->nr_scanned - nr_scanned,
>  				    node_lru_pages);
>  
> +		/*
> +		 * Record the subtree's reclaim efficiency. The reclaimed
> +		 * pages from slab is excluded here because the corresponding
> +		 * scanned pages is not accounted. Moreover, freeing a page
> +		 * by slab shrinking depends on each slab's object population,
> +		 * making the cost model (i.e. scan:free) different from that
> +		 * of LRU.
> +		 */
> +		vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
> +			   sc->nr_scanned - nr_scanned,
> +			   sc->nr_reclaimed - nr_reclaimed);
> +
>  		if (reclaim_state) {
>  			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
>  			reclaim_state->reclaimed_slab = 0;
>  		}
>  
> -		/* Record the subtree's reclaim efficiency */
> -		vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
> -			   sc->nr_scanned - nr_scanned,
> -			   sc->nr_reclaimed - nr_reclaimed);
> -
>  		if (sc->nr_reclaimed - nr_reclaimed)
>  			reclaimable = true;
>  
> -- 
> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
> member of the Code Aurora Forum, hosted by The Linux Foundation
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
