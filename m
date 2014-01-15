Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3076B0037
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 04:40:52 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id e53so718947eek.39
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 01:40:51 -0800 (PST)
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
        by mx.google.com with ESMTPS id n47si6639511eef.199.2014.01.15.01.40.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 01:40:51 -0800 (PST)
Received: by mail-ee0-f43.google.com with SMTP id c41so733404eek.30
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 01:40:50 -0800 (PST)
From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH] mm/mmu_notifier: restore set_pte_at_notify semantics
Date: Wed, 15 Jan 2014 11:40:34 +0200
Message-Id: <1389778834-21200-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Izik Eidus <izik.eidus@ravellosystems.com>, Mike Rapoport <mike.rapoport@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Haggai Eran <haggaie@mellanox.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

Commit 6bdb913f0a70a4dfb7f066fb15e2d6f960701d00 (mm: wrap calls to
set_pte_at_notify with invalidate_range_start and invalidate_range_end)
breaks semantics of set_pte_at_notify. When calls to set_pte_at_notify
are wrapped with mmu_notifier_invalidate_range_start and
mmu_notifier_invalidate_range_end, KVM zaps pte during
mmu_notifier_invalidate_range_start callback and set_pte_at_notify has
no spte to update and therefore it's called for nothing.

As Andrea suggested (1), the problem is resolved by calling
mmu_notifier_invalidate_page after PT lock has been released and only
for mmu_notifiers that do not implement change_ptr callback.

(1) http://thread.gmane.org/gmane.linux.kernel.mm/111710/focus=111711

Reported-by: Izik Eidus <izik.eidus@ravellosystems.com>
Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Haggai Eran <haggaie@mellanox.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mmu_notifier.h | 31 ++++++++++++++++++++++++++-----
 kernel/events/uprobes.c      | 12 ++++++------
 mm/ksm.c                     | 15 +++++----------
 mm/memory.c                  | 14 +++++---------
 mm/mmu_notifier.c            | 24 ++++++++++++++++++++++--
 5 files changed, 64 insertions(+), 32 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index deca874..46c96cb 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -176,14 +176,17 @@ extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long address);
 extern int __mmu_notifier_test_young(struct mm_struct *mm,
 				     unsigned long address);
-extern void __mmu_notifier_change_pte(struct mm_struct *mm,
-				      unsigned long address, pte_t pte);
+extern int __mmu_notifier_change_pte(struct mm_struct *mm,
+				     unsigned long address, pte_t pte);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
+extern void
+__mmu_notifier_invalidate_page_if_missing_change_pte(struct mm_struct *mm,
+						     unsigned long address);
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
@@ -207,11 +210,12 @@ static inline int mmu_notifier_test_young(struct mm_struct *mm,
 	return 0;
 }
 
-static inline void mmu_notifier_change_pte(struct mm_struct *mm,
+static inline int mmu_notifier_change_pte(struct mm_struct *mm,
 					   unsigned long address, pte_t pte)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_change_pte(mm, address, pte);
+		return __mmu_notifier_change_pte(mm, address, pte);
+	return 0;
 }
 
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
@@ -235,6 +239,15 @@ static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 		__mmu_notifier_invalidate_range_end(mm, start, end);
 }
 
+static inline
+void mmu_notifier_invalidate_page_if_missing_change_pte(struct mm_struct *mm,
+							unsigned long address)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_page_if_missing_change_pte(mm,
+								     address);
+}
+
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
 {
 	mm->mmu_notifier_mm = NULL;
@@ -283,9 +296,11 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	struct mm_struct *___mm = __mm;					\
 	unsigned long ___address = __address;				\
 	pte_t ___pte = __pte;						\
+	int ___ret;							\
 									\
-	mmu_notifier_change_pte(___mm, ___address, ___pte);		\
+	___ret = mmu_notifier_change_pte(___mm, ___address, ___pte);	\
 	set_pte_at(___mm, ___address, __ptep, ___pte);			\
+	___ret;								\
 })
 
 #else /* CONFIG_MMU_NOTIFIER */
@@ -326,6 +341,12 @@ static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 {
 }
 
+static inline
+void mmu_notifier_invalidate_page_if_missing_change_pte(struct mm_struct *mm,
+							unsigned long address)
+{
+}
+
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
 {
 }
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 24b7d6c..ec49338 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -131,14 +131,11 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	spinlock_t *ptl;
 	pte_t *ptep;
 	int err;
-	/* For mmu_notifiers */
-	const unsigned long mmun_start = addr;
-	const unsigned long mmun_end   = addr + PAGE_SIZE;
+	int notify_missing = 0;
 
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(page);
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	err = -EAGAIN;
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -154,20 +151,23 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
+	notify_missing = set_pte_at_notify(mm, addr, ptep,
+					   mk_pte(kpage, vma->vm_page_prot));
 
 	page_remove_rmap(page);
 	if (!page_mapped(page))
 		try_to_free_swap(page);
 	pte_unmap_unlock(ptep, ptl);
 
+	if (notify_missing)
+		mmu_notifier_invalidate_page_if_missing_change_pte(mm, addr);
+
 	if (vma->vm_flags & VM_LOCKED)
 		munlock_vma_page(page);
 	put_page(page);
 
 	err = 0;
  unlock:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	unlock_page(page);
 	return err;
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index 175fff7..42e8254 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -861,8 +861,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 	spinlock_t *ptl;
 	int swapped;
 	int err = -EFAULT;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	int notify_missing = 0;
 
 	addr = page_address_in_vma(page, vma);
 	if (addr == -EFAULT)
@@ -870,13 +869,9 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	BUG_ON(PageTransCompound(page));
 
-	mmun_start = addr;
-	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
-		goto out_mn;
+		goto out;
 
 	if (pte_write(*ptep) || pte_dirty(*ptep)) {
 		pte_t entry;
@@ -904,15 +899,15 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		if (pte_dirty(entry))
 			set_page_dirty(page);
 		entry = pte_mkclean(pte_wrprotect(entry));
-		set_pte_at_notify(mm, addr, ptep, entry);
+		notify_missing = set_pte_at_notify(mm, addr, ptep, entry);
 	}
 	*orig_pte = *ptep;
 	err = 0;
 
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
-out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	if (notify_missing)
+		mmu_notifier_invalidate_page_if_missing_change_pte(mm, addr);
 out:
 	return err;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 6768ce9..596d4c3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2611,8 +2611,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int ret = 0;
 	int page_mkwrite = 0;
 	struct page *dirty_page = NULL;
-	unsigned long mmun_start = 0;	/* For mmu_notifiers */
-	unsigned long mmun_end = 0;	/* For mmu_notifiers */
+	int notify_missing = 0;
 
 	old_page = vm_normal_page(vma, address, orig_pte);
 	if (!old_page) {
@@ -2798,10 +2797,6 @@ gotten:
 	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
 		goto oom_free_new;
 
-	mmun_start  = address & PAGE_MASK;
-	mmun_end    = mmun_start + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
@@ -2830,7 +2825,8 @@ gotten:
 		 * mmu page tables (such as kvm shadow page tables), we want the
 		 * new page to be mapped directly into the secondary page table.
 		 */
-		set_pte_at_notify(mm, address, page_table, entry);
+		notify_missing = set_pte_at_notify(mm, address, page_table,
+						   entry);
 		update_mmu_cache(vma, address, page_table);
 		if (old_page) {
 			/*
@@ -2868,8 +2864,8 @@ gotten:
 		page_cache_release(new_page);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
-	if (mmun_end > mmun_start)
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	if (notify_missing)
+		mmu_notifier_invalidate_page_if_missing_change_pte(mm, address);
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 93e6089..5fc5bc2 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -122,18 +122,23 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
 	return young;
 }
 
-void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
-			       pte_t pte)
+int __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
+			      pte_t pte)
 {
 	struct mmu_notifier *mn;
 	int id;
+	int ret = 0;
 
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->change_pte)
 			mn->ops->change_pte(mn, mm, address, pte);
+		else
+			ret = 1;
 	}
 	srcu_read_unlock(&srcu, id);
+
+	return ret;
 }
 
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
@@ -180,6 +185,21 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_end);
 
+void __mmu_notifier_invalidate_page_if_missing_change_pte(struct mm_struct *mm,
+							  unsigned long address)
+{
+	struct mmu_notifier *mn;
+	int id;
+
+	id = srcu_read_lock(&srcu);
+	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->invalidate_page && !mn->ops->change_pte)
+			mn->ops->invalidate_page(mn, mm, address);
+	}
+	srcu_read_unlock(&srcu, id);
+}
+EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_page_if_missing_change_pte);
+
 static int do_mmu_notifier_register(struct mmu_notifier *mn,
 				    struct mm_struct *mm,
 				    int take_mmap_sem)
-- 
1.8.1.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
