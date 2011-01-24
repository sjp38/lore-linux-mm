Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BE4A06B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 07:44:55 -0500 (EST)
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LSU.2.00.1101201052060.1603@sister.anvils>
References: <20101126143843.801484792@chello.nl>
	 <alpine.LSU.2.00.1101172301340.2899@sister.anvils>
	 <1295457039.28776.137.camel@laptop>
	 <alpine.LSU.2.00.1101201052060.1603@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 24 Jan 2011 13:45:31 +0100
Message-ID: <1295873131.28776.431.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2011-01-20 at 11:57 -0800, Hugh Dickins wrote:
> > Since its now preemptable we might consider simply removing that. I
> > simply wanted to keep the changes to a minimum for now.
>=20
> Removing that along with the restart_addr stuff, yes.  I keep wavering.
> Yes it would be nice to get rid of all that, particularly now we find
> it's had holes in all these years.  The only significant loser, I think,
> would be page reclaim (when concurrent with truncation): could spin for a
> long time waiting for the i_mmap_mutex it expects would soon be dropped?=
=20

Right, so unmap vs reclaim is only nasty because we'd hold up reclaim,
avoiding it from doing useful work. Then again, avoiding it from
reclaiming stuff we're throwing away anyway is good, but holding it up
from doing other work less so.

/me applies axe to see what he gets.

XXX: still needs !generic-tlb arch updates, and probably should cure the
tlb_flush_mmu(.start=3D0, .end=3D0) thing.

Temping diffstat, but like you said, not quite sure if its fair wrt
reclaim..

---
 include/asm-generic/tlb.h |   18 ++--
 include/linux/fs.h        |    1=20
 include/linux/mm.h        |    2=20
 include/linux/mm_types.h  |    1=20
 kernel/fork.c             |    1=20
 mm/memory.c               |  203 ++++++++---------------------------------=
-----
 mm/mmap.c                 |   13 --
 mm/mremap.c               |    3=20
 8 files changed, 50 insertions(+), 192 deletions(-)

Index: linux-2.6/include/asm-generic/tlb.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/asm-generic/tlb.h
+++ linux-2.6/include/asm-generic/tlb.h
@@ -193,7 +193,7 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
  *	handling the additional races in SMP caused by other CPUs caching valid
  *	mappings in their TLBs.
  */
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *pa=
ge)
+static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *p=
age)
 {
 	struct mmu_gather_batch *batch;
=20
@@ -201,17 +201,25 @@ static inline void tlb_remove_page(struc
=20
 	if (tlb_fast_mode(tlb)) {
 		free_page_and_swap_cache(page);
-		return;
+		return 0;
 	}
=20
 	batch =3D tlb->active;
+	batch->pages[batch->nr++] =3D page;
 	if (batch->nr =3D=3D batch->max) {
 		if (!tlb_next_batch(tlb))
-			tlb_flush_mmu(tlb, 0, 0);
-		batch =3D tlb->active;
+			return 1;
 	}
=20
-	batch->pages[batch->nr++] =3D page;
+	return 0;
+}
+
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *pa=
ge)
+{
+	WARN_ON_ONCE(in_atomic());
+
+	if (__tlb_remove_page(tlb, page))
+		tlb_flush_mmu(tlb, 0, 0);
 }
=20
 /**
Index: linux-2.6/include/linux/mm.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -876,8 +876,6 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
-	struct mutex *i_mmap_mutex;		/* For unmap_mapping_range: */
-	unsigned long truncate_count;		/* Compare vm_truncate_count */
 };
=20
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr=
,
Index: linux-2.6/mm/memory.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -986,26 +986,24 @@ int copy_page_range(struct mm_struct *ds
 static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				struct zap_details *details)
 {
 	struct mm_struct *mm =3D tlb->mm;
-	pte_t *pte;
-	spinlock_t *ptl;
 	int rss[NR_MM_COUNTERS];
+	int need_flush =3D 0;
+	spinlock_t *ptl;
+	pte_t *pte;
=20
 	init_rss_vec(rss);
-
+again:
 	pte =3D pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
 	do {
 		pte_t ptent =3D *pte;
 		if (pte_none(ptent)) {
-			(*zap_work)--;
 			continue;
 		}
=20
-		(*zap_work) -=3D PAGE_SIZE;
-
 		if (pte_present(ptent)) {
 			struct page *page;
=20
@@ -1051,7 +1049,7 @@ static unsigned long zap_pte_range(struc
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
-			tlb_remove_page(tlb, page);
+			need_flush =3D __tlb_remove_page(tlb, page);
 			continue;
 		}
 		/*
@@ -1072,19 +1070,26 @@ static unsigned long zap_pte_range(struc
 				print_bad_pte(vma, addr, ptent, NULL);
 		}
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
-	} while (pte++, addr +=3D PAGE_SIZE, (addr !=3D end && *zap_work > 0));
+	} while (pte++, addr +=3D PAGE_SIZE, (addr !=3D end && !need_flush));
=20
 	add_mm_rss_vec(mm, rss);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
=20
+	if (need_flush) {
+		need_flush =3D 0;
+		tlb_flush_mmu(tlb, 0, 0);
+		if (addr !=3D end)
+			goto again;
+	}
+
 	return addr;
 }
=20
 static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pud_t *pud,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				struct zap_details *details)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -1096,19 +1101,15 @@ static inline unsigned long zap_pmd_rang
 			if (next-addr !=3D HPAGE_PMD_SIZE) {
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
-		next =3D zap_pte_range(tlb, vma, pmd, addr, next,
-						zap_work, details);
-	} while (pmd++, addr =3D next, (addr !=3D end && *zap_work > 0));
+		next =3D zap_pte_range(tlb, vma, pmd, addr, next, details);
+		cond_resched();
+	} while (pmd++, addr =3D next, addr !=3D end);
=20
 	return addr;
 }
@@ -1116,7 +1117,7 @@ static inline unsigned long zap_pmd_rang
 static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pgd_t *pgd,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				struct zap_details *details)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -1124,13 +1125,10 @@ static inline unsigned long zap_pud_rang
 	pud =3D pud_offset(pgd, addr);
 	do {
 		next =3D pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud)) {
-			(*zap_work)--;
+		if (pud_none_or_clear_bad(pud))
 			continue;
-		}
-		next =3D zap_pmd_range(tlb, vma, pud, addr, next,
-						zap_work, details);
-	} while (pud++, addr =3D next, (addr !=3D end && *zap_work > 0));
+		next =3D zap_pmd_range(tlb, vma, pud, addr, next, details);
+	} while (pud++, addr =3D next, addr !=3D end);
=20
 	return addr;
 }
@@ -1138,7 +1136,7 @@ static inline unsigned long zap_pud_rang
 static unsigned long unmap_page_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				struct zap_details *details)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -1152,13 +1150,10 @@ static unsigned long unmap_page_range(st
 	pgd =3D pgd_offset(vma->vm_mm, addr);
 	do {
 		next =3D pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd)) {
-			(*zap_work)--;
+		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		}
-		next =3D zap_pud_range(tlb, vma, pgd, addr, next,
-						zap_work, details);
-	} while (pgd++, addr =3D next, (addr !=3D end && *zap_work > 0));
+		next =3D zap_pud_range(tlb, vma, pgd, addr, next, details);
+	} while (pgd++, addr =3D next, addr !=3D end);
 	tlb_end_vma(tlb, vma);
 	mem_cgroup_uncharge_end();
=20
@@ -1203,9 +1198,7 @@ unsigned long unmap_vmas(struct mmu_gath
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *details)
 {
-	long zap_work =3D ZAP_BLOCK_SIZE;
 	unsigned long start =3D start_addr;
-	struct mutex *i_mmap_mutex =3D details ? details->i_mmap_mutex : NULL;
 	struct mm_struct *mm =3D vma->vm_mm;
=20
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
@@ -1238,33 +1231,16 @@ unsigned long unmap_vmas(struct mmu_gath
 				 * Since no pte has actually been setup, it is
 				 * safe to do nothing in this case.
 				 */
-				if (vma->vm_file) {
+				if (vma->vm_file)
 					unmap_hugepage_range(vma, start, end, NULL);
-					zap_work -=3D (end - start) /
-					pages_per_huge_page(hstate_vma(vma));
-				}
=20
 				start =3D end;
 			} else
 				start =3D unmap_page_range(tlb, vma,
-						start, end, &zap_work, details);
-
-			if (zap_work > 0) {
-				BUG_ON(start !=3D end);
-				break;
-			}
-
-			if (need_resched() ||
-				(i_mmap_mutex && mutex_is_contended(i_mmap_mutex))) {
-				if (i_mmap_mutex)
-					goto out;
-				cond_resched();
-			}
-
-			zap_work =3D ZAP_BLOCK_SIZE;
+						start, end, details);
 		}
 	}
-out:
+
 	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
 	return start;	/* which is now the end (or restart) address */
 }
@@ -2528,96 +2504,11 @@ static int do_wp_page(struct mm_struct *
 	return ret;
 }
=20
-/*
- * Helper functions for unmap_mapping_range().
- *
- * __ Notes on dropping i_mmap_mutex to reduce latency while unmapping __
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
- * i_mmap_mutex.
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
-		vma->vm_truncate_count =3D 0;
-	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
-		vma->vm_truncate_count =3D 0;
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
-	restart_addr =3D vma->vm_truncate_count;
-	if (is_restart_addr(restart_addr) && start_addr < restart_addr) {
-		start_addr =3D restart_addr;
-		if (start_addr >=3D end_addr) {
-			/* Top of vma has been split off since last time */
-			vma->vm_truncate_count =3D details->truncate_count;
-			return 0;
-		}
-	}
-
-	restart_addr =3D zap_page_range(vma, start_addr,
-					end_addr - start_addr, details);
-	need_break =3D need_resched() || mutex_is_contended(details->i_mmap_mutex=
);
-
-	if (restart_addr >=3D end_addr) {
-		/* We have now completed this vma: mark it so */
-		vma->vm_truncate_count =3D details->truncate_count;
-		if (!need_break)
-			return 0;
-	} else {
-		/* Note restart_addr in vma's truncate_count field */
-		vma->vm_truncate_count =3D restart_addr;
-		if (!need_break)
-			goto again;
-	}
-
-	mutex_unlock(details->i_mmap_mutex);
-	cond_resched();
-	mutex_lock(details->i_mmap_mutex);
-	return -EINTR;
+	zap_page_range(vma, start_addr, end_addr - start_addr, details);
 }
=20
 static inline void unmap_mapping_range_tree(struct prio_tree_root *root,
@@ -2627,12 +2518,8 @@ static inline void unmap_mapping_range_t
 	struct prio_tree_iter iter;
 	pgoff_t vba, vea, zba, zea;
=20
-restart:
 	vma_prio_tree_foreach(vma, &iter, root,
 			details->first_index, details->last_index) {
-		/* Skip quickly over those we have already dealt with */
-		if (vma->vm_truncate_count =3D=3D details->truncate_count)
-			continue;
=20
 		vba =3D vma->vm_pgoff;
 		vea =3D vba + ((vma->vm_end - vma->vm_start) >> PAGE_SHIFT) - 1;
@@ -2644,11 +2531,10 @@ static inline void unmap_mapping_range_t
 		if (zea > vea)
 			zea =3D vea;
=20
-		if (unmap_mapping_range_vma(vma,
+		unmap_mapping_range_vma(vma,
 			((zba - vba) << PAGE_SHIFT) + vma->vm_start,
 			((zea - vba + 1) << PAGE_SHIFT) + vma->vm_start,
-				details) < 0)
-			goto restart;
+				details);
 	}
 }
=20
@@ -2663,15 +2549,9 @@ static inline void unmap_mapping_range_l
 	 * across *all* the pages in each nonlinear VMA, not just the pages
 	 * whose virtual address lies outside the file truncation point.
 	 */
-restart:
 	list_for_each_entry(vma, head, shared.vm_set.list) {
-		/* Skip quickly over those we have already dealt with */
-		if (vma->vm_truncate_count =3D=3D details->truncate_count)
-			continue;
 		details->nonlinear_vma =3D vma;
-		if (unmap_mapping_range_vma(vma, vma->vm_start,
-					vma->vm_end, details) < 0)
-			goto restart;
+		unmap_mapping_range_vma(vma, vma->vm_start, vma->vm_end, details);
 	}
 }
=20
@@ -2710,19 +2590,8 @@ void unmap_mapping_range(struct address_
 	details.last_index =3D hba + hlen - 1;
 	if (details.last_index < details.first_index)
 		details.last_index =3D ULONG_MAX;
-	details.i_mmap_mutex =3D &mapping->i_mmap_mutex;
=20
 	mutex_lock(&mapping->i_mmap_mutex);
-
-	/* Protect against endless unmapping loops */
-	mapping->truncate_count++;
-	if (unlikely(is_restart_addr(mapping->truncate_count))) {
-		if (mapping->truncate_count =3D=3D 0)
-			reset_vma_truncate_counts(mapping);
-		mapping->truncate_count++;
-	}
-	details.truncate_count =3D mapping->truncate_count;
-
 	if (unlikely(!prio_tree_empty(&mapping->i_mmap)))
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
Index: linux-2.6/include/linux/fs.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -640,7 +640,6 @@ struct address_space {
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
-	unsigned int		truncate_count;	/* Cover race condition with truncate */
 	unsigned long		nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
Index: linux-2.6/include/linux/mm_types.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/linux/mm_types.h
+++ linux-2.6/include/linux/mm_types.h
@@ -175,7 +175,6 @@ struct vm_area_struct {
 					   units, *not* PAGE_CACHE_SIZE */
 	struct file * vm_file;		/* File we map to (can be NULL). */
 	void * vm_private_data;		/* was vm_pte (shared mem) */
-	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
=20
 #ifndef CONFIG_MMU
 	struct vm_region *vm_region;	/* NOMMU mapping region */
Index: linux-2.6/kernel/fork.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -379,7 +379,6 @@ static int dup_mmap(struct mm_struct *mm
 			mutex_lock(&mapping->i_mmap_mutex);
 			if (tmp->vm_flags & VM_SHARED)
 				mapping->i_mmap_writable++;
-			tmp->vm_truncate_count =3D mpnt->vm_truncate_count;
 			flush_dcache_mmap_lock(mapping);
 			/* insert tmp into the share list, just after mpnt */
 			vma_prio_tree_add(tmp, mpnt);
Index: linux-2.6/mm/mmap.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -464,10 +464,8 @@ static void vma_link(struct mm_struct *m
 	if (vma->vm_file)
 		mapping =3D vma->vm_file->f_mapping;
=20
-	if (mapping) {
+	if (mapping)
 		mutex_lock(&mapping->i_mmap_mutex);
-		vma->vm_truncate_count =3D mapping->truncate_count;
-	}
=20
 	__vma_link(mm, vma, prev, rb_link, rb_parent);
 	__vma_link_file(vma);
@@ -577,16 +575,7 @@ again:			remove_next =3D 1 + (end > next->
 		if (!(vma->vm_flags & VM_NONLINEAR))
 			root =3D &mapping->i_mmap;
 		mutex_lock(&mapping->i_mmap_mutex);
-		if (importer &&
-		    vma->vm_truncate_count !=3D next->vm_truncate_count) {
-			/*
-			 * unmap_mapping_range might be in progress:
-			 * ensure that the expanding vma is rescanned.
-			 */
-			importer->vm_truncate_count =3D 0;
-		}
 		if (insert) {
-			insert->vm_truncate_count =3D vma->vm_truncate_count;
 			/*
 			 * Put into prio_tree now, so instantiated pages
 			 * are visible to arm/parisc __flush_dcache_page
Index: linux-2.6/mm/mremap.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/mremap.c
+++ linux-2.6/mm/mremap.c
@@ -94,9 +94,6 @@ static void move_ptes(struct vm_area_str
 		 */
 		mapping =3D vma->vm_file->f_mapping;
 		mutex_lock(&mapping->i_mmap_mutex);
-		if (new_vma->vm_truncate_count &&
-		    new_vma->vm_truncate_count !=3D vma->vm_truncate_count)
-			new_vma->vm_truncate_count =3D 0;
 	}
=20
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
