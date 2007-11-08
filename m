Date: Thu, 8 Nov 2007 15:07:05 +0000
Subject: Re: [patch 07/23] SLUB: Add defrag_ratio field and sysfs support.
Message-ID: <20071108150705.GD2591@skynet.ie>
References: <20071107011130.382244340@sgi.com> <20071107011228.102370371@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20071107011228.102370371@sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (06/11/07 17:11), Christoph Lameter didst pronounce:
> The defrag_ratio is used to set the threshold at which defragmentation
> should be run on a slabcache.
> 

I'm thick, I would like to see a quick note here on what defragmentation
means. Also, this defrag_ratio seems to have a significantly different
meaning to the other defrag_ratio which isn't helping my poor head at
all.

"The defrag_ratio sets a threshold at which a slab will be vacated of all
it's objects and the pages freed during memory reclaim."

?

> The allocation ratio is measured in a percentage of the available slots.
> The percentage will be lower for slabs that are more fragmented.
> 
> Add a defrag ratio field and set it to 30% by default. A limit of 30% specified
> that less than 3 out of 10 available slots for objects are in use before
> reclaim occurs.
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  include/linux/slub_def.h |    7 +++++++
>  mm/slub.c                |   18 ++++++++++++++++++
>  2 files changed, 25 insertions(+)
> 
> Index: linux-2.6/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slub_def.h	2007-11-06 12:36:28.000000000 -0800
> +++ linux-2.6/include/linux/slub_def.h	2007-11-06 12:37:44.000000000 -0800
> @@ -53,6 +53,13 @@ struct kmem_cache {
>  	void (*ctor)(struct kmem_cache *, void *);
>  	int inuse;		/* Offset to metadata */
>  	int align;		/* Alignment */
> +	int defrag_ratio;	/*
> +				 * objects/possible-objects limit. If we have
> +				 * less that the specified percentage of
> +				 * objects allocated then defrag passes
> +				 * will start to occur during reclaim.
> +				 */
> +
>  	const char *name;	/* Name (only for display!) */
>  	struct list_head list;	/* List of slab caches */
>  #ifdef CONFIG_SLUB_DEBUG
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2007-11-06 12:37:25.000000000 -0800
> +++ linux-2.6/mm/slub.c	2007-11-06 12:37:44.000000000 -0800
> @@ -2363,6 +2363,7 @@ static int kmem_cache_open(struct kmem_c
>  		goto error;
>  
>  	s->refcount = 1;
> +	s->defrag_ratio = 30;
>  #ifdef CONFIG_NUMA
>  	s->remote_node_defrag_ratio = 100;
>  #endif
> @@ -4005,6 +4006,22 @@ static ssize_t free_calls_show(struct km
>  }
>  SLAB_ATTR_RO(free_calls);
>  
> +static ssize_t defrag_ratio_show(struct kmem_cache *s, char *buf)
> +{
> +	return sprintf(buf, "%d\n", s->defrag_ratio);
> +}
> +
> +static ssize_t defrag_ratio_store(struct kmem_cache *s,
> +				const char *buf, size_t length)
> +{
> +	int n = simple_strtoul(buf, NULL, 10);
> +
> +	if (n < 100)
> +		s->defrag_ratio = n;
> +	return length;
> +}
> +SLAB_ATTR(defrag_ratio);
> +
>  #ifdef CONFIG_NUMA
>  static ssize_t remote_node_defrag_ratio_show(struct kmem_cache *s, char *buf)
>  {
> @@ -4047,6 +4064,7 @@ static struct attribute * slab_attrs[] =
>  	&shrink_attr.attr,
>  	&alloc_calls_attr.attr,
>  	&free_calls_attr.attr,
> +	&defrag_ratio_attr.attr,
>  #ifdef CONFIG_ZONE_DMA
>  	&cache_dma_attr.attr,
>  #endif
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
