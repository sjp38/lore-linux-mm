Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CFD606B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 03:33:55 -0400 (EDT)
Subject: Re: slab: setup allocators earlier in the boot sequence
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>
	 <1244770230.7172.4.camel@pasglop>  <1244779009.7172.52.camel@pasglop>
	 <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop>
	 <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
Content-Type: text/plain
Date: Fri, 12 Jun 2009 17:34:39 +1000
Message-Id: <1244792079.7172.74.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-12 at 09:16 +0300, Pekka J Enberg wrote:

> OK, I am not sure we actually need that. The thing is, no one is allowed 
> to use kmalloc() unless slab_is_available() returns true so we can just 
> grep for the latter and do something like the following patch. Does that 
> make powerpc boot nicely again? Ingo, I think this fixes the early irq 
> screams you were having too.
> 
> There's some more in s390 architecture code and some drivers (!) but I 
> left them out from this patch for now.

I don't like that approach at all. Fixing all the call sites... we are
changing things all over the place, we'll certainly miss some, and
honestly, it's none of the business of things like vmalloc to know about
things like what kmalloc flags are valid and when... 

Besides, by turning everything permanently to GFP_NOWAIT, you also
significantly increase the risk of failure of those allocations since
they can no longer ... wait :-) (And push things out to swap etc...)

I really believe this should be a slab internal thing, which is what my
patch does to a certain extent. IE. All callers need to care about is
KERNEL vs. ATOMIC and in some cases, NOIO or similar for filesystems
etc... but I don't think all sorts of kernel subsystems, because they
can be called early during boot, need to suddenly use GFP_NOWAIT all the
time.

That's why I much prefer my approach :-) (In addition to the fact that
it provides the basis for also fixing suspend/resume).

Cheers,
Ben.

> 			Pekka
> 
> >From fdade1bf17b6717c0de2b3f7c6a7d7bd82fc46db Mon Sep 17 00:00:00 2001
> From: Pekka Enberg <penberg@cs.helsinki.fi>
> Date: Fri, 12 Jun 2009 09:11:11 +0300
> Subject: [PATCH] init: Use GFP_NOWAIT for early slab allocations
> 
> We setup slab allocators very early now while interrupts can still be disabled.
> Therefore, make sure call-sites that use slab_is_available() to switch to slab
> during boot use GFP_NOWAIT.
> 
> Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> ---
>  include/linux/vmalloc.h |    1 +
>  kernel/params.c         |    2 +-
>  kernel/profile.c        |    6 +++---
>  mm/page_alloc.c         |    2 +-
>  mm/page_cgroup.c        |    4 ++--
>  mm/sparse-vmemmap.c     |    2 +-
>  mm/sparse.c             |    2 +-
>  mm/vmalloc.c            |   18 ++++++++++++++++++
>  8 files changed, 28 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index a43ebec..7bcb9d7 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -53,6 +53,7 @@ static inline void vmalloc_init(void)
>  extern void *vmalloc(unsigned long size);
>  extern void *vmalloc_user(unsigned long size);
>  extern void *vmalloc_node(unsigned long size, int node);
> +extern void *vmalloc_node_boot(unsigned long size, int node);
>  extern void *vmalloc_exec(unsigned long size);
>  extern void *vmalloc_32(unsigned long size);
>  extern void *vmalloc_32_user(unsigned long size);
> diff --git a/kernel/params.c b/kernel/params.c
> index de273ec..5c239c3 100644
> --- a/kernel/params.c
> +++ b/kernel/params.c
> @@ -227,7 +227,7 @@ int param_set_charp(const char *val, struct kernel_param *kp)
>  	 * don't need to; this mangled commandline is preserved. */
>  	if (slab_is_available()) {
>  		kp->perm |= KPARAM_KMALLOCED;
> -		*(char **)kp->arg = kstrdup(val, GFP_KERNEL);
> +		*(char **)kp->arg = kstrdup(val, GFP_NOWAIT);
>  		if (!kp->arg)
>  			return -ENOMEM;
>  	} else
> diff --git a/kernel/profile.c b/kernel/profile.c
> index 28cf26a..86ada09 100644
> --- a/kernel/profile.c
> +++ b/kernel/profile.c
> @@ -112,16 +112,16 @@ int __ref profile_init(void)
>  	prof_len = (_etext - _stext) >> prof_shift;
>  	buffer_bytes = prof_len*sizeof(atomic_t);
>  
> -	if (!alloc_cpumask_var(&prof_cpu_mask, GFP_KERNEL))
> +	if (!alloc_cpumask_var(&prof_cpu_mask, GFP_NOWAIT))
>  		return -ENOMEM;
>  
>  	cpumask_copy(prof_cpu_mask, cpu_possible_mask);
>  
> -	prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL);
> +	prof_buffer = kzalloc(buffer_bytes, GFP_NOWAIT);
>  	if (prof_buffer)
>  		return 0;
>  
> -	prof_buffer = alloc_pages_exact(buffer_bytes, GFP_KERNEL|__GFP_ZERO);
> +	prof_buffer = alloc_pages_exact(buffer_bytes, GFP_NOWAIT|__GFP_ZERO);
>  	if (prof_buffer)
>  		return 0;
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 17d5f53..7760ef9 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2903,7 +2903,7 @@ int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
>  		 * To use this new node's memory, further consideration will be
>  		 * necessary.
>  		 */
> -		zone->wait_table = vmalloc(alloc_size);
> +		zone->wait_table = __vmalloc(alloc_size, GFP_NOWAIT, PAGE_KERNEL);
>  	}
>  	if (!zone->wait_table)
>  		return -ENOMEM;
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 3dd4a90..c954e04 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -119,9 +119,9 @@ static int __init_refok init_section_page_cgroup(unsigned long pfn)
>  		table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
>  		if (slab_is_available()) {
>  			base = kmalloc_node(table_size,
> -					GFP_KERNEL | __GFP_NOWARN, nid);
> +					GFP_NOWAIT | __GFP_NOWARN, nid);
>  			if (!base)
> -				base = vmalloc_node(table_size, nid);
> +				base = vmalloc_node_boot(table_size, nid);
>  		} else {
>  			base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
>  				table_size,
> diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> index a13ea64..9df6d99 100644
> --- a/mm/sparse-vmemmap.c
> +++ b/mm/sparse-vmemmap.c
> @@ -49,7 +49,7 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
>  	/* If the main allocator is up use that, fallback to bootmem. */
>  	if (slab_is_available()) {
>  		struct page *page = alloc_pages_node(node,
> -				GFP_KERNEL | __GFP_ZERO, get_order(size));
> +				GFP_NOWAIT | __GFP_ZERO, get_order(size));
>  		if (page)
>  			return page_address(page);
>  		return NULL;
> diff --git a/mm/sparse.c b/mm/sparse.c
> index da432d9..dd558d2 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -63,7 +63,7 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>  				   sizeof(struct mem_section);
>  
>  	if (slab_is_available())
> -		section = kmalloc_node(array_size, GFP_KERNEL, nid);
> +		section = kmalloc_node(array_size, GFP_NOWAIT, nid);
>  	else
>  		section = alloc_bootmem_node(NODE_DATA(nid), array_size);
>  
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index f8189a4..3bec46d 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1559,6 +1559,24 @@ void *vmalloc_node(unsigned long size, int node)
>  }
>  EXPORT_SYMBOL(vmalloc_node);
>  
> +/**
> + *	vmalloc_node_boot  -  allocate memory on a specific node during boot
> + *	@size:		allocation size
> + *	@node:		numa node
> + *
> + *	Allocate enough pages to cover @size from the page level
> + *	allocator and map them into contiguous kernel virtual space.
> + *
> + *	For tight control over page level allocator and protection flags
> + *	use __vmalloc() instead.
> + */
> +void *vmalloc_node_boot(unsigned long size, int node)
> +{
> +	return __vmalloc_node(size, GFP_NOWAIT | __GFP_HIGHMEM, PAGE_KERNEL,
> +					node, __builtin_return_address(0));
> +}
> +EXPORT_SYMBOL(vmalloc_node_boot);
> +
>  #ifndef PAGE_KERNEL_EXEC
>  # define PAGE_KERNEL_EXEC PAGE_KERNEL
>  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
