Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 66FF28E0001
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 04:59:30 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c3so748004eda.3
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 01:59:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n14si3758557edy.344.2019.01.23.01.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 01:59:29 -0800 (PST)
Date: Wed, 23 Jan 2019 10:59:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: vmscan: do not iterate all mem cgroups for
 global direct reclaim
Message-ID: <20190123095926.GS4087@dhcp22.suse.cz>
References: <1548187782-108454-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1548187782-108454-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 23-01-19 04:09:42, Yang Shi wrote:
> In current implementation, both kswapd and direct reclaim has to iterate
> all mem cgroups.  It is not a problem before offline mem cgroups could
> be iterated.  But, currently with iterating offline mem cgroups, it
> could be very time consuming.  In our workloads, we saw over 400K mem
> cgroups accumulated in some cases, only a few hundred are online memcgs.
> Although kswapd could help out to reduce the number of memcgs, direct
> reclaim still get hit with iterating a number of offline memcgs in some
> cases.  We experienced the responsiveness problems due to this
> occassionally.

Can you provide some numbers?

> Here just break the iteration once it reclaims enough pages as what
> memcg direct reclaim does.  This may hurt the fairness among memcgs
> since direct reclaim may awlays do reclaim from same memcgs.  But, it
> sounds ok since direct reclaim just tries to reclaim SWAP_CLUSTER_MAX
> pages and memcgs can be protected by min/low.

OK, this makes some sense to me. The purpose of the direct reclaim is
to reclaim some memory and throttle the allocation pace. The iterator is
cached so the next reclaimer on the same hierarchy will simply continue
so the fairness should be more or less achieved.

Btw. is there any reason to keep !global_reclaim() check in place? Why
is it not sufficient to exclude kswapd?

> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  mm/vmscan.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a714c4f..ced5a16 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2764,16 +2764,15 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  				   sc->nr_reclaimed - reclaimed);
>  
>  			/*
> -			 * Direct reclaim and kswapd have to scan all memory
> -			 * cgroups to fulfill the overall scan target for the
> -			 * node.
> +			 * Kswapd have to scan all memory cgroups to fulfill
> +			 * the overall scan target for the node.
>  			 *
>  			 * Limit reclaim, on the other hand, only cares about
>  			 * nr_to_reclaim pages to be reclaimed and it will
>  			 * retry with decreasing priority if one round over the
>  			 * whole hierarchy is not sufficient.
>  			 */
> -			if (!global_reclaim(sc) &&
> +			if ((!global_reclaim(sc) || !current_is_kswapd()) &&
>  					sc->nr_reclaimed >= sc->nr_to_reclaim) {
>  				mem_cgroup_iter_break(root, memcg);
>  				break;
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
