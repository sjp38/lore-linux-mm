Date: Mon, 21 Jan 2008 13:52:04 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [PATCH] mmu notifiers #v3
Message-ID: <20080121125204.GJ6970@v2.random>
References: <20080113162418.GE8736@v2.random> <20080116124256.44033d48@bree.surriel.com> <478E4356.7030303@qumranet.com> <20080117162302.GI7170@v2.random> <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080117193252.GC24131@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <izike@qumranet.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, clameter@sgi.com, daniel.blueman@quadrics.com, holt@sgi.com, steiner@sgi.com, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 17, 2008 at 08:32:52PM +0100, Andrea Arcangeli wrote:
> To make this work we still need notification from the VM about memory
> pressure [..]

Ok I thought some more at the aging issue of the hot kvm pages (to
prevent the guest-OS very-hot working set to be swapped out). So I now
hooked a age_page mmu notifier in the page_referenced mkold path. This
way when the linux pte is marked old, we can also drop the spte. This
way we give the guest-OS a whole round scan of the inactive list in
order to generate a vmexit minor fault by touching the hot page. The
very-lightweight vmexit will call into follow_page again that I
accordingly changed to mark the pte young (which is nicer because it
truly simulates what a regular access through the virtual address
would do). For direct-io it makes no difference and this way the next
time page_referenced runs it'll find the pte young again and it'll
mark the pte old again and in turn it'll call ->age_page again that
will drop the spte again, etc... So the working set will be sticky in
ram and it won't generate spurious swapouts (this is the theory at
least). It works well in practice so far but I don't have hard numbers
myself (I just implemented what I think is a quite effective aging
strategy to do a not random page replacement on the very hot guest-OS
working set).

In absence of memory pressure (or with little pressure) there will be
no age_page calls at all and the spte cache can grow freely without
any vmexit. This provides peak performance in absence of memory
pressure.

This keeps the VM aging decision in the VM instead of having an lru of
sptes to collect. The lru of sptes to collect would still be
interesting for the shrinker method though (similar to dcache/inode
lru etc..).

This update also adds some locking so multiple subsystems can
register/unregister for the notifiers at any time (something that had
to be handled by design with external serialization before and
effectively it was a bit fragile).

BTW, when MMU_NOTIFIER=n the kernel compile spawns a warning in
memory.c about two unused variables, not sure if it worth hiding it
given I suppose most people will have MMU_NOTIFIER=y. One easy way to
avoid the warning is to move the mmu_notifier call out of line and to
have one function per notifier (which was suggested by Christoph
already as an icache optimization). But this implementation keeps the
patch smaller and quicker to improve for now...

I'd like to know if this could be possibly merged soon and what I need
to change to make this happen. Thanks!

The kvm side of this can be found here:

    http://marc.info/?l=kvm-devel&m=120091930324366&w=2
    http://marc.info/?l=kvm-devel&m=120091906724000&w=2
    http://marc.info/?l=kvm-devel&m=120091939024572&w=2

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -44,8 +44,10 @@
 ({									\
 	int __young;							\
 	__young = ptep_test_and_clear_young(__vma, __address, __ptep);	\
-	if (__young)							\
+	if (__young) {							\
 		flush_tlb_page(__vma, __address);			\
+		mmu_notifier(age_page, (__vma)->vm_mm, __address);	\
+	}								\
 	__young;							\
 })
 #endif
@@ -86,6 +88,7 @@ do {									\
 	pte_t __pte;							\
 	__pte = ptep_get_and_clear((__vma)->vm_mm, __address, __ptep);	\
 	flush_tlb_page(__vma, __address);				\
+	mmu_notifier(invalidate_page, (__vma)->vm_mm, __address);	\
 	__pte;								\
 })
 #endif
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
 
@@ -219,6 +220,10 @@ struct mm_struct {
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
+
+#ifdef CONFIG_MMU_NOTIFIER
+	struct mmu_notifier_head mmu_notifier; /* MMU notifier list */
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
new file mode 100644
--- /dev/null
+++ b/include/linux/mmu_notifier.h
@@ -0,0 +1,79 @@
+#ifndef _LINUX_MMU_NOTIFIER_H
+#define _LINUX_MMU_NOTIFIER_H
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+
+#ifdef CONFIG_MMU_NOTIFIER
+
+struct mmu_notifier;
+
+struct mmu_notifier_ops {
+	void (*release)(struct mmu_notifier *mn,
+			struct mm_struct *mm);
+	void (*age_page)(struct mmu_notifier *mn,
+			 struct mm_struct *mm,
+			 unsigned long address);
+	void (*invalidate_page)(struct mmu_notifier *mn,
+				struct mm_struct *mm,
+				unsigned long address);
+	void (*invalidate_range)(struct mmu_notifier *mn,
+				 struct mm_struct *mm,
+				 unsigned long start, unsigned long end);
+};
+
+struct mmu_notifier_head {
+	struct hlist_head head;
+	rwlock_t lock;
+};
+
+struct mmu_notifier {
+	struct hlist_node hlist;
+	const struct mmu_notifier_ops *ops;
+};
+
+#include <linux/mm_types.h>
+
+extern void mmu_notifier_register(struct mmu_notifier *mn,
+				  struct mm_struct *mm);
+extern void mmu_notifier_unregister(struct mmu_notifier *mn,
+				    struct mm_struct *mm);
+extern void mmu_notifier_release(struct mm_struct *mm);
+
+static inline void mmu_notifier_head_init(struct mmu_notifier_head *mnh)
+{
+	INIT_HLIST_HEAD(&mnh->head);
+	rwlock_init(&mnh->lock);
+}
+
+#define mmu_notifier(function, mm, args...)				\
+	do {								\
+		struct mmu_notifier *__mn;				\
+		struct hlist_node *__n;					\
+									\
+		if (unlikely(!hlist_empty(&(mm)->mmu_notifier.head))) { \
+			read_lock(&(mm)->mmu_notifier.lock);		\
+			hlist_for_each_entry(__mn, __n,			\
+					     &(mm)->mmu_notifier.head,	\
+					     hlist)			\
+				if (__mn->ops->function)		\
+					__mn->ops->function(__mn,	\
+							    mm,		\
+							    args);	\
+			read_unlock(&(mm)->mmu_notifier.lock);		\
+		}							\
+	} while (0)
+
+#else /* CONFIG_MMU_NOTIFIER */
+
+#define mmu_notifier_register(mn, mm) do {} while(0)
+#define mmu_notifier_unregister(mn, mm) do {} while (0)
+#define mmu_notifier_release(mm) do {} while (0)
+#define mmu_notifier_head_init(mmh) do {} while (0)
+
+#define mmu_notifier(function, mm, args...)	\
+	do { } while (0)
+
+#endif /* CONFIG_MMU_NOTIFIER */
+
+#endif /* _LINUX_MMU_NOTIFIER_H */
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -359,6 +359,7 @@ static struct mm_struct * mm_init(struct
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
+		mmu_notifier_head_init(&mm->mmu_notifier);
 		return mm;
 	}
 	free_mm(mm);
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
 
@@ -950,7 +951,8 @@ struct page *follow_page(struct vm_area_
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
 			set_page_dirty(page);
-		mark_page_accessed(page);
+		if (!pte_young(pte))
+			set_pte_at(mm, address, ptep, pte_mkyoung(pte));
 	}
 unlock:
 	pte_unmap_unlock(ptep, ptl);
@@ -1317,7 +1319,7 @@ int remap_pfn_range(struct vm_area_struc
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long end = addr + PAGE_ALIGN(size);
+	unsigned long start = addr, end = addr + PAGE_ALIGN(size);
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
 
@@ -1358,6 +1360,7 @@ int remap_pfn_range(struct vm_area_struc
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	mmu_notifier(invalidate_range, mm, start, end);
 	return err;
 }
 EXPORT_SYMBOL(remap_pfn_range);
@@ -1441,7 +1444,7 @@ int apply_to_page_range(struct mm_struct
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long end = addr + size;
+	unsigned long start = addr, end = addr + size;
 	int err;
 
 	BUG_ON(addr >= end);
@@ -1452,6 +1455,7 @@ int apply_to_page_range(struct mm_struct
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	mmu_notifier(invalidate_range, mm, start, end);
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
@@ -0,0 +1,44 @@
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
+	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
+		read_lock(&mm->mmu_notifier.lock);
+		hlist_for_each_entry_safe(mn, n, tmp,
+					  &mm->mmu_notifier.head, hlist) {
+			if (mn->ops->release)
+				mn->ops->release(mn, mm);
+			hlist_del(&mn->hlist);
+		}
+		read_unlock(&mm->mmu_notifier.lock);
+	}
+}
+
+void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	write_lock(&mm->mmu_notifier.lock);
+	hlist_add_head(&mn->hlist, &mm->mmu_notifier.head);
+	write_unlock(&mm->mmu_notifier.lock);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_register);
+
+void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	write_lock(&mm->mmu_notifier.lock);
+	hlist_del(&mn->hlist);
+	write_unlock(&mm->mmu_notifier.lock);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_unregister);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
