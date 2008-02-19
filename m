Date: Tue, 19 Feb 2008 09:43:57 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] my mmu notifiers
Message-ID: <20080219084357.GA22249@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Well I started reviewing the mmu notifier code, but it is kind of hard to
know what you're talking about just by reading through code and not trying
your suggestions for yourself...

So I implemented mmu notifiers slightly differently. Andrea's mmu notifiers
are rather similar. However I have tried to make a point of minimising the
impact the the core mm/. I don't see why we need to invalidate or flush
anything when changing the pte to be _more_ permissive, and I don't
understand the need for invalidate_begin/invalidate_end pairs at all.
What I have done is basically create it so that the notifiers get called
basically in the same place as the normal TLB flushing is done, and nowhere
else.

I also wanted to avoid calling notifier code from inside eg. hardware TLB
or pte manipulation primitives. These things are already pretty well
spaghetti, so I'd like to just place them right where needed first... I
think eventually it will need a bit of a rethink to make it more consistent
and more general. But I prefer to do put them in the caller for the moment.

I have also attempted to write a skeleton driver. Not like Christoph's
drivers, but one that actually does something. This one can mmap a
window into its own virtual address space. It's not perfect yet (I need
to replace page_mkwrite with ->fault in the core mm before I can get
enough information to do protection properly I think). However I think it
may be race-free in the fault vs unmap paths. It's pretty complex, I must
say.

---

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h
+++ linux-2.6/include/linux/mm_types.h
@@ -228,6 +228,9 @@ struct mm_struct {
 #ifdef CONFIG_CGROUP_MEM_CONT
 	struct mem_cgroup *mem_cgroup;
 #endif
+#ifdef CONFIG_MMU_NOTIFIER
+	struct hlist_head mmu_notifier_list;
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
Index: linux-2.6/include/linux/mmu_notifier.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/mmu_notifier.h
@@ -0,0 +1,69 @@
+#ifndef _LINUX_MMU_NOTIFIER_H
+#define _LINUX_MMU_NOTIFIER_H
+
+#include <linux/list.h>
+#include <linux/mm_types.h>
+
+struct mmu_notifier;
+struct mmu_notifier_operations;
+
+#ifdef CONFIG_MMU_NOTIFIER
+
+struct mmu_notifier {
+	struct hlist_node hlist;
+	const struct mmu_notifier_operations *ops;
+	struct mm_struct *mm;
+};
+
+struct mmu_notifier_operations {
+	void (*release)(struct mmu_notifier *mn);
+	int (*clear_young)(struct mmu_notifier *mn, unsigned long address);
+	void (*unmap)(struct mmu_notifier *mn, unsigned long address);
+	void (*invalidate_range)(struct mmu_notifier *mn, unsigned long start, unsigned long end);
+};
+
+static inline void mmu_notifier_init_mm(struct mm_struct *mm)
+{
+	INIT_HLIST_HEAD(&mm->mmu_notifier_list);
+}
+
+static inline void mmu_notifier_init(struct mmu_notifier *mn, const struct mmu_notifier_operations *ops, struct mm_struct *mm)
+{
+	INIT_HLIST_NODE(&mn->hlist);
+	mn->ops = ops;
+	mn->mm = mm;
+}
+
+extern void mmu_notifier_register(struct mmu_notifier *mn);
+extern void mmu_notifier_unregister(struct mmu_notifier *mn);
+
+extern void mmu_notifier_exit_mm(struct mm_struct *mm);
+extern int mmu_notifier_clear_young(struct mm_struct *mm, unsigned long address);
+extern void mmu_notifier_unmap(struct mm_struct *mm, unsigned long address);
+extern void mmu_notifier_invalidate_range(struct mm_struct *mm, unsigned long start, unsigned long end);
+
+#else /* CONFIG_MMU_NOTIFIER */
+
+static inline void mmu_notifier_init_mm(struct mm_struct *mm)
+{
+}
+
+static inline void mmu_notifier_exit_mm(struct mm_struct *mm)
+{
+}
+
+static inline int mmu_notifier_clear_young(struct mm_struct *mm, unsigned long address)
+{
+	return 0;
+}
+
+static inline void mmu_notifier_unmap(struct mm_struct *mm, unsigned long address)
+{
+}
+
+static inline void mmu_notifier_invalidate_range(struct mm_struct *mm, unsigned long start, unsigned long end)
+{
+}
+#endif /* CONFIG_MMU_NOTIFIER */
+
+#endif
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -43,6 +43,7 @@
 #include <linux/memcontrol.h>
 #include <linux/profile.h>
 #include <linux/rmap.h>
+#include <linux/mmu_notifier.h>
 #include <linux/acct.h>
 #include <linux/tsacct_kern.h>
 #include <linux/cn_proc.h>
@@ -358,6 +359,7 @@ static struct mm_struct * mm_init(struct
 	mm->ioctx_list = NULL;
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
+	mmu_notifier_init_mm(mm);
 	mm_init_cgroup(mm, p);
 
 	if (likely(!mm_alloc_pgd(mm))) {
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c
+++ linux-2.6/mm/filemap_xip.c
@@ -195,6 +195,7 @@ __xip_unmap (struct address_space * mapp
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush(vma, address, pte);
+			mmu_notifier_unmap(mm, address);
 			page_remove_rmap(page, vma);
 			dec_mm_counter(mm, file_rss);
 			BUG_ON(pte_dirty(pteval));
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c
+++ linux-2.6/mm/fremap.c
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -34,6 +35,7 @@ static void zap_pte(struct mm_struct *mm
 		if (page) {
 			if (pte_dirty(pte))
 				set_page_dirty(page);
+			mmu_notifier_unmap(mm, addr);
 			page_remove_rmap(page, vma);
 			page_cache_release(page);
 			update_hiwater_rss(mm);
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -771,10 +772,12 @@ void __unmap_hugepage_range(struct vm_ar
 		page = pte_page(pte);
 		if (pte_dirty(pte))
 			set_page_dirty(page);
+		mmu_notifier_unmap(mm, address);
 		list_add(&page->lru, &page_list);
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
+	mmu_notifier_invalidate_range(mm, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
 		put_page(page);
@@ -1048,6 +1051,7 @@ void hugetlb_change_protection(struct vm
 			continue;
 		if (!pte_none(*ptep)) {
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
+			mmu_notifier_unmap(mm, address);
 			pte = pte_mkhuge(pte_modify(pte, newprot));
 			set_huge_pte_at(mm, address, ptep, pte);
 		}
@@ -1056,6 +1060,7 @@ void hugetlb_change_protection(struct vm
 	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
 
 	flush_tlb_range(vma, start, end);
+	mmu_notifier_invalidate_range(mm, start, end);
 }
 
 struct file_region {
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -51,6 +51,7 @@
 #include <linux/init.h>
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -626,9 +627,10 @@ int copy_page_range(struct mm_struct *ds
 
 static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pmd_t *pmd,
-				unsigned long addr, unsigned long end,
+				unsigned long start, unsigned long end,
 				long *zap_work, struct zap_details *details)
 {
+	unsigned long addr = start;
 	struct mm_struct *mm = tlb->mm;
 	pte_t *pte;
 	spinlock_t *ptl;
@@ -670,6 +672,7 @@ static unsigned long zap_pte_range(struc
 			}
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
+			mmu_notifier_unmap(mm, addr);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 			if (unlikely(!page))
 				continue;
@@ -702,6 +705,7 @@ static unsigned long zap_pte_range(struc
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
 
+	mmu_notifier_invalidate_range(mm, start, end);
 	add_mm_rss(mm, file_rss, anon_rss);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
@@ -981,6 +985,7 @@ no_page_table:
 	}
 	return page;
 }
+EXPORT_SYMBOL(follow_page);
 
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, int len, int write, int force,
@@ -1676,6 +1681,7 @@ gotten:
 		 * thread doing COW.
 		 */
 		ptep_clear_flush(vma, address, page_table);
+		mmu_notifier_unmap(mm, address);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		lru_cache_add_active(new_page);
@@ -2200,7 +2206,7 @@ static int __do_fault(struct mm_struct *
 	vmf.flags = flags;
 	vmf.page = NULL;
 
-	BUG_ON(vma->vm_flags & VM_PFNMAP);
+	/* BUG_ON(vma->vm_flags & VM_PFNMAP); */
 
 	if (likely(vma->vm_ops->fault)) {
 		ret = vma->vm_ops->fault(vma, &vmf);
@@ -2498,8 +2504,10 @@ static inline int handle_pte_fault(struc
 		 * This still avoids useless tlb flushes for .text page faults
 		 * with threads.
 		 */
-		if (write_access)
+		if (write_access) {
 			flush_tlb_page(vma, address);
+			mmu_notifier_invalidate_range(mm, address, address+PAGE_SIZE);
+		}
 	}
 unlock:
 	pte_unmap_unlock(pte, ptl);
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -26,6 +26,7 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2037,6 +2038,7 @@ void exit_mmap(struct mm_struct *mm)
 	unsigned long end;
 
 	/* mm's last user has gone, and its about to be pulled down */
+	mmu_notifier_exit_mm(mm);
 	arch_exit_mmap(mm);
 
 	lru_add_drain();
Index: linux-2.6/mm/mmu_notifier.c
===================================================================
--- /dev/null
+++ linux-2.6/mm/mmu_notifier.c
@@ -0,0 +1,85 @@
+#include <linux/mmu_notifier.h>
+#include <linux/module.h>
+#include <linux/rcupdate.h>
+#include <linux/list.h>
+
+
+#define __mmu_notifier_for_each(mm, mn, hnode)			\
+	hlist_for_each_entry_rcu(mn, hnode, &(mm)->mmu_notifier_list, hlist)
+
+#define do_mmu_notifier_for_each(mm, mn)			\
+	do {							\
+		if (unlikely(!hlist_empty(&(mm)->mmu_notifier_list))) { \
+			struct hlist_node *__do_for_each_node;	\
+			rcu_read_lock();			\
+			__mmu_notifier_for_each(mm, mn, __do_for_each_node) {
+
+#define while_mmu_notifier_for_each				\
+			}					\
+			rcu_read_unlock();			\
+		}						\
+	} while (0)
+
+
+void mmu_notifier_register(struct mmu_notifier *mn)
+{
+	hlist_add_head_rcu(&mn->hlist, &mn->mm->mmu_notifier_list);
+	synchronize_rcu();
+}
+EXPORT_SYMBOL(mmu_notifier_register);
+
+void mmu_notifier_unregister(struct mmu_notifier *mn)
+{
+	hlist_del_rcu(&mn->hlist);
+	synchronize_rcu();
+}
+
+void mmu_notifier_exit_mm(struct mm_struct *mm)
+{
+	if (unlikely(!hlist_empty(&mm->mmu_notifier_list))) {
+		struct mmu_notifier *mn;
+		struct hlist_node *n, *t;
+
+		hlist_for_each_entry_safe(mn, n, t,
+				&mm->mmu_notifier_list, hlist) {
+			hlist_del_rcu(&mn->hlist);
+			if (mn->ops->release)
+				mn->ops->release(mn);
+		}
+	}
+}
+
+int mmu_notifier_clear_young(struct mm_struct *mm, unsigned long address)
+{
+	struct mmu_notifier *mn;
+	int ret = 0;
+
+	do_mmu_notifier_for_each(mm, mn) {
+		if (mn->ops->clear_young) {
+			if (mn->ops->clear_young(mn, address))
+				ret = 1;
+		}
+	} while_mmu_notifier_for_each;
+
+	return ret;
+}
+
+void mmu_notifier_unmap(struct mm_struct *mm, unsigned long address)
+{
+	struct mmu_notifier *mn;
+
+	do_mmu_notifier_for_each(mm, mn) {
+		if (mn->ops->unmap)
+			mn->ops->unmap(mn, address);
+	} while_mmu_notifier_for_each;
+}
+
+void mmu_notifier_invalidate_range(struct mm_struct *mm, unsigned long start, unsigned long end)
+{
+	struct mmu_notifier *mn;
+
+	do_mmu_notifier_for_each(mm, mn) {
+		if (mn->ops->invalidate_range)
+			mn->ops->invalidate_range(mn, start, end);
+	} while_mmu_notifier_for_each;
+}
Index: linux-2.6/mm/mprotect.c
===================================================================
--- linux-2.6.orig/mm/mprotect.c
+++ linux-2.6/mm/mprotect.c
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/mmu_notifier.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -45,6 +46,8 @@ static void change_pte_range(struct mm_s
 			 * into place.
 			 */
 			ptent = ptep_get_and_clear(mm, addr, pte);
+			mmu_notifier_unmap(mm, addr);
+
 			ptent = pte_modify(ptent, newprot);
 			/*
 			 * Avoid taking write faults for pages we know to be
@@ -125,6 +128,7 @@ static void change_protection(struct vm_
 		change_pud_range(mm, pgd, addr, next, newprot, dirty_accountable);
 	} while (pgd++, addr = next, addr != end);
 	flush_tlb_range(vma, start, end);
+	mmu_notifier_invalidate_range(mm, start, end);
 }
 
 int
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c
+++ linux-2.6/mm/mremap.c
@@ -18,6 +18,7 @@
 #include <linux/highmem.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -105,6 +106,7 @@ static void move_ptes(struct vm_area_str
 		if (pte_none(*old_pte))
 			continue;
 		pte = ptep_clear_flush(vma, old_addr, old_pte);
+		mmu_notifier_unmap(mm, old_addr);
 		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
 		set_pte_at(mm, new_addr, new_pte, pte);
 	}
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -49,6 +49,7 @@
 #include <linux/module.h>
 #include <linux/kallsyms.h>
 #include <linux/memcontrol.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/tlbflush.h>
 
@@ -287,8 +288,12 @@ static int page_referenced_one(struct pa
 	if (vma->vm_flags & VM_LOCKED) {
 		referenced++;
 		*mapcount = 1;	/* break early from loop */
-	} else if (ptep_clear_flush_young(vma, address, pte))
-		referenced++;
+	} else {
+		if (ptep_clear_flush_young(vma, address, pte))
+			referenced++;
+		if (mmu_notifier_clear_young(mm, address))
+			referenced++;
+	}
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
@@ -455,6 +460,7 @@ static int page_mkclean_one(struct page 
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
 		entry = ptep_clear_flush(vma, address, pte);
+		mmu_notifier_unmap(mm, address);
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
@@ -711,10 +717,21 @@ static int try_to_unmap_one(struct page 
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young(vma, address, pte)))) {
-		ret = SWAP_FAIL;
-		goto out_unmap;
+	if (!migration) {
+		int referenced;
+
+		if (vma->vm_flags & VM_LOCKED) {
+fail:
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
+		referenced = 0;
+		if (ptep_clear_flush_young(vma, address, pte))
+			referenced = 1;
+		if (mmu_notifier_clear_young(mm, address))
+			referenced = 1;
+		if (referenced)
+			goto fail;
 	}
 
 	/* Nuke the page table entry. */
@@ -724,6 +741,7 @@ static int try_to_unmap_one(struct page 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
 		set_page_dirty(page);
+	mmu_notifier_unmap(mm, address);
 
 	/* Update high watermark before we lower rss */
 	update_hiwater_rss(mm);
@@ -839,12 +857,19 @@ static void try_to_unmap_cluster(unsigne
 	update_hiwater_rss(mm);
 
 	for (; address < end; pte++, address += PAGE_SIZE) {
+		int referenced;
+
 		if (!pte_present(*pte))
 			continue;
 		page = vm_normal_page(vma, address, *pte);
 		BUG_ON(!page || PageAnon(page));
 
+		referenced = 0;
 		if (ptep_clear_flush_young(vma, address, pte))
+			referenced = 1;
+		if (mmu_notifier_clear_young(mm, address))
+			referenced = 1;
+		if (referenced)
 			continue;
 
 		/* Nuke the page table entry. */
@@ -858,6 +883,7 @@ static void try_to_unmap_cluster(unsigne
 		/* Move the dirty bit to the physical page now the pte is gone. */
 		if (pte_dirty(pteval))
 			set_page_dirty(page);
+		mmu_notifier_unmap(mm, address);
 
 		page_remove_rmap(page, vma);
 		page_cache_release(page);
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile
+++ linux-2.6/mm/Makefile
@@ -33,4 +33,4 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_CONT) += memcontrol.o
-
+obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig
+++ linux-2.6/mm/Kconfig
@@ -193,3 +193,7 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config MMU_NOTIFIER
+	bool "MMU notifiers"
+	def_bool y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
