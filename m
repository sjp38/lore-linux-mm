Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3C9596B004D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 18:15:06 -0500 (EST)
Date: Thu, 12 Nov 2009 23:15:01 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 2/6] ksm: remove redundancies when merging page
In-Reply-To: <Pine.LNX.4.64.0911122303450.3378@sister.anvils>
Message-ID: <Pine.LNX.4.64.0911122314040.4050@sister.anvils>
References: <Pine.LNX.4.64.0911122303450.3378@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There is no need for replace_page() to calculate a write-protected prot
vm_page_prot must already be write-protected for an anonymous page (see
mm/memory.c do_anonymous_page() for similar reliance on vm_page_prot).

There is no need for try_to_merge_one_page() to get_page and put_page
on newpage and oldpage: in every case we already hold a reference to
each of them.

But some instinct makes me move try_to_merge_one_page()'s unlock_page
of oldpage down after replace_page(): that doesn't increase contention
on the ksm page, and makes thinking about the transition easier.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/ksm.c |   26 ++++++--------------------
 1 file changed, 6 insertions(+), 20 deletions(-)

--- ksm1/mm/ksm.c	2009-11-12 15:28:36.000000000 +0000
+++ ksm2/mm/ksm.c	2009-11-12 15:28:42.000000000 +0000
@@ -647,7 +647,7 @@ static int write_protect_page(struct vm_
 		 * Check that no O_DIRECT or similar I/O is in progress on the
 		 * page
 		 */
-		if ((page_mapcount(page) + 2 + swapped) != page_count(page)) {
+		if (page_mapcount(page) + 1 + swapped != page_count(page)) {
 			set_pte_at_notify(mm, addr, ptep, entry);
 			goto out_unlock;
 		}
@@ -682,11 +682,8 @@ static int replace_page(struct vm_area_s
 	pte_t *ptep;
 	spinlock_t *ptl;
 	unsigned long addr;
-	pgprot_t prot;
 	int err = -EFAULT;
 
-	prot = vm_get_page_prot(vma->vm_flags & ~VM_WRITE);
-
 	addr = page_address_in_vma(oldpage, vma);
 	if (addr == -EFAULT)
 		goto out;
@@ -714,7 +711,7 @@ static int replace_page(struct vm_area_s
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(newpage, prot));
+	set_pte_at_notify(mm, addr, ptep, mk_pte(newpage, vma->vm_page_prot));
 
 	page_remove_rmap(oldpage);
 	put_page(oldpage);
@@ -746,13 +743,9 @@ static int try_to_merge_one_page(struct
 
 	if (!(vma->vm_flags & VM_MERGEABLE))
 		goto out;
-
 	if (!PageAnon(oldpage))
 		goto out;
 
-	get_page(newpage);
-	get_page(oldpage);
-
 	/*
 	 * We need the page lock to read a stable PageSwapCache in
 	 * write_protect_page().  We use trylock_page() instead of
@@ -761,25 +754,18 @@ static int try_to_merge_one_page(struct
 	 * then come back to this page when it is unlocked.
 	 */
 	if (!trylock_page(oldpage))
-		goto out_putpage;
+		goto out;
 	/*
 	 * If this anonymous page is mapped only here, its pte may need
 	 * to be write-protected.  If it's mapped elsewhere, all of its
 	 * ptes are necessarily already write-protected.  But in either
 	 * case, we need to lock and check page_count is not raised.
 	 */
-	if (write_protect_page(vma, oldpage, &orig_pte)) {
-		unlock_page(oldpage);
-		goto out_putpage;
-	}
-	unlock_page(oldpage);
-
-	if (pages_identical(oldpage, newpage))
+	if (write_protect_page(vma, oldpage, &orig_pte) == 0 &&
+	    pages_identical(oldpage, newpage))
 		err = replace_page(vma, oldpage, newpage, orig_pte);
 
-out_putpage:
-	put_page(oldpage);
-	put_page(newpage);
+	unlock_page(oldpage);
 out:
 	return err;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
