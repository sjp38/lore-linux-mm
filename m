Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4FD6B006E
	for <linux-mm@kvack.org>; Sat, 27 Dec 2014 02:17:32 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id r10so14103916pdi.9
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 23:17:32 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id ce14si43266832pdb.253.2014.12.26.23.17.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Dec 2014 23:17:30 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so14040518pdb.4
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 23:17:30 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Date: Sat, 27 Dec 2014 16:18:14 +0900 (KST)
Subject: Re: [PATCH 3/3] cma: add functions to get region pages counters
In-Reply-To: <dfddb08aba9a05e6e7b43e9861ab09b7ac1c89cd.1419602920.git.s.strogin@partner.samsung.com>
Message-ID: <alpine.DEB.2.10.1412271616450.1819@hxeon>
References: <cover.1419602920.git.s.strogin@partner.samsung.com> <dfddb08aba9a05e6e7b43e9861ab09b7ac1c89cd.1419602920.git.s.strogin@partner.samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Stefan I. Strogin" <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Safonov <d.safonov@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>

Hello,

On Fri, 26 Dec 2014, Stefan I. Strogin wrote:

> From: Dmitry Safonov <d.safonov@partner.samsung.com>
>
> Here are two functions that provide interface to compute/get used size
> and size of biggest free chunk in cma region.
> Added that information in cmainfo.
>
> Signed-off-by: Dmitry Safonov <d.safonov@partner.samsung.com>
> ---
> include/linux/cma.h |  2 ++
> mm/cma.c            | 34 ++++++++++++++++++++++++++++++++++
> 2 files changed, 36 insertions(+)
>
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index 9384ba6..855e6f2 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -18,6 +18,8 @@ struct cma;
> extern unsigned long totalcma_pages;
> extern phys_addr_t cma_get_base(struct cma *cma);
> extern unsigned long cma_get_size(struct cma *cma);
> +extern unsigned long cma_get_used(struct cma *cma);
> +extern unsigned long cma_get_maxchunk(struct cma *cma);
>
> extern int __init cma_declare_contiguous(phys_addr_t base,
> 			phys_addr_t size, phys_addr_t limit,
> diff --git a/mm/cma.c b/mm/cma.c
> index ffaea26..5e560ed 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -78,6 +78,36 @@ unsigned long cma_get_size(struct cma *cma)
> 	return cma->count << PAGE_SHIFT;
> }
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
> static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_order)
> {
> 	if (align_order <= cma->order_per_bit)
> @@ -591,6 +621,10 @@ static int s_show(struct seq_file *m, void *p)
> 	struct cma_buffer *cmabuf;
> 	struct stack_trace trace;
>
> +	seq_printf(m, "CMARegion stat: %8lu kB total, %8lu kB used, %8lu kB max contiguous chunk\n\n",

How about 'CMA Region' rather than 'CMARegion'?

> +		   cma_get_size(cma) >> 10,
> +		   cma_get_used(cma) >> 10,
> +		   cma_get_maxchunk(cma) >> 10);
> 	mutex_lock(&cma->list_lock);
>
> 	list_for_each_entry(cmabuf, &cma->buffers_list, list) {
> -- 
> 2.1.0
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
