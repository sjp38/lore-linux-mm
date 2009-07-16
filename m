Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 45A916B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:32:18 -0400 (EDT)
Date: Thu, 16 Jul 2009 18:31:58 +0100
From: Andy Whitcroft <apw@canonical.com>
Subject: Re: [PATCH] hugetlb:  restore interleaving of bootmem huge pages
Message-ID: <20090716173158.GB9507@shadowen.org>
References: <1247754662.4382.51.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1247754662.4382.51.camel@useless.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Eric Whitney <eric.whitney@hp.com>, linux-numa <linux-numa@vger.kernel.org>
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

It looks like this behaviour was in the original implementation to my eye.
It does indeed seem to prefer taking all it can from one node before moving
on to the next.  Your change seems reasonable to my eye though it may be
worth asking Andi if it was intended.  The intent of this change seems
to bring the behaviour into line with that of alloc_fresh_huge_page()
used for orders less than MAX_ORDER.

Reviewed-by: Andy Whitcroft <apw@canonical.com>

-apw

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
