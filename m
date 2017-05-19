Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3D9F2806DC
	for <linux-mm@kvack.org>; Fri, 19 May 2017 09:57:36 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c75so27652884qka.7
        for <linux-mm@kvack.org>; Fri, 19 May 2017 06:57:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 35si8863072qty.162.2017.05.19.06.57.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 06:57:35 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4JDsGST050435
	for <linux-mm@kvack.org>; Fri, 19 May 2017 09:57:35 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ahr3jaj3n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 May 2017 09:57:34 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 19 May 2017 23:57:31 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4JDvLXB42139796
	for <linux-mm@kvack.org>; Fri, 19 May 2017 23:57:29 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4JDuupI029710
	for <linux-mm@kvack.org>; Fri, 19 May 2017 23:56:56 +1000
Subject: Re: [PATCH v5 11/11] mm: memory_hotplug: memory hotremove supports
 thp migration
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-12-zi.yan@sent.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 19 May 2017 19:26:27 +0530
MIME-Version: 1.0
In-Reply-To: <20170420204752.79703-12-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <76fec3ce-986e-406b-6fe1-c785590dc1bd@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

On 04/21/2017 02:17 AM, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> This patch enables thp migration for memory hotremove.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
> ChangeLog v1->v2:
> - base code switched from alloc_migrate_target to new_node_page()
> ---
>  include/linux/huge_mm.h |  8 ++++++++
>  mm/memory_hotplug.c     | 17 ++++++++++++++---
>  2 files changed, 22 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 6f44a2352597..92c2161704c3 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -189,6 +189,13 @@ static inline int hpage_nr_pages(struct page *page)
>  	return 1;
>  }
>  
> +static inline int hpage_order(struct page *page)
> +{
> +	if (unlikely(PageTransHuge(page)))
> +		return HPAGE_PMD_ORDER;
> +	return 0;
> +}
> +

This function seems to be redundant.

>  struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
>  		pmd_t *pmd, int flags);
>  struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
> @@ -233,6 +240,7 @@ static inline bool thp_migration_supported(void)
>  #define HPAGE_PUD_SIZE ({ BUILD_BUG(); 0; })
>  
>  #define hpage_nr_pages(x) 1
> +#define hpage_order(x) 0
>  
>  #define transparent_hugepage_enabled(__vma) 0
>  
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 257166ebdff0..ecae0852994f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1574,6 +1574,7 @@ static struct page *new_node_page(struct page *page, unsigned long private,
>  	int nid = page_to_nid(page);
>  	nodemask_t nmask = node_states[N_MEMORY];
>  	struct page *new_page = NULL;
> +	unsigned int order = 0;
>  
>  	/*
>  	 * TODO: allocate a destination hugepage from a nearest neighbor node,
> @@ -1584,6 +1585,11 @@ static struct page *new_node_page(struct page *page, unsigned long private,
>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
>  					next_node_in(nid, nmask));
>  
> +	if (thp_migration_supported() && PageTransHuge(page)) {
> +		order = hpage_order(page);

We have already tested the page as THP, we can just use HPAGE_PMD_ORDER.


> +		gfp_mask |= GFP_TRANSHUGE;
> +	}
> +
>  	node_clear(nid, nmask);
>  
>  	if (PageHighMem(page)
> @@ -1591,12 +1597,15 @@ static struct page *new_node_page(struct page *page, unsigned long private,
>  		gfp_mask |= __GFP_HIGHMEM;
>  
>  	if (!nodes_empty(nmask))
> -		new_page = __alloc_pages_nodemask(gfp_mask, 0,
> +		new_page = __alloc_pages_nodemask(gfp_mask, order,
>  					node_zonelist(nid, gfp_mask), &nmask);
>  	if (!new_page)
> -		new_page = __alloc_pages(gfp_mask, 0,
> +		new_page = __alloc_pages(gfp_mask, order,
>  					node_zonelist(nid, gfp_mask));
>  
> +	if (new_page && order == hpage_order(page))
> +		prep_transhuge_page(new_page);
> +

new_page has been allocated with 'order' already. I guess just checking
for PageTransHuge(page) on the old THP 'page' should be sufficient as
that has not been changed in any way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
