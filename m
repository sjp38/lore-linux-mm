Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1E883900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 03:40:21 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so131009pab.18
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 00:40:20 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id xp2si40740615pbc.57.2014.06.12.00.40.19
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 00:40:20 -0700 (PDT)
Date: Thu, 12 Jun 2014 16:40:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 10/10] mm, cma: use spinlock instead of mutex
Message-ID: <20140612074029.GB12663@bbox>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-11-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402543307-29800-11-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, Jun 12, 2014 at 12:21:47PM +0900, Joonsoo Kim wrote:
> Currently, we should take the mutex for manipulating bitmap.
> This job may be really simple and short so we don't need to sleep
> if contended. So I change it to spinlock.

I'm not sure it would be good always.
Maybe you remember we discussed about similar stuff about bitmap
searching in vmap friend internally, which was really painful
when it was fragmented. So, at least we need number if you really want
and I hope the number from ARM machine most popular platform for CMA
at the moment.

> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> diff --git a/mm/cma.c b/mm/cma.c
> index 22a5b23..3085e8c 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -27,6 +27,7 @@
>  #include <linux/memblock.h>
>  #include <linux/err.h>
>  #include <linux/mm.h>
> +#include <linux/spinlock.h>
>  #include <linux/mutex.h>
>  #include <linux/sizes.h>
>  #include <linux/slab.h>
> @@ -36,7 +37,7 @@ struct cma {
>  	unsigned long	count;
>  	unsigned long	*bitmap;
>  	int order_per_bit; /* Order of pages represented by one bit */
> -	struct mutex	lock;
> +	spinlock_t	lock;
>  };
>  
>  /*
> @@ -72,9 +73,9 @@ static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int count)
>  	bitmapno = (pfn - cma->base_pfn) >> cma->order_per_bit;
>  	nr_bits = cma_bitmap_pages_to_bits(cma, count);
>  
> -	mutex_lock(&cma->lock);
> +	spin_lock(&cma->lock);
>  	bitmap_clear(cma->bitmap, bitmapno, nr_bits);
> -	mutex_unlock(&cma->lock);
> +	spin_unlock(&cma->lock);
>  }
>  
>  static int __init cma_activate_area(struct cma *cma)
> @@ -112,7 +113,7 @@ static int __init cma_activate_area(struct cma *cma)
>  		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
>  	} while (--i);
>  
> -	mutex_init(&cma->lock);
> +	spin_lock_init(&cma->lock);
>  	return 0;
>  
>  err:
> @@ -261,11 +262,11 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
>  	nr_bits = cma_bitmap_pages_to_bits(cma, count);
>  
>  	for (;;) {
> -		mutex_lock(&cma->lock);
> +		spin_lock(&cma->lock);
>  		bitmapno = bitmap_find_next_zero_area(cma->bitmap,
>  					bitmap_maxno, start, nr_bits, mask);
>  		if (bitmapno >= bitmap_maxno) {
> -			mutex_unlock(&cma->lock);
> +			spin_unlock(&cma->lock);
>  			break;
>  		}
>  		bitmap_set(cma->bitmap, bitmapno, nr_bits);
> @@ -274,7 +275,7 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
>  		 * our exclusive use. If the migration fails we will take the
>  		 * lock again and unmark it.
>  		 */
> -		mutex_unlock(&cma->lock);
> +		spin_unlock(&cma->lock);
>  
>  		pfn = cma->base_pfn + (bitmapno << cma->order_per_bit);
>  		mutex_lock(&cma_mutex);
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
