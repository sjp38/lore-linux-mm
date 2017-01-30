Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1ACB66B0253
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 18:56:47 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so478063753pfx.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 15:56:47 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id t8si9686630pgn.178.2017.01.30.15.56.45
        for <linux-mm@kvack.org>;
        Mon, 30 Jan 2017 15:56:46 -0800 (PST)
Date: Tue, 31 Jan 2017 08:56:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2 v2] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170130235642.GB7942@bbox>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, shashim@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 27, 2017 at 01:43:36PM +0530, Vinayak Menon wrote:
> It is noticed that during a global reclaim the memory
> reclaimed via shrinking the slabs can sometimes result
> in reclaimed pages being greater than the scanned pages
> in shrink_node. When this is passed to vmpressure, the
> unsigned arithmetic results in the pressure value to be
> huge, thus resulting in a critical event being sent to
> root cgroup. While this can be fixed by underflow checks
> in vmpressure, adding reclaimed slab without a corresponding
> increment of nr_scanned results in incorrect vmpressure
> reporting. So do not consider reclaimed slab pages in
> vmpressure calculation.

I belive we could enhance the description better.

problem

VM include nr_reclaimed of slab but not nr_scanned so pressure
calculation can be underflow.

solution

do not consider reclaimed slab pages for vmpressure

why

Freeing a page by slab shrinking depends on each slab's object
population so the cost model(i.e., scan:free) is not fair with
LRU pages. Also, every shrinker doesn't account reclaimed pages.
Lastly, this regression happens since 6b4f7799c6a5

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

Please add comment about "vmpressure excludes reclaimed pages via slab
because blah blah blah" so upcoming patches doesn't make mistake again.

Thanks!

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
