Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 9F4E96B0146
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 14:24:01 -0400 (EDT)
Date: Tue, 26 Mar 2013 14:23:24 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1364322204-ah777uqs-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130325150952.GA2154@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325150952.GA2154@dhcp22.suse.cz>
Subject: Re: [PATCH 09/10] memory-hotplug: enable memory hotplug to handle
 hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Mon, Mar 25, 2013 at 04:09:52PM +0100, Michal Hocko wrote:
> On Fri 22-03-13 16:23:54, Naoya Horiguchi wrote:
...
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
> 
> What about surplus pages?

This function is only for free hugepage, not for surplus hugepages
(which are considered as in-use hugepages.)
dissolve_free_huge_pages() can be called only when all source hugepages
are free (all in-use hugepages are successfully migrated.)

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
> 
> This assumes that start_pfn doesn't at a tail page otherwise you could
> end up traversing only tail pages. This shouldn't happen normally as
> start_pfn will be bound to a memblock but it looks a bit fragile.

I think that this function is never called for such a memblock because
scan_movable_pages() (scan_lru_pages in old name) skips the memblock
starting with a tail page.
But OK, to make code robuster I'll add checking whether first pfn is a
tail page or not.

> 
> It is a bit unfortunate that the offlining code is pfn range oriented
> while hugetlb pages are organized by nodes.
> 
> > +}
> > +
> >  static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
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
> 
> Why are you checking that the page is active?

This is the counterpart to doing PageLRU check for normal pages.

> It doesn't make much sense
> to me because nothing prevents it from being freed/allocated right after
> you release hugetlb_lock.

Such a race can also happen for normal pages because scan_movable_pages()
just check PageLRU flags without holding any lock.
But the caller, __offline_pages(), repeats to call scan_movable_pages()
until no page in the memblock are judged as movable, and in the repeat loop
do_migrate_range() does nothing for free (unmovable) pages.
So there is no behavioral problem even if the movable page is freed just
after the if(PageLRU) check in scan_movable_page().
Note that in this loop, allocating pages in the memblock is forbidden
because we already do set_migratetype_isolate() for them, so we don't have
to worry about being allocated just after scan_movable_pages().

I want the same thing to be the case for hugepage. As you pointed out,
is_hugepage_movable() is not safe from such a race, but in "being freed
just after is_hugepage_movable() returns true" case we have no problem
for the same reason described above.
However, in "being allocated just after is_hugepage_movable() returns false"
case, it seems to be possible to hot-remove an active hugepage. I think we
can avoid this by adding migratetype check in alloc_huge_page().

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
> 
> This doesn't look right to me. You have to consider where is your tail
> page.
> 					pfn += (1 << compound_order(page)) - (page - compound_head(page)) - 1;
> Or something nicer ;)

OK.

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
> 
> s/page/hpage/

Yes, we should pin head page.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
