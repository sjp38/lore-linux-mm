Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 45FD2828DF
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 20:24:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e190so214547307pfe.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 17:24:32 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 133si5207123pfb.209.2016.04.15.17.24.18
        for <linux-mm@kvack.org>;
        Fri, 15 Apr 2016 17:24:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 03/29] mm: introduce fault_env
Date: Sat, 16 Apr 2016 03:23:34 +0300
Message-Id: <1460766240-84565-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The idea borrowed from Peter's patch from patchset on speculative page
faults[1]:

Instead of passing around the endless list of function arguments,
replace the lot with a single structure so we can change context
without endless function signature changes.

The changes are mostly mechanical with exception of faultaround code:
filemap_map_pages() got reworked a bit.

This patch is preparation for the next one.

[1] http://lkml.kernel.org/r/20141020222841.302891540@infradead.org

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 Documentation/filesystems/Locking |  10 +-
 fs/userfaultfd.c                  |  22 +-
 include/linux/huge_mm.h           |  20 +-
 include/linux/mm.h                |  34 ++-
 include/linux/userfaultfd_k.h     |   8 +-
 mm/filemap.c                      |  28 +-
 mm/huge_memory.c                  | 280 +++++++++---------
 mm/internal.h                     |   4 +-
 mm/memory.c                       | 579 ++++++++++++++++++--------------------
 mm/nommu.c                        |   3 +-
 10 files changed, 473 insertions(+), 515 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 619af9bfdcb3..7f77837a7cf1 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -544,13 +544,13 @@ subsequent truncate), and then return with VM_FAULT_LOCKED, and the page
 locked. The VM will unlock the page.
 
 	->map_pages() is called when VM asks to map easy accessible pages.
-Filesystem should find and map pages associated with offsets from "pgoff"
-till "max_pgoff". ->map_pages() is called with page table locked and must
+Filesystem should find and map pages associated with offsets from "start_pgoff"
+till "end_pgoff". ->map_pages() is called with page table locked and must
 not block.  If it's not possible to reach a page without blocking,
 filesystem should skip it. Filesystem should use do_set_pte() to setup
-page table entry. Pointer to entry associated with offset "pgoff" is
-passed in "pte" field in vm_fault structure. Pointers to entries for other
-offsets should be calculated relative to "pte".
+page table entry. Pointer to entry associated with the page is passed in
+"pte" field in fault_env structure. Pointers to entries for other offsets
+should be calculated relative to "pte".
 
 	->page_mkwrite() is called when a previously read-only pte is
 about to become writeable. The filesystem again must ensure that there are
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 66cdb44616d5..588e9da27ab4 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -257,10 +257,9 @@ out:
  * fatal_signal_pending()s, and the mmap_sem must be released before
  * returning it.
  */
-int handle_userfault(struct vm_area_struct *vma, unsigned long address,
-		     unsigned int flags, unsigned long reason)
+int handle_userfault(struct fault_env *fe, unsigned long reason)
 {
-	struct mm_struct *mm = vma->vm_mm;
+	struct mm_struct *mm = fe->vma->vm_mm;
 	struct userfaultfd_ctx *ctx;
 	struct userfaultfd_wait_queue uwq;
 	int ret;
@@ -269,7 +268,7 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
 	ret = VM_FAULT_SIGBUS;
-	ctx = vma->vm_userfaultfd_ctx.ctx;
+	ctx = fe->vma->vm_userfaultfd_ctx.ctx;
 	if (!ctx)
 		goto out;
 
@@ -302,17 +301,17 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	 * without first stopping userland access to the memory. For
 	 * VM_UFFD_MISSING userfaults this is enough for now.
 	 */
-	if (unlikely(!(flags & FAULT_FLAG_ALLOW_RETRY))) {
+	if (unlikely(!(fe->flags & FAULT_FLAG_ALLOW_RETRY))) {
 		/*
 		 * Validate the invariant that nowait must allow retry
 		 * to be sure not to return SIGBUS erroneously on
 		 * nowait invocations.
 		 */
-		BUG_ON(flags & FAULT_FLAG_RETRY_NOWAIT);
+		BUG_ON(fe->flags & FAULT_FLAG_RETRY_NOWAIT);
 #ifdef CONFIG_DEBUG_VM
 		if (printk_ratelimit()) {
 			printk(KERN_WARNING
-			       "FAULT_FLAG_ALLOW_RETRY missing %x\n", flags);
+			       "FAULT_FLAG_ALLOW_RETRY missing %x\n", fe->flags);
 			dump_stack();
 		}
 #endif
@@ -324,7 +323,7 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	 * and wait.
 	 */
 	ret = VM_FAULT_RETRY;
-	if (flags & FAULT_FLAG_RETRY_NOWAIT)
+	if (fe->flags & FAULT_FLAG_RETRY_NOWAIT)
 		goto out;
 
 	/* take the reference before dropping the mmap_sem */
@@ -332,10 +331,11 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 
 	init_waitqueue_func_entry(&uwq.wq, userfaultfd_wake_function);
 	uwq.wq.private = current;
-	uwq.msg = userfault_msg(address, flags, reason);
+	uwq.msg = userfault_msg(fe->address, fe->flags, reason);
 	uwq.ctx = ctx;
 
-	return_to_userland = (flags & (FAULT_FLAG_USER|FAULT_FLAG_KILLABLE)) ==
+	return_to_userland =
+		(fe->flags & (FAULT_FLAG_USER|FAULT_FLAG_KILLABLE)) ==
 		(FAULT_FLAG_USER|FAULT_FLAG_KILLABLE);
 
 	spin_lock(&ctx->fault_pending_wqh.lock);
@@ -353,7 +353,7 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 			  TASK_KILLABLE);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 
-	must_wait = userfaultfd_must_wait(ctx, address, flags, reason);
+	must_wait = userfaultfd_must_wait(ctx, fe->address, fe->flags, reason);
 	up_read(&mm->mmap_sem);
 
 	if (likely(must_wait && !ACCESS_ONCE(ctx->released) &&
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index d0367c523a0d..05efca1619b6 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -1,20 +1,12 @@
 #ifndef _LINUX_HUGE_MM_H
 #define _LINUX_HUGE_MM_H
 
-extern int do_huge_pmd_anonymous_page(struct mm_struct *mm,
-				      struct vm_area_struct *vma,
-				      unsigned long address, pmd_t *pmd,
-				      unsigned int flags);
+extern int do_huge_pmd_anonymous_page(struct fault_env *fe);
 extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 			 struct vm_area_struct *vma);
-extern void huge_pmd_set_accessed(struct mm_struct *mm,
-				  struct vm_area_struct *vma,
-				  unsigned long address, pmd_t *pmd,
-				  pmd_t orig_pmd, int dirty);
-extern int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
-			       unsigned long address, pmd_t *pmd,
-			       pmd_t orig_pmd);
+extern void huge_pmd_set_accessed(struct fault_env *fe, pmd_t orig_pmd);
+extern int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd);
 extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  unsigned long addr,
 					  pmd_t *pmd,
@@ -134,8 +126,7 @@ static inline int hpage_nr_pages(struct page *page)
 	return 1;
 }
 
-extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
-				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
+extern int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t orig_pmd);
 
 extern struct page *huge_zero_page;
 
@@ -195,8 +186,7 @@ static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 	return NULL;
 }
 
-static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
-					unsigned long addr, pmd_t pmd, pmd_t *pmdp)
+static inline int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t orig_pmd)
 {
 	return 0;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8fc68ed3c862..696ec39b616b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -299,10 +299,27 @@ struct vm_fault {
 					 * is set (which is also implied by
 					 * VM_FAULT_ERROR).
 					 */
-	/* for ->map_pages() only */
-	pgoff_t max_pgoff;		/* map pages for offset from pgoff till
-					 * max_pgoff inclusive */
-	pte_t *pte;			/* pte entry associated with ->pgoff */
+};
+
+/*
+ * Page fault context: passes though page fault handler instead of endless list
+ * of function arguments.
+ */
+struct fault_env {
+	struct vm_area_struct *vma;	/* Target VMA */
+	unsigned long address;		/* Faulting virtual address */
+	unsigned int flags;		/* FAULT_FLAG_xxx flags */
+	pmd_t *pmd;			/* Pointer to pmd entry matching
+					 * the 'address'
+					 */
+	pte_t *pte;			/* Pointer to pte entry matching
+					 * the 'address'. NULL if the page
+					 * table hasn't been allocated.
+					 */
+	spinlock_t *ptl;		/* Page table lock.
+					 * Protects pte page table if 'pte'
+					 * is not NULL, otherwise pmd.
+					 */
 };
 
 /*
@@ -317,7 +334,8 @@ struct vm_operations_struct {
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
 	int (*pmd_fault)(struct vm_area_struct *, unsigned long address,
 						pmd_t *, unsigned int flags);
-	void (*map_pages)(struct vm_area_struct *vma, struct vm_fault *vmf);
+	void (*map_pages)(struct fault_env *fe,
+			pgoff_t start_pgoff, pgoff_t end_pgoff);
 
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
@@ -583,8 +601,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 	return pte;
 }
 
-void do_set_pte(struct vm_area_struct *vma, unsigned long address,
-		struct page *page, pte_t *pte, bool write, bool anon);
+void do_set_pte(struct fault_env *fe, struct page *page);
 #endif
 
 /*
@@ -2119,7 +2136,8 @@ extern void truncate_inode_pages_final(struct address_space *);
 
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
-extern void filemap_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf);
+extern void filemap_map_pages(struct fault_env *fe,
+		pgoff_t start_pgoff, pgoff_t end_pgoff);
 extern int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 /* mm/page-writeback.c */
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 587480ad41b7..dd66a952e8cd 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -27,8 +27,7 @@
 #define UFFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
 #define UFFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS)
 
-extern int handle_userfault(struct vm_area_struct *vma, unsigned long address,
-			    unsigned int flags, unsigned long reason);
+extern int handle_userfault(struct fault_env *fe, unsigned long reason);
 
 extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
 			    unsigned long src_start, unsigned long len);
@@ -56,10 +55,7 @@ static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
-static inline int handle_userfault(struct vm_area_struct *vma,
-				   unsigned long address,
-				   unsigned int flags,
-				   unsigned long reason)
+static inline int handle_userfault(struct fault_env *fe, unsigned long reason)
 {
 	return VM_FAULT_SIGBUS;
 }
diff --git a/mm/filemap.c b/mm/filemap.c
index f2479af09da9..e32e5d70fc0c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2131,22 +2131,27 @@ page_not_uptodate:
 }
 EXPORT_SYMBOL(filemap_fault);
 
-void filemap_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf)
+void filemap_map_pages(struct fault_env *fe,
+		pgoff_t start_pgoff, pgoff_t end_pgoff)
 {
 	struct radix_tree_iter iter;
 	void **slot;
-	struct file *file = vma->vm_file;
+	struct file *file = fe->vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
+	pgoff_t last_pgoff = start_pgoff;
 	loff_t size;
 	struct page *page;
-	unsigned long address = (unsigned long) vmf->virtual_address;
-	unsigned long addr;
-	pte_t *pte;
 
 	rcu_read_lock();
-	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, vmf->pgoff) {
-		if (iter.index > vmf->max_pgoff)
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
+			start_pgoff) {
+		if (iter.index > end_pgoff)
 			break;
+		fe->pte += iter.index - last_pgoff;
+		fe->address += (iter.index - last_pgoff) << PAGE_SHIFT;
+		last_pgoff = iter.index;
+		if (!pte_none(*fe->pte))
+			goto next;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -2182,14 +2187,9 @@ repeat:
 		if (page->index >= size >> PAGE_SHIFT)
 			goto unlock;
 
-		pte = vmf->pte + page->index - vmf->pgoff;
-		if (!pte_none(*pte))
-			goto unlock;
-
 		if (file->f_ra.mmap_miss > 0)
 			file->f_ra.mmap_miss--;
-		addr = address + (page->index - vmf->pgoff) * PAGE_SIZE;
-		do_set_pte(vma, addr, page, pte, false, false);
+		do_set_pte(fe, page);
 		unlock_page(page);
 		goto next;
 unlock:
@@ -2197,7 +2197,7 @@ unlock:
 skip:
 		put_page(page);
 next:
-		if (iter.index == vmf->max_pgoff)
+		if (iter.index == end_pgoff)
 			break;
 	}
 	rcu_read_unlock();
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5211c59e5f26..a4014b484737 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -821,26 +821,23 @@ void prep_transhuge_page(struct page *page)
 	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
 }
 
-static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
-					struct vm_area_struct *vma,
-					unsigned long address, pmd_t *pmd,
-					struct page *page, gfp_t gfp,
-					unsigned int flags)
+static int __do_huge_pmd_anonymous_page(struct fault_env *fe, struct page *page,
+		gfp_t gfp)
 {
+	struct vm_area_struct *vma = fe->vma;
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
-	spinlock_t *ptl;
-	unsigned long haddr = address & HPAGE_PMD_MASK;
+	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
-	if (mem_cgroup_try_charge(page, mm, gfp, &memcg, true)) {
+	if (mem_cgroup_try_charge(page, vma->vm_mm, gfp, &memcg, true)) {
 		put_page(page);
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
 
-	pgtable = pte_alloc_one(mm, haddr);
+	pgtable = pte_alloc_one(vma->vm_mm, haddr);
 	if (unlikely(!pgtable)) {
 		mem_cgroup_cancel_charge(page, memcg, true);
 		put_page(page);
@@ -855,12 +852,12 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	 */
 	__SetPageUptodate(page);
 
-	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_none(*pmd))) {
-		spin_unlock(ptl);
+	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
+	if (unlikely(!pmd_none(*fe->pmd))) {
+		spin_unlock(fe->ptl);
 		mem_cgroup_cancel_charge(page, memcg, true);
 		put_page(page);
-		pte_free(mm, pgtable);
+		pte_free(vma->vm_mm, pgtable);
 	} else {
 		pmd_t entry;
 
@@ -868,12 +865,11 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		if (userfaultfd_missing(vma)) {
 			int ret;
 
-			spin_unlock(ptl);
+			spin_unlock(fe->ptl);
 			mem_cgroup_cancel_charge(page, memcg, true);
 			put_page(page);
-			pte_free(mm, pgtable);
-			ret = handle_userfault(vma, address, flags,
-					       VM_UFFD_MISSING);
+			pte_free(vma->vm_mm, pgtable);
+			ret = handle_userfault(fe, VM_UFFD_MISSING);
 			VM_BUG_ON(ret & VM_FAULT_FALLBACK);
 			return ret;
 		}
@@ -883,11 +879,11 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		page_add_new_anon_rmap(page, vma, haddr, true);
 		mem_cgroup_commit_charge(page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(page, vma);
-		pgtable_trans_huge_deposit(mm, pmd, pgtable);
-		set_pmd_at(mm, haddr, pmd, entry);
-		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
-		atomic_long_inc(&mm->nr_ptes);
-		spin_unlock(ptl);
+		pgtable_trans_huge_deposit(vma->vm_mm, fe->pmd, pgtable);
+		set_pmd_at(vma->vm_mm, haddr, fe->pmd, entry);
+		add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+		atomic_long_inc(&vma->vm_mm->nr_ptes);
+		spin_unlock(fe->ptl);
 		count_vm_event(THP_FAULT_ALLOC);
 	}
 
@@ -937,13 +933,12 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 	return true;
 }
 
-int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
-			       unsigned long address, pmd_t *pmd,
-			       unsigned int flags)
+int do_huge_pmd_anonymous_page(struct fault_env *fe)
 {
+	struct vm_area_struct *vma = fe->vma;
 	gfp_t gfp;
 	struct page *page;
-	unsigned long haddr = address & HPAGE_PMD_MASK;
+	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
 
 	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
 		return VM_FAULT_FALLBACK;
@@ -951,42 +946,40 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_OOM;
 	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
 		return VM_FAULT_OOM;
-	if (!(flags & FAULT_FLAG_WRITE) && !mm_forbids_zeropage(mm) &&
+	if (!(fe->flags & FAULT_FLAG_WRITE) &&
+			!mm_forbids_zeropage(vma->vm_mm) &&
 			transparent_hugepage_use_zero_page()) {
-		spinlock_t *ptl;
 		pgtable_t pgtable;
 		struct page *zero_page;
 		bool set;
 		int ret;
-		pgtable = pte_alloc_one(mm, haddr);
+		pgtable = pte_alloc_one(vma->vm_mm, haddr);
 		if (unlikely(!pgtable))
 			return VM_FAULT_OOM;
 		zero_page = get_huge_zero_page();
 		if (unlikely(!zero_page)) {
-			pte_free(mm, pgtable);
+			pte_free(vma->vm_mm, pgtable);
 			count_vm_event(THP_FAULT_FALLBACK);
 			return VM_FAULT_FALLBACK;
 		}
-		ptl = pmd_lock(mm, pmd);
+		fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
 		ret = 0;
 		set = false;
-		if (pmd_none(*pmd)) {
+		if (pmd_none(*fe->pmd)) {
 			if (userfaultfd_missing(vma)) {
-				spin_unlock(ptl);
-				ret = handle_userfault(vma, address, flags,
-						       VM_UFFD_MISSING);
+				spin_unlock(fe->ptl);
+				ret = handle_userfault(fe, VM_UFFD_MISSING);
 				VM_BUG_ON(ret & VM_FAULT_FALLBACK);
 			} else {
-				set_huge_zero_page(pgtable, mm, vma,
-						   haddr, pmd,
-						   zero_page);
-				spin_unlock(ptl);
+				set_huge_zero_page(pgtable, vma->vm_mm, vma,
+						   haddr, fe->pmd, zero_page);
+				spin_unlock(fe->ptl);
 				set = true;
 			}
 		} else
-			spin_unlock(ptl);
+			spin_unlock(fe->ptl);
 		if (!set) {
-			pte_free(mm, pgtable);
+			pte_free(vma->vm_mm, pgtable);
 			put_huge_zero_page();
 		}
 		return ret;
@@ -998,8 +991,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_FALLBACK;
 	}
 	prep_transhuge_page(page);
-	return __do_huge_pmd_anonymous_page(mm, vma, address, pmd, page, gfp,
-					    flags);
+	return __do_huge_pmd_anonymous_page(fe, page, gfp);
 }
 
 static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
@@ -1171,38 +1163,31 @@ out:
 	return ret;
 }
 
-void huge_pmd_set_accessed(struct mm_struct *mm,
-			   struct vm_area_struct *vma,
-			   unsigned long address,
-			   pmd_t *pmd, pmd_t orig_pmd,
-			   int dirty)
+void huge_pmd_set_accessed(struct fault_env *fe, pmd_t orig_pmd)
 {
-	spinlock_t *ptl;
 	pmd_t entry;
 	unsigned long haddr;
 
-	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_same(*pmd, orig_pmd)))
+	fe->ptl = pmd_lock(fe->vma->vm_mm, fe->pmd);
+	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
 		goto unlock;
 
 	entry = pmd_mkyoung(orig_pmd);
-	haddr = address & HPAGE_PMD_MASK;
-	if (pmdp_set_access_flags(vma, haddr, pmd, entry, dirty))
-		update_mmu_cache_pmd(vma, address, pmd);
+	haddr = fe->address & HPAGE_PMD_MASK;
+	if (pmdp_set_access_flags(fe->vma, haddr, fe->pmd, entry,
+				fe->flags & FAULT_FLAG_WRITE))
+		update_mmu_cache_pmd(fe->vma, fe->address, fe->pmd);
 
 unlock:
-	spin_unlock(ptl);
+	spin_unlock(fe->ptl);
 }
 
-static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
-					struct vm_area_struct *vma,
-					unsigned long address,
-					pmd_t *pmd, pmd_t orig_pmd,
-					struct page *page,
-					unsigned long haddr)
+static int do_huge_pmd_wp_page_fallback(struct fault_env *fe, pmd_t orig_pmd,
+		struct page *page)
 {
+	struct vm_area_struct *vma = fe->vma;
+	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
 	struct mem_cgroup *memcg;
-	spinlock_t *ptl;
 	pgtable_t pgtable;
 	pmd_t _pmd;
 	int ret = 0, i;
@@ -1219,11 +1204,11 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		pages[i] = alloc_page_vma_node(GFP_HIGHUSER_MOVABLE |
-					       __GFP_OTHER_NODE,
-					       vma, address, page_to_nid(page));
+					       __GFP_OTHER_NODE, vma,
+					       fe->address, page_to_nid(page));
 		if (unlikely(!pages[i] ||
-			     mem_cgroup_try_charge(pages[i], mm, GFP_KERNEL,
-						   &memcg, false))) {
+			     mem_cgroup_try_charge(pages[i], vma->vm_mm,
+				     GFP_KERNEL, &memcg, false))) {
 			if (pages[i])
 				put_page(pages[i]);
 			while (--i >= 0) {
@@ -1249,41 +1234,41 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
 
-	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_same(*pmd, orig_pmd)))
+	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
+	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
 		goto out_free_pages;
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
-	pmdp_huge_clear_flush_notify(vma, haddr, pmd);
+	pmdp_huge_clear_flush_notify(vma, haddr, fe->pmd);
 	/* leave pmd empty until pte is filled */
 
-	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
-	pmd_populate(mm, &_pmd, pgtable);
+	pgtable = pgtable_trans_huge_withdraw(vma->vm_mm, fe->pmd);
+	pmd_populate(vma->vm_mm, &_pmd, pgtable);
 
 	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
-		pte_t *pte, entry;
+		pte_t entry;
 		entry = mk_pte(pages[i], vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
-		page_add_new_anon_rmap(pages[i], vma, haddr, false);
+		page_add_new_anon_rmap(pages[i], fe->vma, haddr, false);
 		mem_cgroup_commit_charge(pages[i], memcg, false, false);
 		lru_cache_add_active_or_unevictable(pages[i], vma);
-		pte = pte_offset_map(&_pmd, haddr);
-		VM_BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, haddr, pte, entry);
-		pte_unmap(pte);
+		fe->pte = pte_offset_map(&_pmd, haddr);
+		VM_BUG_ON(!pte_none(*fe->pte));
+		set_pte_at(vma->vm_mm, haddr, fe->pte, entry);
+		pte_unmap(fe->pte);
 	}
 	kfree(pages);
 
 	smp_wmb(); /* make pte visible before pmd */
-	pmd_populate(mm, pmd, pgtable);
+	pmd_populate(vma->vm_mm, fe->pmd, pgtable);
 	page_remove_rmap(page, true);
-	spin_unlock(ptl);
+	spin_unlock(fe->ptl);
 
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
 
 	ret |= VM_FAULT_WRITE;
 	put_page(page);
@@ -1292,8 +1277,8 @@ out:
 	return ret;
 
 out_free_pages:
-	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	spin_unlock(fe->ptl);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
@@ -1304,25 +1289,23 @@ out_free_pages:
 	goto out;
 }
 
-int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
+int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd)
 {
-	spinlock_t *ptl;
-	int ret = 0;
+	struct vm_area_struct *vma = fe->vma;
 	struct page *page = NULL, *new_page;
 	struct mem_cgroup *memcg;
-	unsigned long haddr;
+	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 	gfp_t huge_gfp;			/* for allocation and charge */
+	int ret = 0;
 
-	ptl = pmd_lockptr(mm, pmd);
+	fe->ptl = pmd_lockptr(vma->vm_mm, fe->pmd);
 	VM_BUG_ON_VMA(!vma->anon_vma, vma);
-	haddr = address & HPAGE_PMD_MASK;
 	if (is_huge_zero_pmd(orig_pmd))
 		goto alloc;
-	spin_lock(ptl);
-	if (unlikely(!pmd_same(*pmd, orig_pmd)))
+	spin_lock(fe->ptl);
+	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
 		goto out_unlock;
 
 	page = pmd_page(orig_pmd);
@@ -1341,13 +1324,13 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		if (pmdp_set_access_flags(vma, haddr, pmd, entry,  1))
-			update_mmu_cache_pmd(vma, address, pmd);
+		if (pmdp_set_access_flags(vma, haddr, fe->pmd, entry,  1))
+			update_mmu_cache_pmd(vma, fe->address, fe->pmd);
 		ret |= VM_FAULT_WRITE;
 		goto out_unlock;
 	}
 	get_page(page);
-	spin_unlock(ptl);
+	spin_unlock(fe->ptl);
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow()) {
@@ -1360,13 +1343,12 @@ alloc:
 		prep_transhuge_page(new_page);
 	} else {
 		if (!page) {
-			split_huge_pmd(vma, pmd, address);
+			split_huge_pmd(vma, fe->pmd, fe->address);
 			ret |= VM_FAULT_FALLBACK;
 		} else {
-			ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
-					pmd, orig_pmd, page, haddr);
+			ret = do_huge_pmd_wp_page_fallback(fe, orig_pmd, page);
 			if (ret & VM_FAULT_OOM) {
-				split_huge_pmd(vma, pmd, address);
+				split_huge_pmd(vma, fe->pmd, fe->address);
 				ret |= VM_FAULT_FALLBACK;
 			}
 			put_page(page);
@@ -1375,14 +1357,12 @@ alloc:
 		goto out;
 	}
 
-	if (unlikely(mem_cgroup_try_charge(new_page, mm, huge_gfp, &memcg,
-					   true))) {
+	if (unlikely(mem_cgroup_try_charge(new_page, vma->vm_mm,
+					huge_gfp, &memcg, true))) {
 		put_page(new_page);
-		if (page) {
-			split_huge_pmd(vma, pmd, address);
+		split_huge_pmd(vma, fe->pmd, fe->address);
+		if (page)
 			put_page(page);
-		} else
-			split_huge_pmd(vma, pmd, address);
 		ret |= VM_FAULT_FALLBACK;
 		count_vm_event(THP_FAULT_FALLBACK);
 		goto out;
@@ -1398,13 +1378,13 @@ alloc:
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
 
-	spin_lock(ptl);
+	spin_lock(fe->ptl);
 	if (page)
 		put_page(page);
-	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
-		spin_unlock(ptl);
+	if (unlikely(!pmd_same(*fe->pmd, orig_pmd))) {
+		spin_unlock(fe->ptl);
 		mem_cgroup_cancel_charge(new_page, memcg, true);
 		put_page(new_page);
 		goto out_mn;
@@ -1412,14 +1392,14 @@ alloc:
 		pmd_t entry;
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		pmdp_huge_clear_flush_notify(vma, haddr, pmd);
+		pmdp_huge_clear_flush_notify(vma, haddr, fe->pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr, true);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(new_page, vma);
-		set_pmd_at(mm, haddr, pmd, entry);
-		update_mmu_cache_pmd(vma, address, pmd);
+		set_pmd_at(vma->vm_mm, haddr, fe->pmd, entry);
+		update_mmu_cache_pmd(vma, fe->address, fe->pmd);
 		if (!page) {
-			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
+			add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 			put_huge_zero_page();
 		} else {
 			VM_BUG_ON_PAGE(!PageHead(page), page);
@@ -1428,13 +1408,13 @@ alloc:
 		}
 		ret |= VM_FAULT_WRITE;
 	}
-	spin_unlock(ptl);
+	spin_unlock(fe->ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
 out:
 	return ret;
 out_unlock:
-	spin_unlock(ptl);
+	spin_unlock(fe->ptl);
 	return ret;
 }
 
@@ -1494,13 +1474,12 @@ out:
 }
 
 /* NUMA hinting page fault entry point for trans huge pmds */
-int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
-				unsigned long addr, pmd_t pmd, pmd_t *pmdp)
+int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t pmd)
 {
-	spinlock_t *ptl;
+	struct vm_area_struct *vma = fe->vma;
 	struct anon_vma *anon_vma = NULL;
 	struct page *page;
-	unsigned long haddr = addr & HPAGE_PMD_MASK;
+	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
 	int page_nid = -1, this_nid = numa_node_id();
 	int target_nid, last_cpupid = -1;
 	bool page_locked;
@@ -1511,8 +1490,8 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	/* A PROT_NONE fault should not end up here */
 	BUG_ON(!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)));
 
-	ptl = pmd_lock(mm, pmdp);
-	if (unlikely(!pmd_same(pmd, *pmdp)))
+	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
+	if (unlikely(!pmd_same(pmd, *fe->pmd)))
 		goto out_unlock;
 
 	/*
@@ -1520,9 +1499,9 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * without disrupting NUMA hinting information. Do not relock and
 	 * check_same as the page may no longer be mapped.
 	 */
-	if (unlikely(pmd_trans_migrating(*pmdp))) {
-		page = pmd_page(*pmdp);
-		spin_unlock(ptl);
+	if (unlikely(pmd_trans_migrating(*fe->pmd))) {
+		page = pmd_page(*fe->pmd);
+		spin_unlock(fe->ptl);
 		wait_on_page_locked(page);
 		goto out;
 	}
@@ -1555,7 +1534,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	/* Migration could have started since the pmd_trans_migrating check */
 	if (!page_locked) {
-		spin_unlock(ptl);
+		spin_unlock(fe->ptl);
 		wait_on_page_locked(page);
 		page_nid = -1;
 		goto out;
@@ -1566,12 +1545,12 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * to serialises splits
 	 */
 	get_page(page);
-	spin_unlock(ptl);
+	spin_unlock(fe->ptl);
 	anon_vma = page_lock_anon_vma_read(page);
 
 	/* Confirm the PMD did not change while page_table_lock was released */
-	spin_lock(ptl);
-	if (unlikely(!pmd_same(pmd, *pmdp))) {
+	spin_lock(fe->ptl);
+	if (unlikely(!pmd_same(pmd, *fe->pmd))) {
 		unlock_page(page);
 		put_page(page);
 		page_nid = -1;
@@ -1589,9 +1568,9 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * Migrate the THP to the requested node, returns with page unlocked
 	 * and access rights restored.
 	 */
-	spin_unlock(ptl);
-	migrated = migrate_misplaced_transhuge_page(mm, vma,
-				pmdp, pmd, addr, page, target_nid);
+	spin_unlock(fe->ptl);
+	migrated = migrate_misplaced_transhuge_page(vma->vm_mm, vma,
+				fe->pmd, pmd, fe->address, page, target_nid);
 	if (migrated) {
 		flags |= TNF_MIGRATED;
 		page_nid = target_nid;
@@ -1606,18 +1585,18 @@ clear_pmdnuma:
 	pmd = pmd_mkyoung(pmd);
 	if (was_writable)
 		pmd = pmd_mkwrite(pmd);
-	set_pmd_at(mm, haddr, pmdp, pmd);
-	update_mmu_cache_pmd(vma, addr, pmdp);
+	set_pmd_at(vma->vm_mm, haddr, fe->pmd, pmd);
+	update_mmu_cache_pmd(vma, fe->address, fe->pmd);
 	unlock_page(page);
 out_unlock:
-	spin_unlock(ptl);
+	spin_unlock(fe->ptl);
 
 out:
 	if (anon_vma)
 		page_unlock_anon_vma_read(anon_vma);
 
 	if (page_nid != -1)
-		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR, flags);
+		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR, fe->flags);
 
 	return 0;
 }
@@ -2396,29 +2375,32 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmd)
 {
-	unsigned long _address;
-	pte_t *pte, pteval;
+	pte_t pteval;
 	int swapped_in = 0, ret = 0;
-
-	pte = pte_offset_map(pmd, address);
-	for (_address = address; _address < address + HPAGE_PMD_NR*PAGE_SIZE;
-	     pte++, _address += PAGE_SIZE) {
-		pteval = *pte;
+	struct fault_env fe = {
+		.vma = vma,
+		.address = address,
+		.flags = FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
+		.pmd = pmd,
+	};
+
+	fe.pte = pte_offset_map(pmd, address);
+	for (; fe.address < address + HPAGE_PMD_NR*PAGE_SIZE;
+			fe.pte++, fe.address += PAGE_SIZE) {
+		pteval = *fe.pte;
 		if (!is_swap_pte(pteval))
 			continue;
 		swapped_in++;
-		ret = do_swap_page(mm, vma, _address, pte, pmd,
-				   FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
-				   pteval);
+		ret = do_swap_page(&fe, pteval);
 		if (ret & VM_FAULT_ERROR) {
 			trace_mm_collapse_huge_page_swapin(mm, swapped_in, 0);
 			return;
 		}
 		/* pte is unmapped now, we need to map it */
-		pte = pte_offset_map(pmd, _address);
+		fe.pte = pte_offset_map(pmd, fe.address);
 	}
-	pte--;
-	pte_unmap(pte);
+	fe.pte--;
+	pte_unmap(fe.pte);
 	trace_mm_collapse_huge_page_swapin(mm, swapped_in, 1);
 }
 
diff --git a/mm/internal.h b/mm/internal.h
index 6e9222a41c4a..1458bd904daf 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -35,9 +35,7 @@
 /* Do not use these with a slab allocator */
 #define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
 
-extern int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, pte_t *page_table, pmd_t *pmd,
-			unsigned int flags, pte_t orig_pte);
+int do_swap_page(struct fault_env *fe, pte_t orig_pte);
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
diff --git a/mm/memory.c b/mm/memory.c
index 0002898341a3..6c37f84212ee 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2013,13 +2013,11 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
  * case, all we need to do here is to mark the page as writable and update
  * any related book-keeping.
  */
-static inline int wp_page_reuse(struct mm_struct *mm,
-			struct vm_area_struct *vma, unsigned long address,
-			pte_t *page_table, spinlock_t *ptl, pte_t orig_pte,
-			struct page *page, int page_mkwrite,
-			int dirty_shared)
-	__releases(ptl)
+static inline int wp_page_reuse(struct fault_env *fe, pte_t orig_pte,
+			struct page *page, int page_mkwrite, int dirty_shared)
+	__releases(fe->ptl)
 {
+	struct vm_area_struct *vma = fe->vma;
 	pte_t entry;
 	/*
 	 * Clear the pages cpupid information as the existing
@@ -2029,12 +2027,12 @@ static inline int wp_page_reuse(struct mm_struct *mm,
 	if (page)
 		page_cpupid_xchg_last(page, (1 << LAST_CPUPID_SHIFT) - 1);
 
-	flush_cache_page(vma, address, pte_pfn(orig_pte));
+	flush_cache_page(vma, fe->address, pte_pfn(orig_pte));
 	entry = pte_mkyoung(orig_pte);
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-	if (ptep_set_access_flags(vma, address, page_table, entry, 1))
-		update_mmu_cache(vma, address, page_table);
-	pte_unmap_unlock(page_table, ptl);
+	if (ptep_set_access_flags(vma, fe->address, fe->pte, entry, 1))
+		update_mmu_cache(vma, fe->address, fe->pte);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 
 	if (dirty_shared) {
 		struct address_space *mapping;
@@ -2080,30 +2078,31 @@ static inline int wp_page_reuse(struct mm_struct *mm,
  *   held to the old page, as well as updating the rmap.
  * - In any case, unlock the PTL and drop the reference we took to the old page.
  */
-static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, pte_t *page_table, pmd_t *pmd,
-			pte_t orig_pte, struct page *old_page)
+static int wp_page_copy(struct fault_env *fe, pte_t orig_pte,
+		struct page *old_page)
 {
+	struct vm_area_struct *vma = fe->vma;
+	struct mm_struct *mm = vma->vm_mm;
 	struct page *new_page = NULL;
-	spinlock_t *ptl = NULL;
 	pte_t entry;
 	int page_copied = 0;
-	const unsigned long mmun_start = address & PAGE_MASK;	/* For mmu_notifiers */
-	const unsigned long mmun_end = mmun_start + PAGE_SIZE;	/* For mmu_notifiers */
+	const unsigned long mmun_start = fe->address & PAGE_MASK;
+	const unsigned long mmun_end = mmun_start + PAGE_SIZE;
 	struct mem_cgroup *memcg;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
 
 	if (is_zero_pfn(pte_pfn(orig_pte))) {
-		new_page = alloc_zeroed_user_highpage_movable(vma, address);
+		new_page = alloc_zeroed_user_highpage_movable(vma, fe->address);
 		if (!new_page)
 			goto oom;
 	} else {
-		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
+				fe->address);
 		if (!new_page)
 			goto oom;
-		cow_user_page(new_page, old_page, address, vma);
+		cow_user_page(new_page, old_page, fe->address, vma);
 	}
 
 	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg, false))
@@ -2116,8 +2115,8 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (likely(pte_same(*page_table, orig_pte))) {
+	fe->pte = pte_offset_map_lock(mm, fe->pmd, fe->address, &fe->ptl);
+	if (likely(pte_same(*fe->pte, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
 				dec_mm_counter_fast(mm,
@@ -2127,7 +2126,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		} else {
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
 		}
-		flush_cache_page(vma, address, pte_pfn(orig_pte));
+		flush_cache_page(vma, fe->address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		/*
@@ -2136,8 +2135,8 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush_notify(vma, address, page_table);
-		page_add_new_anon_rmap(new_page, vma, address, false);
+		ptep_clear_flush_notify(vma, fe->address, fe->pte);
+		page_add_new_anon_rmap(new_page, vma, fe->address, false);
 		mem_cgroup_commit_charge(new_page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		/*
@@ -2145,8 +2144,8 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * mmu page tables (such as kvm shadow page tables), we want the
 		 * new page to be mapped directly into the secondary page table.
 		 */
-		set_pte_at_notify(mm, address, page_table, entry);
-		update_mmu_cache(vma, address, page_table);
+		set_pte_at_notify(mm, fe->address, fe->pte, entry);
+		update_mmu_cache(vma, fe->address, fe->pte);
 		if (old_page) {
 			/*
 			 * Only after switching the pte to the new page may
@@ -2183,7 +2182,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (new_page)
 		put_page(new_page);
 
-	pte_unmap_unlock(page_table, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	if (old_page) {
 		/*
@@ -2211,44 +2210,43 @@ oom:
  * Handle write page faults for VM_MIXEDMAP or VM_PFNMAP for a VM_SHARED
  * mapping
  */
-static int wp_pfn_shared(struct mm_struct *mm,
-			struct vm_area_struct *vma, unsigned long address,
-			pte_t *page_table, spinlock_t *ptl, pte_t orig_pte,
-			pmd_t *pmd)
+static int wp_pfn_shared(struct fault_env *fe,  pte_t orig_pte)
 {
+	struct vm_area_struct *vma = fe->vma;
+
 	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
 		struct vm_fault vmf = {
 			.page = NULL,
-			.pgoff = linear_page_index(vma, address),
-			.virtual_address = (void __user *)(address & PAGE_MASK),
+			.pgoff = linear_page_index(vma, fe->address),
+			.virtual_address =
+				(void __user *)(fe->address & PAGE_MASK),
 			.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
 		};
 		int ret;
 
-		pte_unmap_unlock(page_table, ptl);
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		ret = vma->vm_ops->pfn_mkwrite(vma, &vmf);
 		if (ret & VM_FAULT_ERROR)
 			return ret;
-		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+		fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
+				&fe->ptl);
 		/*
 		 * We might have raced with another page fault while we
 		 * released the pte_offset_map_lock.
 		 */
-		if (!pte_same(*page_table, orig_pte)) {
-			pte_unmap_unlock(page_table, ptl);
+		if (!pte_same(*fe->pte, orig_pte)) {
+			pte_unmap_unlock(fe->pte, fe->ptl);
 			return 0;
 		}
 	}
-	return wp_page_reuse(mm, vma, address, page_table, ptl, orig_pte,
-			     NULL, 0, 0);
+	return wp_page_reuse(fe, orig_pte, NULL, 0, 0);
 }
 
-static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
-			  unsigned long address, pte_t *page_table,
-			  pmd_t *pmd, spinlock_t *ptl, pte_t orig_pte,
-			  struct page *old_page)
-	__releases(ptl)
+static int wp_page_shared(struct fault_env *fe, pte_t orig_pte,
+		struct page *old_page)
+	__releases(fe->ptl)
 {
+	struct vm_area_struct *vma = fe->vma;
 	int page_mkwrite = 0;
 
 	get_page(old_page);
@@ -2256,8 +2254,8 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
 		int tmp;
 
-		pte_unmap_unlock(page_table, ptl);
-		tmp = do_page_mkwrite(vma, old_page, address);
+		pte_unmap_unlock(fe->pte, fe->ptl);
+		tmp = do_page_mkwrite(vma, old_page, fe->address);
 		if (unlikely(!tmp || (tmp &
 				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
 			put_page(old_page);
@@ -2269,19 +2267,18 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * they did, we just return, as we can count on the
 		 * MMU to tell us if they didn't also make it writable.
 		 */
-		page_table = pte_offset_map_lock(mm, pmd, address,
-						 &ptl);
-		if (!pte_same(*page_table, orig_pte)) {
+		fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
+						 &fe->ptl);
+		if (!pte_same(*fe->pte, orig_pte)) {
 			unlock_page(old_page);
-			pte_unmap_unlock(page_table, ptl);
+			pte_unmap_unlock(fe->pte, fe->ptl);
 			put_page(old_page);
 			return 0;
 		}
 		page_mkwrite = 1;
 	}
 
-	return wp_page_reuse(mm, vma, address, page_table, ptl,
-			     orig_pte, old_page, page_mkwrite, 1);
+	return wp_page_reuse(fe, orig_pte, old_page, page_mkwrite, 1);
 }
 
 /*
@@ -2302,14 +2299,13 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
  * but allow concurrent faults), with pte both mapped and locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		spinlock_t *ptl, pte_t orig_pte)
-	__releases(ptl)
+static int do_wp_page(struct fault_env *fe, pte_t orig_pte)
+	__releases(fe->ptl)
 {
+	struct vm_area_struct *vma = fe->vma;
 	struct page *old_page;
 
-	old_page = vm_normal_page(vma, address, orig_pte);
+	old_page = vm_normal_page(vma, fe->address, orig_pte);
 	if (!old_page) {
 		/*
 		 * VM_MIXEDMAP !pfn_valid() case, or VM_SOFTDIRTY clear on a
@@ -2320,12 +2316,10 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 */
 		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 				     (VM_WRITE|VM_SHARED))
-			return wp_pfn_shared(mm, vma, address, page_table, ptl,
-					     orig_pte, pmd);
+			return wp_pfn_shared(fe, orig_pte);
 
-		pte_unmap_unlock(page_table, ptl);
-		return wp_page_copy(mm, vma, address, page_table, pmd,
-				    orig_pte, old_page);
+		pte_unmap_unlock(fe->pte, fe->ptl);
+		return wp_page_copy(fe, orig_pte, old_page);
 	}
 
 	/*
@@ -2335,13 +2329,13 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (PageAnon(old_page) && !PageKsm(old_page)) {
 		if (!trylock_page(old_page)) {
 			get_page(old_page);
-			pte_unmap_unlock(page_table, ptl);
+			pte_unmap_unlock(fe->pte, fe->ptl);
 			lock_page(old_page);
-			page_table = pte_offset_map_lock(mm, pmd, address,
-							 &ptl);
-			if (!pte_same(*page_table, orig_pte)) {
+			fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd,
+					fe->address, &fe->ptl);
+			if (!pte_same(*fe->pte, orig_pte)) {
 				unlock_page(old_page);
-				pte_unmap_unlock(page_table, ptl);
+				pte_unmap_unlock(fe->pte, fe->ptl);
 				put_page(old_page);
 				return 0;
 			}
@@ -2353,16 +2347,14 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 * the rmap code will not search our parent or siblings.
 			 * Protected against the rmap code by the page lock.
 			 */
-			page_move_anon_rmap(old_page, vma, address);
+			page_move_anon_rmap(old_page, vma, fe->address);
 			unlock_page(old_page);
-			return wp_page_reuse(mm, vma, address, page_table, ptl,
-					     orig_pte, old_page, 0, 0);
+			return wp_page_reuse(fe, orig_pte, old_page, 0, 0);
 		}
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
-		return wp_page_shared(mm, vma, address, page_table, pmd,
-				      ptl, orig_pte, old_page);
+		return wp_page_shared(fe, orig_pte, old_page);
 	}
 
 	/*
@@ -2370,9 +2362,8 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	get_page(old_page);
 
-	pte_unmap_unlock(page_table, ptl);
-	return wp_page_copy(mm, vma, address, page_table, pmd,
-			    orig_pte, old_page);
+	pte_unmap_unlock(fe->pte, fe->ptl);
+	return wp_page_copy(fe, orig_pte, old_page);
 }
 
 static void unmap_mapping_range_vma(struct vm_area_struct *vma,
@@ -2462,11 +2453,9 @@ EXPORT_SYMBOL(unmap_mapping_range);
  * We return with the mmap_sem locked or unlocked in the same cases
  * as does filemap_fault().
  */
-int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 {
-	spinlock_t *ptl;
+	struct vm_area_struct *vma = fe->vma;
 	struct page *page, *swapcache;
 	struct mem_cgroup *memcg;
 	swp_entry_t entry;
@@ -2475,17 +2464,17 @@ int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int exclusive = 0;
 	int ret = 0;
 
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
+	if (!pte_unmap_same(vma->vm_mm, fe->pmd, fe->pte, orig_pte))
 		goto out;
 
 	entry = pte_to_swp_entry(orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
-			migration_entry_wait(mm, pmd, address);
+			migration_entry_wait(vma->vm_mm, fe->pmd, fe->address);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
 		} else {
-			print_bad_pte(vma, address, orig_pte, NULL);
+			print_bad_pte(vma, fe->address, orig_pte, NULL);
 			ret = VM_FAULT_SIGBUS;
 		}
 		goto out;
@@ -2494,14 +2483,15 @@ int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	page = lookup_swap_cache(entry);
 	if (!page) {
 		page = swapin_readahead(entry,
-					GFP_HIGHUSER_MOVABLE, vma, address);
+					GFP_HIGHUSER_MOVABLE, vma, fe->address);
 		if (!page) {
 			/*
 			 * Back out if somebody else faulted in this pte
 			 * while we released the pte lock.
 			 */
-			page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-			if (likely(pte_same(*page_table, orig_pte)))
+			fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd,
+					fe->address, &fe->ptl);
+			if (likely(pte_same(*fe->pte, orig_pte)))
 				ret = VM_FAULT_OOM;
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 			goto unlock;
@@ -2510,7 +2500,7 @@ int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		/* Had to read the page from swap area: Major fault */
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
-		mem_cgroup_count_vm_event(mm, PGMAJFAULT);
+		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 	} else if (PageHWPoison(page)) {
 		/*
 		 * hwpoisoned dirty swapcache pages are kept for killing
@@ -2523,7 +2513,7 @@ int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	swapcache = page;
-	locked = lock_page_or_retry(page, mm, flags);
+	locked = lock_page_or_retry(page, vma->vm_mm, fe->flags);
 
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 	if (!locked) {
@@ -2540,14 +2530,15 @@ int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!PageSwapCache(page) || page_private(page) != entry.val))
 		goto out_page;
 
-	page = ksm_might_need_to_copy(page, vma, address);
+	page = ksm_might_need_to_copy(page, vma, fe->address);
 	if (unlikely(!page)) {
 		ret = VM_FAULT_OOM;
 		page = swapcache;
 		goto out_page;
 	}
 
-	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg, false)) {
+	if (mem_cgroup_try_charge(page, vma->vm_mm, GFP_KERNEL,
+				&memcg, false)) {
 		ret = VM_FAULT_OOM;
 		goto out_page;
 	}
@@ -2555,8 +2546,9 @@ int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	/*
 	 * Back out if somebody else already faulted in this pte.
 	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*page_table, orig_pte)))
+	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
+			&fe->ptl);
+	if (unlikely(!pte_same(*fe->pte, orig_pte)))
 		goto out_nomap;
 
 	if (unlikely(!PageUptodate(page))) {
@@ -2574,24 +2566,24 @@ int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * must be called after the swap_free(), or it will never succeed.
 	 */
 
-	inc_mm_counter_fast(mm, MM_ANONPAGES);
-	dec_mm_counter_fast(mm, MM_SWAPENTS);
+	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
+	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
 	pte = mk_pte(page, vma->vm_page_prot);
-	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
+	if ((fe->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
-		flags &= ~FAULT_FLAG_WRITE;
+		fe->flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = RMAP_EXCLUSIVE;
 	}
 	flush_icache_page(vma, page);
 	if (pte_swp_soft_dirty(orig_pte))
 		pte = pte_mksoft_dirty(pte);
-	set_pte_at(mm, address, page_table, pte);
+	set_pte_at(vma->vm_mm, fe->address, fe->pte, pte);
 	if (page == swapcache) {
-		do_page_add_anon_rmap(page, vma, address, exclusive);
+		do_page_add_anon_rmap(page, vma, fe->address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true, false);
 	} else { /* ksm created a completely new copy */
-		page_add_new_anon_rmap(page, vma, address, false);
+		page_add_new_anon_rmap(page, vma, fe->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	}
@@ -2614,22 +2606,22 @@ int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		put_page(swapcache);
 	}
 
-	if (flags & FAULT_FLAG_WRITE) {
-		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
+	if (fe->flags & FAULT_FLAG_WRITE) {
+		ret |= do_wp_page(fe, pte);
 		if (ret & VM_FAULT_ERROR)
 			ret &= VM_FAULT_ERROR;
 		goto out;
 	}
 
 	/* No need to invalidate - it was non-present before */
-	update_mmu_cache(vma, address, page_table);
+	update_mmu_cache(vma, fe->address, fe->pte);
 unlock:
-	pte_unmap_unlock(page_table, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 out:
 	return ret;
 out_nomap:
 	mem_cgroup_cancel_charge(page, memcg, false);
-	pte_unmap_unlock(page_table, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 out_page:
 	unlock_page(page);
 out_release:
@@ -2680,37 +2672,36 @@ static inline int check_stack_guard_page(struct vm_area_struct *vma, unsigned lo
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags)
+static int do_anonymous_page(struct fault_env *fe)
 {
+	struct vm_area_struct *vma = fe->vma;
 	struct mem_cgroup *memcg;
 	struct page *page;
-	spinlock_t *ptl;
 	pte_t entry;
 
-	pte_unmap(page_table);
+	pte_unmap(fe->pte);
 
 	/* File mapping without ->vm_ops ? */
 	if (vma->vm_flags & VM_SHARED)
 		return VM_FAULT_SIGBUS;
 
 	/* Check if we need to add a guard page to the stack */
-	if (check_stack_guard_page(vma, address) < 0)
+	if (check_stack_guard_page(vma, fe->address) < 0)
 		return VM_FAULT_SIGSEGV;
 
 	/* Use the zero-page for reads */
-	if (!(flags & FAULT_FLAG_WRITE) && !mm_forbids_zeropage(mm)) {
-		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
+	if (!(fe->flags & FAULT_FLAG_WRITE) &&
+			!mm_forbids_zeropage(vma->vm_mm)) {
+		entry = pte_mkspecial(pfn_pte(my_zero_pfn(fe->address),
 						vma->vm_page_prot));
-		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-		if (!pte_none(*page_table))
+		fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
+				&fe->ptl);
+		if (!pte_none(*fe->pte))
 			goto unlock;
 		/* Deliver the page fault to userland, check inside PT lock */
 		if (userfaultfd_missing(vma)) {
-			pte_unmap_unlock(page_table, ptl);
-			return handle_userfault(vma, address, flags,
-						VM_UFFD_MISSING);
+			pte_unmap_unlock(fe->pte, fe->ptl);
+			return handle_userfault(fe, VM_UFFD_MISSING);
 		}
 		goto setpte;
 	}
@@ -2718,11 +2709,11 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	/* Allocate our own private page. */
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
-	page = alloc_zeroed_user_highpage_movable(vma, address);
+	page = alloc_zeroed_user_highpage_movable(vma, fe->address);
 	if (!page)
 		goto oom;
 
-	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg, false))
+	if (mem_cgroup_try_charge(page, vma->vm_mm, GFP_KERNEL, &memcg, false))
 		goto oom_free_page;
 
 	/*
@@ -2736,30 +2727,30 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (!pte_none(*page_table))
+	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
+			&fe->ptl);
+	if (!pte_none(*fe->pte))
 		goto release;
 
 	/* Deliver the page fault to userland, check inside PT lock */
 	if (userfaultfd_missing(vma)) {
-		pte_unmap_unlock(page_table, ptl);
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		mem_cgroup_cancel_charge(page, memcg, false);
 		put_page(page);
-		return handle_userfault(vma, address, flags,
-					VM_UFFD_MISSING);
+		return handle_userfault(fe, VM_UFFD_MISSING);
 	}
 
-	inc_mm_counter_fast(mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(page, vma, address, false);
+	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
+	page_add_new_anon_rmap(page, vma, fe->address, false);
 	mem_cgroup_commit_charge(page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(page, vma);
 setpte:
-	set_pte_at(mm, address, page_table, entry);
+	set_pte_at(vma->vm_mm, fe->address, fe->pte, entry);
 
 	/* No need to invalidate - it was non-present before */
-	update_mmu_cache(vma, address, page_table);
+	update_mmu_cache(vma, fe->address, fe->pte);
 unlock:
-	pte_unmap_unlock(page_table, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 	return 0;
 release:
 	mem_cgroup_cancel_charge(page, memcg, false);
@@ -2776,16 +2767,16 @@ oom:
  * released depending on flags and vma->vm_ops->fault() return value.
  * See filemap_fault() and __lock_page_retry().
  */
-static int __do_fault(struct vm_area_struct *vma, unsigned long address,
-			pgoff_t pgoff, unsigned int flags,
-			struct page *cow_page, struct page **page)
+static int __do_fault(struct fault_env *fe, pgoff_t pgoff,
+		struct page *cow_page, struct page **page)
 {
+	struct vm_area_struct *vma = fe->vma;
 	struct vm_fault vmf;
 	int ret;
 
-	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
+	vmf.virtual_address = (void __user *)(fe->address & PAGE_MASK);
 	vmf.pgoff = pgoff;
-	vmf.flags = flags;
+	vmf.flags = fe->flags;
 	vmf.page = NULL;
 	vmf.gfp_mask = __get_fault_gfp_mask(vma);
 	vmf.cow_page = cow_page;
@@ -2816,38 +2807,36 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 /**
  * do_set_pte - setup new PTE entry for given page and add reverse page mapping.
  *
- * @vma: virtual memory area
- * @address: user virtual address
+ * @fe: fault environment
  * @page: page to map
- * @pte: pointer to target page table entry
- * @write: true, if new entry is writable
- * @anon: true, if it's anonymous page
  *
- * Caller must hold page table lock relevant for @pte.
+ * Caller must hold page table lock relevant for @fe->pte.
  *
  * Target users are page handler itself and implementations of
  * vm_ops->map_pages.
  */
-void do_set_pte(struct vm_area_struct *vma, unsigned long address,
-		struct page *page, pte_t *pte, bool write, bool anon)
+void do_set_pte(struct fault_env *fe, struct page *page)
 {
+	struct vm_area_struct *vma = fe->vma;
+	bool write = fe->flags & FAULT_FLAG_WRITE;
 	pte_t entry;
 
 	flush_icache_page(vma, page);
 	entry = mk_pte(page, vma->vm_page_prot);
 	if (write)
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-	if (anon) {
+	/* copy-on-write page */
+	if (write && !(vma->vm_flags & VM_SHARED)) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-		page_add_new_anon_rmap(page, vma, address, false);
+		page_add_new_anon_rmap(page, vma, fe->address, false);
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
 		page_add_file_rmap(page);
 	}
-	set_pte_at(vma->vm_mm, address, pte, entry);
+	set_pte_at(vma->vm_mm, fe->address, fe->pte, entry);
 
 	/* no need to invalidate: a not-present page won't be cached */
-	update_mmu_cache(vma, address, pte);
+	update_mmu_cache(vma, fe->address, fe->pte);
 }
 
 static unsigned long fault_around_bytes __read_mostly =
@@ -2914,57 +2903,53 @@ late_initcall(fault_around_debugfs);
  * fault_around_pages() value (and therefore to page order).  This way it's
  * easier to guarantee that we don't cross page table boundaries.
  */
-static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
-		pte_t *pte, pgoff_t pgoff, unsigned int flags)
+static void do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
 {
-	unsigned long start_addr, nr_pages, mask;
-	pgoff_t max_pgoff;
-	struct vm_fault vmf;
+	unsigned long address = fe->address, start_addr, nr_pages, mask;
+	pte_t *pte = fe->pte;
+	pgoff_t end_pgoff;
 	int off;
 
 	nr_pages = READ_ONCE(fault_around_bytes) >> PAGE_SHIFT;
 	mask = ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
 
-	start_addr = max(address & mask, vma->vm_start);
-	off = ((address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
-	pte -= off;
-	pgoff -= off;
+	start_addr = max(fe->address & mask, fe->vma->vm_start);
+	off = ((fe->address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
+	fe->pte -= off;
+	start_pgoff -= off;
 
 	/*
-	 *  max_pgoff is either end of page table or end of vma
-	 *  or fault_around_pages() from pgoff, depending what is nearest.
+	 *  end_pgoff is either end of page table or end of vma
+	 *  or fault_around_pages() from start_pgoff, depending what is nearest.
 	 */
-	max_pgoff = pgoff - ((start_addr >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
+	end_pgoff = start_pgoff -
+		((start_addr >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
 		PTRS_PER_PTE - 1;
-	max_pgoff = min3(max_pgoff, vma_pages(vma) + vma->vm_pgoff - 1,
-			pgoff + nr_pages - 1);
+	end_pgoff = min3(end_pgoff, vma_pages(fe->vma) + fe->vma->vm_pgoff - 1,
+			start_pgoff + nr_pages - 1);
 
 	/* Check if it makes any sense to call ->map_pages */
-	while (!pte_none(*pte)) {
-		if (++pgoff > max_pgoff)
-			return;
-		start_addr += PAGE_SIZE;
-		if (start_addr >= vma->vm_end)
-			return;
-		pte++;
+	fe->address = start_addr;
+	while (!pte_none(*fe->pte)) {
+		if (++start_pgoff > end_pgoff)
+			goto out;
+		fe->address += PAGE_SIZE;
+		if (fe->address >= fe->vma->vm_end)
+			goto out;
+		fe->pte++;
 	}
 
-	vmf.virtual_address = (void __user *) start_addr;
-	vmf.pte = pte;
-	vmf.pgoff = pgoff;
-	vmf.max_pgoff = max_pgoff;
-	vmf.flags = flags;
-	vmf.gfp_mask = __get_fault_gfp_mask(vma);
-	vma->vm_ops->map_pages(vma, &vmf);
+	fe->vma->vm_ops->map_pages(fe, start_pgoff, end_pgoff);
+out:
+	/* restore fault_env */
+	fe->pte = pte;
+	fe->address = address;
 }
 
-static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+static int do_read_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
 {
+	struct vm_area_struct *vma = fe->vma;
 	struct page *fault_page;
-	spinlock_t *ptl;
-	pte_t *pte;
 	int ret = 0;
 
 	/*
@@ -2973,64 +2958,64 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * something).
 	 */
 	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
-		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-		do_fault_around(vma, address, pte, pgoff, flags);
-		if (!pte_same(*pte, orig_pte))
+		fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
+				&fe->ptl);
+		do_fault_around(fe, pgoff);
+		if (!pte_same(*fe->pte, orig_pte))
 			goto unlock_out;
-		pte_unmap_unlock(pte, ptl);
+		pte_unmap_unlock(fe->pte, fe->ptl);
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
+	ret = __do_fault(fe, pgoff, NULL, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
-	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, orig_pte))) {
-		pte_unmap_unlock(pte, ptl);
+	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address, &fe->ptl);
+	if (unlikely(!pte_same(*fe->pte, orig_pte))) {
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		unlock_page(fault_page);
 		put_page(fault_page);
 		return ret;
 	}
-	do_set_pte(vma, address, fault_page, pte, false, false);
+	do_set_pte(fe, fault_page);
 	unlock_page(fault_page);
 unlock_out:
-	pte_unmap_unlock(pte, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 	return ret;
 }
 
-static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
 {
+	struct vm_area_struct *vma = fe->vma;
 	struct page *fault_page, *new_page;
 	struct mem_cgroup *memcg;
-	spinlock_t *ptl;
-	pte_t *pte;
 	int ret;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
 
-	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, fe->address);
 	if (!new_page)
 		return VM_FAULT_OOM;
 
-	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg, false)) {
+	if (mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL,
+				&memcg, false)) {
 		put_page(new_page);
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, new_page, &fault_page);
+	ret = __do_fault(fe, pgoff, new_page, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
 	if (fault_page)
-		copy_user_highpage(new_page, fault_page, address, vma);
+		copy_user_highpage(new_page, fault_page, fe->address, vma);
 	__SetPageUptodate(new_page);
 
-	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, orig_pte))) {
-		pte_unmap_unlock(pte, ptl);
+	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
+			&fe->ptl);
+	if (unlikely(!pte_same(*fe->pte, orig_pte))) {
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		if (fault_page) {
 			unlock_page(fault_page);
 			put_page(fault_page);
@@ -3043,10 +3028,10 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		goto uncharge_out;
 	}
-	do_set_pte(vma, address, new_page, pte, true, true);
+	do_set_pte(fe, new_page);
 	mem_cgroup_commit_charge(new_page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(new_page, vma);
-	pte_unmap_unlock(pte, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 	if (fault_page) {
 		unlock_page(fault_page);
 		put_page(fault_page);
@@ -3064,18 +3049,15 @@ uncharge_out:
 	return ret;
 }
 
-static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff, pte_t orig_pte)
 {
+	struct vm_area_struct *vma = fe->vma;
 	struct page *fault_page;
 	struct address_space *mapping;
-	spinlock_t *ptl;
-	pte_t *pte;
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(vma, address, pgoff, flags, NULL, &fault_page);
+	ret = __do_fault(fe, pgoff, NULL, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -3085,7 +3067,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	if (vma->vm_ops->page_mkwrite) {
 		unlock_page(fault_page);
-		tmp = do_page_mkwrite(vma, fault_page, address);
+		tmp = do_page_mkwrite(vma, fault_page, fe->address);
 		if (unlikely(!tmp ||
 				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
 			put_page(fault_page);
@@ -3093,15 +3075,16 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 	}
 
-	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, orig_pte))) {
-		pte_unmap_unlock(pte, ptl);
+	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
+			&fe->ptl);
+	if (unlikely(!pte_same(*fe->pte, orig_pte))) {
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		unlock_page(fault_page);
 		put_page(fault_page);
 		return ret;
 	}
-	do_set_pte(vma, address, fault_page, pte, true, false);
-	pte_unmap_unlock(pte, ptl);
+	do_set_pte(fe, fault_page);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 
 	if (set_page_dirty(fault_page))
 		dirtied = 1;
@@ -3133,23 +3116,20 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+static int do_fault(struct fault_env *fe, pte_t orig_pte)
 {
-	pgoff_t pgoff = linear_page_index(vma, address);
+	struct vm_area_struct *vma = fe->vma;
+	pgoff_t pgoff = linear_page_index(vma, fe->address);
 
-	pte_unmap(page_table);
+	pte_unmap(fe->pte);
 	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
 	if (!vma->vm_ops->fault)
 		return VM_FAULT_SIGBUS;
-	if (!(flags & FAULT_FLAG_WRITE))
-		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
+	if (!(fe->flags & FAULT_FLAG_WRITE))
+		return do_read_fault(fe, pgoff,	orig_pte);
 	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
-	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+		return do_cow_fault(fe, pgoff, orig_pte);
+	return do_shared_fault(fe, pgoff, orig_pte);
 }
 
 static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
@@ -3167,11 +3147,10 @@ static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 	return mpol_misplaced(page, vma, addr);
 }
 
-static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
+static int do_numa_page(struct fault_env *fe, pte_t pte)
 {
+	struct vm_area_struct *vma = fe->vma;
 	struct page *page = NULL;
-	spinlock_t *ptl;
 	int page_nid = -1;
 	int last_cpupid;
 	int target_nid;
@@ -3191,10 +3170,10 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	* page table entry is not accessible, so there would be no
 	* concurrent hardware modifications to the PTE.
 	*/
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
-	if (unlikely(!pte_same(*ptep, pte))) {
-		pte_unmap_unlock(ptep, ptl);
+	fe->ptl = pte_lockptr(vma->vm_mm, fe->pmd);
+	spin_lock(fe->ptl);
+	if (unlikely(!pte_same(*fe->pte, pte))) {
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		goto out;
 	}
 
@@ -3203,18 +3182,18 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	pte = pte_mkyoung(pte);
 	if (was_writable)
 		pte = pte_mkwrite(pte);
-	set_pte_at(mm, addr, ptep, pte);
-	update_mmu_cache(vma, addr, ptep);
+	set_pte_at(vma->vm_mm, fe->address, fe->pte, pte);
+	update_mmu_cache(vma, fe->address, fe->pte);
 
-	page = vm_normal_page(vma, addr, pte);
+	page = vm_normal_page(vma, fe->address, pte);
 	if (!page) {
-		pte_unmap_unlock(ptep, ptl);
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		return 0;
 	}
 
 	/* TODO: handle PTE-mapped THP */
 	if (PageCompound(page)) {
-		pte_unmap_unlock(ptep, ptl);
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		return 0;
 	}
 
@@ -3238,8 +3217,9 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	last_cpupid = page_cpupid_last(page);
 	page_nid = page_to_nid(page);
-	target_nid = numa_migrate_prep(page, vma, addr, page_nid, &flags);
-	pte_unmap_unlock(ptep, ptl);
+	target_nid = numa_migrate_prep(page, vma, fe->address, page_nid,
+			&flags);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 	if (target_nid == -1) {
 		put_page(page);
 		goto out;
@@ -3259,24 +3239,24 @@ out:
 	return 0;
 }
 
-static int create_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, pmd_t *pmd, unsigned int flags)
+static int create_huge_pmd(struct fault_env *fe)
 {
+	struct vm_area_struct *vma = fe->vma;
 	if (vma_is_anonymous(vma))
-		return do_huge_pmd_anonymous_page(mm, vma, address, pmd, flags);
+		return do_huge_pmd_anonymous_page(fe);
 	if (vma->vm_ops->pmd_fault)
-		return vma->vm_ops->pmd_fault(vma, address, pmd, flags);
+		return vma->vm_ops->pmd_fault(vma, fe->address, fe->pmd,
+				fe->flags);
 	return VM_FAULT_FALLBACK;
 }
 
-static int wp_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, pmd_t *pmd, pmd_t orig_pmd,
-			unsigned int flags)
+static int wp_huge_pmd(struct fault_env *fe, pmd_t orig_pmd)
 {
-	if (vma_is_anonymous(vma))
-		return do_huge_pmd_wp_page(mm, vma, address, pmd, orig_pmd);
-	if (vma->vm_ops->pmd_fault)
-		return vma->vm_ops->pmd_fault(vma, address, pmd, flags);
+	if (vma_is_anonymous(fe->vma))
+		return do_huge_pmd_wp_page(fe, orig_pmd);
+	if (fe->vma->vm_ops->pmd_fault)
+		return fe->vma->vm_ops->pmd_fault(fe->vma, fe->address, fe->pmd,
+				fe->flags);
 	return VM_FAULT_FALLBACK;
 }
 
@@ -3296,12 +3276,9 @@ static int wp_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int handle_pte_fault(struct mm_struct *mm,
-		     struct vm_area_struct *vma, unsigned long address,
-		     pte_t *pte, pmd_t *pmd, unsigned int flags)
+static int handle_pte_fault(struct fault_env *fe)
 {
 	pte_t entry;
-	spinlock_t *ptl;
 
 	/*
 	 * some architectures can have larger ptes than wordsize,
@@ -3311,37 +3288,34 @@ static int handle_pte_fault(struct mm_struct *mm,
 	 * we later double check anyway with the ptl lock held. So here
 	 * a barrier will do.
 	 */
-	entry = *pte;
+	entry = *fe->pte;
 	barrier();
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
-			if (vma_is_anonymous(vma))
-				return do_anonymous_page(mm, vma, address,
-							 pte, pmd, flags);
+			if (vma_is_anonymous(fe->vma))
+				return do_anonymous_page(fe);
 			else
-				return do_fault(mm, vma, address, pte, pmd,
-						flags, entry);
+				return do_fault(fe, entry);
 		}
-		return do_swap_page(mm, vma, address,
-					pte, pmd, flags, entry);
+		return do_swap_page(fe, entry);
 	}
 
 	if (pte_protnone(entry))
-		return do_numa_page(mm, vma, address, entry, pte, pmd);
+		return do_numa_page(fe, entry);
 
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
-	if (unlikely(!pte_same(*pte, entry)))
+	fe->ptl = pte_lockptr(fe->vma->vm_mm, fe->pmd);
+	spin_lock(fe->ptl);
+	if (unlikely(!pte_same(*fe->pte, entry)))
 		goto unlock;
-	if (flags & FAULT_FLAG_WRITE) {
+	if (fe->flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
-			return do_wp_page(mm, vma, address,
-					pte, pmd, ptl, entry);
+			return do_wp_page(fe, entry);
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
-	if (ptep_set_access_flags(vma, address, pte, entry, flags & FAULT_FLAG_WRITE)) {
-		update_mmu_cache(vma, address, pte);
+	if (ptep_set_access_flags(fe->vma, fe->address, fe->pte, entry,
+				fe->flags & FAULT_FLAG_WRITE)) {
+		update_mmu_cache(fe->vma, fe->address, fe->pte);
 	} else {
 		/*
 		 * This is needed only for protection faults but the arch code
@@ -3349,11 +3323,11 @@ static int handle_pte_fault(struct mm_struct *mm,
 		 * This still avoids useless tlb flushes for .text page faults
 		 * with threads.
 		 */
-		if (flags & FAULT_FLAG_WRITE)
-			flush_tlb_fix_spurious_fault(vma, address);
+		if (fe->flags & FAULT_FLAG_WRITE)
+			flush_tlb_fix_spurious_fault(fe->vma, fe->address);
 	}
 unlock:
-	pte_unmap_unlock(pte, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 	return 0;
 }
 
@@ -3366,51 +3340,42 @@ unlock:
 static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		unsigned int flags)
 {
+	struct fault_env fe = {
+		.vma = vma,
+		.address = address,
+		.flags = flags,
+	};
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
 	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-
-	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
-					    flags & FAULT_FLAG_INSTRUCTION,
-					    flags & FAULT_FLAG_REMOTE))
-		return VM_FAULT_SIGSEGV;
-
-	if (unlikely(is_vm_hugetlb_page(vma)))
-		return hugetlb_fault(mm, vma, address, flags);
 
 	pgd = pgd_offset(mm, address);
 	pud = pud_alloc(mm, pgd, address);
 	if (!pud)
 		return VM_FAULT_OOM;
-	pmd = pmd_alloc(mm, pud, address);
-	if (!pmd)
+	fe.pmd = pmd_alloc(mm, pud, address);
+	if (!fe.pmd)
 		return VM_FAULT_OOM;
-	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
-		int ret = create_huge_pmd(mm, vma, address, pmd, flags);
+	if (pmd_none(*fe.pmd) && transparent_hugepage_enabled(vma)) {
+		int ret = create_huge_pmd(&fe);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
 	} else {
-		pmd_t orig_pmd = *pmd;
+		pmd_t orig_pmd = *fe.pmd;
 		int ret;
 
 		barrier();
 		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
-			unsigned int dirty = flags & FAULT_FLAG_WRITE;
-
 			if (pmd_protnone(orig_pmd))
-				return do_huge_pmd_numa_page(mm, vma, address,
-							     orig_pmd, pmd);
+				return do_huge_pmd_numa_page(&fe, orig_pmd);
 
-			if (dirty && !pmd_write(orig_pmd)) {
-				ret = wp_huge_pmd(mm, vma, address, pmd,
-							orig_pmd, flags);
+			if ((fe.flags & FAULT_FLAG_WRITE) &&
+					!pmd_write(orig_pmd)) {
+				ret = wp_huge_pmd(&fe, orig_pmd);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
 			} else {
-				huge_pmd_set_accessed(mm, vma, address, pmd,
-						      orig_pmd, dirty);
+				huge_pmd_set_accessed(&fe, orig_pmd);
 				return 0;
 			}
 		}
@@ -3421,7 +3386,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	 * run pte_offset_map on the pmd, if an huge pmd could
 	 * materialize from under us from a different thread.
 	 */
-	if (unlikely(pte_alloc(mm, pmd, address)))
+	if (unlikely(pte_alloc(fe.vma->vm_mm, fe.pmd, fe.address)))
 		return VM_FAULT_OOM;
 	/*
 	 * If a huge pmd materialized under us just retry later.  Use
@@ -3434,7 +3399,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	 * through an atomic read in C, which is what pmd_trans_unstable()
 	 * provides.
 	 */
-	if (unlikely(pmd_trans_unstable(pmd) || pmd_devmap(*pmd)))
+	if (unlikely(pmd_trans_unstable(fe.pmd) || pmd_devmap(*fe.pmd)))
 		return 0;
 	/*
 	 * A regular pmd is established and it can't morph into a huge pmd
@@ -3442,9 +3407,9 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	 * read mode and khugepaged takes it in write mode. So now it's
 	 * safe to run pte_offset_map().
 	 */
-	pte = pte_offset_map(pmd, address);
+	fe.pte = pte_offset_map(fe.pmd, fe.address);
 
-	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
+	return handle_pte_fault(&fe);
 }
 
 /*
@@ -3473,7 +3438,15 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	if (flags & FAULT_FLAG_USER)
 		mem_cgroup_oom_enable();
 
-	ret = __handle_mm_fault(vma, address, flags);
+	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
+					    flags & FAULT_FLAG_INSTRUCTION,
+					    flags & FAULT_FLAG_REMOTE))
+		return VM_FAULT_SIGSEGV;
+
+	if (unlikely(is_vm_hugetlb_page(vma)))
+		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
+	else
+		ret = __handle_mm_fault(vma, address, flags);
 
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_oom_disable();
diff --git a/mm/nommu.c b/mm/nommu.c
index 102e257cc6c3..146c2139f506 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1811,7 +1811,8 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 }
 EXPORT_SYMBOL(filemap_fault);
 
-void filemap_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf)
+void filemap_map_pages(struct fault_env *fe,
+		pgoff_t start_pgoff, pgoff_t end_pgoff)
 {
 	BUG();
 }
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
