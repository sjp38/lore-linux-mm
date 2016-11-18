Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 440D36B03CC
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:17:33 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so9607208wma.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:17:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s17si1737148wme.47.2016.11.18.01.17.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 01:17:30 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 01/20] mm: Join struct fault_env and vm_fault
Date: Fri, 18 Nov 2016 10:17:05 +0100
Message-Id: <1479460644-25076-2-git-send-email-jack@suse.cz>
In-Reply-To: <1479460644-25076-1-git-send-email-jack@suse.cz>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>

Currently we have two different structures for passing fault information
around - struct vm_fault and struct fault_env. DAX will need more
information in struct vm_fault to handle its faults so the content of
that structure would become event closer to fault_env. Furthermore it
would need to generate struct fault_env to be able to call some of the
generic functions. So at this point I don't think there's much use in
keeping these two structures separate. Just embed into struct vm_fault
all that is needed to use it for both purposes.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 Documentation/filesystems/Locking |   2 +-
 fs/userfaultfd.c                  |  22 +-
 include/linux/huge_mm.h           |  10 +-
 include/linux/mm.h                |  28 +-
 include/linux/userfaultfd_k.h     |   4 +-
 mm/filemap.c                      |  14 +-
 mm/huge_memory.c                  | 173 ++++++------
 mm/internal.h                     |   2 +-
 mm/khugepaged.c                   |  20 +-
 mm/memory.c                       | 549 +++++++++++++++++++-------------------
 mm/nommu.c                        |   2 +-
 11 files changed, 414 insertions(+), 412 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 1b5f15653b1b..69e2387ca278 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -556,7 +556,7 @@ till "end_pgoff". ->map_pages() is called with page table locked and must
 not block.  If it's not possible to reach a page without blocking,
 filesystem should skip it. Filesystem should use do_set_pte() to setup
 page table entry. Pointer to entry associated with the page is passed in
-"pte" field in fault_env structure. Pointers to entries for other offsets
+"pte" field in vm_fault structure. Pointers to entries for other offsets
 should be calculated relative to "pte".
 
 	->page_mkwrite() is called when a previously read-only pte is
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 85959d8324df..d96e2f30084b 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -257,9 +257,9 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
  * fatal_signal_pending()s, and the mmap_sem must be released before
  * returning it.
  */
-int handle_userfault(struct fault_env *fe, unsigned long reason)
+int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 {
-	struct mm_struct *mm = fe->vma->vm_mm;
+	struct mm_struct *mm = vmf->vma->vm_mm;
 	struct userfaultfd_ctx *ctx;
 	struct userfaultfd_wait_queue uwq;
 	int ret;
@@ -268,7 +268,7 @@ int handle_userfault(struct fault_env *fe, unsigned long reason)
 	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
 	ret = VM_FAULT_SIGBUS;
-	ctx = fe->vma->vm_userfaultfd_ctx.ctx;
+	ctx = vmf->vma->vm_userfaultfd_ctx.ctx;
 	if (!ctx)
 		goto out;
 
@@ -301,17 +301,18 @@ int handle_userfault(struct fault_env *fe, unsigned long reason)
 	 * without first stopping userland access to the memory. For
 	 * VM_UFFD_MISSING userfaults this is enough for now.
 	 */
-	if (unlikely(!(fe->flags & FAULT_FLAG_ALLOW_RETRY))) {
+	if (unlikely(!(vmf->flags & FAULT_FLAG_ALLOW_RETRY))) {
 		/*
 		 * Validate the invariant that nowait must allow retry
 		 * to be sure not to return SIGBUS erroneously on
 		 * nowait invocations.
 		 */
-		BUG_ON(fe->flags & FAULT_FLAG_RETRY_NOWAIT);
+		BUG_ON(vmf->flags & FAULT_FLAG_RETRY_NOWAIT);
 #ifdef CONFIG_DEBUG_VM
 		if (printk_ratelimit()) {
 			printk(KERN_WARNING
-			       "FAULT_FLAG_ALLOW_RETRY missing %x\n", fe->flags);
+			       "FAULT_FLAG_ALLOW_RETRY missing %x\n",
+			       vmf->flags);
 			dump_stack();
 		}
 #endif
@@ -323,7 +324,7 @@ int handle_userfault(struct fault_env *fe, unsigned long reason)
 	 * and wait.
 	 */
 	ret = VM_FAULT_RETRY;
-	if (fe->flags & FAULT_FLAG_RETRY_NOWAIT)
+	if (vmf->flags & FAULT_FLAG_RETRY_NOWAIT)
 		goto out;
 
 	/* take the reference before dropping the mmap_sem */
@@ -331,11 +332,11 @@ int handle_userfault(struct fault_env *fe, unsigned long reason)
 
 	init_waitqueue_func_entry(&uwq.wq, userfaultfd_wake_function);
 	uwq.wq.private = current;
-	uwq.msg = userfault_msg(fe->address, fe->flags, reason);
+	uwq.msg = userfault_msg(vmf->address, vmf->flags, reason);
 	uwq.ctx = ctx;
 
 	return_to_userland =
-		(fe->flags & (FAULT_FLAG_USER|FAULT_FLAG_KILLABLE)) ==
+		(vmf->flags & (FAULT_FLAG_USER|FAULT_FLAG_KILLABLE)) ==
 		(FAULT_FLAG_USER|FAULT_FLAG_KILLABLE);
 
 	spin_lock(&ctx->fault_pending_wqh.lock);
@@ -353,7 +354,8 @@ int handle_userfault(struct fault_env *fe, unsigned long reason)
 			  TASK_KILLABLE);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 
-	must_wait = userfaultfd_must_wait(ctx, fe->address, fe->flags, reason);
+	must_wait = userfaultfd_must_wait(ctx, vmf->address, vmf->flags,
+					  reason);
 	up_read(&mm->mmap_sem);
 
 	if (likely(must_wait && !ACCESS_ONCE(ctx->released) &&
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 9b9f65d99873..3237a39f94a4 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -1,12 +1,12 @@
 #ifndef _LINUX_HUGE_MM_H
 #define _LINUX_HUGE_MM_H
 
-extern int do_huge_pmd_anonymous_page(struct fault_env *fe);
+extern int do_huge_pmd_anonymous_page(struct vm_fault *vmf);
 extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 			 struct vm_area_struct *vma);
-extern void huge_pmd_set_accessed(struct fault_env *fe, pmd_t orig_pmd);
-extern int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd);
+extern void huge_pmd_set_accessed(struct vm_fault *vmf, pmd_t orig_pmd);
+extern int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd);
 extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  unsigned long addr,
 					  pmd_t *pmd,
@@ -142,7 +142,7 @@ static inline int hpage_nr_pages(struct page *page)
 	return 1;
 }
 
-extern int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t orig_pmd);
+extern int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd);
 
 extern struct page *huge_zero_page;
 
@@ -210,7 +210,7 @@ static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 	return NULL;
 }
 
-static inline int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t orig_pmd)
+static inline int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	return 0;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a92c8d73aeaf..657eb69eb87e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -292,10 +292,16 @@ extern pgprot_t protection_map[16];
  * pgoff should be used in favour of virtual_address, if possible.
  */
 struct vm_fault {
+	struct vm_area_struct *vma;	/* Target VMA */
 	unsigned int flags;		/* FAULT_FLAG_xxx flags */
 	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
 	pgoff_t pgoff;			/* Logical page offset based on vma */
-	void __user *virtual_address;	/* Faulting virtual address */
+	unsigned long address;		/* Faulting virtual address */
+	void __user *virtual_address;	/* Faulting virtual address masked by
+					 * PAGE_MASK */
+	pmd_t *pmd;			/* Pointer to pmd entry matching
+					 * the 'address'
+					 */
 
 	struct page *cow_page;		/* Handler may choose to COW */
 	struct page *page;		/* ->fault handlers should return a
@@ -309,19 +315,7 @@ struct vm_fault {
 					 * VM_FAULT_DAX_LOCKED and fill in
 					 * entry here.
 					 */
-};
-
-/*
- * Page fault context: passes though page fault handler instead of endless list
- * of function arguments.
- */
-struct fault_env {
-	struct vm_area_struct *vma;	/* Target VMA */
-	unsigned long address;		/* Faulting virtual address */
-	unsigned int flags;		/* FAULT_FLAG_xxx flags */
-	pmd_t *pmd;			/* Pointer to pmd entry matching
-					 * the 'address'
-					 */
+	/* These three entries are valid only while holding ptl lock */
 	pte_t *pte;			/* Pointer to pte entry matching
 					 * the 'address'. NULL if the page
 					 * table hasn't been allocated.
@@ -351,7 +345,7 @@ struct vm_operations_struct {
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
 	int (*pmd_fault)(struct vm_area_struct *, unsigned long address,
 						pmd_t *, unsigned int flags);
-	void (*map_pages)(struct fault_env *fe,
+	void (*map_pages)(struct vm_fault *vmf,
 			pgoff_t start_pgoff, pgoff_t end_pgoff);
 
 	/* notification that a previously read-only page is about to become
@@ -625,7 +619,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 	return pte;
 }
 
-int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
+int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		struct page *page);
 #endif
 
@@ -2097,7 +2091,7 @@ extern void truncate_inode_pages_final(struct address_space *);
 
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
-extern void filemap_map_pages(struct fault_env *fe,
+extern void filemap_map_pages(struct vm_fault *vmf,
 		pgoff_t start_pgoff, pgoff_t end_pgoff);
 extern int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
 
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index dd66a952e8cd..11b92b047a1e 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -27,7 +27,7 @@
 #define UFFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
 #define UFFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS)
 
-extern int handle_userfault(struct fault_env *fe, unsigned long reason);
+extern int handle_userfault(struct vm_fault *vmf, unsigned long reason);
 
 extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
 			    unsigned long src_start, unsigned long len);
@@ -55,7 +55,7 @@ static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
-static inline int handle_userfault(struct fault_env *fe, unsigned long reason)
+static inline int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 {
 	return VM_FAULT_SIGBUS;
 }
diff --git a/mm/filemap.c b/mm/filemap.c
index c3765f9e3a57..37ac8c0cae96 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2212,12 +2212,12 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 }
 EXPORT_SYMBOL(filemap_fault);
 
-void filemap_map_pages(struct fault_env *fe,
+void filemap_map_pages(struct vm_fault *vmf,
 		pgoff_t start_pgoff, pgoff_t end_pgoff)
 {
 	struct radix_tree_iter iter;
 	void **slot;
-	struct file *file = fe->vma->vm_file;
+	struct file *file = vmf->vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
 	pgoff_t last_pgoff = start_pgoff;
 	loff_t size;
@@ -2273,11 +2273,11 @@ void filemap_map_pages(struct fault_env *fe,
 		if (file->f_ra.mmap_miss > 0)
 			file->f_ra.mmap_miss--;
 
-		fe->address += (iter.index - last_pgoff) << PAGE_SHIFT;
-		if (fe->pte)
-			fe->pte += iter.index - last_pgoff;
+		vmf->address += (iter.index - last_pgoff) << PAGE_SHIFT;
+		if (vmf->pte)
+			vmf->pte += iter.index - last_pgoff;
 		last_pgoff = iter.index;
-		if (alloc_set_pte(fe, NULL, page))
+		if (alloc_set_pte(vmf, NULL, page))
 			goto unlock;
 		unlock_page(page);
 		goto next;
@@ -2287,7 +2287,7 @@ void filemap_map_pages(struct fault_env *fe,
 		put_page(page);
 next:
 		/* Huge page is mapped? No need to proceed. */
-		if (pmd_trans_huge(*fe->pmd))
+		if (pmd_trans_huge(*vmf->pmd))
 			break;
 		if (iter.index == end_pgoff)
 			break;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cdcd25cb30fe..e286b09f9d24 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -532,13 +532,13 @@ unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
 }
 EXPORT_SYMBOL_GPL(thp_get_unmapped_area);
 
-static int __do_huge_pmd_anonymous_page(struct fault_env *fe, struct page *page,
+static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 		gfp_t gfp)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
-	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
+	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
@@ -563,9 +563,9 @@ static int __do_huge_pmd_anonymous_page(struct fault_env *fe, struct page *page,
 	 */
 	__SetPageUptodate(page);
 
-	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
-	if (unlikely(!pmd_none(*fe->pmd))) {
-		spin_unlock(fe->ptl);
+	vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
+	if (unlikely(!pmd_none(*vmf->pmd))) {
+		spin_unlock(vmf->ptl);
 		mem_cgroup_cancel_charge(page, memcg, true);
 		put_page(page);
 		pte_free(vma->vm_mm, pgtable);
@@ -576,11 +576,11 @@ static int __do_huge_pmd_anonymous_page(struct fault_env *fe, struct page *page,
 		if (userfaultfd_missing(vma)) {
 			int ret;
 
-			spin_unlock(fe->ptl);
+			spin_unlock(vmf->ptl);
 			mem_cgroup_cancel_charge(page, memcg, true);
 			put_page(page);
 			pte_free(vma->vm_mm, pgtable);
-			ret = handle_userfault(fe, VM_UFFD_MISSING);
+			ret = handle_userfault(vmf, VM_UFFD_MISSING);
 			VM_BUG_ON(ret & VM_FAULT_FALLBACK);
 			return ret;
 		}
@@ -590,11 +590,11 @@ static int __do_huge_pmd_anonymous_page(struct fault_env *fe, struct page *page,
 		page_add_new_anon_rmap(page, vma, haddr, true);
 		mem_cgroup_commit_charge(page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(page, vma);
-		pgtable_trans_huge_deposit(vma->vm_mm, fe->pmd, pgtable);
-		set_pmd_at(vma->vm_mm, haddr, fe->pmd, entry);
+		pgtable_trans_huge_deposit(vma->vm_mm, vmf->pmd, pgtable);
+		set_pmd_at(vma->vm_mm, haddr, vmf->pmd, entry);
 		add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		atomic_long_inc(&vma->vm_mm->nr_ptes);
-		spin_unlock(fe->ptl);
+		spin_unlock(vmf->ptl);
 		count_vm_event(THP_FAULT_ALLOC);
 	}
 
@@ -641,12 +641,12 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 	return true;
 }
 
-int do_huge_pmd_anonymous_page(struct fault_env *fe)
+int do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	gfp_t gfp;
 	struct page *page;
-	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
+	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 
 	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
 		return VM_FAULT_FALLBACK;
@@ -654,7 +654,7 @@ int do_huge_pmd_anonymous_page(struct fault_env *fe)
 		return VM_FAULT_OOM;
 	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
 		return VM_FAULT_OOM;
-	if (!(fe->flags & FAULT_FLAG_WRITE) &&
+	if (!(vmf->flags & FAULT_FLAG_WRITE) &&
 			!mm_forbids_zeropage(vma->vm_mm) &&
 			transparent_hugepage_use_zero_page()) {
 		pgtable_t pgtable;
@@ -670,22 +670,22 @@ int do_huge_pmd_anonymous_page(struct fault_env *fe)
 			count_vm_event(THP_FAULT_FALLBACK);
 			return VM_FAULT_FALLBACK;
 		}
-		fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
+		vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
 		ret = 0;
 		set = false;
-		if (pmd_none(*fe->pmd)) {
+		if (pmd_none(*vmf->pmd)) {
 			if (userfaultfd_missing(vma)) {
-				spin_unlock(fe->ptl);
-				ret = handle_userfault(fe, VM_UFFD_MISSING);
+				spin_unlock(vmf->ptl);
+				ret = handle_userfault(vmf, VM_UFFD_MISSING);
 				VM_BUG_ON(ret & VM_FAULT_FALLBACK);
 			} else {
 				set_huge_zero_page(pgtable, vma->vm_mm, vma,
-						   haddr, fe->pmd, zero_page);
-				spin_unlock(fe->ptl);
+						   haddr, vmf->pmd, zero_page);
+				spin_unlock(vmf->ptl);
 				set = true;
 			}
 		} else
-			spin_unlock(fe->ptl);
+			spin_unlock(vmf->ptl);
 		if (!set)
 			pte_free(vma->vm_mm, pgtable);
 		return ret;
@@ -697,7 +697,7 @@ int do_huge_pmd_anonymous_page(struct fault_env *fe)
 		return VM_FAULT_FALLBACK;
 	}
 	prep_transhuge_page(page);
-	return __do_huge_pmd_anonymous_page(fe, page, gfp);
+	return __do_huge_pmd_anonymous_page(vmf, page, gfp);
 }
 
 static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
@@ -868,30 +868,30 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	return ret;
 }
 
-void huge_pmd_set_accessed(struct fault_env *fe, pmd_t orig_pmd)
+void huge_pmd_set_accessed(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	pmd_t entry;
 	unsigned long haddr;
 
-	fe->ptl = pmd_lock(fe->vma->vm_mm, fe->pmd);
-	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
+	vmf->ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
+	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
 		goto unlock;
 
 	entry = pmd_mkyoung(orig_pmd);
-	haddr = fe->address & HPAGE_PMD_MASK;
-	if (pmdp_set_access_flags(fe->vma, haddr, fe->pmd, entry,
-				fe->flags & FAULT_FLAG_WRITE))
-		update_mmu_cache_pmd(fe->vma, fe->address, fe->pmd);
+	haddr = vmf->address & HPAGE_PMD_MASK;
+	if (pmdp_set_access_flags(vmf->vma, haddr, vmf->pmd, entry,
+				vmf->flags & FAULT_FLAG_WRITE))
+		update_mmu_cache_pmd(vmf->vma, vmf->address, vmf->pmd);
 
 unlock:
-	spin_unlock(fe->ptl);
+	spin_unlock(vmf->ptl);
 }
 
-static int do_huge_pmd_wp_page_fallback(struct fault_env *fe, pmd_t orig_pmd,
+static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 		struct page *page)
 {
-	struct vm_area_struct *vma = fe->vma;
-	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
+	struct vm_area_struct *vma = vmf->vma;
+	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
 	pmd_t _pmd;
@@ -910,7 +910,7 @@ static int do_huge_pmd_wp_page_fallback(struct fault_env *fe, pmd_t orig_pmd,
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		pages[i] = alloc_page_vma_node(GFP_HIGHUSER_MOVABLE |
 					       __GFP_OTHER_NODE, vma,
-					       fe->address, page_to_nid(page));
+					       vmf->address, page_to_nid(page));
 		if (unlikely(!pages[i] ||
 			     mem_cgroup_try_charge(pages[i], vma->vm_mm,
 				     GFP_KERNEL, &memcg, false))) {
@@ -941,15 +941,15 @@ static int do_huge_pmd_wp_page_fallback(struct fault_env *fe, pmd_t orig_pmd,
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
 
-	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
-	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
+	vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
+	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
 		goto out_free_pages;
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
-	pmdp_huge_clear_flush_notify(vma, haddr, fe->pmd);
+	pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
 	/* leave pmd empty until pte is filled */
 
-	pgtable = pgtable_trans_huge_withdraw(vma->vm_mm, fe->pmd);
+	pgtable = pgtable_trans_huge_withdraw(vma->vm_mm, vmf->pmd);
 	pmd_populate(vma->vm_mm, &_pmd, pgtable);
 
 	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
@@ -958,20 +958,20 @@ static int do_huge_pmd_wp_page_fallback(struct fault_env *fe, pmd_t orig_pmd,
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
-		page_add_new_anon_rmap(pages[i], fe->vma, haddr, false);
+		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, false);
 		mem_cgroup_commit_charge(pages[i], memcg, false, false);
 		lru_cache_add_active_or_unevictable(pages[i], vma);
-		fe->pte = pte_offset_map(&_pmd, haddr);
-		VM_BUG_ON(!pte_none(*fe->pte));
-		set_pte_at(vma->vm_mm, haddr, fe->pte, entry);
-		pte_unmap(fe->pte);
+		vmf->pte = pte_offset_map(&_pmd, haddr);
+		VM_BUG_ON(!pte_none(*vmf->pte));
+		set_pte_at(vma->vm_mm, haddr, vmf->pte, entry);
+		pte_unmap(vmf->pte);
 	}
 	kfree(pages);
 
 	smp_wmb(); /* make pte visible before pmd */
-	pmd_populate(vma->vm_mm, fe->pmd, pgtable);
+	pmd_populate(vma->vm_mm, vmf->pmd, pgtable);
 	page_remove_rmap(page, true);
-	spin_unlock(fe->ptl);
+	spin_unlock(vmf->ptl);
 
 	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
 
@@ -982,7 +982,7 @@ static int do_huge_pmd_wp_page_fallback(struct fault_env *fe, pmd_t orig_pmd,
 	return ret;
 
 out_free_pages:
-	spin_unlock(fe->ptl);
+	spin_unlock(vmf->ptl);
 	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		memcg = (void *)page_private(pages[i]);
@@ -994,23 +994,23 @@ static int do_huge_pmd_wp_page_fallback(struct fault_env *fe, pmd_t orig_pmd,
 	goto out;
 }
 
-int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd)
+int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL, *new_page;
 	struct mem_cgroup *memcg;
-	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
+	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 	gfp_t huge_gfp;			/* for allocation and charge */
 	int ret = 0;
 
-	fe->ptl = pmd_lockptr(vma->vm_mm, fe->pmd);
+	vmf->ptl = pmd_lockptr(vma->vm_mm, vmf->pmd);
 	VM_BUG_ON_VMA(!vma->anon_vma, vma);
 	if (is_huge_zero_pmd(orig_pmd))
 		goto alloc;
-	spin_lock(fe->ptl);
-	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
+	spin_lock(vmf->ptl);
+	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
 		goto out_unlock;
 
 	page = pmd_page(orig_pmd);
@@ -1023,13 +1023,13 @@ int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd)
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		if (pmdp_set_access_flags(vma, haddr, fe->pmd, entry,  1))
-			update_mmu_cache_pmd(vma, fe->address, fe->pmd);
+		if (pmdp_set_access_flags(vma, haddr, vmf->pmd, entry,  1))
+			update_mmu_cache_pmd(vma, vmf->address, vmf->pmd);
 		ret |= VM_FAULT_WRITE;
 		goto out_unlock;
 	}
 	get_page(page);
-	spin_unlock(fe->ptl);
+	spin_unlock(vmf->ptl);
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow()) {
@@ -1042,12 +1042,12 @@ int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd)
 		prep_transhuge_page(new_page);
 	} else {
 		if (!page) {
-			split_huge_pmd(vma, fe->pmd, fe->address);
+			split_huge_pmd(vma, vmf->pmd, vmf->address);
 			ret |= VM_FAULT_FALLBACK;
 		} else {
-			ret = do_huge_pmd_wp_page_fallback(fe, orig_pmd, page);
+			ret = do_huge_pmd_wp_page_fallback(vmf, orig_pmd, page);
 			if (ret & VM_FAULT_OOM) {
-				split_huge_pmd(vma, fe->pmd, fe->address);
+				split_huge_pmd(vma, vmf->pmd, vmf->address);
 				ret |= VM_FAULT_FALLBACK;
 			}
 			put_page(page);
@@ -1059,7 +1059,7 @@ int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd)
 	if (unlikely(mem_cgroup_try_charge(new_page, vma->vm_mm,
 					huge_gfp, &memcg, true))) {
 		put_page(new_page);
-		split_huge_pmd(vma, fe->pmd, fe->address);
+		split_huge_pmd(vma, vmf->pmd, vmf->address);
 		if (page)
 			put_page(page);
 		ret |= VM_FAULT_FALLBACK;
@@ -1079,11 +1079,11 @@ int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd)
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
 
-	spin_lock(fe->ptl);
+	spin_lock(vmf->ptl);
 	if (page)
 		put_page(page);
-	if (unlikely(!pmd_same(*fe->pmd, orig_pmd))) {
-		spin_unlock(fe->ptl);
+	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd))) {
+		spin_unlock(vmf->ptl);
 		mem_cgroup_cancel_charge(new_page, memcg, true);
 		put_page(new_page);
 		goto out_mn;
@@ -1091,12 +1091,12 @@ int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd)
 		pmd_t entry;
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		pmdp_huge_clear_flush_notify(vma, haddr, fe->pmd);
+		pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr, true);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(new_page, vma);
-		set_pmd_at(vma->vm_mm, haddr, fe->pmd, entry);
-		update_mmu_cache_pmd(vma, fe->address, fe->pmd);
+		set_pmd_at(vma->vm_mm, haddr, vmf->pmd, entry);
+		update_mmu_cache_pmd(vma, vmf->address, vmf->pmd);
 		if (!page) {
 			add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		} else {
@@ -1106,13 +1106,13 @@ int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd)
 		}
 		ret |= VM_FAULT_WRITE;
 	}
-	spin_unlock(fe->ptl);
+	spin_unlock(vmf->ptl);
 out_mn:
 	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
 out:
 	return ret;
 out_unlock:
-	spin_unlock(fe->ptl);
+	spin_unlock(vmf->ptl);
 	return ret;
 }
 
@@ -1185,12 +1185,12 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 }
 
 /* NUMA hinting page fault entry point for trans huge pmds */
-int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t pmd)
+int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	struct anon_vma *anon_vma = NULL;
 	struct page *page;
-	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
+	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 	int page_nid = -1, this_nid = numa_node_id();
 	int target_nid, last_cpupid = -1;
 	bool page_locked;
@@ -1198,8 +1198,8 @@ int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t pmd)
 	bool was_writable;
 	int flags = 0;
 
-	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
-	if (unlikely(!pmd_same(pmd, *fe->pmd)))
+	vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
+	if (unlikely(!pmd_same(pmd, *vmf->pmd)))
 		goto out_unlock;
 
 	/*
@@ -1207,9 +1207,9 @@ int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t pmd)
 	 * without disrupting NUMA hinting information. Do not relock and
 	 * check_same as the page may no longer be mapped.
 	 */
-	if (unlikely(pmd_trans_migrating(*fe->pmd))) {
-		page = pmd_page(*fe->pmd);
-		spin_unlock(fe->ptl);
+	if (unlikely(pmd_trans_migrating(*vmf->pmd))) {
+		page = pmd_page(*vmf->pmd);
+		spin_unlock(vmf->ptl);
 		wait_on_page_locked(page);
 		goto out;
 	}
@@ -1242,7 +1242,7 @@ int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t pmd)
 
 	/* Migration could have started since the pmd_trans_migrating check */
 	if (!page_locked) {
-		spin_unlock(fe->ptl);
+		spin_unlock(vmf->ptl);
 		wait_on_page_locked(page);
 		page_nid = -1;
 		goto out;
@@ -1253,12 +1253,12 @@ int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t pmd)
 	 * to serialises splits
 	 */
 	get_page(page);
-	spin_unlock(fe->ptl);
+	spin_unlock(vmf->ptl);
 	anon_vma = page_lock_anon_vma_read(page);
 
 	/* Confirm the PMD did not change while page_table_lock was released */
-	spin_lock(fe->ptl);
-	if (unlikely(!pmd_same(pmd, *fe->pmd))) {
+	spin_lock(vmf->ptl);
+	if (unlikely(!pmd_same(pmd, *vmf->pmd))) {
 		unlock_page(page);
 		put_page(page);
 		page_nid = -1;
@@ -1276,9 +1276,9 @@ int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t pmd)
 	 * Migrate the THP to the requested node, returns with page unlocked
 	 * and access rights restored.
 	 */
-	spin_unlock(fe->ptl);
+	spin_unlock(vmf->ptl);
 	migrated = migrate_misplaced_transhuge_page(vma->vm_mm, vma,
-				fe->pmd, pmd, fe->address, page, target_nid);
+				vmf->pmd, pmd, vmf->address, page, target_nid);
 	if (migrated) {
 		flags |= TNF_MIGRATED;
 		page_nid = target_nid;
@@ -1293,18 +1293,19 @@ int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t pmd)
 	pmd = pmd_mkyoung(pmd);
 	if (was_writable)
 		pmd = pmd_mkwrite(pmd);
-	set_pmd_at(vma->vm_mm, haddr, fe->pmd, pmd);
-	update_mmu_cache_pmd(vma, fe->address, fe->pmd);
+	set_pmd_at(vma->vm_mm, haddr, vmf->pmd, pmd);
+	update_mmu_cache_pmd(vma, vmf->address, vmf->pmd);
 	unlock_page(page);
 out_unlock:
-	spin_unlock(fe->ptl);
+	spin_unlock(vmf->ptl);
 
 out:
 	if (anon_vma)
 		page_unlock_anon_vma_read(anon_vma);
 
 	if (page_nid != -1)
-		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR, fe->flags);
+		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR,
+				vmf->flags);
 
 	return 0;
 }
diff --git a/mm/internal.h b/mm/internal.h
index 537ac9951f5f..093b1eacc91b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -36,7 +36,7 @@
 /* Do not use these with a slab allocator */
 #define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
 
-int do_swap_page(struct fault_env *fe, pte_t orig_pte);
+int do_swap_page(struct vm_fault *vmf, pte_t orig_pte);
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 728d7790dc2d..f88b2d3810a7 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -875,7 +875,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 {
 	pte_t pteval;
 	int swapped_in = 0, ret = 0;
-	struct fault_env fe = {
+	struct vm_fault vmf = {
 		.vma = vma,
 		.address = address,
 		.flags = FAULT_FLAG_ALLOW_RETRY,
@@ -887,19 +887,19 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
 		return false;
 	}
-	fe.pte = pte_offset_map(pmd, address);
-	for (; fe.address < address + HPAGE_PMD_NR*PAGE_SIZE;
-			fe.pte++, fe.address += PAGE_SIZE) {
-		pteval = *fe.pte;
+	vmf.pte = pte_offset_map(pmd, address);
+	for (; vmf.address < address + HPAGE_PMD_NR*PAGE_SIZE;
+			vmf.pte++, vmf.address += PAGE_SIZE) {
+		pteval = *vmf.pte;
 		if (!is_swap_pte(pteval))
 			continue;
 		swapped_in++;
-		ret = do_swap_page(&fe, pteval);
+		ret = do_swap_page(&vmf, pteval);
 
 		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
 		if (ret & VM_FAULT_RETRY) {
 			down_read(&mm->mmap_sem);
-			if (hugepage_vma_revalidate(mm, address, &fe.vma)) {
+			if (hugepage_vma_revalidate(mm, address, &vmf.vma)) {
 				/* vma is no longer available, don't continue to swapin */
 				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
 				return false;
@@ -913,10 +913,10 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 			return false;
 		}
 		/* pte is unmapped now, we need to map it */
-		fe.pte = pte_offset_map(pmd, fe.address);
+		vmf.pte = pte_offset_map(pmd, vmf.address);
 	}
-	fe.pte--;
-	pte_unmap(fe.pte);
+	vmf.pte--;
+	pte_unmap(vmf.pte);
 	trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 1);
 	return true;
 }
diff --git a/mm/memory.c b/mm/memory.c
index e18c57bdc75c..fad45cd59ba7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2074,11 +2074,11 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
  * case, all we need to do here is to mark the page as writable and update
  * any related book-keeping.
  */
-static inline int wp_page_reuse(struct fault_env *fe, pte_t orig_pte,
+static inline int wp_page_reuse(struct vm_fault *vmf, pte_t orig_pte,
 			struct page *page, int page_mkwrite, int dirty_shared)
-	__releases(fe->ptl)
+	__releases(vmf->ptl)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	pte_t entry;
 	/*
 	 * Clear the pages cpupid information as the existing
@@ -2088,12 +2088,12 @@ static inline int wp_page_reuse(struct fault_env *fe, pte_t orig_pte,
 	if (page)
 		page_cpupid_xchg_last(page, (1 << LAST_CPUPID_SHIFT) - 1);
 
-	flush_cache_page(vma, fe->address, pte_pfn(orig_pte));
+	flush_cache_page(vma, vmf->address, pte_pfn(orig_pte));
 	entry = pte_mkyoung(orig_pte);
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-	if (ptep_set_access_flags(vma, fe->address, fe->pte, entry, 1))
-		update_mmu_cache(vma, fe->address, fe->pte);
-	pte_unmap_unlock(fe->pte, fe->ptl);
+	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
+		update_mmu_cache(vma, vmf->address, vmf->pte);
+	pte_unmap_unlock(vmf->pte, vmf->ptl);
 
 	if (dirty_shared) {
 		struct address_space *mapping;
@@ -2139,15 +2139,15 @@ static inline int wp_page_reuse(struct fault_env *fe, pte_t orig_pte,
  *   held to the old page, as well as updating the rmap.
  * - In any case, unlock the PTL and drop the reference we took to the old page.
  */
-static int wp_page_copy(struct fault_env *fe, pte_t orig_pte,
+static int wp_page_copy(struct vm_fault *vmf, pte_t orig_pte,
 		struct page *old_page)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *new_page = NULL;
 	pte_t entry;
 	int page_copied = 0;
-	const unsigned long mmun_start = fe->address & PAGE_MASK;
+	const unsigned long mmun_start = vmf->address & PAGE_MASK;
 	const unsigned long mmun_end = mmun_start + PAGE_SIZE;
 	struct mem_cgroup *memcg;
 
@@ -2155,15 +2155,16 @@ static int wp_page_copy(struct fault_env *fe, pte_t orig_pte,
 		goto oom;
 
 	if (is_zero_pfn(pte_pfn(orig_pte))) {
-		new_page = alloc_zeroed_user_highpage_movable(vma, fe->address);
+		new_page = alloc_zeroed_user_highpage_movable(vma,
+							      vmf->address);
 		if (!new_page)
 			goto oom;
 	} else {
 		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
-				fe->address);
+				vmf->address);
 		if (!new_page)
 			goto oom;
-		cow_user_page(new_page, old_page, fe->address, vma);
+		cow_user_page(new_page, old_page, vmf->address, vma);
 	}
 
 	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg, false))
@@ -2176,8 +2177,8 @@ static int wp_page_copy(struct fault_env *fe, pte_t orig_pte,
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	fe->pte = pte_offset_map_lock(mm, fe->pmd, fe->address, &fe->ptl);
-	if (likely(pte_same(*fe->pte, orig_pte))) {
+	vmf->pte = pte_offset_map_lock(mm, vmf->pmd, vmf->address, &vmf->ptl);
+	if (likely(pte_same(*vmf->pte, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
 				dec_mm_counter_fast(mm,
@@ -2187,7 +2188,7 @@ static int wp_page_copy(struct fault_env *fe, pte_t orig_pte,
 		} else {
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
 		}
-		flush_cache_page(vma, fe->address, pte_pfn(orig_pte));
+		flush_cache_page(vma, vmf->address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		/*
@@ -2196,8 +2197,8 @@ static int wp_page_copy(struct fault_env *fe, pte_t orig_pte,
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush_notify(vma, fe->address, fe->pte);
-		page_add_new_anon_rmap(new_page, vma, fe->address, false);
+		ptep_clear_flush_notify(vma, vmf->address, vmf->pte);
+		page_add_new_anon_rmap(new_page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(new_page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		/*
@@ -2205,8 +2206,8 @@ static int wp_page_copy(struct fault_env *fe, pte_t orig_pte,
 		 * mmu page tables (such as kvm shadow page tables), we want the
 		 * new page to be mapped directly into the secondary page table.
 		 */
-		set_pte_at_notify(mm, fe->address, fe->pte, entry);
-		update_mmu_cache(vma, fe->address, fe->pte);
+		set_pte_at_notify(mm, vmf->address, vmf->pte, entry);
+		update_mmu_cache(vma, vmf->address, vmf->pte);
 		if (old_page) {
 			/*
 			 * Only after switching the pte to the new page may
@@ -2243,7 +2244,7 @@ static int wp_page_copy(struct fault_env *fe, pte_t orig_pte,
 	if (new_page)
 		put_page(new_page);
 
-	pte_unmap_unlock(fe->pte, fe->ptl);
+	pte_unmap_unlock(vmf->pte, vmf->ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	if (old_page) {
 		/*
@@ -2271,43 +2272,43 @@ static int wp_page_copy(struct fault_env *fe, pte_t orig_pte,
  * Handle write page faults for VM_MIXEDMAP or VM_PFNMAP for a VM_SHARED
  * mapping
  */
-static int wp_pfn_shared(struct fault_env *fe,  pte_t orig_pte)
+static int wp_pfn_shared(struct vm_fault *vmf, pte_t orig_pte)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 
 	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
-		struct vm_fault vmf = {
+		struct vm_fault vmf2 = {
 			.page = NULL,
-			.pgoff = linear_page_index(vma, fe->address),
+			.pgoff = linear_page_index(vma, vmf->address),
 			.virtual_address =
-				(void __user *)(fe->address & PAGE_MASK),
+				(void __user *)(vmf->address & PAGE_MASK),
 			.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
 		};
 		int ret;
 
-		pte_unmap_unlock(fe->pte, fe->ptl);
-		ret = vma->vm_ops->pfn_mkwrite(vma, &vmf);
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
+		ret = vma->vm_ops->pfn_mkwrite(vma, &vmf2);
 		if (ret & VM_FAULT_ERROR)
 			return ret;
-		fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-				&fe->ptl);
+		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
+				vmf->address, &vmf->ptl);
 		/*
 		 * We might have raced with another page fault while we
 		 * released the pte_offset_map_lock.
 		 */
-		if (!pte_same(*fe->pte, orig_pte)) {
-			pte_unmap_unlock(fe->pte, fe->ptl);
+		if (!pte_same(*vmf->pte, orig_pte)) {
+			pte_unmap_unlock(vmf->pte, vmf->ptl);
 			return 0;
 		}
 	}
-	return wp_page_reuse(fe, orig_pte, NULL, 0, 0);
+	return wp_page_reuse(vmf, orig_pte, NULL, 0, 0);
 }
 
-static int wp_page_shared(struct fault_env *fe, pte_t orig_pte,
+static int wp_page_shared(struct vm_fault *vmf, pte_t orig_pte,
 		struct page *old_page)
-	__releases(fe->ptl)
+	__releases(vmf->ptl)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	int page_mkwrite = 0;
 
 	get_page(old_page);
@@ -2315,8 +2316,8 @@ static int wp_page_shared(struct fault_env *fe, pte_t orig_pte,
 	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
 		int tmp;
 
-		pte_unmap_unlock(fe->pte, fe->ptl);
-		tmp = do_page_mkwrite(vma, old_page, fe->address);
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
+		tmp = do_page_mkwrite(vma, old_page, vmf->address);
 		if (unlikely(!tmp || (tmp &
 				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
 			put_page(old_page);
@@ -2328,18 +2329,18 @@ static int wp_page_shared(struct fault_env *fe, pte_t orig_pte,
 		 * they did, we just return, as we can count on the
 		 * MMU to tell us if they didn't also make it writable.
 		 */
-		fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-						 &fe->ptl);
-		if (!pte_same(*fe->pte, orig_pte)) {
+		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
+						vmf->address, &vmf->ptl);
+		if (!pte_same(*vmf->pte, orig_pte)) {
 			unlock_page(old_page);
-			pte_unmap_unlock(fe->pte, fe->ptl);
+			pte_unmap_unlock(vmf->pte, vmf->ptl);
 			put_page(old_page);
 			return 0;
 		}
 		page_mkwrite = 1;
 	}
 
-	return wp_page_reuse(fe, orig_pte, old_page, page_mkwrite, 1);
+	return wp_page_reuse(vmf, orig_pte, old_page, page_mkwrite, 1);
 }
 
 /*
@@ -2360,13 +2361,13 @@ static int wp_page_shared(struct fault_env *fe, pte_t orig_pte,
  * but allow concurrent faults), with pte both mapped and locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_wp_page(struct fault_env *fe, pte_t orig_pte)
-	__releases(fe->ptl)
+static int do_wp_page(struct vm_fault *vmf, pte_t orig_pte)
+	__releases(vmf->ptl)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	struct page *old_page;
 
-	old_page = vm_normal_page(vma, fe->address, orig_pte);
+	old_page = vm_normal_page(vma, vmf->address, orig_pte);
 	if (!old_page) {
 		/*
 		 * VM_MIXEDMAP !pfn_valid() case, or VM_SOFTDIRTY clear on a
@@ -2377,10 +2378,10 @@ static int do_wp_page(struct fault_env *fe, pte_t orig_pte)
 		 */
 		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 				     (VM_WRITE|VM_SHARED))
-			return wp_pfn_shared(fe, orig_pte);
+			return wp_pfn_shared(vmf, orig_pte);
 
-		pte_unmap_unlock(fe->pte, fe->ptl);
-		return wp_page_copy(fe, orig_pte, old_page);
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
+		return wp_page_copy(vmf, orig_pte, old_page);
 	}
 
 	/*
@@ -2391,13 +2392,13 @@ static int do_wp_page(struct fault_env *fe, pte_t orig_pte)
 		int total_mapcount;
 		if (!trylock_page(old_page)) {
 			get_page(old_page);
-			pte_unmap_unlock(fe->pte, fe->ptl);
+			pte_unmap_unlock(vmf->pte, vmf->ptl);
 			lock_page(old_page);
-			fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd,
-					fe->address, &fe->ptl);
-			if (!pte_same(*fe->pte, orig_pte)) {
+			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
+					vmf->address, &vmf->ptl);
+			if (!pte_same(*vmf->pte, orig_pte)) {
 				unlock_page(old_page);
-				pte_unmap_unlock(fe->pte, fe->ptl);
+				pte_unmap_unlock(vmf->pte, vmf->ptl);
 				put_page(old_page);
 				return 0;
 			}
@@ -2415,12 +2416,12 @@ static int do_wp_page(struct fault_env *fe, pte_t orig_pte)
 				page_move_anon_rmap(old_page, vma);
 			}
 			unlock_page(old_page);
-			return wp_page_reuse(fe, orig_pte, old_page, 0, 0);
+			return wp_page_reuse(vmf, orig_pte, old_page, 0, 0);
 		}
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
-		return wp_page_shared(fe, orig_pte, old_page);
+		return wp_page_shared(vmf, orig_pte, old_page);
 	}
 
 	/*
@@ -2428,8 +2429,8 @@ static int do_wp_page(struct fault_env *fe, pte_t orig_pte)
 	 */
 	get_page(old_page);
 
-	pte_unmap_unlock(fe->pte, fe->ptl);
-	return wp_page_copy(fe, orig_pte, old_page);
+	pte_unmap_unlock(vmf->pte, vmf->ptl);
+	return wp_page_copy(vmf, orig_pte, old_page);
 }
 
 static void unmap_mapping_range_vma(struct vm_area_struct *vma,
@@ -2517,9 +2518,9 @@ EXPORT_SYMBOL(unmap_mapping_range);
  * We return with the mmap_sem locked or unlocked in the same cases
  * as does filemap_fault().
  */
-int do_swap_page(struct fault_env *fe, pte_t orig_pte)
+int do_swap_page(struct vm_fault *vmf, pte_t orig_pte)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	struct page *page, *swapcache;
 	struct mem_cgroup *memcg;
 	swp_entry_t entry;
@@ -2528,17 +2529,18 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	int exclusive = 0;
 	int ret = 0;
 
-	if (!pte_unmap_same(vma->vm_mm, fe->pmd, fe->pte, orig_pte))
+	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, orig_pte))
 		goto out;
 
 	entry = pte_to_swp_entry(orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
-			migration_entry_wait(vma->vm_mm, fe->pmd, fe->address);
+			migration_entry_wait(vma->vm_mm, vmf->pmd,
+					     vmf->address);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
 		} else {
-			print_bad_pte(vma, fe->address, orig_pte, NULL);
+			print_bad_pte(vma, vmf->address, orig_pte, NULL);
 			ret = VM_FAULT_SIGBUS;
 		}
 		goto out;
@@ -2546,16 +2548,16 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
 	page = lookup_swap_cache(entry);
 	if (!page) {
-		page = swapin_readahead(entry,
-					GFP_HIGHUSER_MOVABLE, vma, fe->address);
+		page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE, vma,
+					vmf->address);
 		if (!page) {
 			/*
 			 * Back out if somebody else faulted in this pte
 			 * while we released the pte lock.
 			 */
-			fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd,
-					fe->address, &fe->ptl);
-			if (likely(pte_same(*fe->pte, orig_pte)))
+			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
+					vmf->address, &vmf->ptl);
+			if (likely(pte_same(*vmf->pte, orig_pte)))
 				ret = VM_FAULT_OOM;
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 			goto unlock;
@@ -2577,7 +2579,7 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	}
 
 	swapcache = page;
-	locked = lock_page_or_retry(page, vma->vm_mm, fe->flags);
+	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags);
 
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 	if (!locked) {
@@ -2594,7 +2596,7 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	if (unlikely(!PageSwapCache(page) || page_private(page) != entry.val))
 		goto out_page;
 
-	page = ksm_might_need_to_copy(page, vma, fe->address);
+	page = ksm_might_need_to_copy(page, vma, vmf->address);
 	if (unlikely(!page)) {
 		ret = VM_FAULT_OOM;
 		page = swapcache;
@@ -2610,9 +2612,9 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	/*
 	 * Back out if somebody else already faulted in this pte.
 	 */
-	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-			&fe->ptl);
-	if (unlikely(!pte_same(*fe->pte, orig_pte)))
+	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
+			&vmf->ptl);
+	if (unlikely(!pte_same(*vmf->pte, orig_pte)))
 		goto out_nomap;
 
 	if (unlikely(!PageUptodate(page))) {
@@ -2633,22 +2635,22 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
 	pte = mk_pte(page, vma->vm_page_prot);
-	if ((fe->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
+	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
-		fe->flags &= ~FAULT_FLAG_WRITE;
+		vmf->flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = RMAP_EXCLUSIVE;
 	}
 	flush_icache_page(vma, page);
 	if (pte_swp_soft_dirty(orig_pte))
 		pte = pte_mksoft_dirty(pte);
-	set_pte_at(vma->vm_mm, fe->address, fe->pte, pte);
+	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
 	if (page == swapcache) {
-		do_page_add_anon_rmap(page, vma, fe->address, exclusive);
+		do_page_add_anon_rmap(page, vma, vmf->address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true, false);
 		activate_page(page);
 	} else { /* ksm created a completely new copy */
-		page_add_new_anon_rmap(page, vma, fe->address, false);
+		page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	}
@@ -2671,22 +2673,22 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 		put_page(swapcache);
 	}
 
-	if (fe->flags & FAULT_FLAG_WRITE) {
-		ret |= do_wp_page(fe, pte);
+	if (vmf->flags & FAULT_FLAG_WRITE) {
+		ret |= do_wp_page(vmf, pte);
 		if (ret & VM_FAULT_ERROR)
 			ret &= VM_FAULT_ERROR;
 		goto out;
 	}
 
 	/* No need to invalidate - it was non-present before */
-	update_mmu_cache(vma, fe->address, fe->pte);
+	update_mmu_cache(vma, vmf->address, vmf->pte);
 unlock:
-	pte_unmap_unlock(fe->pte, fe->ptl);
+	pte_unmap_unlock(vmf->pte, vmf->ptl);
 out:
 	return ret;
 out_nomap:
 	mem_cgroup_cancel_charge(page, memcg, false);
-	pte_unmap_unlock(fe->pte, fe->ptl);
+	pte_unmap_unlock(vmf->pte, vmf->ptl);
 out_page:
 	unlock_page(page);
 out_release:
@@ -2737,9 +2739,9 @@ static inline int check_stack_guard_page(struct vm_area_struct *vma, unsigned lo
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_anonymous_page(struct fault_env *fe)
+static int do_anonymous_page(struct vm_fault *vmf)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	struct mem_cgroup *memcg;
 	struct page *page;
 	pte_t entry;
@@ -2749,7 +2751,7 @@ static int do_anonymous_page(struct fault_env *fe)
 		return VM_FAULT_SIGBUS;
 
 	/* Check if we need to add a guard page to the stack */
-	if (check_stack_guard_page(vma, fe->address) < 0)
+	if (check_stack_guard_page(vma, vmf->address) < 0)
 		return VM_FAULT_SIGSEGV;
 
 	/*
@@ -2762,26 +2764,26 @@ static int do_anonymous_page(struct fault_env *fe)
 	 *
 	 * Here we only have down_read(mmap_sem).
 	 */
-	if (pte_alloc(vma->vm_mm, fe->pmd, fe->address))
+	if (pte_alloc(vma->vm_mm, vmf->pmd, vmf->address))
 		return VM_FAULT_OOM;
 
 	/* See the comment in pte_alloc_one_map() */
-	if (unlikely(pmd_trans_unstable(fe->pmd)))
+	if (unlikely(pmd_trans_unstable(vmf->pmd)))
 		return 0;
 
 	/* Use the zero-page for reads */
-	if (!(fe->flags & FAULT_FLAG_WRITE) &&
+	if (!(vmf->flags & FAULT_FLAG_WRITE) &&
 			!mm_forbids_zeropage(vma->vm_mm)) {
-		entry = pte_mkspecial(pfn_pte(my_zero_pfn(fe->address),
+		entry = pte_mkspecial(pfn_pte(my_zero_pfn(vmf->address),
 						vma->vm_page_prot));
-		fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-				&fe->ptl);
-		if (!pte_none(*fe->pte))
+		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
+				vmf->address, &vmf->ptl);
+		if (!pte_none(*vmf->pte))
 			goto unlock;
 		/* Deliver the page fault to userland, check inside PT lock */
 		if (userfaultfd_missing(vma)) {
-			pte_unmap_unlock(fe->pte, fe->ptl);
-			return handle_userfault(fe, VM_UFFD_MISSING);
+			pte_unmap_unlock(vmf->pte, vmf->ptl);
+			return handle_userfault(vmf, VM_UFFD_MISSING);
 		}
 		goto setpte;
 	}
@@ -2789,7 +2791,7 @@ static int do_anonymous_page(struct fault_env *fe)
 	/* Allocate our own private page. */
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
-	page = alloc_zeroed_user_highpage_movable(vma, fe->address);
+	page = alloc_zeroed_user_highpage_movable(vma, vmf->address);
 	if (!page)
 		goto oom;
 
@@ -2807,30 +2809,30 @@ static int do_anonymous_page(struct fault_env *fe)
 	if (vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
-	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-			&fe->ptl);
-	if (!pte_none(*fe->pte))
+	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
+			&vmf->ptl);
+	if (!pte_none(*vmf->pte))
 		goto release;
 
 	/* Deliver the page fault to userland, check inside PT lock */
 	if (userfaultfd_missing(vma)) {
-		pte_unmap_unlock(fe->pte, fe->ptl);
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		mem_cgroup_cancel_charge(page, memcg, false);
 		put_page(page);
-		return handle_userfault(fe, VM_UFFD_MISSING);
+		return handle_userfault(vmf, VM_UFFD_MISSING);
 	}
 
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(page, vma, fe->address, false);
+	page_add_new_anon_rmap(page, vma, vmf->address, false);
 	mem_cgroup_commit_charge(page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(page, vma);
 setpte:
-	set_pte_at(vma->vm_mm, fe->address, fe->pte, entry);
+	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, entry);
 
 	/* No need to invalidate - it was non-present before */
-	update_mmu_cache(vma, fe->address, fe->pte);
+	update_mmu_cache(vma, vmf->address, vmf->pte);
 unlock:
-	pte_unmap_unlock(fe->pte, fe->ptl);
+	pte_unmap_unlock(vmf->pte, vmf->ptl);
 	return 0;
 release:
 	mem_cgroup_cancel_charge(page, memcg, false);
@@ -2847,62 +2849,62 @@ static int do_anonymous_page(struct fault_env *fe)
  * released depending on flags and vma->vm_ops->fault() return value.
  * See filemap_fault() and __lock_page_retry().
  */
-static int __do_fault(struct fault_env *fe, pgoff_t pgoff,
+static int __do_fault(struct vm_fault *vmf, pgoff_t pgoff,
 		struct page *cow_page, struct page **page, void **entry)
 {
-	struct vm_area_struct *vma = fe->vma;
-	struct vm_fault vmf;
+	struct vm_area_struct *vma = vmf->vma;
+	struct vm_fault vmf2;
 	int ret;
 
-	vmf.virtual_address = (void __user *)(fe->address & PAGE_MASK);
-	vmf.pgoff = pgoff;
-	vmf.flags = fe->flags;
-	vmf.page = NULL;
-	vmf.gfp_mask = __get_fault_gfp_mask(vma);
-	vmf.cow_page = cow_page;
+	vmf2.virtual_address = (void __user *)(vmf->address & PAGE_MASK);
+	vmf2.pgoff = pgoff;
+	vmf2.flags = vmf->flags;
+	vmf2.page = NULL;
+	vmf2.gfp_mask = __get_fault_gfp_mask(vma);
+	vmf2.cow_page = cow_page;
 
-	ret = vma->vm_ops->fault(vma, &vmf);
+	ret = vma->vm_ops->fault(vma, &vmf2);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 	if (ret & VM_FAULT_DAX_LOCKED) {
-		*entry = vmf.entry;
+		*entry = vmf2.entry;
 		return ret;
 	}
 
-	if (unlikely(PageHWPoison(vmf.page))) {
+	if (unlikely(PageHWPoison(vmf2.page))) {
 		if (ret & VM_FAULT_LOCKED)
-			unlock_page(vmf.page);
-		put_page(vmf.page);
+			unlock_page(vmf2.page);
+		put_page(vmf2.page);
 		return VM_FAULT_HWPOISON;
 	}
 
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
-		lock_page(vmf.page);
+		lock_page(vmf2.page);
 	else
-		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
+		VM_BUG_ON_PAGE(!PageLocked(vmf2.page), vmf2.page);
 
-	*page = vmf.page;
+	*page = vmf2.page;
 	return ret;
 }
 
-static int pte_alloc_one_map(struct fault_env *fe)
+static int pte_alloc_one_map(struct vm_fault *vmf)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 
-	if (!pmd_none(*fe->pmd))
+	if (!pmd_none(*vmf->pmd))
 		goto map_pte;
-	if (fe->prealloc_pte) {
-		fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
-		if (unlikely(!pmd_none(*fe->pmd))) {
-			spin_unlock(fe->ptl);
+	if (vmf->prealloc_pte) {
+		vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
+		if (unlikely(!pmd_none(*vmf->pmd))) {
+			spin_unlock(vmf->ptl);
 			goto map_pte;
 		}
 
 		atomic_long_inc(&vma->vm_mm->nr_ptes);
-		pmd_populate(vma->vm_mm, fe->pmd, fe->prealloc_pte);
-		spin_unlock(fe->ptl);
-		fe->prealloc_pte = 0;
-	} else if (unlikely(pte_alloc(vma->vm_mm, fe->pmd, fe->address))) {
+		pmd_populate(vma->vm_mm, vmf->pmd, vmf->prealloc_pte);
+		spin_unlock(vmf->ptl);
+		vmf->prealloc_pte = 0;
+	} else if (unlikely(pte_alloc(vma->vm_mm, vmf->pmd, vmf->address))) {
 		return VM_FAULT_OOM;
 	}
 map_pte:
@@ -2917,11 +2919,11 @@ static int pte_alloc_one_map(struct fault_env *fe)
 	 * through an atomic read in C, which is what pmd_trans_unstable()
 	 * provides.
 	 */
-	if (pmd_trans_unstable(fe->pmd) || pmd_devmap(*fe->pmd))
+	if (pmd_trans_unstable(vmf->pmd) || pmd_devmap(*vmf->pmd))
 		return VM_FAULT_NOPAGE;
 
-	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-			&fe->ptl);
+	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
+			&vmf->ptl);
 	return 0;
 }
 
@@ -2939,11 +2941,11 @@ static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
 	return true;
 }
 
-static int do_set_pmd(struct fault_env *fe, struct page *page)
+static int do_set_pmd(struct vm_fault *vmf, struct page *page)
 {
-	struct vm_area_struct *vma = fe->vma;
-	bool write = fe->flags & FAULT_FLAG_WRITE;
-	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
+	struct vm_area_struct *vma = vmf->vma;
+	bool write = vmf->flags & FAULT_FLAG_WRITE;
+	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 	pmd_t entry;
 	int i, ret;
 
@@ -2953,8 +2955,8 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
 	ret = VM_FAULT_FALLBACK;
 	page = compound_head(page);
 
-	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
-	if (unlikely(!pmd_none(*fe->pmd)))
+	vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
+	if (unlikely(!pmd_none(*vmf->pmd)))
 		goto out;
 
 	for (i = 0; i < HPAGE_PMD_NR; i++)
@@ -2967,19 +2969,19 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
 	add_mm_counter(vma->vm_mm, MM_FILEPAGES, HPAGE_PMD_NR);
 	page_add_file_rmap(page, true);
 
-	set_pmd_at(vma->vm_mm, haddr, fe->pmd, entry);
+	set_pmd_at(vma->vm_mm, haddr, vmf->pmd, entry);
 
-	update_mmu_cache_pmd(vma, haddr, fe->pmd);
+	update_mmu_cache_pmd(vma, haddr, vmf->pmd);
 
 	/* fault is handled */
 	ret = 0;
 	count_vm_event(THP_FILE_MAPPED);
 out:
-	spin_unlock(fe->ptl);
+	spin_unlock(vmf->ptl);
 	return ret;
 }
 #else
-static int do_set_pmd(struct fault_env *fe, struct page *page)
+static int do_set_pmd(struct vm_fault *vmf, struct page *page)
 {
 	BUILD_BUG();
 	return 0;
@@ -2990,41 +2992,42 @@ static int do_set_pmd(struct fault_env *fe, struct page *page)
  * alloc_set_pte - setup new PTE entry for given page and add reverse page
  * mapping. If needed, the fucntion allocates page table or use pre-allocated.
  *
- * @fe: fault environment
+ * @vmf: fault environment
  * @memcg: memcg to charge page (only for private mappings)
  * @page: page to map
  *
- * Caller must take care of unlocking fe->ptl, if fe->pte is non-NULL on return.
+ * Caller must take care of unlocking vmf->ptl, if vmf->pte is non-NULL on
+ * return.
  *
  * Target users are page handler itself and implementations of
  * vm_ops->map_pages.
  */
-int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
+int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		struct page *page)
 {
-	struct vm_area_struct *vma = fe->vma;
-	bool write = fe->flags & FAULT_FLAG_WRITE;
+	struct vm_area_struct *vma = vmf->vma;
+	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	pte_t entry;
 	int ret;
 
-	if (pmd_none(*fe->pmd) && PageTransCompound(page) &&
+	if (pmd_none(*vmf->pmd) && PageTransCompound(page) &&
 			IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE)) {
 		/* THP on COW? */
 		VM_BUG_ON_PAGE(memcg, page);
 
-		ret = do_set_pmd(fe, page);
+		ret = do_set_pmd(vmf, page);
 		if (ret != VM_FAULT_FALLBACK)
 			return ret;
 	}
 
-	if (!fe->pte) {
-		ret = pte_alloc_one_map(fe);
+	if (!vmf->pte) {
+		ret = pte_alloc_one_map(vmf);
 		if (ret)
 			return ret;
 	}
 
 	/* Re-check under ptl */
-	if (unlikely(!pte_none(*fe->pte)))
+	if (unlikely(!pte_none(*vmf->pte)))
 		return VM_FAULT_NOPAGE;
 
 	flush_icache_page(vma, page);
@@ -3034,17 +3037,17 @@ int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
 	/* copy-on-write page */
 	if (write && !(vma->vm_flags & VM_SHARED)) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-		page_add_new_anon_rmap(page, vma, fe->address, false);
+		page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
 		page_add_file_rmap(page, false);
 	}
-	set_pte_at(vma->vm_mm, fe->address, fe->pte, entry);
+	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, entry);
 
 	/* no need to invalidate: a not-present page won't be cached */
-	update_mmu_cache(vma, fe->address, fe->pte);
+	update_mmu_cache(vma, vmf->address, vmf->pte);
 
 	return 0;
 }
@@ -3113,17 +3116,17 @@ late_initcall(fault_around_debugfs);
  * fault_around_pages() value (and therefore to page order).  This way it's
  * easier to guarantee that we don't cross page table boundaries.
  */
-static int do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
+static int do_fault_around(struct vm_fault *vmf, pgoff_t start_pgoff)
 {
-	unsigned long address = fe->address, nr_pages, mask;
+	unsigned long address = vmf->address, nr_pages, mask;
 	pgoff_t end_pgoff;
 	int off, ret = 0;
 
 	nr_pages = READ_ONCE(fault_around_bytes) >> PAGE_SHIFT;
 	mask = ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
 
-	fe->address = max(address & mask, fe->vma->vm_start);
-	off = ((address - fe->address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
+	vmf->address = max(address & mask, vmf->vma->vm_start);
+	off = ((address - vmf->address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
 	start_pgoff -= off;
 
 	/*
@@ -3131,49 +3134,51 @@ static int do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
 	 *  or fault_around_pages() from start_pgoff, depending what is nearest.
 	 */
 	end_pgoff = start_pgoff -
-		((fe->address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
+		((vmf->address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
 		PTRS_PER_PTE - 1;
-	end_pgoff = min3(end_pgoff, vma_pages(fe->vma) + fe->vma->vm_pgoff - 1,
+	end_pgoff = min3(end_pgoff,
+			vma_pages(vmf->vma) + vmf->vma->vm_pgoff - 1,
 			start_pgoff + nr_pages - 1);
 
-	if (pmd_none(*fe->pmd)) {
-		fe->prealloc_pte = pte_alloc_one(fe->vma->vm_mm, fe->address);
-		if (!fe->prealloc_pte)
+	if (pmd_none(*vmf->pmd)) {
+		vmf->prealloc_pte = pte_alloc_one(vmf->vma->vm_mm,
+						  vmf->address);
+		if (!vmf->prealloc_pte)
 			goto out;
 		smp_wmb(); /* See comment in __pte_alloc() */
 	}
 
-	fe->vma->vm_ops->map_pages(fe, start_pgoff, end_pgoff);
+	vmf->vma->vm_ops->map_pages(vmf, start_pgoff, end_pgoff);
 
 	/* preallocated pagetable is unused: free it */
-	if (fe->prealloc_pte) {
-		pte_free(fe->vma->vm_mm, fe->prealloc_pte);
-		fe->prealloc_pte = 0;
+	if (vmf->prealloc_pte) {
+		pte_free(vmf->vma->vm_mm, vmf->prealloc_pte);
+		vmf->prealloc_pte = 0;
 	}
 	/* Huge page is mapped? Page fault is solved */
-	if (pmd_trans_huge(*fe->pmd)) {
+	if (pmd_trans_huge(*vmf->pmd)) {
 		ret = VM_FAULT_NOPAGE;
 		goto out;
 	}
 
 	/* ->map_pages() haven't done anything useful. Cold page cache? */
-	if (!fe->pte)
+	if (!vmf->pte)
 		goto out;
 
 	/* check if the page fault is solved */
-	fe->pte -= (fe->address >> PAGE_SHIFT) - (address >> PAGE_SHIFT);
-	if (!pte_none(*fe->pte))
+	vmf->pte -= (vmf->address >> PAGE_SHIFT) - (address >> PAGE_SHIFT);
+	if (!pte_none(*vmf->pte))
 		ret = VM_FAULT_NOPAGE;
-	pte_unmap_unlock(fe->pte, fe->ptl);
+	pte_unmap_unlock(vmf->pte, vmf->ptl);
 out:
-	fe->address = address;
-	fe->pte = NULL;
+	vmf->address = address;
+	vmf->pte = NULL;
 	return ret;
 }
 
-static int do_read_fault(struct fault_env *fe, pgoff_t pgoff)
+static int do_read_fault(struct vm_fault *vmf, pgoff_t pgoff)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	struct page *fault_page;
 	int ret = 0;
 
@@ -3183,27 +3188,27 @@ static int do_read_fault(struct fault_env *fe, pgoff_t pgoff)
 	 * something).
 	 */
 	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
-		ret = do_fault_around(fe, pgoff);
+		ret = do_fault_around(vmf, pgoff);
 		if (ret)
 			return ret;
 	}
 
-	ret = __do_fault(fe, pgoff, NULL, &fault_page, NULL);
+	ret = __do_fault(vmf, pgoff, NULL, &fault_page, NULL);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
-	ret |= alloc_set_pte(fe, NULL, fault_page);
-	if (fe->pte)
-		pte_unmap_unlock(fe->pte, fe->ptl);
+	ret |= alloc_set_pte(vmf, NULL, fault_page);
+	if (vmf->pte)
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
 	unlock_page(fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		put_page(fault_page);
 	return ret;
 }
 
-static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff)
+static int do_cow_fault(struct vm_fault *vmf, pgoff_t pgoff)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	struct page *fault_page, *new_page;
 	void *fault_entry;
 	struct mem_cgroup *memcg;
@@ -3212,7 +3217,7 @@ static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff)
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
 
-	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, fe->address);
+	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vmf->address);
 	if (!new_page)
 		return VM_FAULT_OOM;
 
@@ -3222,17 +3227,17 @@ static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff)
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(fe, pgoff, new_page, &fault_page, &fault_entry);
+	ret = __do_fault(vmf, pgoff, new_page, &fault_page, &fault_entry);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
 	if (!(ret & VM_FAULT_DAX_LOCKED))
-		copy_user_highpage(new_page, fault_page, fe->address, vma);
+		copy_user_highpage(new_page, fault_page, vmf->address, vma);
 	__SetPageUptodate(new_page);
 
-	ret |= alloc_set_pte(fe, memcg, new_page);
-	if (fe->pte)
-		pte_unmap_unlock(fe->pte, fe->ptl);
+	ret |= alloc_set_pte(vmf, memcg, new_page);
+	if (vmf->pte)
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
 	if (!(ret & VM_FAULT_DAX_LOCKED)) {
 		unlock_page(fault_page);
 		put_page(fault_page);
@@ -3248,15 +3253,15 @@ static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff)
 	return ret;
 }
 
-static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff)
+static int do_shared_fault(struct vm_fault *vmf, pgoff_t pgoff)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	struct page *fault_page;
 	struct address_space *mapping;
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(fe, pgoff, NULL, &fault_page, NULL);
+	ret = __do_fault(vmf, pgoff, NULL, &fault_page, NULL);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -3266,7 +3271,7 @@ static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff)
 	 */
 	if (vma->vm_ops->page_mkwrite) {
 		unlock_page(fault_page);
-		tmp = do_page_mkwrite(vma, fault_page, fe->address);
+		tmp = do_page_mkwrite(vma, fault_page, vmf->address);
 		if (unlikely(!tmp ||
 				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
 			put_page(fault_page);
@@ -3274,9 +3279,9 @@ static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff)
 		}
 	}
 
-	ret |= alloc_set_pte(fe, NULL, fault_page);
-	if (fe->pte)
-		pte_unmap_unlock(fe->pte, fe->ptl);
+	ret |= alloc_set_pte(vmf, NULL, fault_page);
+	if (vmf->pte)
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
 					VM_FAULT_RETRY))) {
 		unlock_page(fault_page);
@@ -3314,19 +3319,19 @@ static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff)
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int do_fault(struct fault_env *fe)
+static int do_fault(struct vm_fault *vmf)
 {
-	struct vm_area_struct *vma = fe->vma;
-	pgoff_t pgoff = linear_page_index(vma, fe->address);
+	struct vm_area_struct *vma = vmf->vma;
+	pgoff_t pgoff = linear_page_index(vma, vmf->address);
 
 	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
 	if (!vma->vm_ops->fault)
 		return VM_FAULT_SIGBUS;
-	if (!(fe->flags & FAULT_FLAG_WRITE))
-		return do_read_fault(fe, pgoff);
+	if (!(vmf->flags & FAULT_FLAG_WRITE))
+		return do_read_fault(vmf, pgoff);
 	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(fe, pgoff);
-	return do_shared_fault(fe, pgoff);
+		return do_cow_fault(vmf, pgoff);
+	return do_shared_fault(vmf, pgoff);
 }
 
 static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
@@ -3344,9 +3349,9 @@ static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 	return mpol_misplaced(page, vma, addr);
 }
 
-static int do_numa_page(struct fault_env *fe, pte_t pte)
+static int do_numa_page(struct vm_fault *vmf, pte_t pte)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL;
 	int page_nid = -1;
 	int last_cpupid;
@@ -3364,10 +3369,10 @@ static int do_numa_page(struct fault_env *fe, pte_t pte)
 	* page table entry is not accessible, so there would be no
 	* concurrent hardware modifications to the PTE.
 	*/
-	fe->ptl = pte_lockptr(vma->vm_mm, fe->pmd);
-	spin_lock(fe->ptl);
-	if (unlikely(!pte_same(*fe->pte, pte))) {
-		pte_unmap_unlock(fe->pte, fe->ptl);
+	vmf->ptl = pte_lockptr(vma->vm_mm, vmf->pmd);
+	spin_lock(vmf->ptl);
+	if (unlikely(!pte_same(*vmf->pte, pte))) {
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		goto out;
 	}
 
@@ -3376,18 +3381,18 @@ static int do_numa_page(struct fault_env *fe, pte_t pte)
 	pte = pte_mkyoung(pte);
 	if (was_writable)
 		pte = pte_mkwrite(pte);
-	set_pte_at(vma->vm_mm, fe->address, fe->pte, pte);
-	update_mmu_cache(vma, fe->address, fe->pte);
+	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
+	update_mmu_cache(vma, vmf->address, vmf->pte);
 
-	page = vm_normal_page(vma, fe->address, pte);
+	page = vm_normal_page(vma, vmf->address, pte);
 	if (!page) {
-		pte_unmap_unlock(fe->pte, fe->ptl);
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		return 0;
 	}
 
 	/* TODO: handle PTE-mapped THP */
 	if (PageCompound(page)) {
-		pte_unmap_unlock(fe->pte, fe->ptl);
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		return 0;
 	}
 
@@ -3411,9 +3416,9 @@ static int do_numa_page(struct fault_env *fe, pte_t pte)
 
 	last_cpupid = page_cpupid_last(page);
 	page_nid = page_to_nid(page);
-	target_nid = numa_migrate_prep(page, vma, fe->address, page_nid,
+	target_nid = numa_migrate_prep(page, vma, vmf->address, page_nid,
 			&flags);
-	pte_unmap_unlock(fe->pte, fe->ptl);
+	pte_unmap_unlock(vmf->pte, vmf->ptl);
 	if (target_nid == -1) {
 		put_page(page);
 		goto out;
@@ -3433,28 +3438,28 @@ static int do_numa_page(struct fault_env *fe, pte_t pte)
 	return 0;
 }
 
-static int create_huge_pmd(struct fault_env *fe)
+static int create_huge_pmd(struct vm_fault *vmf)
 {
-	struct vm_area_struct *vma = fe->vma;
+	struct vm_area_struct *vma = vmf->vma;
 	if (vma_is_anonymous(vma))
-		return do_huge_pmd_anonymous_page(fe);
+		return do_huge_pmd_anonymous_page(vmf);
 	if (vma->vm_ops->pmd_fault)
-		return vma->vm_ops->pmd_fault(vma, fe->address, fe->pmd,
-				fe->flags);
+		return vma->vm_ops->pmd_fault(vma, vmf->address, vmf->pmd,
+				vmf->flags);
 	return VM_FAULT_FALLBACK;
 }
 
-static int wp_huge_pmd(struct fault_env *fe, pmd_t orig_pmd)
+static int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 {
-	if (vma_is_anonymous(fe->vma))
-		return do_huge_pmd_wp_page(fe, orig_pmd);
-	if (fe->vma->vm_ops->pmd_fault)
-		return fe->vma->vm_ops->pmd_fault(fe->vma, fe->address, fe->pmd,
-				fe->flags);
+	if (vma_is_anonymous(vmf->vma))
+		return do_huge_pmd_wp_page(vmf, orig_pmd);
+	if (vmf->vma->vm_ops->pmd_fault)
+		return vmf->vma->vm_ops->pmd_fault(vmf->vma, vmf->address,
+				vmf->pmd, vmf->flags);
 
 	/* COW handled on pte level: split pmd */
-	VM_BUG_ON_VMA(fe->vma->vm_flags & VM_SHARED, fe->vma);
-	split_huge_pmd(fe->vma, fe->pmd, fe->address);
+	VM_BUG_ON_VMA(vmf->vma->vm_flags & VM_SHARED, vmf->vma);
+	split_huge_pmd(vmf->vma, vmf->pmd, vmf->address);
 
 	return VM_FAULT_FALLBACK;
 }
@@ -3479,21 +3484,21 @@ static inline bool vma_is_accessible(struct vm_area_struct *vma)
  * The mmap_sem may have been released depending on flags and our return value.
  * See filemap_fault() and __lock_page_or_retry().
  */
-static int handle_pte_fault(struct fault_env *fe)
+static int handle_pte_fault(struct vm_fault *vmf)
 {
 	pte_t entry;
 
-	if (unlikely(pmd_none(*fe->pmd))) {
+	if (unlikely(pmd_none(*vmf->pmd))) {
 		/*
 		 * Leave __pte_alloc() until later: because vm_ops->fault may
 		 * want to allocate huge page, and if we expose page table
 		 * for an instant, it will be difficult to retract from
 		 * concurrent faults and from rmap lookups.
 		 */
-		fe->pte = NULL;
+		vmf->pte = NULL;
 	} else {
 		/* See comment in pte_alloc_one_map() */
-		if (pmd_trans_unstable(fe->pmd) || pmd_devmap(*fe->pmd))
+		if (pmd_trans_unstable(vmf->pmd) || pmd_devmap(*vmf->pmd))
 			return 0;
 		/*
 		 * A regular pmd is established and it can't morph into a huge
@@ -3501,9 +3506,9 @@ static int handle_pte_fault(struct fault_env *fe)
 		 * mmap_sem read mode and khugepaged takes it in write mode.
 		 * So now it's safe to run pte_offset_map().
 		 */
-		fe->pte = pte_offset_map(fe->pmd, fe->address);
+		vmf->pte = pte_offset_map(vmf->pmd, vmf->address);
 
-		entry = *fe->pte;
+		entry = *vmf->pte;
 
 		/*
 		 * some architectures can have larger ptes than wordsize,
@@ -3515,37 +3520,37 @@ static int handle_pte_fault(struct fault_env *fe)
 		 */
 		barrier();
 		if (pte_none(entry)) {
-			pte_unmap(fe->pte);
-			fe->pte = NULL;
+			pte_unmap(vmf->pte);
+			vmf->pte = NULL;
 		}
 	}
 
-	if (!fe->pte) {
-		if (vma_is_anonymous(fe->vma))
-			return do_anonymous_page(fe);
+	if (!vmf->pte) {
+		if (vma_is_anonymous(vmf->vma))
+			return do_anonymous_page(vmf);
 		else
-			return do_fault(fe);
+			return do_fault(vmf);
 	}
 
 	if (!pte_present(entry))
-		return do_swap_page(fe, entry);
+		return do_swap_page(vmf, entry);
 
-	if (pte_protnone(entry) && vma_is_accessible(fe->vma))
-		return do_numa_page(fe, entry);
+	if (pte_protnone(entry) && vma_is_accessible(vmf->vma))
+		return do_numa_page(vmf, entry);
 
-	fe->ptl = pte_lockptr(fe->vma->vm_mm, fe->pmd);
-	spin_lock(fe->ptl);
-	if (unlikely(!pte_same(*fe->pte, entry)))
+	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
+	spin_lock(vmf->ptl);
+	if (unlikely(!pte_same(*vmf->pte, entry)))
 		goto unlock;
-	if (fe->flags & FAULT_FLAG_WRITE) {
+	if (vmf->flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
-			return do_wp_page(fe, entry);
+			return do_wp_page(vmf, entry);
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
-	if (ptep_set_access_flags(fe->vma, fe->address, fe->pte, entry,
-				fe->flags & FAULT_FLAG_WRITE)) {
-		update_mmu_cache(fe->vma, fe->address, fe->pte);
+	if (ptep_set_access_flags(vmf->vma, vmf->address, vmf->pte, entry,
+				vmf->flags & FAULT_FLAG_WRITE)) {
+		update_mmu_cache(vmf->vma, vmf->address, vmf->pte);
 	} else {
 		/*
 		 * This is needed only for protection faults but the arch code
@@ -3553,11 +3558,11 @@ static int handle_pte_fault(struct fault_env *fe)
 		 * This still avoids useless tlb flushes for .text page faults
 		 * with threads.
 		 */
-		if (fe->flags & FAULT_FLAG_WRITE)
-			flush_tlb_fix_spurious_fault(fe->vma, fe->address);
+		if (vmf->flags & FAULT_FLAG_WRITE)
+			flush_tlb_fix_spurious_fault(vmf->vma, vmf->address);
 	}
 unlock:
-	pte_unmap_unlock(fe->pte, fe->ptl);
+	pte_unmap_unlock(vmf->pte, vmf->ptl);
 	return 0;
 }
 
@@ -3570,7 +3575,7 @@ static int handle_pte_fault(struct fault_env *fe)
 static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		unsigned int flags)
 {
-	struct fault_env fe = {
+	struct vm_fault vmf = {
 		.vma = vma,
 		.address = address,
 		.flags = flags,
@@ -3583,35 +3588,35 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	pud = pud_alloc(mm, pgd, address);
 	if (!pud)
 		return VM_FAULT_OOM;
-	fe.pmd = pmd_alloc(mm, pud, address);
-	if (!fe.pmd)
+	vmf.pmd = pmd_alloc(mm, pud, address);
+	if (!vmf.pmd)
 		return VM_FAULT_OOM;
-	if (pmd_none(*fe.pmd) && transparent_hugepage_enabled(vma)) {
-		int ret = create_huge_pmd(&fe);
+	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
+		int ret = create_huge_pmd(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
 	} else {
-		pmd_t orig_pmd = *fe.pmd;
+		pmd_t orig_pmd = *vmf.pmd;
 		int ret;
 
 		barrier();
 		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
 			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
-				return do_huge_pmd_numa_page(&fe, orig_pmd);
+				return do_huge_pmd_numa_page(&vmf, orig_pmd);
 
-			if ((fe.flags & FAULT_FLAG_WRITE) &&
+			if ((vmf.flags & FAULT_FLAG_WRITE) &&
 					!pmd_write(orig_pmd)) {
-				ret = wp_huge_pmd(&fe, orig_pmd);
+				ret = wp_huge_pmd(&vmf, orig_pmd);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
 			} else {
-				huge_pmd_set_accessed(&fe, orig_pmd);
+				huge_pmd_set_accessed(&vmf, orig_pmd);
 				return 0;
 			}
 		}
 	}
 
-	return handle_pte_fault(&fe);
+	return handle_pte_fault(&vmf);
 }
 
 /*
diff --git a/mm/nommu.c b/mm/nommu.c
index 8b8faaf2a9e9..077d0dbe4c28 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1801,7 +1801,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 }
 EXPORT_SYMBOL(filemap_fault);
 
-void filemap_map_pages(struct fault_env *fe,
+void filemap_map_pages(struct vm_fault *vmf,
 		pgoff_t start_pgoff, pgoff_t end_pgoff)
 {
 	BUG();
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
