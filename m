Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5927B6B025E
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 08:56:47 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so3155160wme.4
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 05:56:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u16si3113078wma.110.2016.12.02.05.56.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Dec 2016 05:56:46 -0800 (PST)
Date: Fri, 2 Dec 2016 14:56:43 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2 3/6] mm: hugetlb: change the return type for
 alloc_fresh_gigantic_page
Message-ID: <20161202135643.GK6830@dhcp22.suse.cz>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
 <1479107259-2011-4-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479107259-2011-4-git-send-email-shijie.huang@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Mon 14-11-16 15:07:36, Huang Shijie wrote:
> This patch changes the return type to "struct page*" for
> alloc_fresh_gigantic_page().

OK, this makes somme sense. Other hugetlb allocation function (and page
allocator in general) return struct page as well. Besides that int would
make sense if we wanted to convey an error code but 0 vs. 1 just doesn't
make any sense.

But if you are changing that then alloc_fresh_huge_page should be
changed as well.

> This patch makes preparation for later patch.
> 
> Signed-off-by: Huang Shijie <shijie.huang@arm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/hugetlb.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index db0177b..6995087 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1142,7 +1142,7 @@ static struct page *alloc_fresh_gigantic_page_node(struct hstate *h,
>  	return page;
>  }
>  
> -static int alloc_fresh_gigantic_page(struct hstate *h,
> +static struct page *alloc_fresh_gigantic_page(struct hstate *h,
>  				nodemask_t *nodes_allowed, bool no_init)
>  {
>  	struct page *page = NULL;
> @@ -1151,10 +1151,10 @@ static int alloc_fresh_gigantic_page(struct hstate *h,
>  	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
>  		page = alloc_fresh_gigantic_page_node(h, node, no_init);
>  		if (page)
> -			return 1;
> +			return page;
>  	}
>  
> -	return 0;
> +	return NULL;
>  }
>  
>  static inline bool gigantic_page_supported(void) { return true; }
> @@ -1167,8 +1167,8 @@ static inline bool gigantic_page_supported(void) { return false; }
>  static inline void free_gigantic_page(struct page *page, unsigned int order) { }
>  static inline void destroy_compound_gigantic_page(struct page *page,
>  						unsigned int order) { }
> -static inline int alloc_fresh_gigantic_page(struct hstate *h,
> -		nodemask_t *nodes_allowed, bool no_init) { return 0; }
> +static inline struct page *alloc_fresh_gigantic_page(struct hstate *h,
> +		nodemask_t *nodes_allowed, bool no_init) { return NULL; }
>  #endif
>  
>  static void update_and_free_page(struct hstate *h, struct page *page)
> @@ -2315,7 +2315,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>  		cond_resched();
>  
>  		if (hstate_is_gigantic(h))
> -			ret = alloc_fresh_gigantic_page(h, nodes_allowed,
> +			ret = !!alloc_fresh_gigantic_page(h, nodes_allowed,
>  							false);
>  		else
>  			ret = alloc_fresh_huge_page(h, nodes_allowed);
> -- 
> 2.5.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
