Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBB5Eh2w006934
	for <linux-mm@kvack.org>; Tue, 11 Dec 2007 00:14:43 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBB5Eh3Q092212
	for <linux-mm@kvack.org>; Mon, 10 Dec 2007 22:14:43 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBB5Eh9u006764
	for <linux-mm@kvack.org>; Mon, 10 Dec 2007 22:14:43 -0700
Message-ID: <475E1CBC.4070408@linux.vnet.ibm.com>
Date: Tue, 11 Dec 2007 10:44:36 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][for -mm] fix accounting in vmscan.c for memory controller
References: <20071211112644.221a8dc5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071211112644.221a8dc5.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Without this, ALLOCSTALL and PGSCAN_DIRECT increases too much unless
> there is no memory shortage.
> 
> against 2.6.24-rc4-mm1.
> 
> -Kame
> 
> ==
> Some amount of accounting is done while page reclaiming.
> 
> Now, there are 2 types of page reclaim (if memory controller is used)
>   - global: shortage of (global) pages.
>   - under cgroup: use up to limit.
> 
> I think 2 accountings, ALLOCSTALL and DIRECT should be accounted only under
> global lru scan. They are accounted against memory shortage at alloc_pages().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  mm/vmscan.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.24-rc4-mm1/mm/vmscan.c
> ===================================================================
> --- linux-2.6.24-rc4-mm1.orig/mm/vmscan.c
> +++ linux-2.6.24-rc4-mm1/mm/vmscan.c
> @@ -896,8 +896,9 @@ static unsigned long shrink_inactive_lis
>  		if (current_is_kswapd()) {
>  			__count_zone_vm_events(PGSCAN_KSWAPD, zone, nr_scan);
>  			__count_vm_events(KSWAPD_STEAL, nr_freed);
> -		} else
> +		} else if (scan_global_lru(sc))
>  			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scan);
> +
>  		__count_zone_vm_events(PGSTEAL, zone, nr_freed);
> 
>  		if (nr_taken == 0)
> @@ -1333,7 +1334,8 @@ static unsigned long do_try_to_free_page
>  	unsigned long lru_pages = 0;
>  	int i;
> 
> -	count_vm_event(ALLOCSTALL);
> +	if (scan_global_lru(sc))
> +		count_vm_event(ALLOCSTALL);
>  	/*
>  	 * mem_cgroup will not do shrink_slab.
>  	 */
> 

Looks good to me.

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

TODO:

1. Should we have vm_events for the memory controller as well?
   May be in the longer term

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
