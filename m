Date: Sat, 26 May 2007 10:03:20 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/8] mm: merge nopfn into fault
Message-ID: <20070526080320.GD32402@wotan.suse.de>
References: <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org> <1179963619.32247.991.camel@localhost.localdomain> <20070524014223.GA22998@wotan.suse.de> <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org> <1179976659.32247.1026.camel@localhost.localdomain> <1179977184.32247.1032.camel@localhost.localdomain> <alpine.LFD.0.98.0705232028510.3890@woody.linux-foundation.org> <20070525111818.GA3881@wotan.suse.de> <alpine.LFD.0.98.0705250924320.26602@woody.linux-foundation.org> <20070526073426.GC32402@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070526073426.GC32402@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sat, May 26, 2007 at 09:34:26AM +0200, Nick Piggin wrote:
> On Fri, May 25, 2007 at 09:36:26AM -0700, Linus Torvalds wrote:
> > 
> > 
> > On Fri, 25 May 2007, Nick Piggin wrote:
> > > 
> > > What do you think? Any better?
> > 
> > Yes, I think this is getting there. It made the error returns generally 
> > much simpler.
> > 
> > That said, I think it has room for more improvement. Why not make the 
> > return value just be a bitmask, rather than having two separate "bytes" of 
> > data.
> 
> Yeah, that would be really nice, but I guess that now goes out and
> touches all arch code too, doesn't it? Or... actually we could just
> retain compatibility by masking off the high bits, and defining some
> sane definition for VM_FAULT_MINOR (seems like 0x0000 would work).

Hmm, maybe we just skip that annoying step?

Here is something of an untested mockup (incremental since the last
incremental one). It does look quite a bit cleaner, and let's us
finally get rid of that stupid __handle_mm_fault thing.

---
Index: linux-2.6/arch/i386/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/i386/mm/fault.c
+++ linux-2.6/arch/i386/mm/fault.c
@@ -303,6 +303,7 @@ fastcall void __kprobes do_page_fault(st
 	struct vm_area_struct * vma;
 	unsigned long address;
 	int write, si_code;
+	int ret;
 
 	/* get the address */
         address = read_cr2();
@@ -422,20 +423,18 @@ good_area:
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
+	ret = handle_mm_fault(mm, vma, address, write);
+	if (unlikely(ret & VM_FAULT_ERROR)) {
+		if (ret & VM_FAULT_OOM)
 			goto out_of_memory;
-		default:
-			BUG();
+		else if (ret & VM_FAULT_SIGBUS)
+			goto do_sigbus;
+		BUG();
 	}
+	if (ret & VM_FAULT_MAJOR)
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
 
@@ -709,26 +694,15 @@ static inline int page_mapped(struct pag
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
 
@@ -814,16 +788,8 @@ extern int vmtruncate(struct inode * ino
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
@@ -1828,8 +1827,8 @@ static int unmap_mapping_range_vma(struc
 	/*
 	 * files that support invalidating or truncating portions of the
 	 * file from under mmaped areas must have their ->fault function
-	 * return a locked page (and FAULT_RET_LOCKED code). This provides
-	 * synchronisation against concurrent unmapping here.
+	 * return a locked page (and set VM_FAULT_LOCKED in the return).
+	 * This provides synchronisation against concurrent unmapping here.
 	 */
 
 again:
@@ -2133,7 +2132,7 @@ static int do_swap_page(struct mm_struct
 	struct page *page;
 	swp_entry_t entry;
 	pte_t pte;
-	int ret = VM_FAULT_MINOR;
+	int ret = 0;
 
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
 		goto out;
@@ -2201,8 +2200,9 @@ static int do_swap_page(struct mm_struct
 	unlock_page(page);
 
 	if (write_access) {
+		/* XXX: We could OR the do_wp_page code with this one? */
 		if (do_wp_page(mm, vma, address,
-				page_table, pmd, ptl, pte) == VM_FAULT_OOM)
+				page_table, pmd, ptl, pte) & VM_FAULT_OOM)
 			ret = VM_FAULT_OOM;
 		goto out;
 	}
@@ -2273,7 +2273,7 @@ static int do_anonymous_page(struct mm_s
 	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
-	return VM_FAULT_MINOR;
+	return 0;
 release:
 	page_cache_release(page);
 	goto unlock;
@@ -2316,11 +2316,11 @@ static int __do_fault(struct mm_struct *
 
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
@@ -2333,7 +2333,7 @@ static int __do_fault(struct mm_struct *
 	 * For consistency in subsequent calls, make the faulted page always
 	 * locked.
 	 */
-	if (unlikely(!(ret & FAULT_RET_LOCKED)))
+	if (unlikely(!(ret & VM_FAULT_LOCKED)))
 		lock_page(vmf.page);
 	else
 		VM_BUG_ON(!PageLocked(vmf.page));
@@ -2424,7 +2424,7 @@ out:
 		put_page(dirty_page);
 	}
 
-	return (ret & VM_FAULT_MASK);
+	return ret;
 }
 
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -2463,7 +2463,6 @@ static noinline int do_no_pfn(struct mm_
 	spinlock_t *ptl;
 	pte_t entry;
 	unsigned long pfn;
-	int ret = VM_FAULT_MINOR;
 
 	pte_unmap(page_table);
 	BUG_ON(!(vma->vm_flags & VM_PFNMAP));
@@ -2475,7 +2474,7 @@ static noinline int do_no_pfn(struct mm_
 	else if (unlikely(pfn == NOPFN_SIGBUS))
 		return VM_FAULT_SIGBUS;
 	else if (unlikely(pfn == NOPFN_REFAULT))
-		return VM_FAULT_MINOR;
+		return 0;
 
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 
@@ -2487,7 +2486,7 @@ static noinline int do_no_pfn(struct mm_
 		set_pte_at(mm, address, page_table, entry);
 	}
 	pte_unmap_unlock(page_table, ptl);
-	return ret;
+	return 0;
 }
 
 /*
@@ -2508,7 +2507,7 @@ static int do_nonlinear_fault(struct mm_
 	pgoff_t pgoff;
 
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
-		return VM_FAULT_MINOR;
+		return 0;
 
 	if (unlikely(!(vma->vm_flags & VM_NONLINEAR) ||
 			!(vma->vm_flags & VM_CAN_NONLINEAR))) {
@@ -2594,13 +2593,13 @@ static inline int handle_pte_fault(struc
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
@@ -2629,7 +2628,7 @@ int __handle_mm_fault(struct mm_struct *
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
@@ -1097,7 +1097,7 @@ static int shmem_getpage(struct inode *i
 		return -EFBIG;
 
 	if (type)
-		*type = VM_FAULT_MINOR;
+		*type = 0;
 
 	/*
 	 * Normally, filepage is NULL on entry, and either found
@@ -1132,9 +1132,9 @@ repeat:
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
@@ -1317,7 +1317,7 @@ static int shmem_fault(struct vm_area_st
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
