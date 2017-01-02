Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F66B6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 09:16:27 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xr1so107641650wjb.7
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 06:16:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 203si69645370wms.92.2017.01.02.06.16.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Jan 2017 06:16:25 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: fix remote numa hits statistics
References: <20161221075711.GF16502@dhcp22.suse.cz>
 <20161221080653.29437-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1d9e466b-dc87-eb41-113f-e7737a4bb7ef@suse.cz>
Date: Mon, 2 Jan 2017 15:16:23 +0100
MIME-Version: 1.0
In-Reply-To: <20161221080653.29437-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, Jia He <hejianet@gmail.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On 12/21/2016 09:06 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Jia He has noticed that b9f00e147f27 ("mm, page_alloc: reduce branches
> in zone_statistics") has an unintentional side effect that remote node
> allocation requests are accounted as NUMA_MISS rathat than NUMA_HIT and
> NUMA_OTHER if such a request doesn't use __GFP_OTHER_NODE. There are
> many of these potentially because the flag is used very rarely while
> we have many users of __alloc_pages_node.
> 
> Fix this by simply ignoring __GFP_OTHER_NODE (it can be removed in a
> follow up patch) and treat all allocations that were satisfied from the
> preferred zone's node as NUMA_HITS because this is the same node we
> requested the allocation from in most cases. If this is not the local
> node then we just account it as NUMA_OTHER rather than NUMA_LOCAL.
> 
> One downsize would be that an allocation request for a node which is
> outside of the mempolicy nodemask would be reported as a hit which is a
> bit weird but that was the case before b9f00e147f27 already.
> 
> Reported-by: Jia He <hejianet@gmail.com>
> Fixes: b9f00e147f27 ("mm, page_alloc: reduce branches in zone_statistics")
> Signed-off-by: Michal Hocko <mhocko@suse.com>

cbmc tells me that this patch is not equal to pre-commit b9f00e147f27
(in situation where __GFP_OTHER_NODE is not passed, as that's the only
relevant scenario after your patch), which seems unintended.

counter example:
numa_node_id() == 1
preferred_zone on node 0
allocated from zone on node 1

pre-b9f00e147f27:
allocated zone (node 1) increased NUMA_MISS and NUMA_LOCAL
preferred zone (node 0) increased NUMA_FOREIGN

(that looks correct to me)

your patch:
allocated zone (node 1) increased NUMA_MISS
preferred zone (node 0) increased NUMA_FOREIGN

i.e. it's missing NUMA_LOCAL on node 1, which is IMHO wrong as this was
an allocation local to the CPU (albeit a MISS wrt the preferred node).

Vlastimil

> ---
>  mm/page_alloc.c | 16 ++++------------
>  1 file changed, 4 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f6d5b73e1d7c..506946a902c5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2583,25 +2583,17 @@ int __isolate_free_page(struct page *page, unsigned int order)
>   * Update NUMA hit/miss statistics
>   *
>   * Must be called with interrupts disabled.
> - *
> - * When __GFP_OTHER_NODE is set assume the node of the preferred
> - * zone is the local node. This is useful for daemons who allocate
> - * memory on behalf of other processes.
>   */
>  static inline void zone_statistics(struct zone *preferred_zone, struct zone *z,
>  								gfp_t flags)
>  {
>  #ifdef CONFIG_NUMA
> -	int local_nid = numa_node_id();
> -	enum zone_stat_item local_stat = NUMA_LOCAL;
> -
> -	if (unlikely(flags & __GFP_OTHER_NODE)) {
> -		local_stat = NUMA_OTHER;
> -		local_nid = preferred_zone->node;
> -	}
> +	if (z->node == preferred_zone->node) {
> +		enum zone_stat_item local_stat = NUMA_LOCAL;
>  
> -	if (z->node == local_nid) {
>  		__inc_zone_state(z, NUMA_HIT);
> +		if (z->node != numa_node_id())
> +			local_stat = NUMA_OTHER;
>  		__inc_zone_state(z, local_stat);
>  	} else {
>  		__inc_zone_state(z, NUMA_MISS);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
