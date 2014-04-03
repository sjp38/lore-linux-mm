Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 34A996B0037
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 10:37:59 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so1874657pdj.34
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 07:37:58 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id il2si3174062pbc.349.2014.04.03.07.37.56
        for <linux-mm@kvack.org>;
        Thu, 03 Apr 2014 07:37:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/5] mm: move get_user_pages()-related code to separate file
Date: Thu,  3 Apr 2014 17:35:18 +0300
Message-Id: <1396535722-31108-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

mm/memory.c is overloaded: over 4k lines. get_user_pages() code is
pretty much self-contained let's move it to separate file.

No other changes made.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/Makefile |   2 +-
 mm/gup.c    | 618 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/memory.c | 611 -----------------------------------------------------------
 3 files changed, 619 insertions(+), 612 deletions(-)
 create mode 100644 mm/gup.c

diff --git a/mm/Makefile b/mm/Makefile
index 310c90a09264..c9c9f7c45a14 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -3,7 +3,7 @@
 #
 
 mmu-y			:= nommu.o
-mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
+mmu-$(CONFIG_MMU)	:= fremap.o gup.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
 			   vmalloc.o pagewalk.o pgtable-generic.o
 
diff --git a/mm/gup.c b/mm/gup.c
new file mode 100644
index 000000000000..eca5c3188cef
--- /dev/null
+++ b/mm/gup.c
@@ -0,0 +1,618 @@
+#include <linux/hugetlb.h>
+#include <linux/mm.h>
+#include <linux/rmap.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+
+#include "internal.h"
+
+/**
+ * follow_page_mask - look up a page descriptor from a user-virtual address
+ * @vma: vm_area_struct mapping @address
+ * @address: virtual address to look up
+ * @flags: flags modifying lookup behaviour
+ * @page_mask: on output, *page_mask is set according to the size of the page
+ *
+ * @flags can have FOLL_ flags set, defined in <linux/mm.h>
+ *
+ * Returns the mapped (struct page *), %NULL if no mapping exists, or
+ * an error pointer if there is a mapping to something not represented
+ * by a page descriptor (see also vm_normal_page()).
+ */
+struct page *follow_page_mask(struct vm_area_struct *vma,
+			      unsigned long address, unsigned int flags,
+			      unsigned int *page_mask)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep, pte;
+	spinlock_t *ptl;
+	struct page *page;
+	struct mm_struct *mm = vma->vm_mm;
+
+	*page_mask = 0;
+
+	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
+	if (!IS_ERR(page)) {
+		BUG_ON(flags & FOLL_GET);
+		goto out;
+	}
+
+	page = NULL;
+	pgd = pgd_offset(mm, address);
+	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
+		goto no_page_table;
+
+	pud = pud_offset(pgd, address);
+	if (pud_none(*pud))
+		goto no_page_table;
+	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
+		if (flags & FOLL_GET)
+			goto out;
+		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
+		goto out;
+	}
+	if (unlikely(pud_bad(*pud)))
+		goto no_page_table;
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none(*pmd))
+		goto no_page_table;
+	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
+		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
+		if (flags & FOLL_GET) {
+			/*
+			 * Refcount on tail pages are not well-defined and
+			 * shouldn't be taken. The caller should handle a NULL
+			 * return when trying to follow tail pages.
+			 */
+			if (PageHead(page))
+				get_page(page);
+			else {
+				page = NULL;
+				goto out;
+			}
+		}
+		goto out;
+	}
+	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
+		goto no_page_table;
+	if (pmd_trans_huge(*pmd)) {
+		if (flags & FOLL_SPLIT) {
+			split_huge_page_pmd(vma, address, pmd);
+			goto split_fallthrough;
+		}
+		ptl = pmd_lock(mm, pmd);
+		if (likely(pmd_trans_huge(*pmd))) {
+			if (unlikely(pmd_trans_splitting(*pmd))) {
+				spin_unlock(ptl);
+				wait_split_huge_page(vma->anon_vma, pmd);
+			} else {
+				page = follow_trans_huge_pmd(vma, address,
+							     pmd, flags);
+				spin_unlock(ptl);
+				*page_mask = HPAGE_PMD_NR - 1;
+				goto out;
+			}
+		} else
+			spin_unlock(ptl);
+		/* fall through */
+	}
+split_fallthrough:
+	if (unlikely(pmd_bad(*pmd)))
+		goto no_page_table;
+
+	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+
+	pte = *ptep;
+	if (!pte_present(pte)) {
+		swp_entry_t entry;
+		/*
+		 * KSM's break_ksm() relies upon recognizing a ksm page
+		 * even while it is being migrated, so for that case we
+		 * need migration_entry_wait().
+		 */
+		if (likely(!(flags & FOLL_MIGRATION)))
+			goto no_page;
+		if (pte_none(pte) || pte_file(pte))
+			goto no_page;
+		entry = pte_to_swp_entry(pte);
+		if (!is_migration_entry(entry))
+			goto no_page;
+		pte_unmap_unlock(ptep, ptl);
+		migration_entry_wait(mm, pmd, address);
+		goto split_fallthrough;
+	}
+	if ((flags & FOLL_NUMA) && pte_numa(pte))
+		goto no_page;
+	if ((flags & FOLL_WRITE) && !pte_write(pte))
+		goto unlock;
+
+	page = vm_normal_page(vma, address, pte);
+	if (unlikely(!page)) {
+		if ((flags & FOLL_DUMP) ||
+		    !is_zero_pfn(pte_pfn(pte)))
+			goto bad_page;
+		page = pte_page(pte);
+	}
+
+	if (flags & FOLL_GET)
+		get_page_foll(page);
+	if (flags & FOLL_TOUCH) {
+		if ((flags & FOLL_WRITE) &&
+		    !pte_dirty(pte) && !PageDirty(page))
+			set_page_dirty(page);
+		/*
+		 * pte_mkyoung() would be more correct here, but atomic care
+		 * is needed to avoid losing the dirty bit: it is easier to use
+		 * mark_page_accessed().
+		 */
+		mark_page_accessed(page);
+	}
+	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
+		/*
+		 * The preliminary mapping check is mainly to avoid the
+		 * pointless overhead of lock_page on the ZERO_PAGE
+		 * which might bounce very badly if there is contention.
+		 *
+		 * If the page is already locked, we don't need to
+		 * handle it now - vmscan will handle it later if and
+		 * when it attempts to reclaim the page.
+		 */
+		if (page->mapping && trylock_page(page)) {
+			lru_add_drain();  /* push cached pages to LRU */
+			/*
+			 * Because we lock page here, and migration is
+			 * blocked by the pte's page reference, and we
+			 * know the page is still mapped, we don't even
+			 * need to check for file-cache page truncation.
+			 */
+			mlock_vma_page(page);
+			unlock_page(page);
+		}
+	}
+unlock:
+	pte_unmap_unlock(ptep, ptl);
+out:
+	return page;
+
+bad_page:
+	pte_unmap_unlock(ptep, ptl);
+	return ERR_PTR(-EFAULT);
+
+no_page:
+	pte_unmap_unlock(ptep, ptl);
+	if (!pte_none(pte))
+		return page;
+
+no_page_table:
+	/*
+	 * When core dumping an enormous anonymous area that nobody
+	 * has touched so far, we don't want to allocate unnecessary pages or
+	 * page tables.  Return error instead of NULL to skip handle_mm_fault,
+	 * then get_dump_page() will return NULL to leave a hole in the dump.
+	 * But we can only make this optimization where a hole would surely
+	 * be zero-filled if handle_mm_fault() actually did handle it.
+	 */
+	if ((flags & FOLL_DUMP) &&
+	    (!vma->vm_ops || !vma->vm_ops->fault))
+		return ERR_PTR(-EFAULT);
+	return page;
+}
+
+static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long addr)
+{
+	return stack_guard_page_start(vma, addr) ||
+	       stack_guard_page_end(vma, addr+PAGE_SIZE);
+}
+
+/**
+ * __get_user_pages() - pin user pages in memory
+ * @tsk:	task_struct of target task
+ * @mm:		mm_struct of target mm
+ * @start:	starting user address
+ * @nr_pages:	number of pages from start to pin
+ * @gup_flags:	flags modifying pin behaviour
+ * @pages:	array that receives pointers to the pages pinned.
+ *		Should be at least nr_pages long. Or NULL, if caller
+ *		only intends to ensure the pages are faulted in.
+ * @vmas:	array of pointers to vmas corresponding to each page.
+ *		Or NULL if the caller does not require them.
+ * @nonblocking: whether waiting for disk IO or mmap_sem contention
+ *
+ * Returns number of pages pinned. This may be fewer than the number
+ * requested. If nr_pages is 0 or negative, returns 0. If no pages
+ * were pinned, returns -errno. Each page returned must be released
+ * with a put_page() call when it is finished with. vmas will only
+ * remain valid while mmap_sem is held.
+ *
+ * Must be called with mmap_sem held for read or write.
+ *
+ * __get_user_pages walks a process's page tables and takes a reference to
+ * each struct page that each user address corresponds to at a given
+ * instant. That is, it takes the page that would be accessed if a user
+ * thread accesses the given user virtual address at that instant.
+ *
+ * This does not guarantee that the page exists in the user mappings when
+ * __get_user_pages returns, and there may even be a completely different
+ * page there in some cases (eg. if mmapped pagecache has been invalidated
+ * and subsequently re faulted). However it does guarantee that the page
+ * won't be freed completely. And mostly callers simply care that the page
+ * contains data that was valid *at some point in time*. Typically, an IO
+ * or similar operation cannot guarantee anything stronger anyway because
+ * locks can't be held over the syscall boundary.
+ *
+ * If @gup_flags & FOLL_WRITE == 0, the page must not be written to. If
+ * the page is written to, set_page_dirty (or set_page_dirty_lock, as
+ * appropriate) must be called after the page is finished with, and
+ * before put_page is called.
+ *
+ * If @nonblocking != NULL, __get_user_pages will not wait for disk IO
+ * or mmap_sem contention, and if waiting is needed to pin all pages,
+ * *@nonblocking will be set to 0.
+ *
+ * In most cases, get_user_pages or get_user_pages_fast should be used
+ * instead of __get_user_pages. __get_user_pages should be used only if
+ * you need some special @gup_flags.
+ */
+long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, unsigned long nr_pages,
+		unsigned int gup_flags, struct page **pages,
+		struct vm_area_struct **vmas, int *nonblocking)
+{
+	long i;
+	unsigned long vm_flags;
+	unsigned int page_mask;
+
+	if (!nr_pages)
+		return 0;
+
+	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
+
+	/*
+	 * Require read or write permissions.
+	 * If FOLL_FORCE is set, we only require the "MAY" flags.
+	 */
+	vm_flags  = (gup_flags & FOLL_WRITE) ?
+			(VM_WRITE | VM_MAYWRITE) : (VM_READ | VM_MAYREAD);
+	vm_flags &= (gup_flags & FOLL_FORCE) ?
+			(VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
+
+	/*
+	 * If FOLL_FORCE and FOLL_NUMA are both set, handle_mm_fault
+	 * would be called on PROT_NONE ranges. We must never invoke
+	 * handle_mm_fault on PROT_NONE ranges or the NUMA hinting
+	 * page faults would unprotect the PROT_NONE ranges if
+	 * _PAGE_NUMA and _PAGE_PROTNONE are sharing the same pte/pmd
+	 * bitflag. So to avoid that, don't set FOLL_NUMA if
+	 * FOLL_FORCE is set.
+	 */
+	if (!(gup_flags & FOLL_FORCE))
+		gup_flags |= FOLL_NUMA;
+
+	i = 0;
+
+	do {
+		struct vm_area_struct *vma;
+
+		vma = find_extend_vma(mm, start);
+		if (!vma && in_gate_area(mm, start)) {
+			unsigned long pg = start & PAGE_MASK;
+			pgd_t *pgd;
+			pud_t *pud;
+			pmd_t *pmd;
+			pte_t *pte;
+
+			/* user gate pages are read-only */
+			if (gup_flags & FOLL_WRITE)
+				return i ? : -EFAULT;
+			if (pg > TASK_SIZE)
+				pgd = pgd_offset_k(pg);
+			else
+				pgd = pgd_offset_gate(mm, pg);
+			BUG_ON(pgd_none(*pgd));
+			pud = pud_offset(pgd, pg);
+			BUG_ON(pud_none(*pud));
+			pmd = pmd_offset(pud, pg);
+			if (pmd_none(*pmd))
+				return i ? : -EFAULT;
+			VM_BUG_ON(pmd_trans_huge(*pmd));
+			pte = pte_offset_map(pmd, pg);
+			if (pte_none(*pte)) {
+				pte_unmap(pte);
+				return i ? : -EFAULT;
+			}
+			vma = get_gate_vma(mm);
+			if (pages) {
+				struct page *page;
+
+				page = vm_normal_page(vma, start, *pte);
+				if (!page) {
+					if (!(gup_flags & FOLL_DUMP) &&
+					     is_zero_pfn(pte_pfn(*pte)))
+						page = pte_page(*pte);
+					else {
+						pte_unmap(pte);
+						return i ? : -EFAULT;
+					}
+				}
+				pages[i] = page;
+				get_page(page);
+			}
+			pte_unmap(pte);
+			page_mask = 0;
+			goto next_page;
+		}
+
+		if (!vma ||
+		    (vma->vm_flags & (VM_IO | VM_PFNMAP)) ||
+		    !(vm_flags & vma->vm_flags))
+			return i ? : -EFAULT;
+
+		if (is_vm_hugetlb_page(vma)) {
+			i = follow_hugetlb_page(mm, vma, pages, vmas,
+					&start, &nr_pages, i, gup_flags);
+			continue;
+		}
+
+		do {
+			struct page *page;
+			unsigned int foll_flags = gup_flags;
+			unsigned int page_increm;
+
+			/*
+			 * If we have a pending SIGKILL, don't keep faulting
+			 * pages and potentially allocating memory.
+			 */
+			if (unlikely(fatal_signal_pending(current)))
+				return i ? i : -ERESTARTSYS;
+
+			cond_resched();
+			while (!(page = follow_page_mask(vma, start,
+						foll_flags, &page_mask))) {
+				int ret;
+				unsigned int fault_flags = 0;
+
+				/* For mlock, just skip the stack guard page. */
+				if (foll_flags & FOLL_MLOCK) {
+					if (stack_guard_page(vma, start))
+						goto next_page;
+				}
+				if (foll_flags & FOLL_WRITE)
+					fault_flags |= FAULT_FLAG_WRITE;
+				if (nonblocking)
+					fault_flags |= FAULT_FLAG_ALLOW_RETRY;
+				if (foll_flags & FOLL_NOWAIT)
+					fault_flags |= (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT);
+
+				ret = handle_mm_fault(mm, vma, start,
+							fault_flags);
+
+				if (ret & VM_FAULT_ERROR) {
+					if (ret & VM_FAULT_OOM)
+						return i ? i : -ENOMEM;
+					if (ret & (VM_FAULT_HWPOISON |
+						   VM_FAULT_HWPOISON_LARGE)) {
+						if (i)
+							return i;
+						else if (gup_flags & FOLL_HWPOISON)
+							return -EHWPOISON;
+						else
+							return -EFAULT;
+					}
+					if (ret & VM_FAULT_SIGBUS)
+						return i ? i : -EFAULT;
+					BUG();
+				}
+
+				if (tsk) {
+					if (ret & VM_FAULT_MAJOR)
+						tsk->maj_flt++;
+					else
+						tsk->min_flt++;
+				}
+
+				if (ret & VM_FAULT_RETRY) {
+					if (nonblocking)
+						*nonblocking = 0;
+					return i;
+				}
+
+				/*
+				 * The VM_FAULT_WRITE bit tells us that
+				 * do_wp_page has broken COW when necessary,
+				 * even if maybe_mkwrite decided not to set
+				 * pte_write. We can thus safely do subsequent
+				 * page lookups as if they were reads. But only
+				 * do so when looping for pte_write is futile:
+				 * in some cases userspace may also be wanting
+				 * to write to the gotten user page, which a
+				 * read fault here might prevent (a readonly
+				 * page might get reCOWed by userspace write).
+				 */
+				if ((ret & VM_FAULT_WRITE) &&
+				    !(vma->vm_flags & VM_WRITE))
+					foll_flags &= ~FOLL_WRITE;
+
+				cond_resched();
+			}
+			if (IS_ERR(page))
+				return i ? i : PTR_ERR(page);
+			if (pages) {
+				pages[i] = page;
+
+				flush_anon_page(vma, page, start);
+				flush_dcache_page(page);
+				page_mask = 0;
+			}
+next_page:
+			if (vmas) {
+				vmas[i] = vma;
+				page_mask = 0;
+			}
+			page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
+			if (page_increm > nr_pages)
+				page_increm = nr_pages;
+			i += page_increm;
+			start += page_increm * PAGE_SIZE;
+			nr_pages -= page_increm;
+		} while (nr_pages && start < vma->vm_end);
+	} while (nr_pages);
+	return i;
+}
+EXPORT_SYMBOL(__get_user_pages);
+
+/*
+ * fixup_user_fault() - manually resolve a user page fault
+ * @tsk:	the task_struct to use for page fault accounting, or
+ *		NULL if faults are not to be recorded.
+ * @mm:		mm_struct of target mm
+ * @address:	user address
+ * @fault_flags:flags to pass down to handle_mm_fault()
+ *
+ * This is meant to be called in the specific scenario where for locking reasons
+ * we try to access user memory in atomic context (within a pagefault_disable()
+ * section), this returns -EFAULT, and we want to resolve the user fault before
+ * trying again.
+ *
+ * Typically this is meant to be used by the futex code.
+ *
+ * The main difference with get_user_pages() is that this function will
+ * unconditionally call handle_mm_fault() which will in turn perform all the
+ * necessary SW fixup of the dirty and young bits in the PTE, while
+ * handle_mm_fault() only guarantees to update these in the struct page.
+ *
+ * This is important for some architectures where those bits also gate the
+ * access permission to the page because they are maintained in software.  On
+ * such architectures, gup() will not be enough to make a subsequent access
+ * succeed.
+ *
+ * This should be called with the mm_sem held for read.
+ */
+int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
+		     unsigned long address, unsigned int fault_flags)
+{
+	struct vm_area_struct *vma;
+	int ret;
+
+	vma = find_extend_vma(mm, address);
+	if (!vma || address < vma->vm_start)
+		return -EFAULT;
+
+	ret = handle_mm_fault(mm, vma, address, fault_flags);
+	if (ret & VM_FAULT_ERROR) {
+		if (ret & VM_FAULT_OOM)
+			return -ENOMEM;
+		if (ret & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))
+			return -EHWPOISON;
+		if (ret & VM_FAULT_SIGBUS)
+			return -EFAULT;
+		BUG();
+	}
+	if (tsk) {
+		if (ret & VM_FAULT_MAJOR)
+			tsk->maj_flt++;
+		else
+			tsk->min_flt++;
+	}
+	return 0;
+}
+
+/*
+ * get_user_pages() - pin user pages in memory
+ * @tsk:	the task_struct to use for page fault accounting, or
+ *		NULL if faults are not to be recorded.
+ * @mm:		mm_struct of target mm
+ * @start:	starting user address
+ * @nr_pages:	number of pages from start to pin
+ * @write:	whether pages will be written to by the caller
+ * @force:	whether to force write access even if user mapping is
+ *		readonly. This will result in the page being COWed even
+ *		in MAP_SHARED mappings. You do not want this.
+ * @pages:	array that receives pointers to the pages pinned.
+ *		Should be at least nr_pages long. Or NULL, if caller
+ *		only intends to ensure the pages are faulted in.
+ * @vmas:	array of pointers to vmas corresponding to each page.
+ *		Or NULL if the caller does not require them.
+ *
+ * Returns number of pages pinned. This may be fewer than the number
+ * requested. If nr_pages is 0 or negative, returns 0. If no pages
+ * were pinned, returns -errno. Each page returned must be released
+ * with a put_page() call when it is finished with. vmas will only
+ * remain valid while mmap_sem is held.
+ *
+ * Must be called with mmap_sem held for read or write.
+ *
+ * get_user_pages walks a process's page tables and takes a reference to
+ * each struct page that each user address corresponds to at a given
+ * instant. That is, it takes the page that would be accessed if a user
+ * thread accesses the given user virtual address at that instant.
+ *
+ * This does not guarantee that the page exists in the user mappings when
+ * get_user_pages returns, and there may even be a completely different
+ * page there in some cases (eg. if mmapped pagecache has been invalidated
+ * and subsequently re faulted). However it does guarantee that the page
+ * won't be freed completely. And mostly callers simply care that the page
+ * contains data that was valid *at some point in time*. Typically, an IO
+ * or similar operation cannot guarantee anything stronger anyway because
+ * locks can't be held over the syscall boundary.
+ *
+ * If write=0, the page must not be written to. If the page is written to,
+ * set_page_dirty (or set_page_dirty_lock, as appropriate) must be called
+ * after the page is finished with, and before put_page is called.
+ *
+ * get_user_pages is typically used for fewer-copy IO operations, to get a
+ * handle on the memory by some means other than accesses via the user virtual
+ * addresses. The pages may be submitted for DMA to devices or accessed via
+ * their kernel linear mapping (via the kmap APIs). Care should be taken to
+ * use the correct cache flushing APIs.
+ *
+ * See also get_user_pages_fast, for performance critical applications.
+ */
+long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, unsigned long nr_pages, int write,
+		int force, struct page **pages, struct vm_area_struct **vmas)
+{
+	int flags = FOLL_TOUCH;
+
+	if (pages)
+		flags |= FOLL_GET;
+	if (write)
+		flags |= FOLL_WRITE;
+	if (force)
+		flags |= FOLL_FORCE;
+
+	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas,
+				NULL);
+}
+EXPORT_SYMBOL(get_user_pages);
+
+/**
+ * get_dump_page() - pin user page in memory while writing it to core dump
+ * @addr: user address
+ *
+ * Returns struct page pointer of user page pinned for dump,
+ * to be freed afterwards by page_cache_release() or put_page().
+ *
+ * Returns NULL on any kind of failure - a hole must then be inserted into
+ * the corefile, to preserve alignment with its headers; and also returns
+ * NULL wherever the ZERO_PAGE, or an anonymous pte_none, has been found -
+ * allowing a hole to be left in the corefile to save diskspace.
+ *
+ * Called without mmap_sem, but after all other threads have been killed.
+ */
+#ifdef CONFIG_ELF_CORE
+struct page *get_dump_page(unsigned long addr)
+{
+	struct vm_area_struct *vma;
+	struct page *page;
+
+	if (__get_user_pages(current, current->mm, addr, 1,
+			     FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma,
+			     NULL) < 1)
+		return NULL;
+	flush_cache_page(vma, addr, page_to_pfn(page));
+	return page;
+}
+#endif /* CONFIG_ELF_CORE */
diff --git a/mm/memory.c b/mm/memory.c
index 22dfa617bddb..5731badfa67f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1441,617 +1441,6 @@ int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 }
 EXPORT_SYMBOL_GPL(zap_vma_ptes);
 
-/**
- * follow_page_mask - look up a page descriptor from a user-virtual address
- * @vma: vm_area_struct mapping @address
- * @address: virtual address to look up
- * @flags: flags modifying lookup behaviour
- * @page_mask: on output, *page_mask is set according to the size of the page
- *
- * @flags can have FOLL_ flags set, defined in <linux/mm.h>
- *
- * Returns the mapped (struct page *), %NULL if no mapping exists, or
- * an error pointer if there is a mapping to something not represented
- * by a page descriptor (see also vm_normal_page()).
- */
-struct page *follow_page_mask(struct vm_area_struct *vma,
-			      unsigned long address, unsigned int flags,
-			      unsigned int *page_mask)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *ptep, pte;
-	spinlock_t *ptl;
-	struct page *page;
-	struct mm_struct *mm = vma->vm_mm;
-
-	*page_mask = 0;
-
-	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
-	if (!IS_ERR(page)) {
-		BUG_ON(flags & FOLL_GET);
-		goto out;
-	}
-
-	page = NULL;
-	pgd = pgd_offset(mm, address);
-	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
-		goto no_page_table;
-
-	pud = pud_offset(pgd, address);
-	if (pud_none(*pud))
-		goto no_page_table;
-	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
-		if (flags & FOLL_GET)
-			goto out;
-		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
-		goto out;
-	}
-	if (unlikely(pud_bad(*pud)))
-		goto no_page_table;
-
-	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd))
-		goto no_page_table;
-	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
-		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
-		if (flags & FOLL_GET) {
-			/*
-			 * Refcount on tail pages are not well-defined and
-			 * shouldn't be taken. The caller should handle a NULL
-			 * return when trying to follow tail pages.
-			 */
-			if (PageHead(page))
-				get_page(page);
-			else {
-				page = NULL;
-				goto out;
-			}
-		}
-		goto out;
-	}
-	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
-		goto no_page_table;
-	if (pmd_trans_huge(*pmd)) {
-		if (flags & FOLL_SPLIT) {
-			split_huge_page_pmd(vma, address, pmd);
-			goto split_fallthrough;
-		}
-		ptl = pmd_lock(mm, pmd);
-		if (likely(pmd_trans_huge(*pmd))) {
-			if (unlikely(pmd_trans_splitting(*pmd))) {
-				spin_unlock(ptl);
-				wait_split_huge_page(vma->anon_vma, pmd);
-			} else {
-				page = follow_trans_huge_pmd(vma, address,
-							     pmd, flags);
-				spin_unlock(ptl);
-				*page_mask = HPAGE_PMD_NR - 1;
-				goto out;
-			}
-		} else
-			spin_unlock(ptl);
-		/* fall through */
-	}
-split_fallthrough:
-	if (unlikely(pmd_bad(*pmd)))
-		goto no_page_table;
-
-	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
-
-	pte = *ptep;
-	if (!pte_present(pte)) {
-		swp_entry_t entry;
-		/*
-		 * KSM's break_ksm() relies upon recognizing a ksm page
-		 * even while it is being migrated, so for that case we
-		 * need migration_entry_wait().
-		 */
-		if (likely(!(flags & FOLL_MIGRATION)))
-			goto no_page;
-		if (pte_none(pte) || pte_file(pte))
-			goto no_page;
-		entry = pte_to_swp_entry(pte);
-		if (!is_migration_entry(entry))
-			goto no_page;
-		pte_unmap_unlock(ptep, ptl);
-		migration_entry_wait(mm, pmd, address);
-		goto split_fallthrough;
-	}
-	if ((flags & FOLL_NUMA) && pte_numa(pte))
-		goto no_page;
-	if ((flags & FOLL_WRITE) && !pte_write(pte))
-		goto unlock;
-
-	page = vm_normal_page(vma, address, pte);
-	if (unlikely(!page)) {
-		if ((flags & FOLL_DUMP) ||
-		    !is_zero_pfn(pte_pfn(pte)))
-			goto bad_page;
-		page = pte_page(pte);
-	}
-
-	if (flags & FOLL_GET)
-		get_page_foll(page);
-	if (flags & FOLL_TOUCH) {
-		if ((flags & FOLL_WRITE) &&
-		    !pte_dirty(pte) && !PageDirty(page))
-			set_page_dirty(page);
-		/*
-		 * pte_mkyoung() would be more correct here, but atomic care
-		 * is needed to avoid losing the dirty bit: it is easier to use
-		 * mark_page_accessed().
-		 */
-		mark_page_accessed(page);
-	}
-	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
-		/*
-		 * The preliminary mapping check is mainly to avoid the
-		 * pointless overhead of lock_page on the ZERO_PAGE
-		 * which might bounce very badly if there is contention.
-		 *
-		 * If the page is already locked, we don't need to
-		 * handle it now - vmscan will handle it later if and
-		 * when it attempts to reclaim the page.
-		 */
-		if (page->mapping && trylock_page(page)) {
-			lru_add_drain();  /* push cached pages to LRU */
-			/*
-			 * Because we lock page here, and migration is
-			 * blocked by the pte's page reference, and we
-			 * know the page is still mapped, we don't even
-			 * need to check for file-cache page truncation.
-			 */
-			mlock_vma_page(page);
-			unlock_page(page);
-		}
-	}
-unlock:
-	pte_unmap_unlock(ptep, ptl);
-out:
-	return page;
-
-bad_page:
-	pte_unmap_unlock(ptep, ptl);
-	return ERR_PTR(-EFAULT);
-
-no_page:
-	pte_unmap_unlock(ptep, ptl);
-	if (!pte_none(pte))
-		return page;
-
-no_page_table:
-	/*
-	 * When core dumping an enormous anonymous area that nobody
-	 * has touched so far, we don't want to allocate unnecessary pages or
-	 * page tables.  Return error instead of NULL to skip handle_mm_fault,
-	 * then get_dump_page() will return NULL to leave a hole in the dump.
-	 * But we can only make this optimization where a hole would surely
-	 * be zero-filled if handle_mm_fault() actually did handle it.
-	 */
-	if ((flags & FOLL_DUMP) &&
-	    (!vma->vm_ops || !vma->vm_ops->fault))
-		return ERR_PTR(-EFAULT);
-	return page;
-}
-
-static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long addr)
-{
-	return stack_guard_page_start(vma, addr) ||
-	       stack_guard_page_end(vma, addr+PAGE_SIZE);
-}
-
-/**
- * __get_user_pages() - pin user pages in memory
- * @tsk:	task_struct of target task
- * @mm:		mm_struct of target mm
- * @start:	starting user address
- * @nr_pages:	number of pages from start to pin
- * @gup_flags:	flags modifying pin behaviour
- * @pages:	array that receives pointers to the pages pinned.
- *		Should be at least nr_pages long. Or NULL, if caller
- *		only intends to ensure the pages are faulted in.
- * @vmas:	array of pointers to vmas corresponding to each page.
- *		Or NULL if the caller does not require them.
- * @nonblocking: whether waiting for disk IO or mmap_sem contention
- *
- * Returns number of pages pinned. This may be fewer than the number
- * requested. If nr_pages is 0 or negative, returns 0. If no pages
- * were pinned, returns -errno. Each page returned must be released
- * with a put_page() call when it is finished with. vmas will only
- * remain valid while mmap_sem is held.
- *
- * Must be called with mmap_sem held for read or write.
- *
- * __get_user_pages walks a process's page tables and takes a reference to
- * each struct page that each user address corresponds to at a given
- * instant. That is, it takes the page that would be accessed if a user
- * thread accesses the given user virtual address at that instant.
- *
- * This does not guarantee that the page exists in the user mappings when
- * __get_user_pages returns, and there may even be a completely different
- * page there in some cases (eg. if mmapped pagecache has been invalidated
- * and subsequently re faulted). However it does guarantee that the page
- * won't be freed completely. And mostly callers simply care that the page
- * contains data that was valid *at some point in time*. Typically, an IO
- * or similar operation cannot guarantee anything stronger anyway because
- * locks can't be held over the syscall boundary.
- *
- * If @gup_flags & FOLL_WRITE == 0, the page must not be written to. If
- * the page is written to, set_page_dirty (or set_page_dirty_lock, as
- * appropriate) must be called after the page is finished with, and
- * before put_page is called.
- *
- * If @nonblocking != NULL, __get_user_pages will not wait for disk IO
- * or mmap_sem contention, and if waiting is needed to pin all pages,
- * *@nonblocking will be set to 0.
- *
- * In most cases, get_user_pages or get_user_pages_fast should be used
- * instead of __get_user_pages. __get_user_pages should be used only if
- * you need some special @gup_flags.
- */
-long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, unsigned long nr_pages,
-		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *nonblocking)
-{
-	long i;
-	unsigned long vm_flags;
-	unsigned int page_mask;
-
-	if (!nr_pages)
-		return 0;
-
-	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
-
-	/* 
-	 * Require read or write permissions.
-	 * If FOLL_FORCE is set, we only require the "MAY" flags.
-	 */
-	vm_flags  = (gup_flags & FOLL_WRITE) ?
-			(VM_WRITE | VM_MAYWRITE) : (VM_READ | VM_MAYREAD);
-	vm_flags &= (gup_flags & FOLL_FORCE) ?
-			(VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
-
-	/*
-	 * If FOLL_FORCE and FOLL_NUMA are both set, handle_mm_fault
-	 * would be called on PROT_NONE ranges. We must never invoke
-	 * handle_mm_fault on PROT_NONE ranges or the NUMA hinting
-	 * page faults would unprotect the PROT_NONE ranges if
-	 * _PAGE_NUMA and _PAGE_PROTNONE are sharing the same pte/pmd
-	 * bitflag. So to avoid that, don't set FOLL_NUMA if
-	 * FOLL_FORCE is set.
-	 */
-	if (!(gup_flags & FOLL_FORCE))
-		gup_flags |= FOLL_NUMA;
-
-	i = 0;
-
-	do {
-		struct vm_area_struct *vma;
-
-		vma = find_extend_vma(mm, start);
-		if (!vma && in_gate_area(mm, start)) {
-			unsigned long pg = start & PAGE_MASK;
-			pgd_t *pgd;
-			pud_t *pud;
-			pmd_t *pmd;
-			pte_t *pte;
-
-			/* user gate pages are read-only */
-			if (gup_flags & FOLL_WRITE)
-				return i ? : -EFAULT;
-			if (pg > TASK_SIZE)
-				pgd = pgd_offset_k(pg);
-			else
-				pgd = pgd_offset_gate(mm, pg);
-			BUG_ON(pgd_none(*pgd));
-			pud = pud_offset(pgd, pg);
-			BUG_ON(pud_none(*pud));
-			pmd = pmd_offset(pud, pg);
-			if (pmd_none(*pmd))
-				return i ? : -EFAULT;
-			VM_BUG_ON(pmd_trans_huge(*pmd));
-			pte = pte_offset_map(pmd, pg);
-			if (pte_none(*pte)) {
-				pte_unmap(pte);
-				return i ? : -EFAULT;
-			}
-			vma = get_gate_vma(mm);
-			if (pages) {
-				struct page *page;
-
-				page = vm_normal_page(vma, start, *pte);
-				if (!page) {
-					if (!(gup_flags & FOLL_DUMP) &&
-					     is_zero_pfn(pte_pfn(*pte)))
-						page = pte_page(*pte);
-					else {
-						pte_unmap(pte);
-						return i ? : -EFAULT;
-					}
-				}
-				pages[i] = page;
-				get_page(page);
-			}
-			pte_unmap(pte);
-			page_mask = 0;
-			goto next_page;
-		}
-
-		if (!vma ||
-		    (vma->vm_flags & (VM_IO | VM_PFNMAP)) ||
-		    !(vm_flags & vma->vm_flags))
-			return i ? : -EFAULT;
-
-		if (is_vm_hugetlb_page(vma)) {
-			i = follow_hugetlb_page(mm, vma, pages, vmas,
-					&start, &nr_pages, i, gup_flags);
-			continue;
-		}
-
-		do {
-			struct page *page;
-			unsigned int foll_flags = gup_flags;
-			unsigned int page_increm;
-
-			/*
-			 * If we have a pending SIGKILL, don't keep faulting
-			 * pages and potentially allocating memory.
-			 */
-			if (unlikely(fatal_signal_pending(current)))
-				return i ? i : -ERESTARTSYS;
-
-			cond_resched();
-			while (!(page = follow_page_mask(vma, start,
-						foll_flags, &page_mask))) {
-				int ret;
-				unsigned int fault_flags = 0;
-
-				/* For mlock, just skip the stack guard page. */
-				if (foll_flags & FOLL_MLOCK) {
-					if (stack_guard_page(vma, start))
-						goto next_page;
-				}
-				if (foll_flags & FOLL_WRITE)
-					fault_flags |= FAULT_FLAG_WRITE;
-				if (nonblocking)
-					fault_flags |= FAULT_FLAG_ALLOW_RETRY;
-				if (foll_flags & FOLL_NOWAIT)
-					fault_flags |= (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT);
-
-				ret = handle_mm_fault(mm, vma, start,
-							fault_flags);
-
-				if (ret & VM_FAULT_ERROR) {
-					if (ret & VM_FAULT_OOM)
-						return i ? i : -ENOMEM;
-					if (ret & (VM_FAULT_HWPOISON |
-						   VM_FAULT_HWPOISON_LARGE)) {
-						if (i)
-							return i;
-						else if (gup_flags & FOLL_HWPOISON)
-							return -EHWPOISON;
-						else
-							return -EFAULT;
-					}
-					if (ret & VM_FAULT_SIGBUS)
-						return i ? i : -EFAULT;
-					BUG();
-				}
-
-				if (tsk) {
-					if (ret & VM_FAULT_MAJOR)
-						tsk->maj_flt++;
-					else
-						tsk->min_flt++;
-				}
-
-				if (ret & VM_FAULT_RETRY) {
-					if (nonblocking)
-						*nonblocking = 0;
-					return i;
-				}
-
-				/*
-				 * The VM_FAULT_WRITE bit tells us that
-				 * do_wp_page has broken COW when necessary,
-				 * even if maybe_mkwrite decided not to set
-				 * pte_write. We can thus safely do subsequent
-				 * page lookups as if they were reads. But only
-				 * do so when looping for pte_write is futile:
-				 * in some cases userspace may also be wanting
-				 * to write to the gotten user page, which a
-				 * read fault here might prevent (a readonly
-				 * page might get reCOWed by userspace write).
-				 */
-				if ((ret & VM_FAULT_WRITE) &&
-				    !(vma->vm_flags & VM_WRITE))
-					foll_flags &= ~FOLL_WRITE;
-
-				cond_resched();
-			}
-			if (IS_ERR(page))
-				return i ? i : PTR_ERR(page);
-			if (pages) {
-				pages[i] = page;
-
-				flush_anon_page(vma, page, start);
-				flush_dcache_page(page);
-				page_mask = 0;
-			}
-next_page:
-			if (vmas) {
-				vmas[i] = vma;
-				page_mask = 0;
-			}
-			page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
-			if (page_increm > nr_pages)
-				page_increm = nr_pages;
-			i += page_increm;
-			start += page_increm * PAGE_SIZE;
-			nr_pages -= page_increm;
-		} while (nr_pages && start < vma->vm_end);
-	} while (nr_pages);
-	return i;
-}
-EXPORT_SYMBOL(__get_user_pages);
-
-/*
- * fixup_user_fault() - manually resolve a user page fault
- * @tsk:	the task_struct to use for page fault accounting, or
- *		NULL if faults are not to be recorded.
- * @mm:		mm_struct of target mm
- * @address:	user address
- * @fault_flags:flags to pass down to handle_mm_fault()
- *
- * This is meant to be called in the specific scenario where for locking reasons
- * we try to access user memory in atomic context (within a pagefault_disable()
- * section), this returns -EFAULT, and we want to resolve the user fault before
- * trying again.
- *
- * Typically this is meant to be used by the futex code.
- *
- * The main difference with get_user_pages() is that this function will
- * unconditionally call handle_mm_fault() which will in turn perform all the
- * necessary SW fixup of the dirty and young bits in the PTE, while
- * handle_mm_fault() only guarantees to update these in the struct page.
- *
- * This is important for some architectures where those bits also gate the
- * access permission to the page because they are maintained in software.  On
- * such architectures, gup() will not be enough to make a subsequent access
- * succeed.
- *
- * This should be called with the mm_sem held for read.
- */
-int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
-		     unsigned long address, unsigned int fault_flags)
-{
-	struct vm_area_struct *vma;
-	int ret;
-
-	vma = find_extend_vma(mm, address);
-	if (!vma || address < vma->vm_start)
-		return -EFAULT;
-
-	ret = handle_mm_fault(mm, vma, address, fault_flags);
-	if (ret & VM_FAULT_ERROR) {
-		if (ret & VM_FAULT_OOM)
-			return -ENOMEM;
-		if (ret & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))
-			return -EHWPOISON;
-		if (ret & VM_FAULT_SIGBUS)
-			return -EFAULT;
-		BUG();
-	}
-	if (tsk) {
-		if (ret & VM_FAULT_MAJOR)
-			tsk->maj_flt++;
-		else
-			tsk->min_flt++;
-	}
-	return 0;
-}
-
-/*
- * get_user_pages() - pin user pages in memory
- * @tsk:	the task_struct to use for page fault accounting, or
- *		NULL if faults are not to be recorded.
- * @mm:		mm_struct of target mm
- * @start:	starting user address
- * @nr_pages:	number of pages from start to pin
- * @write:	whether pages will be written to by the caller
- * @force:	whether to force write access even if user mapping is
- *		readonly. This will result in the page being COWed even
- *		in MAP_SHARED mappings. You do not want this.
- * @pages:	array that receives pointers to the pages pinned.
- *		Should be at least nr_pages long. Or NULL, if caller
- *		only intends to ensure the pages are faulted in.
- * @vmas:	array of pointers to vmas corresponding to each page.
- *		Or NULL if the caller does not require them.
- *
- * Returns number of pages pinned. This may be fewer than the number
- * requested. If nr_pages is 0 or negative, returns 0. If no pages
- * were pinned, returns -errno. Each page returned must be released
- * with a put_page() call when it is finished with. vmas will only
- * remain valid while mmap_sem is held.
- *
- * Must be called with mmap_sem held for read or write.
- *
- * get_user_pages walks a process's page tables and takes a reference to
- * each struct page that each user address corresponds to at a given
- * instant. That is, it takes the page that would be accessed if a user
- * thread accesses the given user virtual address at that instant.
- *
- * This does not guarantee that the page exists in the user mappings when
- * get_user_pages returns, and there may even be a completely different
- * page there in some cases (eg. if mmapped pagecache has been invalidated
- * and subsequently re faulted). However it does guarantee that the page
- * won't be freed completely. And mostly callers simply care that the page
- * contains data that was valid *at some point in time*. Typically, an IO
- * or similar operation cannot guarantee anything stronger anyway because
- * locks can't be held over the syscall boundary.
- *
- * If write=0, the page must not be written to. If the page is written to,
- * set_page_dirty (or set_page_dirty_lock, as appropriate) must be called
- * after the page is finished with, and before put_page is called.
- *
- * get_user_pages is typically used for fewer-copy IO operations, to get a
- * handle on the memory by some means other than accesses via the user virtual
- * addresses. The pages may be submitted for DMA to devices or accessed via
- * their kernel linear mapping (via the kmap APIs). Care should be taken to
- * use the correct cache flushing APIs.
- *
- * See also get_user_pages_fast, for performance critical applications.
- */
-long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, unsigned long nr_pages, int write,
-		int force, struct page **pages, struct vm_area_struct **vmas)
-{
-	int flags = FOLL_TOUCH;
-
-	if (pages)
-		flags |= FOLL_GET;
-	if (write)
-		flags |= FOLL_WRITE;
-	if (force)
-		flags |= FOLL_FORCE;
-
-	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas,
-				NULL);
-}
-EXPORT_SYMBOL(get_user_pages);
-
-/**
- * get_dump_page() - pin user page in memory while writing it to core dump
- * @addr: user address
- *
- * Returns struct page pointer of user page pinned for dump,
- * to be freed afterwards by page_cache_release() or put_page().
- *
- * Returns NULL on any kind of failure - a hole must then be inserted into
- * the corefile, to preserve alignment with its headers; and also returns
- * NULL wherever the ZERO_PAGE, or an anonymous pte_none, has been found -
- * allowing a hole to be left in the corefile to save diskspace.
- *
- * Called without mmap_sem, but after all other threads have been killed.
- */
-#ifdef CONFIG_ELF_CORE
-struct page *get_dump_page(unsigned long addr)
-{
-	struct vm_area_struct *vma;
-	struct page *page;
-
-	if (__get_user_pages(current, current->mm, addr, 1,
-			     FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma,
-			     NULL) < 1)
-		return NULL;
-	flush_cache_page(vma, addr, page_to_pfn(page));
-	return page;
-}
-#endif /* CONFIG_ELF_CORE */
-
 pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
 			spinlock_t **ptl)
 {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
