Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 853DA6B0055
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 09:38:03 -0400 (EDT)
Date: Wed, 17 Jun 2009 14:39:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/5] Use per hstate nodes_allowed to constrain huge
	page allocation
Message-ID: <20090617133911.GI28529@csn.ul.ie>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook> <20090616135301.25248.91276.sendpatchset@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090616135301.25248.91276.sendpatchset@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 16, 2009 at 09:53:01AM -0400, Lee Schermerhorn wrote:
> [PATCH 3/5] Use per hstate nodes_allowed to constrain huge page allocation
> 
> Against:  17may09 mmotm
> 
> Select only nodes from the per hstate nodes_allowed mask when
> promoting surplus pages to persistent or when allocating fresh
> huge pages to the pool.
> 
> Note that alloc_buddy_huge_page() still uses task policy to allocate
> surplus huge pages.  This could be changed.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  mm/hugetlb.c |   23 ++++++++++++++++++-----
>  1 file changed, 18 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6.30-rc8-mmotm-090603-1633/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.30-rc8-mmotm-090603-1633.orig/mm/hugetlb.c	2009-06-04 12:59:32.000000000 -0400
> +++ linux-2.6.30-rc8-mmotm-090603-1633/mm/hugetlb.c	2009-06-04 12:59:33.000000000 -0400
> @@ -637,9 +637,9 @@ static struct page *alloc_fresh_huge_pag
>  static int hstate_next_node(struct hstate *h)
>  {
>  	int next_nid;
> -	next_nid = next_node(h->hugetlb_next_nid, node_online_map);
> +	next_nid = next_node(h->hugetlb_next_nid, *h->nodes_allowed);
>  	if (next_nid == MAX_NUMNODES)
> -		next_nid = first_node(node_online_map);
> +		next_nid = first_node(*h->nodes_allowed);
>  	h->hugetlb_next_nid = next_nid;
>  	return next_nid;
>  }
> @@ -652,6 +652,11 @@ static int alloc_fresh_huge_page(struct 
>  	int ret = 0;
>  
>  	start_nid = h->hugetlb_next_nid;
> +	/*
> +	 * we may have allocated with a different nodes_allowed previously
> +	 */
> +	if (!node_isset(start_nid, *h->nodes_allowed))
> +		start_nid = hstate_next_node(h);
>  
>  	do {
>  		page = alloc_fresh_huge_page_node(h, h->hugetlb_next_nid);
> @@ -1169,20 +1174,28 @@ static inline void try_to_free_low(struc
>  
>  /*
>   * Increment or decrement surplus_huge_pages.  Keep node-specific counters
> - * balanced by operating on them in a round-robin fashion.
> + * balanced by operating on them in a round-robin fashion.  Use nodes_allowed
> + * mask when decreasing suplus pages as we're "promoting" them to persistent.

s/suplus/surplus/

> + * Use node_online_map for increment surplus pages as we're demoting previously
> + * persistent huge pages.
> + * Called holding the hugetlb_lock.
>   * Returns 1 if an adjustment was made.
>   */
>  static int adjust_pool_surplus(struct hstate *h, int delta)
>  {
> +	nodemask_t *nodemask = &node_online_map;
>  	static int prev_nid;
>  	int nid = prev_nid;
>  	int ret = 0;
>  
>  	VM_BUG_ON(delta != -1 && delta != 1);
> +	if (delta < 0)
> +		nodemask = h->nodes_allowed;
> +

Please spell out why nodes_allowed is only used when decreasing the surplus
count.

>  	do {
> -		nid = next_node(nid, node_online_map);
> +		nid = next_node(nid, *nodemask);
>  		if (nid == MAX_NUMNODES)
> -			nid = first_node(node_online_map);
> +			nid = first_node(*nodemask);
>  
>  		/* To shrink on this node, there must be a surplus page */
>  		if (delta < 0 && !h->surplus_huge_pages_node[nid])
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
