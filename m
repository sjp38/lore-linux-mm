Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8D086B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 18:35:48 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id w198so2236481qka.3
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 15:35:48 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id q7si3154359qtg.60.2017.12.13.15.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 15:35:47 -0800 (PST)
Subject: Re: [RFC PATCH 3/5] mm, hugetlb: do not rely on overcommit limit
 during migration
References: <20171204140117.7191-1-mhocko@kernel.org>
 <20171204140117.7191-4-mhocko@kernel.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ec386202-9bee-e230-1b37-bc05c4cd8f49@oracle.com>
Date: Wed, 13 Dec 2017 15:35:33 -0800
MIME-Version: 1.0
In-Reply-To: <20171204140117.7191-4-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 12/04/2017 06:01 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> hugepage migration relies on __alloc_buddy_huge_page to get a new page.
> This has 2 main disadvantages.
> 1) it doesn't allow to migrate any huge page if the pool is used
> completely which is not an exceptional case as the pool is static and
> unused memory is just wasted.
> 2) it leads to a weird semantic when migration between two numa nodes
> might increase the pool size of the destination NUMA node while the page
> is in use. The issue is caused by per NUMA node surplus pages tracking
> (see free_huge_page).
> 
> Address both issues by changing the way how we allocate and account
> pages allocated for migration. Those should temporal by definition.
> So we mark them that way (we will abuse page flags in the 3rd page)
> and update free_huge_page to free such pages to the page allocator.
> Page migration path then just transfers the temporal status from the
> new page to the old one which will be freed on the last reference.
> The global surplus count will never change during this path

The global and per-node user visible count of huge pages will be
temporarily increased by one during this path.  This should not
be an issue.

>                                                             but we still
> have to be careful when migrating a per-node suprlus page. This is now
> handled in move_hugetlb_state which is called from the migration path
> and it copies the hugetlb specific page state and fixes up the
> accounting when needed
> 
> Rename __alloc_buddy_huge_page to __alloc_surplus_huge_page to better
> reflect its purpose. The new allocation routine for the migration path
> is __alloc_migrate_huge_page.
> 
> The user visible effect of this patch is that migrated pages are really
> temporal and they travel between NUMA nodes as per the migration
> request:
> Before migration
> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/free_hugepages:0
> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:1
> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/surplus_hugepages:0
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/free_hugepages:0
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:0
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/surplus_hugepages:0
> 
> After
> 
> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/free_hugepages:0
> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:0
> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/surplus_hugepages:0
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/free_hugepages:0
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:1
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/surplus_hugepages:0
> 
> with the previous implementation, both nodes would have nr_hugepages:1
> until the page is freed.

With the previous implementation, the migration would have failed unless
nr_overcommit_hugepages was explicitly set.  Correct?

> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/hugetlb.h |   3 ++
>  mm/hugetlb.c            | 111 +++++++++++++++++++++++++++++++++++++++++-------
>  mm/migrate.c            |   3 +-
>  3 files changed, 99 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 6e3696c7b35a..1a9c89850e4a 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -119,6 +119,7 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
>  						long freed);
>  bool isolate_huge_page(struct page *page, struct list_head *list);
>  void putback_active_hugepage(struct page *page);
> +void move_hugetlb_state(struct page *oldpage, struct page *newpage, int reason);
>  void free_huge_page(struct page *page);
>  void hugetlb_fix_reserve_counts(struct inode *inode);
>  extern struct mutex *hugetlb_fault_mutex_table;
> @@ -157,6 +158,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  		unsigned long address, unsigned long end, pgprot_t newprot);
>  
>  bool is_hugetlb_entry_migration(pte_t pte);
> +
>  #else /* !CONFIG_HUGETLB_PAGE */
>  
>  static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
> @@ -197,6 +199,7 @@ static inline bool isolate_huge_page(struct page *page, struct list_head *list)
>  	return false;
>  }
>  #define putback_active_hugepage(p)	do {} while (0)
> +#define move_hugetlb_state(old, new, reason)	do {} while (0)
>  
>  static inline unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  		unsigned long address, unsigned long end, pgprot_t newprot)
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ac105fb32620..a1b8b2888ec9 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -34,6 +34,7 @@
>  #include <linux/hugetlb_cgroup.h>
>  #include <linux/node.h>
>  #include <linux/userfaultfd_k.h>
> +#include <linux/page_owner.h>
>  #include "internal.h"
>  
>  int hugetlb_max_hstate __read_mostly;
> @@ -1217,6 +1218,28 @@ static void clear_page_huge_active(struct page *page)
>  	ClearPagePrivate(&page[1]);
>  }
>  
> +/*
> + * Internal hugetlb specific page flag. Do not use outside of the hugetlb
> + * code
> + */
> +static inline bool PageHugeTemporary(struct page *page)
> +{
> +	if (!PageHuge(page))
> +		return false;
> +
> +	return (unsigned long)page[2].mapping == -1U;
> +}
> +
> +static inline void SetPageHugeTemporary(struct page *page)
> +{
> +	page[2].mapping = (void *)-1U;
> +}
> +
> +static inline void ClearPageHugeTemporary(struct page *page)
> +{
> +	page[2].mapping = NULL;
> +}
> +
>  void free_huge_page(struct page *page)
>  {
>  	/*
> @@ -1251,7 +1274,11 @@ void free_huge_page(struct page *page)
>  	if (restore_reserve)
>  		h->resv_huge_pages++;
>  
> -	if (h->surplus_huge_pages_node[nid]) {
> +	if (PageHugeTemporary(page)) {
> +		list_del(&page->lru);
> +		ClearPageHugeTemporary(page);
> +		update_and_free_page(h, page);
> +	} else if (h->surplus_huge_pages_node[nid]) {
>  		/* remove the page from active list */
>  		list_del(&page->lru);
>  		update_and_free_page(h, page);
> @@ -1505,7 +1532,10 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  	return rc;
>  }
>  
> -static struct page *__alloc_buddy_huge_page(struct hstate *h, gfp_t gfp_mask,
> +/*
> + * Allocates a fresh surplus page from the page allocator.
> + */
> +static struct page *__alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
>  		int nid, nodemask_t *nmask)
>  {
>  	struct page *page;
> @@ -1569,6 +1599,28 @@ static struct page *__alloc_buddy_huge_page(struct hstate *h, gfp_t gfp_mask,
>  	return page;
>  }
>  
> +static struct page *__alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
> +		int nid, nodemask_t *nmask)
> +{
> +	struct page *page;
> +
> +	if (hstate_is_gigantic(h))
> +		return NULL;
> +
> +	page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask, nid, nmask);
> +	if (!page)
> +		return NULL;
> +
> +	/*
> +	 * We do not account these pages as surplus because they are only
> +	 * temporary and will be released properly on the last reference
> +	 */
> +	prep_new_huge_page(h, page, page_to_nid(page));
> +	SetPageHugeTemporary(page);
> +
> +	return page;
> +}
> +
>  /*
>   * Use the VMA's mpolicy to allocate a huge page from the buddy.
>   */
> @@ -1583,17 +1635,13 @@ struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
>  	nodemask_t *nodemask;
>  
>  	nid = huge_node(vma, addr, gfp_mask, &mpol, &nodemask);
> -	page = __alloc_buddy_huge_page(h, gfp_mask, nid, nodemask);
> +	page = __alloc_surplus_huge_page(h, gfp_mask, nid, nodemask);
>  	mpol_cond_put(mpol);
>  
>  	return page;
>  }
>  
> -/*
> - * This allocation function is useful in the context where vma is irrelevant.
> - * E.g. soft-offlining uses this function because it only cares physical
> - * address of error page.
> - */
> +/* page migration callback function */
>  struct page *alloc_huge_page_node(struct hstate *h, int nid)
>  {
>  	gfp_t gfp_mask = htlb_alloc_mask(h);
> @@ -1608,12 +1656,12 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
>  	spin_unlock(&hugetlb_lock);
>  
>  	if (!page)
> -		page = __alloc_buddy_huge_page(h, gfp_mask, nid, NULL);
> +		page = __alloc_migrate_huge_page(h, gfp_mask, nid, NULL);
>  
>  	return page;
>  }
>  
> -
> +/* page migration callback function */
>  struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
>  		nodemask_t *nmask)
>  {
> @@ -1631,9 +1679,7 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
>  	}
>  	spin_unlock(&hugetlb_lock);
>  
> -	/* No reservations, try to overcommit */
> -
> -	return __alloc_buddy_huge_page(h, gfp_mask, preferred_nid, nmask);
> +	return __alloc_migrate_huge_page(h, gfp_mask, preferred_nid, nmask);
>  }
>  
>  /*
> @@ -1661,7 +1707,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
>  retry:
>  	spin_unlock(&hugetlb_lock);
>  	for (i = 0; i < needed; i++) {
> -		page = __alloc_buddy_huge_page(h, htlb_alloc_mask(h),
> +		page = __alloc_surplus_huge_page(h, htlb_alloc_mask(h),
>  				NUMA_NO_NODE, NULL);
>  		if (!page) {
>  			alloc_ok = false;
> @@ -2258,7 +2304,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>  	 * First take pages out of surplus state.  Then make up the
>  	 * remaining difference by allocating fresh huge pages.
>  	 *
> -	 * We might race with __alloc_buddy_huge_page() here and be unable
> +	 * We might race with __alloc_surplus_huge_page() here and be unable
>  	 * to convert a surplus huge page to a normal huge page. That is
>  	 * not critical, though, it just means the overall size of the
>  	 * pool might be one hugepage larger than it needs to be, but
> @@ -2301,7 +2347,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>  	 * By placing pages into the surplus state independent of the
>  	 * overcommit value, we are allowing the surplus pool size to
>  	 * exceed overcommit. There are few sane options here. Since
> -	 * __alloc_buddy_huge_page() is checking the global counter,
> +	 * __alloc_surplus_huge_page() is checking the global counter,
>  	 * though, we'll note that we're not allowed to exceed surplus
>  	 * and won't grow the pool anywhere else. Not until one of the
>  	 * sysctls are changed, or the surplus pages go out of use.
> @@ -4775,3 +4821,36 @@ void putback_active_hugepage(struct page *page)
>  	spin_unlock(&hugetlb_lock);
>  	put_page(page);
>  }
> +
> +void move_hugetlb_state(struct page *oldpage, struct page *newpage, int reason)
> +{
> +	struct hstate *h = page_hstate(oldpage);
> +
> +	hugetlb_cgroup_migrate(oldpage, newpage);
> +	set_page_owner_migrate_reason(newpage, reason);
> +
> +	/*
> +	 * transfer temporary state of the new huge page. This is
> +	 * reverse to other transitions because the newpage is going to
> +	 * be final while the old one will be freed so it takes over
> +	 * the temporary status.
> +	 *
> +	 * Also note that we have to transfer the per-node surplus state
> +	 * here as well otherwise the global surplus count will not match
> +	 * the per-node's.
> +	 */
> +	if (PageHugeTemporary(newpage)) {
> +		int old_nid = page_to_nid(oldpage);
> +		int new_nid = page_to_nid(newpage);
> +
> +		SetPageHugeTemporary(oldpage);
> +		ClearPageHugeTemporary(newpage);
> +
> +		spin_lock(&hugetlb_lock);
> +		if (h->surplus_huge_pages_node[old_nid]) {
> +			h->surplus_huge_pages_node[old_nid]--;
> +			h->surplus_huge_pages_node[new_nid]++;
> +		}
> +		spin_unlock(&hugetlb_lock);
> +	}
> +}

In the previous version of this patch, I asked about handling of 'free' huge
pages.  I did a little digging and IIUC, we do not attempt migration of
free huge pages.  The routine isolate_huge_page() has this check:

        if (!page_huge_active(page) || !get_page_unless_zero(page)) {
                ret = false;
                goto unlock;
        }

I believe one of your motivations for this effort was memory offlining.
So, this implies that a memory area can not be offlined if it contains
a free (not in use) huge page?  Just FYI and may be something we want to
address later.

My other issues were addressed.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> diff --git a/mm/migrate.c b/mm/migrate.c
> index 4d0be47a322a..1e5525a25691 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1323,9 +1323,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  		put_anon_vma(anon_vma);
>  
>  	if (rc == MIGRATEPAGE_SUCCESS) {
> -		hugetlb_cgroup_migrate(hpage, new_hpage);
> +		move_hugetlb_state(hpage, new_hpage, reason);
>  		put_new_page = NULL;
> -		set_page_owner_migrate_reason(new_hpage, reason);
>  	}
>  
>  	unlock_page(hpage);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
