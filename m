Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC4E6B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:08:20 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id f199so1105563qke.20
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 01:08:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 15si478763qky.264.2017.10.17.01.08.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 01:08:19 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9H87vMh049489
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:08:18 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dnc6emfme-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:08:18 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 17 Oct 2017 09:08:16 +0100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9H88B9b26542302
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 08:08:12 GMT
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9H882GS010405
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 19:08:02 +1100
Subject: Re: [PATCH 1/2] mm, thp: introduce dedicated transparent huge page
 allocation interfaces
References: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
 <1508145557-9944-2-git-send-email-changbin.du@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 17 Oct 2017 13:38:07 +0530
MIME-Version: 1.0
In-Reply-To: <1508145557-9944-2-git-send-email-changbin.du@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <66a3f340-ff44-efad-48ad-a95554938a29@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: changbin.du@intel.com, akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/16/2017 02:49 PM, changbin.du@intel.com wrote:
> From: Changbin Du <changbin.du@intel.com>
> 
> This patch introduced 4 new interfaces to allocate a prepared
> transparent huge page.
>   - alloc_transhuge_page_vma
>   - alloc_transhuge_page_nodemask
>   - alloc_transhuge_page_node
>   - alloc_transhuge_page
> 

If we are trying to match HugeTLB helpers, then it should have
format something like alloc_transhugepage_xxx instead of
alloc_transhuge_page_XXX. But I think its okay.

> The aim is to remove duplicated code and simplify transparent
> huge page allocation. These are similar to alloc_hugepage_xxx
> which are for hugetlbfs pages. This patch does below changes:
>   - define alloc_transhuge_page_xxx interfaces
>   - apply them to all existing code
>   - declare prep_transhuge_page as static since no others use it
>   - remove alloc_hugepage_vma definition since it no longer has users
> 
> Signed-off-by: Changbin Du <changbin.du@intel.com>
> ---
>  include/linux/gfp.h     |  4 ----
>  include/linux/huge_mm.h | 13 ++++++++++++-
>  include/linux/migrate.h | 14 +++++---------
>  mm/huge_memory.c        | 50 ++++++++++++++++++++++++++++++++++++++++++-------
>  mm/khugepaged.c         | 11 ++---------
>  mm/mempolicy.c          | 10 +++-------
>  mm/migrate.c            | 12 ++++--------
>  mm/shmem.c              |  6 ++----
>  8 files changed, 71 insertions(+), 49 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index f780718..855c72e 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -507,15 +507,11 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
>  extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
>  			struct vm_area_struct *vma, unsigned long addr,
>  			int node, bool hugepage);
> -#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
> -	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
>  #else
>  #define alloc_pages(gfp_mask, order) \
>  		alloc_pages_node(numa_node_id(), gfp_mask, order)
>  #define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
>  	alloc_pages(gfp_mask, order)
> -#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
> -	alloc_pages(gfp_mask, order)
>  #endif
>  #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
>  #define alloc_page_vma(gfp_mask, vma, addr)			\
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 14bc21c..1dd2c33 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -130,9 +130,20 @@ extern unsigned long thp_get_unmapped_area(struct file *filp,
>  		unsigned long addr, unsigned long len, unsigned long pgoff,
>  		unsigned long flags);
>  
> -extern void prep_transhuge_page(struct page *page);
>  extern void free_transhuge_page(struct page *page);
>  
> +struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
> +		struct vm_area_struct *vma, unsigned long addr);
> +struct page *alloc_transhuge_page_nodemask(gfp_t gfp_mask,
> +		int preferred_nid, nodemask_t *nmask);

Would not they require 'extern' here ?

> +
> +static inline struct page *alloc_transhuge_page_node(int nid, gfp_t gfp_mask)
> +{
> +	return alloc_transhuge_page_nodemask(gfp_mask, nid, NULL);
> +}
> +
> +struct page *alloc_transhuge_page(gfp_t gfp_mask);
> +
>  bool can_split_huge_page(struct page *page, int *pextra_pins);
>  int split_huge_page_to_list(struct page *page, struct list_head *list);
>  static inline int split_huge_page(struct page *page)
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 643c7ae..70a00f3 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -42,19 +42,15 @@ static inline struct page *new_page_nodemask(struct page *page,
>  		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
>  				preferred_nid, nodemask);
>  
> -	if (thp_migration_supported() && PageTransHuge(page)) {
> -		order = HPAGE_PMD_ORDER;
> -		gfp_mask |= GFP_TRANSHUGE;
> -	}
> -
>  	if (PageHighMem(page) || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
>  		gfp_mask |= __GFP_HIGHMEM;
>  
> -	new_page = __alloc_pages_nodemask(gfp_mask, order,
> +	if (thp_migration_supported() && PageTransHuge(page))
> +		return alloc_transhuge_page_nodemask(gfp_mask | GFP_TRANSHUGE,
> +				preferred_nid, nodemask);
> +	else
> +		return __alloc_pages_nodemask(gfp_mask, order,
>  				preferred_nid, nodemask);
> -
> -	if (new_page && PageTransHuge(page))
> -		prep_transhuge_page(new_page);

This makes sense, calling prep_transhuge_page() inside the
function alloc_transhuge_page_nodemask() is better I guess.

>  
>  	return new_page;
>  }
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 269b5df..e267488 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -490,7 +490,7 @@ static inline struct list_head *page_deferred_list(struct page *page)
>  	return (struct list_head *)&page[2].mapping;
>  }
>  
> -void prep_transhuge_page(struct page *page)
> +static void prep_transhuge_page(struct page *page)

Right. It wont be used outside huge page allocation context and
you have already mentioned about it.

>  {
>  	/*
>  	 * we use page->mapping and page->indexlru in second tail page
> @@ -501,6 +501,45 @@ void prep_transhuge_page(struct page *page)
>  	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
>  }
>  
> +struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
> +		struct vm_area_struct *vma, unsigned long addr)
> +{
> +	struct page *page;
> +
> +	page = alloc_pages_vma(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER,
> +			       vma, addr, numa_node_id(), true);
> +	if (unlikely(!page))
> +		return NULL;
> +	prep_transhuge_page(page);
> +	return page;
> +}

__GFP_COMP and HPAGE_PMD_ORDER are the minimum flags which will be used
for huge page allocation and preparation. Any thing else depending upon
the context will be passed by the caller. Makes sense.

> +
> +struct page *alloc_transhuge_page_nodemask(gfp_t gfp_mask,
> +		int preferred_nid, nodemask_t *nmask)
> +{
> +	struct page *page;
> +
> +	page = __alloc_pages_nodemask(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER,
> +				      preferred_nid, nmask);
> +	if (unlikely(!page))
> +		return NULL;
> +	prep_transhuge_page(page);
> +	return page;
> +}
> +

Same here.

> +struct page *alloc_transhuge_page(gfp_t gfp_mask)
> +{
> +	struct page *page;
> +
> +	VM_BUG_ON(!(gfp_mask & __GFP_COMP));

You expect the caller to provide __GFP_COMP, why ? You are
anyways providing it later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
