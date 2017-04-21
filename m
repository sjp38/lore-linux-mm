Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 42A296B03A0
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 04:23:08 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l21so124320929ioi.2
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 01:23:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x12si9595777pls.154.2017.04.21.01.23.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 01:23:07 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3L8J2cs060815
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 04:23:07 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29y27x27qn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 04:23:05 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 21 Apr 2017 18:22:54 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3L8Mijv6488462
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 18:22:52 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3L8MKZY030224
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 18:22:20 +1000
Subject: Re: [PATCH v5 09/11] mm: mempolicy: mbind and migrate_pages support
 thp migration
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-10-zi.yan@sent.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 21 Apr 2017 13:52:00 +0530
MIME-Version: 1.0
In-Reply-To: <20170420204752.79703-10-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <1ebd80d1-7bb1-db6d-a60c-7f4b7b6afe0f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

On 04/21/2017 02:17 AM, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> This patch enables thp migration for mbind(2) and migrate_pages(2).
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
> ChangeLog v1 -> v2:
> - support pte-mapped and doubly-mapped thp
> ---
>  mm/mempolicy.c | 108 +++++++++++++++++++++++++++++++++++++++++----------------
>  1 file changed, 79 insertions(+), 29 deletions(-)

Snip

> @@ -981,7 +1012,17 @@ static struct page *new_node_page(struct page *page, unsigned long node, int **x
>  	if (PageHuge(page))
>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
>  					node);
> -	else
> +	else if (thp_migration_supported() && PageTransHuge(page)) {
> +		struct page *thp;
> +
> +		thp = alloc_pages_node(node,
> +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
> +			HPAGE_PMD_ORDER);
> +		if (!thp)
> +			return NULL;
> +		prep_transhuge_page(thp);
> +		return thp;
> +	} else
>  		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
>  						    __GFP_THISNODE, 0);
>  }
> @@ -1147,6 +1188,15 @@ static struct page *new_page(struct page *page, unsigned long start, int **x)
>  	if (PageHuge(page)) {
>  		BUG_ON(!vma);
>  		return alloc_huge_page_noerr(vma, address, 1);
> +	} else if (thp_migration_supported() && PageTransHuge(page)) {
> +		struct page *thp;
> +
> +		thp = alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
> +					 HPAGE_PMD_ORDER);
> +		if (!thp)
> +			return NULL;
> +		prep_transhuge_page(thp);
> +		return thp;

GFP flags in both these new page allocation functions should be the same.
Does alloc_hugepage_vma() will eventually call page allocation with the
following flags.

(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
