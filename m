Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D9EA66B0009
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 05:45:32 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p63so11103390wmp.1
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 02:45:32 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id bj10si27465422wjc.110.2016.01.30.02.45.26
        for <linux-mm@kvack.org>;
        Sat, 30 Jan 2016 02:45:31 -0800 (PST)
Message-ID: <56AC9371.5030605@huawei.com>
Date: Sat, 30 Jan 2016 18:41:53 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/2] mm/page_alloc: avoid splitting pages of order
 2 and 3 in migration fallback
References: <cover.1454094692.git.chengyihetaipei@gmail.com> <46b854accad3f40e4178cf3bbd215a4648551763.1454094692.git.chengyihetaipei@gmail.com>
In-Reply-To: <46b854accad3f40e4178cf3bbd215a4648551763.1454094692.git.chengyihetaipei@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ChengYi He <chengyihetaipei@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil
 Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Yaowei Bai <bywxiaobai@163.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/1/30 3:25, ChengYi He wrote:

> While buddy system fallbacks to allocate different migration type pages,
> it prefers the largest feasible pages and might split the chosen page
> into smalller ones. If the largest feasible pages are less than or equal
> to orde-3 and migration fallback happens frequently, then order-2 and
> order-3 pages can be exhausted easily. This patch aims to allocate the
> smallest feasible pages for the fallback mechanism under this condition.
> 
> Signed-off-by: ChengYi He <chengyihetaipei@gmail.com>
> ---
>  mm/page_alloc.c | 19 ++++++++++++++++---
>  1 file changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 50c325a..3fcb653 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1802,9 +1802,22 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>  	struct page *page;
>  
>  	/* Find the largest possible block of pages in the other list */
> -	for (current_order = MAX_ORDER-1;
> -				current_order >= order && current_order <= MAX_ORDER-1;
> -				--current_order) {
> +	for (current_order = MAX_ORDER - 1;
> +			current_order >= max_t(unsigned int, PAGE_ALLOC_COSTLY_ORDER + 1, order);
> +			--current_order) {
> +		page = __rmqueue_fallback_order(zone, order, start_migratetype,
> +				current_order);
> +
> +		if (page)
> +			return page;
> +	}
> +
> +	/*
> +	 * While current_order <= PAGE_ALLOC_COSTLY_ORDER, find the smallest
> +	 * feasible pages in the other list to avoid splitting high order pages
> +	 */
> +	for (current_order = order; current_order <= PAGE_ALLOC_COSTLY_ORDER;
> +			++current_order) {
>  		page = __rmqueue_fallback_order(zone, order, start_migratetype,
>  				current_order);
>  

Hi Chengyi,

So you mean use the largest block first, if no large block left, the use the
smallest block, right?

I have an idea, how about set two migrate types(movable and unmovable) when
doing init work? The function is memmap_init_zone().

I don't know how to set the ratio, maybe unmovable takes 1/10 memory, and left
9/10 memory to movable? I think this effect is a little like the two zones
(normal and movable). 

Another two ideas
https://lkml.org/lkml/2015/8/14/67
7d348b9ea64db0a315d777ce7d4b06697f946503, maybe this patch is not applied on your 3.10

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
