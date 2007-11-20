Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20071120141953.GB32313@csn.ul.ie>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
	 <20071109143426.23540.44459.sendpatchset@skynet.skynet.ie>
	 <Pine.LNX.4.64.0711090741120.13932@schroedinger.engr.sgi.com>
	 <20071120141953.GB32313@csn.ul.ie>
Content-Type: text/plain
Date: Tue, 20 Nov 2007 10:14:39 -0500
Message-Id: <1195571680.5041.14.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, nacc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-11-20 at 14:19 +0000, Mel Gorman wrote:
> On (09/11/07 07:45), Christoph Lameter didst pronounce:
> > On Fri, 9 Nov 2007, Mel Gorman wrote:
> > 
> > >  struct page * fastcall
> > >  __alloc_pages(gfp_t gfp_mask, unsigned int order,
> > >  		struct zonelist *zonelist)
> > >  {
> > > +	/*
> > > +	 * Use a temporary nodemask for __GFP_THISNODE allocations. If the
> > > +	 * cost of allocating on the stack or the stack usage becomes
> > > +	 * noticable, allocate the nodemasks per node at boot or compile time
> > > +	 */
> > > +	if (unlikely(gfp_mask & __GFP_THISNODE)) {
> > > +		nodemask_t nodemask;
> > 
> > Hmmm.. This places a potentially big structure on the stack. nodemask can 
> > contain up to 1024 bits which means 128 bytes. Maybe keep an array of 
> > gfp_thisnode nodemasks (node_nodemask?) and use node_nodemask[nid]?
> 
> Went back and revisited this. Allocating them at boot-time is below but
> essentially it is a silly and it makes sense to just have two zonelists
> where one of them is for __GFP_THISNODE. Implementation wise, this involves
> dropping the last patch in the set and the overall result is still a reduction
> in the number of zonelists.

Hi, Mel:

I'll try this out [n 24-rc2-mm1 or later].  I have a series with yet
another rework of policy reference counting that will be easier/cleaner
atop your series w/o the external zonelist hung off 'BIND policies.  So,
I'm hoping your series goes into -mm "real soon now".

Question:  Just wondering why you didn't embed the '_THISNODE nodemask
in the pgdat_t--initialized at boot/node-hot-add time?  Perhaps under
#ifdef CONFIG_NUMA. The size is known at build time, right?  And
wouldn't that be way smaller than an additional zonelist?  

Lee

> 
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc2-mm1-040_use_one_zonelist/include/linux/gfp.h linux-2.6.24-rc2-mm1-045_use_static_nodemask/include/linux/gfp.h
> --- linux-2.6.24-rc2-mm1-040_use_one_zonelist/include/linux/gfp.h	2007-11-19 19:27:15.000000000 +0000
> +++ linux-2.6.24-rc2-mm1-045_use_static_nodemask/include/linux/gfp.h	2007-11-19 19:28:55.000000000 +0000
> @@ -175,7 +175,6 @@ FASTCALL(__alloc_pages(gfp_t, unsigned i
>  extern struct page *
>  FASTCALL(__alloc_pages_nodemask(gfp_t, unsigned int,
>  				struct zonelist *, nodemask_t *nodemask));
> -extern nodemask_t *nodemask_thisnode(int nid, nodemask_t *nodemask);
>  
>  static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>  						unsigned int order)
> @@ -187,13 +186,10 @@ static inline struct page *alloc_pages_n
>  	if (nid < 0)
>  		nid = numa_node_id();
>  
> -	/* Use a temporary nodemask for __GFP_THISNODE allocations */
>  	if (unlikely(gfp_mask & __GFP_THISNODE)) {
> -		nodemask_t nodemask;
> -
>  		return __alloc_pages_nodemask(gfp_mask, order,
>  				node_zonelist(nid),
> -				nodemask_thisnode(nid, &nodemask));
> +				NODE_DATA(nid)->nodemask_thisnode);
>  	}
>  
>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid));
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc2-mm1-040_use_one_zonelist/include/linux/mmzone.h linux-2.6.24-rc2-mm1-045_use_static_nodemask/include/linux/mmzone.h
> --- linux-2.6.24-rc2-mm1-040_use_one_zonelist/include/linux/mmzone.h	2007-11-19 19:27:15.000000000 +0000
> +++ linux-2.6.24-rc2-mm1-045_use_static_nodemask/include/linux/mmzone.h	2007-11-19 19:28:55.000000000 +0000
> @@ -519,6 +519,9 @@ typedef struct pglist_data {
>  	struct zone node_zones[MAX_NR_ZONES];
>  	struct zonelist node_zonelist;
>  	int nr_zones;
> +
> +	/* nodemask suitable for __GFP_THISNODE */
> +	nodemask_t *nodemask_thisnode;
>  #ifdef CONFIG_FLAT_NODE_MEM_MAP
>  	struct page *node_mem_map;
>  #endif
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc2-mm1-040_use_one_zonelist/mm/page_alloc.c linux-2.6.24-rc2-mm1-045_use_static_nodemask/mm/page_alloc.c
> --- linux-2.6.24-rc2-mm1-040_use_one_zonelist/mm/page_alloc.c	2007-11-19 19:27:15.000000000 +0000
> +++ linux-2.6.24-rc2-mm1-045_use_static_nodemask/mm/page_alloc.c	2007-11-19 19:28:55.000000000 +0000
> @@ -1695,28 +1695,36 @@ got_pg:
>  }
>  
>  /* Creates a nodemask suitable for GFP_THISNODE allocations */
> -nodemask_t *nodemask_thisnode(int nid, nodemask_t *nodemask)
> +static inline void alloc_node_nodemask_thisnode(pg_data_t *pgdat)
>  {
> -	nodes_clear(*nodemask);
> -	node_set(nid, *nodemask);
> +	nodemask_t *nodemask_thisnode;
>  
> -	return nodemask;
> +	/* Only a machine with multiple nodes needs the nodemask */
> +	if (!NUMA_BUILD || num_online_nodes() == 1)
> +		return;
> +	
> +	/* Allocate the nodemask. Serious if it fails, but not world ending */
> +	nodemask_thisnode = alloc_bootmem_node(pgdat, sizeof(nodemask_t));
> +	if (!nodemask_thisnode) {
> +		printk(KERN_WARNING
> +			"thisnode nodemask allocation failed."
> +			"There may be sub-optimal NUMA placement.\n");
> +		return;
> +	}
> +
> +	/* Initialise the nodemask to only cover the current node */
> +	nodes_clear(*nodemask_thisnode);
> +	node_set(pgdat->node_id, *nodemask_thisnode);
> +	pgdat->nodemask_thisnode = nodemask_thisnode;
>  }
>  
>  struct page * fastcall
>  __alloc_pages(gfp_t gfp_mask, unsigned int order,
>  		struct zonelist *zonelist)
>  {
> -	/*
> -	 * Use a temporary nodemask for __GFP_THISNODE allocations. If the
> -	 * cost of allocating on the stack or the stack usage becomes
> -	 * noticable, allocate the nodemasks per node at boot or compile time
> -	 */
>  	if (unlikely(gfp_mask & __GFP_THISNODE)) {
> -		nodemask_t nodemask;
> -
> -		return __alloc_pages_internal(gfp_mask, order,
> -			zonelist, nodemask_thisnode(numa_node_id(), &nodemask));
> +		return __alloc_pages_internal(gfp_mask, order, zonelist,
> +			NODE_DATA(numa_node_id())->nodemask_thisnode);
>  	}
>  
>  	return __alloc_pages_internal(gfp_mask, order, zonelist, NULL);
> @@ -3501,6 +3509,7 @@ void __meminit free_area_init_node(int n
>  	calculate_node_totalpages(pgdat, zones_size, zholes_size);
>  
>  	alloc_node_mem_map(pgdat);
> +	alloc_node_nodemask_thisnode(pgdat);
>  
>  	free_area_init_core(pgdat, zones_size, zholes_size);
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
