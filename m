Date: Thu, 29 Mar 2007 09:58:05 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 1/2] mm: dont account ZERO_PAGE
Message-ID: <20070329075805.GA6852@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
Cc: tee@sgi.com, holt@sgi.com
List-ID: <linux-mm.kvack.org>

Special-case the ZERO_PAGE to prevent it from being accounted like a normal
mapped page. This is not illogical or unclean, because the ZERO_PAGE is
heavily special cased through the page fault path.

This requires Carsten Otte's filemap_xip patch, as well as restoring the
move_pte function for MIPS which was removed after I noticed it didn't
handle the ZERO_PAGE accounting correctly (which is not an issue after
this patch).

A test-case which took over 2 hours to complete on a 1024 core Altix
takes around 2 seconds afterward.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -479,7 +479,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	pte = pte_mkold(pte);
 
 	page = vm_normal_page(vma, addr, pte);
-	if (page) {
+	if (likely(page && page != ZERO_PAGE(addr))) {
 		get_page(page);
 		page_dup_rmap(page);
 		rss[!!PageAnon(page)]++;
@@ -665,7 +665,7 @@ static unsigned long zap_pte_range(struc
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
 			tlb_remove_tlb_entry(tlb, pte, addr);
-			if (unlikely(!page))
+			if (unlikely(!page || page == ZERO_PAGE(addr)))
 				continue;
 			if (unlikely(details) && details->nonlinear_vma
 			    && linear_page_index(details->nonlinear_vma,
@@ -1125,9 +1125,6 @@ static int zeromap_pte_range(struct mm_s
 			pte++;
 			break;
 		}
-		page_cache_get(page);
-		page_add_file_rmap(page);
-		inc_mm_counter(mm, file_rss);
 		set_pte_at(mm, addr, pte, zero_pte);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
@@ -1629,7 +1626,7 @@ gotten:
 	 */
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (likely(pte_same(*page_table, orig_pte))) {
-		if (old_page) {
+		if (likely(old_page && old_page != ZERO_PAGE(address))) {
 			page_remove_rmap(old_page, vma);
 			if (!PageAnon(old_page)) {
 				dec_mm_counter(mm, file_rss);
@@ -1659,7 +1656,7 @@ gotten:
 	}
 	if (new_page)
 		page_cache_release(new_page);
-	if (old_page)
+	if (old_page && old_page != ZERO_PAGE(address))
 		page_cache_release(old_page);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
@@ -2152,15 +2149,12 @@ static int do_anonymous_page(struct mm_s
 	} else {
 		/* Map the ZERO_PAGE - vm_page_prot is readonly */
 		page = ZERO_PAGE(address);
-		page_cache_get(page);
 		entry = mk_pte(page, vma->vm_page_prot);
 
 		ptl = pte_lockptr(mm, pmd);
 		spin_lock(ptl);
 		if (!pte_none(*page_table))
-			goto release;
-		inc_mm_counter(mm, file_rss);
-		page_add_file_rmap(page);
+			goto unlock;
 	}
 
 	set_pte_at(mm, address, page_table, entry);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
