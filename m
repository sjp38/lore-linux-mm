Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9ABBE6B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 16:59:43 -0400 (EDT)
Received: by pdea3 with SMTP id a3so165310931pde.3
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 13:59:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id nt9si8782502pbb.92.2015.04.09.13.59.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 13:59:42 -0700 (PDT)
Date: Thu, 9 Apr 2015 13:59:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: make every pte dirty on do_swap_page
Message-Id: <20150409135939.bbc9025d925de9d0fdd12797@linux-foundation.org>
In-Reply-To: <20150408235012.GA13690@blaptop>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
	<1426036838-18154-4-git-send-email-minchan@kernel.org>
	<20150408235012.GA13690@blaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>

On Thu, 9 Apr 2015 08:50:25 +0900 Minchan Kim <minchan@kernel.org> wrote:

> Bump.

I'm getting the feeling that MADV_FREE is out of control.

Below is the overall rollup of

mm-support-madvisemadv_free.patch
mm-support-madvisemadv_free-fix.patch
mm-support-madvisemadv_free-fix-2.patch
mm-dont-split-thp-page-when-syscall-is-called.patch
mm-dont-split-thp-page-when-syscall-is-called-fix.patch
mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
mm-free-swp_entry-in-madvise_free.patch
mm-move-lazy-free-pages-to-inactive-list.patch
mm-move-lazy-free-pages-to-inactive-list-fix.patch
mm-move-lazy-free-pages-to-inactive-list-fix-fix.patch
mm-move-lazy-free-pages-to-inactive-list-fix-fix-fix.patch
mm-make-every-pte-dirty-on-do_swap_page.patch


It's pretty large and has its sticky little paws in all sorts of places.


The feature would need to be pretty darn useful to justify a mainline
merge.  Has any such usefulness been demonstrated?




 arch/alpha/include/uapi/asm/mman.h     |    1 
 arch/mips/include/uapi/asm/mman.h      |    1 
 arch/parisc/include/uapi/asm/mman.h    |    1 
 arch/xtensa/include/uapi/asm/mman.h    |    1 
 include/linux/huge_mm.h                |    4 
 include/linux/rmap.h                   |    9 -
 include/linux/swap.h                   |    1 
 include/linux/vm_event_item.h          |    1 
 include/uapi/asm-generic/mman-common.h |    1 
 mm/huge_memory.c                       |   35 ++++
 mm/madvise.c                           |  175 +++++++++++++++++++++++
 mm/memory.c                            |   10 +
 mm/rmap.c                              |   46 +++++-
 mm/swap.c                              |   44 +++++
 mm/vmscan.c                            |   63 ++++++--
 mm/vmstat.c                            |    1 
 16 files changed, 372 insertions(+), 22 deletions(-)

diff -puN include/linux/rmap.h~mm-support-madvisemadv_free include/linux/rmap.h
--- a/include/linux/rmap.h~mm-support-madvisemadv_free
+++ a/include/linux/rmap.h
@@ -85,6 +85,7 @@ enum ttu_flags {
 	TTU_UNMAP = 1,			/* unmap mode */
 	TTU_MIGRATION = 2,		/* migration mode */
 	TTU_MUNLOCK = 4,		/* munlock mode */
+	TTU_FREE = 8,			/* free mode */
 
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
 	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
@@ -183,7 +184,8 @@ static inline void page_dup_rmap(struct
  * Called from mm/vmscan.c to handle paging out
  */
 int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+			struct mem_cgroup *memcg, unsigned long *vm_flags,
+			int *is_pte_dirty);
 
 #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
 
@@ -260,9 +262,12 @@ int rmap_walk(struct page *page, struct
 
 static inline int page_referenced(struct page *page, int is_locked,
 				  struct mem_cgroup *memcg,
-				  unsigned long *vm_flags)
+				  unsigned long *vm_flags,
+				  int *is_pte_dirty)
 {
 	*vm_flags = 0;
+	if (is_pte_dirty)
+		*is_pte_dirty = 0;
 	return 0;
 }
 
diff -puN include/linux/vm_event_item.h~mm-support-madvisemadv_free include/linux/vm_event_item.h
--- a/include/linux/vm_event_item.h~mm-support-madvisemadv_free
+++ a/include/linux/vm_event_item.h
@@ -25,6 +25,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		FOR_ALL_ZONES(PGALLOC),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
+		PGLAZYFREED,
 		FOR_ALL_ZONES(PGREFILL),
 		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
 		FOR_ALL_ZONES(PGSTEAL_DIRECT),
diff -puN include/uapi/asm-generic/mman-common.h~mm-support-madvisemadv_free include/uapi/asm-generic/mman-common.h
--- a/include/uapi/asm-generic/mman-common.h~mm-support-madvisemadv_free
+++ a/include/uapi/asm-generic/mman-common.h
@@ -34,6 +34,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* free pages only if memory pressure */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
diff -puN mm/madvise.c~mm-support-madvisemadv_free mm/madvise.c
--- a/mm/madvise.c~mm-support-madvisemadv_free
+++ a/mm/madvise.c
@@ -19,6 +19,14 @@
 #include <linux/blkdev.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/mmu_notifier.h>
+
+#include <asm/tlb.h>
+
+struct madvise_free_private {
+	struct vm_area_struct *vma;
+	struct mmu_gather *tlb;
+};
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -31,6 +39,7 @@ static int madvise_need_mmap_write(int b
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_FREE:
 		return 0;
 	default:
 		/* be safe, default to 1. list exceptions explicitly */
@@ -254,6 +263,163 @@ static long madvise_willneed(struct vm_a
 	return 0;
 }
 
+static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
+
+{
+	struct madvise_free_private *fp = walk->private;
+	struct mmu_gather *tlb = fp->tlb;
+	struct mm_struct *mm = tlb->mm;
+	struct vm_area_struct *vma = fp->vma;
+	spinlock_t *ptl;
+	pte_t *pte, ptent;
+	struct page *page;
+	swp_entry_t entry;
+	unsigned long next;
+	int nr_swap = 0;
+
+	next = pmd_addr_end(addr, end);
+	if (pmd_trans_huge(*pmd)) {
+		if (next - addr != HPAGE_PMD_SIZE)
+			split_huge_page_pmd(vma, addr, pmd);
+		else if (!madvise_free_huge_pmd(tlb, vma, pmd, addr))
+			goto next;
+		/* fall through */
+	}
+
+	if (pmd_trans_unstable(pmd))
+		return 0;
+
+	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	arch_enter_lazy_mmu_mode();
+	for (; addr != end; pte++, addr += PAGE_SIZE) {
+		ptent = *pte;
+
+		if (pte_none(ptent))
+			continue;
+		/*
+		 * If the pte has swp_entry, just clear page table to
+		 * prevent swap-in which is more expensive rather than
+		 * (page allocation + zeroing).
+		 */
+		if (!pte_present(ptent)) {
+			entry = pte_to_swp_entry(ptent);
+			if (non_swap_entry(entry))
+				continue;
+			nr_swap--;
+			free_swap_and_cache(entry);
+			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
+			continue;
+		}
+
+		page = vm_normal_page(vma, addr, ptent);
+		if (!page)
+			continue;
+
+		if (PageSwapCache(page)) {
+			if (!trylock_page(page))
+				continue;
+
+			if (!try_to_free_swap(page)) {
+				unlock_page(page);
+				continue;
+			}
+
+			unlock_page(page);
+		}
+
+		/*
+		 * Some of architecture(ex, PPC) don't update TLB
+		 * with set_pte_at and tlb_remove_tlb_entry so for
+		 * the portability, remap the pte with old|clean
+		 * after pte clearing.
+		 */
+		ptent = ptep_get_and_clear_full(mm, addr, pte,
+						tlb->fullmm);
+		ptent = pte_mkold(ptent);
+		ptent = pte_mkclean(ptent);
+		set_pte_at(mm, addr, pte, ptent);
+		if (PageActive(page))
+			deactivate_page(page);
+		tlb_remove_tlb_entry(tlb, pte, addr);
+	}
+
+	if (nr_swap) {
+		if (current->mm == mm)
+			sync_mm_rss(mm);
+
+		add_mm_counter(mm, MM_SWAPENTS, nr_swap);
+	}
+
+	arch_leave_lazy_mmu_mode();
+	pte_unmap_unlock(pte - 1, ptl);
+next:
+	cond_resched();
+	return 0;
+}
+
+static void madvise_free_page_range(struct mmu_gather *tlb,
+			     struct vm_area_struct *vma,
+			     unsigned long addr, unsigned long end)
+{
+	struct madvise_free_private fp = {
+		.vma = vma,
+		.tlb = tlb,
+	};
+
+	struct mm_walk free_walk = {
+		.pmd_entry = madvise_free_pte_range,
+		.mm = vma->vm_mm,
+		.private = &fp,
+	};
+
+	BUG_ON(addr >= end);
+	tlb_start_vma(tlb, vma);
+	walk_page_range(addr, end, &free_walk);
+	tlb_end_vma(tlb, vma);
+}
+
+static int madvise_free_single_vma(struct vm_area_struct *vma,
+			unsigned long start_addr, unsigned long end_addr)
+{
+	unsigned long start, end;
+	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_gather tlb;
+
+	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
+		return -EINVAL;
+
+	/* MADV_FREE works for only anon vma at the moment */
+	if (vma->vm_file)
+		return -EINVAL;
+
+	start = max(vma->vm_start, start_addr);
+	if (start >= vma->vm_end)
+		return -EINVAL;
+	end = min(vma->vm_end, end_addr);
+	if (end <= vma->vm_start)
+		return -EINVAL;
+
+	lru_add_drain();
+	tlb_gather_mmu(&tlb, mm, start, end);
+	update_hiwater_rss(mm);
+
+	mmu_notifier_invalidate_range_start(mm, start, end);
+	madvise_free_page_range(&tlb, vma, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
+	tlb_finish_mmu(&tlb, start, end);
+
+	return 0;
+}
+
+static long madvise_free(struct vm_area_struct *vma,
+			     struct vm_area_struct **prev,
+			     unsigned long start, unsigned long end)
+{
+	*prev = vma;
+	return madvise_free_single_vma(vma, start, end);
+}
+
 /*
  * Application no longer needs these pages.  If the pages are dirty,
  * it's OK to just throw them away.  The app will be more careful about
@@ -377,6 +543,14 @@ madvise_vma(struct vm_area_struct *vma,
 		return madvise_remove(vma, prev, start, end);
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
+	case MADV_FREE:
+		/*
+		 * XXX: In this implementation, MADV_FREE works like
+		 * MADV_DONTNEED on swapless system or full swap.
+		 */
+		if (get_nr_swap_pages() > 0)
+			return madvise_free(vma, prev, start, end);
+		/* passthrough */
 	case MADV_DONTNEED:
 		return madvise_dontneed(vma, prev, start, end);
 	default:
@@ -396,6 +570,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_FREE:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
diff -puN mm/rmap.c~mm-support-madvisemadv_free mm/rmap.c
--- a/mm/rmap.c~mm-support-madvisemadv_free
+++ a/mm/rmap.c
@@ -712,6 +712,7 @@ int page_mapped_in_vma(struct page *page
 }
 
 struct page_referenced_arg {
+	int dirtied;
 	int mapcount;
 	int referenced;
 	unsigned long vm_flags;
@@ -726,6 +727,7 @@ static int page_referenced_one(struct pa
 	struct mm_struct *mm = vma->vm_mm;
 	spinlock_t *ptl;
 	int referenced = 0;
+	int dirty = 0;
 	struct page_referenced_arg *pra = arg;
 
 	if (unlikely(PageTransHuge(page))) {
@@ -749,6 +751,15 @@ static int page_referenced_one(struct pa
 		/* go ahead even if the pmd is pmd_trans_splitting() */
 		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
+
+		/*
+		 * Use pmd_freeable instead of raw pmd_dirty because in some
+		 * of architecture, pmd_dirty is not defined unless
+		 * CONFIG_TRANSPARENT_HUGEPAGE is enabled
+		 */
+		if (!pmd_freeable(*pmd))
+			dirty++;
+
 		spin_unlock(ptl);
 	} else {
 		pte_t *pte;
@@ -778,6 +789,10 @@ static int page_referenced_one(struct pa
 			if (likely(!(vma->vm_flags & VM_SEQ_READ)))
 				referenced++;
 		}
+
+		if (pte_dirty(*pte))
+			dirty++;
+
 		pte_unmap_unlock(pte, ptl);
 	}
 
@@ -786,6 +801,9 @@ static int page_referenced_one(struct pa
 		pra->vm_flags |= vma->vm_flags;
 	}
 
+	if (dirty)
+		pra->dirtied++;
+
 	pra->mapcount--;
 	if (!pra->mapcount)
 		return SWAP_SUCCESS; /* To break the loop */
@@ -810,6 +828,7 @@ static bool invalid_page_referenced_vma(
  * @is_locked: caller holds lock on the page
  * @memcg: target memory cgroup
  * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
+ * @is_pte_dirty: ptes which have marked dirty bit - used for lazyfree page
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
@@ -817,7 +836,8 @@ static bool invalid_page_referenced_vma(
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *memcg,
-		    unsigned long *vm_flags)
+		    unsigned long *vm_flags,
+		    int *is_pte_dirty)
 {
 	int ret;
 	int we_locked = 0;
@@ -832,6 +852,9 @@ int page_referenced(struct page *page,
 	};
 
 	*vm_flags = 0;
+	if (is_pte_dirty)
+		*is_pte_dirty = 0;
+
 	if (!page_mapped(page))
 		return 0;
 
@@ -859,6 +882,9 @@ int page_referenced(struct page *page,
 	if (we_locked)
 		unlock_page(page);
 
+	if (is_pte_dirty)
+		*is_pte_dirty = pra.dirtied;
+
 	return pra.referenced;
 }
 
@@ -1187,6 +1213,7 @@ static int try_to_unmap_one(struct page
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
 	enum ttu_flags flags = (enum ttu_flags)arg;
+	int dirty = 0;
 
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
@@ -1216,7 +1243,8 @@ static int try_to_unmap_one(struct page
 	pteval = ptep_clear_flush(vma, address, pte);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
-	if (pte_dirty(pteval))
+	dirty = pte_dirty(pteval);
+	if (dirty)
 		set_page_dirty(page);
 
 	/* Update high watermark before we lower rss */
@@ -1245,6 +1273,19 @@ static int try_to_unmap_one(struct page
 		swp_entry_t entry = { .val = page_private(page) };
 		pte_t swp_pte;
 
+		if (flags & TTU_FREE) {
+			VM_BUG_ON_PAGE(PageSwapCache(page), page);
+			if (!dirty) {
+				/* It's a freeable page by MADV_FREE */
+				dec_mm_counter(mm, MM_ANONPAGES);
+				goto discard;
+			} else {
+				set_pte_at(mm, address, pte, pteval);
+				ret = SWAP_FAIL;
+				goto out_unmap;
+			}
+		}
+
 		if (PageSwapCache(page)) {
 			/*
 			 * Store the swap location in the pte.
@@ -1285,6 +1326,7 @@ static int try_to_unmap_one(struct page
 	} else
 		dec_mm_counter(mm, MM_FILEPAGES);
 
+discard:
 	page_remove_rmap(page);
 	page_cache_release(page);
 
diff -puN mm/vmscan.c~mm-support-madvisemadv_free mm/vmscan.c
--- a/mm/vmscan.c~mm-support-madvisemadv_free
+++ a/mm/vmscan.c
@@ -754,13 +754,17 @@ enum page_references {
 };
 
 static enum page_references page_check_references(struct page *page,
-						  struct scan_control *sc)
+						  struct scan_control *sc,
+						  bool *freeable)
 {
 	int referenced_ptes, referenced_page;
 	unsigned long vm_flags;
+	int pte_dirty;
+
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
 	referenced_ptes = page_referenced(page, 1, sc->target_mem_cgroup,
-					  &vm_flags);
+					  &vm_flags, &pte_dirty);
 	referenced_page = TestClearPageReferenced(page);
 
 	/*
@@ -801,6 +805,9 @@ static enum page_references page_check_r
 		return PAGEREF_KEEP;
 	}
 
+	if (PageAnon(page) && !pte_dirty && !PageSwapCache(page))
+		*freeable = true;
+
 	/* Reclaim if clean, defer dirty pages to writeback */
 	if (referenced_page && !PageSwapBacked(page))
 		return PAGEREF_RECLAIM_CLEAN;
@@ -869,6 +876,7 @@ static unsigned long shrink_page_list(st
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
+		bool freeable = false;
 
 		cond_resched();
 
@@ -992,7 +1000,8 @@ static unsigned long shrink_page_list(st
 		}
 
 		if (!force_reclaim)
-			references = page_check_references(page, sc);
+			references = page_check_references(page, sc,
+							&freeable);
 
 		switch (references) {
 		case PAGEREF_ACTIVATE:
@@ -1009,22 +1018,31 @@ static unsigned long shrink_page_list(st
 		 * Try to allocate it some swap space here.
 		 */
 		if (PageAnon(page) && !PageSwapCache(page)) {
-			if (!(sc->gfp_mask & __GFP_IO))
-				goto keep_locked;
-			if (!add_to_swap(page, page_list))
-				goto activate_locked;
-			may_enter_fs = 1;
-
-			/* Adding to swap updated mapping */
-			mapping = page_mapping(page);
+			if (!freeable) {
+				if (!(sc->gfp_mask & __GFP_IO))
+					goto keep_locked;
+				if (!add_to_swap(page, page_list))
+					goto activate_locked;
+				may_enter_fs = 1;
+				/* Adding to swap updated mapping */
+				mapping = page_mapping(page);
+			} else {
+				if (likely(!PageTransHuge(page)))
+					goto unmap;
+				/* try_to_unmap isn't aware of THP page */
+				if (unlikely(split_huge_page_to_list(page,
+								page_list)))
+					goto keep_locked;
+			}
 		}
-
+unmap:
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page_mapped(page) && mapping) {
-			switch (try_to_unmap(page, ttu_flags)) {
+		if (page_mapped(page) && (mapping || freeable)) {
+			switch (try_to_unmap(page,
+				freeable ? TTU_FREE : ttu_flags)) {
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
@@ -1032,7 +1050,20 @@ static unsigned long shrink_page_list(st
 			case SWAP_MLOCK:
 				goto cull_mlocked;
 			case SWAP_SUCCESS:
-				; /* try to free the page below */
+				/* try to free the page below */
+				if (!freeable)
+					break;
+				/*
+				 * Freeable anon page doesn't have mapping
+				 * due to skipping of swapcache so we free
+				 * page in here rather than __remove_mapping.
+				 */
+				VM_BUG_ON_PAGE(PageSwapCache(page), page);
+				if (!page_freeze_refs(page, 1))
+					goto keep_locked;
+				__ClearPageLocked(page);
+				count_vm_event(PGLAZYFREED);
+				goto free_it;
 			}
 		}
 
@@ -1789,7 +1820,7 @@ static void shrink_active_list(unsigned
 		}
 
 		if (page_referenced(page, 0, sc->target_mem_cgroup,
-				    &vm_flags)) {
+				    &vm_flags, NULL)) {
 			nr_rotated += hpage_nr_pages(page);
 			/*
 			 * Identify referenced, file-backed active pages and
diff -puN mm/vmstat.c~mm-support-madvisemadv_free mm/vmstat.c
--- a/mm/vmstat.c~mm-support-madvisemadv_free
+++ a/mm/vmstat.c
@@ -759,6 +759,7 @@ const char * const vmstat_text[] = {
 
 	"pgfault",
 	"pgmajfault",
+	"pglazyfreed",
 
 	TEXTS_FOR_ZONES("pgrefill")
 	TEXTS_FOR_ZONES("pgsteal_kswapd")
diff -puN arch/alpha/include/uapi/asm/mman.h~mm-support-madvisemadv_free arch/alpha/include/uapi/asm/mman.h
--- a/arch/alpha/include/uapi/asm/mman.h~mm-support-madvisemadv_free
+++ a/arch/alpha/include/uapi/asm/mman.h
@@ -44,6 +44,7 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define	MADV_SPACEAVAIL	5		/* ensure resources are available */
 #define MADV_DONTNEED	6		/* don't need these pages */
+#define MADV_FREE	7		/* free pages only if memory pressure */
 
 /* common/generic parameters */
 #define MADV_REMOVE	9		/* remove these pages & resources */
diff -puN arch/mips/include/uapi/asm/mman.h~mm-support-madvisemadv_free arch/mips/include/uapi/asm/mman.h
--- a/arch/mips/include/uapi/asm/mman.h~mm-support-madvisemadv_free
+++ a/arch/mips/include/uapi/asm/mman.h
@@ -67,6 +67,7 @@
 #define MADV_SEQUENTIAL 2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* free pages only if memory pressure */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
diff -puN arch/parisc/include/uapi/asm/mman.h~mm-support-madvisemadv_free arch/parisc/include/uapi/asm/mman.h
--- a/arch/parisc/include/uapi/asm/mman.h~mm-support-madvisemadv_free
+++ a/arch/parisc/include/uapi/asm/mman.h
@@ -40,6 +40,7 @@
 #define MADV_SPACEAVAIL 5               /* insure that resources are reserved */
 #define MADV_VPS_PURGE  6               /* Purge pages from VM page cache */
 #define MADV_VPS_INHERIT 7              /* Inherit parents page size */
+#define MADV_FREE	8		/* free pages only if memory pressure */
 
 /* common/generic parameters */
 #define MADV_REMOVE	9		/* remove these pages & resources */
diff -puN arch/xtensa/include/uapi/asm/mman.h~mm-support-madvisemadv_free arch/xtensa/include/uapi/asm/mman.h
--- a/arch/xtensa/include/uapi/asm/mman.h~mm-support-madvisemadv_free
+++ a/arch/xtensa/include/uapi/asm/mman.h
@@ -80,6 +80,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* free pages only if memory pressure */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
diff -puN include/linux/huge_mm.h~mm-support-madvisemadv_free include/linux/huge_mm.h
--- a/include/linux/huge_mm.h~mm-support-madvisemadv_free
+++ a/include/linux/huge_mm.h
@@ -19,6 +19,9 @@ extern struct page *follow_trans_huge_pm
 					  unsigned long addr,
 					  pmd_t *pmd,
 					  unsigned int flags);
+extern int madvise_free_huge_pmd(struct mmu_gather *tlb,
+			struct vm_area_struct *vma,
+			pmd_t *pmd, unsigned long addr);
 extern int zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr);
@@ -56,6 +59,7 @@ extern pmd_t *page_check_address_pmd(str
 				     unsigned long address,
 				     enum page_check_address_pmd_flag flag,
 				     spinlock_t **ptl);
+extern int pmd_freeable(pmd_t pmd);
 
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
diff -puN mm/huge_memory.c~mm-support-madvisemadv_free mm/huge_memory.c
--- a/mm/huge_memory.c~mm-support-madvisemadv_free
+++ a/mm/huge_memory.c
@@ -1384,6 +1384,36 @@ out:
 	return 0;
 }
 
+int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		 pmd_t *pmd, unsigned long addr)
+
+{
+	spinlock_t *ptl;
+	struct mm_struct *mm = tlb->mm;
+	int ret = 1;
+
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+		struct page *page;
+		pmd_t orig_pmd;
+
+		orig_pmd = pmdp_get_and_clear(mm, addr, pmd);
+
+		/* No hugepage in swapcache */
+		page = pmd_page(orig_pmd);
+		VM_BUG_ON_PAGE(PageSwapCache(page), page);
+
+		orig_pmd = pmd_mkold(orig_pmd);
+		orig_pmd = pmd_mkclean(orig_pmd);
+
+		set_pmd_at(mm, addr, pmd, orig_pmd);
+		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
+		spin_unlock(ptl);
+		ret = 0;
+	}
+
+	return ret;
+}
+
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
@@ -1599,6 +1629,11 @@ unlock:
 	return NULL;
 }
 
+int pmd_freeable(pmd_t pmd)
+{
+	return !pmd_dirty(pmd);
+}
+
 static int __split_huge_page_splitting(struct page *page,
 				       struct vm_area_struct *vma,
 				       unsigned long address)
diff -puN include/linux/swap.h~mm-support-madvisemadv_free include/linux/swap.h
--- a/include/linux/swap.h~mm-support-madvisemadv_free
+++ a/include/linux/swap.h
@@ -308,6 +308,7 @@ extern void lru_add_drain_cpu(int cpu);
 extern void lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_file_page(struct page *page);
+extern void deactivate_page(struct page *page);
 extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
diff -puN mm/swap.c~mm-support-madvisemadv_free mm/swap.c
--- a/mm/swap.c~mm-support-madvisemadv_free
+++ a/mm/swap.c
@@ -44,6 +44,7 @@ int page_cluster;
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -797,6 +798,24 @@ static void lru_deactivate_file_fn(struc
 	update_page_reclaim_stat(lruvec, file, 0);
 }
 
+
+static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
+			    void *arg)
+{
+	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
+		int file = page_is_file_cache(page);
+		int lru = page_lru_base_type(page);
+
+		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
+		ClearPageActive(page);
+		ClearPageReferenced(page);
+		add_page_to_lru_list(page, lruvec, lru);
+
+		__count_vm_event(PGDEACTIVATE);
+		update_page_reclaim_stat(lruvec, file, 0);
+	}
+}
+
 /*
  * Drain pages out of the cpu's pagevecs.
  * Either "cpu" is the current CPU, and preemption has already been
@@ -823,6 +842,10 @@ void lru_add_drain_cpu(int cpu)
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
 
+	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	if (pagevec_count(pvec))
+		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+
 	activate_page_drain(cpu);
 }
 
@@ -852,6 +875,26 @@ void deactivate_file_page(struct page *p
 	}
 }
 
+/**
+ * deactivate_page - deactivate a page
+ * @page: page to deactivate
+ *
+ * deactivate_page() moves @page to the inactive list if @page was on the active
+ * list and was not an unevictable page.  This is done to accelerate the reclaim
+ * of @page.
+ */
+void deactivate_page(struct page *page)
+{
+	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
+		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
+
+		page_cache_get(page);
+		if (!pagevec_add(pvec, page))
+			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+		put_cpu_var(lru_deactivate_pvecs);
+	}
+}
+
 void lru_add_drain(void)
 {
 	lru_add_drain_cpu(get_cpu());
@@ -881,6 +924,7 @@ void lru_add_drain_all(void)
 		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
 		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
+		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			schedule_work_on(cpu, work);
diff -puN mm/memory.c~mm-support-madvisemadv_free mm/memory.c
--- a/mm/memory.c~mm-support-madvisemadv_free
+++ a/mm/memory.c
@@ -2555,9 +2555,15 @@ static int do_swap_page(struct mm_struct
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	dec_mm_counter_fast(mm, MM_SWAPENTS);
-	pte = mk_pte(page, vma->vm_page_prot);
+
+	/*
+	 * The page is swapping in now was dirty before it was swapped out
+	 * so restore the state again(ie, pte_mkdirty) because MADV_FREE
+	 * relies on the dirty bit on page table.
+	 */
+	pte = pte_mkdirty(mk_pte(page, vma->vm_page_prot));
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
-		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		pte = maybe_mkwrite(pte, vma);
 		flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = 1;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
