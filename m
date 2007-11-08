Date: Thu, 8 Nov 2007 14:50:44 +0000
Subject: Re: [patch 02/23] SLUB: Rename NUMA defrag_ratio to remote_node_defrag_ratio
Message-ID: <20071108145044.GB2591@skynet.ie>
References: <20071107011130.382244340@sgi.com> <20071107011226.844437184@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20071107011226.844437184@sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (06/11/07 17:11), Christoph Lameter didst pronounce:
> We need the defrag ratio for the non NUMA situation now. The NUMA defrag works
> by allocating objects from partial slabs on remote nodes. Rename it to
> 
> 	remote_node_defrag_ratio
> 

I'm not too keen on the defrag name here largely because I cannot tell what
it has to do with defragmention or ratios. It's really about working out
when it is better to pack objects into a remote slab than reclaim objects
from a local slab, right? It's also not clear what it is a ratio of what to
what. I thought it might be clock cycles but that isn't very clear either.
If we are renaming this can it be something like remote_packing_cost_limit ?

> to be clear about this.
> 
> [This patch is already in mm]
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  include/linux/slub_def.h |    5 ++++-
>  mm/slub.c                |   17 +++++++++--------
>  2 files changed, 13 insertions(+), 9 deletions(-)
> 
> Index: linux-2.6/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slub_def.h	2007-11-06 12:34:13.000000000 -0800
> +++ linux-2.6/include/linux/slub_def.h	2007-11-06 12:36:28.000000000 -0800
> @@ -60,7 +60,10 @@ struct kmem_cache {
>  #endif
>  
>  #ifdef CONFIG_NUMA
> -	int defrag_ratio;
> +	/*
> +	 * Defragmentation by allocating from a remote node.
> +	 */
> +	int remote_node_defrag_ratio;

How about

/*
 * When packing objects into slabs, it may become necessary to
 * reclaim objects on a local slab or allocate from a remote node.
 * The remote_packing_cost_limit is the maximum cost of remote
 * accesses that should be paid before it becomes worthwhile to
 * reclaim instead
 */
int remote_packing_cost_limit;

?

I still don't see what get_cycles() has to do with anything but this
could be because my understanding of SLUB sucks.

>  	struct kmem_cache_node *node[MAX_NUMNODES];
>  #endif
>  #ifdef CONFIG_SMP
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2007-11-06 12:36:16.000000000 -0800
> +++ linux-2.6/mm/slub.c	2007-11-06 12:37:25.000000000 -0800
> @@ -1345,7 +1345,8 @@ static unsigned long get_any_partial(str
>  	 * expensive if we do it every time we are trying to find a slab
>  	 * with available objects.
>  	 */
> -	if (!s->defrag_ratio || get_cycles() % 1024 > s->defrag_ratio)
> +	if (!s->remote_node_defrag_ratio ||
> +			get_cycles() % 1024 > s->remote_node_defrag_ratio)

I cannot figure out what the number of cycles currently showing on the TSC
have to do with a ratio :(. I could semi-understand if we were counting up
how many cycles were being spent trying to pack objects but that does not
appear to be the case. The comment didn't help a whole lot either. It felt
like a cost for packing, not a ratio

>  		return 0;
>  
>  	zonelist = &NODE_DATA(slab_node(current->mempolicy))
> @@ -2363,7 +2364,7 @@ static int kmem_cache_open(struct kmem_c
>  
>  	s->refcount = 1;
>  #ifdef CONFIG_NUMA
> -	s->defrag_ratio = 100;
> +	s->remote_node_defrag_ratio = 100;
>  #endif
>  	if (!init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
>  		goto error;
> @@ -4005,21 +4006,21 @@ static ssize_t free_calls_show(struct km
>  SLAB_ATTR_RO(free_calls);
>  
>  #ifdef CONFIG_NUMA
> -static ssize_t defrag_ratio_show(struct kmem_cache *s, char *buf)
> +static ssize_t remote_node_defrag_ratio_show(struct kmem_cache *s, char *buf)
>  {
> -	return sprintf(buf, "%d\n", s->defrag_ratio / 10);
> +	return sprintf(buf, "%d\n", s->remote_node_defrag_ratio / 10);
>  }
>  
> -static ssize_t defrag_ratio_store(struct kmem_cache *s,
> +static ssize_t remote_node_defrag_ratio_store(struct kmem_cache *s,
>  				const char *buf, size_t length)
>  {
>  	int n = simple_strtoul(buf, NULL, 10);
>  
>  	if (n < 100)
> -		s->defrag_ratio = n * 10;
> +		s->remote_node_defrag_ratio = n * 10;
>  	return length;
>  }
> -SLAB_ATTR(defrag_ratio);
> +SLAB_ATTR(remote_node_defrag_ratio);
>  #endif
>  
>  static struct attribute * slab_attrs[] = {
> @@ -4050,7 +4051,7 @@ static struct attribute * slab_attrs[] =
>  	&cache_dma_attr.attr,
>  #endif
>  #ifdef CONFIG_NUMA
> -	&defrag_ratio_attr.attr,
> +	&remote_node_defrag_ratio_attr.attr,
>  #endif
>  	NULL
>  };
> 
> -- 
> 

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
