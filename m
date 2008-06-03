Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m53Amo3H680190
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 10:48:50 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m53AmoUT3026994
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 12:48:50 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m53Amo4J001932
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 12:48:50 +0200
Subject: Re: [PATCH] Optimize page_remove_rmap for anon pages
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <200806031829.14150.nickpiggin@yahoo.com.au>
References: <1212069392.16984.25.camel@localhost>
	 <200806030957.49069.nickpiggin@yahoo.com.au>
	 <1212480363.7746.19.camel@localhost>
	 <200806031829.14150.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 03 Jun 2008 12:48:25 +0200
Message-Id: <1212490105.7746.39.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-06-03 at 18:29 +1000, Nick Piggin wrote: 
> pte dirty bit is checked in zap_pte_range. In do_wp_page, the pte dirty
> bit is not checked because it cannot have been dirtied via that mapping.
> However, this may not necessarily be true in the s390 case where it might
> be dirtied by _another_ mapping which has subsequently exited but not
> propogated the physical dirty bit (I don't know, but I'm just wary about
> it).

Yes, what is needed is a check that tells us if the page content is
still needed after the last mapper has gone. For anonymous pages the
check "!PageAnon(page) || PageSwapCache(page)" should do. The idea is
that on each path that replaces a valid pte with a swap pte the
PageSwapCache bit is set first, then page_remove_rmap is called. As far
as I can see this is true for the current code. 

> > > The "easy" way to do it might be just unconditionally mark the page
> > > as dirty in this path (if the pte was writeable), so you can avoid
> > > the page_test_dirty check and be sure of not missing the dirty bit.
> >
> > Hmm, but then an mprotect() can change the pte to read-ony and we'd miss
> > the dirty bit again. Back to the drawing board.
> 
> Hmm, I guess you _could_ set_page_dirty in mprotect.

Yeah, but we don't really want to do that.

> > By the way there is another SSKE I want to get rid of: __SetPageUptodate
> > does a page_clear_dirty(). For all uses of __SetPageUptodate the page
> > will be dirty after the application did its first write. To clear the
> > page dirty bit only to have it set again shortly after doesn't make much
> > sense to me. Has there been any particular reason for the
> > page_clear_dirty in __SetPageUptodate ?
> 
> I guess it is just to match SetPageUptodate. Not all __SetPageUptodate
> paths may necessarily dirty the page, FWIW.

The current users of __SetPageUptodate are:
* do_wp_page
* do_anonymous_page
* do_fault for (flags & FAULT_FLAG_WRITE)
For these three cases the pte is created with pte_mkdirty. Clearing the
physical page dirty bit is pointless.

* hugetlb_cow
* hugetlb_no_page
The dirty bits are of no interest to hugetlbfs, no?

I think it is safe to remove the page_clear_dirty from __SetPageUptodate
New patch below.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.

---
Subject: [PATCH] Optimize storage key operations for anon pages

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

For anonymous pages without a swap cache backing the check for the physical
dirty bit in page_remove_rmap is unnecessary. The instruction that are used
to check and reset the dirty bit are expensive. Removing the check noticably
speeds up process exit. In addition the clearing of the dirty bit in
__SetPageUptodate is pointless as well. With these two changes there is
no storage key operation for an anonymous page anymore if it does not hit
the swap space.

The micro benchmark which repeatedly executes an empty shell script gets
about 5% faster.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

diff -urpN linux-2.6/include/linux/page-flags.h linux-2.6-patched/include/linux/page-flags.h
--- linux-2.6/include/linux/page-flags.h	2008-06-03 09:46:50.000000000 +0200
+++ linux-2.6-patched/include/linux/page-flags.h	2008-06-03 11:37:27.000000000 +0200
@@ -217,9 +217,6 @@ static inline void __SetPageUptodate(str
 {
 	smp_wmb();
 	__set_bit(PG_uptodate, &(page)->flags);
-#ifdef CONFIG_S390
-	page_clear_dirty(page);
-#endif
 }
 
 static inline void SetPageUptodate(struct page *page)
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2008-06-03 11:34:55.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2008-06-03 11:36:27.000000000 +0200
@@ -678,7 +678,8 @@ void page_remove_rmap(struct page *page,
 		 * Leaving it set also helps swapoff to reinstate ptes
 		 * faster for those pages still in swapcache.
 		 */
-		if (page_test_dirty(page)) {
+		if ((!PageAnon(page) || PageSwapCache(page)) && 
+		    page_test_dirty(page)) {
 			page_clear_dirty(page);
 			set_page_dirty(page);
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
