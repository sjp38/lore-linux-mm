Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DC5E26004A8
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 14:56:36 -0500 (EST)
Message-Id: <20100128195634.798620000@alcatraz.americas.sgi.com>
Date: Thu, 28 Jan 2010 13:56:30 -0600
From: Robin Holt <holt@sgi.com>
Subject: [RFP 3/3] Make mmu_notifier_invalidate_range_start able to sleep.
References: <20100128195627.373584000@alcatraz.americas.sgi.com>
Content-Disposition: inline; filename=mmu_notifier_truncate_sleepable_v1
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>


Make the truncate case handle the need to sleep.  We accomplish this
by failing the mmu_notifier_invalidate_range_start(... atomic==1)
case which inturn falls back to unmap_mapping_range_vma() with the
restart_address == start_address.  In that case, we make an additional
callout to mmu_notifier_invalidate_range_start(... atomic==0) after the
i_mmap_lock has been released.

Signed-off-by: Robin Holt <holt@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org

---

 include/linux/mmu_notifier.h |   17 +++++++++--------
 mm/fremap.c                  |    2 +-
 mm/hugetlb.c                 |    2 +-
 mm/memory.c                  |   25 +++++++++++++++++++------
 mm/mmu_notifier.c            |   10 ++++++----
 mm/mprotect.c                |    2 +-
 mm/mremap.c                  |    2 +-
 7 files changed, 38 insertions(+), 22 deletions(-)
Index: mmu_notifiers_sleepable_v1/include/linux/mmu_notifier.h
===================================================================
--- mmu_notifiers_sleepable_v1.orig/include/linux/mmu_notifier.h	2010-01-28 13:43:26.000000000 -0600
+++ mmu_notifiers_sleepable_v1/include/linux/mmu_notifier.h	2010-01-28 13:43:26.000000000 -0600
@@ -170,8 +170,8 @@ extern void __mmu_notifier_change_pte(st
 				      unsigned long address, pte_t pte);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address);
-extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end);
+extern int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+			    unsigned long start, unsigned long end, int atomic);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 
@@ -203,11 +203,12 @@ static inline void mmu_notifier_invalida
 		__mmu_notifier_invalidate_page(mm, address);
 }
 
-static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+static inline int mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+			     unsigned long start, unsigned long end, int atomic)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_start(mm, start, end);
+		return __mmu_notifier_invalidate_range_start(mm, start, end, atomic);
+	return 0;
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
@@ -288,10 +289,10 @@ static inline void mmu_notifier_invalida
 					  unsigned long address)
 {
 }
-
-static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+static inline int mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+			     unsigned long start, unsigned long end, int atomic)
 {
+	return 0;
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
Index: mmu_notifiers_sleepable_v1/mm/fremap.c
===================================================================
--- mmu_notifiers_sleepable_v1.orig/mm/fremap.c	2010-01-28 13:42:15.000000000 -0600
+++ mmu_notifiers_sleepable_v1/mm/fremap.c	2010-01-28 13:43:26.000000000 -0600
@@ -226,7 +226,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
 		vma->vm_flags = saved_flags;
 	}
 
-	mmu_notifier_invalidate_range_start(mm, start, start + size);
+	mmu_notifier_invalidate_range_start(mm, start, start + size, 0);
 	err = populate_range(mm, vma, start, size, pgoff);
 	mmu_notifier_invalidate_range_end(mm, start, start + size);
 	if (!err && !(flags & MAP_NONBLOCK)) {
Index: mmu_notifiers_sleepable_v1/mm/hugetlb.c
===================================================================
--- mmu_notifiers_sleepable_v1.orig/mm/hugetlb.c	2010-01-28 13:42:15.000000000 -0600
+++ mmu_notifiers_sleepable_v1/mm/hugetlb.c	2010-01-28 13:43:26.000000000 -0600
@@ -2159,7 +2159,7 @@ void __unmap_hugepage_range(struct vm_ar
 	BUG_ON(start & ~huge_page_mask(h));
 	BUG_ON(end & ~huge_page_mask(h));
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, start, end, 0);
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address);
Index: mmu_notifiers_sleepable_v1/mm/memory.c
===================================================================
--- mmu_notifiers_sleepable_v1.orig/mm/memory.c	2010-01-28 13:43:26.000000000 -0600
+++ mmu_notifiers_sleepable_v1/mm/memory.c	2010-01-28 13:43:26.000000000 -0600
@@ -786,7 +786,7 @@ int copy_page_range(struct mm_struct *ds
 	 * is_cow_mapping() returns true.
 	 */
 	if (is_cow_mapping(vma->vm_flags))
-		mmu_notifier_invalidate_range_start(src_mm, addr, end);
+		mmu_notifier_invalidate_range_start(src_mm, addr, end, 0);
 
 	ret = 0;
 	dst_pgd = pgd_offset(dst_mm, addr);
@@ -990,7 +990,8 @@ static unsigned long unmap_page_range(st
  * @nr_accounted: Place number of unmapped pages in vm-accountable vma's here
  * @details: details of nonlinear truncation or shared cache invalidation
  *
- * Returns the end address of the unmapping (restart addr if interrupted).
+ * Returns the end address of the unmapping (restart addr if interrupted, start
+ * if the i_mmap_lock is held and mmu_notifier_range_start() needs to sleep).
  *
  * Unmap all pages in the vma list.
  *
@@ -1018,12 +1019,17 @@ unsigned long unmap_vmas(struct mmu_gath
 	unsigned long start = start_addr;
 	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	struct mm_struct *mm = vma->vm_mm;
+	int ret;
 
 	/*
 	 * mmu_notifier_invalidate_range_start can sleep. Don't initialize
 	 * mmu_gather until it completes
 	 */
-	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
+	ret = mmu_notifier_invalidate_range_start(mm, start_addr,
+					end_addr, (i_mmap_lock == NULL));
+	if (ret)
+		goto out;
+
 	*tlbp = tlb_gather_mmu(mm, fullmm);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;
@@ -1107,7 +1113,7 @@ unsigned long zap_page_range(struct vm_a
 		unsigned long size, struct zap_details *details)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct mmu_gather *tlb;
+	struct mmu_gather *tlb == NULL;
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
 
@@ -1908,7 +1914,7 @@ int apply_to_page_range(struct mm_struct
 	int err;
 
 	BUG_ON(addr >= end);
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, start, end, 0);
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -2329,6 +2335,7 @@ static int unmap_mapping_range_vma(struc
 {
 	unsigned long restart_addr;
 	int need_break;
+	int need_unlocked_invalidate;
 
 	/*
 	 * files that support invalidating or truncating portions of the
@@ -2350,7 +2357,9 @@ again:
 
 	restart_addr = zap_page_range(vma, start_addr,
 					end_addr - start_addr, details);
-	need_break = need_resched() || spin_needbreak(details->i_mmap_lock);
+	need_unlocked_invalidate = (restart_addr == start_addr);
+	need_break = need_resched() || spin_needbreak(details->i_mmap_lock) ||
+					need_unlocked_invalidate;
 
 	if (restart_addr >= end_addr) {
 		/* We have now completed this vma: mark it so */
@@ -2365,6 +2374,10 @@ again:
 	}
 
 	spin_unlock(details->i_mmap_lock);
+	if (need_unlocked_invalidate) {
+		mmu_notifier_invalidate_range_start(vma->mm, start, end, 0);
+		mmu_notifier_invalidate_range_end(vma->mm, start, end);
+	}
 	cond_resched();
 	spin_lock(details->i_mmap_lock);
 	return -EINTR;
Index: mmu_notifiers_sleepable_v1/mm/mmu_notifier.c
===================================================================
--- mmu_notifiers_sleepable_v1.orig/mm/mmu_notifier.c	2010-01-28 13:43:26.000000000 -0600
+++ mmu_notifiers_sleepable_v1/mm/mmu_notifier.c	2010-01-28 13:43:26.000000000 -0600
@@ -135,20 +135,22 @@ void __mmu_notifier_invalidate_page(stru
 	}
 	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 }
-
-void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+			     unsigned long start, unsigned long end, int atomic)
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
 	int srcu;
+	int ret = 0;
 
 	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
-			mn->ops->invalidate_range_start(mn, mm, start, end);
+			ret |= mn->ops->invalidate_range_start(mn, mm, start,
+								end, atomic);
 	}
 	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
+	return ret;
 }
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
Index: mmu_notifiers_sleepable_v1/mm/mprotect.c
===================================================================
--- mmu_notifiers_sleepable_v1.orig/mm/mprotect.c	2010-01-28 13:42:15.000000000 -0600
+++ mmu_notifiers_sleepable_v1/mm/mprotect.c	2010-01-28 13:43:26.000000000 -0600
@@ -204,7 +204,7 @@ success:
 		dirty_accountable = 1;
 	}
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, start, end, 0);
 	if (is_vm_hugetlb_page(vma))
 		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
 	else
Index: mmu_notifiers_sleepable_v1/mm/mremap.c
===================================================================
--- mmu_notifiers_sleepable_v1.orig/mm/mremap.c	2010-01-28 13:42:15.000000000 -0600
+++ mmu_notifiers_sleepable_v1/mm/mremap.c	2010-01-28 13:43:26.000000000 -0600
@@ -82,7 +82,7 @@ static void move_ptes(struct vm_area_str
 
 	old_start = old_addr;
 	mmu_notifier_invalidate_range_start(vma->vm_mm,
-					    old_start, old_end);
+					    old_start, old_end, 0);
 	if (vma->vm_file) {
 		/*
 		 * Subtle point from Rajesh Venkatasubramanian: before

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
