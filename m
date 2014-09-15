Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5E86B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 02:57:51 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so5800837pad.14
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 23:57:51 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id j5si20911311pdk.197.2014.09.14.23.57.49
        for <linux-mm@kvack.org>;
        Sun, 14 Sep 2014 23:57:50 -0700 (PDT)
Date: Mon, 15 Sep 2014 15:57:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC V2] Free the reserved memblock when free cma pages
Message-ID: <20140915065759.GM2160@bbox>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
 <20140915052151.GI2160@bbox>
 <35FD53F367049845BC99AC72306C23D103D6DB4915FD@CNBJMBX05.corpusers.net>
 <20140915054236.GJ2160@bbox>
 <35FD53F367049845BC99AC72306C23D103D6DB4915FF@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB4915FF@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: "'mhocko@suse.cz'" <mhocko@suse.cz>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "hughd@google.com" <hughd@google.com>, "b.zolnierkie@samsung.com" <b.zolnierkie@samsung.com>

On Mon, Sep 15, 2014 at 02:10:19PM +0800, Wang, Yalin wrote:
> This patch add memblock_free to also free the reserved memblock,
> so that the cma pages are not marked as reserved memory in
> /sys/kernel/debug/memblock/reserved debug file

If you received some comments and judges the direction is right,
you could remove RFC tag from the patch title.


> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>

Anyway,
Acked-by: Minchan Kim <minchan@kernel.org>

>
> ---
>  mm/cma.c        | 6 +++++-
>  mm/page_alloc.c | 2 +-
>  2 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/cma.c b/mm/cma.c
> index c17751c..ec69c69 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -196,7 +196,11 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  	if (!IS_ALIGNED(size >> PAGE_SHIFT, 1 << order_per_bit))
>  		return -EINVAL;
>  
> -	/* Reserve memory */
> +	/*
> +	 * Reserve memory, and the reserved memory are marked as reserved by
> +	 * memblock driver, remember to clear the reserved status when free
> +	 * these cma pages, see init_cma_reserved_pageblock()
> +	 */
>  	if (base && fixed) {
>  		if (memblock_is_region_reserved(base, size) ||
>  		    memblock_reserve(base, size) < 0) {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 18cee0d..fffbb84 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -836,8 +836,8 @@ void __init init_cma_reserved_pageblock(struct page *page)
>  		set_page_refcounted(page);
>  		__free_pages(page, pageblock_order);
>  	}
> -
>  	adjust_managed_page_count(page, pageblock_nr_pages);
> +	memblock_free(page_to_phys(page), pageblock_nr_pages << PAGE_SHIFT);
>  }
>  #endif
>  
> -- 
> 2.1.0
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
