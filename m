Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7EE6A6B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 19:34:46 -0400 (EDT)
Date: Wed, 2 Jun 2010 16:33:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlb: call mmu notifiers on hugepage cow
Message-Id: <20100602163346.b8f8b8a4.akpm@linux-foundation.org>
In-Reply-To: <4C06E5A6.6@cray.com>
References: <4BFED954.8060807@cray.com>
	<20100601231600.3b3bf499.akpm@linux-foundation.org>
	<4C06E5A6.6@cray.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Doug Doan <dougd@cray.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "rientjes@google.com" <rientjes@google.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, Andrea Arcangeli <andrea@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jun 2010 16:13:42 -0700
Doug Doan <dougd@cray.com> wrote:

> On 06/01/2010 11:16 PM, Andrew Morton wrote:
> > On Thu, 27 May 2010 13:43:00 -0700 Doug Doan<dougd@cray.com>  wrote:
> >
> >>
> >> When a copy-on-write occurs, we take one of two paths in handle_mm_fault:
> >> through handle_pte_fault for normal pages, or through hugetlb_fault for huge pages.
> >>
> >> In the normal page case, we eventually get to do_wp_page and call mmu notifiers
> >> via ptep_clear_flush_notify. There is no callout to the mmmu notifiers in the
> >> huge page case. This patch fixes that.
> >>
> >> Signed-off-by: Doug Doan<dougd@cray.com>
> >> ---
> >>
> >> [patch  text/plain (802B)]
> >> --- mm/hugetlb.c.orig	2010-05-27 13:07:58.569546314 -0700
> >> +++ mm/hugetlb.c	2010-05-26 14:41:06.449296524 -0700
> >
> > (In patch -p1 form, please.  So a/mm/hugetlb.c)
> >
> >> @@ -2345,11 +2345,17 @@ retry_avoidcopy:
> >>   	ptep = huge_pte_offset(mm, address&  huge_page_mask(h));
> >>   	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
> >>   		/* Break COW */
> >> +		mmu_notifier_invalidate_range_start(mm,
> >> +			address&  huge_page_mask(h),
> >> +			(address&  huge_page_mask(h)) + huge_page_size(h));
> >>   		huge_ptep_clear_flush(vma, address, ptep);
> >>   		set_huge_pte_at(mm, address, ptep,
> >>   				make_huge_pte(vma, new_page, 1));
> >>   		/* Make the old page be freed below */
> >>   		new_page = old_page;
> >> +		mmu_notifier_invalidate_range_end(mm,
> >> +			address&  huge_page_mask(h),
> >> +			(address&  huge_page_mask(h)) + huge_page_size(h));
> >>   	}
> >>   	page_cache_release(new_page);
> >>   	page_cache_release(old_page);
> >
> > This causes mmu_notifier_invalidate_range_start() to be called under
> > page_table_lock.  The immediately preceding code seems to take some
> > care to avoid doing that.  I took a quick look at other callsites and
> > cannot immediately see other cases where
> > mmu_notifier_invalidate_range_start/end() are called under that lock.
> >
> > This may not introduce bugs with current notifier implementations (I
> > didn't check), but it does lessen flexibility?
> 
> In the normal page case, handle_pte_fault calls do_wp_page inside a spinlock on 
> ptl = pte_lockptr(mm, pmd), which uses mm->page_table_lock if USE_SPLIT_PTLOCKS 
> is not defined.
> 
> I don't understand what you mean by lessen flexibilty.

Well, specifically it means that
mmu_notifier_invalidate_range_start/end() implemetnations can no longer
take page_table_lock or any lock which nests outside page_table_lock. 
That lessens flexibility.

As the other mmu_notifier_invalidate_range_start/end() callsite in this
function carefully nested those calls outside page_table_lock, perhaps
that was thought to be a significant thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
