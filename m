Subject: Re: [patch 5/9] slub: Fallback to minimal order during slab page
	allocation
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <20080317230528.939792410@sgi.com>
References: <20080317230516.078358225@sgi.com>
	 <20080317230528.939792410@sgi.com>
Content-Type: text/plain; charset=utf-8
Date: Thu, 20 Mar 2008 13:10:39 +0800
Message-Id: <1205989839.14496.32.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-17 at 16:05 -0700, Christoph Lameter wrote:
> plain text document attachment
> (0005-slub-Fallback-to-minimal-order-during-slab-page-all.patch)
> If any higher order allocation fails then fall back the smallest order
> necessary to contain at least one object.
> 
> Add a new field min_objects that will contain the objects for the smallest
> possible order of an allocation.
> 
> Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  include/linux/slub_def.h |    2 +
>  mm/slub.c                |   49 +++++++++++++++++++++++++++++++++--------------
>  2 files changed, 37 insertions(+), 14 deletions(-)
> 
> Index: linux-2.6/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slub_def.h	2008-03-17 15:32:07.605564060 -0700
> +++ linux-2.6/include/linux/slub_def.h	2008-03-17 15:33:05.718268322 -0700
> @@ -29,6 +29,7 @@ enum stat_item {
>  	DEACTIVATE_TO_HEAD,	/* Cpu slab was moved to the head of partials */
>  	DEACTIVATE_TO_TAIL,	/* Cpu slab was moved to the tail of partials */
>  	DEACTIVATE_REMOTE_FREES,/* Slab contained remotely freed objects */
> +	ORDER_FALLBACK,		/* Number of times fallback was necessary */
>  	NR_SLUB_STAT_ITEMS };
>  
>  struct kmem_cache_cpu {
> @@ -73,6 +74,7 @@ struct kmem_cache {
>  	/* Allocation and freeing of slabs */
>  	int max_objects;	/* Number of objects in a slab of maximum size */
>  	int objects;		/* Number of objects in a slab of current size */
> +	int min_objects;	/* Number of objects in a slab of mininum size */
Will min_objects be exported by sysfs? If not, I would like not to add the member.
In stead, just change function allocate_slab:

page->objects = (PAGE_SIZE << get_order(s->size)) / s->size;


It'll look more readable and be simplified.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
