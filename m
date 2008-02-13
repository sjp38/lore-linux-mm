Date: Wed, 13 Feb 2008 11:15:17 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: SLUB tbench regression due to page allocator deficiency
Message-ID: <20080213111516.GA4007@csn.ul.ie>
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

I ran similar tests for tbench and also sysbench as it is closer to a
real workload. I have results from other tests as well although the oddest
was HackBench which showed +/- 30% performance gains/losses depending on
the machine.

In the results, the tbench comparisons are between slab and SLUB-lameter
which is the first patch posted in this thread. I posted up the figures
of slab vs slub-vanilla already. sysbench compares 2.6.23, 2.6.24-slab,
2.6.24-slub-vanilla and 2.6.24-slub-lameter.

Short answer: slub-lameter appears to be usually a win in many cases over
slab. However, such different behaviours between machines on even small
tests is something to be wary of. In one machine, this patch makes SLUB
slower but it was not typical.

Note that sysbench was not run everywhere as some crinkles in the
automation that prevent it running everywhere are still being ironed
out. Incidentally, its scalability sucks. Over 8 threads, performance
starts dropping sharply but I haven't checked out a different userspace
allocator yet as the system malloc was identified as a problem in the past
(http://ozlabs.org/~anton/linux/sysbench/).

elm3a238:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-lameter)
elm3a238-             Min                         Average                     Max                         Std. Deviation              
elm3a238-             --------------------------- --------------------------- --------------------------- ----------------------------
elm3a238-clients-1       80.00/82.66    (  3.22%)    84.22/83.43    ( -0.95%)    84.77/83.84    ( -1.11%)     1.00/0.25     (  75.20%)
elm3a238-clients-1       84.00/83.01    ( -1.20%)    84.41/83.42    ( -1.18%)    84.87/83.73    ( -1.36%)     0.20/0.22     ( -11.47%)
elm3a238-clients-2      115.71/114.89   ( -0.71%)   117.03/115.25   ( -1.55%)   117.71/115.79   ( -1.65%)     0.41/0.25     (  39.51%)
elm3a238-clients-4      116.37/113.40   ( -2.63%)   116.81/113.78   ( -2.66%)   117.24/114.24   ( -2.62%)     0.24/0.21     (  13.45%)
elm3a238-
sysbench: http://www.csn.ul.ie/~mel/postings/tsysbench-20080213/elm3a238-comparison.ps

Still showing a small regression against SLAB here. However, sysbench tells
a different story. 2.6.23 was fastest but 2.6.24-slub-vanilla was faster
than slab on 2.6.24. This patch made sysbench at least slower on this machine.
==

elm3a69:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-lameter)
elm3a69-             Min                         Average                     Max                         Std. Deviation              
elm3a69-             --------------------------- --------------------------- --------------------------- ----------------------------
elm3a69-clients-1      174.21/173.15   ( -0.62%)   174.83/174.13   ( -0.41%)   175.52/175.22   ( -0.17%)     0.39/0.50     ( -29.83%)
elm3a69-clients-1      173.73/173.94   (  0.12%)   175.10/174.35   ( -0.43%)   175.97/174.92   ( -0.60%)     0.52/0.22     (  57.76%)
elm3a69-clients-2      261.58/256.71   ( -1.90%)   299.03/301.13   (  0.70%)   319.82/318.36   ( -0.46%)    23.85/23.56    (   1.22%)
elm3a69-clients-4      312.55/308.88   ( -1.19%)   316.44/313.57   ( -0.92%)   319.31/316.10   ( -1.02%)     1.61/1.76     (  -9.28%)
elm3a69-
sysbench: unavailable

The patch makes SLUB and SLAB comparable on this machine. For example,
with 2 clients, it was previously a 4.24% regression and here it shows a
0.70% gain. However, the difference between kernels is within the standard
deviation of multiple runs so the only conclusion is to say that with the
patch the two allocators become comparable.

==
elm3b133:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-lameter)
elm3b133-             Min                         Average                     Max                         Std. Deviation              
elm3b133-             --------------------------- --------------------------- --------------------------- ----------------------------
elm3b133-clients-1       28.00/28.25    (  0.89%)    28.23/28.46    (  0.81%)    28.42/28.63    (  0.73%)     0.09/0.11     ( -22.52%)
elm3b133-clients-2       52.59/52.70    (  0.20%)    53.33/53.86    (  0.98%)    53.93/54.97    (  1.89%)     0.45/0.52     ( -16.18%)
elm3b133-clients-4      111.24/110.89   ( -0.31%)   112.75/114.51   (  1.53%)   114.07/115.77   (  1.46%)     0.78/1.38     ( -76.86%)
elm3b133-clients-8      110.03/110.13   (  0.09%)   110.57/110.99   (  0.38%)   111.06/111.55   (  0.44%)     0.25/0.33     ( -34.68%)
sysbench: unavailable

The patch is clearly a win on this machine. Regressions were between
3.7% and 5.6%. With the patch applied, it's mainly gains.

==
elm3b19:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-lameter)
elm3b19-             Min                         Average                     Max                         Std. Deviation              
elm3b19-             --------------------------- --------------------------- --------------------------- ----------------------------
elm3b19-clients-1      115.39/119.30   (  3.27%)   118.53/124.61   (  4.88%)   126.01/158.10   ( 20.29%)     2.79/8.61     (-208.87%)
elm3b19-clients-1      116.56/117.51   (  0.81%)   120.83/123.23   (  1.95%)   131.91/130.33   ( -1.21%)     3.68/3.24     (  11.85%)
elm3b19-clients-2      255.60/350.33   ( 27.04%)   345.43/365.53   (  5.50%)   366.62/375.17   (  2.28%)    27.64/7.05     (  74.49%)
elm3b19-clients-4      323.56/324.04   (  0.15%)   334.94/334.64   ( -0.09%)   344.60/339.71   ( -1.44%)     4.98/3.73     (  25.05%)
sysbench: unavalable

The patch is even more clearly a win on this machine for tbench. Went from
losses of between 0.9% and 6.8% to decent gains in some cases.

==
elm3b6:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-lameter)
elm3b6-             Min                         Average                     Max                         Std. Deviation              
elm3b6-             --------------------------- --------------------------- --------------------------- ----------------------------
elm3b6-clients-1      138.88/143.41   (  3.16%)   152.46/154.96   (  1.62%)   176.49/179.71   (  1.79%)    10.05/10.84    (  -7.88%)
elm3b6-clients-2      264.83/263.46   ( -0.52%)   289.35/290.40   (  0.36%)   316.65/337.88   (  6.28%)    12.49/19.85    ( -58.99%)
elm3b6-clients-4      704.21/642.25   ( -9.65%)   751.06/764.37   (  1.74%)   778.11/812.44   (  4.23%)    20.93/45.31    (-116.53%)
elm3b6-clients-8      635.54/650.29   (  2.27%)   732.18/745.58   (  1.80%)   799.16/794.92   ( -0.53%)    49.19/42.10    (  14.43%)
sysbench:http://www.csn.ul.ie/~mel/postings/tsysbench-20080213/elm3b6-comparison.ps

Again solid gains. Went from losses of around 2% to gains of of around
1%. sysbench is less clear cut but slub-lameter inches slightly ahead more
often than not versus slab.

==
gekko-lp1:TBench Throughput Comparisons (2.6.24.2-slab/2.6.24.2-slub-lameter)
gekko-lp1-             Min                         Average                     Max                         Std. Deviation              
gekko-lp1-             --------------------------- --------------------------- --------------------------- ----------------------------
gekko-lp1-clients-1      169.17/176.54   (  4.18%)   198.45/213.08   (  6.87%)   219.36/227.24   (  3.47%)    16.80/14.73    (  12.31%)
gekko-lp1-clients-2      308.51/319.39   (  3.41%)   323.06/329.19   (  1.86%)   333.15/337.09   (  1.17%)     7.04/4.43     (  37.10%)
gekko-lp1-clients-4      465.10/390.12   (-19.22%)   494.48/493.46   ( -0.21%)   508.70/516.23   (  1.46%)    11.28/33.51    (-196.97%)
gekko-lp1-clients-8      476.20/435.68   ( -9.30%)   494.68/505.39   (  2.12%)   504.11/513.86   (  1.90%)     8.89/16.92    ( -90.46%)
sysbench: unavailable

Once again, losses of up to 6% without the patch to gains of 6.8% with. Win.

==
gekko-lp4:TBench Throughput Comparisons (2.6.24.2-slab/2.6.24.2-slub-lameter)
gekko-lp4-             Min                         Average                     Max                         Std. Deviation              
gekko-lp4-             --------------------------- --------------------------- --------------------------- ----------------------------
gekko-lp4-clients-1      167.17/190.43   ( 12.21%)   167.96/190.72   ( 11.93%)   169.27/191.04   ( 11.40%)     0.42/0.18     (  58.78%)
gekko-lp4-clients-1      166.89/190.70   ( 12.48%)   167.88/191.25   ( 12.22%)   169.13/192.56   ( 12.17%)     0.47/0.52     (  -9.98%)
gekko-lp4-clients-2      250.79/300.33   ( 16.50%)   257.55/305.09   ( 15.58%)   260.71/309.14   ( 15.67%)     2.50/2.61     (  -4.49%)
gekko-lp4-clients-4      258.46/297.84   ( 13.22%)   259.18/303.32   ( 14.55%)   259.76/307.08   ( 15.41%)     0.44/2.62     (-494.48%)
sysbench: http://www.csn.ul.ie/~mel/postings/tsysbench-20080213/gekko-lp4-comparison.ps

Big gains here in tbench with the patch. Annoyingly, I find as I write this
I don't have tbench figures comparing slab with vanilla slub but I have no
reason to believe there is anything anomalous there. sysbench shows that SLUB
wins big over 2.6.24-slab on this machine although oddly it's only comparable
with 2.6.23-slab. The patch does not show any significant difference between
the two slub comparisons. So, on this machine the patch doesn't hurt.
==

bl6-13:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-lameter)
bl6-13-             Min                         Average                     Max                         Std. Deviation              
bl6-13-             --------------------------- --------------------------- --------------------------- ----------------------------
bl6-13-clients-1      178.31/164.15   ( -8.63%)   204.12/186.17   ( -9.64%)   265.64/230.74   (-15.12%)    24.44/19.71    (  19.35%)
bl6-13-clients-2      305.58/304.75   ( -0.27%)   346.98/341.09   ( -1.72%)   406.30/405.27   ( -0.25%)    19.77/25.33    ( -28.15%)
bl6-13-clients-4      868.05/839.52   ( -3.40%)   990.49/893.36   (-10.87%)  1054.08/970.95   ( -8.56%)    47.59/37.87    (  20.42%)
bl6-13-clients-8      927.69/770.35   (-20.42%)  1003.17/894.60   (-12.14%)  1030.28/930.52   (-10.72%)    23.46/33.32    ( -42.05%)
sysbench: http://www.csn.ul.ie/~mel/postings/tsysbench-20080213/bl6-13-comparison.ps

Even with the patch, tbench blows on this machine. Without the patch it was
between 7% and 21% regression though so it's still an improvement. It's
worth noting that this machine routinely shows up big difference between
kernel versions with all small benchmarks so it's hard to draw a conclusion
from tbench here. sysbench shows significant gains over 2.6.23-slab in all
cases. 2.6.24-slab is marginally better than slub and the patch makes no
big difference to sysbench on this machine. Like, gekko-lp4 - the patch
doesn't hurt.
==

elm3a203:TBench Throughput Comparisons (2.6.24-slab/2.6.24-slub-lameter)
elm3a203-             Min                         Average                     Max                         Std. Deviation              
elm3a203-             --------------------------- --------------------------- --------------------------- ----------------------------
elm3a203-clients-1      111.14/108.56   ( -2.37%)   112.46/109.65   ( -2.56%)   113.08/110.40   ( -2.43%)     0.50/0.38     (  23.06%)
elm3a203-clients-1      111.57/108.41   ( -2.91%)   112.64/109.63   ( -2.75%)   113.48/110.56   ( -2.64%)     0.49/0.50     (  -1.53%)
elm3a203-clients-2      148.50/144.59   ( -2.70%)   151.82/147.48   ( -2.94%)   153.75/149.10   ( -3.12%)     1.27/1.31     (  -2.91%)
elm3a203-clients-4      146.39/140.32   ( -4.32%)   148.80/142.32   ( -4.55%)   150.70/143.56   ( -4.97%)     0.87/0.87     (  -0.99%)
elm3a203-
sysbench: unavailable

SLUB is a loss on this machine but similar to bl6-13, it went from regressions
of 10-13% to regressions of 2-4% so it is still an improvement.

==

So at the end of all that, it is very clear that modifications to this path
are as not as clear-cut a win/loss as one might like. Despite the lack of
clarity, the patch appears to be a plus on the balance in many cases so

Acked-by: Mel Gorman <mel@csn.ul.ie>

> 4k allocations cannot optimally be handled by SLUB if we are restricted to 
> order 0 allocs because the fastpath only handles fractions of one 
> allocation unit and if the allocation unit is 4k then we only have one 
> object per slab.
> 
> Isnt there a way that we can make the page allocator handle PAGE_SIZEd 
> allocations in such a way that is competitive with the slab allocators? 
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
