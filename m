Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA586B0031
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 06:09:38 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so2882885pdj.19
        for <linux-mm@kvack.org>; Sat, 14 Jun 2014 03:09:37 -0700 (PDT)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id xm4si4884556pbc.45.2014.06.14.03.09.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Jun 2014 03:09:37 -0700 (PDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 14 Jun 2014 20:09:34 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id C06603578047
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 20:09:32 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5EA9Git11469160
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 20:09:17 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5EA9WUB001953
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 20:09:32 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 05/10] DMA, CMA: support arbitrary bitmap granularity
In-Reply-To: <1402543307-29800-6-git-send-email-iamjoonsoo.kim@lge.com>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com> <1402543307-29800-6-git-send-email-iamjoonsoo.kim@lge.com>
Date: Sat, 14 Jun 2014 15:39:25 +0530
Message-ID: <87d2ebg5uy.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> ppc kvm's cma region management requires arbitrary bitmap granularity,
> since they want to reserve very large memory and manage this region
> with bitmap that one bit for several pages to reduce management overheads.
> So support arbitrary bitmap granularity for following generalization.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

>
> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> index bc4c171..9bc9340 100644
> --- a/drivers/base/dma-contiguous.c
> +++ b/drivers/base/dma-contiguous.c
> @@ -38,6 +38,7 @@ struct cma {
>  	unsigned long	base_pfn;
>  	unsigned long	count;
>  	unsigned long	*bitmap;
> +	int order_per_bit; /* Order of pages represented by one bit */
>  	struct mutex	lock;
>  };
>
> @@ -157,9 +158,38 @@ void __init dma_contiguous_reserve(phys_addr_t limit)
>
>  static DEFINE_MUTEX(cma_mutex);
>
> +static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_order)
> +{
> +	return (1 << (align_order >> cma->order_per_bit)) - 1;
> +}
> +
> +static unsigned long cma_bitmap_maxno(struct cma *cma)
> +{
> +	return cma->count >> cma->order_per_bit;
> +}
> +
> +static unsigned long cma_bitmap_pages_to_bits(struct cma *cma,
> +						unsigned long pages)
> +{
> +	return ALIGN(pages, 1 << cma->order_per_bit) >> cma->order_per_bit;
> +}
> +
> +static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int count)
> +{
> +	unsigned long bitmapno, nr_bits;
> +
> +	bitmapno = (pfn - cma->base_pfn) >> cma->order_per_bit;
> +	nr_bits = cma_bitmap_pages_to_bits(cma, count);
> +
> +	mutex_lock(&cma->lock);
> +	bitmap_clear(cma->bitmap, bitmapno, nr_bits);
> +	mutex_unlock(&cma->lock);
> +}
> +
>  static int __init cma_activate_area(struct cma *cma)
>  {
> -	int bitmap_size = BITS_TO_LONGS(cma->count) * sizeof(long);
> +	int bitmap_maxno = cma_bitmap_maxno(cma);
> +	int bitmap_size = BITS_TO_LONGS(bitmap_maxno) * sizeof(long);
>  	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
>  	unsigned i = cma->count >> pageblock_order;
>  	struct zone *zone;
> @@ -221,6 +251,7 @@ core_initcall(cma_init_reserved_areas);
>   * @base: Base address of the reserved area optional, use 0 for any
>   * @limit: End address of the reserved memory (optional, 0 for any).
>   * @alignment: Alignment for the contiguous memory area, should be power of 2
> + * @order_per_bit: Order of pages represented by one bit on bitmap.
>   * @res_cma: Pointer to store the created cma region.
>   * @fixed: hint about where to place the reserved area
>   *
> @@ -235,7 +266,7 @@ core_initcall(cma_init_reserved_areas);
>   */
>  static int __init __dma_contiguous_reserve_area(phys_addr_t size,
>  				phys_addr_t base, phys_addr_t limit,
> -				phys_addr_t alignment,
> +				phys_addr_t alignment, int order_per_bit,
>  				struct cma **res_cma, bool fixed)
>  {
>  	struct cma *cma = &cma_areas[cma_area_count];
> @@ -269,6 +300,8 @@ static int __init __dma_contiguous_reserve_area(phys_addr_t size,
>  	base = ALIGN(base, alignment);
>  	size = ALIGN(size, alignment);
>  	limit &= ~(alignment - 1);
> +	/* size should be aligned with order_per_bit */
> +	BUG_ON(!IS_ALIGNED(size >> PAGE_SHIFT, 1 << order_per_bit));
>
>  	/* Reserve memory */
>  	if (base && fixed) {
> @@ -294,6 +327,7 @@ static int __init __dma_contiguous_reserve_area(phys_addr_t size,
>  	 */
>  	cma->base_pfn = PFN_DOWN(base);
>  	cma->count = size >> PAGE_SHIFT;
> +	cma->order_per_bit = order_per_bit;
>  	*res_cma = cma;
>  	cma_area_count++;
>
> @@ -313,7 +347,7 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
>  {
>  	int ret;
>
> -	ret = __dma_contiguous_reserve_area(size, base, limit, 0,
> +	ret = __dma_contiguous_reserve_area(size, base, limit, 0, 0,
>  						res_cma, fixed);
>  	if (ret)
>  		return ret;
> @@ -324,13 +358,6 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
>  	return 0;
>  }
>
> -static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int count)
> -{
> -	mutex_lock(&cma->lock);
> -	bitmap_clear(cma->bitmap, pfn - cma->base_pfn, count);
> -	mutex_unlock(&cma->lock);
> -}
> -
>  /**
>   * dma_alloc_from_contiguous() - allocate pages from contiguous area
>   * @dev:   Pointer to device for which the allocation is performed.
> @@ -345,7 +372,8 @@ static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int count)
>  static struct page *__dma_alloc_from_contiguous(struct cma *cma, int count,
>  				       unsigned int align)
>  {
> -	unsigned long mask, pfn, pageno, start = 0;
> +	unsigned long mask, pfn, start = 0;
> +	unsigned long bitmap_maxno, bitmapno, nr_bits;
>  	struct page *page = NULL;
>  	int ret;
>
> @@ -358,18 +386,19 @@ static struct page *__dma_alloc_from_contiguous(struct cma *cma, int count,
>  	if (!count)
>  		return NULL;
>
> -	mask = (1 << align) - 1;
> -
> +	mask = cma_bitmap_aligned_mask(cma, align);
> +	bitmap_maxno = cma_bitmap_maxno(cma);
> +	nr_bits = cma_bitmap_pages_to_bits(cma, count);
>
>  	for (;;) {
>  		mutex_lock(&cma->lock);
> -		pageno = bitmap_find_next_zero_area(cma->bitmap, cma->count,
> -						    start, count, mask);
> -		if (pageno >= cma->count) {
> +		bitmapno = bitmap_find_next_zero_area(cma->bitmap,
> +					bitmap_maxno, start, nr_bits, mask);
> +		if (bitmapno >= bitmap_maxno) {
>  			mutex_unlock(&cma->lock);
>  			break;
>  		}
> -		bitmap_set(cma->bitmap, pageno, count);
> +		bitmap_set(cma->bitmap, bitmapno, nr_bits);
>  		/*
>  		 * It's safe to drop the lock here. We've marked this region for
>  		 * our exclusive use. If the migration fails we will take the
> @@ -377,7 +406,7 @@ static struct page *__dma_alloc_from_contiguous(struct cma *cma, int count,
>  		 */
>  		mutex_unlock(&cma->lock);
>
> -		pfn = cma->base_pfn + pageno;
> +		pfn = cma->base_pfn + (bitmapno << cma->order_per_bit);
>  		mutex_lock(&cma_mutex);
>  		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
>  		mutex_unlock(&cma_mutex);
> @@ -392,7 +421,7 @@ static struct page *__dma_alloc_from_contiguous(struct cma *cma, int count,
>  		pr_debug("%s(): memory range at %p is busy, retrying\n",
>  			 __func__, pfn_to_page(pfn));
>  		/* try again with a bit different memory target */
> -		start = pageno + mask + 1;
> +		start = bitmapno + mask + 1;
>  	}
>
>  	pr_debug("%s(): returned %p\n", __func__, page);
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
