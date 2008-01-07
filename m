Date: Mon, 7 Jan 2008 11:32:23 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 05 of 11] reduce the probability of an OOM livelock
In-Reply-To: <fc9148f0ddd0ef11be29.1199326151@v2.random>
Message-ID: <Pine.LNX.4.64.0801071130090.23617@schroedinger.engr.sgi.com>
References: <fc9148f0ddd0ef11be29.1199326151@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@cpushare.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jan 2008, Andrea Arcangeli wrote:

> @@ -1337,7 +1337,6 @@ static unsigned long balance_pgdat(pg_da
>  
>  loop_again:
>  	total_scanned = 0;
> -	nr_reclaimed = 0;
>  	sc.may_writepage = !laptop_mode;
>  	count_vm_event(PAGEOUTRUN);
>  
> @@ -1347,6 +1346,7 @@ loop_again:
>  	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
>  		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
>  		unsigned long lru_pages = 0;
> +		unsigned long nr_reclaimed;
>  
>  		/* The swap token gets in the way of swapout... */
>  		if (!priority)
> @@ -1393,6 +1393,7 @@ loop_again:
>  		 * pages behind kswapd's direction of progress, which would
>  		 * cause too much scanning of the lower zones.
>  		 */
> +		nr_reclaimed = 0;
>  		for (i = 0; i <= end_zone; i++) {
>  			struct zone *zone = pgdat->node_zones + i;
>  			int nr_slab;

nr_reclaimed is now only the number reclaimed at a certain priority. Its 
effectively lower. It seems that the only test that can be affected by 
this is:

  if (nr_reclaimed >= SWAP_CLUSTER_MAX)
                        break;

But reducing nr_reclaim makes it more likely to continue the 
loop? I thought you wanted to stop scanning?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
