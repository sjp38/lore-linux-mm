Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id EAC306B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 16:35:01 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id o17so386553pli.7
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 13:35:01 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l70si93109pge.568.2017.11.28.13.35.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 13:35:00 -0800 (PST)
Subject: Re: [PATCH RFC 1/2] mm, hugetlb: unify core page allocation
 accounting and initialization
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
 <20171128141211.11117-2-mhocko@kernel.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <4c919c6d-2e97-b66d-f572-439bb9f0587b@oracle.com>
Date: Tue, 28 Nov 2017 13:34:53 -0800
MIME-Version: 1.0
In-Reply-To: <20171128141211.11117-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 11/28/2017 06:12 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> hugetlb allocator has two entry points to the page allocator
> - alloc_fresh_huge_page_node
> - __hugetlb_alloc_buddy_huge_page
> 
> The two differ very subtly in two aspects. The first one doesn't care
> about HTLB_BUDDY_* stats and it doesn't initialize the huge page.
> prep_new_huge_page is not used because it not only initializes hugetlb
> specific stuff but because it also put_page and releases the page to
> the hugetlb pool which is not what is required in some contexts. This
> makes things more complicated than necessary.
> 
> Simplify things by a) removing the page allocator entry point duplicity
> and only keep __hugetlb_alloc_buddy_huge_page and b) make
> prep_new_huge_page more reusable by removing the put_page which moves
> the page to the allocator pool. All current callers are updated to call
> put_page explicitly. Later patches will add new callers which won't
> need it.
> 
> This patch shouldn't introduce any functional change.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/hugetlb.c | 61 +++++++++++++++++++++++++++++-------------------------------
>  1 file changed, 29 insertions(+), 32 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 2c9033d39bfe..8189c92fac82 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1157,6 +1157,7 @@ static struct page *alloc_fresh_gigantic_page_node(struct hstate *h, int nid)
>  	if (page) {
>  		prep_compound_gigantic_page(page, huge_page_order(h));
>  		prep_new_huge_page(h, page, nid);
> +		put_page(page); /* free it into the hugepage allocator */
>  	}
>  
>  	return page;
> @@ -1304,7 +1305,6 @@ static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
>  	h->nr_huge_pages++;
>  	h->nr_huge_pages_node[nid]++;
>  	spin_unlock(&hugetlb_lock);
> -	put_page(page); /* free it into the hugepage allocator */
>  }
>  
>  static void prep_compound_gigantic_page(struct page *page, unsigned int order)
> @@ -1381,41 +1381,49 @@ pgoff_t __basepage_index(struct page *page)
>  	return (index << compound_order(page_head)) + compound_idx;
>  }
>  
> -static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
> +static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
> +		gfp_t gfp_mask, int nid, nodemask_t *nmask)
>  {
> +	int order = huge_page_order(h);
>  	struct page *page;
>  
> -	page = __alloc_pages_node(nid,
> -		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
> -						__GFP_RETRY_MAYFAIL|__GFP_NOWARN,
> -		huge_page_order(h));
> -	if (page) {
> -		prep_new_huge_page(h, page, nid);
> -	}
> +	gfp_mask |= __GFP_COMP|__GFP_RETRY_MAYFAIL|__GFP_NOWARN;
> +	if (nid == NUMA_NO_NODE)
> +		nid = numa_mem_id();
> +	page = __alloc_pages_nodemask(gfp_mask, order, nid, nmask);
> +	if (page)
> +		__count_vm_event(HTLB_BUDDY_PGALLOC);
> +	else
> +		__count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
>  
>  	return page;
>  }
>  
> +/*
> + * Allocates a fresh page to the hugetlb allocator pool in the node interleaved
> + * manner.
> + */
>  static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
>  {
>  	struct page *page;
>  	int nr_nodes, node;
> -	int ret = 0;
> +	gfp_t gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
>  
>  	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
> -		page = alloc_fresh_huge_page_node(h, node);
> -		if (page) {
> -			ret = 1;
> +		page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask,
> +				node, nodes_allowed);

I don't have the greatest understanding of node/nodemasks, but ...
Since __hugetlb_alloc_buddy_huge_page calls __alloc_pages_nodemask(), do
we still need to explicitly iterate over nodes with
for_each_node_mask_to_alloc() here?

-- 
Mike Kravetz

> +		if (page)
>  			break;
> -		}
> +
>  	}
>  
> -	if (ret)
> -		count_vm_event(HTLB_BUDDY_PGALLOC);
> -	else
> -		count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
> +	if (!page)
> +		return 0;
>  
> -	return ret;
> +	prep_new_huge_page(h, page, page_to_nid(page));
> +	put_page(page); /* free it into the hugepage allocator */
> +
> +	return 1;
>  }
>  
>  /*
> @@ -1523,17 +1531,6 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  	return rc;
>  }
>  
> -static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
> -		gfp_t gfp_mask, int nid, nodemask_t *nmask)
> -{
> -	int order = huge_page_order(h);
> -
> -	gfp_mask |= __GFP_COMP|__GFP_RETRY_MAYFAIL|__GFP_NOWARN;
> -	if (nid == NUMA_NO_NODE)
> -		nid = numa_mem_id();
> -	return __alloc_pages_nodemask(gfp_mask, order, nid, nmask);
> -}
> -
>  static struct page *__alloc_buddy_huge_page(struct hstate *h, gfp_t gfp_mask,
>  		int nid, nodemask_t *nmask)
>  {
> @@ -1589,11 +1586,9 @@ static struct page *__alloc_buddy_huge_page(struct hstate *h, gfp_t gfp_mask,
>  		 */
>  		h->nr_huge_pages_node[r_nid]++;
>  		h->surplus_huge_pages_node[r_nid]++;
> -		__count_vm_event(HTLB_BUDDY_PGALLOC);
>  	} else {
>  		h->nr_huge_pages--;
>  		h->surplus_huge_pages--;
> -		__count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
>  	}
>  	spin_unlock(&hugetlb_lock);
>  
> @@ -2148,6 +2143,8 @@ static void __init gather_bootmem_prealloc(void)
>  		prep_compound_huge_page(page, h->order);
>  		WARN_ON(PageReserved(page));
>  		prep_new_huge_page(h, page, page_to_nid(page));
> +		put_page(page); /* free it into the hugepage allocator */
> +
>  		/*
>  		 * If we had gigantic hugepages allocated at boot time, we need
>  		 * to restore the 'stolen' pages to totalram_pages in order to
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
