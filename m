Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx3.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j0SLDhC8010079
	for <linux-mm@kvack.org>; Fri, 28 Jan 2005 13:13:50 -0800
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id j0SLnM0W155802258
	for <linux-mm@kvack.org>; Fri, 28 Jan 2005 13:49:22 -0800 (PST)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id j0SLkJae18450893
	for <linux-mm@kvack.org>; Fri, 28 Jan 2005 13:46:19 -0800 (PST)
Date: Fri, 28 Jan 2005 13:46:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] No page table lock COW
Message-ID: <Pine.LNX.4.58.0501281344560.19641@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Do not use the page_table_lock for COW.

Patch depends on the following patches having been applied first:

make_rss_atomic
pte_cmpxchg
ptl_drop_first_use
no_ptl_do_anon_page

Major issue:

The patch enabled the complete replacement of a pte without obtaining
the page_table_lock during COW. This means that obtaining the
page_table_lock does no longer ensures that a (read only) page is not replaced.
The page_table_lock will still have the effect that a writable pte is not
replaced.

I am not sure if this issue can be addressed at all without doing a full
rework of vm locking like in Nick Piggins' patches. But systems seem to boot
fine and survive a couple of tests (none of them targeted at this problem)
that I have run so far.

Index: linux-2.6.10/mm/memory.c
===================================================================
--- linux-2.6.10.orig/mm/memory.c	2005-01-27 17:02:41.000000000 -0800
+++ linux-2.6.10/mm/memory.c	2005-01-27 17:11:39.000000000 -0800
@@ -1256,21 +1256,6 @@ static inline pte_t maybe_mkwrite(pte_t
 }

 /*
- * We hold the mm semaphore for reading and vma->vm_mm->page_table_lock
- */
-static inline void break_cow(struct vm_area_struct * vma, struct page * new_page, unsigned long address,
-		pte_t *page_table)
-{
-	pte_t entry;
-
-	flush_cache_page(vma, address);
-	entry = maybe_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot)),
-			      vma);
-	ptep_establish(vma, address, page_table, entry);
-	update_mmu_cache(vma, address, entry);
-}
-
-/*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
  * and decrementing the shared-page counter for the old page.
@@ -1348,12 +1333,14 @@ static int do_wp_page(struct mm_struct *
 	copy_cow_page(old_page,new_page,address);

 	/*
-	 * Re-check the pte - so far we may not have acquired the
-	 * page_table_lock
+	 * Re-check the pte via a cmpxchg
 	 */
-	spin_lock(&mm->page_table_lock);
+	page_table_atomic_start(mm);
 	page_table = pte_offset_map(pmd, address);
-	if (likely(pte_same(*page_table, pte))) {
+	flush_cache_page(vma, address);
+	entry = maybe_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot)),
+			vma);
+	if (ptep_cmpxchg(page_table, pte, entry)) {
 		if (PageAnon(old_page))
 			update_mm_counter(mm, anon_rss, -1);
 		if (PageReserved(old_page)) {
@@ -1363,7 +1350,7 @@ static int do_wp_page(struct mm_struct *
 		} else

 			page_remove_rmap(old_page);
-		break_cow(vma, new_page, address, page_table);
+		update_mmu_cache(vma, address, entry);
 		lru_cache_add_active(new_page);
 		page_add_anon_rmap(new_page, vma, address);

@@ -1373,7 +1360,7 @@ static int do_wp_page(struct mm_struct *
 	pte_unmap(page_table);
 	page_cache_release(new_page);
 	page_cache_release(old_page);
-	spin_unlock(&mm->page_table_lock);
+	page_table_atomic_stop(mm);
 	return VM_FAULT_MINOR;

 no_new_page:
@@ -1722,15 +1709,15 @@ static int do_swap_page(struct mm_struct
 			/*
 			 * Back out if somebody else faulted in this pte
 			 */
-			spin_lock(&mm->page_table_lock);
+			page_table_atomic_start(mm);
 			page_table = pte_offset_map(pmd, address);
 			if (likely(pte_same(*page_table, orig_pte)))
 				ret = VM_FAULT_OOM;
 			else
 				ret = VM_FAULT_MINOR;
 			pte_unmap(page_table);
-			spin_unlock(&mm->page_table_lock);
-			goto out;
+			page_table_atomic_stop(&mm->page_table_lock);
+			return ret;
 		}

 		/* Had to read the page from swap area: Major fault */
@@ -1740,56 +1727,46 @@ static int do_swap_page(struct mm_struct
 	}

 	SetPageReferenced(page);
+	/* The lock here is enough to guarantee exclusivity in the
+	 * following code. Any other access before the pte is installed
+	 * will wait at lock_page.
+	 */
 	lock_page(page);

 	/*
 	 * Back out if somebody else faulted in this pte
 	 */
-	spin_lock(&mm->page_table_lock);
-	page_table = pte_offset_map(pmd, address);
-	if (unlikely(!pte_same(*page_table, orig_pte))) {
-		pte_unmap(page_table);
-		spin_unlock(&mm->page_table_lock);
-		unlock_page(page);
-		page_cache_release(page);
-		ret = VM_FAULT_MINOR;
-		goto out;
-	}
-
-	/* The page isn't present yet, go ahead with the fault. */
-
-	swap_free(entry);
-	if (vm_swap_full())
-		remove_exclusive_swap_page(page);
-
-	update_mm_counter(mm, rss, 1);
-	acct_update_integrals();
-	update_mem_hiwater();
-
 	pte = mk_pte(page, vma->vm_page_prot);
 	if (write_access && can_share_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		write_access = 0;
 	}
-	unlock_page(page);
-
+
 	flush_icache_page(vma, page);
-	set_pte(page_table, pte);
-	page_add_anon_rmap(page, vma, address);
-
-	/* No need to invalidate - it was non-present before */
-	update_mmu_cache(vma, address, pte);
-	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
+	if (ptep_cmpxchg(page_table, orig_pte, pte)) {
+		unlock_page(page);

-	if (write_access) {
-		page_table_atomic_start(mm);
-		if (do_wp_page(mm, vma, address,
-				page_table, pmd, pte) == VM_FAULT_OOM)
-			ret = VM_FAULT_OOM;
+		page_add_anon_rmap(page, vma, address);
+		swap_free(entry);
+		if (vm_swap_full())
+			remove_exclusive_swap_page(page);
+		update_mm_counter(mm, rss, 1);
+		acct_update_integrals();
+		update_mem_hiwater();
+		if (write_access) {
+			if (do_wp_page(mm, vma, address,
+					page_table, pmd, pte) == VM_FAULT_OOM)
+				return VM_FAULT_OOM;
+			return ret;
+		}
+	} else {
+		/* Another thread was racing with us an won */
+		pte_unmap(page_table);
+		unlock_page(page);
+		page_cache_release(page);
 	}

-out:
+	page_table_atomic_stop(mm);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
