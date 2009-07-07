Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 188726B0082
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 02:26:13 -0400 (EDT)
Subject: Re: [RFC PATCH 2/3] kmemleak: Add callbacks to the bootmem
 allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090706105155.16051.59597.stgit@pc1117.cambridge.arm.com>
References: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
	 <20090706105155.16051.59597.stgit@pc1117.cambridge.arm.com>
Date: Tue, 07 Jul 2009 10:08:50 +0300
Message-Id: <1246950530.24285.7.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-07-06 at 11:51 +0100, Catalin Marinas wrote:
> This patch adds kmemleak_alloc/free callbacks to the bootmem allocator.
> This would allow scanning of such blocks and help avoiding a whole class
> of false positives and more kmemleak annotations.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>

Looks good to me!

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

But lets cc Johannes on this too.

> ---
>  mm/bootmem.c |   36 +++++++++++++++++++++++++++++-------
>  1 files changed, 29 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index d2a9ce9..18858ad 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -335,6 +335,8 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
>  {
>  	unsigned long start, end;
>  
> +	kmemleak_free(__va(physaddr));
> +
>  	start = PFN_UP(physaddr);
>  	end = PFN_DOWN(physaddr + size);
>  
> @@ -354,6 +356,8 @@ void __init free_bootmem(unsigned long addr, unsigned long size)
>  {
>  	unsigned long start, end;
>  
> +	kmemleak_free_part(__va(addr), size);
> +
>  	start = PFN_UP(addr);
>  	end = PFN_DOWN(addr + size);
>  
> @@ -597,7 +601,9 @@ restart:
>  void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
>  					unsigned long goal)
>  {
> -	return ___alloc_bootmem_nopanic(size, align, goal, 0);
> +	void *ptr =  ___alloc_bootmem_nopanic(size, align, goal, 0);
> +	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
> +	return ptr;
>  }
>  
>  static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
> @@ -631,7 +637,9 @@ static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
>  void * __init __alloc_bootmem(unsigned long size, unsigned long align,
>  			      unsigned long goal)
>  {
> -	return ___alloc_bootmem(size, align, goal, 0);
> +	void *ptr = ___alloc_bootmem(size, align, goal, 0);
> +	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
> +	return ptr;
>  }
>  
>  static void * __init ___alloc_bootmem_node(bootmem_data_t *bdata,
> @@ -669,10 +677,14 @@ static void * __init ___alloc_bootmem_node(bootmem_data_t *bdata,
>  void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
>  				   unsigned long align, unsigned long goal)
>  {
> +	void *ptr;
> +
>  	if (WARN_ON_ONCE(slab_is_available()))
>  		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
>  
> -	return ___alloc_bootmem_node(pgdat->bdata, size, align, goal, 0);
> +	ptr = ___alloc_bootmem_node(pgdat->bdata, size, align, goal, 0);
> +	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
> +	return ptr;
>  }
>  
>  #ifdef CONFIG_SPARSEMEM
> @@ -707,14 +719,18 @@ void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
>  		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
>  
>  	ptr = alloc_arch_preferred_bootmem(pgdat->bdata, size, align, goal, 0);
> +	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
>  	if (ptr)
>  		return ptr;
>  
>  	ptr = alloc_bootmem_core(pgdat->bdata, size, align, goal, 0);
> +	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
>  	if (ptr)
>  		return ptr;
>  
> -	return __alloc_bootmem_nopanic(size, align, goal);
> +	ptr = __alloc_bootmem_nopanic(size, align, goal);
> +	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
> +	return ptr;
>  }
>  
>  #ifndef ARCH_LOW_ADDRESS_LIMIT
> @@ -737,7 +753,9 @@ void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
>  void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
>  				  unsigned long goal)
>  {
> -	return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT);
> +	void *ptr =  ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT);
> +	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
> +	return ptr;
>  }
>  
>  /**
> @@ -758,9 +776,13 @@ void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
>  void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
>  				       unsigned long align, unsigned long goal)
>  {
> +	void *ptr;
> +
>  	if (WARN_ON_ONCE(slab_is_available()))
>  		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
>  
> -	return ___alloc_bootmem_node(pgdat->bdata, size, align,
> -				goal, ARCH_LOW_ADDRESS_LIMIT);
> +	ptr = ___alloc_bootmem_node(pgdat->bdata, size, align,
> +				    goal, ARCH_LOW_ADDRESS_LIMIT);
> +	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
> +	return ptr;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
