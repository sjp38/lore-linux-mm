Message-ID: <44D8C24F.8010808@shadowen.org>
Date: Tue, 08 Aug 2006 17:56:47 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@SGI.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, pj@SGI.com, jes@SGI.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Add a new gfp flag __GFP_THISNODE to avoid fallback to other nodes. This flag
> is essential if a kernel component requires memory to be located on a
> certain node. It will be needed for alloc_pages_node() to force allocation
> on the indicated node and for alloc_pages() to force allocation on the
> current node.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.18-rc3-mm2/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.18-rc3-mm2.orig/mm/page_alloc.c	2006-08-07 20:21:28.431331931 -0700
> +++ linux-2.6.18-rc3-mm2/mm/page_alloc.c	2006-08-08 09:23:23.323396326 -0700
> @@ -916,6 +916,9 @@ get_page_from_freelist(gfp_t gfp_mask, u
>  	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
>  	 */
>  	do {
> +		if (unlikely((gfp_mask & __GFP_THISNODE) &&
> +			(*z)->zone_pgdat != zonelist->zones[0]->zone_pgdat))
> +				break;
>  		if ((alloc_flags & ALLOC_CPUSET) &&
>  				!cpuset_zone_allowed(*z, gfp_mask))
>  			continue;

Would this not be a very good example of an overlapping GFP_foo bits?. 
If this bit were just passed through with the GFP_DMA etc then we could 
build lists per-node which only include the node, then put those in the 
zonelist[GFP_THISNODE|GFP_DMA] etc?

-apw

> Index: linux-2.6.18-rc3-mm2/include/linux/gfp.h
> ===================================================================
> --- linux-2.6.18-rc3-mm2.orig/include/linux/gfp.h	2006-08-07 20:21:01.808957041 -0700
> +++ linux-2.6.18-rc3-mm2/include/linux/gfp.h	2006-08-08 09:20:41.727897528 -0700
> @@ -45,6 +45,7 @@ struct vm_area_struct;
>  #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
>  #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
>  #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
> +#define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
>  
>  #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
> Index: linux-2.6.18-rc3-mm2/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.18-rc3-mm2.orig/mm/mempolicy.c	2006-08-07 20:21:01.810910045 -0700
> +++ linux-2.6.18-rc3-mm2/mm/mempolicy.c	2006-08-08 09:20:41.729850533 -0700
> @@ -1278,7 +1278,7 @@ struct page *alloc_pages_current(gfp_t g
>  
>  	if ((gfp & __GFP_WAIT) && !in_interrupt())
>  		cpuset_update_task_memory_state();
> -	if (!pol || in_interrupt())
> +	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
>  		pol = &default_policy;
>  	if (pol->policy == MPOL_INTERLEAVE)
>  		return alloc_page_interleave(gfp, order, interleave_nodes(pol));
> Index: linux-2.6.18-rc3-mm2/kernel/cpuset.c
> ===================================================================
> --- linux-2.6.18-rc3-mm2.orig/kernel/cpuset.c	2006-08-07 20:21:07.429702734 -0700
> +++ linux-2.6.18-rc3-mm2/kernel/cpuset.c	2006-08-08 09:20:41.730827035 -0700
> @@ -2282,7 +2282,7 @@ int __cpuset_zone_allowed(struct zone *z
>  	const struct cpuset *cs;	/* current cpuset ancestors */
>  	int allowed;			/* is allocation in zone z allowed? */
>  
> -	if (in_interrupt())
> +	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
>  		return 1;
>  	node = z->zone_pgdat->node_id;
>  	might_sleep_if(!(gfp_mask & __GFP_HARDWALL));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
