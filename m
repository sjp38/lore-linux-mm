Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C02C76B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 04:28:25 -0400 (EDT)
Date: Thu, 26 Aug 2010 17:26:16 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 7/8] HWPOISON, hugetlb: fix unpoison for hugepage
Message-ID: <20100826082616.GX21389@spritzera.linux.bs1.fc.nec.co.jp>
References: <1282694127-14609-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1282694127-14609-8-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100825025432.GA15129@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100825025432.GA15129@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 25, 2010 at 10:54:32AM +0800, Wu Fengguang wrote:
> On Wed, Aug 25, 2010 at 07:55:26AM +0800, Naoya Horiguchi wrote:
> > Currently unpoisoning hugepages doesn't work because it's not enough
> > to just clear PG_HWPoison bits and we need to link the hugepage
> > to be unpoisoned back to the free hugepage list.
> > To do this, we get and put hwpoisoned hugepage whose refcount is 0.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
> > ---
> >  mm/memory-failure.c |   16 +++++++++++++---
> >  1 files changed, 13 insertions(+), 3 deletions(-)
> > 
> > diff --git v2.6.36-rc2/mm/memory-failure.c v2.6.36-rc2/mm/memory-failure.c
> > index 60178d2..ab36690 100644
> > --- v2.6.36-rc2/mm/memory-failure.c
> > +++ v2.6.36-rc2/mm/memory-failure.c
> > @@ -1154,9 +1154,19 @@ int unpoison_memory(unsigned long pfn)
> >  	nr_pages = 1 << compound_order(page);
> >  
> >  	if (!get_page_unless_zero(page)) {
> > -		if (TestClearPageHWPoison(p))
> > +		/* The page to be unpoisoned was free one when hwpoisoned */
> > +		if (TestClearPageHWPoison(page))
> >  			atomic_long_sub(nr_pages, &mce_bad_pages);
> >  		pr_debug("MCE: Software-unpoisoned free page %#lx\n", pfn);
> > +		if (PageHuge(page)) {
> > +			/*
> > +			 * To unpoison free hugepage, we get and put it
> > +			 * to move it back to the free list.
> > +			 */
> > +			get_page(page);
> > +			clear_page_hwpoison_huge_page(page);
> > +			put_page(page);
> > +		}
> >  		return 0;
> >  	}
> 
> It's racy in free huge page detection.
> 
> alloc_huge_page() does not increase page refcount inside hugetlb_lock,
> the alloc_huge_page()=>alloc_buddy_huge_page() path even drops the
> lock temporarily! Then we never know reliably if a huge page is really
> free.

I agree.

> Here is a scratched fix. It is totally untested. Just want to notice
> you that with this patch, the huge page unpoisoning should go easier.

Great.
I adjusted this patch to real hugetlb code and passed libhugetlbfs test.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
