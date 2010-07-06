Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8851C6B01AC
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 23:35:46 -0400 (EDT)
Date: Tue, 6 Jul 2010 12:33:42 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 6/7] hugetlb: hugepage migration core
Message-ID: <20100706033342.GA10626@spritzera.linux.bs1.fc.nec.co.jp>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1278049646-29769-7-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100705095927.GC8510@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100705095927.GC8510@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 05, 2010 at 11:59:28AM +0200, Andi Kleen wrote:
> On Fri, Jul 02, 2010 at 02:47:25PM +0900, Naoya Horiguchi wrote:
> > diff --git v2.6.35-rc3-hwpoison/mm/migrate.c v2.6.35-rc3-hwpoison/mm/migrate.c
> > index e4a381c..e7af148 100644
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
> 
> Why is this a break and not a continue? Couldn't you have small and large
> pages in the same list?

Hmm, this chunk need to be fixed because I had too specific assumption.
The list passed to migrate_pages() has only one page or one hugepage in
page migration kicked by soft offline, but it's not the case in general case.
Since hugepage is not linked to LRU list, we had better simply skip
putback_lru_pages().

> There's more code that handles LRU in this file. Do they all handle huge pages
> correctly?
> 
> I also noticed we do not always lock all sub pages in the huge page. Now if
> IO happens it will lock on subpages, not the head page. But this code
> handles all subpages as a unit. Could this cause locking problems?
> Perhaps it would be safer to lock all sub pages always? Or would 
> need  to audit other page users to make sure they always lock on the head
> and do the same here.
> 
> Hmm page reference counts may have the same issue?

If we try to implement paging out of hugepage in the future, we need to
solve all these problems straightforwardly. But at least for now we can
skirt them by not touching LRU code for hugepage extension.

> > @@ -95,6 +98,12 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
> >  	pte_t *ptep, pte;
> >   	spinlock_t *ptl;
> >  
> > +	if (unlikely(PageHuge(new))) {
> > +		ptep = huge_pte_offset(mm, addr);
> > +		ptl = &mm->page_table_lock;
> > +		goto check;
> > +	}
> > +
> >   	pgd = pgd_offset(mm, addr);
> >  	if (!pgd_present(*pgd))
> >  		goto out;
> > @@ -115,6 +124,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
> >   	}
> >  
> >   	ptl = pte_lockptr(mm, pmd);
> > +check:
> 
> I think I would prefer a proper if else over a goto here.
> 
> The lookup should probably just call a helper to make this function more readable
> (like lookup_address(), unfortunately that's x86 specific right now)

OK.
I'll move common code to helper function.

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
> 
> Better reuse copy_huge_page() instead of open coding.

Agreed.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
