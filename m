Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 91C3C600580
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 15:49:29 -0500 (EST)
Message-Id: <20100104182813.270919564@chello.nl>
References: <20100104182429.833180340@chello.nl>
Date: Mon, 04 Jan 2010 19:24:31 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 2/8] mm: Speculative pagefault infrastructure
Content-Disposition: inline; filename=mm-foo-6.patch
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Replace pte_offset_map_lock() usage in the pagefault path with
pte_map_lock() which when called with .flags & FAULT_FLAG_SPECULATIVE
can fail, in which case we should return VM_FAULT_RETRY, meaning we
need to retry the fault (or do one with mmap_sem held).

This patch adds both FAULT_FLAG_SPECULATIVE, VM_FAULT_RETRY and the
error paths.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm.h |    2 
 mm/memory.c        |  119 ++++++++++++++++++++++++++++++++++++++---------------
 2 files changed, 88 insertions(+), 33 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -136,6 +136,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
 #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
 #define FAULT_FLAG_MKWRITE	0x04	/* Fault was mkwrite of existing pte */
+#define FAULT_FLAG_SPECULATIVE	0x08
 
 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
@@ -711,6 +712,7 @@ static inline int page_mapped(struct pag
 
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
+#define VM_FAULT_RETRY  0x0400
 
 #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_HWPOISON)
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1957,6 +1957,14 @@ static inline void cow_user_page(struct 
 		copy_user_highpage(dst, src, va, vma);
 }
 
+static int pte_map_lock(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmd, unsigned int flags,
+		pte_t **ptep, spinlock_t **ptl)
+{
+	*ptep = pte_offset_map_lock(mm, pmd, address, ptl);
+	return 1;
+}
+
 /*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
@@ -1977,7 +1985,7 @@ static inline void cow_user_page(struct 
  */
 static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		spinlock_t *ptl, pte_t orig_pte)
+		spinlock_t *ptl, unsigned int flags, pte_t orig_pte)
 {
 	struct page *old_page, *new_page;
 	pte_t entry;
@@ -2009,8 +2017,14 @@ static int do_wp_page(struct mm_struct *
 			page_cache_get(old_page);
 			pte_unmap_unlock(page_table, ptl);
 			lock_page(old_page);
-			page_table = pte_offset_map_lock(mm, pmd, address,
-							 &ptl);
+
+			if (!pte_map_lock(mm, vma, address, pmd, flags,
+						&page_table, &ptl)) {
+				unlock_page(old_page);
+				ret = VM_FAULT_RETRY;
+				goto err;
+			}
+
 			if (!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
 				page_cache_release(old_page);
@@ -2052,14 +2066,14 @@ static int do_wp_page(struct mm_struct *
 			if (unlikely(tmp &
 					(VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
 				ret = tmp;
-				goto unwritable_page;
+				goto err;
 			}
 			if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
 				lock_page(old_page);
 				if (!old_page->mapping) {
 					ret = 0; /* retry the fault */
 					unlock_page(old_page);
-					goto unwritable_page;
+					goto err;
 				}
 			} else
 				VM_BUG_ON(!PageLocked(old_page));
@@ -2070,8 +2084,13 @@ static int do_wp_page(struct mm_struct *
 			 * they did, we just return, as we can count on the
 			 * MMU to tell us if they didn't also make it writable.
 			 */
-			page_table = pte_offset_map_lock(mm, pmd, address,
-							 &ptl);
+			if (!pte_map_lock(mm, vma, address, pmd, flags,
+						&page_table, &ptl)) {
+				unlock_page(old_page);
+				ret = VM_FAULT_RETRY;
+				goto err;
+			}
+
 			if (!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
 				page_cache_release(old_page);
@@ -2103,17 +2122,23 @@ reuse:
 gotten:
 	pte_unmap_unlock(page_table, ptl);
 
-	if (unlikely(anon_vma_prepare(vma)))
-		goto oom;
+	if (unlikely(anon_vma_prepare(vma))) {
+		ret = VM_FAULT_OOM;
+		goto err;
+	}
 
 	if (is_zero_pfn(pte_pfn(orig_pte))) {
 		new_page = alloc_zeroed_user_highpage_movable(vma, address);
-		if (!new_page)
-			goto oom;
+		if (!new_page) {
+			ret = VM_FAULT_OOM;
+			goto err;
+		}
 	} else {
 		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
-		if (!new_page)
-			goto oom;
+		if (!new_page) {
+			ret = VM_FAULT_OOM;
+			goto err;
+		}
 		cow_user_page(new_page, old_page, address, vma);
 	}
 	__SetPageUptodate(new_page);
@@ -2128,13 +2153,20 @@ gotten:
 		unlock_page(old_page);
 	}
 
-	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
-		goto oom_free_new;
+	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL)) {
+		ret = VM_FAULT_OOM;
+		goto err_free_new;
+	}
 
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!pte_map_lock(mm, vma, address, pmd, flags, &page_table, &ptl)) {
+		mem_cgroup_uncharge_page(new_page);
+		ret = VM_FAULT_RETRY;
+		goto err_free_new;
+	}
+
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
@@ -2233,9 +2265,9 @@ unlock:
 			file_update_time(vma->vm_file);
 	}
 	return ret;
-oom_free_new:
+err_free_new:
 	page_cache_release(new_page);
-oom:
+err:
 	if (old_page) {
 		if (page_mkwrite) {
 			unlock_page(old_page);
@@ -2243,10 +2275,6 @@ oom:
 		}
 		page_cache_release(old_page);
 	}
-	return VM_FAULT_OOM;
-
-unwritable_page:
-	page_cache_release(old_page);
 	return ret;
 }
 
@@ -2496,6 +2524,10 @@ static int do_swap_page(struct mm_struct
 	entry = pte_to_swp_entry(orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
+			if (flags & FAULT_FLAG_SPECULATIVE) {
+				ret = VM_FAULT_RETRY;
+				goto out;
+			}
 			migration_entry_wait(mm, pmd, address);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
@@ -2516,7 +2548,11 @@ static int do_swap_page(struct mm_struct
 			 * Back out if somebody else faulted in this pte
 			 * while we released the pte lock.
 			 */
-			page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+			if (!pte_map_lock(mm, vma, address, pmd, flags,
+						&page_table, &ptl)) {
+				ret = VM_FAULT_RETRY;
+				goto out;
+			}
 			if (likely(pte_same(*page_table, orig_pte)))
 				ret = VM_FAULT_OOM;
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
@@ -2553,7 +2589,11 @@ static int do_swap_page(struct mm_struct
 	/*
 	 * Back out if somebody else already faulted in this pte.
 	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!pte_map_lock(mm, vma, address, pmd, flags, &page_table, &ptl)) {
+		ret = VM_FAULT_RETRY;
+		goto out_nolock;
+	}
+
 	if (unlikely(!pte_same(*page_table, orig_pte)))
 		goto out_nomap;
 
@@ -2594,7 +2634,7 @@ static int do_swap_page(struct mm_struct
 	unlock_page(page);
 
 	if (flags & FAULT_FLAG_WRITE) {
-		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
+		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, flags, pte);
 		if (ret & VM_FAULT_ERROR)
 			ret &= VM_FAULT_ERROR;
 		goto out;
@@ -2607,8 +2647,9 @@ unlock:
 out:
 	return ret;
 out_nomap:
-	mem_cgroup_cancel_charge_swapin(ptr);
 	pte_unmap_unlock(page_table, ptl);
+out_nolock:
+	mem_cgroup_cancel_charge_swapin(ptr);
 out_page:
 	unlock_page(page);
 out_release:
@@ -2631,7 +2672,9 @@ static int do_anonymous_page(struct mm_s
 	if (!(flags & FAULT_FLAG_WRITE)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
 						vma->vm_page_prot));
-		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+		if (!pte_map_lock(mm, vma, address, pmd, flags,
+					&page_table, &ptl))
+			return VM_FAULT_RETRY;
 		if (!pte_none(*page_table))
 			goto unlock;
 		goto setpte;
@@ -2654,7 +2697,12 @@ static int do_anonymous_page(struct mm_s
 	if (vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!pte_map_lock(mm, vma, address, pmd, flags, &page_table, &ptl)) {
+		mem_cgroup_uncharge_page(page);
+		page_cache_release(page);
+		return VM_FAULT_RETRY;
+	}
+
 	if (!pte_none(*page_table))
 		goto release;
 
@@ -2793,7 +2841,10 @@ static int __do_fault(struct mm_struct *
 
 	}
 
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!pte_map_lock(mm, vma, address, pmd, flags, &page_table, &ptl)) {
+		ret = VM_FAULT_RETRY;
+		goto out_uncharge;
+	}
 
 	/*
 	 * This silly early PAGE_DIRTY setting removes a race
@@ -2826,7 +2877,10 @@ static int __do_fault(struct mm_struct *
 
 		/* no need to invalidate: a not-present page won't be cached */
 		update_mmu_cache(vma, address, entry);
+		pte_unmap_unlock(page_table, ptl);
 	} else {
+		pte_unmap_unlock(page_table, ptl);
+out_uncharge:
 		if (charged)
 			mem_cgroup_uncharge_page(page);
 		if (anon)
@@ -2835,8 +2889,6 @@ static int __do_fault(struct mm_struct *
 			anon = 1; /* no anon but release faulted_page */
 	}
 
-	pte_unmap_unlock(page_table, ptl);
-
 out:
 	if (dirty_page) {
 		struct address_space *mapping = page->mapping;
@@ -2945,13 +2997,14 @@ static inline int handle_pte_fault(struc
 					pmd, flags, entry);
 	}
 
-	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!pte_map_lock(mm, vma, address, pmd, flags, &pte, &ptl))
+		return VM_FAULT_RETRY;
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
 			return do_wp_page(mm, vma, address,
-					pte, pmd, ptl, entry);
+					pte, pmd, ptl, flags, entry);
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
