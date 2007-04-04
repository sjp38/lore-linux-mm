Date: Wed, 4 Apr 2007 05:37:26 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc] no ZERO_PAGE?
Message-ID: <20070404033726.GE18507@wotan.suse.de>
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330024048.GG19407@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070330024048.GG19407@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Andrea Arcangeli <andrea@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 30, 2007 at 04:40:48AM +0200, Nick Piggin wrote:
> 
> Well it would make life easier if we got rid of ZERO_PAGE completely,
> which I definitely wouldn't complain about ;)

So, what bad things (apart from my bugs in untested code) happen
if we do this? We can actually go further, and probably remove the
ZERO_PAGE completely (just need an extra get_user_pages flag or
something for the core dumping issue).

Shall I do a more complete patchset and ask Andrew to give it a
run in -mm?

--

ZERO_PAGE for anonymous pages seems to only be designed to help stupid
programs, so remove it. This solves issues with ZERO_PAGE refcounting
and NUMA un-awareness.

(Actually, not quite. We should also remove all the zeromap stuff that
also seems to not do much except help stupid programs).

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1613,16 +1613,10 @@ gotten:
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
-	if (old_page == ZERO_PAGE(address)) {
-		new_page = alloc_zeroed_user_highpage(vma, address);
-		if (!new_page)
-			goto oom;
-	} else {
-		new_page = alloc_page_vma(GFP_HIGHUSER, vma, address);
-		if (!new_page)
-			goto oom;
-		cow_user_page(new_page, old_page, address, vma);
-	}
+	new_page = alloc_page_vma(GFP_HIGHUSER, vma, address);
+	if (!new_page)
+		goto oom;
+	cow_user_page(new_page, old_page, address, vma);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -2130,52 +2124,33 @@ static int do_anonymous_page(struct mm_s
 	spinlock_t *ptl;
 	pte_t entry;
 
-	if (write_access) {
-		/* Allocate our own private page. */
-		pte_unmap(page_table);
+	/* Allocate our own private page. */
+	pte_unmap(page_table);
 
-		if (unlikely(anon_vma_prepare(vma)))
-			goto oom;
-		page = alloc_zeroed_user_highpage(vma, address);
-		if (!page)
-			goto oom;
+	if (unlikely(anon_vma_prepare(vma)))
+		return VM_FAULT_OOM;
+	page = alloc_zeroed_user_highpage(vma, address);
+	if (!page)
+		return VM_FAULT_OOM;
 
-		entry = mk_pte(page, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	entry = mk_pte(page, vma->vm_page_prot);
+	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 
-		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-		if (!pte_none(*page_table))
-			goto release;
+	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (likely(!pte_none(*page_table))) {
 		inc_mm_counter(mm, anon_rss);
 		lru_cache_add_active(page);
 		page_add_new_anon_rmap(page, vma, address);
-	} else {
-		/* Map the ZERO_PAGE - vm_page_prot is readonly */
-		page = ZERO_PAGE(address);
-		page_cache_get(page);
-		entry = mk_pte(page, vma->vm_page_prot);
-
-		ptl = pte_lockptr(mm, pmd);
-		spin_lock(ptl);
-		if (!pte_none(*page_table))
-			goto release;
-		inc_mm_counter(mm, file_rss);
-		page_add_file_rmap(page);
-	}
-
-	set_pte_at(mm, address, page_table, entry);
+		set_pte_at(mm, address, page_table, entry);
 
-	/* No need to invalidate - it was non-present before */
-	update_mmu_cache(vma, address, entry);
-	lazy_mmu_prot_update(entry);
-unlock:
+		/* No need to invalidate - it was non-present before */
+		update_mmu_cache(vma, address, entry);
+		lazy_mmu_prot_update(entry);
+	} else
+		page_cache_release(page);
 	pte_unmap_unlock(page_table, ptl);
+
 	return VM_FAULT_MINOR;
-release:
-	page_cache_release(page);
-	goto unlock;
-oom:
-	return VM_FAULT_OOM;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
