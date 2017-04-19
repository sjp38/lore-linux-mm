Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4CE6B0038
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 12:00:36 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e132so14847328ite.19
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 09:00:36 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 140si1023239wmf.2.2017.04.19.09.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 09:00:32 -0700 (PDT)
Date: Wed, 19 Apr 2017 12:00:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v9 3/3] mm, THP, swap: Enable THP swap optimization
 only if has compound map
Message-ID: <20170419160029.GB3376@cmpxchg.org>
References: <20170419070625.19776-1-ying.huang@intel.com>
 <20170419070625.19776-4-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419070625.19776-4-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 19, 2017 at 03:06:25PM +0800, Huang, Ying wrote:
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
> ---
>  mm/swap_state.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 3a3217f68937..b025c9878e5e 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -192,9 +192,15 @@ int add_to_swap(struct page *page, struct list_head *list)
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	VM_BUG_ON_PAGE(!PageUptodate(page), page);
>  
> -	/* cannot split, skip it */
> -	if (unlikely(PageTransHuge(page)) && !can_split_huge_page(page, NULL))
> -		return 0;
> +	if (unlikely(PageTransHuge(page))) {
> +		/* cannot split, skip it */
> +		if (!can_split_huge_page(page, NULL))
> +			return 0;
> +		/* fallback to split huge page firstly if no PMD map */
> +		if (!compound_mapcount(page) &&
> +		    split_huge_page_to_list(page, list))
> +			return 0;
> +	}

This looks good to me, but could you please elaborate the comment a
little bit with what you have in the changelog? Something like:

	/*
	 * Split pages without a PMD map right away. Chances are
	 * some or all of the tail pages can be freed without IO.
	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
