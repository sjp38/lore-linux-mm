From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] Minimal mmu notifiers for kvm
Date: Fri, 25 Apr 2008 08:13:00 +1000
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200804250813.00792.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Avi Kivity <avi@qumranet.com>, Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

AFAICT this is the minimal mmu notifier support required by kvm.  It's pretty
trivial and in fact contains all the parts noone's arguing over.

1) All under CONFIG_MMU_NOTIFIER.
2) Only one mmu notifier per mm
3) No way to unregister mmu notifier.
4) mmu notifier callbacks can't sleep.
5) Only clear_flush_young, invalidate_page and invalidate_range_end callbacks.

Based on patch Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -225,6 +225,9 @@ struct mm_struct {
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 	struct mem_cgroup *mem_cgroup;
 #endif
+#ifdef CONFIG_MMU_NOTIFIER
+	const struct mmu_notifier_ops *mmu_notifier_ops;
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
new file mode 100644
--- /dev/null
+++ b/include/linux/mmu_notifier.h
@@ -0,0 +1,120 @@
+#ifndef _LINUX_MMU_NOTIFIER_H
+#define _LINUX_MMU_NOTIFIER_H
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/mm_types.h>
+#include <asm/tlbflush.h>
+
+#ifdef CONFIG_MMU_NOTIFIER
+
+/*
+ * No sleeping in any of these callbacks: we can't handle that yet.
+ * Each callback must be populated.
+ */
+struct mmu_notifier_ops {
+	/*
+	 * clear_flush_young is called after the VM is
+	 * test-and-clearing the young/accessed bitflag in the
+	 * pte. This way the VM will provide proper aging to the
+	 * accesses to the page through the secondary MMUs and not
+	 * only to the ones through the Linux pte.
+	 */
+	int (*clear_flush_young)(struct mm_struct *mm,
+				 unsigned long address);
+
+	/*
+	 * Before this is invoked any secondary MMU is still ok to
+	 * read/write to the page previously pointed by the Linux pte
+	 * because the old page hasn't been freed yet.  If required
+	 * set_page_dirty has to be called internally to this method.
+	 */
+	void (*invalidate_page)(struct mm_struct *mm,
+				unsigned long address);
+
+	/*
+	 * invalidate_range_end() is called when all pages in the
+	 * range have been unmapped and the pages have been freed by
+	 * the VM.
+	 */
+	void (*invalidate_range_end)(struct mm_struct *mm,
+				     unsigned long start, unsigned long end);
+};
+
+extern int mm_add_notifier_ops(struct mm_struct *mm,
+			       const struct mmu_notifier_ops *mops);
+				
+
+static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
+					  unsigned long address)
+{
+	if (unlikely(mm->mmu_notifier_ops))
+		return mm->mmu_notifier_ops->clear_flush_young(mm, address);
+	return 0;
+}
+
+static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
+					  unsigned long address)
+{
+	if (unlikely(mm->mmu_notifier_ops))
+		mm->mmu_notifier_ops->invalidate_page(mm, address);
+}
+
+static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	if (unlikely(mm->mmu_notifier_ops))
+		mm->mmu_notifier_ops->invalidate_range_end(mm, start, end);
+}
+
+static inline void mmu_notifier_mm_init(struct mm_struct *mm)
+{
+	mm->mmu_notifier_ops = NULL;
+}
+
+static inline pte_t ptep_clear_flush_notify(struct vm_area_struct *vma,
+					    unsigned long address,
+					    pte_t *ptep)
+{
+	pte_t pte = ptep_clear_flush(vma, address, ptep);
+	mmu_notifier_invalidate_page(vma->vm_mm, address);
+	return pte;
+}
+
+static inline int ptep_clear_flush_young_notify(struct vm_area_struct *vma,
+						unsigned long address,
+						pte_t *ptep)
+{
+	int young;
+	young = ptep_clear_flush_young(vma, address,ptep);
+	young |= mmu_notifier_clear_flush_young(vma->vm_mm, address);
+	return young;
+}
+#else /* CONFIG_MMU_NOTIFIER */
+
+static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return 0;
+}
+
+static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
+					  unsigned long address)
+{
+}
+
+static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+}
+
+static inline void mmu_notifier_mm_init(struct mm_struct *mm)
+{
+}
+
+#define ptep_clear_flush_young_notify ptep_clear_flush_young
+#define ptep_clear_flush_notify ptep_clear_flush
+
+#endif /* CONFIG_MMU_NOTIFIER */
+
+#endif /* _LINUX_MMU_NOTIFIER_H */
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -53,6 +53,7 @@
 #include <linux/tty.h>
 #include <linux/proc_fs.h>
 #include <linux/blkdev.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -385,6 +386,7 @@ static struct mm_struct * mm_init(struct
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
+		mmu_notifier_mm_init(mm);
 		return mm;
 	}
 
diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -193,3 +193,8 @@ config VIRT_TO_BUS
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config MMU_NOTIFIER
+	def_bool n
+	depends on EXPERIMENTAL
+	bool "MMU notifier, for paging KVM (EXPERIMENTAL)"
diff --git a/mm/Makefile b/mm/Makefile
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -33,4 +33,5 @@ obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -194,7 +194,7 @@ __xip_unmap (struct address_space * mapp
 		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
-			pteval = ptep_clear_flush(vma, address, pte);
+			pteval = ptep_clear_flush_notify(vma, address, pte);
 			page_remove_rmap(page, vma);
 			dec_mm_counter(mm, file_rss);
 			BUG_ON(pte_dirty(pteval));
diff --git a/mm/fremap.c b/mm/fremap.c
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -215,6 +216,7 @@ asmlinkage long sys_remap_file_pages(uns
 	}
 
 	err = populate_range(mm, vma, start, size, pgoff);
+	mmu_notifier_invalidate_range_end(mm, start, start + size);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {
 			downgrade_write(&mm->mmap_sem);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -819,6 +820,7 @@ void __unmap_hugepage_range(struct vm_ar
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
 		put_page(page);
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -51,6 +51,7 @@
 #include <linux/init.h>
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -621,6 +622,11 @@ int copy_page_range(struct mm_struct *ds
 						vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
+
+	if (is_cow_mapping(vma->vm_flags))
+		mmu_notifier_invalidate_range_end(src_mm,
+						vma->vm_start, end);
+
 	return 0;
 }
 
@@ -825,6 +831,7 @@ unsigned long unmap_vmas(struct mmu_gath
 	unsigned long start = start_addr;
 	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	int fullmm = (*tlbp)->fullmm;
+	struct mm_struct *mm = vma->vm_mm;
 
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;
@@ -876,6 +883,7 @@ unsigned long unmap_vmas(struct mmu_gath
 		}
 	}
 out:
+	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
 	return start;	/* which is now the end (or restart) address */
 }
 
@@ -1463,7 +1471,7 @@ int apply_to_page_range(struct mm_struct
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long end = addr + size;
+	unsigned long start = addr, end = addr + size;
 	int err;
 
 	BUG_ON(addr >= end);
@@ -1474,6 +1482,7 @@ int apply_to_page_range(struct mm_struct
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 	return err;
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
@@ -1675,7 +1684,7 @@ gotten:
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush(vma, address, page_table);
+		ptep_clear_flush_notify(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		lru_cache_add_active(new_page);
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
new file mode 100644
--- /dev/null
+++ b/mm/mmu_notifier.c
@@ -0,0 +1,39 @@
+/*
+ *  linux/mm/mmu_notifier.c
+ *
+ *  Copyright (C) 2008  Qumranet, Inc.
+ *  Copyright (C) 2008  SGI
+ *             Christoph Lameter <clameter@sgi.com>
+ *
+ *  This work is licensed under the terms of the GNU GPL, version 2. See
+ *  the COPYING file in the top-level directory.
+ */
+
+#include <linux/mmu_notifier.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/spinlock.h>
+
+/* This prevents simultaneous registrations on same mm. */
+static DEFINE_SPINLOCK(notifier_lock);
+
+/*
+ * Must not hold mmap_sem nor any other VM related lock when calling
+ * this registration function.
+ */
+int mm_add_notifier_ops(struct mm_struct *mm,
+			const struct mmu_notifier_ops *mops)
+{
+	int err;
+
+	spin_lock(&notifier_lock);
+	if (mm->mmu_notifier_ops)
+		err = -EBUSY;
+	else {
+		mm->mmu_notifier_ops = mops;
+		err = 0;
+	}
+	spin_unlock(&notifier_lock);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mm_add_notifier_ops);
diff --git a/mm/mprotect.c b/mm/mprotect.c
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/mmu_notifier.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -202,6 +203,7 @@ success:
 		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
 	else
 		change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
 	return 0;
diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -18,6 +18,7 @@
 #include <linux/highmem.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -74,7 +75,9 @@ static void move_ptes(struct vm_area_str
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
+	unsigned long old_start;
 
+	old_start = old_addr;
 	if (vma->vm_file) {
 		/*
 		 * Subtle point from Rajesh Venkatasubramanian: before
@@ -116,6 +119,7 @@ static void move_ptes(struct vm_area_str
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, old_start, old_end);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -49,6 +49,7 @@
 #include <linux/module.h>
 #include <linux/kallsyms.h>
 #include <linux/memcontrol.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/tlbflush.h>
 
@@ -287,7 +288,7 @@ static int page_referenced_one(struct pa
 	if (vma->vm_flags & VM_LOCKED) {
 		referenced++;
 		*mapcount = 1;	/* break early from loop */
-	} else if (ptep_clear_flush_young(vma, address, pte))
+	} else if (ptep_clear_flush_young_notify(vma, address, pte))
 		referenced++;
 
 	/* Pretend the page is referenced if the task has the
@@ -456,7 +457,7 @@ static int page_mkclean_one(struct page 
 		pte_t entry;
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		entry = ptep_clear_flush(vma, address, pte);
+		entry = ptep_clear_flush_notify(vma, address, pte);
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
@@ -717,14 +718,14 @@ static int try_to_unmap_one(struct page 
 	 * skipped over this mm) then we should reactivate it.
 	 */
 	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young(vma, address, pte)))) {
+			(ptep_clear_flush_young_notify(vma, address, pte)))) {
 		ret = SWAP_FAIL;
 		goto out_unmap;
 	}
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
-	pteval = ptep_clear_flush(vma, address, pte);
+	pteval = ptep_clear_flush_notify(vma, address, pte);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
@@ -849,12 +850,12 @@ static void try_to_unmap_cluster(unsigne
 		page = vm_normal_page(vma, address, *pte);
 		BUG_ON(!page || PageAnon(page));
 
-		if (ptep_clear_flush_young(vma, address, pte))
+		if (ptep_clear_flush_young_notify(vma, address, pte))
 			continue;
 
 		/* Nuke the page table entry. */
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		pteval = ptep_clear_flush(vma, address, pte);
+		pteval = ptep_clear_flush_notify(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
