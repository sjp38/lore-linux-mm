Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86A616B0038
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 21:37:04 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l30so39175370pgc.15
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 18:37:04 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id s184si12879151pfb.65.2017.04.17.18.37.02
        for <linux-mm@kvack.org>;
        Mon, 17 Apr 2017 18:37:03 -0700 (PDT)
Date: Tue, 18 Apr 2017 10:36:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch] mm, vmscan: avoid thrashing anon lru when free + file is
 low
Message-ID: <20170418013659.GD21354@bbox>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com>
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello David,

On Mon, Apr 17, 2017 at 05:06:20PM -0700, David Rientjes wrote:
> The purpose of the code that commit 623762517e23 ("revert 'mm: vmscan: do
> not swap anon pages just because free+file is low'") reintroduces is to
> prefer swapping anonymous memory rather than trashing the file lru.
> 
> If all anonymous memory is unevictable, however, this insistance on

"unevictable" means hot workingset, not (mlocked and increased refcount
by some driver)?
I got confused.

> SCAN_ANON ends up thrashing that lru instead.

Sound reasonable.

> 
> Check that enough evictable anon memory is actually on this lruvec before
> insisting on SCAN_ANON.  SWAP_CLUSTER_MAX is used as the threshold to
> determine if only scanning anon is beneficial.

Why do you use SWAP_CLUSTER_MAX instead of (high wmark + free) like
file-backed pages?
As considering anonymous pages have more probability to become workingset
because they are are mapped, IMO, more {strong or equal} condition than
file-LRU would be better to prevent anon LRU thrashing.

> 
> Otherwise, fallback to balanced reclaim so the file lru doesn't remain
> untouched.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/vmscan.c | 41 +++++++++++++++++++++++------------------
>  1 file changed, 23 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2186,26 +2186,31 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  	 * anon pages.  Try to detect this based on file LRU size.

Please update this comment, too.

>  	 */
>  	if (global_reclaim(sc)) {
> -		unsigned long pgdatfile;
> -		unsigned long pgdatfree;
> -		int z;
> -		unsigned long total_high_wmark = 0;
> -
> -		pgdatfree = sum_zone_node_page_state(pgdat->node_id, NR_FREE_PAGES);
> -		pgdatfile = node_page_state(pgdat, NR_ACTIVE_FILE) +
> -			   node_page_state(pgdat, NR_INACTIVE_FILE);
> -
> -		for (z = 0; z < MAX_NR_ZONES; z++) {
> -			struct zone *zone = &pgdat->node_zones[z];
> -			if (!managed_zone(zone))
> -				continue;
> +		anon = lruvec_lru_size(lruvec, LRU_ACTIVE_ANON, sc->reclaim_idx) +
> +		       lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx);
> +		if (likely(anon >= SWAP_CLUSTER_MAX)) {

With high_wmark, we can do this.

        if (global_reclaim(sc)) {
                pgdatfree = xxx;
                pgdatfile = xxx;
                total_high_wmark = xxx;

                if (pgdatfile + pgdatfree <= total_high_wmark) {
                        pgdatanon = xxx;
                        if (pgdatanon + pgdatfree > total_high_wmark) {
                                scan_balance = SCAN_ANON;
                                goto out;
                        }
                }
        }


> +			unsigned long total_high_wmark = 0;
> +			unsigned long pgdatfile;
> +			unsigned long pgdatfree;
> +			int z;
> +
> +			pgdatfree = sum_zone_node_page_state(pgdat->node_id,
> +							     NR_FREE_PAGES);
> +			pgdatfile = node_page_state(pgdat, NR_ACTIVE_FILE) +
> +				    node_page_state(pgdat, NR_INACTIVE_FILE);
> +
> +			for (z = 0; z < MAX_NR_ZONES; z++) {
> +				struct zone *zone = &pgdat->node_zones[z];
> +				if (!managed_zone(zone))
> +					continue;
>  
> -			total_high_wmark += high_wmark_pages(zone);
> -		}
> +				total_high_wmark += high_wmark_pages(zone);
> +			}
>  
> -		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
> -			scan_balance = SCAN_ANON;
> -			goto out;
> +			if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
> +				scan_balance = SCAN_ANON;
> +				goto out;
> +			}
>  		}
>  	}
>  
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
