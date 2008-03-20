Subject: Re: [patch 7/9] slub: Adjust order boundaries and minimum objects
	per slab.
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <20080317230529.474353536@sgi.com>
References: <20080317230516.078358225@sgi.com>
	 <20080317230529.474353536@sgi.com>
Content-Type: text/plain; charset=utf-8
Date: Thu, 20 Mar 2008 14:44:43 +0800
Message-Id: <1205995483.14496.59.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-17 at 16:05 -0700, Christoph Lameter wrote:
> plain text document attachment
> (0007-slub-Adjust-order-boundaries-and-minimum-objects-pe.patch)
> Since there is now no worry anymore about higher order allocs (hopefully).
> Set the max order to default to PAGE_ALLOC_ORDER_COSTLY (32k) and require
> slub to use a higher order if a certain object density cannot be reached.
> 
> The mininum objects per slab is calculated based on the number of processors
> that may come online.
> 
> Processors	min_objects
> ---------------------------
> 1		4
> 2		8
> 4		12
> 8		16
> 16		20
> 32		24
> 64		28
> 1024		44
> 4096		52
All min_objects's real values are 4 more than above values, as fls(16)
is equal to 5. So on 16-core tigerton, min_objects=24 which is between 16 and 32.

I applied the patches to 2.6.26-rc6 and tested it on 16-core tigerton and 8-core
stoakley. The result is between the ones of min_objects=16 and min_objects=32 on tigerton.
On stoakley, the result distance is even smaller. I'm ok with the result.

Thanks,
yanmin

> 
> V1->V2
> - Add logic to compute min_objects based on processor count.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  mm/slub.c |   29 +++++++----------------------
>  1 file changed, 7 insertions(+), 22 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2008-03-17 15:33:42.118699647 -0700
> +++ linux-2.6/mm/slub.c	2008-03-17 15:49:57.459504642 -0700
> @@ -5,7 +5,7 @@
>   * The allocator synchronizes using per slab locks and only
>   * uses a centralized lock to manage a pool of partial slabs.
>   *
> - * (C) 2007 SGI, Christoph Lameter <clameter@sgi.com>
> + * (C) 2007, 2008 SGI, Christoph Lameter <clameter@sgi.com>
>   */
>  
>  #include <linux/mm.h>
> @@ -149,24 +149,7 @@ static inline void ClearSlabDebug(struct
>  /* Enable to test recovery from slab corruption on boot */
>  #undef SLUB_RESILIENCY_TEST
>  
> -#if PAGE_SHIFT <= 12
> -
> -/*
> - * Small page size. Make sure that we do not fragment memory
> - */
> -#define DEFAULT_MAX_ORDER 1
> -#define DEFAULT_MIN_OBJECTS 4
> -
> -#else
> -
> -/*
> - * Large page machines are customarily able to handle larger
> - * page orders.
> - */
> -#define DEFAULT_MAX_ORDER 2
> -#define DEFAULT_MIN_OBJECTS 8
> -
> -#endif
> +#define DEFAULT_MAX_ORDER PAGE_ALLOC_COSTLY_ORDER
>  
>  /*
>   * Mininum number of partial slabs. These will be left on the partial
> @@ -1768,7 +1751,7 @@ static struct page *get_object_page(cons
>   */
>  static int slub_min_order;
>  static int slub_max_order = DEFAULT_MAX_ORDER;
> -static int slub_min_objects = DEFAULT_MIN_OBJECTS;
> +static int slub_min_objects = -1;
>  
>  /*
>   * Merge control. If this is set then no merging of slab caches will occur.
> @@ -1845,9 +1828,11 @@ static inline int calculate_order(int si
>  	 * we reduce the minimum objects required in a slab.
>  	 */
>  	min_objects = slub_min_objects;
> +	if (min_objects <= 0)
> +		min_objects = 4 * (fls(nr_cpu_ids) + 1);
>  	while (min_objects > 1) {
> -		fraction = 8;
> -		while (fraction >= 4) {
> +		fraction = 16;
> +		while (fraction >= 8) {
>  			order = slab_order(size, min_objects,
>  						slub_max_order, fraction);
>  			if (order <= slub_max_order)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
