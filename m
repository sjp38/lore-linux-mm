Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ACD496B01AD
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 01:06:35 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o5R56VXn031916
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 22:06:32 -0700
Received: from pvc7 (pvc7.prod.google.com [10.241.209.135])
	by hpaq3.eem.corp.google.com with ESMTP id o5R56T8d027552
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 22:06:30 -0700
Received: by pvc7 with SMTP id 7so543340pvc.35
        for <linux-mm@kvack.org>; Sat, 26 Jun 2010 22:06:29 -0700 (PDT)
Date: Sat, 26 Jun 2010 22:06:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q 02/16] [PATCH 1/2] percpu: make @dyn_size always mean min
 dyn_size in first chunk init functions
In-Reply-To: <20100625212102.196049458@quilx.com>
Message-ID: <alpine.DEB.2.00.1006262155260.12531@chino.kir.corp.google.com>
References: <20100625212026.810557229@quilx.com> <20100625212102.196049458@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jun 2010, Christoph Lameter wrote:

> In pcpu_alloc_info()

You mean pcpu_build_alloc_info()?

This should have a "From: Tejun Heo <tj@kernel.org>" line, right?

> and pcpu_embed_first_chunk(), @dyn_size was
> ssize_t, -1 meant auto-size, 0 forced 0 and positive meant minimum
> size.  There's no use case for forcing 0 and the upcoming early alloc
> support always requires non-zero dynamic size.  Make @dyn_size always
> mean minimum dyn_size.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> Index: linux-2.6/include/linux/percpu.h
> ===================================================================
> --- linux-2.6.orig/include/linux/percpu.h	2010-06-18 12:23:22.000000000 -0500
> +++ linux-2.6/include/linux/percpu.h	2010-06-18 12:24:52.000000000 -0500
> @@ -105,7 +105,7 @@ extern struct pcpu_alloc_info * __init p
>  extern void __init pcpu_free_alloc_info(struct pcpu_alloc_info *ai);
>  
>  extern struct pcpu_alloc_info * __init pcpu_build_alloc_info(
> -				size_t reserved_size, ssize_t dyn_size,
> +				size_t reserved_size, size_t dyn_size,
>  				size_t atom_size,
>  				pcpu_fc_cpu_distance_fn_t cpu_distance_fn);
>  

This can just be removed entirely, it's unnecessarily global.

> @@ -113,7 +113,7 @@ extern int __init pcpu_setup_first_chunk
>  					 void *base_addr);
>  
>  #ifdef CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK
> -extern int __init pcpu_embed_first_chunk(size_t reserved_size, ssize_t dyn_size,
> +extern int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>  				size_t atom_size,
>  				pcpu_fc_cpu_distance_fn_t cpu_distance_fn,
>  				pcpu_fc_alloc_fn_t alloc_fn,
> Index: linux-2.6/mm/percpu.c
> ===================================================================
> --- linux-2.6.orig/mm/percpu.c	2010-06-18 11:20:35.000000000 -0500
> +++ linux-2.6/mm/percpu.c	2010-06-18 12:24:52.000000000 -0500
> @@ -988,20 +988,6 @@ phys_addr_t per_cpu_ptr_to_phys(void *ad
>  		return page_to_phys(pcpu_addr_to_page(addr));
>  }
>  
> -static inline size_t pcpu_calc_fc_sizes(size_t static_size,
> -					size_t reserved_size,
> -					ssize_t *dyn_sizep)
> -{
> -	size_t size_sum;
> -
> -	size_sum = PFN_ALIGN(static_size + reserved_size +
> -			     (*dyn_sizep >= 0 ? *dyn_sizep : 0));
> -	if (*dyn_sizep != 0)
> -		*dyn_sizep = size_sum - static_size - reserved_size;
> -
> -	return size_sum;
> -}
> -
>  /**
>   * pcpu_alloc_alloc_info - allocate percpu allocation info
>   * @nr_groups: the number of groups
> @@ -1060,7 +1046,7 @@ void __init pcpu_free_alloc_info(struct 
>  /**
>   * pcpu_build_alloc_info - build alloc_info considering distances between CPUs
>   * @reserved_size: the size of reserved percpu area in bytes
> - * @dyn_size: free size for dynamic allocation in bytes, -1 for auto
> + * @dyn_size: free size for dynamic allocation in bytes

It's the minimum free size, it's not necessarily the exact size due to 
round-up.

>   * @atom_size: allocation atom size
>   * @cpu_distance_fn: callback to determine distance between cpus, optional
>   *
> @@ -1079,7 +1065,7 @@ void __init pcpu_free_alloc_info(struct 
>   * failure, ERR_PTR value is returned.
>   */
>  struct pcpu_alloc_info * __init pcpu_build_alloc_info(
> -				size_t reserved_size, ssize_t dyn_size,
> +				size_t reserved_size, size_t dyn_size,
>  				size_t atom_size,
>  				pcpu_fc_cpu_distance_fn_t cpu_distance_fn)
>  {
> @@ -1098,13 +1084,15 @@ struct pcpu_alloc_info * __init pcpu_bui
>  	memset(group_map, 0, sizeof(group_map));
>  	memset(group_cnt, 0, sizeof(group_map));
>  
> +	size_sum = PFN_ALIGN(static_size + reserved_size + dyn_size);
> +	dyn_size = size_sum - static_size - reserved_size;

Ok, so the only purpose of "dyn_size" is to store in the struct 
pcpu_alloc_info later.  Before this patch, ai->dyn_size would always be 0 
if that's what was passed to pcpu_build_alloc_info(), but due to this 
arithmetic it now requires that static_size + reserved_size to be pfn 
aligned.  Where is that enforced or do we not care?

> +
>  	/*
>  	 * Determine min_unit_size, alloc_size and max_upa such that
>  	 * alloc_size is multiple of atom_size and is the smallest
>  	 * which can accomodate 4k aligned segments which are equal to
>  	 * or larger than min_unit_size.
>  	 */
> -	size_sum = pcpu_calc_fc_sizes(static_size, reserved_size, &dyn_size);
>  	min_unit_size = max_t(size_t, size_sum, PCPU_MIN_UNIT_SIZE);
>  
>  	alloc_size = roundup(min_unit_size, atom_size);
> @@ -1508,7 +1496,7 @@ early_param("percpu_alloc", percpu_alloc
>  /**
>   * pcpu_embed_first_chunk - embed the first percpu chunk into bootmem
>   * @reserved_size: the size of reserved percpu area in bytes
> - * @dyn_size: free size for dynamic allocation in bytes, -1 for auto
> + * @dyn_size: minimum free size for dynamic allocation in bytes
>   * @atom_size: allocation atom size
>   * @cpu_distance_fn: callback to determine distance between cpus, optional
>   * @alloc_fn: function to allocate percpu page
> @@ -1529,10 +1517,7 @@ early_param("percpu_alloc", percpu_alloc
>   * vmalloc space is not orders of magnitude larger than distances
>   * between node memory addresses (ie. 32bit NUMA machines).
>   *
> - * When @dyn_size is positive, dynamic area might be larger than
> - * specified to fill page alignment.  When @dyn_size is auto,
> - * @dyn_size is just big enough to fill page alignment after static
> - * and reserved areas.
> + * @dyn_size specifies the minimum dynamic area size.
>   *
>   * If the needed size is smaller than the minimum or specified unit
>   * size, the leftover is returned using @free_fn.
> @@ -1540,7 +1525,7 @@ early_param("percpu_alloc", percpu_alloc
>   * RETURNS:
>   * 0 on success, -errno on failure.
>   */
> -int __init pcpu_embed_first_chunk(size_t reserved_size, ssize_t dyn_size,
> +int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>  				  size_t atom_size,
>  				  pcpu_fc_cpu_distance_fn_t cpu_distance_fn,
>  				  pcpu_fc_alloc_fn_t alloc_fn,
> @@ -1671,7 +1656,7 @@ int __init pcpu_page_first_chunk(size_t 
>  
>  	snprintf(psize_str, sizeof(psize_str), "%luK", PAGE_SIZE >> 10);
>  
> -	ai = pcpu_build_alloc_info(reserved_size, -1, PAGE_SIZE, NULL);
> +	ai = pcpu_build_alloc_info(reserved_size, 0, PAGE_SIZE, NULL);
>  	if (IS_ERR(ai))
>  		return PTR_ERR(ai);
>  	BUG_ON(ai->nr_groups != 1);
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
