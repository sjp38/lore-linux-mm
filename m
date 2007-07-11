Date: Wed, 11 Jul 2007 13:54:16 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/2] mm: fault feedback 2
Message-ID: <20070711115416.GC18204@wotan.suse.de>
References: <20070711115004.GA18204@wotan.suse.de> <20070711115125.GB18204@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070711115125.GB18204@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This again I'm not sure quite how it should logically be part of
the first patch or a seperate one.



--
This patch completes Linus's wish that the fault return codes be made
into bit flags, which I agree makes everything nicer. This requires
requires all handle_mm_fault callers to be modified (possibly the
modifications should go further and do things like fault accounting
in handle_mm_fault -- however that would be for another patch).

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/arch/i386/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/i386/mm/fault.c
+++ linux-2.6/arch/i386/mm/fault.c
@@ -305,6 +305,7 @@ fastcall void __kprobes do_page_fault(st
 	struct vm_area_struct * vma;
 	unsigned long address;
 	int write, si_code;
+	int fault;
 
 	/* get the address */
         address = read_cr2();
@@ -424,20 +425,18 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	switch (handle_mm_fault(mm, vma, address, write)) {
-		case VM_FAULT_MINOR:
-			tsk->min_flt++;
-			break;
-		case VM_FAULT_MAJOR:
-			tsk->maj_flt++;
-			break;
-		case VM_FAULT_SIGBUS:
-			goto do_sigbus;
-		case VM_FAULT_OOM:
+	fault = handle_mm_fault(mm, vma, address, write);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
-		default:
-			BUG();
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
+		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		tsk->maj_flt++;
+	else
+		tsk->min_flt++;
 
 	/*
 	 * Did it hit the DOS screen memory VA from vm86 mode?
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -198,25 +198,10 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
 
 
-#define FAULT_RET_NOPAGE	0x0100	/* ->fault did not return a page. This
-					 * can be used if the handler installs
-					 * their own pte.
-					 */
-#define FAULT_RET_LOCKED	0x0200	/* ->fault locked the page, caller must
-					 * unlock after installing the mapping.
-					 * This is used by pagecache in
-					 * particular, where the page lock is
-					 * used to synchronise against truncate
-					 * and invalidate. Mutually exclusive
-					 * with FAULT_RET_NOPAGE.
-					 */
-
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
- * ->fault function. The vma's ->fault is responsible for returning the
- * VM_FAULT_xxx type which occupies the lowest byte of the return code, ORed
- * with FAULT_RET_ flags that occupy the next byte and give details about
- * how the fault was handled.
+ * ->fault function. The vma's ->fault is responsible for returning a bitmask
+ * of VM_FAULT_xxx flags that give details about how the fault was handled.
  *
  * pgoff should be used in favour of virtual_address, if possible. If pgoff
  * is used, one may set VM_CAN_NONLINEAR in the vma->vm_flags to get nonlinear
@@ -228,9 +213,9 @@ struct vm_fault {
 	void __user *virtual_address;	/* Faulting virtual address */
 
 	struct page *page;		/* ->fault handlers should return a
-					 * page here, unless FAULT_RET_NOPAGE
+					 * page here, unless VM_FAULT_NOPAGE
 					 * is set (which is also implied by
-					 * VM_FAULT_OOM or SIGBUS).
+					 * VM_FAULT_ERROR).
 					 */
 };
 
@@ -713,26 +698,15 @@ static inline int page_mapped(struct pag
  * just gets major/minor fault counters bumped up.
  */
 
-/*
- * VM_FAULT_ERROR is set for the error cases, to make some tests simpler.
- */
-#define VM_FAULT_ERROR	0x20
+#define VM_FAULT_OOM	0x0001
+#define VM_FAULT_SIGBUS	0x0002
+#define VM_FAULT_MAJOR	0x0004
+#define VM_FAULT_WRITE	0x0008	/* Special case for get_user_pages */
 
-#define VM_FAULT_OOM	(0x00 | VM_FAULT_ERROR)
-#define VM_FAULT_SIGBUS	(0x01 | VM_FAULT_ERROR)
-#define VM_FAULT_MINOR	0x02
-#define VM_FAULT_MAJOR	0x03
+#define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
+#define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 
-/* 
- * Special case for get_user_pages.
- * Must be in a distinct bit from the above VM_FAULT_ flags.
- */
-#define VM_FAULT_WRITE	0x10
-
-/*
- * Mask of VM_FAULT_ flags
- */
-#define VM_FAULT_MASK	0xff
+#define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS)
 
 #define offset_in_page(p)	((unsigned long)(p) & ~PAGE_MASK)
 
@@ -818,16 +792,8 @@ extern int vmtruncate(struct inode * ino
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 
 #ifdef CONFIG_MMU
-extern int __handle_mm_fault(struct mm_struct *mm,struct vm_area_struct *vma,
+extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);
-
-static inline int handle_mm_fault(struct mm_struct *mm,
-			struct vm_area_struct *vma, unsigned long address,
-			int write_access)
-{
-	return __handle_mm_fault(mm, vma, address, write_access) &
-				(~VM_FAULT_WRITE);
-}
 #else
 static inline int handle_mm_fault(struct mm_struct *mm,
 			struct vm_area_struct *vma, unsigned long address,
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1062,31 +1062,30 @@ int get_user_pages(struct task_struct *t
 			cond_resched();
 			while (!(page = follow_page(vma, start, foll_flags))) {
 				int ret;
-				ret = __handle_mm_fault(mm, vma, start,
+				ret = handle_mm_fault(mm, vma, start,
 						foll_flags & FOLL_WRITE);
+				if (ret & VM_FAULT_ERROR) {
+					if (ret & VM_FAULT_OOM)
+						return i ? i : -ENOMEM;
+					else if (ret & VM_FAULT_SIGBUS)
+						return i ? i : -EFAULT;
+					BUG();
+				}
+				if (ret & VM_FAULT_MAJOR)
+					tsk->maj_flt++;
+				else
+					tsk->min_flt++;
+
 				/*
-				 * The VM_FAULT_WRITE bit tells us that do_wp_page has
-				 * broken COW when necessary, even if maybe_mkwrite
-				 * decided not to set pte_write. We can thus safely do
-				 * subsequent page lookups as if they were reads.
+				 * The VM_FAULT_WRITE bit tells us that
+				 * do_wp_page has broken COW when necessary,
+				 * even if maybe_mkwrite decided not to set
+				 * pte_write. We can thus safely do subsequent
+				 * page lookups as if they were reads.
 				 */
 				if (ret & VM_FAULT_WRITE)
 					foll_flags &= ~FOLL_WRITE;
-				
-				switch (ret & ~VM_FAULT_WRITE) {
-				case VM_FAULT_MINOR:
-					tsk->min_flt++;
-					break;
-				case VM_FAULT_MAJOR:
-					tsk->maj_flt++;
-					break;
-				case VM_FAULT_SIGBUS:
-					return i ? i : -EFAULT;
-				case VM_FAULT_OOM:
-					return i ? i : -ENOMEM;
-				default:
-					BUG();
-				}
+
 				cond_resched();
 			}
 			if (pages) {
@@ -1633,7 +1632,7 @@ static int do_wp_page(struct mm_struct *
 {
 	struct page *old_page, *new_page;
 	pte_t entry;
-	int reuse = 0, ret = VM_FAULT_MINOR;
+	int reuse = 0, ret = 0;
 	struct page *dirty_page = NULL;
 
 	old_page = vm_normal_page(vma, address, orig_pte);
@@ -1829,8 +1828,8 @@ static int unmap_mapping_range_vma(struc
 	/*
 	 * files that support invalidating or truncating portions of the
 	 * file from under mmaped areas must have their ->fault function
-	 * return a locked page (and FAULT_RET_LOCKED code). This provides
-	 * synchronisation against concurrent unmapping here.
+	 * return a locked page (and set VM_FAULT_LOCKED in the return).
+	 * This provides synchronisation against concurrent unmapping here.
 	 */
 
 again:
@@ -2134,7 +2133,7 @@ static int do_swap_page(struct mm_struct
 	struct page *page;
 	swp_entry_t entry;
 	pte_t pte;
-	int ret = VM_FAULT_MINOR;
+	int ret = 0;
 
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
 		goto out;
@@ -2202,8 +2201,9 @@ static int do_swap_page(struct mm_struct
 	unlock_page(page);
 
 	if (write_access) {
+		/* XXX: We could OR the do_wp_page code with this one? */
 		if (do_wp_page(mm, vma, address,
-				page_table, pmd, ptl, pte) == VM_FAULT_OOM)
+				page_table, pmd, ptl, pte) & VM_FAULT_OOM)
 			ret = VM_FAULT_OOM;
 		goto out;
 	}
@@ -2274,7 +2274,7 @@ static int do_anonymous_page(struct mm_s
 	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
-	return VM_FAULT_MINOR;
+	return 0;
 release:
 	page_cache_release(page);
 	goto unlock;
@@ -2317,11 +2317,11 @@ static int __do_fault(struct mm_struct *
 
 	if (likely(vma->vm_ops->fault)) {
 		ret = vma->vm_ops->fault(vma, &vmf);
-		if (unlikely(ret & (VM_FAULT_ERROR | FAULT_RET_NOPAGE)))
-			return (ret & VM_FAULT_MASK);
+		if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+			return ret;
 	} else {
 		/* Legacy ->nopage path */
-		ret = VM_FAULT_MINOR;
+		ret = 0;
 		vmf.page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &ret);
 		/* no page was available -- either SIGBUS or OOM */
 		if (unlikely(vmf.page == NOPAGE_SIGBUS))
@@ -2334,7 +2334,7 @@ static int __do_fault(struct mm_struct *
 	 * For consistency in subsequent calls, make the faulted page always
 	 * locked.
 	 */
-	if (unlikely(!(ret & FAULT_RET_LOCKED)))
+	if (unlikely(!(ret & VM_FAULT_LOCKED)))
 		lock_page(vmf.page);
 	else
 		VM_BUG_ON(!PageLocked(vmf.page));
@@ -2378,7 +2378,7 @@ static int __do_fault(struct mm_struct *
 				 * is better done later.
 				 */
 				if (!page->mapping) {
-					ret = VM_FAULT_MINOR;
+					ret = 0;
 					anon = 1; /* no anon but release vmf.page */
 					goto out;
 				}
@@ -2441,7 +2441,7 @@ out_unlocked:
 		put_page(dirty_page);
 	}
 
-	return (ret & VM_FAULT_MASK);
+	return ret;
 }
 
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -2480,7 +2480,6 @@ static noinline int do_no_pfn(struct mm_
 	spinlock_t *ptl;
 	pte_t entry;
 	unsigned long pfn;
-	int ret = VM_FAULT_MINOR;
 
 	pte_unmap(page_table);
 	BUG_ON(!(vma->vm_flags & VM_PFNMAP));
@@ -2492,7 +2491,7 @@ static noinline int do_no_pfn(struct mm_
 	else if (unlikely(pfn == NOPFN_SIGBUS))
 		return VM_FAULT_SIGBUS;
 	else if (unlikely(pfn == NOPFN_REFAULT))
-		return VM_FAULT_MINOR;
+		return 0;
 
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 
@@ -2504,7 +2503,7 @@ static noinline int do_no_pfn(struct mm_
 		set_pte_at(mm, address, page_table, entry);
 	}
 	pte_unmap_unlock(page_table, ptl);
-	return ret;
+	return 0;
 }
 
 /*
@@ -2525,7 +2524,7 @@ static int do_nonlinear_fault(struct mm_
 	pgoff_t pgoff;
 
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
-		return VM_FAULT_MINOR;
+		return 0;
 
 	if (unlikely(!(vma->vm_flags & VM_NONLINEAR) ||
 			!(vma->vm_flags & VM_CAN_NONLINEAR))) {
@@ -2609,13 +2608,13 @@ static inline int handle_pte_fault(struc
 	}
 unlock:
 	pte_unmap_unlock(pte, ptl);
-	return VM_FAULT_MINOR;
+	return 0;
 }
 
 /*
  * By the time we get here, we already hold the mm semaphore
  */
-int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, int write_access)
 {
 	pgd_t *pgd;
@@ -2644,7 +2643,7 @@ int __handle_mm_fault(struct mm_struct *
 	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
 }
 
-EXPORT_SYMBOL_GPL(__handle_mm_fault);
+EXPORT_SYMBOL_GPL(handle_mm_fault);
 
 #ifndef __PAGETABLE_PUD_FOLDED
 /*
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1355,9 +1355,7 @@ int filemap_fault(struct vm_area_struct 
 	struct page *page;
 	unsigned long size;
 	int did_readaround = 0;
-	int ret;
-
-	ret = VM_FAULT_MINOR;
+	int ret = 0;
 
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	if (vmf->pgoff >= size)
@@ -1441,7 +1439,7 @@ retry_find:
 	 */
 	mark_page_accessed(page);
 	vmf->page = page;
-	return ret | FAULT_RET_LOCKED;
+	return ret | VM_FAULT_LOCKED;
 
 outside_data_content:
 	/*
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -1099,7 +1099,7 @@ static int shmem_getpage(struct inode *i
 		return -EFBIG;
 
 	if (type)
-		*type = VM_FAULT_MINOR;
+		*type = 0;
 
 	/*
 	 * Normally, filepage is NULL on entry, and either found
@@ -1134,9 +1134,9 @@ repeat:
 		if (!swappage) {
 			shmem_swp_unmap(entry);
 			/* here we actually do the io */
-			if (type && *type == VM_FAULT_MINOR) {
+			if (type && !(*type & VM_FAULT_MAJOR)) {
 				__count_vm_event(PGMAJFAULT);
-				*type = VM_FAULT_MAJOR;
+				*type |= VM_FAULT_MAJOR;
 			}
 			spin_unlock(&info->lock);
 			swappage = shmem_swapin(info, swap, idx);
@@ -1319,7 +1319,7 @@ static int shmem_fault(struct vm_area_st
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
 
 	mark_page_accessed(vmf->page);
-	return ret | FAULT_RET_LOCKED;
+	return ret | VM_FAULT_LOCKED;
 }
 
 #ifdef CONFIG_NUMA
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -445,7 +445,7 @@ static int hugetlb_cow(struct mm_struct 
 	avoidcopy = (page_count(old_page) == 1);
 	if (avoidcopy) {
 		set_huge_ptep_writable(vma, address, ptep);
-		return VM_FAULT_MINOR;
+		return 0;
 	}
 
 	page_cache_get(old_page);
@@ -470,7 +470,7 @@ static int hugetlb_cow(struct mm_struct 
 	}
 	page_cache_release(new_page);
 	page_cache_release(old_page);
-	return VM_FAULT_MINOR;
+	return 0;
 }
 
 int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -527,7 +527,7 @@ retry:
 	if (idx >= size)
 		goto backout;
 
-	ret = VM_FAULT_MINOR;
+	ret = 0;
 	if (!pte_none(*ptep))
 		goto backout;
 
@@ -578,7 +578,7 @@ int hugetlb_fault(struct mm_struct *mm, 
 		return ret;
 	}
 
-	ret = VM_FAULT_MINOR;
+	ret = 0;
 
 	spin_lock(&mm->page_table_lock);
 	/* Check for a racing update before calling hugetlb_cow */
@@ -617,7 +617,7 @@ int follow_hugetlb_page(struct mm_struct
 			spin_unlock(&mm->page_table_lock);
 			ret = hugetlb_fault(mm, vma, vaddr, 0);
 			spin_lock(&mm->page_table_lock);
-			if (ret == VM_FAULT_MINOR)
+			if (!(ret & VM_FAULT_MAJOR))
 				continue;
 
 			remainder = 0;
Index: linux-2.6/arch/alpha/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/alpha/mm/fault.c
+++ linux-2.6/arch/alpha/mm/fault.c
@@ -148,21 +148,17 @@ do_page_fault(unsigned long address, uns
 	   the fault.  */
 	fault = handle_mm_fault(mm, vma, address, cause > 0);
 	up_read(&mm->mmap_sem);
-
-	switch (fault) {
-	      case VM_FAULT_MINOR:
-		current->min_flt++;
-		break;
-	      case VM_FAULT_MAJOR:
-		current->maj_flt++;
-		break;
-	      case VM_FAULT_SIGBUS:
-		goto do_sigbus;
-	      case VM_FAULT_OOM:
-		goto out_of_memory;
-	      default:
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
 		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		tsk->maj_flt++;
+	else
+		tsk->min_flt++;
 	return;
 
 	/* Something tried to access memory that isn't in our memory map.
Index: linux-2.6/arch/arm26/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/arm26/mm/fault.c
+++ linux-2.6/arch/arm26/mm/fault.c
@@ -170,20 +170,20 @@ good_area:
 	 */
 survive:
 	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, DO_COW(fsr));
-
-	/*
-	 * Handle the "normal" cases first - successful and sigbus
-	 */
-	switch (fault) {
-	case VM_FAULT_MAJOR:
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			return fault;
+		BUG();
+	}
+	if (fault & VM_FAULT_MAJOR)
 		tsk->maj_flt++;
-		return fault;
-	case VM_FAULT_MINOR:
+	else
 		tsk->min_flt++;
-	case VM_FAULT_SIGBUS:
-		return fault;
-	}
+	return fault;
 
+out_of_memory:
 	fault = -3; /* out of memory */
 	if (!is_init(tsk))
 		goto out;
@@ -225,7 +225,7 @@ int do_page_fault(unsigned long addr, un
 	/*
 	 * Handle the "normal" case first
 	 */
-	switch (fault) {
+	if (unlikely(fault & VM_FAULT_SIGBUS))
 	case VM_FAULT_MINOR:
 	case VM_FAULT_MAJOR:
 		return 0;
Index: linux-2.6/arch/powerpc/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/fault.c
+++ linux-2.6/arch/powerpc/mm/fault.c
@@ -146,7 +146,7 @@ int __kprobes do_page_fault(struct pt_re
 	struct mm_struct *mm = current->mm;
 	siginfo_t info;
 	int code = SEGV_MAPERR;
-	int is_write = 0;
+	int is_write = 0, ret;
 	int trap = TRAP(regs);
  	int is_exec = trap == 0x400;
 
@@ -331,22 +331,18 @@ good_area:
 	 * the fault.
 	 */
  survive:
-	switch (handle_mm_fault(mm, vma, address, is_write)) {
-
-	case VM_FAULT_MINOR:
-		current->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		current->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		goto do_sigbus;
-	case VM_FAULT_OOM:
-		goto out_of_memory;
-	default:
+	ret = handle_mm_fault(mm, vma, address, is_write);
+	if (unlikely(ret & VM_FAULT_ERROR)) {
+		if (ret & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (ret & VM_FAULT_SIGBUS)
+			goto do_sigbus;
 		BUG();
 	}
-
+	if (ret & VM_FAULT_MAJOR)
+		current->maj_flt++;
+	else
+		current->min_flt++;
 	up_read(&mm->mmap_sem);
 	return 0;
 
Index: linux-2.6/arch/x86_64/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/x86_64/mm/fault.c
+++ linux-2.6/arch/x86_64/mm/fault.c
@@ -307,7 +307,7 @@ asmlinkage void __kprobes do_page_fault(
 	struct vm_area_struct * vma;
 	unsigned long address;
 	const struct exception_table_entry *fixup;
-	int write;
+	int write, fault;
 	unsigned long flags;
 	siginfo_t info;
 
@@ -440,19 +440,18 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	switch (handle_mm_fault(mm, vma, address, write)) {
-	case VM_FAULT_MINOR:
-		tsk->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		tsk->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		goto do_sigbus;
-	default:
-		goto out_of_memory;
+	fault = handle_mm_fault(mm, vma, address, write);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
+		BUG();
 	}
-
+	if (fault & VM_FAULT_MAJOR)
+		tsk->maj_flt++;
+	else
+		tsk->min_flt++;
 	up_read(&mm->mmap_sem);
 	return;
 
Index: linux-2.6/fs/gfs2/ops_vm.c
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_vm.c
+++ linux-2.6/fs/gfs2/ops_vm.c
@@ -112,7 +112,7 @@ static int gfs2_sharewrite_fault(struct 
 	struct gfs2_holder i_gh;
 	int alloc_required;
 	int error;
-	int ret = VM_FAULT_MINOR;
+	int ret = 0;
 
 	error = gfs2_glock_nq_init(ip->i_gl, LM_ST_EXCLUSIVE, 0, &i_gh);
 	if (error)
@@ -132,14 +132,19 @@ static int gfs2_sharewrite_fault(struct 
 	set_bit(GFF_EXLOCK, &gf->f_flags);
 	ret = filemap_fault(vma, vmf);
 	clear_bit(GFF_EXLOCK, &gf->f_flags);
-	if (ret & (VM_FAULT_ERROR | FAULT_RET_NOPAGE))
+	if (ret & VM_FAULT_ERROR)
 		goto out_unlock;
 
 	if (alloc_required) {
 		/* XXX: do we need to drop page lock around alloc_page_backing?*/
 		error = alloc_page_backing(ip, vmf->page);
 		if (error) {
-			if (ret & FAULT_RET_LOCKED)
+			/*
+			 * VM_FAULT_LOCKED should always be the case for
+			 * filemap_fault, but it may not be in a future
+			 * implementation.
+			 */
+			if (ret & VM_FAULT_LOCKED)
 				unlock_page(vmf->page);
 			page_cache_release(vmf->page);
 			ret = VM_FAULT_OOM;
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c
+++ linux-2.6/mm/filemap_xip.c
@@ -274,7 +274,7 @@ static int xip_file_fault(struct vm_area
 out:
 	page_cache_get(page);
 	vmf->page = page;
-	return VM_FAULT_MINOR;
+	return 0;
 }
 
 static struct vm_operations_struct xip_file_vm_ops = {
Index: linux-2.6/arch/arm/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/fault.c
+++ linux-2.6/arch/arm/mm/fault.c
@@ -183,20 +183,20 @@ good_area:
 	 */
 survive:
 	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, fsr & (1 << 11));
-
-	/*
-	 * Handle the "normal" cases first - successful and sigbus
-	 */
-	switch (fault) {
-	case VM_FAULT_MAJOR:
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			return fault;
+		BUG();
+	}
+	if (fault & VM_FAULT_MAJOR)
 		tsk->maj_flt++;
-		return fault;
-	case VM_FAULT_MINOR:
+	else
 		tsk->min_flt++;
-	case VM_FAULT_SIGBUS:
-		return fault;
-	}
+	return fault;
 
+out_of_memory:
 	if (!is_init(tsk))
 		goto out;
 
@@ -249,7 +249,7 @@ do_page_fault(unsigned long addr, unsign
 	/*
 	 * Handle the "normal" case first - VM_FAULT_MAJOR / VM_FAULT_MINOR
 	 */
-	if (fault >= VM_FAULT_MINOR)
+	if (likely(!(fault & VM_FAULT_ERROR)))
 		return 0;
 
 	/*
@@ -259,8 +259,7 @@ do_page_fault(unsigned long addr, unsign
 	if (!user_mode(regs))
 		goto no_context;
 
-	switch (fault) {
-	case VM_FAULT_OOM:
+	if (fault & VM_FAULT_OOM) {
 		/*
 		 * We ran out of memory, or some other thing
 		 * happened to us that made us unable to handle
@@ -269,17 +268,15 @@ do_page_fault(unsigned long addr, unsign
 		printk("VM: killing process %s\n", tsk->comm);
 		do_exit(SIGKILL);
 		return 0;
-
-	case VM_FAULT_SIGBUS:
+	}
+	if (fault & VM_FAULT_SIGBUS) {
 		/*
 		 * We had some memory, but were unable to
 		 * successfully fix up this page fault.
 		 */
 		sig = SIGBUS;
 		code = BUS_ADRERR;
-		break;
-
-	default:
+	} else {
 		/*
 		 * Something tried to access memory that
 		 * isn't in our memory map..
@@ -287,7 +284,6 @@ do_page_fault(unsigned long addr, unsign
 		sig = SIGSEGV;
 		code = fault == VM_FAULT_BADACCESS ?
 			SEGV_ACCERR : SEGV_MAPERR;
-		break;
 	}
 
 	__do_user_fault(tsk, addr, fsr, sig, code, regs);
Index: linux-2.6/arch/avr32/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/avr32/mm/fault.c
+++ linux-2.6/arch/avr32/mm/fault.c
@@ -64,6 +64,7 @@ asmlinkage void do_page_fault(unsigned l
 	int writeaccess;
 	long signr;
 	int code;
+	int fault;
 
 	if (notify_page_fault(regs, ecr))
 		return;
@@ -132,20 +133,18 @@ good_area:
 	 * fault.
 	 */
 survive:
-	switch (handle_mm_fault(mm, vma, address, writeaccess)) {
-	case VM_FAULT_MINOR:
-		tsk->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		tsk->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		goto do_sigbus;
-	case VM_FAULT_OOM:
-		goto out_of_memory;
-	default:
+	fault = handle_mm_fault(mm, vma, address, writeaccess);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
 		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		tsk->maj_flt++;
+	else
+		tsk->min_flt++;
 
 	up_read(&mm->mmap_sem);
 	return;
Index: linux-2.6/arch/cris/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/cris/mm/fault.c
+++ linux-2.6/arch/cris/mm/fault.c
@@ -179,6 +179,7 @@ do_page_fault(unsigned long address, str
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
 	siginfo_t info;
+	int fault;
 
         D(printk("Page fault for %lX on %X at %lX, prot %d write %d\n",
                  address, smp_processor_id(), instruction_pointer(regs),
@@ -283,18 +284,18 @@ do_page_fault(unsigned long address, str
 	 * the fault.
 	 */
 
-	switch (handle_mm_fault(mm, vma, address, writeaccess & 1)) {
-	case VM_FAULT_MINOR:
-		tsk->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		tsk->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		goto do_sigbus;
-	default:
-		goto out_of_memory;
+	fault = handle_mm_fault(mm, vma, address, writeaccess & 1);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
+		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		tsk->maj_flt++;
+	else
+		tsk->min_flt++;
 
 	up_read(&mm->mmap_sem);
 	return;
Index: linux-2.6/arch/frv/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/frv/mm/fault.c
+++ linux-2.6/arch/frv/mm/fault.c
@@ -40,6 +40,7 @@ asmlinkage void do_page_fault(int datamm
 	pud_t *pue;
 	pte_t *pte;
 	int write;
+	int fault;
 
 #if 0
 	const char *atxc[16] = {
@@ -162,18 +163,18 @@ asmlinkage void do_page_fault(int datamm
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	switch (handle_mm_fault(mm, vma, ear0, write)) {
-	case VM_FAULT_MINOR:
-		current->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		current->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		goto do_sigbus;
-	default:
-		goto out_of_memory;
+	fault = handle_mm_fault(mm, vma, ear0, write);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
+		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		current->maj_flt++;
+	else
+		current->min_flt++;
 
 	up_read(&mm->mmap_sem);
 	return;
Index: linux-2.6/arch/ia64/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/ia64/mm/fault.c
+++ linux-2.6/arch/ia64/mm/fault.c
@@ -80,6 +80,7 @@ ia64_do_page_fault (unsigned long addres
 	struct mm_struct *mm = current->mm;
 	struct siginfo si;
 	unsigned long mask;
+	int fault;
 
 	/* mmap_sem is performance critical.... */
 	prefetchw(&mm->mmap_sem);
@@ -147,26 +148,25 @@ ia64_do_page_fault (unsigned long addres
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	switch (handle_mm_fault(mm, vma, address, (mask & VM_WRITE) != 0)) {
-	      case VM_FAULT_MINOR:
-		++current->min_flt;
-		break;
-	      case VM_FAULT_MAJOR:
-		++current->maj_flt;
-		break;
-	      case VM_FAULT_SIGBUS:
+	fault = handle_mm_fault(mm, vma, address, (mask & VM_WRITE) != 0);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
 		 * We ran out of memory, or some other thing happened
 		 * to us that made us unable to handle the page fault
 		 * gracefully.
 		 */
-		signal = SIGBUS;
-		goto bad_area;
-	      case VM_FAULT_OOM:
-		goto out_of_memory;
-	      default:
+		if (fault & VM_FAULT_OOM) {
+			goto out_of_memory;
+			signal = SIGBUS;
+			goto bad_area;
+		} else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
 		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		current->maj_flt++;
+	else
+		current->min_flt++;
 	up_read(&mm->mmap_sem);
 	return;
 
Index: linux-2.6/arch/m32r/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/m32r/mm/fault.c
+++ linux-2.6/arch/m32r/mm/fault.c
@@ -80,6 +80,7 @@ asmlinkage void do_page_fault(struct pt_
 	struct vm_area_struct * vma;
 	unsigned long page, addr;
 	int write;
+	int fault;
 	siginfo_t info;
 
 	/*
@@ -195,20 +196,18 @@ survive:
 	 */
 	addr = (address & PAGE_MASK);
 	set_thread_fault_code(error_code);
-	switch (handle_mm_fault(mm, vma, addr, write)) {
-		case VM_FAULT_MINOR:
-			tsk->min_flt++;
-			break;
-		case VM_FAULT_MAJOR:
-			tsk->maj_flt++;
-			break;
-		case VM_FAULT_SIGBUS:
-			goto do_sigbus;
-		case VM_FAULT_OOM:
+	fault = handle_mm_fault(mm, vma, addr, write);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
-		default:
-			BUG();
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
+		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		tsk->maj_flt++;
+	else
+		tsk->min_flt++;
 	set_thread_fault_code(0);
 	up_read(&mm->mmap_sem);
 	return;
Index: linux-2.6/arch/m68k/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/m68k/mm/fault.c
+++ linux-2.6/arch/m68k/mm/fault.c
@@ -159,18 +159,17 @@ good_area:
 #ifdef DEBUG
 	printk("handle_mm_fault returns %d\n",fault);
 #endif
-	switch (fault) {
-	case VM_FAULT_MINOR:
-		current->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		current->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		goto bus_err;
-	default:
-		goto out_of_memory;
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto bus_err;
+		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		current->maj_flt++;
+	else
+		current->min_flt++;
 
 	up_read(&mm->mmap_sem);
 	return 0;
Index: linux-2.6/arch/mips/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/fault.c
+++ linux-2.6/arch/mips/mm/fault.c
@@ -39,6 +39,7 @@ asmlinkage void do_page_fault(struct pt_
 	struct mm_struct *mm = tsk->mm;
 	const int field = sizeof(unsigned long) * 2;
 	siginfo_t info;
+	int fault;
 
 #if 0
 	printk("Cpu%d[%s:%d:%0*lx:%ld:%0*lx]\n", raw_smp_processor_id(),
@@ -102,20 +103,18 @@ survive:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	switch (handle_mm_fault(mm, vma, address, write)) {
-	case VM_FAULT_MINOR:
-		tsk->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		tsk->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		goto do_sigbus;
-	case VM_FAULT_OOM:
-		goto out_of_memory;
-	default:
+	fault = handle_mm_fault(mm, vma, address, write);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
 		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		tsk->maj_flt++;
+	else
+		tsk->min_flt++;
 
 	up_read(&mm->mmap_sem);
 	return;
Index: linux-2.6/arch/parisc/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/parisc/mm/fault.c
+++ linux-2.6/arch/parisc/mm/fault.c
@@ -147,6 +147,7 @@ void do_page_fault(struct pt_regs *regs,
 	struct mm_struct *mm = tsk->mm;
 	const struct exception_table_entry *fix;
 	unsigned long acc_type;
+	int fault;
 
 	if (in_atomic() || !mm)
 		goto no_context;
@@ -173,23 +174,23 @@ good_area:
 	 * fault.
 	 */
 
-	switch (handle_mm_fault(mm, vma, address, (acc_type & VM_WRITE) != 0)) {
-	      case VM_FAULT_MINOR:
-		++current->min_flt;
-		break;
-	      case VM_FAULT_MAJOR:
-		++current->maj_flt;
-		break;
-	      case VM_FAULT_SIGBUS:
+	fault = handle_mm_fault(mm, vma, address, (acc_type & VM_WRITE) != 0);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
 		 * We hit a shared mapping outside of the file, or some
 		 * other thing happened to us that made us unable to
 		 * handle the page fault gracefully.
 		 */
-		goto bad_area;
-	      default:
-		goto out_of_memory;
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto bad_area;
+		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		current->maj_flt++;
+	else
+		current->min_flt++;
 	up_read(&mm->mmap_sem);
 	return;
 
Index: linux-2.6/arch/powerpc/platforms/cell/spufs/fault.c
===================================================================
--- linux-2.6.orig/arch/powerpc/platforms/cell/spufs/fault.c
+++ linux-2.6/arch/powerpc/platforms/cell/spufs/fault.c
@@ -38,6 +38,7 @@ static int spu_handle_mm_fault(struct mm
 	struct vm_area_struct *vma;
 	unsigned long is_write;
 	int ret;
+	int fault;
 
 #if 0
 	if (!IS_VALID_EA(ea)) {
@@ -73,22 +74,21 @@ good_area:
 			goto bad_area;
 	}
 	ret = 0;
-	switch (handle_mm_fault(mm, vma, ea, is_write)) {
-	case VM_FAULT_MINOR:
-		current->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		current->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		ret = -EFAULT;
-		goto bad_area;
-	case VM_FAULT_OOM:
-		ret = -ENOMEM;
-		goto bad_area;
-	default:
+	fault = handle_mm_fault(mm, vma, ea, is_write);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM) {
+			ret = -ENOMEM;
+			goto bad_area;
+		} else if (fault & VM_FAULT_SIGBUS) {
+			ret = -EFAULT;
+			goto bad_area;
+		}
 		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		current->maj_flt++;
+	else
+		current->min_flt++;
 	up_read(&mm->mmap_sem);
 	return ret;
 
Index: linux-2.6/arch/ppc/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/ppc/mm/fault.c
+++ linux-2.6/arch/ppc/mm/fault.c
@@ -97,6 +97,7 @@ int do_page_fault(struct pt_regs *regs, 
 	struct mm_struct *mm = current->mm;
 	siginfo_t info;
 	int code = SEGV_MAPERR;
+	int fault;
 #if defined(CONFIG_4xx) || defined (CONFIG_BOOKE)
 	int is_write = error_code & ESR_DST;
 #else
@@ -250,20 +251,18 @@ good_area:
 	 * the fault.
 	 */
  survive:
-        switch (handle_mm_fault(mm, vma, address, is_write)) {
-        case VM_FAULT_MINOR:
-                current->min_flt++;
-                break;
-        case VM_FAULT_MAJOR:
-                current->maj_flt++;
-                break;
-        case VM_FAULT_SIGBUS:
-                goto do_sigbus;
-        case VM_FAULT_OOM:
-                goto out_of_memory;
-	default:
+	fault = handle_mm_fault(mm, vma, address, is_write);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
 		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		tsk->maj_flt++;
+	else
+		tsk->min_flt++;
 
 	up_read(&mm->mmap_sem);
 	/*
Index: linux-2.6/arch/s390/lib/uaccess_pt.c
===================================================================
--- linux-2.6.orig/arch/s390/lib/uaccess_pt.c
+++ linux-2.6/arch/s390/lib/uaccess_pt.c
@@ -20,6 +20,7 @@ static int __handle_fault(struct mm_stru
 {
 	struct vm_area_struct *vma;
 	int ret = -EFAULT;
+	int fault;
 
 	if (in_atomic())
 		return ret;
@@ -44,20 +45,18 @@ static int __handle_fault(struct mm_stru
 	}
 
 survive:
-	switch (handle_mm_fault(mm, vma, address, write_access)) {
-	case VM_FAULT_MINOR:
-		current->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		current->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		goto out_sigbus;
-	case VM_FAULT_OOM:
-		goto out_of_memory;
-	default:
+	fault = handle_mm_fault(mm, vma, address, write_access);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
 		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		current->maj_flt++;
+	else
+		current->min_flt++;
 	ret = 0;
 out:
 	up_read(&mm->mmap_sem);
Index: linux-2.6/arch/s390/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/fault.c
+++ linux-2.6/arch/s390/mm/fault.c
@@ -307,6 +307,7 @@ do_exception(struct pt_regs *regs, unsig
 	unsigned long address;
 	int space;
 	int si_code;
+	int fault;
 
 	if (notify_page_fault(regs, error_code))
 		return;
@@ -377,23 +378,22 @@ survive:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	switch (handle_mm_fault(mm, vma, address, write)) {
-	case VM_FAULT_MINOR:
-		tsk->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		tsk->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		do_sigbus(regs, error_code, address);
-		return;
-	case VM_FAULT_OOM:
-		if (do_out_of_memory(regs, error_code, address))
-			goto survive;
-		return;
-	default:
+	fault = handle_mm_fault(mm, vma, address, write);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM) {
+			if (do_out_of_memory(regs, error_code, address))
+				goto survive;
+			return;
+		} else if (fault & VM_FAULT_SIGBUS) {
+			do_sigbus(regs, error_code, address);
+			return;
+		}
 		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		tsk->maj_flt++;
+	else
+		tsk->min_flt++;
 
         up_read(&mm->mmap_sem);
 	/*
Index: linux-2.6/arch/sh/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/fault.c
+++ linux-2.6/arch/sh/mm/fault.c
@@ -32,7 +32,7 @@ asmlinkage void __kprobes do_page_fault(
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
 	unsigned long page;
-	int si_code;
+	int si_code, fault;
 	siginfo_t info;
 
 	trace_hardirqs_on();
@@ -119,20 +119,18 @@ good_area:
 	 * the fault.
 	 */
 survive:
-	switch (handle_mm_fault(mm, vma, address, writeaccess)) {
-		case VM_FAULT_MINOR:
-			tsk->min_flt++;
-			break;
-		case VM_FAULT_MAJOR:
-			tsk->maj_flt++;
-			break;
-		case VM_FAULT_SIGBUS:
-			goto do_sigbus;
-		case VM_FAULT_OOM:
+	fault = handle_mm_fault(mm, vma, address, writeaccess);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
-		default:
-			BUG();
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
+		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		tsk->maj_flt++;
+	else
+		tsk->min_flt++;
 
 	up_read(&mm->mmap_sem);
 	return;
Index: linux-2.6/arch/sh64/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/sh64/mm/fault.c
+++ linux-2.6/arch/sh64/mm/fault.c
@@ -127,6 +127,7 @@ asmlinkage void do_page_fault(struct pt_
 	struct vm_area_struct * vma;
 	const struct exception_table_entry *fixup;
 	pte_t *pte;
+	int fault;
 
 #if defined(CONFIG_SH64_PROC_TLB)
         ++calls_to_do_slow_page_fault;
@@ -221,18 +222,19 @@ good_area:
 	 * the fault.
 	 */
 survive:
-	switch (handle_mm_fault(mm, vma, address, writeaccess)) {
-	case VM_FAULT_MINOR:
-		tsk->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		tsk->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		goto do_sigbus;
-	default:
-		goto out_of_memory;
+	fault = handle_mm_fault(mm, vma, address, writeaccess);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
+		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		tsk->maj_flt++;
+	else
+		tsk->min_flt++;
+
 	/* If we get here, the page fault has been handled.  Do the TLB refill
 	   now from the newly-setup PTE, to avoid having to fault again right
 	   away on the same instruction. */
Index: linux-2.6/arch/sparc/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/fault.c
+++ linux-2.6/arch/sparc/mm/fault.c
@@ -289,19 +289,18 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	switch (handle_mm_fault(mm, vma, address, write)) {
-	case VM_FAULT_SIGBUS:
-		goto do_sigbus;
-	case VM_FAULT_OOM:
-		goto out_of_memory;
-	case VM_FAULT_MAJOR:
+	fault = handle_mm_fault(mm, vma, address, write);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
+		BUG();
+	}
+	if (fault & VM_FAULT_MAJOR)
 		current->maj_flt++;
-		break;
-	case VM_FAULT_MINOR:
-	default:
+	else
 		current->min_flt++;
-		break;
-	}
 	up_read(&mm->mmap_sem);
 	return;
 
Index: linux-2.6/arch/sparc64/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/sparc64/mm/fault.c
+++ linux-2.6/arch/sparc64/mm/fault.c
@@ -278,7 +278,7 @@ asmlinkage void __kprobes do_sparc64_fau
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned int insn = 0;
-	int si_code, fault_code;
+	int si_code, fault_code, fault;
 	unsigned long address, mm_rss;
 
 	fault_code = get_thread_fault_code();
@@ -415,20 +415,18 @@ good_area:
 			goto bad_area;
 	}
 
-	switch (handle_mm_fault(mm, vma, address, (fault_code & FAULT_CODE_WRITE))) {
-	case VM_FAULT_MINOR:
-		current->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		current->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		goto do_sigbus;
-	case VM_FAULT_OOM:
-		goto out_of_memory;
-	default:
+	fault = handle_mm_fault(mm, vma, address, (fault_code & FAULT_CODE_WRITE));
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
 		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		tsk->maj_flt++;
+	else
+		tsk->min_flt++;
 
 	up_read(&mm->mmap_sem);
 
Index: linux-2.6/arch/um/kernel/trap.c
===================================================================
--- linux-2.6.orig/arch/um/kernel/trap.c
+++ linux-2.6/arch/um/kernel/trap.c
@@ -76,23 +76,24 @@ good_area:
 		goto out;
 
 	do {
+		int fault;
 survive:
-		switch (handle_mm_fault(mm, vma, address, is_write)){
-		case VM_FAULT_MINOR:
-			current->min_flt++;
-			break;
-		case VM_FAULT_MAJOR:
-			current->maj_flt++;
-			break;
-		case VM_FAULT_SIGBUS:
-			err = -EACCES;
-			goto out;
-		case VM_FAULT_OOM:
-			err = -ENOMEM;
-			goto out_of_memory;
-		default:
+		fault = handle_mm_fault(mm, vma, address, is_write);
+		if (unlikely(fault & VM_FAULT_ERROR)) {
+			if (fault & VM_FAULT_OOM) {
+				err = -ENOMEM;
+				goto out_of_memory;
+			} else if (fault & VM_FAULT_SIGBUS) {
+				err = -EACCES;
+				goto out;
+			}
 			BUG();
 		}
+		if (fault & VM_FAULT_MAJOR)
+			current->maj_flt++;
+		else
+			current->min_flt++;
+
 		pgd = pgd_offset(mm, address);
 		pud = pud_offset(pgd, address);
 		pmd = pmd_offset(pud, address);
Index: linux-2.6/arch/xtensa/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/xtensa/mm/fault.c
+++ linux-2.6/arch/xtensa/mm/fault.c
@@ -41,6 +41,7 @@ void do_page_fault(struct pt_regs *regs)
 	siginfo_t info;
 
 	int is_write, is_exec;
+	int fault;
 
 	info.si_code = SEGV_MAPERR;
 
@@ -102,20 +103,18 @@ good_area:
 	 * the fault.
 	 */
 survive:
-	switch (handle_mm_fault(mm, vma, address, is_write)) {
-	case VM_FAULT_MINOR:
-		current->min_flt++;
-		break;
-	case VM_FAULT_MAJOR:
-		current->maj_flt++;
-		break;
-	case VM_FAULT_SIGBUS:
-		goto do_sigbus;
-	case VM_FAULT_OOM:
-		goto out_of_memory;
-	default:
+	fault = handle_mm_fault(mm, vma, address, is_write);
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		if (fault & VM_FAULT_OOM)
+			goto out_of_memory;
+		else if (fault & VM_FAULT_SIGBUS)
+			goto do_sigbus;
 		BUG();
 	}
+	if (fault & VM_FAULT_MAJOR)
+		current->maj_flt++;
+	else
+		current->min_flt++;
 
 	up_read(&mm->mmap_sem);
 	return;
Index: linux-2.6/kernel/futex.c
===================================================================
--- linux-2.6.orig/kernel/futex.c
+++ linux-2.6/kernel/futex.c
@@ -317,15 +317,20 @@ static int futex_handle_fault(unsigned l
 	vma = find_vma(mm, address);
 	if (vma && address >= vma->vm_start &&
 	    (vma->vm_flags & VM_WRITE)) {
-		switch (handle_mm_fault(mm, vma, address, 1)) {
-		case VM_FAULT_MINOR:
-			ret = 0;
-			current->min_flt++;
-			break;
-		case VM_FAULT_MAJOR:
+		int fault;
+		fault = handle_mm_fault(mm, vma, address, 1);
+		if (unlikely((fault & VM_FAULT_ERROR))) {
+#if 0
+			/* XXX: let's do this when we verify it is OK */
+			if (ret & VM_FAULT_OOM)
+				ret = -ENOMEM;
+#endif
+		} else {
 			ret = 0;
-			current->maj_flt++;
-			break;
+			if (fault & VM_FAULT_MAJOR)
+				current->maj_flt++;
+			else
+				current->min_flt++;
 		}
 	}
 	if (!fshared)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
