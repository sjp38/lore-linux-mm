Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C9BF46B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 04:18:45 -0400 (EDT)
Date: Thu, 9 Jul 2009 09:33:49 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] hugetlb:  add nodemask arg to huge page alloc,
	free and surplus adjust fcns
Message-ID: <20090709083349.GA29480@csn.ul.ie>
References: <20090708192430.20687.30157.sendpatchset@lts-notebook> <20090708192438.20687.21878.sendpatchset@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090708192438.20687.21878.sendpatchset@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 03:24:38PM -0400, Lee Schermerhorn wrote:
> [PATCH 1/3] hugetlb:  add nodemask arg to huge page alloc, free and surplus adjust fcns
> 
> Against: 25jun09 mmotm atop the "hugetlb: balance freeing..." series
> 
> In preparation for constraining huge page allocation and freeing by the
> controlling task's numa mempolicy, add a "nodes_allowed" nodemask pointer
> to the allocate, free and surplus adjustment functions.  For now, pass
> NULL to indicate default behavior--i.e., use node_online_map.  A
> subsqeuent patch will derive a non-default mask from the controlling 
> task's numa mempolicy.
> 
> Note the "cleanup" in alloc_bootmem_huge_page(): always advance next nid,
> even if allocation succeeds.  I believe that this is correct behavior,
> and I'll replace it in the next patch which assumes this behavior.
> However, perhaps the current code is correct:  we only want to advance
> bootmem huge page allocation to the next node when we've exhausted all
> huge pages on the current hstate "next_node_to_alloc".  Any who understands
> the rationale for this:  please advise.
> 

I think we covered this up in V1. What I said at the time was

	I strongly suspect that the same node being used until allocation
	failure instead of round-robin is an oversight and not deliberate
	at all. I can't think of a good reason for boot-allocation to behave
	significantly different to runtime-allocation.

But I looked briefly into it a bit more now. Maybe you could change the
changelog to say the following?

==== CUT HERE ====
Note the "cleanup" in alloc_bootmem_huge_page(): always advance next nid,
even if allocation succeeds.  I believe that this is correct behavior,
and I'll replace it in the next patch which assumes this behavior.
According to Mel Gorman;
	I strongly suspect that the same node being used until allocation
	failure instead of round-robin is an oversight and not deliberate
	at all. It appears to be a side-effect of a fix made way back in
	commit 63b4613c3f0d4b724ba259dc6c201bb68b884e1a ["hugetlb: fix
	hugepage allocation with memoryless nodes"]. Prior to that patch
	it looked like allocations would always round-robin even when
	allocation was successful.
==== CUT HERE ====

> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 

Other then the comment "/* always advance nid */" being on the same line
as the code and one minor piece of whitespace damage I point out below,
I can't see any problem with the patch.

Reviewed-by: Mel Gorman <mel@csn.ul.ie>


>  mm/hugetlb.c |   51 +++++++++++++++++++++++++++++++--------------------
>  1 file changed, 31 insertions(+), 20 deletions(-)
> 
> Index: linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.31-rc1-mmotm-090625-1549.orig/mm/hugetlb.c	2009-07-07 09:58:13.000000000 -0400
> +++ linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c	2009-07-07 09:58:17.000000000 -0400
> @@ -631,17 +631,22 @@ static struct page *alloc_fresh_huge_pag
>   * if we just successfully allocated a hugepage so that
>   * the next caller gets hugepages on the next node.
>   */
> -static int hstate_next_node_to_alloc(struct hstate *h)
> +static int hstate_next_node_to_alloc(struct hstate *h,
> +					nodemask_t *nodes_allowed)
>  {
>  	int next_nid;
> -	next_nid = next_node(h->next_nid_to_alloc, node_online_map);
> +
> +	if (!nodes_allowed)
> +		nodes_allowed = &node_online_map;
> +
> +	next_nid = next_node(h->next_nid_to_alloc, *nodes_allowed);
>  	if (next_nid == MAX_NUMNODES)
> -		next_nid = first_node(node_online_map);
> +		next_nid = first_node(*nodes_allowed);
>  	h->next_nid_to_alloc = next_nid;
>  	return next_nid;
>  }
>  
> -static int alloc_fresh_huge_page(struct hstate *h)
> +static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
>  {
>  	struct page *page;
>  	int start_nid;
> @@ -655,7 +660,7 @@ static int alloc_fresh_huge_page(struct 
>  		page = alloc_fresh_huge_page_node(h, next_nid);
>  		if (page)
>  			ret = 1;
> -		next_nid = hstate_next_node_to_alloc(h);
> +		next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
>  	} while (!page && next_nid != start_nid);
>  
>  	if (ret)
> @@ -670,12 +675,16 @@ static int alloc_fresh_huge_page(struct 
>   * helper for free_pool_huge_page() - find next node
>   * from which to free a huge page
>   */
> -static int hstate_next_node_to_free(struct hstate *h)
> +static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>  {
>  	int next_nid;
> -	next_nid = next_node(h->next_nid_to_free, node_online_map);
> +
> +	if (!nodes_allowed)
> +		nodes_allowed = &node_online_map;
> +
> +	next_nid = next_node(h->next_nid_to_free, *nodes_allowed);
>  	if (next_nid == MAX_NUMNODES)
> -		next_nid = first_node(node_online_map);
> +		next_nid = first_node(*nodes_allowed);
>  	h->next_nid_to_free = next_nid;
>  	return next_nid;
>  }
> @@ -686,7 +695,8 @@ static int hstate_next_node_to_free(stru
>   * balanced over allowed nodes.
>   * Called with hugetlb_lock locked.
>   */
> -static int free_pool_huge_page(struct hstate *h, bool acct_surplus)
> +static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
> +							 bool acct_surplus)
>  {
>  	int start_nid;
>  	int next_nid;
> @@ -715,7 +725,7 @@ static int free_pool_huge_page(struct hs
>  			update_and_free_page(h, page);
>  			ret = 1;
>  		}
> -		next_nid = hstate_next_node_to_free(h);
> + 		next_nid = hstate_next_node_to_free(h, nodes_allowed);

There is minor whitespace damage there - specifically space at the
beginning of the line.

>  	} while (!ret && next_nid != start_nid);
>  
>  	return ret;
> @@ -917,7 +927,7 @@ static void return_unused_surplus_pages(
>  	 * on-line nodes for us and will handle the hstate accounting.
>  	 */
>  	while (nr_pages--) {
> -		if (!free_pool_huge_page(h, 1))
> +		if (!free_pool_huge_page(h, NULL, 1))
>  			break;
>  	}
>  }
> @@ -1030,6 +1040,7 @@ int __weak alloc_bootmem_huge_page(struc
>  				NODE_DATA(h->next_nid_to_alloc),
>  				huge_page_size(h), huge_page_size(h), 0);
>  
> +		hstate_next_node_to_alloc(h, NULL); /* always advance nid */
>  		if (addr) {
>  			/*
>  			 * Use the beginning of the huge page to store the
> @@ -1039,7 +1050,6 @@ int __weak alloc_bootmem_huge_page(struc
>  			m = addr;
>  			goto found;
>  		}
> -		hstate_next_node_to_alloc(h);
>  		nr_nodes--;
>  	}
>  	return 0;
> @@ -1083,7 +1093,7 @@ static void __init hugetlb_hstate_alloc_
>  		if (h->order >= MAX_ORDER) {
>  			if (!alloc_bootmem_huge_page(h))
>  				break;
> -		} else if (!alloc_fresh_huge_page(h))
> +		} else if (!alloc_fresh_huge_page(h, NULL))
>  			break;
>  	}
>  	h->max_huge_pages = i;
> @@ -1158,7 +1168,8 @@ static inline void try_to_free_low(struc
>   * balanced by operating on them in a round-robin fashion.
>   * Returns 1 if an adjustment was made.
>   */
> -static int adjust_pool_surplus(struct hstate *h, int delta)
> +static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
> +				int delta)
>  {
>  	int start_nid, next_nid;
>  	int ret = 0;
> @@ -1174,7 +1185,7 @@ static int adjust_pool_surplus(struct hs
>  	do {
>  		int nid = next_nid;
>  		if (delta < 0)  {
> -			next_nid = hstate_next_node_to_alloc(h);
> +			next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
>  			/*
>  			 * To shrink on this node, there must be a surplus page
>  			 */
> @@ -1182,7 +1193,7 @@ static int adjust_pool_surplus(struct hs
>  				continue;
>  		}
>  		if (delta > 0) {
> -			next_nid = hstate_next_node_to_free(h);
> +			next_nid = hstate_next_node_to_free(h, nodes_allowed);
>  			/*
>  			 * Surplus cannot exceed the total number of pages
>  			 */
> @@ -1221,7 +1232,7 @@ static unsigned long set_max_huge_pages(
>  	 */
>  	spin_lock(&hugetlb_lock);
>  	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
> -		if (!adjust_pool_surplus(h, -1))
> +		if (!adjust_pool_surplus(h, NULL, -1))
>  			break;
>  	}
>  
> @@ -1232,7 +1243,7 @@ static unsigned long set_max_huge_pages(
>  		 * and reducing the surplus.
>  		 */
>  		spin_unlock(&hugetlb_lock);
> -		ret = alloc_fresh_huge_page(h);
> +		ret = alloc_fresh_huge_page(h, NULL);
>  		spin_lock(&hugetlb_lock);
>  		if (!ret)
>  			goto out;
> @@ -1258,11 +1269,11 @@ static unsigned long set_max_huge_pages(
>  	min_count = max(count, min_count);
>  	try_to_free_low(h, min_count);
>  	while (min_count < persistent_huge_pages(h)) {
> -		if (!free_pool_huge_page(h, 0))
> +		if (!free_pool_huge_page(h, NULL, 0))
>  			break;
>  	}
>  	while (count < persistent_huge_pages(h)) {
> -		if (!adjust_pool_surplus(h, 1))
> +		if (!adjust_pool_surplus(h, NULL, 1))
>  			break;
>  	}
>  out:
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
