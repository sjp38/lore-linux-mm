Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EA88C6B00A0
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:05:24 -0400 (EDT)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id n7PK5NFS004589
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 13:05:23 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by spaceape8.eur.corp.google.com with ESMTP id n7P8GSwP019964
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 01:18:22 -0700
Received: by pzk36 with SMTP id 36so1455272pzk.12
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 01:16:27 -0700 (PDT)
Date: Tue, 25 Aug 2009 01:16:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] hugetlb:  add nodemask arg to huge page alloc, free
 and surplus adjust fcns
In-Reply-To: <20090824192637.10317.31039.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.0908250112510.23660@chino.kir.corp.google.com>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain> <20090824192637.10317.31039.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 24 Aug 2009, Lee Schermerhorn wrote:

> [PATCH 2/4] hugetlb:  add nodemask arg to huge page alloc, free and surplus adjust fcns
> 
> Against: 2.6.31-rc6-mmotm-090820-1918
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
> Reviewed-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  mm/hugetlb.c |  102 ++++++++++++++++++++++++++++++++++++++---------------------
>  1 file changed, 67 insertions(+), 35 deletions(-)
> 
> Index: linux-2.6.31-rc6-mmotm-090820-1918/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.31-rc6-mmotm-090820-1918.orig/mm/hugetlb.c	2009-08-24 12:12:46.000000000 -0400
> +++ linux-2.6.31-rc6-mmotm-090820-1918/mm/hugetlb.c	2009-08-24 12:12:50.000000000 -0400
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

Awkward name considering this doesn't simply return true or false as 
expected, it returns a nid.

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

Don't need next_nid.

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

Same.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
