Date: Mon, 11 Feb 2008 13:50:47 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: SLUB tbench regression due to page allocator deficiency
Message-ID: <20080211135046.GD31903@csn.ul.ie>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On (09/02/08 13:45), Christoph Lameter didst pronounce:
> I have been chasing the tbench regression (1-4%) for two weeks now and 
> even after I added statistics I could only verify that behavior was just 
> optimal.
> 
> None of the tricks that I threw at the problem changed anything until I 
> realized that the tbench load depends heavily on 4k allocations that SLUB 
> hands off to the page allocator (SLAB handles 4k itself). I extended the 
> kmalloc array to 4k and I got:

This poked me into checking the results I got when comparing SLAB/SLUB
in 2.6.24. I ran a fairly large set of benchmarks and then failed to
follow up on it :/

The results I got for tbench were considerably worse than 4% (sorry for
the wide output). This

bl6-13/report.txt:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-debug)
bl6-13/report.txt-                     Min                         Average                     Max                         Std. Deviation              
bl6-13/report.txt-                     --------------------------- --------------------------- --------------------------- ----------------------------
bl6-13/report.txt-clients-1              176.37/156.81   (-12.47%)   186.57/173.51   ( -7.53%)   204.71/209.94   (  2.49%)     9.51/13.64    ( -43.38%)
bl6-13/report.txt-clients-2              319.70/282.60   (-13.13%)   347.16/313.87   (-10.61%)   414.66/343.35   (-20.77%)    21.12/12.45    (  41.04%)
bl6-13/report.txt-clients-4              854.17/685.53   (-24.60%)  1024.46/845.32   (-21.19%)  1067.28/905.61   (-17.85%)    44.97/46.26    (  -2.87%)
bl6-13/report.txt-clients-8              974.06/835.80   (-16.54%)  1010.90/882.97   (-14.49%)  1027.36/917.22   (-12.01%)    13.68/19.84    ( -45.00%)
bl6-13/report.txt-
--
elm3a203/report.txt:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-debug)
elm3a203/report.txt-                     Min                         Average                     Max                         Std. Deviation              
elm3a203/report.txt-                     --------------------------- --------------------------- --------------------------- ----------------------------
elm3a203/report.txt-clients-1              111.25/97.59    (-13.99%)   112.30/99.66    (-12.68%)   113.25/101.21   (-11.89%)     0.49/0.78     ( -59.29%)
elm3a203/report.txt-clients-1              112.28/97.39    (-15.29%)   113.13/99.68    (-13.50%)   113.79/100.58   (-13.13%)     0.32/0.87     (-176.48%)
elm3a203/report.txt-clients-2              149.01/131.90   (-12.97%)   151.04/136.51   (-10.64%)   152.52/139.26   ( -9.53%)     0.97/1.51     ( -55.79%)
elm3a203/report.txt-clients-4              145.94/130.05   (-12.22%)   147.62/132.33   (-11.56%)   148.92/134.26   (-10.92%)     0.88/1.10     ( -25.10%)
elm3a203/report.txt-
--
elm3b133/report.txt:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-debug)
elm3b133/report.txt-                     Min                         Average                     Max                         Std. Deviation              
elm3b133/report.txt-                     --------------------------- --------------------------- --------------------------- ----------------------------
elm3b133/report.txt-clients-1               28.17/26.95    ( -4.53%)    28.34/27.25    ( -4.01%)    28.53/27.38    ( -4.22%)     0.09/0.10     (  -5.42%)
elm3b133/report.txt-clients-2               52.55/50.61    ( -3.83%)    53.20/51.28    ( -3.74%)    54.47/51.82    ( -5.11%)     0.49/0.33     (  32.41%)
elm3b133/report.txt-clients-4              111.15/105.14   ( -5.71%)   113.29/107.29   ( -5.59%)   114.16/108.58   ( -5.13%)     0.69/0.91     ( -32.14%)
elm3b133/report.txt-clients-8              109.63/104.37   ( -5.04%)   110.14/104.78   ( -5.12%)   110.80/105.43   ( -5.10%)     0.25/0.27     (  -8.94%)
elm3b133/report.txt-
--
elm3b19/report.txt:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-debug)
elm3b19/report.txt-                     Min                         Average                     Max                         Std. Deviation              
elm3b19/report.txt-                     --------------------------- --------------------------- --------------------------- ----------------------------
elm3b19/report.txt-clients-1              118.85/0.00     (  0.00%)   123.72/115.79   ( -6.84%)   131.11/129.94   ( -0.90%)     3.77/26.77    (-609.67%)
elm3b19/report.txt-clients-1              118.68/117.89   ( -0.67%)   124.65/123.52   ( -0.91%)   137.54/132.09   ( -4.13%)     5.52/4.20     (  23.78%)
elm3b19/report.txt-clients-2              223.73/211.77   ( -5.64%)   339.06/334.21   ( -1.45%)   367.83/357.20   ( -2.97%)    38.36/30.30    (  21.03%)
elm3b19/report.txt-clients-4              320.07/316.04   ( -1.28%)   331.93/324.42   ( -2.31%)   341.92/332.29   ( -2.90%)     5.51/4.07     (  26.03%)
elm3b19/report.txt-
--
elm3b6/report.txt:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-debug)
elm3b6/report.txt-                     Min                         Average                     Max                         Std. Deviation              
elm3b6/report.txt-                     --------------------------- --------------------------- --------------------------- ----------------------------
elm3b6/report.txt-clients-1              148.01/140.79   ( -5.13%)   156.19/153.67   ( -1.64%)   182.30/185.11   (  1.52%)     9.76/13.84    ( -41.84%)
elm3b6/report.txt-clients-2              251.07/253.07   (  0.79%)   292.60/286.59   ( -2.10%)   338.81/360.93   (  6.13%)    22.58/21.48    (   4.85%)
elm3b6/report.txt-clients-4              673.43/523.51   (-28.64%)   784.56/761.89   ( -2.98%)   846.40/818.38   ( -3.42%)    36.95/82.30    (-122.75%)
elm3b6/report.txt-clients-8              652.73/700.72   (  6.85%)   783.54/772.22   ( -1.47%)   833.56/812.21   ( -2.63%)    47.45/27.48    (  42.09%)
elm3b6/report.txt-
--
gekko-lp1/report.txt:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-debug)
gekko-lp1/report.txt-                     Min                         Average                     Max                         Std. Deviation              
gekko-lp1/report.txt-                     --------------------------- --------------------------- --------------------------- ----------------------------
gekko-lp1/report.txt-clients-1              170.56/163.15   ( -4.55%)   206.59/194.96   ( -5.96%)   221.27/206.46   ( -7.17%)    17.06/13.59    (  20.34%)
gekko-lp1/report.txt-clients-2              302.55/277.45   ( -9.05%)   319.14/306.39   ( -4.16%)   328.74/313.01   ( -5.03%)     6.21/8.18     ( -31.81%)
gekko-lp1/report.txt-clients-4              467.98/393.05   (-19.06%)   490.42/464.23   ( -5.64%)   503.74/477.13   ( -5.58%)    10.49/17.68    ( -68.61%)
gekko-lp1/report.txt-clients-8              469.16/447.00   ( -4.96%)   492.14/468.37   ( -5.07%)   498.79/472.47   ( -5.57%)     7.08/5.61     (  20.79%)
gekko-lp1/report.txt-

I think I didn't look too closely because kernbench was generally ok,
hackbench showed gains and losses depending on the machine and as TBench
has historically been a bit all over the place. That was a mistake
though as there was a definite slow-up even with the variances taken
into account.

> 
> christoph@stapp:~$ slabinfo -AD
> Name                   Objects    Alloc     Free   %Fast
> :0004096                   180 665259550 665259415  99  99
> skbuff_fclone_cache         46 665196592 665196592  99  99
> :0000192                  2575 31232665 31230129  99  99
> :0001024                   854 31204838 31204006  99  99
> vm_area_struct            1093   108941   107954  91  17
> dentry                    7738    26248    18544  92  43
> :0000064                  2179    19208    17287  97  73
> 
> So the kmalloc-4096 is heavily used. If I give the 4k objects a reasonable 
> allocation size in slub (PAGE_ALLOC_COSTLY_ORDER) then the fastpath of 
> SLUB becomes effective for 4k allocs and then SLUB is faster than SLAB 
> here.
> 
> Performance on tbench (Dual Quad 8p 8G):
> 
> SLAB		2223.32 MB/sec
> SLUB unmodified	2144.36 MB/sec
> SLUB+patch	2245.56 MB/sec (stats still active so this isnt optimal yet)
> 

I'll run tests for this patch and see what it looks like.

> 4k allocations cannot optimally be handled by SLUB if we are restricted to 
> order 0 allocs because the fastpath only handles fractions of one 
> allocation unit and if the allocation unit is 4k then we only have one 
> object per slab.
> 
> Isnt there a way that we can make the page allocator handle PAGE_SIZEd 
> allocations in such a way that is competitive with the slab allocators? 

Probably. It's been on my TODO list for an age to see what can be done.

> The cycle count for an allocation needs to be <100 not just below 1000 as 
> it is now.
> 
> ---
>  include/linux/slub_def.h |    6 +++---
>  mm/slub.c                |   25 +++++++++++++++++--------
>  2 files changed, 20 insertions(+), 11 deletions(-)
> 
> Index: linux-2.6/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slub_def.h	2008-02-09 13:04:48.464203968 -0800
> +++ linux-2.6/include/linux/slub_def.h	2008-02-09 13:08:37.413120259 -0800
> @@ -110,7 +110,7 @@ struct kmem_cache {
>   * We keep the general caches in an array of slab caches that are used for
>   * 2^x bytes of allocations.
>   */
> -extern struct kmem_cache kmalloc_caches[PAGE_SHIFT];
> +extern struct kmem_cache kmalloc_caches[PAGE_SHIFT + 1];
>  
>  /*
>   * Sorry that the following has to be that ugly but some versions of GCC
> @@ -191,7 +191,7 @@ void *__kmalloc(size_t size, gfp_t flags
>  static __always_inline void *kmalloc(size_t size, gfp_t flags)
>  {
>  	if (__builtin_constant_p(size)) {
> -		if (size > PAGE_SIZE / 2)
> +		if (size > PAGE_SIZE)
>  			return (void *)__get_free_pages(flags | __GFP_COMP,
>  							get_order(size));
>  
> @@ -214,7 +214,7 @@ void *kmem_cache_alloc_node(struct kmem_
>  static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
>  {
>  	if (__builtin_constant_p(size) &&
> -		size <= PAGE_SIZE / 2 && !(flags & SLUB_DMA)) {
> +		size <= PAGE_SIZE && !(flags & SLUB_DMA)) {
>  			struct kmem_cache *s = kmalloc_slab(size);
>  
>  		if (!s)
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2008-02-09 13:04:48.472203975 -0800
> +++ linux-2.6/mm/slub.c	2008-02-09 13:14:43.786633258 -0800
> @@ -1919,6 +1919,15 @@ static inline int calculate_order(int si
>  	int fraction;
>  
>  	/*
> +	 * Cover up bad performance of page allocator fastpath vs
> +	 * slab allocator fastpaths. Take the largest order reasonable
> +	 * in order to be able to avoid partial list overhead.
> +	 *
> +	 * This yields 8 4k objects per 32k slab allocation.
> +	 */
> +	if (size == PAGE_SIZE)
> +		return PAGE_ALLOC_COSTLY_ORDER;
> +	/*
>  	 * Attempt to find best configuration for a slab. This
>  	 * works by first attempting to generate a layout with
>  	 * the best configuration and backing off gradually.
> @@ -2484,11 +2493,11 @@ EXPORT_SYMBOL(kmem_cache_destroy);
>   *		Kmalloc subsystem
>   *******************************************************************/
>  
> -struct kmem_cache kmalloc_caches[PAGE_SHIFT] __cacheline_aligned;
> +struct kmem_cache kmalloc_caches[PAGE_SHIFT + 1] __cacheline_aligned;
>  EXPORT_SYMBOL(kmalloc_caches);
>  
>  #ifdef CONFIG_ZONE_DMA
> -static struct kmem_cache *kmalloc_caches_dma[PAGE_SHIFT];
> +static struct kmem_cache *kmalloc_caches_dma[PAGE_SHIFT + 1];
>  #endif
>  
>  static int __init setup_slub_min_order(char *str)
> @@ -2670,7 +2679,7 @@ void *__kmalloc(size_t size, gfp_t flags
>  {
>  	struct kmem_cache *s;
>  
> -	if (unlikely(size > PAGE_SIZE / 2))
> +	if (unlikely(size > PAGE_SIZE))
>  		return (void *)__get_free_pages(flags | __GFP_COMP,
>  							get_order(size));
>  
> @@ -2688,7 +2697,7 @@ void *__kmalloc_node(size_t size, gfp_t 
>  {
>  	struct kmem_cache *s;
>  
> -	if (unlikely(size > PAGE_SIZE / 2))
> +	if (unlikely(size > PAGE_SIZE))
>  		return (void *)__get_free_pages(flags | __GFP_COMP,
>  							get_order(size));
>  
> @@ -3001,7 +3010,7 @@ void __init kmem_cache_init(void)
>  		caches++;
>  	}
>  
> -	for (i = KMALLOC_SHIFT_LOW; i < PAGE_SHIFT; i++) {
> +	for (i = KMALLOC_SHIFT_LOW; i <= PAGE_SHIFT; i++) {
>  		create_kmalloc_cache(&kmalloc_caches[i],
>  			"kmalloc", 1 << i, GFP_KERNEL);
>  		caches++;
> @@ -3028,7 +3037,7 @@ void __init kmem_cache_init(void)
>  	slab_state = UP;
>  
>  	/* Provide the correct kmalloc names now that the caches are up */
> -	for (i = KMALLOC_SHIFT_LOW; i < PAGE_SHIFT; i++)
> +	for (i = KMALLOC_SHIFT_LOW; i <= PAGE_SHIFT; i++)
>  		kmalloc_caches[i]. name =
>  			kasprintf(GFP_KERNEL, "kmalloc-%d", 1 << i);
>  
> @@ -3218,7 +3227,7 @@ void *__kmalloc_track_caller(size_t size
>  {
>  	struct kmem_cache *s;
>  
> -	if (unlikely(size > PAGE_SIZE / 2))
> +	if (unlikely(size > PAGE_SIZE))
>  		return (void *)__get_free_pages(gfpflags | __GFP_COMP,
>  							get_order(size));
>  	s = get_slab(size, gfpflags);
> @@ -3234,7 +3243,7 @@ void *__kmalloc_node_track_caller(size_t
>  {
>  	struct kmem_cache *s;
>  
> -	if (unlikely(size > PAGE_SIZE / 2))
> +	if (unlikely(size > PAGE_SIZE))
>  		return (void *)__get_free_pages(gfpflags | __GFP_COMP,
>  							get_order(size));
>  	s = get_slab(size, gfpflags);
> 
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
