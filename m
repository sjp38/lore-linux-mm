Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE9F6B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 18:27:16 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e4so159292687pfg.4
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:27:16 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a4si3008673pli.200.2017.01.25.15.27.14
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 15:27:15 -0800 (PST)
Date: Thu, 26 Jan 2017 08:27:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: vmscan: do not pass reclaimed slab to vmpressure
Message-ID: <20170125232713.GB20811@bbox>
References: <1485344318-6418-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485344318-6418-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, shiraz.hashim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Vinayak,

On Wed, Jan 25, 2017 at 05:08:38PM +0530, Vinayak Menon wrote:
> It is noticed that during a global reclaim the memory
> reclaimed via shrinking the slabs can sometimes result
> in reclaimed pages being greater than the scanned pages
> in shrink_node. When this is passed to vmpressure, the

I don't know you are saying zsmalloc. Anyway, it's one of those which
free larger pages than requested. I should fix that but was not sent
yet, unfortunately.

> unsigned arithmetic results in the pressure value to be
> huge, thus resulting in a critical event being sent to
> root cgroup. Fix this by not passing the reclaimed slab
> count to vmpressure, with the assumption that vmpressure
> should show the actual pressure on LRU which is now
> diluted by adding reclaimed slab without a corresponding
> scanned value.

I can't guess justfication of your assumption from the description.
Why do we consider only LRU pages for vmpressure? Could you elaborate
a bit?

Thanks.

> 
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> ---
>  mm/vmscan.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 947ab6f..37c4486 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2594,16 +2594,16 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  				    sc->nr_scanned - nr_scanned,
>  				    node_lru_pages);
>  
> -		if (reclaim_state) {
> -			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> -			reclaim_state->reclaimed_slab = 0;
> -		}
> -
>  		/* Record the subtree's reclaim efficiency */
>  		vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
>  			   sc->nr_scanned - nr_scanned,
>  			   sc->nr_reclaimed - nr_reclaimed);
>  
> +		if (reclaim_state) {
> +			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> +			reclaim_state->reclaimed_slab = 0;
> +		}
> +
>  		if (sc->nr_reclaimed - nr_reclaimed)
>  			reclaimable = true;
>  
> -- 
> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
> member of the Code Aurora Forum, hosted by The Linux Foundation
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
