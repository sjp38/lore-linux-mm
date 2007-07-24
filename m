Message-ID: <46A621B3.6060902@shadowen.org>
Date: Tue, 24 Jul 2007 16:58:43 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Do not trigger OOM-killer for high-order allocation failures
References: <20070724153531.GA30585@skynet.ie>
In-Reply-To: <20070724153531.GA30585@skynet.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> out_of_memory() may be called when an allocation is failing and the direct
> reclaim is not making any progress. This does not take into account the
> requested order of the allocation. If the request if for an order larger
> than PAGE_ALLOC_COSTLY_ORDER, it is reasonable to fail the allocation
> because the kernel makes no guarantees about those allocations succeeding.
> 
> This false OOM situation can occur if a user is trying to grow the hugepage
> pool in a script like;
> 
> #!/bin/bash
> REQUIRED=$1
> echo 1 > /proc/sys/vm/hugepages_treat_as_movable
> echo $REQUIRED > /proc/sys/vm/nr_hugepages
> ACTUAL=`cat /proc/sys/vm/nr_hugepages`
> while [ $REQUIRED -ne $ACTUAL ]; do
> 	echo Huge page pool at $ACTUAL growing to $REQUIRED
> 	echo $REQUIRED > /proc/sys/vm/nr_hugepages
> 	ACTUAL=`cat /proc/sys/vm/nr_hugepages`
> 	sleep 1
> done
> 
> This is a reasonable scenario when ZONE_MOVABLE is in use but triggers OOM
> easily on 2.6.23-rc1. This patch will fail an allocation for an order above
> PAGE_ALLOC_COSTLY_ORDER instead of killing processes and retrying.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

We have had this problem for a long time.  When allocating large pages
we could find ourselves unable to allocate such a page nor reclaim one
for ourselves.  At this point we will OOM with little hope of that
actually changing the situation for the better.

As you say PAGE_ALLOC_COSTLY_ORDER pretty much defines the orders at
which any sort of guarantee of success is provided.  It seems preferable
to fail a allocations above this order/ than killing things to try and
make it available.  As higher order users already have to handle failure
to allocate they should be best equipped to continue.

Acked-by: Andy Whitcroft <apw@shadowen.org>

> ---
>  page_alloc.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 40954fb..da57173 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1350,6 +1350,10 @@ nofail_alloc:
>  		if (page)
>  			goto got_pg;
>  
> +		/* The OOM killer will not help higher order allocs so fail */
> +		if (order > PAGE_ALLOC_COSTLY_ORDER)
> +			goto nopage;
> +
>  		out_of_memory(zonelist, gfp_mask, order);
>  		goto restart;
>  	}

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
