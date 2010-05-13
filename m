Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 414DF6B01E3
	for <linux-mm@kvack.org>; Wed, 12 May 2010 23:29:13 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4D3TACs026525
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 13 May 2010 12:29:10 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C305645DE51
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:29:09 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9058F45DE4F
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:29:09 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 715F51DB803C
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:29:09 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D0641DB8038
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:29:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 4/5] vmscan: remove isolate_pages callback scan control
In-Reply-To: <20100430224316.121105897@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org> <20100430224316.121105897@cmpxchg.org>
Message-Id: <20100513122717.215E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 13 May 2010 12:29:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> For now, we have global isolation vs. memory control group isolation,
> do not allow the reclaim entry function to set an arbitrary page
> isolation callback, we do not need that flexibility.
> 
> And since we already pass around the group descriptor for the memory
> control group isolation case, just use it to decide which one of the
> two isolator functions to use.
> 
> The decisions can be merged into nearby branches, so no extra cost
> there.  In fact, we save the indirect calls.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h |   13 ++++++-----
>  mm/vmscan.c                |   52 ++++++++++++++++++++++++---------------------
>  2 files changed, 35 insertions(+), 30 deletions(-)
> 
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -82,12 +82,6 @@ struct scan_control {
>  	 * are scanned.
>  	 */
>  	nodemask_t	*nodemask;
> -
> -	/* Pluggable isolate pages callback */
> -	unsigned long (*isolate_pages)(unsigned long nr, struct list_head *dst,
> -			unsigned long *scanned, int order, int mode,
> -			struct zone *z, struct mem_cgroup *mem_cont,
> -			int active, int file);
>  };
>  
>  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> @@ -1000,7 +994,6 @@ static unsigned long isolate_pages_globa
>  					struct list_head *dst,
>  					unsigned long *scanned, int order,
>  					int mode, struct zone *z,
> -					struct mem_cgroup *mem_cont,
>  					int active, int file)
>  {
>  	int lru = LRU_BASE;
> @@ -1144,11 +1137,11 @@ static unsigned long shrink_inactive_lis
>  		unsigned long nr_anon;
>  		unsigned long nr_file;
>  
> -		nr_taken = sc->isolate_pages(SWAP_CLUSTER_MAX,
> -			     &page_list, &nr_scan, sc->order, mode,
> -				zone, sc->mem_cgroup, 0, file);
> -
>  		if (scanning_global_lru(sc)) {
> +			nr_taken = isolate_pages_global(SWAP_CLUSTER_MAX,
> +							&page_list, &nr_scan,
> +							sc->order, mode,
> +							zone, 0, file);
>  			zone->pages_scanned += nr_scan;
>  			if (current_is_kswapd())
>  				__count_zone_vm_events(PGSCAN_KSWAPD, zone,
> @@ -1156,6 +1149,16 @@ static unsigned long shrink_inactive_lis
>  			else
>  				__count_zone_vm_events(PGSCAN_DIRECT, zone,
>  						       nr_scan);
> +		} else {
> +			nr_taken = mem_cgroup_isolate_pages(SWAP_CLUSTER_MAX,
> +							&page_list, &nr_scan,
> +							sc->order, mode,
> +							zone, sc->mem_cgroup,
> +							0, file);
> +			/*
> +			 * mem_cgroup_isolate_pages() keeps track of
> +			 * scanned pages on its own.
> +			 */
>  		}

There are the same logic in shrink_active/inactive_list.
Can we make wrapper function? It probably improve code readability.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
