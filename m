Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 515666B005A
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 14:08:34 -0400 (EDT)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id n8MI8WkX011630
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 11:08:33 -0700
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by spaceape10.eur.corp.google.com with ESMTP id n8MI86sZ014445
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 11:08:29 -0700
Received: by pzk27 with SMTP id 27so301143pzk.12
        for <linux-mm@kvack.org>; Tue, 22 Sep 2009 11:08:29 -0700 (PDT)
Date: Tue, 22 Sep 2009 11:08:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/11] hugetlb:  rework hstate_next_node_* functions
In-Reply-To: <20090915204333.4828.47722.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0909221100000.10595@chino.kir.corp.google.com>
References: <20090915204327.4828.4349.sendpatchset@localhost.localdomain> <20090915204333.4828.47722.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 15 Sep 2009, Lee Schermerhorn wrote:

> Index: linux-2.6.31-mmotm-090914-0157/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.31-mmotm-090914-0157.orig/mm/hugetlb.c	2009-09-15 13:23:01.000000000 -0400
> +++ linux-2.6.31-mmotm-090914-0157/mm/hugetlb.c	2009-09-15 13:42:14.000000000 -0400
> @@ -622,6 +622,20 @@ static struct page *alloc_fresh_huge_pag
>  }
>  
>  /*
> + * common helper function for hstate_next_node_to_{alloc|free}.
> + * return next node in node_online_map, wrapping at end.
> + */
> +static int next_node_allowed(int nid)
> +{
> +	nid = next_node(nid, node_online_map);
> +	if (nid == MAX_NUMNODES)
> +		nid = first_node(node_online_map);
> +	VM_BUG_ON(nid >= MAX_NUMNODES);
> +
> +	return nid;
> +}
> +
> +/*
>   * Use a helper variable to find the next node and then
>   * copy it back to next_nid_to_alloc afterwards:
>   * otherwise there's a window in which a racer might
> @@ -634,12 +648,12 @@ static struct page *alloc_fresh_huge_pag
>   */
>  static int hstate_next_node_to_alloc(struct hstate *h)
>  {
> -	int next_nid;
> -	next_nid = next_node(h->next_nid_to_alloc, node_online_map);
> -	if (next_nid == MAX_NUMNODES)
> -		next_nid = first_node(node_online_map);
> +	int nid, next_nid;
> +
> +	nid = h->next_nid_to_alloc;
> +	next_nid = next_node_allowed(nid);
>  	h->next_nid_to_alloc = next_nid;
> -	return next_nid;
> +	return nid;
>  }
>  
>  static int alloc_fresh_huge_page(struct hstate *h)

I thought you had refactored this to drop next_nid entirely since gcc 
optimizes it away?

> @@ -649,15 +663,17 @@ static int alloc_fresh_huge_page(struct
>  	int next_nid;
>  	int ret = 0;
>  
> -	start_nid = h->next_nid_to_alloc;
> +	start_nid = hstate_next_node_to_alloc(h);
>  	next_nid = start_nid;
>  
>  	do {
>  		page = alloc_fresh_huge_page_node(h, next_nid);
> -		if (page)
> +		if (page) {
>  			ret = 1;
> +			break;
> +		}
>  		next_nid = hstate_next_node_to_alloc(h);
> -	} while (!page && next_nid != start_nid);
> +	} while (next_nid != start_nid);
>  
>  	if (ret)
>  		count_vm_event(HTLB_BUDDY_PGALLOC);
> @@ -668,17 +684,19 @@ static int alloc_fresh_huge_page(struct
>  }
>  
>  /*
> - * helper for free_pool_huge_page() - find next node
> - * from which to free a huge page
> + * helper for free_pool_huge_page() - return the next node
> + * from which to free a huge page.  Advance the next node id
> + * whether or not we find a free huge page to free so that the
> + * next attempt to free addresses the next node.
>   */
>  static int hstate_next_node_to_free(struct hstate *h)
>  {
> -	int next_nid;
> -	next_nid = next_node(h->next_nid_to_free, node_online_map);
> -	if (next_nid == MAX_NUMNODES)
> -		next_nid = first_node(node_online_map);
> +	int nid, next_nid;
> +
> +	nid = h->next_nid_to_free;
> +	next_nid = next_node_allowed(nid);
>  	h->next_nid_to_free = next_nid;
> -	return next_nid;
> +	return nid;
>  }
>  
>  /*

Ditto for next_nid.

> @@ -693,7 +711,7 @@ static int free_pool_huge_page(struct hs
>  	int next_nid;
>  	int ret = 0;
>  
> -	start_nid = h->next_nid_to_free;
> +	start_nid = hstate_next_node_to_free(h);
>  	next_nid = start_nid;
>  
>  	do {
> @@ -715,9 +733,10 @@ static int free_pool_huge_page(struct hs
>  			}
>  			update_and_free_page(h, page);
>  			ret = 1;
> +			break;
>  		}
>  		next_nid = hstate_next_node_to_free(h);
> -	} while (!ret && next_nid != start_nid);
> +	} while (next_nid != start_nid);
>  
>  	return ret;
>  }
> @@ -1028,10 +1047,9 @@ int __weak alloc_bootmem_huge_page(struc
>  		void *addr;
>  
>  		addr = __alloc_bootmem_node_nopanic(
> -				NODE_DATA(h->next_nid_to_alloc),
> +				NODE_DATA(hstate_next_node_to_alloc(h)),
>  				huge_page_size(h), huge_page_size(h), 0);
>  
> -		hstate_next_node_to_alloc(h);
>  		if (addr) {
>  			/*
>  			 * Use the beginning of the huge page to store the

Shouldn't that panic if hstate_next_node_to_alloc() returns a memoryless 
node since it uses node_online_map?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
