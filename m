Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id E5D506B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 21:03:27 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id u10so377695pdi.9
        for <linux-mm@kvack.org>; Tue, 19 Mar 2013 18:03:26 -0700 (PDT)
Message-ID: <51490AD8.9050308@gmail.com>
Date: Wed, 20 Mar 2013 09:03:20 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/9] memory-hotplug: enable memory hotplug to handle hugepage
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1361475708-25991-9-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1361475708-25991-9-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

Hi Naoya,
On 02/22/2013 03:41 AM, Naoya Horiguchi wrote:
> Currently we can't offline memory blocks which contain hugepages because
> a hugepage is considered as an unmovable page. But now with this patch
> series, a hugepage has become movable, so by using hugepage migration we
> can offline such memory blocks.
>
> What's different from other users of hugepage migration is that we need
> to decompose all the hugepages inside the target memory block into free

For other hugepage migration users, hugepage should be freed to 
hugepage_freelists after migration, but why I don't see any codes do this?

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
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>   include/linux/hugetlb.h |  8 ++++++++
>   mm/hugetlb.c            | 43 +++++++++++++++++++++++++++++++++++++++++
>   mm/memory_hotplug.c     | 51 ++++++++++++++++++++++++++++++++++++++++---------
>   mm/migrate.c            | 12 +++++++++++-
>   mm/page_alloc.c         | 12 ++++++++++++
>   mm/page_isolation.c     |  5 +++++
>   6 files changed, 121 insertions(+), 10 deletions(-)
>
> diff --git v3.8.orig/include/linux/hugetlb.h v3.8/include/linux/hugetlb.h
> index 86a4d78..e33f07f 100644
> --- v3.8.orig/include/linux/hugetlb.h
> +++ v3.8/include/linux/hugetlb.h
> @@ -70,6 +70,7 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
>   void putback_active_hugepage(struct page *page);
>   void putback_active_hugepages(struct list_head *l);
>   void migrate_hugepage_add(struct page *page, struct list_head *list);
> +int is_hugepage_movable(struct page *page);
>   void copy_huge_page(struct page *dst, struct page *src);
>   
>   extern unsigned long hugepages_treat_as_movable;
> @@ -136,6 +137,7 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
>   #define putback_active_hugepage(p) 0
>   #define putback_active_hugepages(l) 0
>   #define migrate_hugepage_add(p, l) 0
> +#define is_hugepage_movable(x) 0
>   static inline void copy_huge_page(struct page *dst, struct page *src)
>   {
>   }
> @@ -358,6 +360,10 @@ static inline int hstate_index(struct hstate *h)
>   	return h - hstates;
>   }
>   
> +extern void dissolve_free_huge_page(struct page *page);
> +extern void dissolve_free_huge_pages(unsigned long start_pfn,
> +				     unsigned long end_pfn);
> +
>   #else
>   struct hstate {};
>   #define alloc_huge_page(v, a, r) NULL
> @@ -378,6 +384,8 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
>   }
>   #define hstate_index_to_shift(index) 0
>   #define hstate_index(h) 0
> +#define dissolve_free_huge_page(p) 0
> +#define dissolve_free_huge_pages(s, e) 0
>   #endif
>   
>   #endif /* _LINUX_HUGETLB_H */
> diff --git v3.8.orig/mm/hugetlb.c v3.8/mm/hugetlb.c
> index ccf9995..c28e6c9 100644
> --- v3.8.orig/mm/hugetlb.c
> +++ v3.8/mm/hugetlb.c
> @@ -843,6 +843,30 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
>   	return ret;
>   }
>   
> +/* Dissolve a given free hugepage into free pages. */
> +void dissolve_free_huge_page(struct page *page)
> +{
> +	if (PageHuge(page) && !page_count(page)) {
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
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += step)
> +		dissolve_free_huge_page(pfn_to_page(pfn));
> +}
> +
>   static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
>   {
>   	struct page *page;
> @@ -3158,6 +3182,25 @@ static int is_hugepage_on_freelist(struct page *hpage)
>   	return 0;
>   }
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
>   /*
>    * This function is called from memory failure code.
>    * Assume the caller holds page lock of the head page.
> diff --git v3.8.orig/mm/memory_hotplug.c v3.8/mm/memory_hotplug.c
> index d04ed87..6418de2 100644
> --- v3.8.orig/mm/memory_hotplug.c
> +++ v3.8/mm/memory_hotplug.c
> @@ -29,6 +29,7 @@
>   #include <linux/suspend.h>
>   #include <linux/mm_inline.h>
>   #include <linux/firmware-map.h>
> +#include <linux/hugetlb.h>
>   
>   #include <asm/tlbflush.h>
>   
> @@ -985,10 +986,12 @@ static int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>   }
>   
>   /*
> - * Scanning pfn is much easier than scanning lru list.
> - * Scan pfn from start to end and Find LRU page.
> + * Scan pfn range [start,end) to find movable/migratable pages (LRU pages
> + * and hugepages). We scan pfn because it's much easier than scanning over
> + * linked list. This function returns the pfn of the first found movable
> + * page if it's found, otherwise 0.
>    */
> -static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
> +static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>   {
>   	unsigned long pfn;
>   	struct page *page;
> @@ -997,6 +1000,12 @@ static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
>   			page = pfn_to_page(pfn);
>   			if (PageLRU(page))
>   				return pfn;
> +			if (PageHuge(page)) {
> +				if (is_hugepage_movable(page))
> +					return pfn;
> +				else
> +					pfn += (1 << compound_order(page)) - 1;
> +			}
>   		}
>   	}
>   	return 0;
> @@ -1019,6 +1028,30 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>   		page = pfn_to_page(pfn);
>   		if (!get_page_unless_zero(page))
>   			continue;
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
> +			list_move_tail(&page->lru, &source);
> +			move_pages -= 1 << compound_order(page);
> +			continue;
> +		}
>   		/*
>   		 * We can skip free pages. And we can only deal with pages on
>   		 * LRU.
> @@ -1049,7 +1082,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>   	}
>   	if (!list_empty(&source)) {
>   		if (not_managed) {
> -			putback_lru_pages(&source);
> +			putback_movable_pages(&source);
>   			goto out;
>   		}
>   
> @@ -1057,11 +1090,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>   		 * alloc_migrate_target should be improooooved!!
>   		 * migrate_pages returns # of failed pages.
>   		 */
> -		ret = migrate_pages(&source, alloc_migrate_target, 0,
> +		ret = migrate_movable_pages(&source, alloc_migrate_target, 0,
>   							true, MIGRATE_SYNC,
>   							MR_MEMORY_HOTPLUG);
> -		if (ret)
> -			putback_lru_pages(&source);
>   	}
>   out:
>   	return ret;
> @@ -1304,8 +1335,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
>   		drain_all_pages();
>   	}
>   
> -	pfn = scan_lru_pages(start_pfn, end_pfn);
> -	if (pfn) { /* We have page on LRU */
> +	pfn = scan_movable_pages(start_pfn, end_pfn);
> +	if (pfn) { /* We have movable pages */
>   		ret = do_migrate_range(pfn, end_pfn);
>   		if (!ret) {
>   			drain = 1;
> @@ -1324,6 +1355,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
>   	yield();
>   	/* drain pcp pages, this is synchronous. */
>   	drain_all_pages();
> +	/* dissolve all free hugepages inside the memory block */
> +	dissolve_free_huge_pages(start_pfn, end_pfn);
>   	/* check again */
>   	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
>   	if (offlined_pages < 0) {
> diff --git v3.8.orig/mm/migrate.c v3.8/mm/migrate.c
> index 8c457e7..a491a98 100644
> --- v3.8.orig/mm/migrate.c
> +++ v3.8/mm/migrate.c
> @@ -1009,8 +1009,18 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>   
>   	unlock_page(hpage);
>   out:
> -	if (rc != -EAGAIN)
> +	if (rc != -EAGAIN) {
>   		putback_active_hugepage(hpage);
> +
> +		/*
> +		 * After hugepage migration from memory hotplug, the original
> +		 * hugepage should never be allocated again. This will be
> +		 * done by dissolving it into free normal pages, because
> +		 * we already set migratetype to MIGRATE_ISOLATE for them.
> +		 */
> +		if (offlining)
> +			dissolve_free_huge_page(hpage);
> +	}
>   	put_page(new_hpage);
>   	if (result) {
>   		if (rc)
> diff --git v3.8.orig/mm/page_alloc.c v3.8/mm/page_alloc.c
> index 6a83cd3..c37951d 100644
> --- v3.8.orig/mm/page_alloc.c
> +++ v3.8/mm/page_alloc.c
> @@ -58,6 +58,7 @@
>   #include <linux/prefetch.h>
>   #include <linux/migrate.h>
>   #include <linux/page-debug-flags.h>
> +#include <linux/hugetlb.h>
>   
>   #include <asm/tlbflush.h>
>   #include <asm/div64.h>
> @@ -5686,6 +5687,17 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>   			continue;
>   
>   		page = pfn_to_page(check);
> +
> +		/*
> +		 * Hugepages are not in LRU lists, but they're movable.
> +		 * We need not scan over tail pages bacause we don't
> +		 * handle each tail page individually in migration.
> +		 */
> +		if (PageHuge(page)) {
> +			iter += (1 << compound_order(page)) - 1;
> +			continue;
> +		}
> +
>   		/*
>   		 * We can't use page_count without pin a page
>   		 * because another CPU can free compound page.
> diff --git v3.8.orig/mm/page_isolation.c v3.8/mm/page_isolation.c
> index 383bdbb..cf48ef6 100644
> --- v3.8.orig/mm/page_isolation.c
> +++ v3.8/mm/page_isolation.c
> @@ -6,6 +6,7 @@
>   #include <linux/page-isolation.h>
>   #include <linux/pageblock-flags.h>
>   #include <linux/memory.h>
> +#include <linux/hugetlb.h>
>   #include "internal.h"
>   
>   int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
> @@ -252,6 +253,10 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
>   {
>   	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
>   
> +	if (PageHuge(page))
> +		return alloc_huge_page_node(page_hstate(compound_head(page)),
> +					    numa_node_id());
> +
>   	if (PageHighMem(page))
>   		gfp_mask |= __GFP_HIGHMEM;
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
