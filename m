Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1146B00E4
	for <linux-mm@kvack.org>; Thu,  8 May 2014 08:41:39 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so2318573pdi.2
        for <linux-mm@kvack.org>; Thu, 08 May 2014 05:41:39 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yd10si467710pab.207.2014.05.08.05.41.37
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 05:41:38 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm: replace remap_file_pages() syscall with emulation
Date: Thu,  8 May 2014 15:41:28 +0300
Message-Id: <1399552888-11024-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

remap_file_pages(2) was invented to be able efficiently map parts of
huge file into limited 32-bit virtual address space such as in database
workloads.

Nonlinear mappings are pain to support and it seems there's no
legitimate use-cases nowadays since 64-bit systems are widely available.

Let's drop it and get rid of all these special-cased code.

The patch replaces the syscall with emulation which creates new VMA on
each remap_file_pages(), unless they it can be merged with an adjacent
one.

I didn't find *any* real code that uses remap_file_pages(2) to test
emulation impact on. I've checked Debian code search and source of all
packages in ALT Linux. No real users: libc wrappers, mentions in strace,
gdb, valgrind and this kind of stuff.

There are few basic tests in LTP for the syscall. They work just fine
with emulation.

To test performance impact, I've written small test case which
demonstrate pretty much worst case scenario: map 4G shmfs file, write to
begin of every page pgoff of the page, remap pages in reverse order,
read every page.

The test creates 1 million of VMAs if emulation is in use, so I had to
set vm.max_map_count to 1100000 to avoid -ENOMEM.

Before:		23.3 ( +-  4.31% ) seconds
After:		43.9 ( +-  0.85% ) seconds
Slowdown:	1.88x

I believe we can live with that.

Test case:

	#define _GNU_SOURCE
	#include <assert.h>
	#include <stdlib.h>
	#include <stdio.h>
	#include <sys/mman.h>

	#define MB	(1024UL * 1024)
	#define SIZE	(4096 * MB)

	int main(int argc, char **argv)
	{
		unsigned long *p;
		long i, pass;

		for (pass = 0; pass < 10; pass++) {
			p = mmap(NULL, SIZE, PROT_READ|PROT_WRITE,
					MAP_SHARED | MAP_ANONYMOUS, -1, 0);
			if (p == MAP_FAILED) {
				perror("mmap");
				return -1;
			}

			for (i = 0; i < SIZE / 4096; i++)
				p[i * 4096 / sizeof(*p)] = i;

			for (i = 0; i < SIZE / 4096; i++) {
				if (remap_file_pages(p + i * 4096 / sizeof(*p), 4096,
						0, (SIZE - 4096 * (i + 1)) >> 12, 0)) {
					perror("remap_file_pages");
					return -1;
				}
			}

			for (i = SIZE / 4096 - 1; i >= 0; i--)
				assert(p[i * 4096 / sizeof(*p)] == SIZE / 4096 - i - 1);

			munmap(p, SIZE);
		}

		return 0;
	}

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/remap_file_pages.txt |   7 +-
 include/linux/fs.h                    |   8 +-
 mm/Makefile                           |   2 +-
 mm/fremap.c                           | 286 ----------------------------------
 mm/mmap.c                             |  66 ++++++++
 mm/nommu.c                            |   8 -
 6 files changed, 76 insertions(+), 301 deletions(-)
 delete mode 100644 mm/fremap.c

diff --git a/Documentation/vm/remap_file_pages.txt b/Documentation/vm/remap_file_pages.txt
index 560e4363a55d..f609142f406a 100644
--- a/Documentation/vm/remap_file_pages.txt
+++ b/Documentation/vm/remap_file_pages.txt
@@ -18,10 +18,9 @@ on 32-bit systems to map files bigger than can linearly fit into 32-bit
 virtual address space. This use-case is not critical anymore since 64-bit
 systems are widely available.
 
-The plan is to deprecate the syscall and replace it with an emulation.
-The emulation will create new VMAs instead of nonlinear mappings. It's
-going to work slower for rare users of remap_file_pages() but ABI is
-preserved.
+The syscall is deprecated and replaced it with an emulation now. The
+emulation creates new VMAs instead of nonlinear mappings. It's going to
+work slower for rare users of remap_file_pages() but ABI is preserved.
 
 One side effect of emulation (apart from performance) is that user can hit
 vm.max_map_count limit more easily due to additional VMAs. See comment for
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
index 12c3bb63b7f9..000000000000
--- a/mm/fremap.c
+++ /dev/null
@@ -1,286 +0,0 @@
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
-	pr_warn_once("%s (%d) uses depricated remap_file_pages() syscall. "
-			"See Documentation/vm/remap_file_pages.txt.\n",
-			current->comm, current->pid);
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
index b1202cf81f4b..a490e5203eb9 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2579,6 +2579,72 @@ SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
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
+	unsigned long ret = -EINVAL;
+
+	pr_warn_once("%s (%d) uses depricated remap_file_pages() syscall. "
+			"See Documentation/vm/remap_file_pages.txt.\n",
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
+	flags &= MAP_NONBLOCK;
+	flags |= MAP_SHARED | MAP_FIXED | MAP_POPULATE;
+	if (vma->vm_flags & VM_LOCKED) {
+		flags |= MAP_LOCKED;
+		/* drop PG_Mlocked flag for over-mapped range */
+		munlock_vma_pages_range(vma, start, start + size);
+	}
+
+	ret = do_mmap_pgoff(vma->vm_file, start, size,
+			prot, flags, pgoff, &populate);
+out:
+	up_write(&mm->mmap_sem);
+	if (populate)
+		mm_populate(ret, populate);
+	if (!IS_ERR_VALUE(ret))
+		ret = 0;
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
2.0.0.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
