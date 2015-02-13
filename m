Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id CD63F6B0074
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 22:09:34 -0500 (EST)
Received: by pdno5 with SMTP id o5so16334123pdn.8
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 19:09:34 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id iu6si1099891pbc.180.2015.02.12.19.09.33
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 19:09:34 -0800 (PST)
Date: Fri, 13 Feb 2015 12:11:50 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/4] mm: cma: add functions to get region pages counters
Message-ID: <20150213031150.GI6592@js1304-P5Q-DELUXE>
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
 <c6a3312c9eb667f0f5330c313f328bc49f7addd9.1423777850.git.s.strogin@partner.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c6a3312c9eb667f0f5330c313f328bc49f7addd9.1423777850.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Safonov <d.safonov@partner.samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

On Fri, Feb 13, 2015 at 01:15:42AM +0300, Stefan Strogin wrote:
> From: Dmitry Safonov <d.safonov@partner.samsung.com>
> 
> Here are two functions that provide interface to compute/get used size
> and size of biggest free chunk in cma region.
> Add that information to debugfs.
> 
> Signed-off-by: Dmitry Safonov <d.safonov@partner.samsung.com>
> Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>
> ---
>  include/linux/cma.h |  2 ++
>  mm/cma.c            | 30 ++++++++++++++++++++++++++++++
>  mm/cma_debug.c      | 24 ++++++++++++++++++++++++
>  3 files changed, 56 insertions(+)
> 
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index 4c2c83c..54a2c4d 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -18,6 +18,8 @@ struct cma;
>  extern unsigned long totalcma_pages;
>  extern phys_addr_t cma_get_base(struct cma *cma);
>  extern unsigned long cma_get_size(struct cma *cma);
> +extern unsigned long cma_get_used(struct cma *cma);
> +extern unsigned long cma_get_maxchunk(struct cma *cma);
>  
>  extern int __init cma_declare_contiguous(phys_addr_t base,
>  			phys_addr_t size, phys_addr_t limit,
> diff --git a/mm/cma.c b/mm/cma.c
> index ed269b0..95e8121 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -54,6 +54,36 @@ unsigned long cma_get_size(struct cma *cma)
>  	return cma->count << PAGE_SHIFT;
>  }
>  
> +unsigned long cma_get_used(struct cma *cma)
> +{
> +	unsigned long ret = 0;
> +
> +	mutex_lock(&cma->lock);
> +	/* pages counter is smaller than sizeof(int) */
> +	ret = bitmap_weight(cma->bitmap, (int)cma->count);
> +	mutex_unlock(&cma->lock);
> +
> +	return ret;
> +}

Need to consider order_per_bit for returing number of page rather
than number of bits.

> +
> +unsigned long cma_get_maxchunk(struct cma *cma)
> +{
> +	unsigned long maxchunk = 0;
> +	unsigned long start, end = 0;
> +
> +	mutex_lock(&cma->lock);
> +	for (;;) {
> +		start = find_next_zero_bit(cma->bitmap, cma->count, end);
> +		if (start >= cma->count)
> +			break;
> +		end = find_next_bit(cma->bitmap, cma->count, start);
> +		maxchunk = max(end - start, maxchunk);
> +	}
> +	mutex_unlock(&cma->lock);
> +
> +	return maxchunk;
> +}
> +

Same here.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
