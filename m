Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D2B73900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 13:08:05 -0400 (EDT)
Received: by iwg8 with SMTP id 8so9575011iwg.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:08:04 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: Re: [PATCH 1/3] rename alloc_pages_exact()
References: <20110411220345.9B95067C@kernel>
Date: Wed, 13 Apr 2011 02:07:38 +0900
In-Reply-To: <20110411220345.9B95067C@kernel> (Dave Hansen's message of "Mon,
	11 Apr 2011 15:03:45 -0700")
Message-ID: <87r597jt45.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, David Rientjes <rientjes@google.com>

Dave Hansen <dave@linux.vnet.ibm.com> writes:

> alloc_pages_exact() returns a virtual address.  But, alloc_pages() returns
> a 'struct page *'.  That makes for very confused kernel hackers.
>
> __get_free_pages(), on the other hand, returns virtual addresses.  That
> makes alloc_pages_exact() a much closer match to __get_free_pages(), so
> rename it to get_free_pages_exact().  Also change the arguments to have
> flags first, just like __get_free_pages().
>
> Note that alloc_pages_exact()'s partner, free_pages_exact() already
> matches free_pages(), so we do not have to touch the free side of things.
>
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Acked-by: David Rientjes <rientjes@google.com>
> ---
>
>  linux-2.6.git-dave/drivers/video/fsl-diu-fb.c  |    2 +-
>  linux-2.6.git-dave/drivers/video/mxsfb.c       |    2 +-
>  linux-2.6.git-dave/drivers/video/pxafb.c       |    6 +++---
>  linux-2.6.git-dave/drivers/virtio/virtio_pci.c |    2 +-
>  linux-2.6.git-dave/include/linux/gfp.h         |    2 +-
>  linux-2.6.git-dave/kernel/profile.c            |    4 ++--
>  linux-2.6.git-dave/mm/page_alloc.c             |   18 +++++++++---------
>  linux-2.6.git-dave/mm/page_cgroup.c            |    2 +-
>  8 files changed, 19 insertions(+), 19 deletions(-)
>
> diff -puN drivers/video/fsl-diu-fb.c~change-alloc_pages_exact-name drivers/video/fsl-diu-fb.c
> --- linux-2.6.git/drivers/video/fsl-diu-fb.c~change-alloc_pages_exact-name	2011-04-11 15:01:16.453823153 -0700
> +++ linux-2.6.git-dave/drivers/video/fsl-diu-fb.c	2011-04-11 15:01:16.489823137 -0700
> @@ -294,7 +294,7 @@ static void *fsl_diu_alloc(size_t size, 
>  
>  	pr_debug("size=%zu\n", size);
>  
> -	virt = alloc_pages_exact(size, GFP_DMA | __GFP_ZERO);
> +	virt = get_free_pages_exact(GFP_DMA | __GFP_ZERO, size);
>  	if (virt) {
>  		*phys = virt_to_phys(virt);
>  		pr_debug("virt=%p phys=%llx\n", virt,
> diff -puN drivers/video/mxsfb.c~change-alloc_pages_exact-name drivers/video/mxsfb.c
> --- linux-2.6.git/drivers/video/mxsfb.c~change-alloc_pages_exact-name	2011-04-11 15:01:16.457823151 -0700
> +++ linux-2.6.git-dave/drivers/video/mxsfb.c	2011-04-11 15:01:16.489823137 -0700
> @@ -718,7 +718,7 @@ static int __devinit mxsfb_init_fbinfo(s
>  	} else {
>  		if (!fb_size)
>  			fb_size = SZ_2M; /* default */
> -		fb_virt = alloc_pages_exact(fb_size, GFP_DMA);
> +		fb_virt = get_free_pages_exact(GFP_DMA, fb_size);
>  		if (!fb_virt)
>  			return -ENOMEM;
>  
> diff -puN drivers/video/pxafb.c~change-alloc_pages_exact-name drivers/video/pxafb.c
> --- linux-2.6.git/drivers/video/pxafb.c~change-alloc_pages_exact-name	2011-04-11 15:01:16.461823149 -0700
> +++ linux-2.6.git-dave/drivers/video/pxafb.c	2011-04-11 15:01:16.493823135 -0700
> @@ -905,8 +905,8 @@ static int __devinit pxafb_overlay_map_v
>  	/* We assume that user will use at most video_mem_size for overlay fb,
>  	 * anyway, it's useless to use 16bpp main plane and 24bpp overlay
>  	 */
> -	ofb->video_mem = alloc_pages_exact(PAGE_ALIGN(pxafb->video_mem_size),
> -		GFP_KERNEL | __GFP_ZERO);
> +	ofb->video_mem = get_free_pages_exact(GFP_KERNEL | __GFP_ZERO,
> +		PAGE_ALIGN(pxafb->video_mem_size));
>  	if (ofb->video_mem == NULL)
>  		return -ENOMEM;
>  
> @@ -1714,7 +1714,7 @@ static int __devinit pxafb_init_video_me
>  {
>  	int size = PAGE_ALIGN(fbi->video_mem_size);
>  
> -	fbi->video_mem = alloc_pages_exact(size, GFP_KERNEL | __GFP_ZERO);
> +	fbi->video_mem = get_free_pages_exact(GFP_KERNEL | __GFP_ZERO, size);
>  	if (fbi->video_mem == NULL)
>  		return -ENOMEM;
>  
> diff -puN drivers/virtio/virtio_pci.c~change-alloc_pages_exact-name drivers/virtio/virtio_pci.c
> --- linux-2.6.git/drivers/virtio/virtio_pci.c~change-alloc_pages_exact-name	2011-04-11 15:01:16.465823147 -0700
> +++ linux-2.6.git-dave/drivers/virtio/virtio_pci.c	2011-04-11 15:01:16.493823135 -0700
> @@ -385,7 +385,7 @@ static struct virtqueue *setup_vq(struct
>  	info->msix_vector = msix_vec;
>  
>  	size = PAGE_ALIGN(vring_size(num, VIRTIO_PCI_VRING_ALIGN));
> -	info->queue = alloc_pages_exact(size, GFP_KERNEL|__GFP_ZERO);
> +	info->queue = get_free_pages_exact(GFP_KERNEL|__GFP_ZERO, size);
>  	if (info->queue == NULL) {
>  		err = -ENOMEM;
>  		goto out_info;
> diff -puN include/linux/gfp.h~change-alloc_pages_exact-name include/linux/gfp.h
> --- linux-2.6.git/include/linux/gfp.h~change-alloc_pages_exact-name	2011-04-11 15:01:16.469823145 -0700
> +++ linux-2.6.git-dave/include/linux/gfp.h	2011-04-11 15:01:16.493823135 -0700
> @@ -351,7 +351,7 @@ extern struct page *alloc_pages_vma(gfp_
>  extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
>  extern unsigned long get_zeroed_page(gfp_t gfp_mask);
>  
> -void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
> +void *get_free_pages_exact(gfp_t gfp_mask, size_t size);
>  void free_pages_exact(void *virt, size_t size);
>  
>  #define __get_free_page(gfp_mask) \
> diff -puN kernel/profile.c~change-alloc_pages_exact-name kernel/profile.c
> --- linux-2.6.git/kernel/profile.c~change-alloc_pages_exact-name	2011-04-11 15:01:16.473823143 -0700
> +++ linux-2.6.git-dave/kernel/profile.c	2011-04-11 15:01:16.497823133 -0700
> @@ -121,8 +121,8 @@ int __ref profile_init(void)
>  	if (prof_buffer)
>  		return 0;
>  
> -	prof_buffer = alloc_pages_exact(buffer_bytes,
> -					GFP_KERNEL|__GFP_ZERO|__GFP_NOWARN);
> +	prof_buffer = get_free_pages_exact(GFP_KERNEL|__GFP_ZERO|__GFP_NOWARN,
> +					buffer_bytes);
>  	if (prof_buffer)
>  		return 0;
>  
> diff -puN mm/page_alloc.c~change-alloc_pages_exact-name mm/page_alloc.c
> --- linux-2.6.git/mm/page_alloc.c~change-alloc_pages_exact-name	2011-04-11 15:01:16.477823141 -0700
> +++ linux-2.6.git-dave/mm/page_alloc.c	2011-04-11 15:01:16.501823131 -0700
> @@ -2318,7 +2318,7 @@ void free_pages(unsigned long addr, unsi
>  EXPORT_SYMBOL(free_pages);
>  
>  /**
> - * alloc_pages_exact - allocate an exact number physically-contiguous pages.
> + * get_free_pages_exact - allocate an exact number physically-contiguous pages.
>   * @size: the number of bytes to allocate
>   * @gfp_mask: GFP flags for the allocation
>   *
> @@ -2330,7 +2330,7 @@ EXPORT_SYMBOL(free_pages);
>   *
>   * Memory allocated by this function must be released by free_pages_exact().
>   */
> -void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
> +void *get_free_pages_exact(gfp_t gfp_mask, size_t size)
>  {
>  	unsigned int order = get_order(size);
>  	unsigned long addr;
> @@ -2349,14 +2349,14 @@ void *alloc_pages_exact(size_t size, gfp
>  
>  	return (void *)addr;
>  }
> -EXPORT_SYMBOL(alloc_pages_exact);
> +EXPORT_SYMBOL(get_free_pages_exact);
>  
>  /**
> - * free_pages_exact - release memory allocated via alloc_pages_exact()
> - * @virt: the value returned by alloc_pages_exact.
> - * @size: size of allocation, same value as passed to alloc_pages_exact().
> + * free_pages_exact - release memory allocated via get_free_pages_exact()
> + * @virt: the value returned by get_free_pages_exact.
> + * @size: size of allocation, same value as passed to get_free_pages_exact().
>   *
> - * Release the memory allocated by a previous call to alloc_pages_exact.
> + * Release the memory allocated by a previous call to get_free_pages_exact().
>   */
>  void free_pages_exact(void *virt, size_t size)
>  {
> @@ -5308,10 +5308,10 @@ void *__init alloc_large_system_hash(con
>  			/*
>  			 * If bucketsize is not a power-of-two, we may free
>  			 * some pages at the end of hash table which
> -			 * alloc_pages_exact() automatically does
> +			 * get_free_pages_exact() automatically does
>  			 */
>  			if (get_order(size) < MAX_ORDER) {
> -				table = alloc_pages_exact(size, GFP_ATOMIC);
> +				table = get_free_pages_exact(size, GFP_ATOMIC);

This should be                  table = get_free_pages_exact(GFP_ATOMIC, size);

Thanks.


>  				kmemleak_alloc(table, size, 1, GFP_ATOMIC);
>  			}
>  		}
> diff -puN mm/page_cgroup.c~change-alloc_pages_exact-name mm/page_cgroup.c
> --- linux-2.6.git/mm/page_cgroup.c~change-alloc_pages_exact-name	2011-04-11 15:01:16.481823139 -0700
> +++ linux-2.6.git-dave/mm/page_cgroup.c	2011-04-11 15:01:16.501823131 -0700
> @@ -134,7 +134,7 @@ static void *__init_refok alloc_page_cgr
>  {
>  	void *addr = NULL;
>  
> -	addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN);
> +	addr = get_free_pages_exact(GFP_KERNEL | __GFP_NOWARN, size);
>  	if (addr)
>  		return addr;
>  
> _
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
