Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D7DD96B0248
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 02:47:02 -0400 (EDT)
Date: Wed, 7 Jul 2010 15:45:39 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 6/7] hugetlb: hugepage migration core
Message-ID: <20100707064538.GC21962@spritzera.linux.bs1.fc.nec.co.jp>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1278049646-29769-7-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1007061057230.4938@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1007061057230.4938@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 06, 2010 at 11:00:27AM -0500, Christoph Lameter wrote:
> On Fri, 2 Jul 2010, Naoya Horiguchi wrote:
> 
> > --- v2.6.35-rc3-hwpoison/mm/migrate.c
> > +++ v2.6.35-rc3-hwpoison/mm/migrate.c
> > @@ -32,6 +32,7 @@
> >  #include <linux/security.h>
> >  #include <linux/memcontrol.h>
> >  #include <linux/syscalls.h>
> > +#include <linux/hugetlb.h>
> >  #include <linux/gfp.h>
> >
> >  #include "internal.h"
> > @@ -74,6 +75,8 @@ void putback_lru_pages(struct list_head *l)
> >  	struct page *page2;
> >
> >  	list_for_each_entry_safe(page, page2, l, lru) {
> > +		if (PageHuge(page))
> > +			break;
> >  		list_del(&page->lru);
> 
> Argh. Hugepages in putpack_lru_pages()? Huge pages are not on the lru.
> Come up with something cleaner here.

OK.

> > @@ -267,7 +284,14 @@ static int migrate_page_move_mapping(struct address_space *mapping,
> >  	 * Note that anonymous pages are accounted for
> >  	 * via NR_FILE_PAGES and NR_ANON_PAGES if they
> >  	 * are mapped to swap space.
> > +	 *
> > +	 * Not account hugepage here for now because hugepage has
> > +	 * separate accounting rule.
> >  	 */
> > +	if (PageHuge(newpage)) {
> > +		spin_unlock_irq(&mapping->tree_lock);
> > +		return 0;
> > +	}
> >  	__dec_zone_page_state(page, NR_FILE_PAGES);
> >  	__inc_zone_page_state(newpage, NR_FILE_PAGES);
> >  	if (PageSwapBacked(page)) {
> 
> This looks wrong here. Too many special casing added to basic migration
> functionality.

Agreed.
As I replied in another email, I'll move to migrate_huge_page() and
avoid adding ugly changes like this.

> > @@ -284,7 +308,17 @@ static int migrate_page_move_mapping(struct address_space *mapping,
> >   */
> >  static void migrate_page_copy(struct page *newpage, struct page *page)
> >  {
> > -	copy_highpage(newpage, page);
> > +	int i;
> > +	struct hstate *h;
> > +	if (!PageHuge(newpage))
> > +		copy_highpage(newpage, page);
> > +	else {
> > +		h = page_hstate(newpage);
> > +		for (i = 0; i < pages_per_huge_page(h); i++) {
> > +			cond_resched();
> > +			copy_highpage(newpage + i, page + i);
> > +		}
> > +	}
> >
> >  	if (PageError(page))
> >  		SetPageError(newpage);
> 
> Could you generalize this for migrating an order N page?

Yes.
I'll define a helper function to handle order N case.

> > @@ -718,6 +752,11 @@ unlock:
> >  	put_page(page);
> >
> >  	if (rc != -EAGAIN) {
> > +		if (PageHuge(newpage)) {
> > +			put_page(newpage);
> > +			goto out;
> > +		}
> > +
> 
> I dont like this kind of inconsistency with the refcounting. Page
> migration is complicated enough already.

OK.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
