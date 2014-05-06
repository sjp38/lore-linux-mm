Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3001A82963
	for <linux-mm@kvack.org>; Tue,  6 May 2014 10:38:11 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so6234236pab.3
        for <linux-mm@kvack.org>; Tue, 06 May 2014 07:38:10 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id ug9si12121733pab.212.2014.05.06.07.38.09
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 07:38:10 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/8] mm: replace remap_file_pages() syscall with emulation
Date: Tue,  6 May 2014 17:37:25 +0300
Message-Id: <1399387052-31660-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

remap_file_pages(2) was invented to be able efficiently map parts of
huge file into limited 32-bit virtual address space such as in database
workloads.

Nonlinear mappings are pain to support and it seems there's no
legitimate use-cases nowadays since 64-bit systems are widely available.

Let's drop it and get rid of all these special-cased code.

The patch replaces the syscall with emulation which creates new VMA on
each remap.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/fs.h |   8 +-
 mm/Makefile        |   2 +-
 mm/fremap.c        | 282 -----------------------------------------------------
 mm/mmap.c          |  68 +++++++++++++
 mm/nommu.c         |   8 --
 5 files changed, 75 insertions(+), 293 deletions(-)
 delete mode 100644 mm/fremap.c

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 878031227c57..b7cda7d95ea0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2401,8 +2401,12 @@ extern int sb_min_blocksize(struct super_block *, int);
 
 extern int generic_file_mmap(struct file *, struct vm_area_struct *);
 extern int generic_file_readonly_mmap(struct file *, struct vm_area_struct *);
-extern int generic_file_remap_pages(struct vm_area_struct *, unsigned long addr,
-		unsigned long size, pgoff_t pgoff);
+static inline int generic_file_remap_pages(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long size, pgoff_t pgoff)
+{
+	BUG();
+	return 0;
+}
 int generic_write_checks(struct file *file, loff_t *pos, size_t *count, int isblk);
 extern ssize_t generic_file_aio_read(struct kiocb *, const struct iovec *, unsigned long, loff_t);
 extern ssize_t __generic_file_aio_write(struct kiocb *, const struct iovec *, unsigned long);
diff --git a/mm/Makefile b/mm/Makefile
index b484452dac57..27e3e30be39b 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -3,7 +3,7 @@
 #
 
 mmu-y			:= nommu.o
-mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
+mmu-$(CONFIG_MMU)	:= highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
 			   vmalloc.o pagewalk.o pgtable-generic.o
 
diff --git a/mm/fremap.c b/mm/fremap.c
deleted file mode 100644
index 34feba60a17e..000000000000
--- a/mm/fremap.c
+++ /dev/null
@@ -1,282 +0,0 @@
-/*
- *   linux/mm/fremap.c
- * 
- * Explicit pagetable population and nonlinear (random) mappings support.
- *
- * started by Ingo Molnar, Copyright (C) 2002, 2003
- */
-#include <linux/export.h>
-#include <linux/backing-dev.h>
-#include <linux/mm.h>
-#include <linux/swap.h>
-#include <linux/file.h>
-#include <linux/mman.h>
-#include <linux/pagemap.h>
-#include <linux/swapops.h>
-#include <linux/rmap.h>
-#include <linux/syscalls.h>
-#include <linux/mmu_notifier.h>
-
-#include <asm/mmu_context.h>
-#include <asm/cacheflush.h>
-#include <asm/tlbflush.h>
-
-#include "internal.h"
-
-static int mm_counter(struct page *page)
-{
-	return PageAnon(page) ? MM_ANONPAGES : MM_FILEPAGES;
-}
-
-static void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long addr, pte_t *ptep)
-{
-	pte_t pte = *ptep;
-	struct page *page;
-	swp_entry_t entry;
-
-	if (pte_present(pte)) {
-		flush_cache_page(vma, addr, pte_pfn(pte));
-		pte = ptep_clear_flush(vma, addr, ptep);
-		page = vm_normal_page(vma, addr, pte);
-		if (page) {
-			if (pte_dirty(pte))
-				set_page_dirty(page);
-			update_hiwater_rss(mm);
-			dec_mm_counter(mm, mm_counter(page));
-			page_remove_rmap(page);
-			page_cache_release(page);
-		}
-	} else {	/* zap_pte() is not called when pte_none() */
-		if (!pte_file(pte)) {
-			update_hiwater_rss(mm);
-			entry = pte_to_swp_entry(pte);
-			if (non_swap_entry(entry)) {
-				if (is_migration_entry(entry)) {
-					page = migration_entry_to_page(entry);
-					dec_mm_counter(mm, mm_counter(page));
-				}
-			} else {
-				free_swap_and_cache(entry);
-				dec_mm_counter(mm, MM_SWAPENTS);
-			}
-		}
-		pte_clear_not_present_full(mm, addr, ptep, 0);
-	}
-}
-
-/*
- * Install a file pte to a given virtual memory address, release any
- * previously existing mapping.
- */
-static int install_file_pte(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long addr, unsigned long pgoff, pgprot_t prot)
-{
-	int err = -ENOMEM;
-	pte_t *pte, ptfile;
-	spinlock_t *ptl;
-
-	pte = get_locked_pte(mm, addr, &ptl);
-	if (!pte)
-		goto out;
-
-	ptfile = pgoff_to_pte(pgoff);
-
-	if (!pte_none(*pte)) {
-		if (pte_present(*pte) && pte_soft_dirty(*pte))
-			pte_file_mksoft_dirty(ptfile);
-		zap_pte(mm, vma, addr, pte);
-	}
-
-	set_pte_at(mm, addr, pte, ptfile);
-	/*
-	 * We don't need to run update_mmu_cache() here because the "file pte"
-	 * being installed by install_file_pte() is not a real pte - it's a
-	 * non-present entry (like a swap entry), noting what file offset should
-	 * be mapped there when there's a fault (in a non-linear vma where
-	 * that's not obvious).
-	 */
-	pte_unmap_unlock(pte, ptl);
-	err = 0;
-out:
-	return err;
-}
-
-int generic_file_remap_pages(struct vm_area_struct *vma, unsigned long addr,
-			     unsigned long size, pgoff_t pgoff)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	int err;
-
-	do {
-		err = install_file_pte(mm, vma, addr, pgoff, vma->vm_page_prot);
-		if (err)
-			return err;
-
-		size -= PAGE_SIZE;
-		addr += PAGE_SIZE;
-		pgoff++;
-	} while (size);
-
-	return 0;
-}
-EXPORT_SYMBOL(generic_file_remap_pages);
-
-/**
- * sys_remap_file_pages - remap arbitrary pages of an existing VM_SHARED vma
- * @start: start of the remapped virtual memory range
- * @size: size of the remapped virtual memory range
- * @prot: new protection bits of the range (see NOTE)
- * @pgoff: to-be-mapped page of the backing store file
- * @flags: 0 or MAP_NONBLOCKED - the later will cause no IO.
- *
- * sys_remap_file_pages remaps arbitrary pages of an existing VM_SHARED vma
- * (shared backing store file).
- *
- * This syscall works purely via pagetables, so it's the most efficient
- * way to map the same (large) file into a given virtual window. Unlike
- * mmap()/mremap() it does not create any new vmas. The new mappings are
- * also safe across swapout.
- *
- * NOTE: the @prot parameter right now is ignored (but must be zero),
- * and the vma's default protection is used. Arbitrary protections
- * might be implemented in the future.
- */
-SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
-		unsigned long, prot, unsigned long, pgoff, unsigned long, flags)
-{
-	struct mm_struct *mm = current->mm;
-	struct address_space *mapping;
-	struct vm_area_struct *vma;
-	int err = -EINVAL;
-	int has_write_lock = 0;
-	vm_flags_t vm_flags = 0;
-
-	if (prot)
-		return err;
-	/*
-	 * Sanitize the syscall parameters:
-	 */
-	start = start & PAGE_MASK;
-	size = size & PAGE_MASK;
-
-	/* Does the address range wrap, or is the span zero-sized? */
-	if (start + size <= start)
-		return err;
-
-	/* Does pgoff wrap? */
-	if (pgoff + (size >> PAGE_SHIFT) < pgoff)
-		return err;
-
-	/* Can we represent this offset inside this architecture's pte's? */
-#if PTE_FILE_MAX_BITS < BITS_PER_LONG
-	if (pgoff + (size >> PAGE_SHIFT) >= (1UL << PTE_FILE_MAX_BITS))
-		return err;
-#endif
-
-	/* We need down_write() to change vma->vm_flags. */
-	down_read(&mm->mmap_sem);
- retry:
-	vma = find_vma(mm, start);
-
-	/*
-	 * Make sure the vma is shared, that it supports prefaulting,
-	 * and that the remapped range is valid and fully within
-	 * the single existing vma.
-	 */
-	if (!vma || !(vma->vm_flags & VM_SHARED))
-		goto out;
-
-	if (!vma->vm_ops || !vma->vm_ops->remap_pages)
-		goto out;
-
-	if (start < vma->vm_start || start + size > vma->vm_end)
-		goto out;
-
-	/* Must set VM_NONLINEAR before any pages are populated. */
-	if (!(vma->vm_flags & VM_NONLINEAR)) {
-		/*
-		 * vm_private_data is used as a swapout cursor
-		 * in a VM_NONLINEAR vma.
-		 */
-		if (vma->vm_private_data)
-			goto out;
-
-		/* Don't need a nonlinear mapping, exit success */
-		if (pgoff == linear_page_index(vma, start)) {
-			err = 0;
-			goto out;
-		}
-
-		if (!has_write_lock) {
-get_write_lock:
-			up_read(&mm->mmap_sem);
-			down_write(&mm->mmap_sem);
-			has_write_lock = 1;
-			goto retry;
-		}
-		mapping = vma->vm_file->f_mapping;
-		/*
-		 * page_mkclean doesn't work on nonlinear vmas, so if
-		 * dirty pages need to be accounted, emulate with linear
-		 * vmas.
-		 */
-		if (mapping_cap_account_dirty(mapping)) {
-			unsigned long addr;
-			struct file *file = get_file(vma->vm_file);
-			/* mmap_region may free vma; grab the info now */
-			vm_flags = vma->vm_flags;
-
-			addr = mmap_region(file, start, size, vm_flags, pgoff);
-			fput(file);
-			if (IS_ERR_VALUE(addr)) {
-				err = addr;
-			} else {
-				BUG_ON(addr != start);
-				err = 0;
-			}
-			goto out_freed;
-		}
-		mutex_lock(&mapping->i_mmap_mutex);
-		flush_dcache_mmap_lock(mapping);
-		vma->vm_flags |= VM_NONLINEAR;
-		vma_interval_tree_remove(vma, &mapping->i_mmap);
-		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
-		flush_dcache_mmap_unlock(mapping);
-		mutex_unlock(&mapping->i_mmap_mutex);
-	}
-
-	if (vma->vm_flags & VM_LOCKED) {
-		/*
-		 * drop PG_Mlocked flag for over-mapped range
-		 */
-		if (!has_write_lock)
-			goto get_write_lock;
-		vm_flags = vma->vm_flags;
-		munlock_vma_pages_range(vma, start, start + size);
-		vma->vm_flags = vm_flags;
-	}
-
-	mmu_notifier_invalidate_range_start(mm, start, start + size);
-	err = vma->vm_ops->remap_pages(vma, start, size, pgoff);
-	mmu_notifier_invalidate_range_end(mm, start, start + size);
-
-	/*
-	 * We can't clear VM_NONLINEAR because we'd have to do
-	 * it after ->populate completes, and that would prevent
-	 * downgrading the lock.  (Locks can't be upgraded).
-	 */
-
-out:
-	if (vma)
-		vm_flags = vma->vm_flags;
-out_freed:
-	if (likely(!has_write_lock))
-		up_read(&mm->mmap_sem);
-	else
-		up_write(&mm->mmap_sem);
-	if (!err && ((vm_flags & VM_LOCKED) || !(flags & MAP_NONBLOCK)))
-		mm_populate(start, size);
-
-	return err;
-}
diff --git a/mm/mmap.c b/mm/mmap.c
index b1202cf81f4b..4106fc833f56 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2579,6 +2579,74 @@ SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 	return vm_munmap(addr, len);
 }
 
+
+/*
+ * Emulation of deprecated remap_file_pages() syscall.
+ */
+SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
+		unsigned long, prot, unsigned long, pgoff, unsigned long, flags)
+{
+
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	unsigned long populate;
+	int ret = -EINVAL;
+
+	printk_once(KERN_WARNING "%s (%d) calls remap_file_pages(2) which is "
+			"deprecated and no longer supported by kernel in "
+			"an efficient way.\n"
+			"Note that emulated remap_file_pages(2) can "
+			"potentially create a lot of mappings. "
+			"Consider increasing vm.max_map_count.\n",
+			current->comm, current->pid);
+
+	if (prot)
+		return ret;
+	start = start & PAGE_MASK;
+	size = size & PAGE_MASK;
+
+	if (start + size <= start)
+		return ret;
+
+	/* Does pgoff wrap? */
+	if (pgoff + (size >> PAGE_SHIFT) < pgoff)
+		return ret;
+
+	down_write(&mm->mmap_sem);
+	vma = find_vma(mm, start);
+
+	if (!vma || !(vma->vm_flags & VM_SHARED))
+		goto out;
+
+	if (start < vma->vm_start || start + size > vma->vm_end)
+		goto out;
+
+	if (pgoff == linear_page_index(vma, start)) {
+		ret = 0;
+		goto out;
+	}
+
+	prot |= vma->vm_flags & VM_READ ? PROT_READ : 0;
+	prot |= vma->vm_flags & VM_WRITE ? PROT_WRITE : 0;
+	prot |= vma->vm_flags & VM_EXEC ? PROT_EXEC : 0;
+
+	flags &= MAP_POPULATE;
+	flags |= MAP_SHARED | MAP_FIXED;
+	if (vma->vm_flags & VM_LOCKED) {
+		flags |= MAP_LOCKED;
+		/* drop PG_Mlocked flag for over-mapped range */
+		munlock_vma_pages_range(vma, start, start + size);
+	}
+
+	ret = do_mmap_pgoff(vma->vm_file, start, size,
+			prot, flags, pgoff, &populate);
+	if (populate)
+		mm_populate(ret, populate);
+out:
+	up_write(&mm->mmap_sem);
+	return ret;
+}
+
 static inline void verify_mm_writelocked(struct mm_struct *mm)
 {
 #ifdef CONFIG_DEBUG_VM
diff --git a/mm/nommu.c b/mm/nommu.c
index 85f8d6698d48..d20b7fea2852 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1996,14 +1996,6 @@ void filemap_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf)
 }
 EXPORT_SYMBOL(filemap_map_pages);
 
-int generic_file_remap_pages(struct vm_area_struct *vma, unsigned long addr,
-			     unsigned long size, pgoff_t pgoff)
-{
-	BUG();
-	return 0;
-}
-EXPORT_SYMBOL(generic_file_remap_pages);
-
 static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long addr, void *buf, int len, int write)
 {
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
