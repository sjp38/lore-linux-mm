Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id A1E466B0039
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 16:07:31 -0400 (EDT)
Date: Tue, 09 Apr 2013 16:07:16 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1365538036-pu7x5mck-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <515F68BB.3010601@gmail.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <515F68BB.3010601@gmail.com>
Subject: Re: [PATCH 09/10] memory-hotplug: enable memory hotplug to handle
 hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org

On Fri, Apr 05, 2013 at 08:13:47PM -0400, KOSAKI Motohiro wrote:
> (3/22/13 4:23 PM), Naoya Horiguchi wrote:
> > Currently we can't offline memory blocks which contain hugepages because
> > a hugepage is considered as an unmovable page. But now with this patch
> > series, a hugepage has become movable, so by using hugepage migration we
> > can offline such memory blocks.
> > 
> > What's different from other users of hugepage migration is that we need
> > to decompose all the hugepages inside the target memory block into free
> > buddy pages after hugepage migration, because otherwise free hugepages
> > remaining in the memory block intervene the memory offlining.
> > For this reason we introduce new functions dissolve_free_huge_page() and
> > dissolve_free_huge_pages().
> > 
> > Other than that, what this patch does is straightforwardly to add hugepage
> > migration code, that is, adding hugepage code to the functions which scan
> > over pfn and collect hugepages to be migrated, and adding a hugepage
> > allocation function to alloc_migrate_target().
> > 
> > As for larger hugepages (1GB for x86_64), it's not easy to do hotremove
> > over them because it's larger than memory block. So we now simply leave
> > it to fail as it is.
> > 
> > ChangeLog v2:
> >  - changed return value type of is_hugepage_movable() to bool
> >  - is_hugepage_movable() uses list_for_each_entry() instead of *_safe()
> >  - moved if(PageHuge) block before get_page_unless_zero() in do_migrate_range()
> >  - do_migrate_range() returns -EBUSY for hugepages larger than memory block
> >  - dissolve_free_huge_pages() calculates scan step and sets it to minimum
> >    hugepage size
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  include/linux/hugetlb.h |  6 +++++
> >  mm/hugetlb.c            | 58 +++++++++++++++++++++++++++++++++++++++++++++++++
> >  mm/memory_hotplug.c     | 42 +++++++++++++++++++++++++++--------
> >  mm/page_alloc.c         | 12 ++++++++++
> >  mm/page_isolation.c     |  5 +++++
> >  5 files changed, 114 insertions(+), 9 deletions(-)
> > 
> > diff --git v3.9-rc3.orig/include/linux/hugetlb.h v3.9-rc3/include/linux/hugetlb.h
> > index 981eff8..8220a8a 100644
> > --- v3.9-rc3.orig/include/linux/hugetlb.h
> > +++ v3.9-rc3/include/linux/hugetlb.h
> > @@ -69,6 +69,7 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
> >  void putback_active_hugepage(struct page *page);
> >  void putback_active_hugepages(struct list_head *l);
> >  void migrate_hugepage_add(struct page *page, struct list_head *list);
> > +bool is_hugepage_movable(struct page *page);
> >  void copy_huge_page(struct page *dst, struct page *src);
> >  
> >  extern unsigned long hugepages_treat_as_movable;
> > @@ -134,6 +135,7 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
> >  #define putback_active_hugepage(p) 0
> >  #define putback_active_hugepages(l) 0
> >  #define migrate_hugepage_add(p, l) 0
> > +#define is_hugepage_movable(x) 0
> 
> should be false instaed of 0.

OK.

> 
> >  static inline void copy_huge_page(struct page *dst, struct page *src)
> >  {
> >  }
> > @@ -356,6 +358,9 @@ static inline int hstate_index(struct hstate *h)
> >  	return h - hstates;
> >  }
> >  
> > +extern void dissolve_free_huge_pages(unsigned long start_pfn,
> > +				     unsigned long end_pfn);
> > +
> >  #else
> >  struct hstate {};
> >  #define alloc_huge_page(v, a, r) NULL
> > @@ -376,6 +381,7 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
> >  }
> >  #define hstate_index_to_shift(index) 0
> >  #define hstate_index(h) 0
> > +#define dissolve_free_huge_pages(s, e) 0
> 
> no need 0.

OK.

> >  #endif
> >  
> >  #endif /* _LINUX_HUGETLB_H */
> > diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
> > index d9d3dd7..ef79871 100644
> > --- v3.9-rc3.orig/mm/hugetlb.c
> > +++ v3.9-rc3/mm/hugetlb.c
> > @@ -844,6 +844,36 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
> >  	return ret;
> >  }
> >  
> > +/* Dissolve a given free hugepage into free pages. */
> > +static void dissolve_free_huge_page(struct page *page)
> > +{
> > +	spin_lock(&hugetlb_lock);
> > +	if (PageHuge(page) && !page_count(page)) {
> > +		struct hstate *h = page_hstate(page);
> > +		int nid = page_to_nid(page);
> > +		list_del(&page->lru);
> > +		h->free_huge_pages--;
> > +		h->free_huge_pages_node[nid]--;
> > +		update_and_free_page(h, page);
> > +	}
> > +	spin_unlock(&hugetlb_lock);
> > +}
> > +
> > +/* Dissolve free hugepages in a given pfn range. Used by memory hotplug. */
> > +void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
> > +{
> > +	unsigned int order = 8 * sizeof(void *);
> > +	unsigned long pfn;
> > +	struct hstate *h;
> > +
> > +	/* Set scan step to minimum hugepage size */
> > +	for_each_hstate(h)
> > +		if (order > huge_page_order(h))
> > +			order = huge_page_order(h);
> > +	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)
> > +		dissolve_free_huge_page(pfn_to_page(pfn));
> > +}
> 
> hotplug.c must not have such pure huge page function.

This code is put in mm/hugetlb.c.

> >  {
> >  	struct page *page;
> > @@ -3155,6 +3185,34 @@ static int is_hugepage_on_freelist(struct page *hpage)
> >  	return 0;
> >  }
> >  
> > +/* Returns true for head pages of in-use hugepages, otherwise returns false. */
> > +bool is_hugepage_movable(struct page *hpage)
> > +{
> > +	struct page *page;
> > +	struct hstate *h;
> > +	bool ret = false;
> > +
> > +	VM_BUG_ON(!PageHuge(hpage));
> > +	/*
> > +	 * This function can be called for a tail page because memory hotplug
> > +	 * scans movability of pages by pfn range of a memory block.
> > +	 * Larger hugepages (1GB for x86_64) are larger than memory block, so
> > +	 * the scan can start at the tail page of larger hugepages.
> > +	 * 1GB hugepage is not movable now, so we return with false for now.
> > +	 */
> > +	if (PageTail(hpage))
> > +		return false;
> > +	h = page_hstate(hpage);
> > +	spin_lock(&hugetlb_lock);
> > +	list_for_each_entry(page, &h->hugepage_activelist, lru)
> > +		if (page == hpage) {
> > +			ret = true;
> > +			break;
> > +		}
> > +	spin_unlock(&hugetlb_lock);
> > +	return ret;
> > +}
> > +
> >  /*
> >   * This function is called from memory failure code.
> >   * Assume the caller holds page lock of the head page.
> > diff --git v3.9-rc3.orig/mm/memory_hotplug.c v3.9-rc3/mm/memory_hotplug.c
> > index 9597eec..2d206e8 100644
> > --- v3.9-rc3.orig/mm/memory_hotplug.c
> > +++ v3.9-rc3/mm/memory_hotplug.c
> > @@ -30,6 +30,7 @@
> >  #include <linux/mm_inline.h>
> >  #include <linux/firmware-map.h>
> >  #include <linux/stop_machine.h>
> > +#include <linux/hugetlb.h>
> >  
> >  #include <asm/tlbflush.h>
> >  
> > @@ -1215,10 +1216,12 @@ static int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
> >  }
> >  
> >  /*
> > - * Scanning pfn is much easier than scanning lru list.
> > - * Scan pfn from start to end and Find LRU page.
> > + * Scan pfn range [start,end) to find movable/migratable pages (LRU pages
> > + * and hugepages). We scan pfn because it's much easier than scanning over
> > + * linked list. This function returns the pfn of the first found movable
> > + * page if it's found, otherwise 0.
> >   */
> > -static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
> > +static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
> 
> We can kill scan_lru_pages() completely. That's mere minor optimization and memory
> hotremove it definitely not hot path.

OK.

> 
> >  {
> >  	unsigned long pfn;
> >  	struct page *page;
> > @@ -1227,6 +1230,12 @@ static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
> >  			page = pfn_to_page(pfn);
> >  			if (PageLRU(page))
> >  				return pfn;
> > +			if (PageHuge(page)) {
> > +				if (is_hugepage_movable(page))
> > +					return pfn;
> > +				else
> > +					pfn += (1 << compound_order(page)) - 1;
> > +			}
> >  		}
> >  	}
> >  	return 0;
> > @@ -1247,6 +1256,21 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> >  		if (!pfn_valid(pfn))
> >  			continue;
> >  		page = pfn_to_page(pfn);
> > +
> > +		if (PageHuge(page)) {
> > +			struct page *head = compound_head(page);
> > +			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
> > +			if (compound_order(head) > PFN_SECTION_SHIFT) {
> > +				ret = -EBUSY;
> > +				break;
> > +			}
> > +			if (!get_page_unless_zero(page))
> > +				continue;
> > +			list_move_tail(&head->lru, &source);
> > +			move_pages -= 1 << compound_order(head);
> > +			continue;
> > +		}
> > +
> >  		if (!get_page_unless_zero(page))
> >  			continue;
> >  		/*
> > @@ -1279,7 +1303,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> >  	}
> >  	if (!list_empty(&source)) {
> >  		if (not_managed) {
> > -			putback_lru_pages(&source);
> > +			putback_movable_pages(&source);
> >  			goto out;
> >  		}
> >  
> > @@ -1287,10 +1311,8 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> >  		 * alloc_migrate_target should be improooooved!!
> >  		 * migrate_pages returns # of failed pages.
> >  		 */
> > -		ret = migrate_pages(&source, alloc_migrate_target, 0,
> > +		ret = migrate_movable_pages(&source, alloc_migrate_target, 0,
> >  					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
> > -		if (ret)
> > -			putback_lru_pages(&source);
> >  	}
> >  out:
> >  	return ret;
> > @@ -1533,8 +1555,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
> >  		drain_all_pages();
> >  	}
> 
> After applying your patch, __offline_pages() free hugetlb persistent and surplus pages. 
> Thus this should allocate same size huge pages on other nodes.
> Otherwise, total hugepages implicitely decrease and application may crash after offline page
> success.

I'm not sure that this should be done in kernel, because the user processes
which trigger page migration should know more about what they want.
It seems to me more reasonable that we leave it for userspace.

> 
> >  
> > -	pfn = scan_lru_pages(start_pfn, end_pfn);
> > -	if (pfn) { /* We have page on LRU */
> > +	pfn = scan_movable_pages(start_pfn, end_pfn);
> > +	if (pfn) { /* We have movable pages */
> >  		ret = do_migrate_range(pfn, end_pfn);
> >  		if (!ret) {
> >  			drain = 1;
> > @@ -1553,6 +1575,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
> >  	yield();
> >  	/* drain pcp pages, this is synchronous. */
> >  	drain_all_pages();
> > +	/* dissolve all free hugepages inside the memory block */
> > +	dissolve_free_huge_pages(start_pfn, end_pfn);
> >  	/* check again */
> >  	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
> >  	if (offlined_pages < 0) {
> > diff --git v3.9-rc3.orig/mm/page_alloc.c v3.9-rc3/mm/page_alloc.c
> > index 8fcced7..09a95e7 100644
> > --- v3.9-rc3.orig/mm/page_alloc.c
> > +++ v3.9-rc3/mm/page_alloc.c
> > @@ -59,6 +59,7 @@
> >  #include <linux/migrate.h>
> >  #include <linux/page-debug-flags.h>
> >  #include <linux/sched/rt.h>
> > +#include <linux/hugetlb.h>
> >  
> >  #include <asm/tlbflush.h>
> >  #include <asm/div64.h>
> > @@ -5716,6 +5717,17 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> >  			continue;
> >  
> >  		page = pfn_to_page(check);
> > +
> > +		/*
> > +		 * Hugepages are not in LRU lists, but they're movable.
> > +		 * We need not scan over tail pages bacause we don't
> > +		 * handle each tail page individually in migration.
> > +		 */
> > +		if (PageHuge(page)) {
> > +			iter += (1 << compound_order(page)) - 1;
> > +			continue;
> > +		}
> 
> Your patch description says, we can't move 1GB hugepage. and then this seems
> too blutal.

iter should be set to the last tail page of the hugepage.

> > +
> >  		/*
> >  		 * We can't use page_count without pin a page
> >  		 * because another CPU can free compound page.
> > diff --git v3.9-rc3.orig/mm/page_isolation.c v3.9-rc3/mm/page_isolation.c
> > index 383bdbb..cf48ef6 100644
> > --- v3.9-rc3.orig/mm/page_isolation.c
> > +++ v3.9-rc3/mm/page_isolation.c
> > @@ -6,6 +6,7 @@
> >  #include <linux/page-isolation.h>
> >  #include <linux/pageblock-flags.h>
> >  #include <linux/memory.h>
> > +#include <linux/hugetlb.h>
> >  #include "internal.h"
> >  
> >  int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
> > @@ -252,6 +253,10 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
> >  {
> >  	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
> >  
> > +	if (PageHuge(page))
> > +		return alloc_huge_page_node(page_hstate(compound_head(page)),
> > +					    numa_node_id());
> 
> numa_node_id() is really silly. This might lead to allocate from offlining node.

Right, it should've been alloc_huge_page().

> and, offline_pages() should mark hstate as isolated likes normal pages for prohibiting
> new allocation at first.

It seems that alloc_migrate_target() calls alloc_page() for normal pages
and the destination pages can be in the same node with the source pages
(new page allocation from the same memblock are prohibited.)
So if we want to avoid new page allocation from the same node,
this is the problem both for normal and huge pages.

BTW, is it correct to think that all users of memory hotplug assume
that they want to hotplug a whole node (not the part of it?)
If that's correct, introducing a kind of "allocate pages from the nearest
neighbor node" can be an improvement.
But I'm not sure how hard it is to implement yet.
Or if my assumption is wrong, what kind of real use cases to do memory
hotplug in more smaller (zone/memblock) unit are there?

Anyway, thank you for the detailed reviews/comments.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
