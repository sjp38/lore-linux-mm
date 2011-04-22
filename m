Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C86D8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 20:36:20 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DAF9D3EE0B5
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 09:36:16 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BB7E545DE95
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 09:36:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A538945DE78
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 09:36:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 96176E18003
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 09:36:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 594B3E08005
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 09:36:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: always set nodes with regular memory in N_NORMAL_MEMORY
In-Reply-To: <alpine.DEB.2.00.1104211440240.20201@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104211411540.20201@chino.kir.corp.google.com> <alpine.DEB.2.00.1104211440240.20201@chino.kir.corp.google.com>
Message-Id: <20110422093619.FA5A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 22 Apr 2011 09:36:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> N_NORMAL_MEMORY is intended to include all nodes that have present memory 
> in regular zones, that is, zones below ZONE_HIGHMEM.  This should be done 
> regardless of whether CONFIG_HIGHMEM is set or not.
> 
> This fixes ia64 so that the nodes get set appropriately in the nodemask 
> for DISCONTIGMEM and mips if it does not enable CONFIG_HIGHMEM even for 
> 32-bit kernels.
> 
> If N_NORMAL_MEMORY is not accurate, slub may encounter errors since it 
> relies on this nodemask to setup kmem_cache_node data structures for each 
> cache.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/page_alloc.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4727,7 +4727,6 @@ out:
>  /* Any regular memory on that node ? */
>  static void check_for_regular_memory(pg_data_t *pgdat)
>  {
> -#ifdef CONFIG_HIGHMEM
>  	enum zone_type zone_type;
>  
>  	for (zone_type = 0; zone_type <= ZONE_NORMAL; zone_type++) {
> @@ -4735,7 +4734,6 @@ static void check_for_regular_memory(pg_data_t *pgdat)
>  		if (zone->present_pages)
>  			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
>  	}
> -#endif

enum node_states {
        N_POSSIBLE,             /* The node could become online at some point */
        N_ONLINE,               /* The node is online */
        N_NORMAL_MEMORY,        /* The node has regular memory */
#ifdef CONFIG_HIGHMEM
        N_HIGH_MEMORY,          /* The node has regular or high memory */
#else
        N_HIGH_MEMORY = N_NORMAL_MEMORY,
#endif
        N_CPU,          /* The node has one or more cpus */
        NR_NODE_STATES
};

Then, only node_set_state(nid, N_HIGH_MEMORY) is enough initialization, IIUC.
Can you please explain when do we need this patch?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
