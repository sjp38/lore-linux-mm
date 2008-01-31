Date: Wed, 30 Jan 2008 18:08:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] [patch 2/6] mmu_notifier: Callbacks to invalidate
 address ranges
In-Reply-To: <20080131003434.GE7185@v2.random>
Message-ID: <Pine.LNX.4.64.0801301805200.14071@schroedinger.engr.sgi.com>
References: <20080129220212.GX7233@v2.random>
 <Pine.LNX.4.64.0801291407380.27104@schroedinger.engr.sgi.com>
 <20080130000039.GA7233@v2.random> <20080130161123.GS26420@sgi.com>
 <20080130170451.GP7233@v2.random> <20080130173009.GT26420@sgi.com>
 <20080130182506.GQ7233@v2.random> <Pine.LNX.4.64.0801301147330.30568@schroedinger.engr.sgi.com>
 <20080130235214.GC7185@v2.random> <Pine.LNX.4.64.0801301555550.1722@schroedinger.engr.sgi.com>
 <20080131003434.GE7185@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Patch to


1. Remove sync on notifier_release. Must be called when only a 
   single process remain.

2. Add invalidate_range_start/end. This should allow safe removal
   of ranges of external ptes without having to resort to a callback
   for every individual page.

This must be able to nest so the driver needs to keep a refcount of range 
invalidates and wait if the refcount != 0.


---
 include/linux/mmu_notifier.h |   11 +++++++++--
 mm/fremap.c                  |    3 ++-
 mm/hugetlb.c                 |    3 ++-
 mm/memory.c                  |   16 ++++++++++------
 mm/mmu_notifier.c            |    9 ++++-----
 5 files changed, 27 insertions(+), 15 deletions(-)

Index: linux-2.6/mm/mmu_notifier.c
===================================================================
--- linux-2.6.orig/mm/mmu_notifier.c	2008-01-30 17:58:48.000000000 -0800
+++ linux-2.6/mm/mmu_notifier.c	2008-01-30 18:00:26.000000000 -0800
@@ -13,23 +13,22 @@
 #include <linux/mm.h>
 #include <linux/mmu_notifier.h>
 
+/*
+ * No synchronization. This function can only be called when only a single
+ * process remains that performs teardown.
+ */
 void mmu_notifier_release(struct mm_struct *mm)
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n, *t;
 
 	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
-		down_write(&mm->mmap_sem);
-		rcu_read_lock();
 		hlist_for_each_entry_safe_rcu(mn, n, t,
 					  &mm->mmu_notifier.head, hlist) {
 			hlist_del_rcu(&mn->hlist);
 			if (mn->ops->release)
 				mn->ops->release(mn, mm);
 		}
-		rcu_read_unlock();
-		up_write(&mm->mmap_sem);
-		synchronize_rcu();
 	}
 }
 
Index: linux-2.6/include/linux/mmu_notifier.h
===================================================================
--- linux-2.6.orig/include/linux/mmu_notifier.h	2008-01-30 17:58:48.000000000 -0800
+++ linux-2.6/include/linux/mmu_notifier.h	2008-01-30 18:00:26.000000000 -0800
@@ -67,15 +67,22 @@ struct mmu_notifier_ops {
 				int dummy);
 
 	/*
+	 * invalidate_range_begin() and invalidate_range_end() are paired.
+	 *
+	 * invalidate_range_begin must clear all references in the range
+	 * and stop the establishment of new references.
+	 *
+	 * invalidate_range_end() reenables the establishment of references.
+	 *
 	 * lock indicates that the function is called under spinlock.
 	 */
 	void (*invalidate_range_begin)(struct mmu_notifier *mn,
 				 struct mm_struct *mm,
+				 unsigned long start, unsigned long end,
 				 int lock);
 
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
-				 struct mm_struct *mm,
-				 unsigned long start, unsigned long end);
+				 struct mm_struct *mm);
 };
 
 struct mmu_rmap_notifier_ops;
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c	2008-01-30 17:58:48.000000000 -0800
+++ linux-2.6/mm/fremap.c	2008-01-30 18:00:26.000000000 -0800
@@ -212,8 +212,9 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
+	mmu_notifier(invalidate_range_start, mm, start, start + size, 0);
 	err = populate_range(mm, vma, start, size, pgoff);
-	mmu_notifier(invalidate_range, mm, start, start + size, 0);
+	mmu_notifier(invalidate_range_end, mm);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {
 			downgrade_write(&mm->mmap_sem);
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-01-30 17:58:48.000000000 -0800
+++ linux-2.6/mm/hugetlb.c	2008-01-30 18:00:26.000000000 -0800
@@ -744,6 +744,7 @@ void __unmap_hugepage_range(struct vm_ar
 	BUG_ON(start & ~HPAGE_MASK);
 	BUG_ON(end & ~HPAGE_MASK);
 
+	mmu_notifier(invalidate_range_start, mm, start, end, 1);
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
@@ -764,7 +765,7 @@ void __unmap_hugepage_range(struct vm_ar
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
-	mmu_notifier(invalidate_range, mm, start, end, 1);
+	mmu_notifier(invalidate_range_end, mm);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
 		put_page(page);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-01-30 17:58:48.000000000 -0800
+++ linux-2.6/mm/memory.c	2008-01-30 18:00:51.000000000 -0800
@@ -888,11 +888,12 @@ unsigned long zap_page_range(struct vm_a
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
+	mmu_notifier(invalidate_range_start, mm, address, end,
+		(details ? (details->i_mmap_lock != NULL)  : 0));
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
-	mmu_notifier(invalidate_range, mm, address, end,
-		(details ? (details->i_mmap_lock != NULL)  : 0));
+	mmu_notifier(invalidate_range_end, mm);
 	return end;
 }
 
@@ -1355,6 +1356,7 @@ int remap_pfn_range(struct vm_area_struc
 	pfn -= addr >> PAGE_SHIFT;
 	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
+	mmu_notifier(invalidate_range_start, mm, start, end, 0);
 	do {
 		next = pgd_addr_end(addr, end);
 		err = remap_pud_range(mm, pgd, addr, next,
@@ -1362,7 +1364,7 @@ int remap_pfn_range(struct vm_area_struc
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
-	mmu_notifier(invalidate_range, mm, start, end, 0);
+	mmu_notifier(invalidate_range_end, mm);
 	return err;
 }
 EXPORT_SYMBOL(remap_pfn_range);
@@ -1450,6 +1452,7 @@ int apply_to_page_range(struct mm_struct
 	int err;
 
 	BUG_ON(addr >= end);
+	mmu_notifier(invalidate_range_start, mm, start, end, 0);
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1457,7 +1460,7 @@ int apply_to_page_range(struct mm_struct
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
-	mmu_notifier(invalidate_range, mm, start, end, 0);
+	mmu_notifier(invalidate_range_end, mm);
 	return err;
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
@@ -1635,6 +1638,8 @@ gotten:
 		goto oom;
 	cow_user_page(new_page, old_page, address, vma);
 
+	mmu_notifier(invalidate_range_start, mm, address,
+				address + PAGE_SIZE - 1, 0);
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
@@ -1673,8 +1678,7 @@ gotten:
 		page_cache_release(old_page);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
-	mmu_notifier(invalidate_range, mm, address,
-				address + PAGE_SIZE - 1, 0);
+	mmu_notifier(invalidate_range_end, mm);
 	if (dirty_page) {
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
