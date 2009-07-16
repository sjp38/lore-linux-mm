Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AF37A6B008A
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:51:17 -0400 (EDT)
Date: Thu, 16 Jul 2009 15:51:21 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] hugetlb:  restore interleaving of bootmem huge pages
Message-ID: <20090716145121.GD22499@csn.ul.ie>
References: <1247754662.4382.51.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1247754662.4382.51.camel@useless.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, linux-numa <linux-numa@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 16, 2009 at 10:31:02AM -0400, Lee Schermerhorn wrote:
> PATCH restore interleaving of bootmem huge pages
> 
> Against: 2.6.31-rc1-mmotm-090625-1549
> atop the "hugetlb-balance-freeing-of-huge-pages-across-node" series
> 
> I noticed that alloc_bootmem_huge_page() will only advance to the
> next node on failure to allocate a huge page, potentially filling 
> nodes with huge-pages.  I asked about this on linux-mm and linux-numa,
> cc'ing the usual huge page suspects.
> 
> Mel Gorman responded:
> 
> 	I strongly suspect that the same node being used until allocation
> 	failure instead of round-robin is an oversight and not deliberate
> 	at all. It appears to be a side-effect of a fix made way back in
> 	commit 63b4613c3f0d4b724ba259dc6c201bb68b884e1a ["hugetlb: fix
> 	hugepage allocation with memoryless nodes"]. Prior to that patch
> 	it looked like allocations would always round-robin even when
> 	allocation was successful.
> 
> This patch--factored out of my "hugetlb mempolicy" series--moves the
> advance of the hstate next node from which to allocate up before the
> test for success of the attempted allocation.
> 
> Note that alloc_bootmem_huge_page() is only used for order > MAX_ORDER
> huge pages.
> 
> I'll post a separate patch for mainline/stable, as the above mentioned
> "balance freeing" series renamed the next node to alloc function.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

> 
>  mm/hugetlb.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.31-rc1-mmotm-090625-1549.orig/mm/hugetlb.c	2009-07-13 09:05:22.000000000 -0400
> +++ linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c	2009-07-13 09:06:22.000000000 -0400
> @@ -1030,6 +1030,7 @@ int __weak alloc_bootmem_huge_page(struc
>  				NODE_DATA(h->next_nid_to_alloc),
>  				huge_page_size(h), huge_page_size(h), 0);
>  
> +		hstate_next_node_to_alloc(h);
>  		if (addr) {
>  			/*
>  			 * Use the beginning of the huge page to store the
> @@ -1039,7 +1040,6 @@ int __weak alloc_bootmem_huge_page(struc
>  			m = addr;
>  			goto found;
>  		}
> -		hstate_next_node_to_alloc(h);
>  		nr_nodes--;
>  	}
>  	return 0;
> 
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
