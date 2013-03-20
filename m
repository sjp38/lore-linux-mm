Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id E70926B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 03:57:41 -0400 (EDT)
Date: Wed, 20 Mar 2013 08:57:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 8/9] memory-hotplug: enable memory hotplug to handle
 hugepage
Message-ID: <20130320075736.GC20045@dhcp22.suse.cz>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-9-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130318160737.GU10192@dhcp22.suse.cz>
 <1363751733-1fg9kic6-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363751733-1fg9kic6-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Tue 19-03-13 23:55:33, Naoya Horiguchi wrote:
> On Mon, Mar 18, 2013 at 05:07:37PM +0100, Michal Hocko wrote:
> > On Thu 21-02-13 14:41:47, Naoya Horiguchi wrote:
[...]
> > > As for larger hugepages (1GB for x86_64), it's not easy to do hotremove
> > > over them because it's larger than memory block. So we now simply leave
> > > it to fail as it is.
> > 
> > What we could do is to check whether there is a free gb huge page on
> > other node and migrate there.
> 
> Correct, and 1GB page migration needs more code in migration core code
> (mainly it's related to migration entry in pud) and enough testing,
> so I want to do it in separate patchset.

Sure, this was just a note that it is achievable not that it has to be
done in the patchset.

[...]
> > > diff --git v3.8.orig/mm/hugetlb.c v3.8/mm/hugetlb.c
> > > index ccf9995..c28e6c9 100644
> > > --- v3.8.orig/mm/hugetlb.c
> > > +++ v3.8/mm/hugetlb.c
> > > @@ -843,6 +843,30 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
> > >  	return ret;
> > >  }
> > >  
> > > +/* Dissolve a given free hugepage into free pages. */
> > > +void dissolve_free_huge_page(struct page *page)
> > > +{
> > > +	if (PageHuge(page) && !page_count(page)) {
> > 
> > Could you clarify why you are cheking page_count here? I assume it is to
> > make sure the page is free but what prevents it being increased before
> > you take hugetlb_lock?
> 
> There's nothing to prevent it, so it's not safe to check refcount outside
> hugetlb_lock.

OK, so the lock has to be moved up.

[...]
> > > diff --git v3.8.orig/mm/memory_hotplug.c v3.8/mm/memory_hotplug.c
> > > index d04ed87..6418de2 100644
> > > --- v3.8.orig/mm/memory_hotplug.c
> > > +++ v3.8/mm/memory_hotplug.c
> > > @@ -29,6 +29,7 @@
> > >  #include <linux/suspend.h>
> > >  #include <linux/mm_inline.h>
> > >  #include <linux/firmware-map.h>
> > > +#include <linux/hugetlb.h>
> > >  
> > >  #include <asm/tlbflush.h>
> > >  
> > > @@ -985,10 +986,12 @@ static int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
> > >  }
> > >  
> > >  /*
> > > - * Scanning pfn is much easier than scanning lru list.
> > > - * Scan pfn from start to end and Find LRU page.
> > > + * Scan pfn range [start,end) to find movable/migratable pages (LRU pages
> > > + * and hugepages). We scan pfn because it's much easier than scanning over
> > > + * linked list. This function returns the pfn of the first found movable
> > > + * page if it's found, otherwise 0.
> > >   */
> > > -static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
> > > +static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
> > >  {
> > >  	unsigned long pfn;
> > >  	struct page *page;
> > > @@ -997,6 +1000,12 @@ static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
> > >  			page = pfn_to_page(pfn);
> > >  			if (PageLRU(page))
> > >  				return pfn;
> > > +			if (PageHuge(page)) {
> > > +				if (is_hugepage_movable(page))
> > > +					return pfn;
> > > +				else
> > > +					pfn += (1 << compound_order(page)) - 1;
> > > +			}
> > 
> > scan_lru_pages's name gets really confusing after this change because
> > hugetlb pages are not on the LRU. Maybe it would be good to rename it.
> 
> Yes, and that's done in right above chunk.

bahh, I am blind. I got confused by the name in the hunk header. Sorry
about that.

> 
> > 
> > >  		}
> > >  	}
> > >  	return 0;
> > > @@ -1019,6 +1028,30 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> > >  		page = pfn_to_page(pfn);
> > >  		if (!get_page_unless_zero(page))
> > >  			continue;
> > 
> > All tail pages have 0 reference count (according to prep_compound_page)
> > so they would be skipped anyway. This makes the below pfn tweaks
> > pointless.
> 
> I was totally mistaken about what we should do here, sorry. If we call
> do_migrate_range() for 1GB hugepage, we should return with error (maybe -EBUSY)
> instead of just skipping it, otherwise the caller __offline_pages() repeats
> 'goto repeat' until timeout. In order to do that, we had better insert
> if(PageHuge) block before getting refcount. And ...
> 
> > > +		if (PageHuge(page)) {
> > > +			/*
> > > +			 * Larger hugepage (1GB for x86_64) is larger than
> > > +			 * memory block, so pfn scan can start at the tail
> > > +			 * page of larger hugepage. In such case,
> > > +			 * we simply skip the hugepage and move the cursor
> > > +			 * to the last tail page.
> > > +			 */
> > > +			if (PageTail(page)) {
> > > +				struct page *head = compound_head(page);
> > > +				pfn = page_to_pfn(head) +
> > > +					(1 << compound_order(head)) - 1;
> > > +				put_page(page);
> > > +				continue;
> > > +			}
> > > +			pfn = (1 << compound_order(page)) - 1;
> > > +			if (huge_page_size(page_hstate(page)) != PMD_SIZE) {
> > > +				put_page(page);
> > > +				continue;
> > > +			}
> > 
> > There might be other hugepage sizes which fit into memblock so this test
> > doesn't seem right.
> 
> yes, so compound_order(head) > PFN_SECTION_SHIFT would be better.

I would rather see compound_order(head) < MAX_ORDER to be more coupled
with the allocator.

> I'll replace this chunk with the following if I don't get any other
> suggestion.
> 
> @@ -1017,6 +1026,21 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  		if (!pfn_valid(pfn))
>  			continue;
>  		page = pfn_to_page(pfn);
> +
> +		if (PageHuge(page)) {
> +			struct page *head = compound_head(page);
> +			pfn = page_to_pfn(head) + (1 << compound_order(head)) - 1;

I do not think this is safe without an elevated ref count. Your page
might be on the way to be freed. So you need to put get_page_unless_zero
before compound_order check.

Besides that I do not see too much point in optimizing this path on the
code complexity behalf. Sure we would call get_page_unless_zero
pointlessly for all tail pages but this is hardly a hot path.

> +			if (compound_order(head) > PFN_SECTION_SHIFT) {
> +				ret = -EBUSY;
> +				break;
> +			}
> +			if (!get_page_unless_zero(page))

Should be head.

> +				continue;
> +			list_move_tail(&head->lru, &source);
> +			move_pages -= 1 << compound_order(head);
> +			continue;
> +		}
> +
>  		if (!get_page_unless_zero(page))
>  			continue;
>  		/*
> 
> Thanks,
> Naoya
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
