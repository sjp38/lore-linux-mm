Date: Fri, 10 Mar 2006 16:05:27 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: drain_node_pages: interrupt latency reduction / optimization
Message-Id: <20060310160527.5ddfc610.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603101258290.29954@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603101258290.29954@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> 1. Only disable interrupts if there is actually something to free
> 
> 2. Only dirty the pcp cacheline if we actually freed something.
> 
> 3. Disable interrupts for each single pcp and not for cleaning
>   all the pcps in all zones of a node.
> 
> drain_node_pages is called every 2 seconds from cache_reap. This
> fix should avoid most disabling of interrupts.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c	2006-03-10 10:34:56.000000000 -0800
> +++ linux-2.6/mm/page_alloc.c	2006-03-10 12:55:02.000000000 -0800
> @@ -599,7 +599,6 @@ void drain_node_pages(int nodeid)
>  	int i, z;
>  	unsigned long flags;
>  
> -	local_irq_save(flags);
>  	for (z = 0; z < MAX_NR_ZONES; z++) {
>  		struct zone *zone = NODE_DATA(nodeid)->node_zones + z;
>  		struct per_cpu_pageset *pset;
> @@ -609,11 +608,14 @@ void drain_node_pages(int nodeid)
>  			struct per_cpu_pages *pcp;
>  
>  			pcp = &pset->pcp[i];
> -			free_pages_bulk(zone, pcp->count, &pcp->list, 0);
> -			pcp->count = 0;
> +			if (pcp->count) {
> +				local_irq_save(flags);
> +				free_pages_bulk(zone, pcp->count, &pcp->list, 0);
> +				pcp->count = 0;
> +				local_irq_restore(flags);
> +			}
>  		}
>  	}

This can cause us to run smp_processor_id() with preempt_count==0 and local
irqs enabled.  This will a) cause nasty runtime warnings and b) possibly go
bad if preemption causes this thread to hop CPUs.

But we've had that problem for a little while, because next_reap_node() is
calling __get_cpu_var() from preemptible code too.

But I _think_ we're OK for now because these functions are only ever called
from pinned-to-cpu kernel threads.

Please test all this with CONFIG_PREEMPT_DEBUG, confirm that it's OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
