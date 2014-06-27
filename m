Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id E1EE46B0038
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 01:55:56 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id un15so4148516pbc.13
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 22:55:56 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id fb3si12771173pab.58.2014.06.26.22.55.54
        for <linux-mm@kvack.org>;
        Thu, 26 Jun 2014 22:55:56 -0700 (PDT)
Date: Fri, 27 Jun 2014 15:00:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC] mm: cma: move init_cma_reserved_pageblock to cma.c
Message-ID: <20140627060047.GB9511@js1304-P5Q-DELUXE>
References: <1403650082-10056-1-git-send-email-mina86@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1403650082-10056-1-git-send-email-mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Mark Salter <msalter@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On Wed, Jun 25, 2014 at 12:48:02AM +0200, Michal Nazarewicz wrote:
> With [f495d26: a??generalize CMA reserved area management
> functionalitya??] patch CMA has its place under mm directory now so
> there is no need to shoehorn a highly CMA specific functions inside of
> page_alloc.c.
> 
> As such move init_cma_reserved_pageblock from mm/page_alloc.c to
> mm/cma.c, rename it to cma_init_reserved_pageblock and refactor
> a little.
> 
> Most importantly, if a !pfn_valid(pfn) is encountered, just
> return -EINVAL instead of warning and trying to continue the
> initialisation of the area.  It's not clear, to me at least, what good
> is continuing the work on a PFN that is known to be invalid.
> 
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

One question below.

> ---
>  include/linux/gfp.h |  3 --
>  mm/cma.c            | 85 +++++++++++++++++++++++++++++++++++++++++------------
>  mm/page_alloc.c     | 31 -------------------
>  3 files changed, 66 insertions(+), 53 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 5e7219d..107793e9 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -415,9 +415,6 @@ extern int alloc_contig_range(unsigned long start, unsigned long end,
>  			      unsigned migratetype);
>  extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
>  
> -/* CMA stuff */
> -extern void init_cma_reserved_pageblock(struct page *page);
> -
>  #endif
>  
>  #endif /* __LINUX_GFP_H */
> diff --git a/mm/cma.c b/mm/cma.c
> index c17751c..843b2b6 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -28,11 +28,14 @@
>  #include <linux/err.h>
>  #include <linux/mm.h>
>  #include <linux/mutex.h>
> +#include <linux/page-isolation.h>
>  #include <linux/sizes.h>
>  #include <linux/slab.h>
>  #include <linux/log2.h>
>  #include <linux/cma.h>
>  
> +#include "internal.h"
> +
>  struct cma {
>  	unsigned long	base_pfn;
>  	unsigned long	count;
> @@ -83,37 +86,81 @@ static void cma_clear_bitmap(struct cma *cma, unsigned long pfn, int count)
>  	mutex_unlock(&cma->lock);
>  }
>  
> +/* Free whole pageblock and set its migration type to MIGRATE_CMA. */
> +static int __init cma_init_reserved_pageblock(struct zone *zone,
> +					      unsigned long pageblock_pfn)
> +{
> +	unsigned long pfn, nr_pages, i;
> +	struct page *page, *p;
> +	unsigned order;
> +
> +	pfn = pageblock_pfn;
> +	if (!pfn_valid(pfn))
> +		goto invalid_pfn;
> +	page = pfn_to_page(pfn);
> +
> +	p = page;
> +	i = pageblock_nr_pages;
> +	do {
> +		if (!pfn_valid(pfn))
> +			goto invalid_pfn;
> +
> +		/*
> +		 * alloc_contig_range requires the pfn range specified to be
> +		 * in the same zone. Make this simple by forcing the entire
> +		 * CMA resv range to be in the same zone.
> +		 */
> +		if (page_zone(p) != zone) {
> +			pr_err("pfn %lu belongs to %s, expecting %s\n",
> +			       pfn, page_zone(p)->name, zone->name);
> +			return -EINVAL;
> +		}
> +
> +		__ClearPageReserved(p);
> +		set_page_count(p, 0);
> +	} while (++p, ++pfn, --i);

So, when we meet fail condition, __ClearPageReserved, set_page_count()
are already executed for some pages. Is that no problem?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
