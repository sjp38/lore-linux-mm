Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 061C96B00A5
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 06:48:59 -0400 (EDT)
Date: Thu, 30 Jul 2009 11:49:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/4] hugetlb:  add nodemask arg to huge page alloc,
	free and surplus adjust fcns
Message-ID: <20090730104902.GB4831@csn.ul.ie>
References: <20090729175450.23681.75547.sendpatchset@localhost.localdomain> <20090729175505.23681.71659.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090729175505.23681.71659.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, Jul 29, 2009 at 01:55:05PM -0400, Lee Schermerhorn wrote:
> [PATCH 2/4] hugetlb:  add nodemask arg to huge page alloc, free and surplus adjust fcns
> 
> Against: 2.6.31-rc3-mmotm-090716-1432
> atop the alloc_bootmem_huge_page() fix patch
> [http://marc.info/?l=linux-mm&m=124775468226290&w=4]
> 
> V3:
> + moved this patch to after the "rework" of hstate_next_node_to_...
>   functions as this patch is more specific to using task mempolicy
>   to control huge page allocation and freeing.
> 
> In preparation for constraining huge page allocation and freeing by the
> controlling task's numa mempolicy, add a "nodes_allowed" nodemask pointer
> to the allocate, free and surplus adjustment functions.  For now, pass
> NULL to indicate default behavior--i.e., use node_online_map.  A
> subsqeuent patch will derive a non-default mask from the controlling 
> task's numa mempolicy.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

>  mm/hugetlb.c |  102 ++++++++++++++++++++++++++++++++++++++---------------------
>  1 file changed, 67 insertions(+), 35 deletions(-)
> 
> Index: linux-2.6.31-rc3-mmotm-090716-1432/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.31-rc3-mmotm-090716-1432.orig/mm/hugetlb.c	2009-07-28 11:14:58.000000000 -0400
> +++ linux-2.6.31-rc3-mmotm-090716-1432/mm/hugetlb.c	2009-07-28 11:23:18.000000000 -0400
> @@ -622,19 +622,29 @@ static struct page *alloc_fresh_huge_pag
>  }
>  
>  /*
> - * common helper function for hstate_next_node_to_{alloc|free}.
> - * return next node in node_online_map, wrapping at end.
> + * common helper functions for hstate_next_node_to_{alloc|free}.
> + * We may have allocated or freed a huge pages based on a different
> + * nodes_allowed, previously, so h->next_node_to_{alloc|free} might
> + * be outside of *nodes_allowed.  Ensure that we use the next
> + * allowed node for alloc or free.
>   */
> -static int next_node_allowed(int nid)
> +static int next_node_allowed(int nid, nodemask_t *nodes_allowed)
>  {
> -	nid = next_node(nid, node_online_map);
> +	nid = next_node(nid, *nodes_allowed);
>  	if (nid == MAX_NUMNODES)
> -		nid = first_node(node_online_map);
> +		nid = first_node(*nodes_allowed);
>  	VM_BUG_ON(nid >= MAX_NUMNODES);
>  
>  	return nid;
>  }
>  
> +static int this_node_allowed(int nid, nodemask_t *nodes_allowed)
> +{
> +	if (!node_isset(nid, *nodes_allowed))
> +		nid = next_node_allowed(nid, nodes_allowed);
> +	return nid;
> +}
> +
>  /*
>   * Use a helper variable to find the next node and then
>   * copy it back to next_nid_to_alloc afterwards:
> @@ -642,28 +652,34 @@ static int next_node_allowed(int nid)
>   * pass invalid nid MAX_NUMNODES to alloc_pages_exact_node.
>   * But we don't need to use a spin_lock here: it really
>   * doesn't matter if occasionally a racer chooses the
> - * same nid as we do.  Move nid forward in the mask even
> - * if we just successfully allocated a hugepage so that
> - * the next caller gets hugepages on the next node.
> + * same nid as we do.  Move nid forward in the mask whether
> + * or not we just successfully allocated a hugepage so that
> + * the next allocation addresses the next node.
>   */
> -static int hstate_next_node_to_alloc(struct hstate *h)
> +static int hstate_next_node_to_alloc(struct hstate *h,
> +					nodemask_t *nodes_allowed)
>  {
>  	int nid, next_nid;
>  
> -	nid = h->next_nid_to_alloc;
> -	next_nid = next_node_allowed(nid);
> +	if (!nodes_allowed)
> +		nodes_allowed = &node_online_map;
> +
> +	nid = this_node_allowed(h->next_nid_to_alloc, nodes_allowed);
> +
> +	next_nid = next_node_allowed(nid, nodes_allowed);
>  	h->next_nid_to_alloc = next_nid;
> +
>  	return nid;
>  }
>  
> -static int alloc_fresh_huge_page(struct hstate *h)
> +static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
>  {
>  	struct page *page;
>  	int start_nid;
>  	int next_nid;
>  	int ret = 0;
>  
> -	start_nid = hstate_next_node_to_alloc(h);
> +	start_nid = hstate_next_node_to_alloc(h, nodes_allowed);
>  	next_nid = start_nid;
>  
>  	do {
> @@ -672,7 +688,7 @@ static int alloc_fresh_huge_page(struct 
>  			ret = 1;
>  			break;
>  		}
> -		next_nid = hstate_next_node_to_alloc(h);
> +		next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
>  	} while (next_nid != start_nid);
>  
>  	if (ret)
> @@ -689,13 +705,18 @@ static int alloc_fresh_huge_page(struct 
>   * whether or not we find a free huge page to free so that the
>   * next attempt to free addresses the next node.
>   */
> -static int hstate_next_node_to_free(struct hstate *h)
> +static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>  {
>  	int nid, next_nid;
>  
> -	nid = h->next_nid_to_free;
> -	next_nid = next_node_allowed(nid);
> +	if (!nodes_allowed)
> +		nodes_allowed = &node_online_map;
> +
> +	nid = this_node_allowed(h->next_nid_to_free, nodes_allowed);
> +
> +	next_nid = next_node_allowed(nid, nodes_allowed);
>  	h->next_nid_to_free = next_nid;
> +
>  	return nid;
>  }
>  
> @@ -705,13 +726,14 @@ static int hstate_next_node_to_free(stru
>   * balanced over allowed nodes.
>   * Called with hugetlb_lock locked.
>   */
> -static int free_pool_huge_page(struct hstate *h, bool acct_surplus)
> +static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
> +							 bool acct_surplus)
>  {
>  	int start_nid;
>  	int next_nid;
>  	int ret = 0;
>  
> -	start_nid = hstate_next_node_to_free(h);
> +	start_nid = hstate_next_node_to_free(h, nodes_allowed);
>  	next_nid = start_nid;
>  
>  	do {
> @@ -735,7 +757,7 @@ static int free_pool_huge_page(struct hs
>  			ret = 1;
>  			break;
>  		}
> -		next_nid = hstate_next_node_to_free(h);
> +		next_nid = hstate_next_node_to_free(h, nodes_allowed);
>  	} while (next_nid != start_nid);
>  
>  	return ret;
> @@ -937,7 +959,7 @@ static void return_unused_surplus_pages(
>  	 * on-line nodes for us and will handle the hstate accounting.
>  	 */
>  	while (nr_pages--) {
> -		if (!free_pool_huge_page(h, 1))
> +		if (!free_pool_huge_page(h, NULL, 1))
>  			break;
>  	}
>  }
> @@ -1047,7 +1069,7 @@ int __weak alloc_bootmem_huge_page(struc
>  		void *addr;
>  
>  		addr = __alloc_bootmem_node_nopanic(
> -				NODE_DATA(hstate_next_node_to_alloc(h)),
> +				NODE_DATA(hstate_next_node_to_alloc(h, NULL)),
>  				huge_page_size(h), huge_page_size(h), 0);
>  
>  		if (addr) {
> @@ -1102,7 +1124,7 @@ static void __init hugetlb_hstate_alloc_
>  		if (h->order >= MAX_ORDER) {
>  			if (!alloc_bootmem_huge_page(h))
>  				break;
> -		} else if (!alloc_fresh_huge_page(h))
> +		} else if (!alloc_fresh_huge_page(h, NULL))
>  			break;
>  	}
>  	h->max_huge_pages = i;
> @@ -1144,16 +1166,22 @@ static void __init report_hugepages(void
>  }
>  
>  #ifdef CONFIG_HIGHMEM
> -static void try_to_free_low(struct hstate *h, unsigned long count)
> +static void try_to_free_low(struct hstate *h, unsigned long count,
> +						nodemask_t *nodes_allowed)
>  {
>  	int i;
>  
>  	if (h->order >= MAX_ORDER)
>  		return;
>  
> +	if (!nodes_allowed)
> +		nodes_allowed = &node_online_map;
> +
>  	for (i = 0; i < MAX_NUMNODES; ++i) {
>  		struct page *page, *next;
>  		struct list_head *freel = &h->hugepage_freelists[i];
> +		if (!node_isset(i, *nodes_allowed))
> +			continue;
>  		list_for_each_entry_safe(page, next, freel, lru) {
>  			if (count >= h->nr_huge_pages)
>  				return;
> @@ -1167,7 +1195,8 @@ static void try_to_free_low(struct hstat
>  	}
>  }
>  #else
> -static inline void try_to_free_low(struct hstate *h, unsigned long count)
> +static inline void try_to_free_low(struct hstate *h, unsigned long count,
> +						nodemask_t *nodes_allowed)
>  {
>  }
>  #endif
> @@ -1177,7 +1206,8 @@ static inline void try_to_free_low(struc
>   * balanced by operating on them in a round-robin fashion.
>   * Returns 1 if an adjustment was made.
>   */
> -static int adjust_pool_surplus(struct hstate *h, int delta)
> +static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
> +				int delta)
>  {
>  	int start_nid, next_nid;
>  	int ret = 0;
> @@ -1185,9 +1215,9 @@ static int adjust_pool_surplus(struct hs
>  	VM_BUG_ON(delta != -1 && delta != 1);
>  
>  	if (delta < 0)
> -		start_nid = hstate_next_node_to_alloc(h);
> +		start_nid = hstate_next_node_to_alloc(h, nodes_allowed);
>  	else
> -		start_nid = hstate_next_node_to_free(h);
> +		start_nid = hstate_next_node_to_free(h, nodes_allowed);
>  	next_nid = start_nid;
>  
>  	do {
> @@ -1197,7 +1227,8 @@ static int adjust_pool_surplus(struct hs
>  			 * To shrink on this node, there must be a surplus page
>  			 */
>  			if (!h->surplus_huge_pages_node[nid]) {
> -				next_nid = hstate_next_node_to_alloc(h);
> +				next_nid = hstate_next_node_to_alloc(h,
> +								nodes_allowed);
>  				continue;
>  			}
>  		}
> @@ -1207,7 +1238,8 @@ static int adjust_pool_surplus(struct hs
>  			 */
>  			if (h->surplus_huge_pages_node[nid] >=
>  						h->nr_huge_pages_node[nid]) {
> -				next_nid = hstate_next_node_to_free(h);
> +				next_nid = hstate_next_node_to_free(h,
> +								nodes_allowed);
>  				continue;
>  			}
>  		}
> @@ -1242,7 +1274,7 @@ static unsigned long set_max_huge_pages(
>  	 */
>  	spin_lock(&hugetlb_lock);
>  	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
> -		if (!adjust_pool_surplus(h, -1))
> +		if (!adjust_pool_surplus(h, NULL, -1))
>  			break;
>  	}
>  
> @@ -1253,7 +1285,7 @@ static unsigned long set_max_huge_pages(
>  		 * and reducing the surplus.
>  		 */
>  		spin_unlock(&hugetlb_lock);
> -		ret = alloc_fresh_huge_page(h);
> +		ret = alloc_fresh_huge_page(h, NULL);
>  		spin_lock(&hugetlb_lock);
>  		if (!ret)
>  			goto out;
> @@ -1277,13 +1309,13 @@ static unsigned long set_max_huge_pages(
>  	 */
>  	min_count = h->resv_huge_pages + h->nr_huge_pages - h->free_huge_pages;
>  	min_count = max(count, min_count);
> -	try_to_free_low(h, min_count);
> +	try_to_free_low(h, min_count, NULL);
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
