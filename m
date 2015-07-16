Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA532802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 20:06:09 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so32279263pac.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:06:08 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id k16si9889090pdm.244.2015.07.15.17.06.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 17:06:08 -0700 (PDT)
Received: by padck2 with SMTP id ck2so32123879pad.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:06:08 -0700 (PDT)
Date: Thu, 16 Jul 2015 09:06:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm/page_owner: set correct gfp_mask on page_owner
Message-ID: <20150716000613.GE988@bgram>
References: <1436942039-16897-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1436942039-16897-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436942039-16897-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, Jul 15, 2015 at 03:33:59PM +0900, Joonsoo Kim wrote:
> Currently, we set wrong gfp_mask to page_owner info in case of
> isolated freepage by compaction and split page. It causes incorrect
> mixed pageblock report that we can get from '/proc/pagetypeinfo'.
> This metric is really useful to measure fragmentation effect so
> should be accurate. This patch fixes it by setting correct
> information.
> 
> Without this patch, after kernel build workload is finished, number
> of mixed pageblock is 112 among roughly 210 movable pageblocks.
> 
> But, with this fix, output shows that mixed pageblock is just 57.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/page_owner.h | 13 +++++++++++++
>  mm/page_alloc.c            |  8 +++++---
>  mm/page_owner.c            |  7 +++++++
>  3 files changed, 25 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
> index b48c347..cacaabe 100644
> --- a/include/linux/page_owner.h
> +++ b/include/linux/page_owner.h
> @@ -8,6 +8,7 @@ extern struct page_ext_operations page_owner_ops;
>  extern void __reset_page_owner(struct page *page, unsigned int order);
>  extern void __set_page_owner(struct page *page,
>  			unsigned int order, gfp_t gfp_mask);
> +extern gfp_t __get_page_owner_gfp(struct page *page);
>  
>  static inline void reset_page_owner(struct page *page, unsigned int order)
>  {
> @@ -25,6 +26,14 @@ static inline void set_page_owner(struct page *page,
>  
>  	__set_page_owner(page, order, gfp_mask);
>  }
> +
> +static inline gfp_t get_page_owner_gfp(struct page *page)
> +{
> +	if (likely(!page_owner_inited))
> +		return 0;
> +
> +	return __get_page_owner_gfp(page);
> +}
>  #else
>  static inline void reset_page_owner(struct page *page, unsigned int order)
>  {
> @@ -33,6 +42,10 @@ static inline void set_page_owner(struct page *page,
>  			unsigned int order, gfp_t gfp_mask)
>  {
>  }
> +static inline gfp_t get_page_owner_gfp(struct page *page)
> +{
> +	return 0;
> +}
>  
>  #endif /* CONFIG_PAGE_OWNER */
>  #endif /* __LINUX_PAGE_OWNER_H */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 70d6a85..3ce3ec2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1957,6 +1957,7 @@ void free_hot_cold_page_list(struct list_head *list, bool cold)
>  void split_page(struct page *page, unsigned int order)
>  {
>  	int i;
> +	gfp_t gfp_mask;
>  
>  	VM_BUG_ON_PAGE(PageCompound(page), page);
>  	VM_BUG_ON_PAGE(!page_count(page), page);
> @@ -1970,10 +1971,11 @@ void split_page(struct page *page, unsigned int order)
>  		split_page(virt_to_page(page[0].shadow), order);
>  #endif
>  
> -	set_page_owner(page, 0, 0);
> +	gfp_mask = get_page_owner_gfp(page);
> +	set_page_owner(page, 0, gfp_mask);
>  	for (i = 1; i < (1 << order); i++) {
>  		set_page_refcounted(page + i);
> -		set_page_owner(page + i, 0, 0);
> +		set_page_owner(page + i, 0, gfp_mask);
>  	}
>  }
>  EXPORT_SYMBOL_GPL(split_page);
> @@ -2003,7 +2005,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  	zone->free_area[order].nr_free--;
>  	rmv_page_order(page);
>  
> -	set_page_owner(page, order, 0);
> +	set_page_owner(page, order, __GFP_MOVABLE);

It seems the reason why  __GFP_MOVABLE is okay is that __isolate_free_page
works on a free page on MIGRATE_MOVABLE|MIGRATE_CMA's pageblock. But if we
break the assumption in future, here is broken again?

Please put the comment here to cause it.

Otherwise, Good spot!

Reviewed-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
