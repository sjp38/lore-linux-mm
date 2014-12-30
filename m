Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id F055A6B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 21:26:29 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so18645032pab.14
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 18:26:29 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id d7si55712468pdf.238.2014.12.29.18.26.27
        for <linux-mm@kvack.org>;
        Mon, 29 Dec 2014 18:26:28 -0800 (PST)
Date: Tue, 30 Dec 2014 11:26:26 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/3] cma: add functions to get region pages counters
Message-ID: <20141230022625.GA4588@js1304-P5Q-DELUXE>
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
 <dfddb08aba9a05e6e7b43e9861ab09b7ac1c89cd.1419602920.git.s.strogin@partner.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dfddb08aba9a05e6e7b43e9861ab09b7ac1c89cd.1419602920.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Stefan I. Strogin" <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Safonov <d.safonov@partner.samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>

On Fri, Dec 26, 2014 at 05:39:04PM +0300, Stefan I. Strogin wrote:
> From: Dmitry Safonov <d.safonov@partner.samsung.com>
> 
> Here are two functions that provide interface to compute/get used size
> and size of biggest free chunk in cma region.
> Added that information in cmainfo.
> 
> Signed-off-by: Dmitry Safonov <d.safonov@partner.samsung.com>
> ---
>  include/linux/cma.h |  2 ++
>  mm/cma.c            | 34 ++++++++++++++++++++++++++++++++++
>  2 files changed, 36 insertions(+)
> 
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index 9384ba6..855e6f2 100644
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
> index ffaea26..5e560ed 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -78,6 +78,36 @@ unsigned long cma_get_size(struct cma *cma)
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
> +	return ret << (PAGE_SHIFT + cma->order_per_bit);
> +}
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
> +	return maxchunk << (PAGE_SHIFT + cma->order_per_bit);
> +}
> +
>  static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_order)
>  {
>  	if (align_order <= cma->order_per_bit)
> @@ -591,6 +621,10 @@ static int s_show(struct seq_file *m, void *p)
>  	struct cma_buffer *cmabuf;
>  	struct stack_trace trace;
>  
> +	seq_printf(m, "CMARegion stat: %8lu kB total, %8lu kB used, %8lu kB max contiguous chunk\n\n",
> +		   cma_get_size(cma) >> 10,
> +		   cma_get_used(cma) >> 10,
> +		   cma_get_maxchunk(cma) >> 10);
>  	mutex_lock(&cma->list_lock);
>  
>  	list_for_each_entry(cmabuf, &cma->buffers_list, list) {

Hello,

How about changing printing format like as meminfo or zoneinfo?

CMARegion #
Total: XXX
Used: YYY
MaxContig: ZZZ

It would help to parse information.

And, how about adding how many pages are used now as system pages?
You can implement it by iterating range of CMA region and checking
Buddy flag.

UsedBySystem = Total - UsedByCMA - freepageinCMARegion

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
