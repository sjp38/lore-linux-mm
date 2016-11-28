Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0FD26B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:17:33 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so20865281wjb.3
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:17:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b124si26010459wmg.77.2016.11.28.06.17.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 06:17:32 -0800 (PST)
Subject: Re: [PATCH V2 fix 5/6] mm: hugetlb: add a new function to allocate a
 new gigantic page
References: <1479107259-2011-6-git-send-email-shijie.huang@arm.com>
 <1479279304-31379-1-git-send-email-shijie.huang@arm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f6fc93b4-5c1c-bbab-7c74-a0d60d4afc84@suse.cz>
Date: Mon, 28 Nov 2016 15:17:28 +0100
MIME-Version: 1.0
In-Reply-To: <1479279304-31379-1-git-send-email-shijie.huang@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>, akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On 11/16/2016 07:55 AM, Huang Shijie wrote:
> There are three ways we can allocate a new gigantic page:
>
> 1. When the NUMA is not enabled, use alloc_gigantic_page() to get
>    the gigantic page.
>
> 2. The NUMA is enabled, but the vma is NULL.
>    There is no memory policy we can refer to.
>    So create a @nodes_allowed, initialize it with init_nodemask_of_mempolicy()
>    or init_nodemask_of_node(). Then use alloc_fresh_gigantic_page() to get
>    the gigantic page.
>
> 3. The NUMA is enabled, and the vma is valid.
>    We can follow the memory policy of the @vma.
>
>    Get @nodes_allowed by huge_nodemask(), and use alloc_fresh_gigantic_page()
>    to get the gigantic page.
>
> Signed-off-by: Huang Shijie <shijie.huang@arm.com>
> ---
> Since the huge_nodemask() is changed, we have to change this function a little.
>
> ---
>  mm/hugetlb.c | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 63 insertions(+)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6995087..c33bddc 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1502,6 +1502,69 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>
>  /*
>   * There are 3 ways this can get called:
> + *
> + * 1. When the NUMA is not enabled, use alloc_gigantic_page() to get
> + *    the gigantic page.
> + *
> + * 2. The NUMA is enabled, but the vma is NULL.
> + *    Create a @nodes_allowed, and use alloc_fresh_gigantic_page() to get
> + *    the gigantic page.
> + *
> + * 3. The NUMA is enabled, and the vma is valid.
> + *    Use the @vma's memory policy.
> + *    Get @nodes_allowed by huge_nodemask(), and use alloc_fresh_gigantic_page()
> + *    to get the gigantic page.
> + */
> +static struct page *__hugetlb_alloc_gigantic_page(struct hstate *h,
> +		struct vm_area_struct *vma, unsigned long addr, int nid)
> +{
> +	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);

What if the allocation fails and nodes_allowed is NULL?
It might work fine now, but it's rather fragile, so I'd rather see an 
explicit check.

BTW same thing applies to __nr_hugepages_store_common().

> +	struct page *page = NULL;
> +
> +	/* Not NUMA */
> +	if (!IS_ENABLED(CONFIG_NUMA)) {
> +		if (nid == NUMA_NO_NODE)
> +			nid = numa_mem_id();
> +
> +		page = alloc_gigantic_page(nid, huge_page_order(h));
> +		if (page)
> +			prep_compound_gigantic_page(page, huge_page_order(h));
> +
> +		NODEMASK_FREE(nodes_allowed);
> +		return page;
> +	}
> +
> +	/* NUMA && !vma */
> +	if (!vma) {
> +		if (nid == NUMA_NO_NODE) {
> +			if (!init_nodemask_of_mempolicy(nodes_allowed)) {
> +				NODEMASK_FREE(nodes_allowed);
> +				nodes_allowed = &node_states[N_MEMORY];
> +			}
> +		} else if (nodes_allowed) {
> +			init_nodemask_of_node(nodes_allowed, nid);
> +		} else {
> +			nodes_allowed = &node_states[N_MEMORY];
> +		}
> +
> +		page = alloc_fresh_gigantic_page(h, nodes_allowed, true);
> +
> +		if (nodes_allowed != &node_states[N_MEMORY])
> +			NODEMASK_FREE(nodes_allowed);
> +
> +		return page;
> +	}
> +
> +	/* NUMA && vma */
> +	if (huge_nodemask(vma, addr, nodes_allowed))
> +		page = alloc_fresh_gigantic_page(h, nodes_allowed, true);
> +
> +	NODEMASK_FREE(nodes_allowed);
> +	return page;
> +}
> +
> +/*
> + * There are 3 ways this can get called:
>   * 1. With vma+addr: we use the VMA's memory policy
>   * 2. With !vma, but nid=NUMA_NO_NODE:  We try to allocate a huge
>   *    page from any node, and let the buddy allocator itself figure
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
