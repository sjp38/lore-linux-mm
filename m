Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B596D6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:19:09 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q97so39991wrb.14
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 06:19:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c195si10912wmc.103.2017.06.14.06.19.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 06:19:07 -0700 (PDT)
Subject: Re: [RFC PATCH 1/4] mm, hugetlb: unclutter hugetlb allocation layers
References: <20170613090039.14393-1-mhocko@kernel.org>
 <20170613090039.14393-2-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1babcd50-a90e-a3e4-c45c-85b1b8b93171@suse.cz>
Date: Wed, 14 Jun 2017 15:18:26 +0200
MIME-Version: 1.0
In-Reply-To: <20170613090039.14393-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/13/2017 11:00 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Hugetlb allocation path for fresh huge pages is unnecessarily complex
> and it mixes different interfaces between layers. __alloc_buddy_huge_page
> is the central place to perform a new allocation. It checks for the
> hugetlb overcommit and then relies on __hugetlb_alloc_buddy_huge_page to
> invoke the page allocator. This is all good except that
> __alloc_buddy_huge_page pushes vma and address down the callchain and
> so __hugetlb_alloc_buddy_huge_page has to deal with two different
> allocation modes - one for memory policy and other node specific (or to
> make it more obscure node non-specific) requests. This just screams for a
> reorganization.
> 
> This patch pulls out all the vma specific handling up to
> __alloc_buddy_huge_page_with_mpol where it belongs.
> __alloc_buddy_huge_page will get nodemask argument and
> __hugetlb_alloc_buddy_huge_page will become a trivial wrapper over the
> page allocator.
> 
> In short:
> __alloc_buddy_huge_page_with_mpol - memory policy handling
>   __alloc_buddy_huge_page - overcommit handling and accounting
>     __hugetlb_alloc_buddy_huge_page - page allocator layer
> 
> Also note that __hugetlb_alloc_buddy_huge_page and its cpuset retry loop
> is not really needed because the page allocator already handles the
> cpusets update.
> 
> Finally __hugetlb_alloc_buddy_huge_page had a special case for node
> specific allocations (when no policy is applied and there is a node
> given). This has relied on __GFP_THISNODE to not fallback to a different
> node. alloc_huge_page_node is the only caller which relies on this
> behavior. Keep it for now and emulate it by a proper nodemask.
> 
> Not only this removes quite some code it also should make those layers
> easier to follow and clear wrt responsibilities.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/hugetlb.h |   2 +-
>  mm/hugetlb.c            | 134 +++++++++++-------------------------------------
>  2 files changed, 31 insertions(+), 105 deletions(-)

Very nice cleanup indeed!

> @@ -1717,13 +1640,22 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
>  		page = dequeue_huge_page_node(h, nid);
>  	spin_unlock(&hugetlb_lock);
>  
> -	if (!page)
> -		page = __alloc_buddy_huge_page_no_mpol(h, nid);
> +	if (!page) {
> +		nodemask_t nmask;
> +
> +		if (nid != NUMA_NO_NODE) {
> +			nmask = NODE_MASK_NONE;
> +			node_set(nid, nmask);

TBH I don't like this hack too much, and would rather see __GFP_THISNODE
involved, which picks a different (short) zonelist. Also it's allocating
nodemask on stack, which we generally avoid? Although the callers
currently seem to be shallow.

> +		} else {
> +			nmask = node_states[N_MEMORY];

If nothing, this case could pass NULL? Although that would lead to
uglier code too...

> +		}
> +		page = __alloc_buddy_huge_page(h, nid, &nmask);
> +	}
>  
>  	return page;
>  }
>  
> -struct page *alloc_huge_page_nodemask(struct hstate *h, const nodemask_t *nmask)
> +struct page *alloc_huge_page_nodemask(struct hstate *h, nodemask_t *nmask)
>  {
>  	struct page *page = NULL;
>  	int node;
> @@ -1741,13 +1673,7 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, const nodemask_t *nmask)
>  		return page;
>  
>  	/* No reservations, try to overcommit */
> -	for_each_node_mask(node, *nmask) {
> -		page = __alloc_buddy_huge_page_no_mpol(h, node);
> -		if (page)
> -			return page;
> -	}
> -
> -	return NULL;
> +	return __alloc_buddy_huge_page(h, NUMA_NO_NODE, nmask);
>  }
>  
>  /*
> @@ -1775,7 +1701,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
>  retry:
>  	spin_unlock(&hugetlb_lock);
>  	for (i = 0; i < needed; i++) {
> -		page = __alloc_buddy_huge_page_no_mpol(h, NUMA_NO_NODE);
> +		page = __alloc_buddy_huge_page(h, NUMA_NO_NODE, NULL);
>  		if (!page) {
>  			alloc_ok = false;
>  			break;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
