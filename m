Date: Thu, 23 Aug 2001 21:24:50 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
In-Reply-To: <3B853EEA.6D445E0E@pp.inet.fi>
Message-ID: <Pine.LNX.4.21.0108232049530.1020-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jari Ruusu <jari.ruusu@pp.inet.fi>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeremy Linton <jlinton@interactivesi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2001, Jari Ruusu wrote:
> 
> Box didn't die but I stopped VM torture test after this appeared:
> 
> Unused swap offset entry in swap_dup 003d6b00
> VM: Bad swap entry 003d6b00
> Unused swap offset entry in swap_count 003d6b00
> VM: Bad swap entry 003d6b00

Don't stop your test when such messages appear, under heavy swapping
they can appear even when the system is proceeding correctly, not
only when doing swapoff.  (In a separate, swapoff patch I've
suppressed them, but won't bother you with that here.)

Alan has intentionally been avoiding many of the VM "fixes" in Linus'
tree, Rik has been feeding him some of the less controversial ones,
but I believe there are important ones missing (unrelated to aging
and tuning etc.).  Looking no further than mm/memory.c, patch below
to bring 2.4.8-ac9 in line with 2.4.9 there:

1. lock_kiovec page unwind fix (velizarb@pirincom.com)
2. copy_cow_page & clear_user_highpage can block in kmap
   (Anton Blanchard, Ingo Molnar, Linus Torvalds, Hugh Dickins)
3. do_swap_page recheck pte before failing (Jeremy Linton, Linus Torvalds)
4. do_swap_page don't mkwrite when deleting from swap cache (Linus Torvalds)

The first has no relevance to your issues, but should be in -ac.
The second is rarely needed, but I wouldn't want to run a torture
test on a highmem machine (okay, yours is far from that!) without it.
The third is probably the fix to the process killing you saw near
the Unused swap and Bad swap messages.  The fourth is a correction
Linus made to Rik's swap freeing, which might also have some bearing.

(Alan, some doubts in do_wp_page: the additional PageReserved test
may be redundant in view of your earlier ZERO_PAGE test, but I
felt safer to include it; and I was dubious about the additional
set_pte and ptep_get_and_clear in your version, but don't know the
history and let them stay.)

Hugh

--- 2.4.8-ac9/mm/memory.c	Thu Aug 23 12:31:32 2001
+++ linux/mm/memory.c	Thu Aug 23 19:56:55 2001
@@ -611,9 +611,9 @@
 			
 			if (TryLockPage(page)) {
 				while (j--) {
-					page = *(--ppage);
-					if (page)
-						UnlockPage(page);
+					struct page *tmp = *--ppage;
+					if (tmp)
+						UnlockPage(tmp);
 				}
 				goto retry;
 			}
@@ -856,10 +856,9 @@
 /*
  * We hold the mm semaphore for reading and vma->vm_mm->page_table_lock
  */
-static inline void break_cow(struct vm_area_struct * vma, struct page *	old_page, struct page * new_page, unsigned long address, 
+static inline void break_cow(struct vm_area_struct * vma, struct page * new_page, unsigned long address, 
 		pte_t *page_table)
 {
-	copy_cow_page(old_page,new_page,address);
 	flush_page_to_ram(new_page);
 	flush_cache_page(vma, address);
 	establish_pte(vma, address, page_table, pte_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot))));
@@ -923,6 +922,8 @@
 			break;
 		/* FallThrough */
 	case 1:
+		if (PageReserved(old_page))
+			break;
 		flush_cache_page(vma, address);
 		establish_pte(vma, address, page_table, pte_mkyoung(pte_mkdirty(pte_mkwrite(pte))));
 		return 1;	/* Minor fault */
@@ -932,16 +933,20 @@
 	 * Ok, we need to copy. Oh, well..
 	 */
 copy:	 
- 	set_pte(page_table, pte);
+	set_pte(page_table, pte);
+	page_cache_get(old_page);
 	spin_unlock(&mm->page_table_lock);
+
 	new_page = alloc_page(GFP_HIGHUSER);
-	spin_lock(&mm->page_table_lock);
 	if (!new_page)
-		return -1;
+		goto no_mem;
+	copy_cow_page(old_page,new_page,address);
+	page_cache_release(old_page);
 
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
+	spin_lock(&mm->page_table_lock);
 	if (pte_same(*page_table, pte)) {
 		/* We are changing the pte, so get rid of the old
 		 * one to avoid races with the hardware, this really
@@ -950,7 +955,7 @@
 		pte = ptep_get_and_clear(page_table);
 		if (PageReserved(old_page))
 			++mm->rss;
-		break_cow(vma, old_page, new_page, address, page_table);
+		break_cow(vma, new_page, address, page_table);
 
 		/* Free the old page.. */
 		new_page = old_page;
@@ -961,6 +966,10 @@
 bad_wp_page:
 	printk("do_wp_page: bogus page at address %08lx (page 0x%lx)\n",address,(unsigned long)old_page);
 	return -1;
+no_mem:
+	page_cache_release(old_page);
+	spin_lock(&mm->page_table_lock);
+	return -1;
 }
 
 static void vmtruncate_list(struct vm_area_struct *mpnt, unsigned long pgoff)
@@ -1099,9 +1108,10 @@
  */
 static int do_swap_page(struct mm_struct * mm,
 	struct vm_area_struct * vma, unsigned long address,
-	pte_t * page_table, swp_entry_t entry, int write_access)
+	pte_t * page_table, pte_t orig_pte, int write_access)
 {
 	struct page *page;
+	swp_entry_t entry = pte_to_swp_entry(orig_pte);
 	pte_t pte;
 	int ret = 1;
 
@@ -1114,7 +1124,11 @@
 		unlock_kernel();
 		if (!page) {
 			spin_lock(&mm->page_table_lock);
-			return -1;
+			/*
+			 * Back out if somebody else faulted in this pte while
+			 * we released the page table lock.
+			 */
+			return pte_same(*page_table, orig_pte) ? -1 : 1;
 		}
 
 		/* Had to read the page from swap area: Major fault */
@@ -1133,7 +1147,7 @@
 	 * released the page table lock.
 	 */
 	spin_lock(&mm->page_table_lock);
-	if (pte_present(*page_table)) {
+	if (!pte_same(*page_table, orig_pte)) {
 		UnlockPage(page);
 		page_cache_release(page);
 		return 1;
@@ -1144,21 +1158,13 @@
 	pte = mk_pte(page, vma->vm_page_prot);
 
 	swap_free(entry);
-	if (write_access && exclusive_swap_page(page))
-		pte = pte_mkwrite(pte_mkdirty(pte));
-
-	/*
-	 * If swap space is getting low and we were the last user
-	 * of this piece of swap space, we free this space so
-	 * somebody else can be swapped out.
-	 *
-	 * We are protected against try_to_swap_out() because the
-	 * page is locked and against do_fork() because we have
-	 * read_lock(&mm->mmap_sem).
-	 */
-	if (vm_swap_full() && exclusive_swap_page(page)) {
-		delete_from_swap_cache_nolock(page);
-		pte = pte_mkwrite(pte_mkdirty(pte));
+	if (exclusive_swap_page(page)) {	
+		if (write_access)
+			pte = pte_mkwrite(pte_mkdirty(pte));
+		if (vm_swap_full()) {
+			delete_from_swap_cache_nolock(page);
+			pte = pte_mkdirty(pte);
+		}
 	}
 	UnlockPage(page);
 
@@ -1189,16 +1195,18 @@
 
 		/* Allocate our own private page. */
 		spin_unlock(&mm->page_table_lock);
+
 		page = alloc_page(GFP_HIGHUSER);
-		spin_lock(&mm->page_table_lock);
 		if (!page)
-			return -1;
+			goto no_mem;
+		clear_user_highpage(page, addr);
+
+		spin_lock(&mm->page_table_lock);
 		if (!pte_none(*page_table)) {
 			page_cache_release(page);
 			return 1;
 		}
 		mm->rss++;
-		clear_user_highpage(page, addr);
 		flush_page_to_ram(page);
 		entry = pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
 	}
@@ -1208,6 +1216,10 @@
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, entry);
 	return 1;	/* Minor fault */
+
+no_mem:
+	spin_lock(&mm->page_table_lock);
+	return -1;
 }
 
 /*
@@ -1327,7 +1339,7 @@
 		 */
 		if (pte_none(entry))
 			return do_no_page(mm, vma, address, write_access, pte);
-		return do_swap_page(mm, vma, address, pte, pte_to_swp_entry(entry), write_access);
+		return do_swap_page(mm, vma, address, pte, entry, write_access);
 	}
 
 	entry = ptep_get_and_clear(pte);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
