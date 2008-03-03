Date: Mon, 3 Mar 2008 04:33:54 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] mmu notifiers #v8
Message-ID: <20080303033354.GC3301@wotan.suse.de>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080302155457.GK8091@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Sun, Mar 02, 2008 at 04:54:57PM +0100, Andrea Arcangeli wrote:
> Difference between #v7 and #v8:

[patch] mmu-v8: demacro


Remove the macros from mmu_notifier.h, in favour of functions.

This requires untangling the include order circular dependencies as well,
so just remove struct mmu_notifier_head in favour of just using the hlist
in mm_struct.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/include/linux/mmu_notifier.h
===================================================================
--- linux-2.6.orig/include/linux/mmu_notifier.h
+++ linux-2.6/include/linux/mmu_notifier.h
@@ -55,12 +55,13 @@ struct mmu_notifier {
 
 #ifdef CONFIG_MMU_NOTIFIER
 
-struct mmu_notifier_head {
-	struct hlist_head head;
-};
-
 #include <linux/mm_types.h>
 
+static inline int mm_has_notifiers(struct mm_struct *mm)
+{
+	return unlikely(!hlist_empty(&mm->mmu_notifier_list));
+}
+
 /*
  * Must hold the mmap_sem for write.
  *
@@ -79,33 +80,59 @@ extern void mmu_notifier_register(struct
  */
 extern void mmu_notifier_unregister(struct mmu_notifier *mn,
 				    struct mm_struct *mm);
-extern void mmu_notifier_release(struct mm_struct *mm);
-extern int mmu_notifier_clear_flush_young(struct mm_struct *mm,
+
+extern void __mmu_notifier_release(struct mm_struct *mm);
+extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long address);
+extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
+					  unsigned long address);
+extern void __mmu_notifier_invalidate_range_begin(struct mm_struct *mm,
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
+static inline void mmu_notifier_invalidate_range_begin(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_range_begin(mm, start, end);
+}
+
+static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_range_end(mm, start, end);
+}
 
-static inline void mmu_notifier_head_init(struct mmu_notifier_head *mnh)
+static inline void mmu_notifier_mm_init(struct mm_struct *mm)
 {
-	INIT_HLIST_HEAD(&mnh->head);
+	INIT_HLIST_HEAD(&mm->mmu_notifier_list);
 }
 
-#define mmu_notifier(function, mm, args...)				\
-	do {								\
-		struct mmu_notifier *__mn;				\
-		struct hlist_node *__n;					\
-		struct mm_struct * __mm = mm;				\
-									\
-		if (unlikely(!hlist_empty(&__mm->mmu_notifier.head))) { \
-			rcu_read_lock();				\
-			hlist_for_each_entry_rcu(__mn, __n,		\
-						 &__mm->mmu_notifier.head, \
-						 hlist)			\
-				if (__mn->ops->function)		\
-					__mn->ops->function(__mn,	\
-							    __mm,	\
-							    args);	\
-			rcu_read_unlock();				\
-		}							\
-	} while (0)
+
 
 #define ptep_clear_flush_notify(__vma, __address, __ptep)		\
 ({									\
@@ -113,7 +140,7 @@ static inline void mmu_notifier_head_ini
 	struct vm_area_struct * ___vma = __vma;				\
 	unsigned long ___address = __address;				\
 	__pte = ptep_clear_flush(___vma, ___address, __ptep);		\
-	mmu_notifier(invalidate_page, ___vma->vm_mm, ___address);	\
+	mmu_notifier_invalidate_page(___vma->vm_mm, ___address);	\
 	__pte;								\
 })
 
@@ -130,28 +157,34 @@ static inline void mmu_notifier_head_ini
 
 #else /* CONFIG_MMU_NOTIFIER */
 
-struct mmu_notifier_head {};
+static inline void mmu_notifier_release(struct mm_struct *mm)
+{
+}
 
-#define mmu_notifier_register(mn, mm) do {} while(0)
-#define mmu_notifier_unregister(mn, mm) do {} while (0)
-#define mmu_notifier_release(mm) do {} while (0)
-#define mmu_notifier_head_init(mmh) do {} while (0)
+static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return 0;
+}
 
-/*
- * Notifiers that use the parameters that they were passed so that the
- * compiler does not complain about unused variables but does proper
- * parameter checks even if !CONFIG_MMU_NOTIFIER.
- * Macros generate no code.
- */
-#define mmu_notifier(function, mm, args...)			       \
-	do {							       \
-		if (0) {					       \
-			struct mmu_notifier *__mn;		       \
-								       \
-			__mn = (struct mmu_notifier *)(0x00ff);	       \
-			__mn->ops->function(__mn, mm, args);	       \
-		};						       \
-	} while (0)
+static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
+					  unsigned long address)
+{
+}
+
+static inline void mmu_notifier_invalidate_range_begin(struct mm_struct *mm,
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
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define ptep_clear_flush_notify ptep_clear_flush
Index: linux-2.6/mm/mmu_notifier.c
===================================================================
--- linux-2.6.orig/mm/mmu_notifier.c
+++ linux-2.6/mm/mmu_notifier.c
@@ -17,12 +17,12 @@
  * No synchronization. This function can only be called when only a single
  * process remains that performs teardown.
  */
-void mmu_notifier_release(struct mm_struct *mm)
+void __mmu_notifier_release(struct mm_struct *mm)
 {
 	struct mmu_notifier *mn;
 
-	while (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
-		mn = hlist_entry(mm->mmu_notifier.head.first,
+	while (unlikely(!hlist_empty(&mm->mmu_notifier_list))) {
+		mn = hlist_entry(mm->mmu_notifier_list.first,
 				 struct mmu_notifier,
 				 hlist);
 		hlist_del(&mn->hlist);
@@ -32,30 +32,69 @@ void mmu_notifier_release(struct mm_stru
 }
 
 /*
- * If no young bitflag is supported by the hardware, ->age_page can
+ * If no young bitflag is supported by the hardware, ->clear_flush_young can
  * unmap the address and return 1 or 0 depending if the mapping previously
  * existed or not.
  */
-int mmu_notifier_clear_flush_young(struct mm_struct *mm, unsigned long address)
+int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
+					unsigned long address)
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
 	int young = 0;
 
-	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(mn, n,
-					 &mm->mmu_notifier.head, hlist) {
-			if (mn->ops->clear_flush_young)
-				young |= mn->ops->clear_flush_young(mn, mm,
-								    address);
-		}
-		rcu_read_unlock();
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
+		if (mn->ops->clear_flush_young)
+			young |= mn->ops->clear_flush_young(mn, mm, address);
 	}
+	rcu_read_unlock();
 
 	return young;
 }
 
+void __mmu_notifier_invalidate_page(struct mm_struct *mm,
+					  unsigned long address)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
+		if (mn->ops->invalidate_page)
+			mn->ops->invalidate_page(mn, mm, address);
+	}
+	rcu_read_unlock();
+}
+
+void __mmu_notifier_invalidate_range_begin(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
+		if (mn->ops->invalidate_range_begin)
+			mn->ops->invalidate_range_begin(mn, mm, start, end);
+	}
+	rcu_read_unlock();
+}
+
+void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
+		if (mn->ops->invalidate_range_end)
+			mn->ops->invalidate_range_end(mn, mm, start, end);
+	}
+	rcu_read_unlock();
+}
+
 /*
  * Note that all notifiers use RCU. The updates are only guaranteed to
  * be visible to other processes after a RCU quiescent period!
@@ -64,7 +103,7 @@ int mmu_notifier_clear_flush_young(struc
  */
 void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier.head);
+	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier_list);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_register);
 
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
@@ -214,9 +215,9 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
-	mmu_notifier(invalidate_range_begin, mm, start, start + size);
+	mmu_notifier_invalidate_range_begin(mm, start, start + size);
 	err = populate_range(mm, vma, start, size, pgoff);
-	mmu_notifier(invalidate_range_end, mm, start, start + size);
+	mmu_notifier_invalidate_range_end(mm, start, start + size);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {
 			downgrade_write(&mm->mmap_sem);
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
@@ -755,7 +756,7 @@ void __unmap_hugepage_range(struct vm_ar
 	BUG_ON(start & ~HPAGE_MASK);
 	BUG_ON(end & ~HPAGE_MASK);
 
-	mmu_notifier(invalidate_range_begin, mm, start, end);
+	mmu_notifier_invalidate_range_begin(mm, start, end);
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
@@ -776,7 +777,7 @@ void __unmap_hugepage_range(struct vm_ar
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
-	mmu_notifier(invalidate_range_end, mm, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
 		put_page(page);
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
@@ -612,7 +613,7 @@ int copy_page_range(struct mm_struct *ds
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
 	if (is_cow_mapping(vma->vm_flags))
-		mmu_notifier(invalidate_range_begin, src_mm, addr, end);
+		mmu_notifier_invalidate_range_begin(src_mm, addr, end);
 
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
@@ -626,7 +627,7 @@ int copy_page_range(struct mm_struct *ds
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow_mapping(vma->vm_flags))
-		mmu_notifier(invalidate_range_end, src_mm,
+		mmu_notifier_invalidate_range_end(src_mm,
 						vma->vm_start, end);
 
 	return 0;
@@ -905,9 +906,9 @@ unsigned long zap_page_range(struct vm_a
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	mmu_notifier(invalidate_range_begin, mm, address, end);
+	mmu_notifier_invalidate_range_begin(mm, address, end);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
-	mmu_notifier(invalidate_range_end, mm, address, end);
+	mmu_notifier_invalidate_range_end(mm, address, end);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
 	return end;
@@ -1477,7 +1478,7 @@ int apply_to_page_range(struct mm_struct
 	int err;
 
 	BUG_ON(addr >= end);
-	mmu_notifier(invalidate_range_begin, mm, start, end);
+	mmu_notifier_invalidate_range_begin(mm, start, end);
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1485,7 +1486,7 @@ int apply_to_page_range(struct mm_struct
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
-	mmu_notifier(invalidate_range_end, mm, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 	return err;
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
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
@@ -1747,13 +1748,13 @@ static void unmap_region(struct mm_struc
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	mmu_notifier(invalidate_range_begin, mm, start, end);
+	mmu_notifier_invalidate_range_begin(mm, start, end);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
-	mmu_notifier(invalidate_range_end, mm, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 }
 
 /*
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
@@ -198,12 +199,12 @@ success:
 		dirty_accountable = 1;
 	}
 
-	mmu_notifier(invalidate_range_begin, mm, start, end);
+	mmu_notifier_invalidate_range_begin(mm, start, end);
 	if (is_vm_hugetlb_page(vma))
 		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
 	else
 		change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
-	mmu_notifier(invalidate_range_end, mm, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
 	return 0;
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
@@ -102,7 +103,7 @@ static void move_ptes(struct vm_area_str
 	arch_enter_lazy_mmu_mode();
 
 	old_start = old_addr;
-	mmu_notifier(invalidate_range_begin, vma->vm_mm,
+	mmu_notifier_invalidate_range_begin(vma->vm_mm,
 		     old_start, old_end);
 	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
 				   new_pte++, new_addr += PAGE_SIZE) {
@@ -112,7 +113,7 @@ static void move_ptes(struct vm_area_str
 		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
 		set_pte_at(mm, new_addr, new_pte, pte);
 	}
-	mmu_notifier(invalidate_range_end, vma->vm_mm, old_start, old_end);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, old_start, old_end);
 
 	arch_leave_lazy_mmu_mode();
 	if (new_ptl != old_ptl)
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h
+++ linux-2.6/include/linux/mm_types.h
@@ -10,7 +10,6 @@
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
 #include <linux/completion.h>
-#include <linux/mmu_notifier.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -229,8 +228,9 @@ struct mm_struct {
 #ifdef CONFIG_CGROUP_MEM_CONT
 	struct mem_cgroup *mem_cgroup;
 #endif
-
-	struct mmu_notifier_head mmu_notifier; /* MMU notifier list */
+#ifdef CONFIG_MMU_NOTIFIER
+	struct hlist_head mmu_notifier_list;
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
