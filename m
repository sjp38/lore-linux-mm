Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A10DC6B004D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 05:09:43 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id n9699d7x011098
	for <linux-mm@kvack.org>; Tue, 6 Oct 2009 10:09:39 +0100
Received: from pxi3 (pxi3.prod.google.com [10.243.27.3])
	by wpaz33.hot.corp.google.com with ESMTP id n9698Zgg017324
	for <linux-mm@kvack.org>; Tue, 6 Oct 2009 02:09:36 -0700
Received: by pxi3 with SMTP id 3so3911472pxi.31
        for <linux-mm@kvack.org>; Tue, 06 Oct 2009 02:09:36 -0700 (PDT)
Date: Tue, 6 Oct 2009 02:09:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/11] hugetlb:  add nodemask arg to huge page alloc, free
 and surplus adjust fcns
In-Reply-To: <20091006031751.22576.23355.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0910060147120.24787@chino.kir.corp.google.com>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain> <20091006031751.22576.23355.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 5 Oct 2009, Lee Schermerhorn wrote:

> Index: linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/mm/hugetlb.c	2009-09-28 10:12:20.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c	2009-09-30 11:41:36.000000000 -0400
> @@ -622,48 +622,56 @@ static struct page *alloc_fresh_huge_pag
>  }
>  
>  /*
> - * common helper function for hstate_next_node_to_{alloc|free}.
> - * return next node in node_online_map, wrapping at end.
> + * common helper functions for hstate_next_node_to_{alloc|free}.
> + * We may have allocated or freed a huge page based on a different
> + * nodes_allowed previously, so h->next_node_to_{alloc|free} might
> + * be outside of *nodes_allowed.  Ensure that we use an allowed
> + * node for alloc or free.
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
> +static int get_valid_node_allowed(int nid, nodemask_t *nodes_allowed)
> +{
> +	if (!node_isset(nid, *nodes_allowed))
> +		nid = next_node_allowed(nid, nodes_allowed);
> +	return nid;
> +}
> +
>  /*
> - * Use a helper variable to find the next node and then
> - * copy it back to next_nid_to_alloc afterwards:
> - * otherwise there's a window in which a racer might
> - * pass invalid nid MAX_NUMNODES to alloc_pages_exact_node.
> - * But we don't need to use a spin_lock here: it really
> - * doesn't matter if occasionally a racer chooses the
> - * same nid as we do.  Move nid forward in the mask even
> - * if we just successfully allocated a hugepage so that
> - * the next caller gets hugepages on the next node.
> + * returns the previously saved node ["this node"] from which to
> + * allocate a persistent huge page for the pool and advance the
> + * next node from which to allocate, handling wrap at end of node
> + * mask.
>   */
> -static int hstate_next_node_to_alloc(struct hstate *h)
> +static int hstate_next_node_to_alloc(struct hstate *h,
> +					nodemask_t *nodes_allowed)
>  {
> -	int nid, next_nid;
> +	int nid;
> +
> +	VM_BUG_ON(!nodes_allowed);
> +
> +	nid = get_valid_node_allowed(h->next_nid_to_alloc, nodes_allowed);
> +	h->next_nid_to_alloc = next_node_allowed(nid, nodes_allowed);
>  
> -	nid = h->next_nid_to_alloc;
> -	next_nid = next_node_allowed(nid);
> -	h->next_nid_to_alloc = next_nid;
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
> @@ -672,7 +680,7 @@ static int alloc_fresh_huge_page(struct
>  			ret = 1;
>  			break;
>  		}
> -		next_nid = hstate_next_node_to_alloc(h);
> +		next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
>  	} while (next_nid != start_nid);
>  
>  	if (ret)
> @@ -684,18 +692,20 @@ static int alloc_fresh_huge_page(struct
>  }
>  
>  /*
> - * helper for free_pool_huge_page() - return the next node
> - * from which to free a huge page.  Advance the next node id
> - * whether or not we find a free huge page to free so that the
> - * next attempt to free addresses the next node.
> + * helper for free_pool_huge_page() - return the previously saved
> + * node ["this node"] from which to free a huge page.  Advance the
> + * next node id whether or not we find a free huge page to free so
> + * that the next attempt to free addresses the next node.
>   */
> -static int hstate_next_node_to_free(struct hstate *h)
> +static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>  {
> -	int nid, next_nid;
> +	int nid;
> +
> +	VM_BUG_ON(!nodes_allowed);
> +
> +	nid = get_valid_node_allowed(h->next_nid_to_free, nodes_allowed);
> +	h->next_nid_to_free = next_node_allowed(nid, nodes_allowed);
>  
> -	nid = h->next_nid_to_free;
> -	next_nid = next_node_allowed(nid);
> -	h->next_nid_to_free = next_nid;
>  	return nid;
>  }
>  
> @@ -705,13 +715,14 @@ static int hstate_next_node_to_free(stru
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
> @@ -735,7 +746,7 @@ static int free_pool_huge_page(struct hs
>  			ret = 1;
>  			break;
>  		}
> -		next_nid = hstate_next_node_to_free(h);
> +		next_nid = hstate_next_node_to_free(h, nodes_allowed);
>  	} while (next_nid != start_nid);
>  
>  	return ret;
> @@ -937,7 +948,7 @@ static void return_unused_surplus_pages(
>  	 * on-line nodes for us and will handle the hstate accounting.
>  	 */
>  	while (nr_pages--) {
> -		if (!free_pool_huge_page(h, 1))
> +		if (!free_pool_huge_page(h, &node_online_map, 1))
>  			break;
>  	}
>  }
> @@ -1047,7 +1058,7 @@ int __weak alloc_bootmem_huge_page(struc
>  		void *addr;
>  
>  		addr = __alloc_bootmem_node_nopanic(
> -				NODE_DATA(hstate_next_node_to_alloc(h)),
> +				NODE_DATA(hstate_next_node_to_alloc(h, NULL)),
>  				huge_page_size(h), huge_page_size(h), 0);
>  
>  		if (addr) {

This will trigger the VM_BUG_ON() in hstate_next_node_to_alloc() so it 
needs to be changed to &node_states[N_HIGH_MEMORY].  I'm wondering why it 
didn't show up in testing; CONFIG_DEBUG_VM isn't enabled by default so 
perhaps this hasn't had any hugepagez= coverage for hugepages of greater 
than MAX_ORDER?

 [ The VM_BUG_ON()'s in both hstate_next_node_to_alloc() and 
   hstate_next_node_to_free() are actually unnecessary since both will 
   quickly hit a node_isset() NULL pointer on the subsequent call to 
   get_valid_node_allowed() if it's true. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
