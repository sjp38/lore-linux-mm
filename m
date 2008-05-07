Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 03 of 11] invalidate_page outside PT lock
Message-Id: <d60d200565abde6a8ed4.1210170953@duo.random>
In-Reply-To: <patchbomb.1210170950@duo.random>
Date: Wed, 07 May 2008 16:35:53 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1210115129 -7200
# Node ID d60d200565abde6a8ed45271e53cde9c5c75b426
# Parent  c5badbefeee07518d9d1acca13e94c981420317c
invalidate_page outside PT lock

Moves all mmu notifier methods outside the PT lock (first and not last
step to make them sleep capable).

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -210,35 +210,6 @@ static inline void mmu_notifier_mm_destr
 		__mmu_notifier_mm_destroy(mm);
 }
 
-/*
- * These two macros will sometime replace ptep_clear_flush.
- * ptep_clear_flush is impleemnted as macro itself, so this also is
- * implemented as a macro until ptep_clear_flush will converted to an
- * inline function, to diminish the risk of compilation failure. The
- * invalidate_page method over time can be moved outside the PT lock
- * and these two macros can be later removed.
- */
-#define ptep_clear_flush_notify(__vma, __address, __ptep)		\
-({									\
-	pte_t __pte;							\
-	struct vm_area_struct *___vma = __vma;				\
-	unsigned long ___address = __address;				\
-	__pte = ptep_clear_flush(___vma, ___address, __ptep);		\
-	mmu_notifier_invalidate_page(___vma->vm_mm, ___address);	\
-	__pte;								\
-})
-
-#define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
-({									\
-	int __young;							\
-	struct vm_area_struct *___vma = __vma;				\
-	unsigned long ___address = __address;				\
-	__young = ptep_clear_flush_young(___vma, ___address, __ptep);	\
-	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\
-						  ___address);		\
-	__young;							\
-})
-
 #else /* CONFIG_MMU_NOTIFIER */
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
@@ -274,9 +245,6 @@ static inline void mmu_notifier_mm_destr
 {
 }
 
-#define ptep_clear_flush_young_notify ptep_clear_flush_young
-#define ptep_clear_flush_notify ptep_clear_flush
-
 #endif /* CONFIG_MMU_NOTIFIER */
 
 #endif /* _LINUX_MMU_NOTIFIER_H */
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -188,11 +188,13 @@ __xip_unmap (struct address_space * mapp
 		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
-			pteval = ptep_clear_flush_notify(vma, address, pte);
+			pteval = ptep_clear_flush(vma, address, pte);
 			page_remove_rmap(page, vma);
 			dec_mm_counter(mm, file_rss);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
+			/* must invalidate_page _before_ freeing the page */
+			mmu_notifier_invalidate_page(mm, address);
 			page_cache_release(page);
 		}
 	}
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1714,9 +1714,10 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			page_cache_release(old_page);
+			new_page = NULL;
 			if (!pte_same(*page_table, orig_pte))
 				goto unlock;
+			page_cache_release(old_page);
 
 			page_mkwrite = 1;
 		}
@@ -1732,6 +1733,7 @@ static int do_wp_page(struct mm_struct *
 		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, entry);
 		ret |= VM_FAULT_WRITE;
+		old_page = new_page = NULL;
 		goto unlock;
 	}
 
@@ -1776,7 +1778,7 @@ gotten:
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush_notify(vma, address, page_table);
+		ptep_clear_flush(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		lru_cache_add_active(new_page);
@@ -1788,12 +1790,18 @@ gotten:
 	} else
 		mem_cgroup_uncharge_page(new_page);
 
-	if (new_page)
+unlock:
+	pte_unmap_unlock(page_table, ptl);
+
+	if (new_page) {
+		if (new_page == old_page)
+			/* cow happened, notify before releasing old_page */
+			mmu_notifier_invalidate_page(mm, address);
 		page_cache_release(new_page);
+	}
 	if (old_page)
 		page_cache_release(old_page);
-unlock:
-	pte_unmap_unlock(page_table, ptl);
+
 	if (dirty_page) {
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -275,7 +275,7 @@ static int page_referenced_one(struct pa
 	unsigned long address;
 	pte_t *pte;
 	spinlock_t *ptl;
-	int referenced = 0;
+	int referenced = 0, clear_flush_young = 0;
 
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
@@ -288,8 +288,11 @@ static int page_referenced_one(struct pa
 	if (vma->vm_flags & VM_LOCKED) {
 		referenced++;
 		*mapcount = 1;	/* break early from loop */
-	} else if (ptep_clear_flush_young_notify(vma, address, pte))
-		referenced++;
+	} else {
+		clear_flush_young = 1;
+		if (ptep_clear_flush_young(vma, address, pte))
+			referenced++;
+	}
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
@@ -299,6 +302,10 @@ static int page_referenced_one(struct pa
 
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
+
+	if (clear_flush_young)
+		referenced += mmu_notifier_clear_flush_young(mm, address);
+
 out:
 	return referenced;
 }
@@ -458,7 +465,7 @@ static int page_mkclean_one(struct page 
 		pte_t entry;
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		entry = ptep_clear_flush_notify(vma, address, pte);
+		entry = ptep_clear_flush(vma, address, pte);
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
@@ -466,6 +473,10 @@ static int page_mkclean_one(struct page 
 	}
 
 	pte_unmap_unlock(pte, ptl);
+
+	if (ret)
+		mmu_notifier_invalidate_page(mm, address);
+
 out:
 	return ret;
 }
@@ -717,15 +728,14 @@ static int try_to_unmap_one(struct page 
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young_notify(vma, address, pte)))) {
+	if (!migration && (vma->vm_flags & VM_LOCKED)) {
 		ret = SWAP_FAIL;
 		goto out_unmap;
 	}
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
-	pteval = ptep_clear_flush_notify(vma, address, pte);
+	pteval = ptep_clear_flush(vma, address, pte);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
@@ -780,6 +790,8 @@ static int try_to_unmap_one(struct page 
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
+	if (ret != SWAP_FAIL)
+		mmu_notifier_invalidate_page(mm, address);
 out:
 	return ret;
 }
@@ -818,7 +830,7 @@ static void try_to_unmap_cluster(unsigne
 	spinlock_t *ptl;
 	struct page *page;
 	unsigned long address;
-	unsigned long end;
+	unsigned long start, end;
 
 	address = (vma->vm_start + cursor) & CLUSTER_MASK;
 	end = address + CLUSTER_SIZE;
@@ -839,6 +851,8 @@ static void try_to_unmap_cluster(unsigne
 	if (!pmd_present(*pmd))
 		return;
 
+	start = address;
+	mmu_notifier_invalidate_range_start(mm, start, end);
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 
 	/* Update high watermark before we lower rss */
@@ -850,12 +864,12 @@ static void try_to_unmap_cluster(unsigne
 		page = vm_normal_page(vma, address, *pte);
 		BUG_ON(!page || PageAnon(page));
 
-		if (ptep_clear_flush_young_notify(vma, address, pte))
+		if (ptep_clear_flush_young(vma, address, pte))
 			continue;
 
 		/* Nuke the page table entry. */
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		pteval = ptep_clear_flush_notify(vma, address, pte);
+		pteval = ptep_clear_flush(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address))
@@ -871,6 +885,7 @@ static void try_to_unmap_cluster(unsigne
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 }
 
 static int try_to_unmap_anon(struct page *page, int migration)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
