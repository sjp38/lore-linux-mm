Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9DF385F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 04:05:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3F85ufp010197
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Apr 2009 17:05:57 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F2E845DD7B
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 17:05:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6647145DD78
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 17:05:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E19E1DB803B
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 17:05:56 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E14F11DB8038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 17:05:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
In-Reply-To: <200904150042.15653.nickpiggin@yahoo.com.au>
References: <20090414143252.GE28265@random.random> <200904150042.15653.nickpiggin@yahoo.com.au>
Message-Id: <20090415165431.AC4C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Apr 2009 17:05:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi

> On Wednesday 15 April 2009 00:32:52 Andrea Arcangeli wrote:
> > On Wed, Apr 15, 2009 at 12:26:34AM +1000, Nick Piggin wrote:
> > > Andrea: I didn't veto that set_bit change of yours as such. I just
> > 
> > I know you didn't ;)
> > 
> > > noted there could be more atomic operations. Actually I would
> > > welcome more comparison between our two approaches, but they seem
> > 
> > Agree about the welcome of comparison, it'd be nice to measure it the
> > enterprise workloads that showed the gup_fast gain in the first place.
> 
> I think we should be able to ask IBM to run some tests, provided
> they still have machines available to do so. Although I don't want
> to waste their time so we need to have something that has got past
> initial code review and has a chance of being merged.
> 
> If we get that far, then I can ask them to run tests definitely.

Oh, it seem very charming idea.
Nick, I hope to help your patch's rollup. It makes good comparision, I think.
Is there my doable thing?

And, I changed my patch.
How about this? I added simple twice check.

because, both do_wp_page and try_to_unmap_one grab ptl. then,
page-fault routine can't change pte while try_to_unmap nuke pte.



---
 mm/rmap.c     |   30 ++++++++++++++++++++++++------
 mm/swapfile.c |    3 ++-
 2 files changed, 26 insertions(+), 7 deletions(-)

Index: b/mm/swapfile.c
===================================================================
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -547,7 +547,8 @@ int reuse_swap_page(struct page *page)
 			SetPageDirty(page);
 		}
 	}
-	return count == 1;
+
+	return count + page_count(page) == 2;
 }
 
 /*
Index: b/mm/rmap.c
===================================================================
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -772,12 +772,18 @@ static int try_to_unmap_one(struct page 
 	if (!pte)
 		goto out;
 
-	/*
-	 * If the page is mlock()d, we cannot swap it out.
-	 * If it's recently referenced (perhaps page_referenced
-	 * skipped over this mm) then we should reactivate it.
-	 */
 	if (!migration) {
+		if (PageSwapCache(page) &&
+		    page_count(page) != page_mapcount(page) + 2) {
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
+
+		/*
+		 * If the page is mlock()d, we cannot swap it out.
+		 * If it's recently referenced (perhaps page_referenced
+		 * skipped over this mm) then we should reactivate it.
+		 */
 		if (vma->vm_flags & VM_LOCKED) {
 			ret = SWAP_MLOCK;
 			goto out_unmap;
@@ -790,7 +796,19 @@ static int try_to_unmap_one(struct page 
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
-	pteval = ptep_clear_flush_notify(vma, address, pte);
+	pteval = ptep_clear_flush(vma, address, pte);
+
+	if (!migration) {
+		/* re-check */
+		if (PageSwapCache(page) &&
+		    page_count(page) != page_mapcount(page) + 2) {
+			/* We lose race against get_user_pages_fast() */
+			set_pte_at(mm, address, pte, pteval);
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
+	}
+	mmu_notifier_invalidate_page(vma->vm_mm, address);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
