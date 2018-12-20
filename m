Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A31C68E0003
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 23:19:10 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id a9so411164pla.2
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 20:19:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 62sor31286486pla.19.2018.12.19.20.19.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 20:19:08 -0800 (PST)
Subject: Re: [PATCH V5 1/3] mm: Add get_user_pages_cma_migrate
References: <20181219034047.16305-1-aneesh.kumar@linux.ibm.com>
 <20181219034047.16305-2-aneesh.kumar@linux.ibm.com>
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Message-ID: <e9c9b68a-a31b-ab59-902a-73401a89f72a@ozlabs.ru>
Date: Thu, 20 Dec 2018 15:19:00 +1100
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
> +
>  #endif /* CONFIG_MIGRATION */
>  
>  #endif /* _LINUX_MIGRATE_H */
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7f2a28ab46d5..faf3102ae45e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1585,8 +1585,8 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
>  	return page;
>  }
>  
> -static struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
> -		int nid, nodemask_t *nmask)
> +struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
> +				     int nid, nodemask_t *nmask)
>  {
>  	struct page *page;
>  
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f7e4bfdc13b7..d564558fba03 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2946,3 +2946,142 @@ int migrate_vma(const struct migrate_vma_ops *ops,
>  }
>  EXPORT_SYMBOL(migrate_vma);
>  #endif /* defined(MIGRATE_VMA_HELPER) */
> +
> +static struct page *new_non_cma_page(struct page *page, unsigned long private)
> +{
> +	/*
> +	 * We want to make sure we allocate the new page from the same node
> +	 * as the source page.
> +	 */
> +	int nid = page_to_nid(page);
> +	/*
> +	 * Trying to allocate a page for migration. Ignore allocation
> +	 * failure warnings
> +	 */
> +	gfp_t gfp_mask = GFP_USER | __GFP_THISNODE | __GFP_NOWARN;
> +
> +	if (PageHighMem(page))
> +		gfp_mask |= __GFP_HIGHMEM;
> +
> +#ifdef CONFIG_HUGETLB_PAGE
> +	if (PageHuge(page)) {
> +		struct hstate *h = page_hstate(page);
> +		/*
> +		 * We don't want to dequeue from the pool because pool pages will
> +		 * mostly be from the CMA region.
> +		 */
> +		return alloc_migrate_huge_page(h, gfp_mask, nid, NULL);
> +	}
> +#endif
> +	if (PageTransHuge(page)) {
> +		struct page *thp;
> +		/*
> +		 * ignore allocation failure warnings
> +		 */
> +		gfp_t thp_gfpmask = GFP_TRANSHUGE | __GFP_THISNODE | __GFP_NOWARN;
> +
> +		/*
> +		 * Remove the movable mask so that we don't allocate from
> +		 * CMA area again.
> +		 */
> +		thp_gfpmask &= ~__GFP_MOVABLE;
> +		thp = __alloc_pages_node(nid, thp_gfpmask, HPAGE_PMD_ORDER);
> +		if (!thp)
> +			return NULL;
> +		prep_transhuge_page(thp);
> +		return thp;
> +	}
> +
> +	return __alloc_pages_node(nid, gfp_mask, 0);
> +}
> +
> +/**
> + * get_user_pages_cma_migrate() - pin user pages in memory by migrating pages in CMA region
> + * @start:	starting user address
> + * @nr_pages:	number of pages from start to pin
> + * @write:	whether pages will be written to
> + * @pages:	array that receives pointers to the pages pinned.
> + *		Should be at least nr_pages long.
> + *
> + * Attempt to pin user pages in memory without taking mm->mmap_sem.
> + * If not successful, it will fall back to taking the lock and
> + * calling get_user_pages().
> + *
> + * If the pinned pages are backed by CMA region, we migrate those pages out,
> + * allocating new pages from non-CMA region. This helps in avoiding keeping
> + * pages pinned in the CMA region for a long time thereby resulting in
> + * CMA allocation failures.
> + *
> + * Returns number of pages pinned. This may be fewer than the number
> + * requested. If nr_pages is 0 or negative, returns 0. If no pages
> + * were pinned, returns -errno.
> + */
> +
> +int get_user_pages_cma_migrate(unsigned long start, int nr_pages, int write,
> +			       struct page **pages)
> +{
> +	int i, ret;
> +	bool drain_allow = true;
> +	bool migrate_allow = true;
> +	LIST_HEAD(cma_page_list);
> +
> +get_user_again:
> +	ret = get_user_pages_fast(start, nr_pages, write, pages);
> +	if (ret <= 0)
> +		return ret;
> +
> +	for (i = 0; i < ret; ++i) {
> +		/*
> +		 * If we get a page from the CMA zone, since we are going to
> +		 * be pinning these entries, we might as well move them out
> +		 * of the CMA zone if possible.
> +		 */
> +		if (is_migrate_cma_page(pages[i]) && migrate_allow) {
> +
> +			struct page *head = compound_head(pages[i]);
> +
> +			if (PageHuge(head))
> +				isolate_huge_page(head, &cma_page_list);


You need curly braces in both branches as per
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/process/coding-style.rst#n191


> +			else {
> +				if (!PageLRU(head) && drain_allow) {
> +					lru_add_drain_all();
> +					drain_allow = false;
> +				}
> +
> +				if (!isolate_lru_page(head)) {
> +					list_add_tail(&head->lru, &cma_page_list);
> +					mod_node_page_state(page_pgdat(head),
> +							    NR_ISOLATED_ANON +
> +							    page_is_file_cache(head),
> +							    hpage_nr_pages(head));
> +				}
> +			}
> +		}
> +	}
> +	if (!list_empty(&cma_page_list)) {
> +		/*
> +		 * drop the above get_user_pages reference.
> +		 */


Can be a single line comment.

> +		for (i = 0; i < ret; ++i)
> +			put_page(pages[i]);
> +
> +		if (migrate_pages(&cma_page_list, new_non_cma_page,
> +				  NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE)) {
> +			/*
> +			 * some of the pages failed migration. Do get_user_pages
> +			 * without migration.
> +			 */
> +			migrate_allow = false;
> +
> +			if (!list_empty(&cma_page_list))
> +				putback_movable_pages(&cma_page_list);
> +		}
> +		/*
> +		 * We did migrate all the pages, Try to get the page references again
> +		 * migrating any new CMA pages which we failed to isolate earlier.
> +		 */
> +		drain_allow = true;
> +		goto get_user_again;


So it is possible to have pages pinned, then successfully migrated
(migrate_pages() returned 0), then pinned again, then some pages may end
up in CMA again and migrate again and nothing seems to prevent this loop
from being endless. What do I miss?

(ps I hate such "goto"s, confuse a lot)


> +	}
> +	return ret;
> +}
> 

-- 
Alexey
