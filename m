Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2728E0003
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 23:29:01 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v2so416013plg.6
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 20:29:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i10sor31262172plt.38.2018.12.19.20.28.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 20:28:59 -0800 (PST)
Subject: Re: [PATCH V5 1/3] mm: Add get_user_pages_cma_migrate
References: <20181219034047.16305-1-aneesh.kumar@linux.ibm.com>
 <20181219034047.16305-2-aneesh.kumar@linux.ibm.com>
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Message-ID: <da69679a-9455-aea6-6d3c-f36c2b8c641b@ozlabs.ru>
Date: Thu, 20 Dec 2018 15:28:52 +1100
MIME-Version: 1.0
In-Reply-To: <20181219034047.16305-2-aneesh.kumar@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, mpe@ellerman.id.au, paulus@samba.org, David Gibson <david@gibson.dropbear.id.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org



On 19/12/2018 14:40, Aneesh Kumar K.V wrote:
> This helper does a get_user_pages_fast and if it find pages in the CMA area
> it will try to migrate them before taking page reference. This makes sure that
> we don't keep non-movable pages (due to page reference count) in the CMA area.
> Not able to move pages out of CMA area result in CMA allocation failures.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  include/linux/hugetlb.h |   2 +
>  include/linux/migrate.h |   3 +
>  mm/hugetlb.c            |   4 +-
>  mm/migrate.c            | 139 ++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 146 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 087fd5f48c91..1eed0cdaec0e 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -371,6 +371,8 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
>  				nodemask_t *nmask);
>  struct page *alloc_huge_page_vma(struct hstate *h, struct vm_area_struct *vma,
>  				unsigned long address);
> +struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
> +				     int nid, nodemask_t *nmask);
>  int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
>  			pgoff_t idx);
>  
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index f2b4abbca55e..d82b35afd2eb 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -286,6 +286,9 @@ static inline int migrate_vma(const struct migrate_vma_ops *ops,
>  }
>  #endif /* IS_ENABLED(CONFIG_MIGRATE_VMA_HELPER) */
>  
> +extern int get_user_pages_cma_migrate(unsigned long start, int nr_pages, int write,
> +				      struct page **pages);


ah, sorry for commenting the same patch again but
./scripts/checkpatch.pl complains a log on this patch.


-- 
Alexey
