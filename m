Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15BA96B0397
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 04:11:25 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id a103so99525877ioj.8
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 01:11:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 91si9564024plb.165.2017.04.21.01.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 01:11:24 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3L88dUB063596
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 04:11:23 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29y0he6xh3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 04:11:23 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 21 Apr 2017 18:11:20 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3L8BAhJ55443710
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 18:11:18 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3L8Ajkw001833
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 18:10:45 +1000
Subject: Re: [PATCH v5 08/11] mm: hwpoison: soft offline supports thp
 migration
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-9-zi.yan@sent.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 21 Apr 2017 13:40:20 +0530
MIME-Version: 1.0
In-Reply-To: <20170420204752.79703-9-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <62d7eea3-96c8-3230-3e1b-fdc2bfbea6bd@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

On 04/21/2017 02:17 AM, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> This patch enables thp migration for soft offline.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> ChangeLog: v1 -> v5:
> - fix page isolation counting error
> 
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  mm/memory-failure.c | 35 ++++++++++++++---------------------
>  1 file changed, 14 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 9b77476ef31f..23ff02eb3ed4 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1481,7 +1481,17 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
>  	if (PageHuge(p))
>  		return alloc_huge_page_node(page_hstate(compound_head(p)),
>  						   nid);
> -	else
> +	else if (thp_migration_supported() && PageTransHuge(p)) {
> +		struct page *thp;
> +
> +		thp = alloc_pages_node(nid,
> +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,

Why not __GFP_RECLAIM ? Its soft offline path we wait a bit before
declaring that THP page cannot be allocated and hence should invoke
reclaim methods as well.

> +			HPAGE_PMD_ORDER);
> +		if (!thp)
> +			return NULL;
> +		prep_transhuge_page(thp);
> +		return thp;
> +	} else
>  		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
>  }
>  
> @@ -1665,8 +1675,8 @@ static int __soft_offline_page(struct page *page, int flags)
>  		 * cannot have PAGE_MAPPING_MOVABLE.
>  		 */
>  		if (!__PageMovable(page))
> -			inc_node_page_state(page, NR_ISOLATED_ANON +
> -						page_is_file_cache(page));
> +			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
> +						page_is_file_cache(page), hpage_nr_pages(page));
>  		list_add(&page->lru, &pagelist);
>  		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>  					MIGRATE_SYNC, MR_MEMORY_FAILURE);
> @@ -1689,28 +1699,11 @@ static int __soft_offline_page(struct page *page, int flags)
>  static int soft_offline_in_use_page(struct page *page, int flags)
>  {
>  	int ret;
> -	struct page *hpage = compound_head(page);
> -
> -	if (!PageHuge(page) && PageTransHuge(hpage)) {
> -		lock_page(hpage);
> -		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
> -			unlock_page(hpage);
> -			if (!PageAnon(hpage))
> -				pr_info("soft offline: %#lx: non anonymous thp\n", page_to_pfn(page));
> -			else
> -				pr_info("soft offline: %#lx: thp split failed\n", page_to_pfn(page));
> -			put_hwpoison_page(hpage);
> -			return -EBUSY;
> -		}
> -		unlock_page(hpage);
> -		get_hwpoison_page(page);
> -		put_hwpoison_page(hpage);
> -	}
>  
>  	if (PageHuge(page))
>  		ret = soft_offline_huge_page(page, flags);
>  	else
> -		ret = __soft_offline_page(page, flags);
> +		ret = __soft_offline_page(compound_head(page), flags);

Hmm, what if the THP allocation fails in the new_page() path and
we fallback for general page allocation. In that case we will
always be still calling with the head page ? Because we dont
split the huge page any more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
