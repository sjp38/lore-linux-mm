Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 255258D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 06:32:53 -0500 (EST)
Date: Tue, 8 Mar 2011 12:32:45 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: THP, rmap and page_referenced_one()
Message-ID: <20110308113245.GR25641@random.random>
References: <AANLkTikJpr9H2NJHyw_uajL=Ef_p16L3QYgmJSfFynSZ@mail.gmail.com>
 <AANLkTinncv11r3cJnOr0HWZyaSu5NQMz6pEYThMkmFd0@mail.gmail.com>
 <AANLkTikKtxEoXT=Y9d80oYnY7LvfLn8Hwz-XorSxR3Mv@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikKtxEoXT=Y9d80oYnY7LvfLn8Hwz-XorSxR3Mv@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

Hello,

On Mon, Mar 07, 2011 at 02:35:15AM -0800, Michel Lespinasse wrote:
> There is also the issue that *mapcount will be decremented even if the
> pmd turns out not to point to the given page. page_referenced() will
> stop looking at rmap's candidate mappings once the refcount hits zero,
> so the decrement will cause an actual mapping to be ignored.

Both the mapcount and vm_flags problems would worst case lead to some
page ("parent page" in the example provided with mlock in the child)
being evicted too early, not to become unevictable. The mapcount is
actually a bigger concern to me as it doesn't require the race. I also
added a proper comment before page_check_address* as suggested by
Minchan. Frankly when I updated the code I didn't realize that was the
actual reason VM_LOCKED was placed in the middle between
page_check_address and ptep_clear_flush_young_notify, now it's clear
why...

I only run some basic testing, please review. I seen no reason to
return "referenced = 0" if the pmd is still splitting. So I let it go
ahead now and test_and_set_bit the accessed bit even on a splitting
pmd. After all the tlb miss could still activate the young bit on a
pmd while it's in splitting state. There's no check for splitting in
the pmdp_clear_flush_young. The secondary mmu has no secondary spte
mapped while it's set to splitting so it shouldn't matter for it if we
clear the young bit (and new secondary mmu page faults will wait on
splitting to clear and __split_huge_page_map to finish before going
ahead creating new secondary sptes with 4k granularity).

Here a fix:

===
Subject: thp: fix page_referenced to modify mapcount/vm_flags only if page is found

From: Andrea Arcangeli <aarcange@redhat.com>

When vmscan.c calls page_referenced, if an anon page was created before a
process forked, rmap will search for it in both of the processes, even though
one of them might have since broken COW. If the child process mlocks the vma
where the COWed page belongs to, page_referenced() running on the page mapped
by the parent would lead to *vm_flags getting VM_LOCKED set erroneously (leading
to the references on the parent page being ignored and evicting the parent page
too early).

*mapcount would also be decremented by page_referenced_one even if the page
wasn't found by page_check_address.

This also let pmdp_clear_flush_young_notify() go ahead on a
pmd_trans_splitting() pmd. We hold the page_table_lock so
__split_huge_page_map() must wait the pmdp_clear_flush_young_notify()
to complete before it can modify the pmd. The pmd is also still mapped
in userland so the young bit may materialize through a tlb miss before
split_huge_page_map runs. This will provide a more accurate
page_referenced() behavior during split_huge_page().

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Michel Lespinasse <walken@google.com>
---

diff --git a/mm/rmap.c b/mm/rmap.c
index f21f4a1..e8924bc 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -497,41 +497,62 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 	struct mm_struct *mm = vma->vm_mm;
 	int referenced = 0;
 
-	/*
-	 * Don't want to elevate referenced for mlocked page that gets this far,
-	 * in order that it progresses to try_to_unmap and is moved to the
-	 * unevictable list.
-	 */
-	if (vma->vm_flags & VM_LOCKED) {
-		*mapcount = 0;	/* break early from loop */
-		*vm_flags |= VM_LOCKED;
-		goto out;
-	}
-
-	/* Pretend the page is referenced if the task has the
-	   swap token and is in the middle of a page fault. */
-	if (mm != current->mm && has_swap_token(mm) &&
-			rwsem_is_locked(&mm->mmap_sem))
-		referenced++;
-
 	if (unlikely(PageTransHuge(page))) {
 		pmd_t *pmd;
 
 		spin_lock(&mm->page_table_lock);
+		/*
+		 * We must update *vm_flags and *mapcount only if
+		 * page_check_address_pmd() succeeds in finding the
+		 * page.
+		 */
 		pmd = page_check_address_pmd(page, mm, address,
 					     PAGE_CHECK_ADDRESS_PMD_FLAG);
-		if (pmd && !pmd_trans_splitting(*pmd) &&
-		    pmdp_clear_flush_young_notify(vma, address, pmd))
+		if (!pmd) {
+			spin_unlock(&mm->page_table_lock);
+			goto out;
+		}
+
+		/*
+		 * Don't want to elevate referenced for mlocked page
+		 * that gets this far, in order that it progresses to
+		 * try_to_unmap and is moved to the unevictable list.
+		 */
+		if (vma->vm_flags & VM_LOCKED) {
+			spin_unlock(&mm->page_table_lock);
+			*mapcount = 0;	/* break early from loop */
+			*vm_flags |= VM_LOCKED;
+			goto out;
+		}
+
+		/* go ahead even if the pmd is pmd_trans_splitting() */
+		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
 		spin_unlock(&mm->page_table_lock);
 	} else {
 		pte_t *pte;
 		spinlock_t *ptl;
 
+		/*
+		 * We must update *vm_flags and *mapcount only if
+		 * page_check_address() succeeds in finding the page.
+		 */
 		pte = page_check_address(page, mm, address, &ptl, 0);
 		if (!pte)
 			goto out;
 
+		/*
+		 * Don't want to elevate referenced for mlocked page
+		 * that gets this far, in order that it progresses to
+		 * try_to_unmap and is moved to the unevictable list.
+		 */
+		if (vma->vm_flags & VM_LOCKED) {
+			pte_unmap_unlock(pte, ptl);
+			*mapcount = 0;	/* break early from loop */
+			*vm_flags |= VM_LOCKED;
+			goto out;
+		}
+
 		if (ptep_clear_flush_young_notify(vma, address, pte)) {
 			/*
 			 * Don't treat a reference through a sequentially read
@@ -546,6 +567,12 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		pte_unmap_unlock(pte, ptl);
 	}
 
+	/* Pretend the page is referenced if the task has the
+	   swap token and is in the middle of a page fault. */
+	if (mm != current->mm && has_swap_token(mm) &&
+			rwsem_is_locked(&mm->mmap_sem))
+		referenced++;
+
 	(*mapcount)--;
 
 	if (referenced)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
