Subject: [RFC][PATCH] mm: fix page_mkclean() vs non-linear vmas
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070307150102.GH18704@wotan.suse.de>
References: <1173264462.6374.140.camel@twins>
	 <20070307110035.GE5555@wotan.suse.de> <1173268086.6374.157.camel@twins>
	 <20070307121730.GC18704@wotan.suse.de> <1173271286.6374.166.camel@twins>
	 <20070307130851.GE18704@wotan.suse.de> <1173273562.6374.175.camel@twins>
	 <20070307133649.GF18704@wotan.suse.de> <1173275532.6374.183.camel@twins>
	 <1173278067.6374.188.camel@twins>  <20070307150102.GH18704@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 07 Mar 2007 17:58:02 +0100
Message-Id: <1173286682.6374.191.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, Jeff Dike <jdike@addtoit.com>, hugh <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

compile tested only so far

---

Partial revert of commit: 204ec841fbea3e5138168edbc3a76d46747cc987

Non-linear vmas aren't properly handled by page_mkclean() and fixing that
would result in linear scans of all related non-linear vmas per page_mkclean()
invocation.

This is deemed too costly, hence re-instate the msync scan for non-linear vmas.

However this can lead to double IO:

 - pages get instanciated with RO mapping
 - page takes write fault, and gets marked with PG_dirty
 - page gets tagged for writeout and calls page_mkclean()
 - page_mkclean() fails to find the dirty pte (and clean it)
 - writeout happens and PG_dirty gets cleared.
 - user calls msync, the dirty pte is found and the page marked with PG_dirty
 - the page gets writen out _again_ even though its not re-dirtied.

To minimize this reset the protection when creating a nonlinear vma.

I'm not at all happy with this, but plain disallowing remap_file_pages on bdis
without BDI_CAP_NO_WRITEBACK seems to offend some people, hence restrict it to
root only.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/fremap.c |   21 ++++++++
 mm/msync.c  |  146 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 162 insertions(+), 5 deletions(-)

Index: linux-2.6-git/mm/msync.c
===================================================================
--- linux-2.6-git.orig/mm/msync.c	2007-03-07 17:18:09.000000000 +0100
+++ linux-2.6-git/mm/msync.c	2007-03-07 17:31:29.000000000 +0100
@@ -7,12 +7,123 @@
 /*
  * The msync() system call.
  */
+#include <linux/slab.h>
+#include <linux/pagemap.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
+#include <linux/hugetlb.h>
+#include <linux/writeback.h>
 #include <linux/file.h>
 #include <linux/syscalls.h>
 
+#include <asm/pgtable.h>
+#include <asm/tlbflush.h>
+
+static unsigned long msync_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+				unsigned long addr, unsigned long end)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+	int progress = 0;
+	unsigned long ret = 0;
+
+again:
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	do {
+		struct page *page;
+
+		if (progress >= 64) {
+			progress = 0;
+			if (need_resched() || need_lockbreak(ptl))
+				break;
+		}
+		progress++;
+		if (!pte_present(*pte))
+			continue;
+		if (!pte_maybe_dirty(*pte))
+			continue;
+		page = vm_normal_page(vma, addr, *pte);
+		if (!page)
+			continue;
+
+		/*
+		 * Only non-linear vmas reach here, resetting the RO state
+		 * has no use, since page_mkclean doesn't work for them anyway.
+		 * It might even cause extra IO.
+		 */
+		if (ptep_clear_flush_dirty(vma, addr, pte) ||
+				page_test_and_clear_dirty(page))
+			ret += set_page_dirty(page);
+		progress += 3;
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+	if (addr != end)
+		goto again;
+	return ret;
+}
+
+static inline unsigned long msync_pmd_range(struct vm_area_struct *vma,
+			pud_t *pud, unsigned long addr, unsigned long end)
+{
+	pmd_t *pmd;
+	unsigned long next;
+	unsigned long ret = 0;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		ret += msync_pte_range(vma, pmd, addr, next);
+	} while (pmd++, addr = next, addr != end);
+	return ret;
+}
+
+static inline unsigned long msync_pud_range(struct vm_area_struct *vma,
+			pgd_t *pgd, unsigned long addr, unsigned long end)
+{
+	pud_t *pud;
+	unsigned long next;
+	unsigned long ret = 0;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		ret += msync_pmd_range(vma, pud, addr, next);
+	} while (pud++, addr = next, addr != end);
+	return ret;
+}
+
+static unsigned long msync_page_range(struct vm_area_struct *vma,
+				unsigned long addr, unsigned long end)
+{
+	pgd_t *pgd;
+	unsigned long next;
+	unsigned long ret = 0;
+
+	/* For hugepages we can't go walking the page table normally,
+	 * but that's ok, hugetlbfs is memory based, so we don't need
+	 * to do anything more on an msync().
+	 */
+	if (vma->vm_flags & VM_HUGETLB)
+		return 0;
+
+	BUG_ON(addr >= end);
+	pgd = pgd_offset(vma->vm_mm, addr);
+	flush_cache_range(vma, addr, end);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		ret += msync_pud_range(vma, pgd, addr, next);
+	} while (pgd++, addr = next, addr != end);
+	return ret;
+}
+
 /*
  * MS_SYNC syncs the entire file - including mappings.
  *
@@ -27,6 +138,21 @@
  * So by _not_ starting I/O in MS_ASYNC we provide complete flexibility to
  * applications.
  */
+static int msync_interval(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long end, int flags,
+			unsigned long *nr_pages_dirtied)
+{
+	struct file *file = vma->vm_file;
+
+	if ((flags & MS_INVALIDATE) && (vma->vm_flags & VM_LOCKED))
+		return -EBUSY;
+
+	if (file && (vma->vm_flags & VM_SHARED) &&
+			(vma->vm_flags & VM_NONLINEAR))
+		*nr_pages_dirtied = msync_page_range(vma, addr, end);
+	return 0;
+}
+
 asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
 {
 	unsigned long end;
@@ -56,6 +182,7 @@ asmlinkage long sys_msync(unsigned long 
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, start);
 	for (;;) {
+		unsigned long nr_pages_dirtied = 0;
 		struct file *file;
 
 		/* Still start < end. */
@@ -70,14 +197,23 @@ asmlinkage long sys_msync(unsigned long 
 			unmapped_error = -ENOMEM;
 		}
 		/* Here vma->vm_start <= start < vma->vm_end. */
-		if ((flags & MS_INVALIDATE) &&
-				(vma->vm_flags & VM_LOCKED)) {
-			error = -EBUSY;
+		error = msync_interval(vma, start, min(end, vma->vm_end),
+				flags, &nr_pages_dirtied);
+		if (error)
 			goto out_unlock;
-		}
 		file = vma->vm_file;
 		start = vma->vm_end;
-		if ((flags & MS_SYNC) && file &&
+		if ((flags & MS_ASYNC) && file && nr_pages_dirtied) {
+			get_file(file);
+			up_read(&mm->mmap_sem);
+			balance_dirty_pages_ratelimited_nr(file->f_mapping,
+					nr_pages_dirtied);
+			fput(file);
+			if (start >= end)
+				goto out;
+			down_read(&mm->mmap_sem);
+			vma = find_vma(mm, start);
+		} else if ((flags & MS_SYNC) && file &&
 				(vma->vm_flags & VM_SHARED)) {
 			get_file(file);
 			up_read(&mm->mmap_sem);
Index: linux-2.6-git/mm/fremap.c
===================================================================
--- linux-2.6-git.orig/mm/fremap.c	2007-03-07 17:35:19.000000000 +0100
+++ linux-2.6-git/mm/fremap.c	2007-03-07 17:52:15.000000000 +0100
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
+#include <linux/capability.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -178,6 +179,16 @@ asmlinkage long sys_remap_file_pages(uns
 	vma = find_vma(mm, start);
 
 	/*
+	 * Don't allow non root to create non-linear mappings on backing
+	 * devices capable of accounting dirty pages.
+	 */
+	if (!(vma->vm_flags & VM_NONLINEAR) && vma_wants_writenotify(vma) &&
+			!capable(CAP_SYS_ADMIN)) {
+		err = -EPERM;
+		goto out;
+	}
+
+	/*
 	 * Make sure the vma is shared, that it supports prefaulting,
 	 * and that the remapped range is valid and fully within
 	 * the single existing vma.  vm_private_data is used as a
@@ -201,6 +212,15 @@ asmlinkage long sys_remap_file_pages(uns
 			mapping = vma->vm_file->f_mapping;
 			spin_lock(&mapping->i_mmap_lock);
 			flush_dcache_mmap_lock(mapping);
+			/*
+			 * reset protection because non-linear maps don't
+			 * work with the fancy dirty page accounting code.
+			 */
+			if (vma_wants_writenotify(vma)) {
+				vma->vm_page_prot =
+					protection_map[vma->vm_flags &
+					(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)];
+			}
 			vma->vm_flags |= VM_NONLINEAR;
 			vma_prio_tree_remove(vma, &mapping->i_mmap);
 			vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
@@ -218,6 +238,7 @@ asmlinkage long sys_remap_file_pages(uns
 		 * downgrading the lock.  (Locks can't be upgraded).
 		 */
 	}
+out:
 	if (likely(!has_write_lock))
 		up_read(&mm->mmap_sem);
 	else


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
