Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 3AEB66B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 01:28:40 -0400 (EDT)
Message-ID: <4FEA9A0D.4020000@kernel.org>
Date: Wed, 27 Jun 2012 14:28:45 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] zsmalloc: add generic path and remove x86 dependency
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1340640878-27536-3-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 06/26/2012 01:14 AM, Seth Jennings wrote:

> This patch adds generic pages mapping methods that
> work on all archs in the absence of support for
> local_tlb_flush_kernel_range() advertised by the
> arch through __HAVE_LOCAL_TLB_FLUSH_KERNEL_RANGE
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>


Sorry for handling this issue recently.
I like the patch.
Some comment below.

> ---
>  drivers/staging/zsmalloc/Kconfig         |    4 -
>  drivers/staging/zsmalloc/zsmalloc-main.c |  136 ++++++++++++++++++++++++------
>  drivers/staging/zsmalloc/zsmalloc_int.h  |    5 +-
>  3 files changed, 115 insertions(+), 30 deletions(-)
> 
> diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
> index a5ab720..9084565 100644
> --- a/drivers/staging/zsmalloc/Kconfig
> +++ b/drivers/staging/zsmalloc/Kconfig
> @@ -1,9 +1,5 @@
>  config ZSMALLOC
>  	tristate "Memory allocator for compressed pages"
> -	# X86 dependency is because of the use of __flush_tlb_one and set_pte
> -	# in zsmalloc-main.c.
> -	# TODO: convert these to portable functions
> -	depends on X86
>  	default n
>  	help
>  	  zsmalloc is a slab-based memory allocator designed to store
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index 10b0d60..14f04d8 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -470,28 +470,116 @@ static struct page *find_get_zspage(struct size_class *class)
>  	return page;
>  }
>  
> +#ifdef __HAVE_LOCAL_FLUSH_TLB_KERNEL_RANGE


As you already mentioned, __HAVE_ARCH_LOCAL_XXX

> +static inline int zs_arch_cpu_up(struct mapping_area *area)


Why should function's name represent arch dependent?
IMHO, it would be better to use just zs_cpu_up.


> +{
> +	if (area->vm)
> +		return 0;


Just out of curiosity.
When do we need above check?

> +	area->vm = alloc_vm_area(PAGE_SIZE * 2, NULL);
> +	if (!area->vm)
> +		return -ENOMEM;
> +	return 0;
> +}
> +
> +static inline void zs_arch_cpu_down(struct mapping_area *area)


Ditto.

> +{
> +	if (area->vm)
> +		free_vm_area(area->vm);
> +	area->vm = NULL;
> +}
> +
> +static inline void zs_arch_map_object(struct mapping_area *area,
> +				struct page *pages[2], int off, int size)
> +{
> +	BUG_ON(map_vm_area(area->vm, PAGE_KERNEL, &pages));


I think we need some comment about why map_vm_area must not fail.
I used below comment in my patch.
+               /*
+                * map_vm_area never fail because we already allocated
+                * pages for page table in alloc_vm_area.
+                */

> +	area->vm_addr = area->vm->addr;
> +}
> +
> +static inline void zs_arch_unmap_object(struct mapping_area *area,
> +				struct page *pages[2], int off, int size)
> +{
> +	unsigned long addr = (unsigned long)area->vm_addr;
> +	unsigned long end = addr + (PAGE_SIZE * 2);
> +
> +	flush_cache_vunmap(addr, end);
> +	unmap_kernel_range_noflush(addr, PAGE_SIZE * 2);
> +	local_flush_tlb_kernel_range(addr, end);
> +}
> +#else
> +static inline int zs_arch_cpu_up(struct mapping_area *area)
> +{
> +	if (area->vm_buf)
> +		return 0;
> +	area->vm_buf = (char *)__get_free_pages(GFP_KERNEL, 1);

> +	if (!area->vm_buf)

> +		return -ENOMEM;
> +	return 0;
> +}
> +
> +static inline void zs_arch_cpu_down(struct mapping_area *area)
> +{
> +	if (area->vm_buf)
> +		free_pages((unsigned long)area->vm_buf, 1);
> +	area->vm_buf = NULL;
> +}
> +
> +static void zs_arch_map_object(struct mapping_area *area,
> +				struct page *pages[2], int off, int size)


How about just void __zs_map_object?
Anyway, it's just preference and I am not strong against.

> +{
> +	int sizes[2];
> +	char *buf = area->vm_buf + off;
> +	void *addr;
> +
> +	sizes[0] = PAGE_SIZE - off;
> +	sizes[1] = size - sizes[0];
> +
> +	/* copy object to temp buffer */
> +	addr = kmap_atomic(pages[0]);
> +	memcpy(buf, addr + off, sizes[0]);
> +	kunmap_atomic(addr);
> +	addr = kmap_atomic(pages[1]);
> +	memcpy(buf + sizes[0], addr, sizes[1]);
> +	kunmap_atomic(addr);
> +	area->vm_addr = area->vm_buf;
> +}
> +
> +static void zs_arch_unmap_object(struct mapping_area *area,
> +				struct page *pages[2], int off, int size)
> +{
> +	int sizes[2];
> +	char *buf = area->vm_buf + off;
> +	void *addr;
> +
> +	sizes[0] = PAGE_SIZE - off;
> +	sizes[1] = size - sizes[0];
> +
> +	/* copy temp buffer to obj*/
> +	addr = kmap_atomic(pages[0]);
> +	memcpy(addr + off, buf, sizes[0]);
> +	kunmap_atomic(addr);
> +	addr = kmap_atomic(pages[1]);
> +	memcpy(addr, buf + sizes[0], sizes[1]);
> +	kunmap_atomic(addr);
> +}
> +#endif
>  
>  static int zs_cpu_notifier(struct notifier_block *nb, unsigned long action,
>  				void *pcpu)
>  {
> -	int cpu = (long)pcpu;
> +	int ret, cpu = (long)pcpu;
>  	struct mapping_area *area;
>  
>  	switch (action) {
>  	case CPU_UP_PREPARE:
>  		area = &per_cpu(zs_map_area, cpu);
> -		if (area->vm)
> -			break;
> -		area->vm = alloc_vm_area(2 * PAGE_SIZE, area->vm_ptes);
> -		if (!area->vm)
> -			return notifier_from_errno(-ENOMEM);
> +		ret = zs_arch_cpu_up(area);
> +		if (ret)
> +			return notifier_from_errno(ret);
>  		break;
>  	case CPU_DEAD:
>  	case CPU_UP_CANCELED:
>  		area = &per_cpu(zs_map_area, cpu);
> -		if (area->vm)
> -			free_vm_area(area->vm);
> -		area->vm = NULL;
> +		zs_arch_cpu_down(area);
>  		break;
>  	}
>  
> @@ -716,19 +804,14 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle)
>  		area->vm_addr = kmap_atomic(page);
>  	} else {
>  		/* this object spans two pages */
> -		struct page *nextp;
> -
> -		nextp = get_next_page(page);
> -		BUG_ON(!nextp);
> +		struct page *pages[2];
>  
> +		pages[0] = page;
> +		pages[1] = get_next_page(page);
> +		BUG_ON(!pages[1]);
>  
> -		set_pte(area->vm_ptes[0], mk_pte(page, PAGE_KERNEL));
> -		set_pte(area->vm_ptes[1], mk_pte(nextp, PAGE_KERNEL));
> -
> -		/* We pre-allocated VM area so mapping can never fail */
> -		area->vm_addr = area->vm->addr;
> +		zs_arch_map_object(area, pages, off, class->size);
>  	}
> -
>  	return area->vm_addr + off;
>  }
>  EXPORT_SYMBOL_GPL(zs_map_object);
> @@ -751,13 +834,16 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
>  	off = obj_idx_to_offset(page, obj_idx, class->size);
>  
>  	area = &__get_cpu_var(zs_map_area);
> -	if (off + class->size <= PAGE_SIZE) {
> +	if (off + class->size <= PAGE_SIZE)
>  		kunmap_atomic(area->vm_addr);
> -	} else {
> -		set_pte(area->vm_ptes[0], __pte(0));
> -		set_pte(area->vm_ptes[1], __pte(0));
> -		__flush_tlb_one((unsigned long)area->vm_addr);
> -		__flush_tlb_one((unsigned long)area->vm_addr + PAGE_SIZE);
> +	else {
> +		struct page *pages[2];
> +
> +		pages[0] = page;
> +		pages[1] = get_next_page(page);
> +		BUG_ON(!pages[1]);
> +
> +		zs_arch_unmap_object(area, pages, off, class->size);
>  	}
>  	put_cpu_var(zs_map_area);
>  }
> diff --git a/drivers/staging/zsmalloc/zsmalloc_int.h b/drivers/staging/zsmalloc/zsmalloc_int.h
> index 6fd32a9..8a6887e 100644
> --- a/drivers/staging/zsmalloc/zsmalloc_int.h
> +++ b/drivers/staging/zsmalloc/zsmalloc_int.h
> @@ -110,8 +110,11 @@ enum fullness_group {
>  static const int fullness_threshold_frac = 4;
>  
>  struct mapping_area {
> +#ifdef __HAVE_LOCAL_FLUSH_TLB_KERNEL_RANGE
>  	struct vm_struct *vm;
> -	pte_t *vm_ptes[2];
> +#else
> +	char *vm_buf;
> +#endif
>  	char *vm_addr;
>  };


Need comment about vm_buf and vm_addr.

Thanks, Seth.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
