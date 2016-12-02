Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 219AE6B025E
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 09:03:35 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id he10so4615467wjc.6
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 06:03:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s5si3182585wma.51.2016.12.02.06.03.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Dec 2016 06:03:33 -0800 (PST)
Date: Fri, 2 Dec 2016 15:03:30 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH V2 fix 5/6] mm: hugetlb: add a new function to allocate a
 new gigantic page
Message-ID: <20161202140325.GM6830@dhcp22.suse.cz>
References: <1479107259-2011-6-git-send-email-shijie.huang@arm.com>
 <1479279304-31379-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479279304-31379-1-git-send-email-shijie.huang@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Wed 16-11-16 14:55:04, Huang Shijie wrote:
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

Again __hugetlb_alloc_gigantic_page is not used and it is hard to deduce
its usage from this commit. The above shouldn't be really much different from
what we do in alloc_pages_vma so please make sure to check it before
coming up with something hugetlb specific.

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
> -- 
> 2.5.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
