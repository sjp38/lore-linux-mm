Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 09FC06B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 03:10:16 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id kq3so16738003wjc.1
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 00:10:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w91si41080931wrb.163.2017.02.06.00.10.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 00:10:10 -0800 (PST)
Date: Mon, 6 Feb 2017 09:10:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm, vmscan: consider eligible zones in get_scan_count
Message-ID: <20170206081006.GA3085@dhcp22.suse.cz>
References: <20170117103702.28542-1-mhocko@kernel.org>
 <20170117103702.28542-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117103702.28542-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Trevor Cordes <trevor@tecnopolis.ca>

Hi Andrew,
it turned out that this is not a theoretical issue after all. Trevor
(added to the CC) was seeing pre-mature OOM killer triggering [1]
bisected to b2e18757f2c9 ("mm, vmscan: begin reclaiming pages on a
per-node basis").
After some going back and forth it turned out that b4536f0c829c ("mm,
memcg: fix the active list aging for lowmem requests when memcg is
enabled") helped a lot but it wasn't sufficient on its own. We also
need this patch to make the oom behavior stable again. So I suggest
backporting this to stable as well. Could you update the changelog as
follows?

The patch would need to be tweaked a bit to apply to 4.10 and older
but I will do that as soon as it hits the Linus tree in the next merge
window.

[1] http://lkml.kernel.org/r/20170111103243.GA27795@pog.tecnopolis.ca

On Tue 17-01-17 11:37:01, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> get_scan_count considers the whole node LRU size when
> - doing SCAN_FILE due to many page cache inactive pages
> - calculating the number of pages to scan
> 
> in both cases this might lead to unexpected behavior especially on 32b
> systems where we can expect lowmem memory pressure very often.
> 
> A large highmem zone can easily distort SCAN_FILE heuristic because
> there might be only few file pages from the eligible zones on the node
> lru and we would still enforce file lru scanning which can lead to
> trashing while we could still scan anonymous pages.
> 
> The later use of lruvec_lru_size can be problematic as well. Especially
> when there are not many pages from the eligible zones. We would have to
> skip over many pages to find anything to reclaim but shrink_node_memcg
> would only reduce the remaining number to scan by SWAP_CLUSTER_MAX
> at maximum. Therefore we can end up going over a large LRU many times
> without actually having chance to reclaim much if anything at all. The
> closer we are out of memory on lowmem zone the worse the problem will
> be.
> 
> Fix this by filtering out all the ineligible zones when calculating the
> lru size for both paths and consider only sc->reclaim_idx zones.
> 

Fixes: b2e18757f2c9 ("mm, vmscan: begin reclaiming pages on a per-node basis")
Cc: stable # 4.8+
Tested-by: Trevor Cordes <trevor@tecnopolis.ca>

> Acked-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/vmscan.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index aed39dc272c0..ffac8fa7bdd8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2235,7 +2235,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  	 * system is under heavy pressure.
>  	 */
>  	if (!inactive_list_is_low(lruvec, true, sc, false) &&
> -	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, MAX_NR_ZONES) >> sc->priority) {
> +	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
>  		scan_balance = SCAN_FILE;
>  		goto out;
>  	}
> @@ -2302,7 +2302,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  			unsigned long size;
>  			unsigned long scan;
>  
> -			size = lruvec_lru_size(lruvec, lru, MAX_NR_ZONES);
> +			size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
>  			scan = size >> sc->priority;
>  
>  			if (!scan && pass && force_scan)
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
