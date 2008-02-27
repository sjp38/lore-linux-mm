Date: Wed, 27 Feb 2008 20:26:10 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [PATCH] mmu notifiers #v7
Message-ID: <20080227192610.GF28483@v2.random>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080221161028.GA14220@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Hello,

I hope this will can be considered final for .25 and be merged. Risk
is zero, the only discussion here is to make an API that will last
forever, functionality-wise all these patches provides zero risk and
zero overhead when MMU_NOTIFIER=n. This last patch covers KVM and GRU
and hopefully all other non-blocking users optimally, and the below
API will hopefully last forever (but even if it lasts just for .25 and
.26 is changed that's fine with us, it's a kernel _internal_ API
anyway, there's absolutely nothing visible to userland).

What Christoph need to do when he's back from vacations to support
sleepable mmu notifiers is to add a CONFIG_XPMEM config option that
will switch the i_mmap_lock from a semaphore to a mutex (any other
change to this patch will be minor compared to that) so XPMEM hardware
will have kernels compiled that way. I don't see other sane ways to
remove the "atomic" parameter from the API (apparently required by
Andrew for merging something not restricted to the xpmem current usage
with only anonymous memory) and I don't want to have such a
locking-change intrusive dependency for all other non-blocking users
that are fine without having to alter how the VM works (for example
KVM and GRU). Very minor changes will be required to this patch to
make it work after the VM locking will be altered (for example the
CONFIG_XPMEM should also switch the mmu_register/unregister locking
from RCU to mutex as well). XPMEM then will only compile if
CONFIG_XPMEM=y and in turn the invalidate_range_* will support
scheduling inside.

I don't think pretending to merge all in one block (I mean including
xpmem support that requires blocking methods) is good idea anymore as
long as we agree the "atomic" parameter shouldn't be merged. But we
can quite easily agree on the below to be optimal for GRU/KVM and
trivially extendible once a CONFIG_XPMEM will be added. So this first
part can go in now I think.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -10,6 +10,7 @@
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
 #include <linux/completion.h>
+#include <linux/mmu_notifier.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -228,6 +229,8 @@ struct mm_struct {
 #ifdef CONFIG_CGROUP_MEM_CONT
 	struct mem_cgroup *mem_cgroup;
 #endif
+
+	struct mmu_notifier_head mmu_notifier; /* MMU notifier list */
 };
 
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
new file mode 100644
--- /dev/null
+++ b/include/linux/mmu_notifier.h
@@ -0,0 +1,159 @@
+#ifndef _LINUX_MMU_NOTIFIER_H
+#define _LINUX_MMU_NOTIFIER_H
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+
+struct mmu_notifier;
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
+	 * invalidate_page is called in atomic context after any pte
+	 * has been updated and before dropping the PT lock required
+	 * to update any Linux pte.  Once the PT lock will be released
+	 * the pte will have its final value to export through the
+	 * secondary MMU.  Before this is invoked any secondary MMU is
+	 * still ok to read/write to the page previously pointed by
+	 * the Linux pte because the old page hasn't been freed yet.
+	 * If required set_page_dirty has to be called internally to
+	 * this method.
+	 */
+	void (*invalidate_page)(struct mmu_notifier *mn,
+				struct mm_struct *mm,
+				unsigned long address);
+
+	/*
+	 * Age page is called in atomic context inside the PT lock
+	 * right after the VM is test-and-clearing the young/accessed
+	 * bitflag in the pte. This way the VM will provide proper
+	 * aging to the accesses to the page through the secondary
+	 * MMUs and not only to the ones through the Linux pte.
+	 */
+	int (*age_page)(struct mmu_notifier *mn,
+			struct mm_struct *mm,
+			unsigned long address);
+
+	/*
+	 * invalidate_range_begin() and invalidate_range_end() must be
+	 * paired. Multiple invalidate_range_begin/ends may be nested
+	 * or called concurrently.
+	 */
+	void (*invalidate_range_begin)(struct mmu_notifier *mn,
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
+#ifdef CONFIG_MMU_NOTIFIER
+
+struct mmu_notifier_head {
+	struct hlist_head head;
+	spinlock_t lock;
+};
+
+#include <linux/mm_types.h>
+
+/*
+ * RCU is used to traverse the list. A quiescent period needs to pass
+ * before the notifier is guaranteed to be visible to all threads.
+ */
+extern void mmu_notifier_register(struct mmu_notifier *mn,
+				  struct mm_struct *mm);
+/*
+ * RCU is used to traverse the list. A quiescent period needs to pass
+ * before the "struct mmu_notifier" can be freed. Alternatively it
+ * can be synchronously freed inside ->release when the list can't
+ * change anymore and nobody could possibly walk it.
+ */
+extern void mmu_notifier_unregister(struct mmu_notifier *mn,
+				    struct mm_struct *mm);
+extern void mmu_notifier_release(struct mm_struct *mm);
+extern int mmu_notifier_age_page(struct mm_struct *mm,
+				 unsigned long address);
+
+static inline void mmu_notifier_head_init(struct mmu_notifier_head *mnh)
+{
+	INIT_HLIST_HEAD(&mnh->head);
+	spin_lock_init(&mnh->lock);
+}
+
+#define mmu_notifier(function, mm, args...)				\
+	do {								\
+		struct mmu_notifier *__mn;				\
+		struct hlist_node *__n;					\
+									\
+		if (unlikely(!hlist_empty(&(mm)->mmu_notifier.head))) { \
+			rcu_read_lock();				\
+			hlist_for_each_entry_rcu(__mn, __n,		\
+						 &(mm)->mmu_notifier.head, \
+						 hlist)			\
+				if (__mn->ops->function)		\
+					__mn->ops->function(__mn,	\
+							    mm,		\
+							    args);	\
+			rcu_read_unlock();				\
+		}							\
+	} while (0)
+
+#define ptep_clear_flush_notify(__vma, __address, __ptep)		\
+({									\
+	pte_t __pte;							\
+	__pte = ptep_clear_flush(__vma, __address, __ptep);		\
+	mmu_notifier(invalidate_page, (__vma)->vm_mm, __address);	\
+	__pte;								\
+})
+
+#define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
+({									\
+	int __young;							\
+	__young = ptep_clear_flush_young(__vma, __address, __ptep);	\
+	__young |= mmu_notifier_age_page((__vma)->vm_mm, __address);	\
+	__young;							\
+})
+
+#else /* CONFIG_MMU_NOTIFIER */
+
+struct mmu_notifier_head {};
+
+#define mmu_notifier_register(mn, mm) do {} while(0)
+#define mmu_notifier_unregister(mn, mm) do {} while (0)
+#define mmu_notifier_release(mm) do {} while (0)
+#define mmu_notifier_age_page(mm, address) ({ 0; })
+#define mmu_notifier_head_init(mmh) do {} while (0)
+
+/*
+ * Notifiers that use the parameters that they were passed so that the
+ * compiler does not complain about unused variables but does proper
+ * parameter checks even if !CONFIG_MMU_NOTIFIER.
+ * Macros generate no code.
+ */
+#define mmu_notifier(function, mm, args...)			       \
+	do {							       \
+		if (0) {					       \
+			struct mmu_notifier *__mn;		       \
+								       \
+			__mn = (struct mmu_notifier *)(0x00ff);	       \
+			__mn->ops->function(__mn, mm, args);	       \
+		};						       \
+	} while (0)
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
@@ -362,6 +362,7 @@ static struct mm_struct * mm_init(struct
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
+		mmu_notifier_head_init(&mm->mmu_notifier);
 		return mm;
 	}
 
diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -193,3 +193,7 @@ config VIRT_TO_BUS
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
@@ -33,4 +33,4 @@ obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_CONT) += memcontrol.o
-
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
@@ -214,7 +214,9 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
+	mmu_notifier(invalidate_range_begin, mm, start, start + size);
 	err = populate_range(mm, vma, start, size, pgoff);
+	mmu_notifier(invalidate_range_end, mm, start, start + size);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {
 			downgrade_write(&mm->mmap_sem);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -755,6 +755,7 @@ void __unmap_hugepage_range(struct vm_ar
 	BUG_ON(start & ~HPAGE_MASK);
 	BUG_ON(end & ~HPAGE_MASK);
 
+	mmu_notifier(invalidate_range_begin, mm, start, end);
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
@@ -775,6 +776,7 @@ void __unmap_hugepage_range(struct vm_ar
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
+	mmu_notifier(invalidate_range_end, mm, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
 		put_page(page);
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -611,6 +611,9 @@ int copy_page_range(struct mm_struct *ds
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
+	if (is_cow_mapping(vma->vm_flags))
+		mmu_notifier(invalidate_range_begin, src_mm, addr, end);
+
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
 	do {
@@ -621,6 +624,11 @@ int copy_page_range(struct mm_struct *ds
 						vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
+
+	if (is_cow_mapping(vma->vm_flags))
+		mmu_notifier(invalidate_range_end, src_mm,
+						vma->vm_start, end);
+
 	return 0;
 }
 
@@ -897,7 +905,9 @@ unsigned long zap_page_range(struct vm_a
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
+	mmu_notifier(invalidate_range_begin, mm, address, end);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
+	mmu_notifier(invalidate_range_end, mm, address, end);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
 	return end;
@@ -1463,10 +1473,11 @@ int apply_to_page_range(struct mm_struct
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long end = addr + size;
+	unsigned long start = addr, end = addr + size;
 	int err;
 
 	BUG_ON(addr >= end);
+	mmu_notifier(invalidate_range_begin, mm, start, end);
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1474,6 +1485,7 @@ int apply_to_page_range(struct mm_struct
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	mmu_notifier(invalidate_range_end, mm, start, end);
 	return err;
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
@@ -1675,7 +1687,7 @@ gotten:
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
@@ -1747,11 +1747,13 @@ static void unmap_region(struct mm_struc
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
+	mmu_notifier(invalidate_range_begin, mm, start, end);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
+	mmu_notifier(invalidate_range_end, mm, start, end);
 }
 
 /*
@@ -2048,6 +2050,7 @@ void exit_mmap(struct mm_struct *mm)
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
+	mmu_notifier_release(mm);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
new file mode 100644
--- /dev/null
+++ b/mm/mmu_notifier.c
@@ -0,0 +1,73 @@
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
+#include <linux/rcupdate.h>
+
+/*
+ * No synchronization. This function can only be called when only a single
+ * process remains that performs teardown.
+ */
+void mmu_notifier_release(struct mm_struct *mm)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n, *tmp;
+
+	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
+		hlist_for_each_entry_safe(mn, n, tmp,
+					  &mm->mmu_notifier.head, hlist) {
+			hlist_del(&mn->hlist);
+			if (mn->ops->release)
+				mn->ops->release(mn, mm);
+		}
+	}
+}
+
+/*
+ * If no young bitflag is supported by the hardware, ->age_page can
+ * unmap the address and return 1 or 0 depending if the mapping previously
+ * existed or not.
+ */
+int mmu_notifier_age_page(struct mm_struct *mm, unsigned long address)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+	int young = 0;
+
+	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(mn, n,
+					 &mm->mmu_notifier.head, hlist) {
+			if (mn->ops->age_page)
+				young |= mn->ops->age_page(mn, mm, address);
+		}
+		rcu_read_unlock();
+	}
+
+	return young;
+}
+
+void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	spin_lock(&mm->mmu_notifier.lock);
+	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier.head);
+	spin_unlock(&mm->mmu_notifier.lock);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_register);
+
+void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	spin_lock(&mm->mmu_notifier.lock);
+	hlist_del_rcu(&mn->hlist);
+	spin_unlock(&mm->mmu_notifier.lock);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
diff --git a/mm/mprotect.c b/mm/mprotect.c
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -198,10 +198,12 @@ success:
 		dirty_accountable = 1;
 	}
 
+	mmu_notifier(invalidate_range_begin, mm, start, end);
 	if (is_vm_hugetlb_page(vma))
 		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
 	else
 		change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
+	mmu_notifier(invalidate_range_end, mm, start, end);
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
 	return 0;
diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -74,6 +74,7 @@ static void move_ptes(struct vm_area_str
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
+	unsigned long old_start;
 
 	if (vma->vm_file) {
 		/*
@@ -100,6 +101,9 @@ static void move_ptes(struct vm_area_str
 		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
 	arch_enter_lazy_mmu_mode();
 
+	old_start = old_addr;
+	mmu_notifier(invalidate_range_begin, vma->vm_mm,
+		     old_start, old_end);
 	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
 				   new_pte++, new_addr += PAGE_SIZE) {
 		if (pte_none(*old_pte))
@@ -108,6 +112,7 @@ static void move_ptes(struct vm_area_str
 		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
 		set_pte_at(mm, new_addr, new_pte, pte);
 	}
+	mmu_notifier(invalidate_range_end, vma->vm_mm, old_start, old_end);
 
 	arch_leave_lazy_mmu_mode();
 	if (new_ptl != old_ptl)
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -287,7 +287,7 @@ static int page_referenced_one(struct pa
 	if (vma->vm_flags & VM_LOCKED) {
 		referenced++;
 		*mapcount = 1;	/* break early from loop */
-	} else if (ptep_clear_flush_young(vma, address, pte))
+	} else if (ptep_clear_flush_young_notify(vma, address, pte))
 		referenced++;
 
 	/* Pretend the page is referenced if the task has the
@@ -454,7 +454,7 @@ static int page_mkclean_one(struct page 
 		pte_t entry;
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		entry = ptep_clear_flush(vma, address, pte);
+		entry = ptep_clear_flush_notify(vma, address, pte);
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
@@ -712,14 +712,14 @@ static int try_to_unmap_one(struct page 
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
@@ -844,12 +844,12 @@ static void try_to_unmap_cluster(unsigne
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
