Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id EB6D76B0038
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:32:44 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so52383202pab.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:32:44 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id iu1si17177884pbd.163.2015.11.11.20.32.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 Nov 2015 20:32:43 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 01/17] mm: support madvise(MADV_FREE)
Date: Thu, 12 Nov 2015 13:32:57 +0900
Message-Id: <1447302793-5376-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1447302793-5376-1-git-send-email-minchan@kernel.org>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Minchan Kim <minchan@kernel.org>

Linux doesn't have an ability to free pages lazy while other OS already
have been supported that named by madvise(MADV_FREE).

The gain is clear that kernel can discard freed pages rather than swapping
out or OOM if memory pressure happens.

Without memory pressure, freed pages would be reused by userspace without
another additional overhead(ex, page fault + allocation + zeroing).

Jason Evans said:

: Facebook has been using MAP_UNINITIALIZED
: (https://lkml.org/lkml/2012/1/18/308) in some of its applications for
: several years, but there are operational costs to maintaining this
: out-of-tree in our kernel and in jemalloc, and we are anxious to retire it
: in favor of MADV_FREE.  When we first enabled MAP_UNINITIALIZED it
: increased throughput for much of our workload by ~5%, and although the
: benefit has decreased using newer hardware and kernels, there is still
: enough benefit that we cannot reasonably retire it without a replacement.
:
: Aside from Facebook operations, there are numerous broadly used
: applications that would benefit from MADV_FREE.  The ones that immediately
: come to mind are redis, varnish, and MariaDB.  I don't have much insight
: into Android internals and development process, but I would hope to see
: MADV_FREE support eventually end up there as well to benefit applications
: linked with the integrated jemalloc.
:
: jemalloc will use MADV_FREE once it becomes available in the Linux kernel.
: In fact, jemalloc already uses MADV_FREE or equivalent everywhere it's
: available: *BSD, OS X, Windows, and Solaris -- every platform except Linux
: (and AIX, but I'm not sure it even compiles on AIX).  The lack of
: MADV_FREE on Linux forced me down a long series of increasingly
: sophisticated heuristics for madvise() volume reduction, and even so this
: remains a common performance issue for people using jemalloc on Linux.
: Please integrate MADV_FREE; many people will benefit substantially.

How it works:

When madvise syscall is called, VM clears dirty bit of ptes of the range.
If memory pressure happens, VM checks dirty bit of page table and if it
found still "clean", it means it's a "lazyfree pages" so VM could discard
the page instead of swapping out.  Once there was store operation for the
page before VM peek a page to reclaim, dirty bit is set so VM can swap out
the page instead of discarding.

Firstly, heavy users would be general allocators(ex, jemalloc, tcmalloc
and hope glibc supports it) and jemalloc/tcmalloc already have supported
the feature for other OS(ex, FreeBSD)

barrios@blaptop:~/benchmark/ebizzy$ lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                12
On-line CPU(s) list:   0-11
Thread(s) per core:    1
Core(s) per socket:    1
Socket(s):             12
NUMA node(s):          1
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 2
Stepping:              3
CPU MHz:               3200.185
BogoMIPS:              6400.53
Virtualization:        VT-x
Hypervisor vendor:     KVM
Virtualization type:   full
L1d cache:             32K
L1i cache:             32K
L2 cache:              4096K
NUMA node0 CPU(s):     0-11
ebizzy benchmark(./ebizzy -S 10 -n 512)

Higher avg is better.

 vanilla-jemalloc		MADV_free-jemalloc

1 thread
records: 10			    records: 10
avg:	2961.90			    avg:   12069.70
std:	  71.96(2.43%)		    std:     186.68(1.55%)
max:	3070.00			    max:   12385.00
min:	2796.00			    min:   11746.00

2 thread
records: 10			    records: 10
avg:	5020.00			    avg:   17827.00
std:	 264.87(5.28%)		    std:     358.52(2.01%)
max:	5244.00			    max:   18760.00
min:	4251.00			    min:   17382.00

4 thread
records: 10			    records: 10
avg:	8988.80			    avg:   27930.80
std:	1175.33(13.08%)		    std:    3317.33(11.88%)
max:	9508.00			    max:   30879.00
min:	5477.00			    min:   21024.00

8 thread
records: 10			    records: 10
avg:   13036.50			    avg:   33739.40
std:	 170.67(1.31%)		    std:    5146.22(15.25%)
max:   13371.00			    max:   40572.00
min:   12785.00			    min:   24088.00

16 thread
records: 10			    records: 10
avg:   11092.40			    avg:   31424.20
std:	 710.60(6.41%)		    std:    3763.89(11.98%)
max:   12446.00			    max:   36635.00
min:	9949.00			    min:   25669.00

32 thread
records: 10			    records: 10
avg:   11067.00			    avg:   34495.80
std:	 971.06(8.77%)		    std:    2721.36(7.89%)
max:   12010.00			    max:   38598.00
min:	9002.00			    min:   30636.00

In summary, MADV_FREE is about much faster than MADV_DONTNEED.

Acked-by: Hugh Dickins <hughd@google.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h                   |   1 +
 include/linux/vm_event_item.h          |   1 +
 include/uapi/asm-generic/mman-common.h |   1 +
 mm/madvise.c                           | 132 +++++++++++++++++++++++++++++++++
 mm/rmap.c                              |   7 ++
 mm/swap_state.c                        |   5 +-
 mm/vmscan.c                            |  10 ++-
 mm/vmstat.c                            |   1 +
 8 files changed, 153 insertions(+), 5 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 29446aeef36e..f4c992826242 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -85,6 +85,7 @@ enum ttu_flags {
 	TTU_UNMAP = 1,			/* unmap mode */
 	TTU_MIGRATION = 2,		/* migration mode */
 	TTU_MUNLOCK = 4,		/* munlock mode */
+	TTU_FREE = 8,			/* free mode */
 
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
 	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 9246d32dc973..2b1cef88b827 100644
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
index c889fcbb530e..a8813f7b37b3 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -20,6 +20,9 @@
 #include <linux/backing-dev.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/mmu_notifier.h>
+
+#include <asm/tlb.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -32,6 +35,7 @@ static int madvise_need_mmap_write(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_FREE:
 		return 0;
 	default:
 		/* be safe, default to 1. list exceptions explicitly */
@@ -256,6 +260,125 @@ static long madvise_willneed(struct vm_area_struct *vma,
 	return 0;
 }
 
+static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
+
+{
+	struct mmu_gather *tlb = walk->private;
+	struct mm_struct *mm = tlb->mm;
+	struct vm_area_struct *vma = walk->vma;
+	spinlock_t *ptl;
+	pte_t *pte, ptent;
+	struct page *page;
+
+	split_huge_page_pmd(vma, addr, pmd);
+	if (pmd_trans_unstable(pmd))
+		return 0;
+
+	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	arch_enter_lazy_mmu_mode();
+	for (; addr != end; pte++, addr += PAGE_SIZE) {
+		ptent = *pte;
+
+		if (!pte_present(ptent))
+			continue;
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
+			ClearPageDirty(page);
+			unlock_page(page);
+		}
+
+		if (pte_young(ptent) || pte_dirty(ptent)) {
+			/*
+			 * Some of architecture(ex, PPC) don't update TLB
+			 * with set_pte_at and tlb_remove_tlb_entry so for
+			 * the portability, remap the pte with old|clean
+			 * after pte clearing.
+			 */
+			ptent = ptep_get_and_clear_full(mm, addr, pte,
+							tlb->fullmm);
+
+			ptent = pte_mkold(ptent);
+			ptent = pte_mkclean(ptent);
+			set_pte_at(mm, addr, pte, ptent);
+			tlb_remove_tlb_entry(tlb, pte, addr);
+		}
+	}
+
+	arch_leave_lazy_mmu_mode();
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+	return 0;
+}
+
+static void madvise_free_page_range(struct mmu_gather *tlb,
+			     struct vm_area_struct *vma,
+			     unsigned long addr, unsigned long end)
+{
+	struct mm_walk free_walk = {
+		.pmd_entry = madvise_free_pte_range,
+		.mm = vma->vm_mm,
+		.private = tlb,
+	};
+
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
+	if (!vma_is_anonymous(vma))
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
@@ -379,6 +502,14 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
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
@@ -398,6 +529,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_FREE:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
diff --git a/mm/rmap.c b/mm/rmap.c
index f5b5c1f3dcd7..9449e91839ab 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1374,6 +1374,12 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		swp_entry_t entry = { .val = page_private(page) };
 		pte_t swp_pte;
 
+		if (!PageDirty(page) && (flags & TTU_FREE)) {
+			/* It's a freeable page by MADV_FREE */
+			dec_mm_counter(mm, MM_ANONPAGES);
+			goto discard;
+		}
+
 		if (PageSwapCache(page)) {
 			/*
 			 * Store the swap location in the pte.
@@ -1414,6 +1420,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	} else
 		dec_mm_counter(mm, MM_FILEPAGES);
 
+discard:
 	page_remove_rmap(page);
 	page_cache_release(page);
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index d504adb7fa5f..10f63eded7b7 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -185,13 +185,12 @@ int add_to_swap(struct page *page, struct list_head *list)
 	 * deadlock in the swap out path.
 	 */
 	/*
-	 * Add it to the swap cache and mark it dirty
+	 * Add it to the swap cache.
 	 */
 	err = add_to_swap_cache(page, entry,
 			__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);
 
-	if (!err) {	/* Success */
-		SetPageDirty(page);
+	if (!err) {
 		return 1;
 	} else {	/* -ENOMEM radix-tree allocation failure */
 		/*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7f63a9381f71..7a415b9fdd34 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -906,6 +906,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
+		bool freeable = false;
 
 		cond_resched();
 
@@ -1049,6 +1050,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 			if (!add_to_swap(page, page_list))
 				goto activate_locked;
+			freeable = true;
 			may_enter_fs = 1;
 
 			/* Adding to swap updated mapping */
@@ -1060,8 +1062,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page) && mapping) {
-			switch (try_to_unmap(page,
-					ttu_flags|TTU_BATCH_FLUSH)) {
+			switch (try_to_unmap(page, freeable ?
+				(ttu_flags | TTU_BATCH_FLUSH | TTU_FREE) :
+				(ttu_flags | TTU_BATCH_FLUSH))) {
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
@@ -1186,6 +1189,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		__clear_page_locked(page);
 free_it:
+		if (freeable && !PageDirty(page))
+			count_vm_event(PGLAZYFREED);
+
 		nr_reclaimed++;
 
 		/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index fbf14485a049..59d45b22355f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -759,6 +759,7 @@ const char * const vmstat_text[] = {
 
 	"pgfault",
 	"pgmajfault",
+	"pglazyfreed",
 
 	TEXTS_FOR_ZONES("pgrefill")
 	TEXTS_FOR_ZONES("pgsteal_kswapd")
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
