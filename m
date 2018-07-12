Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8376B0006
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 03:47:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x5-v6so10491763edh.8
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 00:47:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 63-v6si3562037edl.217.2018.07.12.00.47.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 00:47:19 -0700 (PDT)
Date: Thu, 12 Jul 2018 09:47:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/hugetlb: remove gigantic page support for HIGHMEM
Message-ID: <20180712074716.GA32648@dhcp22.suse.cz>
References: <20180711195913.1294-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711195913.1294-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Cannon Matthews <cannonmatthews@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 11-07-18 12:59:13, Mike Kravetz wrote:
> This reverts commit ee8f248d266e ("hugetlb: add phys addr to struct
> huge_bootmem_page")
> 
> At one time powerpc used this field and supporting code. However that
> was removed with commit 79cc38ded1e1 ("powerpc/mm/hugetlb: Add support
> for reserving gigantic huge pages via kernel command line").
> 
> There are no users of this field and supporting code, so remove it.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/hugetlb.h | 3 ---
>  mm/hugetlb.c            | 9 +--------
>  2 files changed, 1 insertion(+), 11 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 36fa6a2a82e3..c39d9170a8a0 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -348,9 +348,6 @@ struct hstate {
>  struct huge_bootmem_page {
>  	struct list_head list;
>  	struct hstate *hstate;
> -#ifdef CONFIG_HIGHMEM
> -	phys_addr_t phys;
> -#endif
>  };
>  
>  struct page *alloc_huge_page(struct vm_area_struct *vma,
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 430be42b6ca1..e39593df050b 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2139,16 +2139,9 @@ static void __init gather_bootmem_prealloc(void)
>  	struct huge_bootmem_page *m;
>  
>  	list_for_each_entry(m, &huge_boot_pages, list) {
> +		struct page *page = virt_to_page(m);
>  		struct hstate *h = m->hstate;
> -		struct page *page;
>  
> -#ifdef CONFIG_HIGHMEM
> -		page = pfn_to_page(m->phys >> PAGE_SHIFT);
> -		memblock_free_late(__pa(m),
> -				   sizeof(struct huge_bootmem_page));
> -#else
> -		page = virt_to_page(m);
> -#endif
>  		WARN_ON(page_count(page) != 1);
>  		prep_compound_huge_page(page, h->order);
>  		WARN_ON(PageReserved(page));
> -- 
> 2.17.1

-- 
Michal Hocko
SUSE Labs
