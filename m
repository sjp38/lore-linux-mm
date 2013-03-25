Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id A39866B0080
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 11:09:56 -0400 (EDT)
Date: Mon, 25 Mar 2013 16:09:52 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 09/10] memory-hotplug: enable memory hotplug to handle
 hugepage
Message-ID: <20130325150952.GA2154@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-10-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363983835-20184-10-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri 22-03-13 16:23:54, Naoya Horiguchi wrote:
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
> 
> ChangeLog v2:
>  - changed return value type of is_hugepage_movable() to bool
>  - is_hugepage_movable() uses list_for_each_entry() instead of *_safe()
>  - moved if(PageHuge) block before get_page_unless_zero() in do_migrate_range()
>  - do_migrate_range() returns -EBUSY for hugepages larger than memory block
>  - dissolve_free_huge_pages() calculates scan step and sets it to minimum
>    hugepage size
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/hugetlb.h |  6 +++++
>  mm/hugetlb.c            | 58 +++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/memory_hotplug.c     | 42 +++++++++++++++++++++++++++--------
>  mm/page_alloc.c         | 12 ++++++++++
>  mm/page_isolation.c     |  5 +++++
>  5 files changed, 114 insertions(+), 9 deletions(-)
> 
> diff --git v3.9-rc3.orig/include/linux/hugetlb.h v3.9-rc3/include/linux/hugetlb.h
> index 981eff8..8220a8a 100644
> --- v3.9-rc3.orig/include/linux/hugetlb.h
> +++ v3.9-rc3/include/linux/hugetlb.h
> @@ -69,6 +69,7 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
>  void putback_active_hugepage(struct page *page);
>  void putback_active_hugepages(struct list_head *l);
>  void migrate_hugepage_add(struct page *page, struct list_head *list);
> +bool is_hugepage_movable(struct page *page);
>  void copy_huge_page(struct page *dst, struct page *src);
>  
>  extern unsigned long hugepages_treat_as_movable;
> @@ -134,6 +135,7 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
>  #define putback_active_hugepage(p) 0
>  #define putback_active_hugepages(l) 0
>  #define migrate_hugepage_add(p, l) 0
> +#define is_hugepage_movable(x) 0
>  static inline void copy_huge_page(struct page *dst, struct page *src)
>  {
>  }
> @@ -356,6 +358,9 @@ static inline int hstate_index(struct hstate *h)
>  	return h - hstates;
>  }
>  
> +extern void dissolve_free_huge_pages(unsigned long start_pfn,
> +				     unsigned long end_pfn);
> +
>  #else
>  struct hstate {};
>  #define alloc_huge_page(v, a, r) NULL
> @@ -376,6 +381,7 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
>  }
>  #define hstate_index_to_shift(index) 0
>  #define hstate_index(h) 0
> +#define dissolve_free_huge_pages(s, e) 0
>  #endif
>  
>  #endif /* _LINUX_HUGETLB_H */
> diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
> index d9d3dd7..ef79871 100644
> --- v3.9-rc3.orig/mm/hugetlb.c
> +++ v3.9-rc3/mm/hugetlb.c
> @@ -844,6 +844,36 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
>  	return ret;
>  }
>  
> +/* Dissolve a given free hugepage into free pages. */
> +static void dissolve_free_huge_page(struct page *page)
> +{
> +	spin_lock(&hugetlb_lock);
> +	if (PageHuge(page) && !page_count(page)) {
> +		struct hstate *h = page_hstate(page);
> +		int nid = page_to_nid(page);
> +		list_del(&page->lru);
> +		h->free_huge_pages--;
> +		h->free_huge_pages_node[nid]--;
> +		update_and_free_page(h, page);
> +	}

What about surplus pages?

> +	spin_unlock(&hugetlb_lock);
> +}
> +
> +/* Dissolve free hugepages in a given pfn range. Used by memory hotplug. */
> +void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	unsigned int order = 8 * sizeof(void *);
> +	unsigned long pfn;
> +	struct hstate *h;
> +
> +	/* Set scan step to minimum hugepage size */
> +	for_each_hstate(h)
> +		if (order > huge_page_order(h))
> +			order = huge_page_order(h);
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)
> +		dissolve_free_huge_page(pfn_to_page(pfn));

This assumes that start_pfn doesn't at a tail page otherwise you could
end up traversing only tail pages. This shouldn't happen normally as
start_pfn will be bound to a memblock but it looks a bit fragile.

It is a bit unfortunate that the offlining code is pfn range oriented
while hugetlb pages are organized by nodes.

> +}
> +
>  static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
>  {
>  	struct page *page;
> @@ -3155,6 +3185,34 @@ static int is_hugepage_on_freelist(struct page *hpage)
>  	return 0;
>  }
>  
> +/* Returns true for head pages of in-use hugepages, otherwise returns false. */
> +bool is_hugepage_movable(struct page *hpage)
> +{
> +	struct page *page;
> +	struct hstate *h;
> +	bool ret = false;
> +
> +	VM_BUG_ON(!PageHuge(hpage));
> +	/*
> +	 * This function can be called for a tail page because memory hotplug
> +	 * scans movability of pages by pfn range of a memory block.
> +	 * Larger hugepages (1GB for x86_64) are larger than memory block, so
> +	 * the scan can start at the tail page of larger hugepages.
> +	 * 1GB hugepage is not movable now, so we return with false for now.
> +	 */
> +	if (PageTail(hpage))
> +		return false;
> +	h = page_hstate(hpage);
> +	spin_lock(&hugetlb_lock);
> +	list_for_each_entry(page, &h->hugepage_activelist, lru)
> +		if (page == hpage) {
> +			ret = true;
> +			break;
> +		}

Why are you checking that the page is active? It doesn't make much sense
to me because nothing prevents it from being freed/allocated right after
you release hugetlb_lock.

> +	spin_unlock(&hugetlb_lock);
> +	return ret;
> +}
> +
>  /*
>   * This function is called from memory failure code.
>   * Assume the caller holds page lock of the head page.
> diff --git v3.9-rc3.orig/mm/memory_hotplug.c v3.9-rc3/mm/memory_hotplug.c
> index 9597eec..2d206e8 100644
> --- v3.9-rc3.orig/mm/memory_hotplug.c
> +++ v3.9-rc3/mm/memory_hotplug.c
> @@ -30,6 +30,7 @@
>  #include <linux/mm_inline.h>
>  #include <linux/firmware-map.h>
>  #include <linux/stop_machine.h>
> +#include <linux/hugetlb.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -1215,10 +1216,12 @@ static int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
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
> @@ -1227,6 +1230,12 @@ static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
>  			page = pfn_to_page(pfn);
>  			if (PageLRU(page))
>  				return pfn;
> +			if (PageHuge(page)) {
> +				if (is_hugepage_movable(page))
> +					return pfn;
> +				else
> +					pfn += (1 << compound_order(page)) - 1;

This doesn't look right to me. You have to consider where is your tail
page.
					pfn += (1 << compound_order(page)) - (page - compound_head(page)) - 1;
Or something nicer ;)

> +			}
>  		}
>  	}
>  	return 0;
> @@ -1247,6 +1256,21 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  		if (!pfn_valid(pfn))
>  			continue;
>  		page = pfn_to_page(pfn);
> +
> +		if (PageHuge(page)) {
> +			struct page *head = compound_head(page);
> +			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
> +			if (compound_order(head) > PFN_SECTION_SHIFT) {
> +				ret = -EBUSY;
> +				break;
> +			}
> +			if (!get_page_unless_zero(page))
> +				continue;

s/page/hpage/

> +			list_move_tail(&head->lru, &source);
> +			move_pages -= 1 << compound_order(head);
> +			continue;
> +		}
> +
>  		if (!get_page_unless_zero(page))
>  			continue;
>  		/*
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
