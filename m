Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id E48A86B00C2
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 10:05:04 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id t61so2685335wes.14
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 07:05:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o10si3102221wix.17.2014.02.21.07.04.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 07:04:54 -0800 (PST)
Date: Fri, 21 Feb 2014 16:04:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: exclude memory less nodes from zone_reclaim
Message-ID: <20140221150455.GA27184@dhcp22.suse.cz>
References: <1392889904-18019-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1392889904-18019-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 20-02-14 10:51:44, Michal Hocko wrote:
> We had a report about strange OOM killer strikes on a PPC machine
> although there was a lot of swap free and a tons of anonymous memory
> which could be swapped out. In the end it turned out that the OOM was
> a side effect of zone reclaim which wasn't doesn't unmap and swapp out
> and so the system was pushed to the OOM. Although this sounds like a bug
> somewhere in the kswapd vs. zone reclaim vs. direct reclaim interaction
> numactl on the said hardware suggests that the zone reclaim should

Hmm, not somehow got lost... It should read "suggests that the zone
reclaim should not have been set in the first place"

> have been set in the first place:
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
> node 0 size: 0 MB
> node 0 free: 0 MB
> node 2 cpus:
> node 2 size: 7168 MB
> node 2 free: 6019 MB
> node distances:
> node   0   2
> 0:  10  40
> 2:  40  10
> 
> So all the CPUs are associated with Node0 which doesn't have any memory
> while Node2 contains all the available memory. Node distances cause an
> automatic zone_reclaim_mode enabling.
> 
> Zone reclaim is intended to keep the allocations local but this doesn't
> make any sense on the memory less nodes. So let's exclude such nodes
> for init_zone_allows_reclaim which evaluates zone reclaim behavior and
> suitable reclaim_nodes.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> Tested-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> ---
>  mm/page_alloc.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3e953f07edb0..fafb9e24e87f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1855,7 +1855,7 @@ static void __paginginit init_zone_allows_reclaim(int nid)
>  {
>  	int i;
>  
> -	for_each_online_node(i)
> +	for_each_node_state(i, N_MEMORY)
>  		if (node_distance(nid, i) <= RECLAIM_DISTANCE)
>  			node_set(i, NODE_DATA(nid)->reclaim_nodes);
>  		else
> @@ -4901,7 +4901,8 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>  
>  	pgdat->node_id = nid;
>  	pgdat->node_start_pfn = node_start_pfn;
> -	init_zone_allows_reclaim(nid);
> +	if (node_state(nid, N_MEMORY))
> +		init_zone_allows_reclaim(nid);
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
>  #endif
> -- 
> 1.9.0.rc3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
