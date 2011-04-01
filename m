Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DB9EC8D004E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 09:39:08 -0400 (EDT)
Message-Id: <20110401121725.991633993@chello.nl>
Date: Fri, 01 Apr 2011 14:13:12 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 14/20] mm: Remove i_mmap_lock lockbreak
References: <20110401121258.211963744@chello.nl>
Content-Disposition: inline; filename=mm-fix-zap_block_size.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

Hugh says:
 "The only significant loser, I think, would be page reclaim (when
  concurrent with truncation): could spin for a long time waiting for
  the i_mmap_mutex it expects would soon be dropped? "

Counter points:
 - cpu contention makes the spin stop (need_resched())
 - zap pages should be freeing pages at a higher rate than reclaim
   ever can

I think the simplification of the truncate code is definately worth it.

Effectively reverts: 2aa15890f3c (mm: prevent concurrent
unmap_mapping_range() on the same inode) and takes out the code that
caused its problem.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
LKML-Reference: <new-submission>
---
 fs/inode.c               |    1 
 include/linux/fs.h       |    2 
 include/linux/mm.h       |    2 
 include/linux/mm_types.h |    1 
 kernel/fork.c            |    1 
 mm/memory.c              |  195 ++++++-----------------------------------------
 mm/mmap.c                |   13 ---
 mm/mremap.c              |    1 
 8 files changed, 28 insertions(+), 188 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -878,8 +878,6 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
-	spinlock_t *i_mmap_lock;		/* For unmap_mapping_range: */
-	unsigned long truncate_count;		/* Compare vm_truncate_count */
 };
 
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -986,13 +986,13 @@ int copy_page_range(struct mm_struct *ds
 static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				struct zap_details *details)
 {
 	struct mm_struct *mm = tlb->mm;
 	int force_flush = 0;
-	pte_t *pte;
-	spinlock_t *ptl;
 	int rss[NR_MM_COUNTERS];
+	spinlock_t *ptl;
+	pte_t *pte;
 
 	init_rss_vec(rss);
 again:
@@ -1001,12 +1001,9 @@ static unsigned long zap_pte_range(struc
 	do {
 		pte_t ptent = *pte;
 		if (pte_none(ptent)) {
-			(*zap_work)--;
 			continue;
 		}
 
-		(*zap_work) -= PAGE_SIZE;
-
 		if (pte_present(ptent)) {
 			struct page *page;
 
@@ -1075,7 +1072,7 @@ static unsigned long zap_pte_range(struc
 				print_bad_pte(vma, addr, ptent, NULL);
 		}
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
-	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
+	} while (pte++, addr += PAGE_SIZE, addr != end);
 
 	add_mm_rss_vec(mm, rss);
 	arch_leave_lazy_mmu_mode();
@@ -1099,7 +1096,7 @@ static unsigned long zap_pte_range(struc
 static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pud_t *pud,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				struct zap_details *details)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -1111,19 +1108,15 @@ static inline unsigned long zap_pmd_rang
 			if (next-addr != HPAGE_PMD_SIZE) {
 				VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
 				split_huge_page_pmd(vma->vm_mm, pmd);
-			} else if (zap_huge_pmd(tlb, vma, pmd)) {
-				(*zap_work)--;
+			} else if (zap_huge_pmd(tlb, vma, pmd))
 				continue;
-			}
 			/* fall through */
 		}
-		if (pmd_none_or_clear_bad(pmd)) {
-			(*zap_work)--;
+		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		}
-		next = zap_pte_range(tlb, vma, pmd, addr, next,
-						zap_work, details);
-	} while (pmd++, addr = next, (addr != end && *zap_work > 0));
+		next = zap_pte_range(tlb, vma, pmd, addr, next, details);
+		cond_resched();
+	} while (pmd++, addr = next, addr != end);
 
 	return addr;
 }
@@ -1131,7 +1124,7 @@ static inline unsigned long zap_pmd_rang
 static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pgd_t *pgd,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				struct zap_details *details)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -1139,13 +1132,10 @@ static inline unsigned long zap_pud_rang
 	pud = pud_offset(pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud)) {
-			(*zap_work)--;
+		if (pud_none_or_clear_bad(pud))
 			continue;
-		}
-		next = zap_pmd_range(tlb, vma, pud, addr, next,
-						zap_work, details);
-	} while (pud++, addr = next, (addr != end && *zap_work > 0));
+		next = zap_pmd_range(tlb, vma, pud, addr, next, details);
+	} while (pud++, addr = next, addr != end);
 
 	return addr;
 }
@@ -1153,7 +1143,7 @@ static inline unsigned long zap_pud_rang
 static unsigned long unmap_page_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				struct zap_details *details)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -1167,13 +1157,10 @@ static unsigned long unmap_page_range(st
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd)) {
-			(*zap_work)--;
+		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		}
-		next = zap_pud_range(tlb, vma, pgd, addr, next,
-						zap_work, details);
-	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
+		next = zap_pud_range(tlb, vma, pgd, addr, next, details);
+	} while (pgd++, addr = next, addr != end);
 	tlb_end_vma(tlb, vma);
 	mem_cgroup_uncharge_end();
 
@@ -1218,9 +1205,7 @@ unsigned long unmap_vmas(struct mmu_gath
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *details)
 {
-	long zap_work = ZAP_BLOCK_SIZE;
 	unsigned long start = start_addr;
-	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	struct mm_struct *mm = vma->vm_mm;
 
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
@@ -1253,33 +1238,15 @@ unsigned long unmap_vmas(struct mmu_gath
 				 * Since no pte has actually been setup, it is
 				 * safe to do nothing in this case.
 				 */
-				if (vma->vm_file) {
+				if (vma->vm_file)
 					unmap_hugepage_range(vma, start, end, NULL);
-					zap_work -= (end - start) /
-					pages_per_huge_page(hstate_vma(vma));
-				}
 
 				start = end;
 			} else
-				start = unmap_page_range(tlb, vma,
-						start, end, &zap_work, details);
-
-			if (zap_work > 0) {
-				BUG_ON(start != end);
-				break;
-			}
-
-			if (need_resched() ||
-				(i_mmap_lock && spin_needbreak(i_mmap_lock))) {
-				if (i_mmap_lock)
-					goto out;
-				cond_resched();
-			}
-
-			zap_work = ZAP_BLOCK_SIZE;
+				start = unmap_page_range(tlb, vma, start, end, details);
 		}
 	}
-out:
+
 	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
 	return start;	/* which is now the end (or restart) address */
 }
@@ -2541,96 +2508,11 @@ static int do_wp_page(struct mm_struct *
 	return ret;
 }
 
-/*
- * Helper functions for unmap_mapping_range().
- *
- * __ Notes on dropping i_mmap_lock to reduce latency while unmapping __
- *
- * We have to restart searching the prio_tree whenever we drop the lock,
- * since the iterator is only valid while the lock is held, and anyway
- * a later vma might be split and reinserted earlier while lock dropped.
- *
- * The list of nonlinear vmas could be handled more efficiently, using
- * a placeholder, but handle it in the same way until a need is shown.
- * It is important to search the prio_tree before nonlinear list: a vma
- * may become nonlinear and be shifted from prio_tree to nonlinear list
- * while the lock is dropped; but never shifted from list to prio_tree.
- *
- * In order to make forward progress despite restarting the search,
- * vm_truncate_count is used to mark a vma as now dealt with, so we can
- * quickly skip it next time around.  Since the prio_tree search only
- * shows us those vmas affected by unmapping the range in question, we
- * can't efficiently keep all vmas in step with mapping->truncate_count:
- * so instead reset them all whenever it wraps back to 0 (then go to 1).
- * mapping->truncate_count and vma->vm_truncate_count are protected by
- * i_mmap_lock.
- *
- * In order to make forward progress despite repeatedly restarting some
- * large vma, note the restart_addr from unmap_vmas when it breaks out:
- * and restart from that address when we reach that vma again.  It might
- * have been split or merged, shrunk or extended, but never shifted: so
- * restart_addr remains valid so long as it remains in the vma's range.
- * unmap_mapping_range forces truncate_count to leap over page-aligned
- * values so we can save vma's restart_addr in its truncate_count field.
- */
-#define is_restart_addr(truncate_count) (!((truncate_count) & ~PAGE_MASK))
-
-static void reset_vma_truncate_counts(struct address_space *mapping)
-{
-	struct vm_area_struct *vma;
-	struct prio_tree_iter iter;
-
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, ULONG_MAX)
-		vma->vm_truncate_count = 0;
-	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
-		vma->vm_truncate_count = 0;
-}
-
-static int unmap_mapping_range_vma(struct vm_area_struct *vma,
+static void unmap_mapping_range_vma(struct vm_area_struct *vma,
 		unsigned long start_addr, unsigned long end_addr,
 		struct zap_details *details)
 {
-	unsigned long restart_addr;
-	int need_break;
-
-	/*
-	 * files that support invalidating or truncating portions of the
-	 * file from under mmaped areas must have their ->fault function
-	 * return a locked page (and set VM_FAULT_LOCKED in the return).
-	 * This provides synchronisation against concurrent unmapping here.
-	 */
-
-again:
-	restart_addr = vma->vm_truncate_count;
-	if (is_restart_addr(restart_addr) && start_addr < restart_addr) {
-		start_addr = restart_addr;
-		if (start_addr >= end_addr) {
-			/* Top of vma has been split off since last time */
-			vma->vm_truncate_count = details->truncate_count;
-			return 0;
-		}
-	}
-
-	restart_addr = zap_page_range(vma, start_addr,
-					end_addr - start_addr, details);
-	need_break = need_resched() || spin_needbreak(details->i_mmap_lock);
-
-	if (restart_addr >= end_addr) {
-		/* We have now completed this vma: mark it so */
-		vma->vm_truncate_count = details->truncate_count;
-		if (!need_break)
-			return 0;
-	} else {
-		/* Note restart_addr in vma's truncate_count field */
-		vma->vm_truncate_count = restart_addr;
-		if (!need_break)
-			goto again;
-	}
-
-	spin_unlock(details->i_mmap_lock);
-	cond_resched();
-	spin_lock(details->i_mmap_lock);
-	return -EINTR;
+	zap_page_range(vma, start_addr, end_addr - start_addr, details);
 }
 
 static inline void unmap_mapping_range_tree(struct prio_tree_root *root,
@@ -2640,12 +2522,8 @@ static inline void unmap_mapping_range_t
 	struct prio_tree_iter iter;
 	pgoff_t vba, vea, zba, zea;
 
-restart:
 	vma_prio_tree_foreach(vma, &iter, root,
 			details->first_index, details->last_index) {
-		/* Skip quickly over those we have already dealt with */
-		if (vma->vm_truncate_count == details->truncate_count)
-			continue;
 
 		vba = vma->vm_pgoff;
 		vea = vba + ((vma->vm_end - vma->vm_start) >> PAGE_SHIFT) - 1;
@@ -2657,11 +2535,10 @@ static inline void unmap_mapping_range_t
 		if (zea > vea)
 			zea = vea;
 
-		if (unmap_mapping_range_vma(vma,
+		unmap_mapping_range_vma(vma,
 			((zba - vba) << PAGE_SHIFT) + vma->vm_start,
 			((zea - vba + 1) << PAGE_SHIFT) + vma->vm_start,
-				details) < 0)
-			goto restart;
+				details);
 	}
 }
 
@@ -2676,15 +2553,9 @@ static inline void unmap_mapping_range_l
 	 * across *all* the pages in each nonlinear VMA, not just the pages
 	 * whose virtual address lies outside the file truncation point.
 	 */
-restart:
 	list_for_each_entry(vma, head, shared.vm_set.list) {
-		/* Skip quickly over those we have already dealt with */
-		if (vma->vm_truncate_count == details->truncate_count)
-			continue;
 		details->nonlinear_vma = vma;
-		if (unmap_mapping_range_vma(vma, vma->vm_start,
-					vma->vm_end, details) < 0)
-			goto restart;
+		unmap_mapping_range_vma(vma, vma->vm_start, vma->vm_end, details);
 	}
 }
 
@@ -2723,26 +2594,14 @@ void unmap_mapping_range(struct address_
 	details.last_index = hba + hlen - 1;
 	if (details.last_index < details.first_index)
 		details.last_index = ULONG_MAX;
-	details.i_mmap_lock = &mapping->i_mmap_lock;
-
-	mutex_lock(&mapping->unmap_mutex);
-	spin_lock(&mapping->i_mmap_lock);
 
-	/* Protect against endless unmapping loops */
-	mapping->truncate_count++;
-	if (unlikely(is_restart_addr(mapping->truncate_count))) {
-		if (mapping->truncate_count == 0)
-			reset_vma_truncate_counts(mapping);
-		mapping->truncate_count++;
-	}
-	details.truncate_count = mapping->truncate_count;
 
+	spin_lock(&mapping->i_mmap_lock);
 	if (unlikely(!prio_tree_empty(&mapping->i_mmap)))
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
 	spin_unlock(&mapping->i_mmap_lock);
-	mutex_unlock(&mapping->unmap_mutex);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -643,7 +643,6 @@ struct address_space {
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
-	unsigned int		truncate_count;	/* Cover race condition with truncate */
 	unsigned long		nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
@@ -652,7 +651,6 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
-	struct mutex		unmap_mutex;    /* to protect unmapping */
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h
+++ linux-2.6/include/linux/mm_types.h
@@ -175,7 +175,6 @@ struct vm_area_struct {
 					   units, *not* PAGE_CACHE_SIZE */
 	struct file * vm_file;		/* File we map to (can be NULL). */
 	void * vm_private_data;		/* was vm_pte (shared mem) */
-	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
 
 #ifndef CONFIG_MMU
 	struct vm_region *vm_region;	/* NOMMU mapping region */
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -379,7 +379,6 @@ static int dup_mmap(struct mm_struct *mm
 			spin_lock(&mapping->i_mmap_lock);
 			if (tmp->vm_flags & VM_SHARED)
 				mapping->i_mmap_writable++;
-			tmp->vm_truncate_count = mpnt->vm_truncate_count;
 			flush_dcache_mmap_lock(mapping);
 			/* insert tmp into the share list, just after mpnt */
 			vma_prio_tree_add(tmp, mpnt);
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -464,10 +464,8 @@ static void vma_link(struct mm_struct *m
 	if (vma->vm_file)
 		mapping = vma->vm_file->f_mapping;
 
-	if (mapping) {
+	if (mapping)
 		spin_lock(&mapping->i_mmap_lock);
-		vma->vm_truncate_count = mapping->truncate_count;
-	}
 
 	__vma_link(mm, vma, prev, rb_link, rb_parent);
 	__vma_link_file(vma);
@@ -577,16 +575,7 @@ again:			remove_next = 1 + (end > next->
 		if (!(vma->vm_flags & VM_NONLINEAR))
 			root = &mapping->i_mmap;
 		spin_lock(&mapping->i_mmap_lock);
-		if (importer &&
-		    vma->vm_truncate_count != next->vm_truncate_count) {
-			/*
-			 * unmap_mapping_range might be in progress:
-			 * ensure that the expanding vma is rescanned.
-			 */
-			importer->vm_truncate_count = 0;
-		}
 		if (insert) {
-			insert->vm_truncate_count = vma->vm_truncate_count;
 			/*
 			 * Put into prio_tree now, so instantiated pages
 			 * are visible to arm/parisc __flush_dcache_page
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c
+++ linux-2.6/mm/mremap.c
@@ -94,7 +94,6 @@ static void move_ptes(struct vm_area_str
 		 */
 		mapping = vma->vm_file->f_mapping;
 		spin_lock(&mapping->i_mmap_lock);
-		new_vma->vm_truncate_count = 0;
 	}
 
 	/*
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c
+++ linux-2.6/fs/inode.c
@@ -305,7 +305,6 @@ void address_space_init_once(struct addr
 	spin_lock_init(&mapping->private_lock);
 	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
 	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
-	mutex_init(&mapping->unmap_mutex);
 }
 EXPORT_SYMBOL(address_space_init_once);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
