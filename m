Date: Wed, 20 Feb 2008 11:39:42 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [PATCH] mmu notifiers #v6
Message-ID: <20080220103942.GU7128@v2.random>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080220010941.GR7128@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Given Nick's comments I ported my version of the mmu notifiers to
latest mainline. There are no known bugs AFIK and it's obviously safe
(nothing is allowed to schedule inside rcu_read_lock taken by
mmu_notifier() with my patch).

XPMEM simply can't use RCU for the registration locking if it wants to
schedule inside the mmu notifier calls. So I guess it's better to add
the XPMEM invalidate_range_end/begin/external-rmap as a whole
different subsystem that will have to use a mutex (not RCU) to
serialize, and at the same time that CONFIG_XPMEM will also have to
switch the i_mmap_lock to a mutex. I doubt xpmem fits inside a
CONFIG_MMU_NOTIFIER anymore, or we'll all run a bit slower because of
it. It's really a call of how much we want to optimize the MMU
notifier, by keeping things like RCU for the registration.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -46,6 +46,7 @@
 	__young = ptep_test_and_clear_young(__vma, __address, __ptep);	\
 	if (__young)							\
 		flush_tlb_page(__vma, __address);			\
+	__young |= mmu_notifier_age_page((__vma)->vm_mm, __address);	\
 	__young;							\
 })
 #endif
@@ -86,6 +87,7 @@ do {									\
 	pte_t __pte;							\
 	__pte = ptep_get_and_clear((__vma)->vm_mm, __address, __ptep);	\
 	flush_tlb_page(__vma, __address);				\
+	mmu_notifier(invalidate_page, (__vma)->vm_mm, __address);	\
 	__pte;								\
 })
 #endif
diff --git a/include/asm-s390/pgtable.h b/include/asm-s390/pgtable.h
--- a/include/asm-s390/pgtable.h
+++ b/include/asm-s390/pgtable.h
@@ -735,6 +735,7 @@ static inline pte_t ptep_clear_flush(str
 {
 	pte_t pte = *ptep;
 	ptep_invalidate(vma->vm_mm, address, ptep);
+	mmu_notifier(invalidate_page, vma->vm_mm, address);
 	return pte;
 }
 
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
@@ -0,0 +1,132 @@
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
+	 * invalidate_page[s] is called in atomic context
+	 * after any pte has been updated and before
+	 * dropping the PT lock required to update any Linux pte.
+	 * Once the PT lock will be released the pte will have its
+	 * final value to export through the secondary MMU.
+	 * Before this is invoked any secondary MMU is still ok
+	 * to read/write to the page previously pointed by the
+	 * Linux pte because the old page hasn't been freed yet.
+	 * If required set_page_dirty has to be called internally
+	 * to this method.
+	 */
+	void (*invalidate_page)(struct mmu_notifier *mn,
+				struct mm_struct *mm,
+				unsigned long address);
+	void (*invalidate_pages)(struct mmu_notifier *mn,
+				 struct mm_struct *mm,
+				 unsigned long start, unsigned long end);
+
+	/*
+	 * Age page is called in atomic context inside the PT lock
+	 * right after the VM is test-and-clearing the young/accessed
+	 * bitflag in the pte. This way the VM will provide proper aging
+	 * to the accesses to the page through the secondary MMUs
+	 * and not only to the ones through the Linux pte.
+	 */
+	int (*age_page)(struct mmu_notifier *mn,
+			struct mm_struct *mm,
+			unsigned long address);
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
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -768,6 +768,7 @@ void __unmap_hugepage_range(struct vm_ar
 		if (pte_none(pte))
 			continue;
 
+		mmu_notifier(invalidate_page, mm, address);
 		page = pte_page(pte);
 		if (pte_dirty(pte))
 			set_page_dirty(page);
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -504,6 +504,7 @@ static int copy_pte_range(struct mm_stru
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
 	int rss[2];
+	unsigned long start;
 
 again:
 	rss[1] = rss[0] = 0;
@@ -515,6 +516,7 @@ again:
 	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
 	arch_enter_lazy_mmu_mode();
 
+	start = addr;
 	do {
 		/*
 		 * We are holding two locks at this point - either of them
@@ -535,6 +537,8 @@ again:
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
 
 	arch_leave_lazy_mmu_mode();
+	if (is_cow_mapping(vma->vm_flags))
+		mmu_notifier(invalidate_pages, vma->vm_mm, start, addr);
 	spin_unlock(src_ptl);
 	pte_unmap_nested(src_pte - 1);
 	add_mm_rss(dst_mm, rss[0], rss[1]);
@@ -670,6 +674,7 @@ static unsigned long zap_pte_range(struc
 			}
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
+			mmu_notifier(invalidate_page, mm, addr);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 			if (unlikely(!page))
 				continue;
@@ -1269,6 +1274,7 @@ static int remap_pte_range(struct mm_str
 {
 	pte_t *pte;
 	spinlock_t *ptl;
+	unsigned long start = addr;
 
 	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
 	if (!pte)
@@ -1280,6 +1286,7 @@ static int remap_pte_range(struct mm_str
 		pfn++;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
+	mmu_notifier(invalidate_pages, mm, start, addr);
 	pte_unmap_unlock(pte - 1, ptl);
 	return 0;
 }
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2048,6 +2048,7 @@ void exit_mmap(struct mm_struct *mm)
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
@@ -32,6 +32,7 @@ static void change_pte_range(struct mm_s
 {
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
+	unsigned long start = addr;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -71,6 +72,7 @@ static void change_pte_range(struct mm_s
 
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
+	mmu_notifier(invalidate_pages, mm, start, addr);
 	pte_unmap_unlock(pte - 1, ptl);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
