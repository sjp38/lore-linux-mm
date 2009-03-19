Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D85316B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 18:06:45 -0400 (EDT)
Date: Thu, 19 Mar 2009 22:06:41 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 20/35] Use a pre-calculated value for num_online_nodes()
Message-ID: <20090319220641.GC24586@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-21-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161207500.32577@qirst.com> <20090316163626.GJ24293@csn.ul.ie> <alpine.DEB.1.10.0903161247170.17730@qirst.com> <20090318150833.GC4629@csn.ul.ie> <alpine.DEB.1.10.0903181256440.15570@qirst.com> <20090318180152.GB24462@csn.ul.ie> <alpine.DEB.1.10.0903181508030.10154@qirst.com> <alpine.DEB.1.10.0903191642160.22425@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903191642160.22425@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 19, 2009 at 04:43:55PM -0400, Christoph Lameter wrote:
> 
> It seems that its beneficial to have a less expensive way to check for the
> number of currently active and possible nodes in a NUMA system. This will
> simplify further kernel optimizations for the cases in which only a single
> node is online or possible.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> Index: linux-2.6/include/linux/nodemask.h
> ===================================================================
> --- linux-2.6.orig/include/linux/nodemask.h	2009-03-19 15:04:28.000000000 -0500
> +++ linux-2.6/include/linux/nodemask.h	2009-03-19 15:33:18.000000000 -0500
> @@ -408,6 +408,20 @@
>  #define next_online_node(nid)	next_node((nid), node_states[N_ONLINE])
> 
>  extern int nr_node_ids;
> +extern int nr_online_nodes;
> +extern int nr_possible_nodes;

Have you tested the nr_possible_nodes aspects  of this patch? I can see
where it gets initialised but nothing that updates it. It would appear that
nr_possible_nodes() and num_possible_nodes() can return different values.

> +
> +static inline void node_set_online(int nid)
> +{
> +	node_set_state(nid, N_ONLINE);
> +	nr_online_nodes = num_node_state(N_ONLINE);
> +}
> +
> +static inline void node_set_offline(int nid)
> +{
> +	node_clear_state(nid, N_ONLINE);
> +	nr_online_nodes = num_node_state(N_ONLINE);
> +}
>  #else
> 
>  static inline int node_state(int node, enum node_states state)
> @@ -434,7 +448,8 @@
>  #define first_online_node	0
>  #define next_online_node(nid)	(MAX_NUMNODES)
>  #define nr_node_ids		1
> -
> +#define nr_online_nodes		1
> +#define nr_possible_nodes	1
>  #endif
> 
>  #define node_online_map 	node_states[N_ONLINE]
> @@ -454,8 +469,7 @@
>  #define node_online(node)	node_state((node), N_ONLINE)
>  #define node_possible(node)	node_state((node), N_POSSIBLE)
> 
> -#define node_set_online(node)	   node_set_state((node), N_ONLINE)
> -#define node_set_offline(node)	   node_clear_state((node), N_ONLINE)
> +
> 
>  #define for_each_node(node)	   for_each_node_state(node, N_POSSIBLE)
>  #define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c	2009-03-19 15:11:49.000000000 -0500
> +++ linux-2.6/mm/hugetlb.c	2009-03-19 15:12:13.000000000 -0500
> @@ -875,7 +875,7 @@
>  	 * can no longer free unreserved surplus pages. This occurs when
>  	 * the nodes with surplus pages have no free pages.
>  	 */
> -	unsigned long remaining_iterations = num_online_nodes();
> +	unsigned long remaining_iterations = nr_online_nodes;
> 
>  	/* Uncommit the reservation */
>  	h->resv_huge_pages -= unused_resv_pages;
> @@ -904,7 +904,7 @@
>  			h->surplus_huge_pages--;
>  			h->surplus_huge_pages_node[nid]--;
>  			nr_pages--;
> -			remaining_iterations = num_online_nodes();
> +			remaining_iterations = nr_online_nodes;
>  		}
>  	}
>  }
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c	2009-03-19 15:12:19.000000000 -0500
> +++ linux-2.6/mm/page_alloc.c	2009-03-19 15:30:21.000000000 -0500
> @@ -168,6 +168,10 @@
>  #if MAX_NUMNODES > 1
>  int nr_node_ids __read_mostly = MAX_NUMNODES;
>  EXPORT_SYMBOL(nr_node_ids);
> +int nr_online_nodes __read_mostly = 1;
> +EXPORT_SYMBOL(nr_online_nodes);
> +int nr_possible_nodes __read_mostly = MAX_NUMNODES;
> +EXPORT_SYMBOL(nr_possible_nodes);
>  #endif
> 
>  int page_group_by_mobility_disabled __read_mostly;
> @@ -2115,7 +2119,7 @@
>  }
> 
> 
> -#define MAX_NODE_LOAD (num_online_nodes())
> +#define MAX_NODE_LOAD nr_online_nodes
>  static int node_load[MAX_NUMNODES];
> 
>  /**
> Index: linux-2.6/mm/slab.c
> ===================================================================
> --- linux-2.6.orig/mm/slab.c	2009-03-19 15:13:45.000000000 -0500
> +++ linux-2.6/mm/slab.c	2009-03-19 15:15:28.000000000 -0500
> @@ -881,7 +881,6 @@
>    */
> 
>  static int use_alien_caches __read_mostly = 1;
> -static int numa_platform __read_mostly = 1;
>  static int __init noaliencache_setup(char *s)
>  {
>  	use_alien_caches = 0;
> @@ -1434,9 +1433,8 @@
>  	int order;
>  	int node;
> 
> -	if (num_possible_nodes() == 1) {
> +	if (nr_possible_nodes == 1) {
>  		use_alien_caches = 0;
> -		numa_platform = 0;
>  	}
> 
>  	for (i = 0; i < NUM_INIT_LISTS; i++) {
> @@ -3526,7 +3524,7 @@
>  	 * variable to skip the call, which is mostly likely to be present in
>  	 * the cache.
>  	 */
> -	if (numa_platform && cache_free_alien(cachep, objp))
> +	if (nr_possible_nodes > 1 && cache_free_alien(cachep, objp))
>  		return;
> 
>  	if (likely(ac->avail < ac->limit)) {
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2009-03-19 15:13:15.000000000 -0500
> +++ linux-2.6/mm/slub.c	2009-03-19 15:13:38.000000000 -0500
> @@ -3648,7 +3648,7 @@
>  						 to_cpumask(l->cpus));
>  		}
> 
> -		if (num_online_nodes() > 1 && !nodes_empty(l->nodes) &&
> +		if (nr_online_nodes > 1 && !nodes_empty(l->nodes) &&
>  				len < PAGE_SIZE - 60) {
>  			len += sprintf(buf + len, " nodes=");
>  			len += nodelist_scnprintf(buf + len, PAGE_SIZE - len - 50,
> Index: linux-2.6/net/sunrpc/svc.c
> ===================================================================
> --- linux-2.6.orig/net/sunrpc/svc.c	2009-03-19 15:16:21.000000000 -0500
> +++ linux-2.6/net/sunrpc/svc.c	2009-03-19 15:16:51.000000000 -0500
> @@ -124,7 +124,7 @@
>  {
>  	unsigned int node;
> 
> -	if (num_online_nodes() > 1) {
> +	if (nr_online_nodes > 1) {
>  		/*
>  		 * Actually have multiple NUMA nodes,
>  		 * so split pools on NUMA node boundaries
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
