Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 00A2C6B007E
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 23:02:22 -0500 (EST)
Message-Id: <20100202040216.113119000@alcatraz.americas.sgi.com>
Date: Mon, 01 Feb 2010 22:01:48 -0600
From: Robin Holt <holt@sgi.com>
Subject: [RFP-V2 3/3] Make mmu_notifier_invalidate_range_start able to sleep.
References: <20100202040145.555474000@alcatraz.americas.sgi.com>
Content-Disposition: inline; filename=mmu_notifier_truncate_sleepable_v1
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Make the truncate case handle the need to sleep.  We accomplish this
by failing the mmu_notifier_invalidate_range_start(... atomic==1)
case which in turn falls back to unmap_mapping_range_vma() with the
restart_address == start_address.  In that case, we make an additional
callout to mmu_notifier_invalidate_range_start(... atomic==0) after the
i_mmap_lock has been released.

Signed-off-by: Robin Holt <holt@sgi.com>
To: Andrew Morton <akpm@linux-foundation.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Jack Steiner <steiner@sgi.com>
Cc: linux-mm@kvack.org

---

 drivers/misc/sgi-gru/grutlbpurge.c |    8 +++++---
 include/linux/mmu_notifier.h       |   22 ++++++++++++----------
 mm/fremap.c                        |    2 +-
 mm/hugetlb.c                       |    2 +-
 mm/memory.c                        |   29 +++++++++++++++++++++++------
 mm/mmu_notifier.c                  |   10 ++++++----
 mm/mprotect.c                      |    2 +-
 mm/mremap.c                        |    2 +-
 virt/kvm/kvm_main.c                |   11 +++++++----
 9 files changed, 57 insertions(+), 31 deletions(-)

Index: mmu_notifiers_sleepable_v2/drivers/misc/sgi-gru/grutlbpurge.c
===================================================================
--- mmu_notifiers_sleepable_v2.orig/drivers/misc/sgi-gru/grutlbpurge.c	2010-02-01 21:10:06.000000000 -0600
+++ mmu_notifiers_sleepable_v2/drivers/misc/sgi-gru/grutlbpurge.c	2010-02-01 21:41:19.000000000 -0600
@@ -219,9 +219,10 @@ void gru_flush_all_tlb(struct gru_state 
 /*
  * MMUOPS notifier callout functions
  */
-static void gru_invalidate_range_start(struct mmu_notifier *mn,
-				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end)
+static int gru_invalidate_range_start(struct mmu_notifier *mn,
+				      struct mm_struct *mm,
+				      unsigned long start, unsigned long end,
+				      bool atomic)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
@@ -231,6 +232,7 @@ static void gru_invalidate_range_start(s
 	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx, act %d\n", gms,
 		start, end, atomic_read(&gms->ms_range_active));
 	gru_flush_tlb_range(gms, start, end - start);
+	return 0;
 }
 
 static void gru_invalidate_range_end(struct mmu_notifier *mn,
Index: mmu_notifiers_sleepable_v2/include/linux/mmu_notifier.h
===================================================================
--- mmu_notifiers_sleepable_v2.orig/include/linux/mmu_notifier.h	2010-02-01 21:10:20.000000000 -0600
+++ mmu_notifiers_sleepable_v2/include/linux/mmu_notifier.h	2010-02-01 21:10:21.000000000 -0600
@@ -127,9 +127,10 @@ struct mmu_notifier_ops {
 	 * address space but may still be referenced by sptes until
 	 * the last refcount is dropped.
 	 */
-	void (*invalidate_range_start)(struct mmu_notifier *mn,
+	int (*invalidate_range_start)(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end);
+				       unsigned long start, unsigned long end,
+				       bool atomic);
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
 				     struct mm_struct *mm,
 				     unsigned long start, unsigned long end);
@@ -170,8 +171,8 @@ extern void __mmu_notifier_change_pte(st
 				      unsigned long address, pte_t pte);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address);
-extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end);
+extern int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+			    unsigned long start, unsigned long end, bool atomic);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 
@@ -203,11 +204,12 @@ static inline void mmu_notifier_invalida
 		__mmu_notifier_invalidate_page(mm, address);
 }
 
-static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+static inline int mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+			     unsigned long start, unsigned long end, bool atomic)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_start(mm, start, end);
+		return __mmu_notifier_invalidate_range_start(mm, start, end, atomic);
+	return 0;
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
@@ -288,10 +290,10 @@ static inline void mmu_notifier_invalida
 					  unsigned long address)
 {
 }
-
-static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+static inline int mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+			     unsigned long start, unsigned long end, bool atomic)
 {
+	return 0;
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
Index: mmu_notifiers_sleepable_v2/mm/fremap.c
===================================================================
--- mmu_notifiers_sleepable_v2.orig/mm/fremap.c	2010-02-01 21:10:06.000000000 -0600
+++ mmu_notifiers_sleepable_v2/mm/fremap.c	2010-02-01 21:41:19.000000000 -0600
@@ -226,7 +226,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
 		vma->vm_flags = saved_flags;
 	}
 
-	mmu_notifier_invalidate_range_start(mm, start, start + size);
+	mmu_notifier_invalidate_range_start(mm, start, start + size, 0);
 	err = populate_range(mm, vma, start, size, pgoff);
 	mmu_notifier_invalidate_range_end(mm, start, start + size);
 	if (!err && !(flags & MAP_NONBLOCK)) {
Index: mmu_notifiers_sleepable_v2/mm/hugetlb.c
===================================================================
--- mmu_notifiers_sleepable_v2.orig/mm/hugetlb.c	2010-02-01 21:10:06.000000000 -0600
+++ mmu_notifiers_sleepable_v2/mm/hugetlb.c	2010-02-01 21:41:19.000000000 -0600
@@ -2159,7 +2159,7 @@ void __unmap_hugepage_range(struct vm_ar
 	BUG_ON(start & ~huge_page_mask(h));
 	BUG_ON(end & ~huge_page_mask(h));
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, start, end, 0);
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address);
Index: mmu_notifiers_sleepable_v2/mm/memory.c
===================================================================
--- mmu_notifiers_sleepable_v2.orig/mm/memory.c	2010-02-01 21:10:21.000000000 -0600
+++ mmu_notifiers_sleepable_v2/mm/memory.c	2010-02-01 21:41:19.000000000 -0600
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
@@ -1023,7 +1024,10 @@ unsigned long unmap_vmas(struct mmu_gath
 	 * mmu_notifier_invalidate_range_start can sleep. Don't initialize
 	 * mmu_gather until it completes
 	 */
-	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
+	if (mmu_notifier_invalidate_range_start(mm, start_addr,
+					end_addr, (i_mmap_lock == NULL)));
+		goto out;
+
 	*tlbp = tlb_gather_mmu(mm, fullmm);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;
@@ -1107,7 +1111,7 @@ unsigned long zap_page_range(struct vm_a
 		unsigned long size, struct zap_details *details)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct mmu_gather *tlb;
+	struct mmu_gather *tlb = NULL;
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
 
@@ -1908,7 +1912,7 @@ int apply_to_page_range(struct mm_struct
 	int err;
 
 	BUG_ON(addr >= end);
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, start, end, 0);
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -2329,6 +2333,7 @@ static int unmap_mapping_range_vma(struc
 {
 	unsigned long restart_addr;
 	int need_break;
+	int need_unlocked_invalidate;
 
 	/*
 	 * files that support invalidating or truncating portions of the
@@ -2350,7 +2355,9 @@ again:
 
 	restart_addr = zap_page_range(vma, start_addr,
 					end_addr - start_addr, details);
-	need_break = need_resched() || spin_needbreak(details->i_mmap_lock);
+	need_unlocked_invalidate = (restart_addr == start_addr);
+	need_break = need_resched() || spin_needbreak(details->i_mmap_lock) ||
+					need_unlocked_invalidate;
 
 	if (restart_addr >= end_addr) {
 		/* We have now completed this vma: mark it so */
@@ -2365,6 +2372,16 @@ again:
 	}
 
 	spin_unlock(details->i_mmap_lock);
+	if (need_unlocked_invalidate) {
+		/*
+		 * If zap_page_range failed to make any progress because the
+		 * mmu_notifier_invalidate_range_start was called atomically
+		 * while the callee needed to sleep.  In that event, we
+		 * make the callout while the i_mmap_lock is released.
+		 */
+		mmu_notifier_invalidate_range_start(vma->vm_mm, start_addr, end_addr, 0);
+		mmu_notifier_invalidate_range_end(vma->vm_mm, start_addr, end_addr);
+	}
 	cond_resched();
 	spin_lock(details->i_mmap_lock);
 	return -EINTR;
Index: mmu_notifiers_sleepable_v2/mm/mmu_notifier.c
===================================================================
--- mmu_notifiers_sleepable_v2.orig/mm/mmu_notifier.c	2010-02-01 21:10:20.000000000 -0600
+++ mmu_notifiers_sleepable_v2/mm/mmu_notifier.c	2010-02-01 21:41:19.000000000 -0600
@@ -135,20 +135,22 @@ void __mmu_notifier_invalidate_page(stru
 	}
 	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 }
-
-void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+			     unsigned long start, unsigned long end, bool atomic)
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
Index: mmu_notifiers_sleepable_v2/mm/mprotect.c
===================================================================
--- mmu_notifiers_sleepable_v2.orig/mm/mprotect.c	2010-02-01 21:10:06.000000000 -0600
+++ mmu_notifiers_sleepable_v2/mm/mprotect.c	2010-02-01 21:41:19.000000000 -0600
@@ -204,7 +204,7 @@ success:
 		dirty_accountable = 1;
 	}
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, start, end, 0);
 	if (is_vm_hugetlb_page(vma))
 		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
 	else
Index: mmu_notifiers_sleepable_v2/mm/mremap.c
===================================================================
--- mmu_notifiers_sleepable_v2.orig/mm/mremap.c	2010-02-01 21:10:06.000000000 -0600
+++ mmu_notifiers_sleepable_v2/mm/mremap.c	2010-02-01 21:41:19.000000000 -0600
@@ -82,7 +82,7 @@ static void move_ptes(struct vm_area_str
 
 	old_start = old_addr;
 	mmu_notifier_invalidate_range_start(vma->vm_mm,
-					    old_start, old_end);
+					    old_start, old_end, 0);
 	if (vma->vm_file) {
 		/*
 		 * Subtle point from Rajesh Venkatasubramanian: before
Index: mmu_notifiers_sleepable_v2/virt/kvm/kvm_main.c
===================================================================
--- mmu_notifiers_sleepable_v2.orig/virt/kvm/kvm_main.c	2010-02-01 21:10:06.000000000 -0600
+++ mmu_notifiers_sleepable_v2/virt/kvm/kvm_main.c	2010-02-01 21:41:19.000000000 -0600
@@ -259,10 +259,11 @@ static void kvm_mmu_notifier_change_pte(
 	spin_unlock(&kvm->mmu_lock);
 }
 
-static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
-						    struct mm_struct *mm,
-						    unsigned long start,
-						    unsigned long end)
+static int kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
+						   struct mm_struct *mm,
+						   unsigned long start,
+						   unsigned long end,
+						   bool atomic)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 	int need_tlb_flush = 0;
@@ -281,6 +282,8 @@ static void kvm_mmu_notifier_invalidate_
 	/* we've to flush the tlb before the pages can be freed */
 	if (need_tlb_flush)
 		kvm_flush_remote_tlbs(kvm);
+
+	return 0;
 }
 
 static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
