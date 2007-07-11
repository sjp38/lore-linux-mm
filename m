Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6BGHlal021185
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 12:17:47 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6BGHla4543724
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 12:17:47 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6BGHkIZ005954
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 12:17:46 -0400
Date: Wed, 11 Jul 2007 09:17:42 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 02/12] NUMA: Introduce node_memory_map
Message-ID: <20070711161742.GO27655@us.ibm.com>
References: <20070710215339.110895755@sgi.com> <20070710215454.355598739@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070710215454.355598739@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, kxr@sgi.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10.07.2007 [14:52:07 -0700], Christoph Lameter wrote:
> It is necessary to know if nodes have memory since we have recently
> begun to add support for memoryless nodes. For that purpose we introduce
> a new node state N_MEMORY.
> 
> A node has its bit in node_memory_map set if it has memory. If a node
> has memory then it has at least one zone defined in its pgdat structure
> that is located in the pgdat itself.

Uh, except node_memory_map is not defined below.

I'm guessing you just need

#define	node_memory_map	node_states[N_MEMORY]

below.

Thanks,
Nish

> N_MEMORY can then be used in various places to insure that we
> do the right thing when we encounter a memoryless node.
> 
> Signed-off-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  include/linux/nodemask.h |    1 +
>  mm/page_alloc.c          |    9 +++++++--
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.22-rc6-mm1/include/linux/nodemask.h
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/include/linux/nodemask.h	2007-07-09 22:13:44.000000000 -0700
> +++ linux-2.6.22-rc6-mm1/include/linux/nodemask.h	2007-07-09 22:16:05.000000000 -0700
> @@ -343,6 +343,7 @@ static inline void __nodes_remap(nodemas
>  enum node_states {
>  	N_POSSIBLE,	/* The node could become online at some point */
>  	N_ONLINE,	/* The node is online */
> +	N_MEMORY,	/* The node has memory */
>  	NR_NODE_STATES
>  };
> 
> Index: linux-2.6.22-rc6-mm1/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/mm/page_alloc.c	2007-07-09 22:15:45.000000000 -0700
> +++ linux-2.6.22-rc6-mm1/mm/page_alloc.c	2007-07-09 22:19:28.000000000 -0700
> @@ -2392,8 +2392,13 @@ static int __build_all_zonelists(void *d
>  	int nid;
> 
>  	for_each_online_node(nid) {
> -		build_zonelists(NODE_DATA(nid));
> -		build_zonelist_cache(NODE_DATA(nid));
> +		pg_data_t *pgdat = NODE_DATA(nid);
> +
> +		build_zonelists(pgdat);
> +		build_zonelist_cache(pgdat);
> +
> +		if (pgdat->node_present_pages)
> +			node_set_state(nid, N_MEMORY);
>  	}
>  	return 0;
>  }
> 
> -- 

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
