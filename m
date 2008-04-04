From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] [PATCH] mmu notifier #v11
Date: Fri, 4 Apr 2008 22:20:56 +0200
Message-ID: <20080404202055.GA14784@duo.random>
References: <20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com>
	<20080402220148.GV19189@duo.random>
	<Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com>
	<20080402221716.GY19189@duo.random>
	<Pine.LNX.4.64.0804021821230.639@schroedinger.engr.sgi.com>
	<20080403151908.GB9603@duo.random>
	<Pine.LNX.4.64.0804031215050.7480@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804031215050.7480@schroedinger.engr.sgi.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

This should guarantee that nobody can register when any of the mmu
notifiers is running avoiding all the races including guaranteeing
range_start not to be missed. I'll adapt the other patches to provide
the sleeping-feature on top of this (only needed by XPMEM) soon. KVM
seems to run fine on top of this one.

Andrew can you apply this to -mm?

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1050,6 +1050,9 @@
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
 
+extern void mm_lock(struct mm_struct *mm);
+extern void mm_unlock(struct mm_struct *mm);
+
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -225,6 +225,9 @@
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 	struct mem_cgroup *mem_cgroup;
 #endif
+#ifdef CONFIG_MMU_NOTIFIER
+	struct hlist_head mmu_notifier_list;
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
new file mode 100644
--- /dev/null
+++ b/include/linux/mmu_notifier.h
@@ -0,0 +1,175 @@
+#ifndef _LINUX_MMU_NOTIFIER_H
+#define _LINUX_MMU_NOTIFIER_H
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/mm_types.h>
+
+struct mmu_notifier;
+struct mmu_notifier_ops;
+
+#ifdef CONFIG_MMU_NOTIFIER
+
+struct mmu_notifier_ops {
+	/*
+	 * Called when nobody can register any more notifier in the mm
+	 * and after the "mn" notifier has been disarmed already.
+	 */
+	void (*release)(struct mmu_notifier *mn,
+			struct mm_struct *mm);
+
+	/*
+	 * clear_flush_young is called after the VM is
+	 * test-and-clearing the young/accessed bitflag in the
+	 * pte. This way the VM will provide proper aging to the
+	 * accesses to the page through the secondary MMUs and not
+	 * only to the ones through the Linux pte.
+	 */
+	int (*clear_flush_young)(struct mmu_notifier *mn,
+				 struct mm_struct *mm,
+				 unsigned long address);
+
+	/*
+	 * Before this is invoked any secondary MMU is still ok to
+	 * read/write to the page previously pointed by the Linux pte
+	 * because the old page hasn't been freed yet.  If required
+	 * set_page_dirty has to be called internally to this method.
+	 */
+	void (*invalidate_page)(struct mmu_notifier *mn,
+				struct mm_struct *mm,
+				unsigned long address);
+
+	/*
+	 * invalidate_range_start() and invalidate_range_end() must be
+	 * paired. Multiple invalidate_range_start/ends may be nested
+	 * or called concurrently.
+	 */
+	void (*invalidate_range_start)(struct mmu_notifier *mn,
+				       struct mm_struct *mm,
+				       unsigned long start, unsigned long end);
+	void (*invalidate_range_end)(struct mmu_notifier *mn,
+				     struct mm_struct *mm,
+				     unsigned long start, unsigned long end);
+};
+
+struct mmu_notifier {
+	struct hlist_node hlist;
+	const struct mmu_notifier_ops *ops;
+};
+
+static inline int mm_has_notifiers(struct mm_struct *mm)
+{
+	return unlikely(!hlist_empty(&mm->mmu_notifier_list));
+}
+
+extern void mmu_notifier_register(struct mmu_notifier *mn,
+				  struct mm_struct *mm);
+extern void __mmu_notifier_release(struct mm_struct *mm);
+extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
+					  unsigned long address);
+extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
+					  unsigned long address);
+extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+				  unsigned long start, unsigned long end);
+extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end);
+
+
+static inline void mmu_notifier_release(struct mm_struct *mm)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_release(mm);
+}
+
+static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
+					  unsigned long address)
+{
+	if (mm_has_notifiers(mm))
+		return __mmu_notifier_clear_flush_young(mm, address);
+	return 0;
+}
+
+static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
+					  unsigned long address)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_page(mm, address);
+}
+
+static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_range_start(mm, start, end);
+}
+
+static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_range_end(mm, start, end);
+}
+
+static inline void mmu_notifier_mm_init(struct mm_struct *mm)
+{
+	INIT_HLIST_HEAD(&mm->mmu_notifier_list);
+}
+
+#define ptep_clear_flush_notify(__vma, __address, __ptep)		\
+({									\
+	pte_t __pte;							\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	__pte = ptep_clear_flush(___vma, ___address, __ptep);		\
+	mmu_notifier_invalidate_page(___vma->vm_mm, ___address);	\
+	__pte;								\
+})
+
+#define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
+({									\
+	int __young;							\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	__young = ptep_clear_flush_young(___vma, ___address, __ptep);	\
+	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\
+						  ___address);		\
+	__young;							\
+})
+
+#else /* CONFIG_MMU_NOTIFIER */
+
+static inline void mmu_notifier_release(struct mm_struct *mm)
+{
+}
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
+static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
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
@@ -362,6 +363,7 @@
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
+		mmu_notifier_mm_init(mm);
 		return mm;
 	}
 
diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -193,3 +193,7 @@
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config MMU_NOTIFIER
+	def_bool y
+	bool "MMU notifier, for paging KVM/RDMA"
diff --git a/mm/Makefile b/mm/Makefile
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -33,4 +33,5 @@
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -194,7 +194,7 @@
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
@@ -214,7 +215,9 @@
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
+	mmu_notifier_invalidate_range_start(mm, start, start + size);
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
@@ -799,6 +800,7 @@
 	BUG_ON(start & ~HPAGE_MASK);
 	BUG_ON(end & ~HPAGE_MASK);
 
+	mmu_notifier_invalidate_range_start(mm, start, end);
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
@@ -819,6 +821,7 @@
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
@@ -611,6 +612,9 @@
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
+	if (is_cow_mapping(vma->vm_flags))
+		mmu_notifier_invalidate_range_start(src_mm, addr, end);
+
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
 	do {
@@ -621,6 +625,11 @@
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
 
@@ -897,7 +906,9 @@
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
+	mmu_notifier_invalidate_range_start(mm, address, end);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
+	mmu_notifier_invalidate_range_end(mm, address, end);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
 	return end;
@@ -1463,10 +1474,11 @@
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long end = addr + size;
+	unsigned long start = addr, end = addr + size;
 	int err;
 
 	BUG_ON(addr >= end);
+	mmu_notifier_invalidate_range_start(mm, start, end);
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1474,6 +1486,7 @@
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 	return err;
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
@@ -1675,7 +1688,7 @@
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush(vma, address, page_table);
+		ptep_clear_flush_notify(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		lru_cache_add_active(new_page);
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -26,6 +26,7 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1747,11 +1748,13 @@
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
+	mmu_notifier_invalidate_range_start(mm, start, end);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 }
 
 /*
@@ -2037,6 +2040,7 @@
 	unsigned long end;
 
 	/* mm's last user has gone, and its about to be pulled down */
+	mmu_notifier_release(mm);
 	arch_exit_mmap(mm);
 
 	lru_add_drain();
@@ -2242,3 +2246,69 @@
 
 	return 0;
 }
+
+static void mm_lock_unlock(struct mm_struct *mm, int lock)
+{
+	struct vm_area_struct *vma;
+	spinlock_t *i_mmap_lock_last, *anon_vma_lock_last;
+
+	i_mmap_lock_last = NULL;
+	for (;;) {
+		spinlock_t *i_mmap_lock = (spinlock_t *) -1UL;
+		for (vma = mm->mmap; vma; vma = vma->vm_next)
+			if (vma->vm_file && vma->vm_file->f_mapping &&
+			    (unsigned long) i_mmap_lock >
+			    (unsigned long)
+			    &vma->vm_file->f_mapping->i_mmap_lock &&
+			    (unsigned long)
+			    &vma->vm_file->f_mapping->i_mmap_lock >
+			    (unsigned long) i_mmap_lock_last)
+				i_mmap_lock =
+					&vma->vm_file->f_mapping->i_mmap_lock;
+		if (i_mmap_lock == (spinlock_t *) -1UL)
+			break;
+		i_mmap_lock_last = i_mmap_lock;
+		if (lock)
+			spin_lock(i_mmap_lock);
+		else
+			spin_unlock(i_mmap_lock);
+	}
+
+	anon_vma_lock_last = NULL;
+	for (;;) {
+		spinlock_t *anon_vma_lock = (spinlock_t *) -1UL;
+		for (vma = mm->mmap; vma; vma = vma->vm_next)
+			if (vma->anon_vma &&
+			    (unsigned long) anon_vma_lock >
+			    (unsigned long) &vma->anon_vma->lock &&
+			    (unsigned long) &vma->anon_vma->lock >
+			    (unsigned long) anon_vma_lock_last)
+				anon_vma_lock = &vma->anon_vma->lock;
+		if (anon_vma_lock == (spinlock_t *) -1UL)
+			break;
+		anon_vma_lock_last = anon_vma_lock;
+		if (lock)
+			spin_lock(anon_vma_lock);
+		else
+			spin_unlock(anon_vma_lock);
+	}
+}
+
+/*
+ * This operation locks against the VM for all pte/vma/mm related
+ * operations that could ever happen on a certain mm. This includes
+ * vmtruncate, try_to_unmap, and all page faults. The holder
+ * must not hold any mm related lock. A single task can't take more
+ * than one mm lock in a row or it would deadlock.
+ */
+void mm_lock(struct mm_struct * mm)
+{
+	down_write(&mm->mmap_sem);
+	mm_lock_unlock(mm, 1);
+}
+
+void mm_unlock(struct mm_struct *mm)
+{
+	mm_lock_unlock(mm, 0);
+	up_write(&mm->mmap_sem);
+}
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
new file mode 100644
--- /dev/null
+++ b/mm/mmu_notifier.c
@@ -0,0 +1,100 @@
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
+#include <linux/mm.h>
+
+/*
+ * No synchronization. This function can only be called when only a single
+ * process remains that performs teardown.
+ */
+void __mmu_notifier_release(struct mm_struct *mm)
+{
+	struct mmu_notifier *mn;
+
+	while (unlikely(!hlist_empty(&mm->mmu_notifier_list))) {
+		mn = hlist_entry(mm->mmu_notifier_list.first,
+				 struct mmu_notifier,
+				 hlist);
+		hlist_del(&mn->hlist);
+		if (mn->ops->release)
+			mn->ops->release(mn, mm);
+	}
+}
+
+/*
+ * If no young bitflag is supported by the hardware, ->clear_flush_young can
+ * unmap the address and return 1 or 0 depending if the mapping previously
+ * existed or not.
+ */
+int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
+					unsigned long address)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+	int young = 0;
+
+	hlist_for_each_entry(mn, n, &mm->mmu_notifier_list, hlist) {
+		if (mn->ops->clear_flush_young)
+			young |= mn->ops->clear_flush_young(mn, mm, address);
+	}
+
+	return young;
+}
+
+void __mmu_notifier_invalidate_page(struct mm_struct *mm,
+					  unsigned long address)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+
+	hlist_for_each_entry(mn, n, &mm->mmu_notifier_list, hlist) {
+		if (mn->ops->invalidate_page)
+			mn->ops->invalidate_page(mn, mm, address);
+	}
+}
+
+void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+
+	hlist_for_each_entry(mn, n, &mm->mmu_notifier_list, hlist) {
+		if (mn->ops->invalidate_range_start)
+			mn->ops->invalidate_range_start(mn, mm, start, end);
+	}
+}
+
+void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+
+	hlist_for_each_entry(mn, n, &mm->mmu_notifier_list, hlist) {
+		if (mn->ops->invalidate_range_end)
+			mn->ops->invalidate_range_end(mn, mm, start, end);
+	}
+}
+
+/*
+ * Must not hold mmap_sem nor any other VM related lock when calling
+ * this registration function.
+ */
+void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	mm_lock(mm);
+	hlist_add_head(&mn->hlist, &mm->mmu_notifier_list);
+	mm_unlock(mm);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_register);
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
@@ -198,10 +199,12 @@
 		dirty_accountable = 1;
 	}
 
+	mmu_notifier_invalidate_range_start(mm, start, end);
 	if (is_vm_hugetlb_page(vma))
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
@@ -74,7 +75,11 @@
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
+	unsigned long old_start;
 
+	old_start = old_addr;
+	mmu_notifier_invalidate_range_start(vma->vm_mm,
+					    old_start, old_end);
 	if (vma->vm_file) {
 		/*
 		 * Subtle point from Rajesh Venkatasubramanian: before
@@ -116,6 +121,7 @@
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
 
@@ -287,7 +288,7 @@
 	if (vma->vm_flags & VM_LOCKED) {
 		referenced++;
 		*mapcount = 1;	/* break early from loop */
-	} else if (ptep_clear_flush_young(vma, address, pte))
+	} else if (ptep_clear_flush_young_notify(vma, address, pte))
 		referenced++;
 
 	/* Pretend the page is referenced if the task has the
@@ -456,7 +457,7 @@
 		pte_t entry;
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		entry = ptep_clear_flush(vma, address, pte);
+		entry = ptep_clear_flush_notify(vma, address, pte);
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
@@ -717,14 +718,14 @@
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
@@ -849,12 +850,12 @@
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
