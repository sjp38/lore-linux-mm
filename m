Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFF656B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 13:17:01 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v44so4481742wrc.9
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 10:17:01 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o191si7969001wme.129.2017.03.29.10.17.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 10:17:00 -0700 (PDT)
Date: Wed, 29 Mar 2017 13:16:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v7 9/9] mm, THP, swap: Delay splitting THP during
 swap out
Message-ID: <20170329171654.GD31821@cmpxchg.org>
References: <20170328053209.25876-1-ying.huang@intel.com>
 <20170328053209.25876-10-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328053209.25876-10-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 28, 2017 at 01:32:09PM +0800, Huang, Ying wrote:
> @@ -183,12 +184,53 @@ void __delete_from_swap_cache(struct page *page)
>  	ADD_CACHE_INFO(del_total, nr);
>  }
>  
> +#ifdef CONFIG_THP_SWAP_CLUSTER
> +int add_to_swap_trans_huge(struct page *page, struct list_head *list)
> +{
> +	swp_entry_t entry;
> +	int ret = 0;
> +
> +	/* cannot split, which may be needed during swap in, skip it */
> +	if (!can_split_huge_page(page, NULL))
> +		return -EBUSY;
> +	/* fallback to split huge page firstly if no PMD map */
> +	if (!compound_mapcount(page))
> +		return 0;
> +	entry = get_huge_swap_page();
> +	if (!entry.val)
> +		return 0;
> +	if (mem_cgroup_try_charge_swap(page, entry, HPAGE_PMD_NR)) {
> +		__swapcache_free(entry, true);
> +		return -EOVERFLOW;
> +	}
> +	ret = add_to_swap_cache(page, entry,
> +				__GFP_HIGH | __GFP_NOMEMALLOC|__GFP_NOWARN);
> +	/* -ENOMEM radix-tree allocation failure */
> +	if (ret) {
> +		__swapcache_free(entry, true);
> +		return 0;
> +	}
> +	ret = split_huge_page_to_list(page, list);
> +	if (ret) {
> +		delete_from_swap_cache(page);
> +		return -EBUSY;
> +	}
> +	return 1;
> +}
> +#else
> +static inline int add_to_swap_trans_huge(struct page *page,
> +					 struct list_head *list)
> +{
> +	return 0;
> +}
> +#endif
> +
>  /**
>   * add_to_swap - allocate swap space for a page
>   * @page: page we want to move to swap
>   *
>   * Allocate swap space for the page and add the page to the
> - * swap cache.  Caller needs to hold the page lock. 
> + * swap cache.  Caller needs to hold the page lock.
>   */
>  int add_to_swap(struct page *page, struct list_head *list)
>  {
> @@ -198,6 +240,18 @@ int add_to_swap(struct page *page, struct list_head *list)
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	VM_BUG_ON_PAGE(!PageUptodate(page), page);
>  
> +	if (unlikely(PageTransHuge(page))) {
> +		err = add_to_swap_trans_huge(page, list);
> +		switch (err) {
> +		case 1:
> +			return 1;
> +		case 0:
> +			/* fallback to split firstly if return 0 */
> +			break;
> +		default:
> +			return 0;
> +		}
> +	}
>  	entry = get_swap_page();
>  	if (!entry.val)
>  		return 0;

add_to_swap_trans_huge() is too close a copy of add_to_swap(), which
makes the code error prone for future modifications to the swap slot
allocation protocol.

This should read:

retry:
	entry = get_swap_page(page);
	if (!entry.val) {
		if (PageTransHuge(page)) {
			split_huge_page_to_list(page, list);
			goto retry;
		}
		return 0;
	}

And get_swap_page(), mem_cgroup_try_charge_swap() etc. should all
check PageTransHuge() instead of having extra parameters or separate
code paths for the huge page case.

In general, don't try to tack this feature onto the side of the
VM. Because right now, this looks a bit like the hugetlb code, with
one big branch in the beginning that opens up an alternate
reality. Instead, these functions should handle THP all the way down
the stack, and without passing down redundant information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
