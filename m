Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E77C76B02EE
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 17:46:22 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y106so8232883wrb.14
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 14:46:22 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g7si1093842edh.292.2017.04.25.14.46.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 14:46:21 -0700 (PDT)
Date: Tue, 25 Apr 2017 17:46:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v10 3/3] mm, THP, swap: Enable THP swap optimization
 only if has compound map
Message-ID: <20170425214618.GB6841@cmpxchg.org>
References: <20170425125658.28684-1-ying.huang@intel.com>
 <20170425125658.28684-4-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170425125658.28684-4-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 25, 2017 at 08:56:58PM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> If there is no compound map for a THP (Transparent Huge Page), it is
> possible that the map count of some sub-pages of the THP is 0.  So it
> is better to split the THP before swapping out. In this way, the
> sub-pages not mapped will be freed, and we can avoid the unnecessary
> swap out operations for these sub-pages.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

CC Kirill to double check the reasoning here

> ---
>  mm/swap_state.c | 16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 006d91d8fc53..13f83c6bb1b4 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -192,9 +192,19 @@ int add_to_swap(struct page *page, struct list_head *list)
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	VM_BUG_ON_PAGE(!PageUptodate(page), page);
>  
> -	/* cannot split, skip it */
> -	if (PageTransHuge(page) && !can_split_huge_page(page, NULL))
> -		return 0;
> +	if (PageTransHuge(page)) {
> +		/* cannot split, skip it */
> +		if (!can_split_huge_page(page, NULL))
> +			return 0;
> +		/*
> +		 * Split pages without a PMD map right away. Chances
> +		 * are some or all of the tail pages can be freed
> +		 * without IO.
> +		 */
> +		if (!compound_mapcount(page) &&
> +		    split_huge_page_to_list(page, list))
> +			return 0;
> +	}
>  
>  retry:
>  	entry = get_swap_page(page);
> -- 
> 2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
