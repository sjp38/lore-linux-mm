Date: Wed, 9 Jan 2008 19:19:08 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: mmu notifiers
Message-ID: <20080109181908.GS6958@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kvm-devel@lists.sourceforge.net, linux-mm@kvack.org
Cc: Daniel J Blueman <daniel.blueman@quadrics.com>
List-ID: <linux-mm.kvack.org>

Hello,

This patch is a first basic implementation of the mmu notifiers. More
methods can be added in the future.

In short when the linux VM decides to free a page, it will unmap it
from the linux pagetables. However when a page is mapped not just by
the regular linux ptes, but also from the shadow pagetables, it's
currently unfreeable by the linux VM.

This patch allows the shadow pagetables to be dropped and the page to
be freed after that, if the linux VM decides to unmap the page from
the main ptes because it wants to swap out the page.

In my basic initial patch I only track the tlb flushes which should be
the minimum required to have a nice linux-VM controlled swapping
behavior of the KVM gphysical memory. The shadow-ptes works much like
a TLB, so the same way we flush the tlb after clearing the ptes, we
should also issue the mmu_notifier invalidate_page/range/release
methods. Quadrics needs much more than that to optimize things but
it's easy to add more methods to the below code to fit their needs if
the basic is ok.

This follows the model of Avi's original patch, however I guess it
would also be possible to track when the VM shrink_cache methods wants
to free a certain host-page_t instead of tracking when the tlb is
flushed. Not sure what's better, but the below should be enough for
KVM to swap nicely with minimal overhead to the host kernel even if
KVM is unused.

About the locking perhaps I'm underestimating it, but by following the
TLB flushing analogy, by simply clearing the shadow ptes (with kvm
mmu_lock spinlock) and flushing the shadow-pte after clearing the main
linux pte, it should be enough to serialize against shadow-pte page
faults that would call into get_user_pages. Flushing the host TLB
before or after the shadow-ptes shouldn't matter.

Comments welcome... especially from Quadrics. Patch is mostly
untested, tomorrow I'll try to plug KVM on top of the below and see if
it survives swap.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -86,6 +86,7 @@ do {									\
 	pte_t __pte;							\
 	__pte = ptep_get_and_clear((__vma)->vm_mm, __address, __ptep);	\
 	flush_tlb_page(__vma, __address);				\
+	mmu_notifier(invalidate_page, (__vma)->vm_mm, __address);	\
 	__pte;								\
 })
 #endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -13,6 +13,7 @@
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
 #include <linux/security.h>
+#include <linux/mmu_notifier.h>
 
 struct mempolicy;
 struct anon_vma;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -219,6 +219,10 @@ struct mm_struct {
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
+
+#ifdef CONFIG_MMU_NOTIFIER
+	struct hlist_head mmu_notifier; /* MMU notifier list */
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
new file mode 100644
--- /dev/null
+++ b/include/linux/mmu_notifier.h
@@ -0,0 +1,53 @@
+#ifndef _LINUX_MMU_NOTIFIER_H
+#define _LINUX_MMU_NOTIFIER_H
+
+#include <linux/list.h>
+#include <linux/mm_types.h>
+
+#ifdef CONFIG_MMU_NOTIFIER
+
+struct mmu_notifier;
+
+struct mmu_notifier_ops {
+	void (*release)(struct mmu_notifier * mn,
+			struct mm_struct *mm);
+	void (*invalidate_page)(struct mmu_notifier * mn,
+				struct mm_struct *mm,
+				unsigned long address);
+	void (*invalidate_range)(struct mmu_notifier * mn,
+				 struct mm_struct *mm,
+				 unsigned long start, unsigned long end);
+};
+
+struct mmu_notifier {
+	struct hlist_node hlist;
+	const struct mmu_notifier_ops *ops;
+};
+
+extern void mmu_notifier_register(struct mmu_notifier *mn,
+				  struct mm_struct *mm);
+extern void mmu_notifier_unregister(struct mmu_notifier *mn);
+extern void mmu_notifier_release(struct mm_struct *mm);
+
+#define mmu_notifier(function, mm, args...)				\
+	do {								\
+		struct mmu_notifier *__mn;				\
+		struct hlist_node *__n;					\
+									\
+		hlist_for_each_entry(__mn, __n, &(mm)->mmu_notifier, hlist) \
+			if (__mn->ops->function)			\
+				__mn->ops->function(__mn, mm, args);	\
+	} while (0)
+
+#else /* CONFIG_MMU_NOTIFIER */
+
+#define mmu_notifier_register(mn, mm) do {} while(0)
+#define mmu_notifier_unregister(mn) do {} while (0)
+#define mmu_notifier_release(mm) do {} while (0)
+
+#define mmu_notifier(function, mm, args...)	\
+	do { } while (0)
+
+#endif /* CONFIG_MMU_NOTIFIER */
+
+#endif /* _LINUX_MMU_NOTIFIER_H */
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
@@ -30,4 +30,5 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
+obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -753,6 +753,7 @@ void __unmap_hugepage_range(struct vm_ar
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
+	mmu_notifier(invalidate_range, mm, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
 		put_page(page);
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -889,6 +889,7 @@ unsigned long zap_page_range(struct vm_a
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
+	mmu_notifier(invalidate_range, mm, address, end);
 	return end;
 }
 
@@ -1358,6 +1359,7 @@ int remap_pfn_range(struct vm_area_struc
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	mmu_notifier(invalidate_range, mm, end-PAGE_ALIGN(size), end);
 	return err;
 }
 EXPORT_SYMBOL(remap_pfn_range);
@@ -1452,6 +1454,7 @@ int apply_to_page_range(struct mm_struct
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	mmu_notifier(invalidate_range, mm, end-size, end);
 	return err;
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1747,6 +1747,7 @@ static void unmap_region(struct mm_struc
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
+	mmu_notifier(invalidate_range, mm, start, end);
 }
 
 /*
@@ -2043,6 +2044,7 @@ void exit_mmap(struct mm_struct *mm)
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
@@ -0,0 +1,35 @@
+/*
+ *  linux/mm/mmu_notifier.c
+ *
+ *  Copyright (C) 2008  Qumranet, Inc.
+ *
+ *  This work is licensed under the terms of the GNU GPL, version 2. See
+ *  the COPYING file in the top-level directory.
+ */
+
+#include <linux/mmu_notifier.h>
+#include <linux/module.h>
+
+void mmu_notifier_release(struct mm_struct *mm)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n, *tmp;
+
+	hlist_for_each_entry_safe(mn, n, tmp, &mm->mmu_notifier, hlist) {
+		if (mn->ops->release)
+			mn->ops->release(mn, mm);
+		hlist_del(n);
+	}
+}
+
+void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	hlist_add_head(&mn->hlist, &mm->mmu_notifier);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_register);
+
+void mmu_notifier_unregister(struct mmu_notifier *mn)
+{
+	hlist_del(&mn->hlist);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_unregister);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
