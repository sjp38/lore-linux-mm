Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C93486B0038
	for <linux-mm@kvack.org>; Sun, 11 May 2014 21:24:16 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so3070684pad.25
        for <linux-mm@kvack.org>; Sun, 11 May 2014 18:24:16 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id rw8si5546816pbc.18.2014.05.11.18.24.14
        for <linux-mm@kvack.org>;
        Sun, 11 May 2014 18:24:15 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v6] mm: support madvise(MADV_FREE)
Date: Mon, 12 May 2014 10:26:28 +0900
Message-Id: <1399857988-2880-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, John Stultz <john.stultz@linaro.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>

Linux doesn't have an ability to free pages lazy while other OS
already have been supported that named by madvise(MADV_FREE).

The gain is clear that kernel can discard freed pages rather than
swapping out or OOM if memory pressure happens.

Without memory pressure, freed pages would be reused by userspace
without another additional overhead(ex, page fault + allocation
+ zeroing).

How to work is following as.

When madvise syscall is called, VM clears dirty bit of ptes of
the range. If memory pressure happens, VM checks dirty bit of
page table and if it found still "clean", it means it's a
"lazyfree pages" so VM could discard the page instead of swapping out.
Once there was store operation for the page before VM peek a page
to reclaim, dirty bit is set so VM can swap out the page instead of
discarding.

Firstly, heavy users would be general allocators(ex, jemalloc,
tcmalloc and hope glibc supports it) and jemalloc/tcmalloc already
have supported the feature for other OS(ex, FreeBSD)

barrios@blaptop:~/benchmark/ebizzy$ lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                4
On-line CPU(s) list:   0-3
Thread(s) per core:    2
Core(s) per socket:    2
Socket(s):             1
NUMA node(s):          1
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 42
Stepping:              7
CPU MHz:               2801.000
BogoMIPS:              5581.64
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              4096K
NUMA node0 CPU(s):     0-3

ebizzy benchmark(./ebizzy -S 10 -n 512)

 vanilla-jemalloc		MADV_free-jemalloc

1 thread
records:  10              records:  10
avg:      7436.70         avg:      15292.70
std:      48.01(0.65%)    std:      496.40(3.25%)
max:      7542.00         max:      15944.00
min:      7366.00         min:      14478.00

2 thread
records:  10              records:  10
avg:      12190.50        avg:      24975.50
std:      1011.51(8.30%)  std:      1127.22(4.51%)
max:      13012.00        max:      26382.00
min:      10192.00        min:      23265.00

4 thread
records:  10              records:  10
avg:      16875.30        avg:      36320.90
std:      562.59(3.33%)   std:      1503.75(4.14%)
max:      17465.00        max:      38314.00
min:      15552.00        min:      33863.00

8 thread
records:  10              records:  10
avg:      16966.80        avg:      35915.20
std:      229.35(1.35%)   std:      2153.89(6.00%)
max:      17456.00        max:      37943.00
min:      16742.00        min:      29891.00

16 thread
records:  10              records:  10
avg:      20590.90        avg:      37388.40
std:      362.33(1.76%)   std:      1282.59(3.43%)
max:      20954.00        max:      38911.00
min:      19985.00        min:      34928.00

32 thread
records:  10              records:  10
avg:      22633.40        avg:      37118.00
std:      413.73(1.83%)   std:      766.36(2.06%)
max:      23120.00        max:      38328.00
min:      22071.00        min:      35557.00

In summary, MADV_FREE is about 2 time faster than MADV_DONTNEED.

Patchset is based on v3.15-rc5
* From v5
 * Fix PPC problem which don't flush TLB - Rik
 * Remove unnecessary lazyfree_range stub function - Rik
 * Rebased on v3.15-rc5

* From v4
 * Add Reviewed-by: Zhang Yanfei
 * Rebase on v3.15-rc1-mmotm-2014-04-15-16-14

* From v3
 * Add "how to work part" in description - Zhang
 * Add page_discardable utility function - Zhang
 * Clean up

* From v2
 * Remove forceful dirty marking of swap-readed page - Johannes
 * Remove deactivation logic of lazyfreed page
 * Rebased on 3.14
 * Remove RFC tag

* From v1
 * Use custom page table walker for madvise_free - Johannes
 * Remove PG_lazypage flag - Johannes
 * Do madvise_dontneed instead of madvise_freein swapless system

Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Jason Evans <je@fb.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mm.h                     |   2 +
 include/linux/rmap.h                   |  21 ++++-
 include/linux/vm_event_item.h          |   1 +
 include/uapi/asm-generic/mman-common.h |   1 +
 mm/madvise.c                           |  17 ++++
 mm/memory.c                            | 139 +++++++++++++++++++++++++++++++++
 mm/rmap.c                              |  83 ++++++++++++++++++--
 mm/vmscan.c                            |  29 ++++++-
 mm/vmstat.c                            |   1 +
 9 files changed, 282 insertions(+), 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bf9811e1321a..c69594c141a9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1082,6 +1082,8 @@ int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size);
 void zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
+int lazyfree_single_vma(struct vm_area_struct *vma, unsigned long start_addr,
+		unsigned long end_addr);
 void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long start, unsigned long end);
 
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index b66c2110cb1f..7c842675bb1b 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -181,8 +181,11 @@ static inline void page_dup_rmap(struct page *page)
 /*
  * Called from mm/vmscan.c to handle paging out
  */
+
+bool page_discardable(struct page *page, bool pte_dirty);
 int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+			struct mem_cgroup *memcg, unsigned long *vm_flags,
+			int *is_dirty);
 int page_referenced_one(struct page *, struct vm_area_struct *,
 	unsigned long address, void *arg);
 
@@ -235,6 +238,11 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page);
 void page_unlock_anon_vma_read(struct anon_vma *anon_vma);
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
+struct rmap_private {
+	enum ttu_flags flags;
+	int pte_dirty;	/* used for lazyfree */
+};
+
 /*
  * rmap_walk_control: To control rmap traversing for specific needs
  *
@@ -263,11 +271,19 @@ int rmap_walk(struct page *page, struct rmap_walk_control *rwc);
 #define anon_vma_prepare(vma)	(0)
 #define anon_vma_link(vma)	do {} while (0)
 
+bool page_discardable(struct page *page, bool pte_dirty)
+{
+	return false;
+}
+
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
 
@@ -288,5 +304,6 @@ static inline int page_mkclean(struct page *page)
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
 #define SWAP_MLOCK	3
+#define SWAP_DISCARD	4
 
 #endif	/* _LINUX_RMAP_H */
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 486c3972c0be..669045bcfef2 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -25,6 +25,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
+		PGLAZYFREED,
 		FOR_ALL_ZONES(PGREFILL),
 		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
 		FOR_ALL_ZONES(PGSTEAL_DIRECT),
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index ddc3b36f1046..7a94102b7a02 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -34,6 +34,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* free pages only if memory pressure */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
diff --git a/mm/madvise.c b/mm/madvise.c
index 539eeb96b323..ced874700b77 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -31,6 +31,7 @@ static int madvise_need_mmap_write(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_FREE:
 		return 0;
 	default:
 		/* be safe, default to 1. list exceptions explicitly */
@@ -251,6 +252,14 @@ static long madvise_willneed(struct vm_area_struct *vma,
 	return 0;
 }
 
+static long madvise_lazyfree(struct vm_area_struct *vma,
+			     struct vm_area_struct **prev,
+			     unsigned long start, unsigned long end)
+{
+	*prev = vma;
+	return lazyfree_single_vma(vma, start, end);
+}
+
 /*
  * Application no longer needs these pages.  If the pages are dirty,
  * it's OK to just throw them away.  The app will be more careful about
@@ -384,6 +393,13 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		return madvise_remove(vma, prev, start, end);
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
+	case MADV_FREE:
+		/*
+		 * In this implementation, MADV_FREE works like MADV_DONTNEED
+		 * on swapless system or full swap.
+		 */
+		if (get_nr_swap_pages() > 0)
+			return madvise_lazyfree(vma, prev, start, end);
 	case MADV_DONTNEED:
 		return madvise_dontneed(vma, prev, start, end);
 	default:
@@ -403,6 +419,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_FREE:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
diff --git a/mm/memory.c b/mm/memory.c
index 037b812a9531..0516c94da1a4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1284,6 +1284,112 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 	return addr;
 }
 
+static unsigned long lazyfree_pte_range(struct mmu_gather *tlb,
+				struct vm_area_struct *vma, pmd_t *pmd,
+				unsigned long addr, unsigned long end)
+{
+	struct mm_struct *mm = tlb->mm;
+	spinlock_t *ptl;
+	pte_t *start_pte;
+	pte_t *pte;
+
+	start_pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	pte = start_pte;
+	arch_enter_lazy_mmu_mode();
+	do {
+		pte_t ptent = *pte;
+
+		if (pte_none(ptent))
+			continue;
+
+		if (!pte_present(ptent))
+			continue;
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
+		tlb_remove_tlb_entry(tlb, pte, addr);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	arch_leave_lazy_mmu_mode();
+	pte_unmap_unlock(start_pte, ptl);
+
+	return addr;
+}
+
+static inline unsigned long lazyfree_pmd_range(struct mmu_gather *tlb,
+				struct vm_area_struct *vma, pud_t *pud,
+				unsigned long addr, unsigned long end)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_trans_huge(*pmd))
+			split_huge_page_pmd(vma, addr, pmd);
+		/*
+		 * Here there can be other concurrent MADV_DONTNEED or
+		 * trans huge page faults running, and if the pmd is
+		 * none or trans huge it can change under us. This is
+		 * because MADV_LAZYFREE holds the mmap_sem in read
+		 * mode.
+		 */
+		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
+			goto next;
+		next = lazyfree_pte_range(tlb, vma, pmd, addr, next);
+next:
+		cond_resched();
+	} while (pmd++, addr = next, addr != end);
+
+	return addr;
+}
+
+static inline unsigned long lazyfree_pud_range(struct mmu_gather *tlb,
+				struct vm_area_struct *vma, pgd_t *pgd,
+				unsigned long addr, unsigned long end)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		next = lazyfree_pmd_range(tlb, vma, pud, addr, next);
+	} while (pud++, addr = next, addr != end);
+
+	return addr;
+}
+
+static void lazyfree_page_range(struct mmu_gather *tlb,
+			     struct vm_area_struct *vma,
+			     unsigned long addr, unsigned long end)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	BUG_ON(addr >= end);
+	tlb_start_vma(tlb, vma);
+	pgd = pgd_offset(vma->vm_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		next = lazyfree_pud_range(tlb, vma, pgd, addr, next);
+	} while (pgd++, addr = next, addr != end);
+	tlb_end_vma(tlb, vma);
+}
+
 static void unmap_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
 			     unsigned long addr, unsigned long end,
@@ -1310,6 +1416,39 @@ static void unmap_page_range(struct mmu_gather *tlb,
 }
 
 
+int lazyfree_single_vma(struct vm_area_struct *vma, unsigned long start_addr,
+		unsigned long end_addr)
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
+	lazyfree_page_range(&tlb, vma, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
+	tlb_finish_mmu(&tlb, start, end);
+
+	return 0;
+}
+
 static void unmap_single_vma(struct mmu_gather *tlb,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr,
diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e77396d1a..968712084083 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -661,6 +661,7 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
 }
 
 struct page_referenced_arg {
+	int dirtied;
 	int mapcount;
 	int referenced;
 	unsigned long vm_flags;
@@ -675,6 +676,7 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 	struct mm_struct *mm = vma->vm_mm;
 	spinlock_t *ptl;
 	int referenced = 0;
+	int dirty = 0;
 	struct page_referenced_arg *pra = arg;
 
 	if (unlikely(PageTransHuge(page))) {
@@ -727,6 +729,10 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			if (likely(!(vma->vm_flags & VM_SEQ_READ)))
 				referenced++;
 		}
+
+		if (pte_dirty(*pte))
+			dirty++;
+
 		pte_unmap_unlock(pte, ptl);
 	}
 
@@ -735,6 +741,9 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		pra->vm_flags |= vma->vm_flags;
 	}
 
+	if (dirty)
+		pra->dirtied++;
+
 	pra->mapcount--;
 	if (!pra->mapcount)
 		return SWAP_SUCCESS; /* To break the loop */
@@ -754,11 +763,34 @@ static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
 }
 
 /**
+ * page_discardable - test if the page could be discardable instead of swap
+ * @page: the page to test
+ * @pte_dirty: ptes which have marked dirty bit
+ *
+ * Should check PageDirty because swap-in page by read fault
+ * would put on swapcache and pte point out the page doesn't have
+ * dirty bit so only pte dirtiness check isn't enough to detect
+ * lazyfree page so we need to check PG_swapcache to filter it out.
+ * But, if the page is removed from swapcache, it must have PG_dirty
+ * so we should check it to prevent purging non-lazyfree page.
+ */
+bool page_discardable(struct page *page, bool pte_dirty)
+{
+	bool ret = false;
+
+	if (PageAnon(page) && !pte_dirty && !PageSwapCache(page) &&
+			!PageDirty(page))
+		ret = true;
+	return ret;
+}
+
+/**
  * page_referenced - test if the page was referenced
  * @page: the page to test
  * @is_locked: caller holds lock on the page
  * @memcg: target memory cgroup
  * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
+ * @is_pte_dirty: ptes which have marked dirty bit - used for lazyfree page
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
@@ -766,7 +798,8 @@ static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *memcg,
-		    unsigned long *vm_flags)
+		    unsigned long *vm_flags,
+		    int *is_pte_dirty)
 {
 	int ret;
 	int we_locked = 0;
@@ -781,6 +814,9 @@ int page_referenced(struct page *page,
 	};
 
 	*vm_flags = 0;
+	if (is_pte_dirty)
+		*is_pte_dirty = 0;
+
 	if (!page_mapped(page))
 		return 0;
 
@@ -808,6 +844,9 @@ int page_referenced(struct page *page,
 	if (we_locked)
 		unlock_page(page);
 
+	if (is_pte_dirty)
+		*is_pte_dirty = pra.dirtied;
+
 	return pra.referenced;
 }
 
@@ -1120,7 +1159,9 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	pte_t pteval;
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
-	enum ttu_flags flags = (enum ttu_flags)arg;
+	struct rmap_private *rp = (struct rmap_private *)arg;
+	enum ttu_flags flags = rp->flags;
+	int dirty = 0;
 
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
@@ -1150,7 +1191,8 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	pteval = ptep_clear_flush(vma, address, pte);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
-	if (pte_dirty(pteval))
+	dirty = pte_dirty(pteval);
+	if (dirty)
 		set_page_dirty(page);
 
 	/* Update high watermark before we lower rss */
@@ -1179,6 +1221,15 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		swp_entry_t entry = { .val = page_private(page) };
 		pte_t swp_pte;
 
+		if ((TTU_ACTION(flags) == TTU_UNMAP) &&
+				page_discardable(page, dirty)) {
+			dec_mm_counter(mm, MM_ANONPAGES);
+			goto discard;
+		}
+
+		if (dirty)
+			rp->pte_dirty++;
+
 		if (PageSwapCache(page)) {
 			/*
 			 * Store the swap location in the pte.
@@ -1197,6 +1248,10 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			}
 			dec_mm_counter(mm, MM_ANONPAGES);
 			inc_mm_counter(mm, MM_SWAPENTS);
+		} else if (TTU_ACTION(flags) == TTU_UNMAP) {
+			set_pte_at(mm, address, pte, pteval);
+			ret = SWAP_FAIL;
+			goto out_unmap;
 		} else if (IS_ENABLED(CONFIG_MIGRATION)) {
 			/*
 			 * Store the pfn of the page in a special migration
@@ -1220,6 +1275,7 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	} else
 		dec_mm_counter(mm, MM_FILEPAGES);
 
+discard:
 	page_remove_rmap(page);
 	page_cache_release(page);
 
@@ -1490,13 +1546,19 @@ static int page_not_mapped(struct page *page)
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
  * SWAP_MLOCK	- page is mlocked.
+ * SWAP_DISCARD - same with SWAP_SUCCESS but no need to swap out
  */
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
 	int ret;
+
+	struct rmap_private rp = {
+		.flags = flags,
+	};
+
 	struct rmap_walk_control rwc = {
 		.rmap_one = try_to_unmap_one,
-		.arg = (void *)flags,
+		.arg = &rp,
 		.done = page_not_mapped,
 		.file_nonlinear = try_to_unmap_nonlinear,
 		.anon_lock = page_lock_anon_vma_read,
@@ -1517,8 +1579,13 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 
 	ret = rmap_walk(page, &rwc);
 
-	if (ret != SWAP_MLOCK && !page_mapped(page))
+	if (ret != SWAP_MLOCK && !page_mapped(page)) {
 		ret = SWAP_SUCCESS;
+		if (TTU_ACTION(flags) == TTU_UNMAP &&
+			page_discardable(page, rp.pte_dirty))
+			ret = SWAP_DISCARD;
+	}
+
 	return ret;
 }
 
@@ -1540,9 +1607,13 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 int try_to_munlock(struct page *page)
 {
 	int ret;
+	struct rmap_private rp = {
+		.flags = TTU_MUNLOCK,
+	};
+
 	struct rmap_walk_control rwc = {
 		.rmap_one = try_to_unmap_one,
-		.arg = (void *)TTU_MUNLOCK,
+		.arg = &rp,
 		.done = page_not_mapped,
 		/*
 		 * We don't bother to try to find the munlocked page in
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3f56c8deb3c0..be93b9ad144d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -698,6 +698,7 @@ enum page_references {
 	PAGEREF_RECLAIM_CLEAN,
 	PAGEREF_KEEP,
 	PAGEREF_ACTIVATE,
+	PAGEREF_DISCARD,
 };
 
 static enum page_references page_check_references(struct page *page,
@@ -705,9 +706,12 @@ static enum page_references page_check_references(struct page *page,
 {
 	int referenced_ptes, referenced_page;
 	unsigned long vm_flags;
+	int is_pte_dirty;
+
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
 	referenced_ptes = page_referenced(page, 1, sc->target_mem_cgroup,
-					  &vm_flags);
+					  &vm_flags, &is_pte_dirty);
 	referenced_page = TestClearPageReferenced(page);
 
 	/*
@@ -748,6 +752,9 @@ static enum page_references page_check_references(struct page *page,
 		return PAGEREF_KEEP;
 	}
 
+	if (page_discardable(page, is_pte_dirty))
+		return PAGEREF_DISCARD;
+
 	/* Reclaim if clean, defer dirty pages to writeback */
 	if (referenced_page && !PageSwapBacked(page))
 		return PAGEREF_RECLAIM_CLEAN;
@@ -817,6 +824,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
+		bool discard = false;
 
 		cond_resched();
 
@@ -946,6 +954,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto activate_locked;
 		case PAGEREF_KEEP:
 			goto keep_locked;
+		case PAGEREF_DISCARD:
+			/*
+			 * skip to add the page into swapcache  then
+			 * unmap without mapping
+			 */
+			discard = true;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
 			; /* try to reclaim the page below */
@@ -955,7 +969,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
+		if (PageAnon(page) && !PageSwapCache(page) && !discard) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
 			if (!add_to_swap(page, page_list))
@@ -970,7 +984,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page_mapped(page) && mapping) {
+		if (page_mapped(page) && (mapping || discard)) {
 			switch (try_to_unmap(page, ttu_flags)) {
 			case SWAP_FAIL:
 				goto activate_locked;
@@ -978,6 +992,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 			case SWAP_MLOCK:
 				goto cull_mlocked;
+			case SWAP_DISCARD:
+				VM_BUG_ON_PAGE(PageSwapCache(page), page);
+				if (!page_freeze_refs(page, 1))
+					goto keep_locked;
+				__clear_page_locked(page);
+				count_vm_event(PGLAZYFREED);
+				goto free_it;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -1702,7 +1723,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 		}
 
 		if (page_referenced(page, 0, sc->target_mem_cgroup,
-				    &vm_flags)) {
+				    &vm_flags, NULL)) {
 			nr_rotated += hpage_nr_pages(page);
 			/*
 			 * Identify referenced, file-backed active pages and
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 302dd076b8bf..759d8dc0ea93 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -792,6 +792,7 @@ const char * const vmstat_text[] = {
 
 	"pgfault",
 	"pgmajfault",
+	"pglazyfreed",
 
 	TEXTS_FOR_ZONES("pgrefill")
 	TEXTS_FOR_ZONES("pgsteal_kswapd")
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
