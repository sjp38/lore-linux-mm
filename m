Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 59A136B0069
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 11:37:46 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id gf13so1428014lab.29
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 08:37:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bc10si19560384lab.15.2014.10.21.08.37.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 08:37:43 -0700 (PDT)
Date: Tue, 21 Oct 2014 17:37:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: remove mem_cgroup_reclaimable check from soft
 reclaim
Message-ID: <20141021153741.GI9415@dhcp22.suse.cz>
References: <1413897350-32553-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413897350-32553-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 21-10-14 17:15:50, Vladimir Davydov wrote:
> mem_cgroup_reclaimable() checks whether a cgroup has reclaimable pages
> on *any* NUMA node. However, the only place where it's called is
> mem_cgroup_soft_reclaim(), which tries to reclaim memory from a
> *specific* zone. So the way how it's used is incorrect - it will return
> true even if the cgroup doesn't have pages on the zone we're scanning.
> 
> I think we can get rid of this check completely, because
> mem_cgroup_shrink_node_zone(), which is called by
> mem_cgroup_soft_reclaim() if mem_cgroup_reclaimable() returns true, is
> equivalent to shrink_lruvec(), which exits almost immediately if the
> lruvec passed to it is empty. So there's no need to optimize anything
> here. Besides, we don't have such a check in the general scan path
> (shrink_zone) either.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

yeah, let's ditch it. It doesn't make any sense without checking the
target zone and even then it is dubious bevause get_scan_count will give
us 0 target on an empty lru list.

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks

> ---
>  mm/memcontrol.c |   43 -------------------------------------------
>  1 file changed, 43 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 53393e27ff03..833b6a696aab 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1799,52 +1799,11 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
>  	memcg->last_scanned_node = node;
>  	return node;
>  }
> -
> -/*
> - * Check all nodes whether it contains reclaimable pages or not.
> - * For quick scan, we make use of scan_nodes. This will allow us to skip
> - * unused nodes. But scan_nodes is lazily updated and may not cotain
> - * enough new information. We need to do double check.
> - */
> -static bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
> -{
> -	int nid;
> -
> -	/*
> -	 * quick check...making use of scan_node.
> -	 * We can skip unused nodes.
> -	 */
> -	if (!nodes_empty(memcg->scan_nodes)) {
> -		for (nid = first_node(memcg->scan_nodes);
> -		     nid < MAX_NUMNODES;
> -		     nid = next_node(nid, memcg->scan_nodes)) {
> -
> -			if (test_mem_cgroup_node_reclaimable(memcg, nid, noswap))
> -				return true;
> -		}
> -	}
> -	/*
> -	 * Check rest of nodes.
> -	 */
> -	for_each_node_state(nid, N_MEMORY) {
> -		if (node_isset(nid, memcg->scan_nodes))
> -			continue;
> -		if (test_mem_cgroup_node_reclaimable(memcg, nid, noswap))
> -			return true;
> -	}
> -	return false;
> -}
> -
>  #else
>  int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
>  {
>  	return 0;
>  }
> -
> -static bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
> -{
> -	return test_mem_cgroup_node_reclaimable(memcg, 0, noswap);
> -}
>  #endif
>  
>  static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
> @@ -1888,8 +1847,6 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
>  			}
>  			continue;
>  		}
> -		if (!mem_cgroup_reclaimable(victim, false))
> -			continue;
>  		total += mem_cgroup_shrink_node_zone(victim, gfp_mask, false,
>  						     zone, &nr_scanned);
>  		*total_scanned += nr_scanned;
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
