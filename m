Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26A826B0292
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 11:07:30 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n7so986394wrb.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 08:07:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18si296952wrg.233.2017.06.14.08.07.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 08:07:28 -0700 (PDT)
Subject: Re: [RFC PATCH 1/4] mm, hugetlb: unclutter hugetlb allocation layers
References: <20170613090039.14393-1-mhocko@kernel.org>
 <20170613090039.14393-2-mhocko@kernel.org>
 <1babcd50-a90e-a3e4-c45c-85b1b8b93171@suse.cz>
 <20170614134258.GP6045@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <115a973d-6ede-7fcf-d1c6-8a62194cff59@suse.cz>
Date: Wed, 14 Jun 2017 17:06:47 +0200
MIME-Version: 1.0
In-Reply-To: <20170614134258.GP6045@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 06/14/2017 03:42 PM, Michal Hocko wrote:
> On Wed 14-06-17 15:18:26, Vlastimil Babka wrote:
>> On 06/13/2017 11:00 AM, Michal Hocko wrote:
> [...]
>>> @@ -1717,13 +1640,22 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
>>>  		page = dequeue_huge_page_node(h, nid);
>>>  	spin_unlock(&hugetlb_lock);
>>>  
>>> -	if (!page)
>>> -		page = __alloc_buddy_huge_page_no_mpol(h, nid);
>>> +	if (!page) {
>>> +		nodemask_t nmask;
>>> +
>>> +		if (nid != NUMA_NO_NODE) {
>>> +			nmask = NODE_MASK_NONE;
>>> +			node_set(nid, nmask);
>>
>> TBH I don't like this hack too much, and would rather see __GFP_THISNODE
>> involved, which picks a different (short) zonelist. Also it's allocating
>> nodemask on stack, which we generally avoid? Although the callers
>> currently seem to be shallow.
> 
> Fair enough. That would require pulling gfp mask handling up the call
> chain. This on top of this patch + refreshes for other patches later in
> the series as they will conflict now?

For the orig patch + fold (squashed locally from your mmotm/... branch)

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Please update the commit description which still mentions the nodemask
emulation of __GFP_THISNODE.

Also I noticed that the goal of patch 2 is already partially achieved
here, because alloc_huge_page_nodemask() will now allocate using
zonelist. It won't dequeue that way yet, though.

> ---
> commit dcd863b48fb2c93e5aebce818e75c30978e26cf1
> Author: Michal Hocko <mhocko@suse.com>
> Date:   Wed Jun 14 15:41:07 2017 +0200
> 
>     fold me
>     
>     - pull gfp mask out of __hugetlb_alloc_buddy_huge_page and make it an
>       explicit argument to allow __GFP_THISNODE in alloc_huge_page_node per
>       Vlastimil
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3d5f25d589b3..afc87de5de5c 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1532,17 +1532,18 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  }
>  
>  static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
> -		int nid, nodemask_t *nmask)
> +		gfp_t gfp_mask, int nid, nodemask_t *nmask)
>  {
>  	int order = huge_page_order(h);
> -	gfp_t gfp = htlb_alloc_mask(h)|__GFP_COMP|__GFP_REPEAT|__GFP_NOWARN;
>  
> +	gfp_mask |= __GFP_COMP|__GFP_REPEAT|__GFP_NOWARN;
>  	if (nid == NUMA_NO_NODE)
>  		nid = numa_mem_id();
> -	return __alloc_pages_nodemask(gfp, order, nid, nmask);
> +	return __alloc_pages_nodemask(gfp_mask, order, nid, nmask);
>  }
>  
> -static struct page *__alloc_buddy_huge_page(struct hstate *h, int nid, nodemask_t *nmask)
> +static struct page *__alloc_buddy_huge_page(struct hstate *h, gfp_t gfp_mask,
> +		int nid, nodemask_t *nmask)
>  {
>  	struct page *page;
>  	unsigned int r_nid;
> @@ -1583,7 +1584,7 @@ static struct page *__alloc_buddy_huge_page(struct hstate *h, int nid, nodemask_
>  	}
>  	spin_unlock(&hugetlb_lock);
>  
> -	page = __hugetlb_alloc_buddy_huge_page(h, nid, nmask);
> +	page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask, nid, nmask);
>  
>  	spin_lock(&hugetlb_lock);
>  	if (page) {
> @@ -1616,11 +1617,12 @@ struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
>  {
>  	struct page *page;
>  	struct mempolicy *mpol;
> +	gfp_t gfp_mask = htlb_alloc_mask(h);
>  	int nid;
>  	nodemask_t *nodemask;
>  
> -	nid = huge_node(vma, addr, htlb_alloc_mask(h), &mpol, &nodemask);
> -	page = __alloc_buddy_huge_page(h, nid, nodemask);
> +	nid = huge_node(vma, addr, gfp_mask, &mpol, &nodemask);
> +	page = __alloc_buddy_huge_page(h, gfp_mask, nid, nodemask);
>  	mpol_cond_put(mpol);
>  
>  	return page;
> @@ -1633,30 +1635,26 @@ struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
>   */
>  struct page *alloc_huge_page_node(struct hstate *h, int nid)
>  {
> +	gfp_t gfp_mask = htlb_alloc_mask(h);
>  	struct page *page = NULL;
>  
> +	if (nid != NUMA_NO_NODE)
> +		gfp_mask |= __GFP_THISNODE;
> +
>  	spin_lock(&hugetlb_lock);
>  	if (h->free_huge_pages - h->resv_huge_pages > 0)
>  		page = dequeue_huge_page_node(h, nid);
>  	spin_unlock(&hugetlb_lock);
>  
> -	if (!page) {
> -		nodemask_t nmask;
> -
> -		if (nid != NUMA_NO_NODE) {
> -			nmask = NODE_MASK_NONE;
> -			node_set(nid, nmask);
> -		} else {
> -			nmask = node_states[N_MEMORY];
> -		}
> -		page = __alloc_buddy_huge_page(h, nid, &nmask);
> -	}
> +	if (!page)
> +		page = __alloc_buddy_huge_page(h, gfp_mask, nid, NULL);
>  
>  	return page;
>  }
>  
>  struct page *alloc_huge_page_nodemask(struct hstate *h, nodemask_t *nmask)
>  {
> +	gfp_t gfp_mask = htlb_alloc_mask(h);
>  	struct page *page = NULL;
>  	int node;
>  
> @@ -1673,7 +1671,7 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, nodemask_t *nmask)
>  		return page;
>  
>  	/* No reservations, try to overcommit */
> -	return __alloc_buddy_huge_page(h, NUMA_NO_NODE, nmask);
> +	return __alloc_buddy_huge_page(h, gfp_mask, NUMA_NO_NODE, nmask);
>  }
>  
>  /*
> @@ -1701,7 +1699,8 @@ static int gather_surplus_pages(struct hstate *h, int delta)
>  retry:
>  	spin_unlock(&hugetlb_lock);
>  	for (i = 0; i < needed; i++) {
> -		page = __alloc_buddy_huge_page(h, NUMA_NO_NODE, NULL);
> +		page = __alloc_buddy_huge_page(h, htlb_alloc_mask(h),
> +				NUMA_NO_NODE, NULL);
>  		if (!page) {
>  			alloc_ok = false;
>  			break;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
