Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id CD2536B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 12:07:40 -0400 (EDT)
Date: Mon, 18 Mar 2013 17:07:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 8/9] memory-hotplug: enable memory hotplug to handle
 hugepage
Message-ID: <20130318160737.GU10192@dhcp22.suse.cz>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-9-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1361475708-25991-9-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Thu 21-02-13 14:41:47, Naoya Horiguchi wrote:
> Currently we can't offline memory blocks which contain hugepages because
> a hugepage is considered as an unmovable page. But now with this patch
> series, a hugepage has become movable, so by using hugepage migration we
> can offline such memory blocks.
> 
> What's different from other users of hugepage migration is that we need
> to decompose all the hugepages inside the target memory block into free
> buddy pages after hugepage migration, because otherwise free hugepages
> remaining in the memory block intervene the memory offlining.
> For this reason we introduce new functions dissolve_free_huge_page() and
> dissolve_free_huge_pages().
> 
> Other than that, what this patch does is straightforwardly to add hugepage
> migration code, that is, adding hugepage code to the functions which scan
> over pfn and collect hugepages to be migrated, and adding a hugepage
> allocation function to alloc_migrate_target().
> 
> As for larger hugepages (1GB for x86_64), it's not easy to do hotremove
> over them because it's larger than memory block. So we now simply leave
> it to fail as it is.

What we could do is to check whether there is a free gb huge page on
other node and migrate there.

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/hugetlb.h |  8 ++++++++
>  mm/hugetlb.c            | 43 +++++++++++++++++++++++++++++++++++++++++
>  mm/memory_hotplug.c     | 51 ++++++++++++++++++++++++++++++++++++++++---------
>  mm/migrate.c            | 12 +++++++++++-
>  mm/page_alloc.c         | 12 ++++++++++++
>  mm/page_isolation.c     |  5 +++++
>  6 files changed, 121 insertions(+), 10 deletions(-)
> 
> diff --git v3.8.orig/include/linux/hugetlb.h v3.8/include/linux/hugetlb.h
> index 86a4d78..e33f07f 100644
> --- v3.8.orig/include/linux/hugetlb.h
> +++ v3.8/include/linux/hugetlb.h
> @@ -70,6 +70,7 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
>  void putback_active_hugepage(struct page *page);
>  void putback_active_hugepages(struct list_head *l);
>  void migrate_hugepage_add(struct page *page, struct list_head *list);
> +int is_hugepage_movable(struct page *page);
>  void copy_huge_page(struct page *dst, struct page *src);
>  
>  extern unsigned long hugepages_treat_as_movable;
> @@ -136,6 +137,7 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
>  #define putback_active_hugepage(p) 0
>  #define putback_active_hugepages(l) 0
>  #define migrate_hugepage_add(p, l) 0
> +#define is_hugepage_movable(x) 0
>  static inline void copy_huge_page(struct page *dst, struct page *src)
>  {
>  }
> @@ -358,6 +360,10 @@ static inline int hstate_index(struct hstate *h)
>  	return h - hstates;
>  }
>  
> +extern void dissolve_free_huge_page(struct page *page);
> +extern void dissolve_free_huge_pages(unsigned long start_pfn,
> +				     unsigned long end_pfn);
> +
>  #else
>  struct hstate {};
>  #define alloc_huge_page(v, a, r) NULL
> @@ -378,6 +384,8 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
>  }
>  #define hstate_index_to_shift(index) 0
>  #define hstate_index(h) 0
> +#define dissolve_free_huge_page(p) 0
> +#define dissolve_free_huge_pages(s, e) 0
>  #endif
>  
>  #endif /* _LINUX_HUGETLB_H */
> diff --git v3.8.orig/mm/hugetlb.c v3.8/mm/hugetlb.c
> index ccf9995..c28e6c9 100644
> --- v3.8.orig/mm/hugetlb.c
> +++ v3.8/mm/hugetlb.c
> @@ -843,6 +843,30 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
>  	return ret;
>  }
>  
> +/* Dissolve a given free hugepage into free pages. */
> +void dissolve_free_huge_page(struct page *page)
> +{
> +	if (PageHuge(page) && !page_count(page)) {

Could you clarify why you are cheking page_count here? I assume it is to
make sure the page is free but what prevents it being increased before
you take hugetlb_lock?

> +		struct hstate *h = page_hstate(page);
> +		int nid = page_to_nid(page);
> +		spin_lock(&hugetlb_lock);
> +		list_del(&page->lru);
> +		h->free_huge_pages--;
> +		h->free_huge_pages_node[nid]--;
> +		update_and_free_page(h, page);
> +		spin_unlock(&hugetlb_lock);
> +	}
> +}
> +
> +/* Dissolve free hugepages in a given pfn range. Used by memory hotplug. */
> +void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	unsigned long pfn;
> +	unsigned int step = 1 << (HUGETLB_PAGE_ORDER);

hugetlb pages could be present in different sizes so this doesn't work
in general. You need to to get order from page_hstate.

> +	for (pfn = start_pfn; pfn < end_pfn; pfn += step)
> +		dissolve_free_huge_page(pfn_to_page(pfn));
> +}
> +
>  static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
>  {
>  	struct page *page;
> @@ -3158,6 +3182,25 @@ static int is_hugepage_on_freelist(struct page *hpage)
>  	return 0;
>  }
>  
> +/* Returns true for head pages of in-use hugepages, otherwise returns false. */
> +int is_hugepage_movable(struct page *hpage)
> +{
> +	struct page *page;
> +	struct page *tmp;
> +	struct hstate *h = page_hstate(hpage);
> +	int ret = 0;
> +
> +	VM_BUG_ON(!PageHuge(hpage));
> +	if (PageTail(hpage))
> +		return 0;
> +	spin_lock(&hugetlb_lock);
> +	list_for_each_entry_safe(page, tmp, &h->hugepage_activelist, lru)
> +		if (page == hpage)
> +			ret = 1;
> +	spin_unlock(&hugetlb_lock);
> +	return ret;
> +}
> +
>  /*
>   * This function is called from memory failure code.
>   * Assume the caller holds page lock of the head page.
> diff --git v3.8.orig/mm/memory_hotplug.c v3.8/mm/memory_hotplug.c
> index d04ed87..6418de2 100644
> --- v3.8.orig/mm/memory_hotplug.c
> +++ v3.8/mm/memory_hotplug.c
> @@ -29,6 +29,7 @@
>  #include <linux/suspend.h>
>  #include <linux/mm_inline.h>
>  #include <linux/firmware-map.h>
> +#include <linux/hugetlb.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -985,10 +986,12 @@ static int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>  }
>  
>  /*
> - * Scanning pfn is much easier than scanning lru list.
> - * Scan pfn from start to end and Find LRU page.
> + * Scan pfn range [start,end) to find movable/migratable pages (LRU pages
> + * and hugepages). We scan pfn because it's much easier than scanning over
> + * linked list. This function returns the pfn of the first found movable
> + * page if it's found, otherwise 0.
>   */
> -static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
> +static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  {
>  	unsigned long pfn;
>  	struct page *page;
> @@ -997,6 +1000,12 @@ static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
>  			page = pfn_to_page(pfn);
>  			if (PageLRU(page))
>  				return pfn;
> +			if (PageHuge(page)) {
> +				if (is_hugepage_movable(page))
> +					return pfn;
> +				else
> +					pfn += (1 << compound_order(page)) - 1;
> +			}

scan_lru_pages's name gets really confusing after this change because
hugetlb pages are not on the LRU. Maybe it would be good to rename it.

>  		}
>  	}
>  	return 0;
> @@ -1019,6 +1028,30 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  		page = pfn_to_page(pfn);
>  		if (!get_page_unless_zero(page))
>  			continue;

All tail pages have 0 reference count (according to prep_compound_page)
so they would be skipped anyway. This makes the below pfn tweaks
pointless.

> +		if (PageHuge(page)) {
> +			/*
> +			 * Larger hugepage (1GB for x86_64) is larger than
> +			 * memory block, so pfn scan can start at the tail
> +			 * page of larger hugepage. In such case,
> +			 * we simply skip the hugepage and move the cursor
> +			 * to the last tail page.
> +			 */
> +			if (PageTail(page)) {
> +				struct page *head = compound_head(page);
> +				pfn = page_to_pfn(head) +
> +					(1 << compound_order(head)) - 1;
> +				put_page(page);
> +				continue;
> +			}
> +			pfn = (1 << compound_order(page)) - 1;
> +			if (huge_page_size(page_hstate(page)) != PMD_SIZE) {
> +				put_page(page);
> +				continue;
> +			}

There might be other hugepage sizes which fit into memblock so this test
doesn't seem right.

> +			list_move_tail(&page->lru, &source);
> +			move_pages -= 1 << compound_order(page);
> +			continue;
> +		}
>  		/*
>  		 * We can skip free pages. And we can only deal with pages on
>  		 * LRU.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
