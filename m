Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 395A46B004D
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 16:20:04 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id n98KJun5009264
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 13:19:56 -0700
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by wpaz21.hot.corp.google.com with ESMTP id n98KIt0M021130
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 13:19:54 -0700
Received: by pxi12 with SMTP id 12so6095241pxi.9
        for <linux-mm@kvack.org>; Thu, 08 Oct 2009 13:19:53 -0700 (PDT)
Date: Thu, 8 Oct 2009 13:19:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 10/12] mm: clear node in N_HIGH_MEMORY and stop kswapd
 when all memory is offlined
In-Reply-To: <20091008162643.23192.65918.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0910081318250.6998@chino.kir.corp.google.com>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain> <20091008162643.23192.65918.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Christoph Lameter <cl@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Oct 2009, Lee Schermerhorn wrote:

> From rientjes@google.com Wed Oct  7 02:25:10 2009
> 

From: David Rientjes <rientjes@google.com>

> [PATCH 10/12] mm: clear node in N_HIGH_MEMORY and stop kswapd when all memory is offlined
> 
> mm: clear node in N_HIGH_MEMORY and stop kswapd when all memory is offlined
> 
> When memory is hot-removed, its node must be cleared in N_HIGH_MEMORY if
> there are no present pages left.
> 
> In such a situation, kswapd must also be stopped since it has nothing
> left to do.
> 
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Rafael J. Wysocki <rjw@sisk.pl>
> Cc: Rik van Riel <riel@redhat.com>

Thanks for adding these, but four of five never got cc'd on the patch :)  
I've added them.

> Signed-off-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
> ---
> 
>  include/linux/swap.h |    1 +
>  mm/memory_hotplug.c  |    4 ++++
>  mm/vmscan.c          |   28 ++++++++++++++++++++++------
>  3 files changed, 27 insertions(+), 6 deletions(-)
> 
> Index: linux-2.6.31-mmotm-090925-1435/include/linux/swap.h
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/include/linux/swap.h	2009-09-28 10:10:39.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/include/linux/swap.h	2009-10-07 16:24:43.000000000 -0400
> @@ -273,6 +273,7 @@ extern int scan_unevictable_register_nod
>  extern void scan_unevictable_unregister_node(struct node *node);
>  
>  extern int kswapd_run(int nid);
> +extern void kswapd_stop(int nid);
>  
>  #ifdef CONFIG_MMU
>  /* linux/mm/shmem.c */
> Index: linux-2.6.31-mmotm-090925-1435/mm/memory_hotplug.c
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/mm/memory_hotplug.c	2009-09-28 10:10:39.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/mm/memory_hotplug.c	2009-10-07 16:24:43.000000000 -0400
> @@ -838,6 +838,10 @@ repeat:
>  
>  	setup_per_zone_wmarks();
>  	calculate_zone_inactive_ratio(zone);
> +	if (!node_present_pages(node)) {
> +		node_clear_state(node, N_HIGH_MEMORY);
> +		kswapd_stop(node);
> +	}
>  
>  	vm_total_pages = nr_free_pagecache_pages();
>  	writeback_set_ratelimit();
> Index: linux-2.6.31-mmotm-090925-1435/mm/vmscan.c
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/mm/vmscan.c	2009-09-28 10:10:43.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/mm/vmscan.c	2009-10-07 16:24:43.000000000 -0400
> @@ -2167,6 +2167,7 @@ static int kswapd(void *p)
>  	order = 0;
>  	for ( ; ; ) {
>  		unsigned long new_order;
> +		int ret;
>  
>  		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>  		new_order = pgdat->kswapd_max_order;
> @@ -2178,19 +2179,23 @@ static int kswapd(void *p)
>  			 */
>  			order = new_order;
>  		} else {
> -			if (!freezing(current))
> +			if (!freezing(current) && !kthread_should_stop())
>  				schedule();
>  
>  			order = pgdat->kswapd_max_order;
>  		}
>  		finish_wait(&pgdat->kswapd_wait, &wait);
>  
> -		if (!try_to_freeze()) {
> -			/* We can speed up thawing tasks if we don't call
> -			 * balance_pgdat after returning from the refrigerator
> -			 */
> +		ret = try_to_freeze();
> +		if (kthread_should_stop())
> +			break;
> +
> +		/*
> +		 * We can speed up thawing tasks if we don't call balance_pgdat
> +		 * after returning from the refrigerator
> +		 */
> +		if (!ret)
>  			balance_pgdat(pgdat, order);
> -		}
>  	}
>  	return 0;
>  }
> @@ -2445,6 +2450,17 @@ int kswapd_run(int nid)
>  	return ret;
>  }
>  
> +/*
> + * Called by memory hotplug when all memory in a node is offlined.
> + */
> +void kswapd_stop(int nid)
> +{
> +	struct task_struct *kswapd = NODE_DATA(nid)->kswapd;
> +
> +	if (kswapd)
> +		kthread_stop(kswapd);
> +}
> +
>  static int __init kswapd_init(void)
>  {
>  	int nid;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
