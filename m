Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6715C6B0191
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 02:39:44 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so483179pde.25
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 23:39:44 -0700 (PDT)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ha5si704059pbc.172.2014.03.19.23.39.41
        for <linux-mm@kvack.org>;
        Wed, 19 Mar 2014 23:39:43 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v2 1/3] mm: support madvise(MADV_FREE)
Date: Thu, 20 Mar 2014 15:38:56 +0900
Message-Id: <1395297538-10491-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1395297538-10491-1-git-send-email-minchan@kernel.org>
References: <1395297538-10491-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>

Linux doesn't have an ability to free pages lazy while other OS
already have been supported that named by madvise(MADV_FREE).

The gain is clear that kernel can evict freed pages rather than
swapping out or OOM if memory pressure happens.

Without memory pressure, freed pages would be reused by userspace
without another additional overhead(ex, page fault + allocation
+ zeroing).

Firstly, heavy users would be general allocators(ex, jemalloc,
I hope ptmalloc support it) and jemalloc already have supported
the feature for other OS(ex, FreeBSD)

>From comment from Johannes, I removed PG_lazyflag in patchset
and just check pte dirtiness but the problem of the approach
is the page readed by swap-read. It couldn't set a dirty bit
to pte but it shouldn't be discarded so I decide making pte
dirty on every read-in page. Surely, it would make CRIU
guys unhappy because it would make more diff data for them
so Ccing them with hope that they might have an idea.

We could use SetPageDirty in do_swap_page forcefully and check
it in try_to_unmap_one to detect lazyfree as well as pte dirtiness
but it would cause unnecessary swapout although same page was
already wroten to swap device. :(

If there isn't great idea, I should roll back to PG_lazyfree
approach.

Cc: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mm.h                     |   2 +
 include/linux/rmap.h                   |   6 ++
 include/linux/vm_event_item.h          |   1 +
 include/uapi/asm-generic/mman-common.h |   1 +
 mm/madvise.c                           |  25 +++++
 mm/memory.c                            | 161 ++++++++++++++++++++++++++++++++-
 mm/rmap.c                              |  31 ++++++-
 mm/swap_state.c                        |   3 +-
 mm/vmscan.c                            |  12 +++
 mm/vmstat.c                            |   1 +
 10 files changed, 235 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c1b7414c7bef..79af90212c19 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1063,6 +1063,8 @@ int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size);
 void zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
+void lazyfree_range(struct vm_area_struct *vma, unsigned long address,
+		unsigned long size);
 void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long start, unsigned long end);
 
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 1da693d51255..edd6aef92c0f 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -235,6 +235,11 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page);
 void page_unlock_anon_vma_read(struct anon_vma *anon_vma);
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
+struct rmap_private {
+	enum ttu_flags flags;
+	int dirtied;	/* used for lazyfree */
+};
+
 /*
  * rmap_walk_control: To control rmap traversing for specific needs
  *
@@ -289,5 +294,6 @@ static inline int page_mkclean(struct page *page)
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
 #define SWAP_MLOCK	3
+#define SWAP_DISCARD	4
 
 #endif	/* _LINUX_RMAP_H */
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 3a712e2e7d76..a69680d335bb 100644
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
index 4164529a94f9..7e257e49be2e 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -34,6 +34,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* do lazy free */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
diff --git a/mm/madvise.c b/mm/madvise.c
index 539eeb96b323..3e4568ac02f0 100644
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
@@ -251,6 +252,22 @@ static long madvise_willneed(struct vm_area_struct *vma,
 	return 0;
 }
 
+static long madvise_free(struct vm_area_struct *vma,
+			     struct vm_area_struct **prev,
+			     unsigned long start, unsigned long end)
+{
+	*prev = vma;
+	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
+		return -EINVAL;
+
+	/* madv_free works for only anon vma */
+	if (vma->vm_file)
+		return -EINVAL;
+
+	lazyfree_range(vma, start, end - start);
+	return 0;
+}
+
 /*
  * Application no longer needs these pages.  If the pages are dirty,
  * it's OK to just throw them away.  The app will be more careful about
@@ -384,6 +401,13 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		return madvise_remove(vma, prev, start, end);
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
+	case MADV_FREE:
+		/*
+		 * At the moment, MADV_FREE doesn't support swapless
+		 * Will revisit.
+		 */
+		if (get_nr_swap_pages() > 0)
+			return madvise_free(vma, prev, start, end);
 	case MADV_DONTNEED:
 		return madvise_dontneed(vma, prev, start, end);
 	default:
@@ -403,6 +427,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_FREE:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
diff --git a/mm/memory.c b/mm/memory.c
index 22dfa617bddb..6f221225f62b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1268,6 +1268,123 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
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
+		struct page *page;
+		pte_t ptent = *pte;
+
+		if (pte_none(ptent))
+			continue;
+
+		if (!pte_present(ptent))
+			continue;
+
+		page = vm_normal_page(vma, addr, ptent);
+
+		BUG_ON(!PageAnon(page));
+
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
+		if (pmd_trans_huge(*pmd)) {
+			if (next - addr != HPAGE_PMD_SIZE) {
+#ifdef CONFIG_DEBUG_VM
+				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
+					pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
+						__func__, addr, end,
+						vma->vm_start,
+						vma->vm_end);
+					BUG();
+				}
+#endif
+				split_huge_page_pmd(vma, addr, pmd);
+			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
+				goto next;
+			/* fall through */
+		}
+		/*
+		 * Here there can be other concurrent MADV_DONTNEED or
+		 * trans huge page faults running, and if the pmd is
+		 * none or trans huge it can change under us. This is
+		 * because MADV_DONTNEED holds the mmap_sem in read
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
@@ -1294,6 +1411,23 @@ static void unmap_page_range(struct mmu_gather *tlb,
 }
 
 
+static void lazyfree_single_vma(struct mmu_gather *tlb,
+		struct vm_area_struct *vma, unsigned long start_addr,
+		unsigned long end_addr)
+{
+	unsigned long start = max(vma->vm_start, start_addr);
+	unsigned long end;
+
+	if (start >= vma->vm_end)
+		return;
+	end = min(vma->vm_end, end_addr);
+	if (end <= vma->vm_start)
+		return;
+
+	if (start != end)
+		lazyfree_page_range(tlb, vma, start, end);
+}
+
 static void unmap_single_vma(struct mmu_gather *tlb,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr,
@@ -1367,6 +1501,27 @@ void unmap_vmas(struct mmu_gather *tlb,
 	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
 }
 
+/*
+ * Most of code would be shared with zap_page_range.
+ * Will address later.
+ */
+void lazyfree_range(struct vm_area_struct *vma, unsigned long start,
+		unsigned long size)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_gather tlb;
+	unsigned long end = start + size;
+
+	lru_add_drain();
+	tlb_gather_mmu(&tlb, mm, start, end);
+	update_hiwater_rss(mm);
+	mmu_notifier_invalidate_range_start(mm, start, end);
+	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
+		lazyfree_single_vma(&tlb, vma, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
+	tlb_finish_mmu(&tlb, start, end);
+}
+
 /**
  * zap_page_range - remove user pages in a given range
  * @vma: vm_area_struct holding the applicable pages
@@ -3119,7 +3274,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	dec_mm_counter_fast(mm, MM_SWAPENTS);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
-		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		pte = maybe_mkwrite(pte, vma);
 		flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = 1;
@@ -3127,7 +3282,9 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	flush_icache_page(vma, page);
 	if (pte_swp_soft_dirty(orig_pte))
 		pte = pte_mksoft_dirty(pte);
-	set_pte_at(mm, address, page_table, pte);
+
+	/* Make pte dirty to prevent purge the page without swapping. */
+	set_pte_at(mm, address, page_table, pte_mkdirty(pte));
 	if (page == swapcache)
 		do_page_add_anon_rmap(page, vma, address, exclusive);
 	else /* ksm created a completely new copy */
diff --git a/mm/rmap.c b/mm/rmap.c
index d9d42316a99a..83b04c437f00 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1120,7 +1120,8 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	pte_t pteval;
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
-	enum ttu_flags flags = (enum ttu_flags)arg;
+	struct rmap_private *rp = (struct rmap_private *)arg;
+	enum ttu_flags flags = rp->flags;
 
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
@@ -1169,6 +1170,13 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		swp_entry_t entry = { .val = page_private(page) };
 		pte_t swp_pte;
 
+		/* discard lazyfree page if there was no write access */
+		if (!pte_dirty(pteval)) {
+			dec_mm_counter(mm, MM_ANONPAGES);
+			goto discard;
+		}
+
+		rp->dirtied++;
 		if (PageSwapCache(page)) {
 			/*
 			 * Store the swap location in the pte.
@@ -1210,6 +1218,7 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	} else
 		dec_mm_counter(mm, MM_FILEPAGES);
 
+discard:
 	page_remove_rmap(page);
 	page_cache_release(page);
 
@@ -1469,13 +1478,19 @@ static int page_not_mapped(struct page *page)
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
  * SWAP_MLOCK	- page is mlocked.
+ * SWAP_DISCARD - we succedded but no need to swap out
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
@@ -1496,8 +1511,12 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 
 	ret = rmap_walk(page, &rwc);
 
-	if (ret != SWAP_MLOCK && !page_mapped(page))
+	if (ret != SWAP_MLOCK && !page_mapped(page)) {
 		ret = SWAP_SUCCESS;
+		if (PageAnon(page) && !rp.dirtied)
+			ret = SWAP_DISCARD;
+	}
+
 	return ret;
 }
 
@@ -1519,9 +1538,13 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
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
diff --git a/mm/swap_state.c b/mm/swap_state.c
index e76ace30d436..7ddc59913952 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -189,13 +189,12 @@ int add_to_swap(struct page *page, struct list_head *list)
 	 * deadlock in the swap out path.
 	 */
 	/*
-	 * Add it to the swap cache and mark it dirty
+	 * Add it to the swap cache.
 	 */
 	err = add_to_swap_cache(page, entry,
 			__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);
 
 	if (!err) {	/* Success */
-		SetPageDirty(page);
 		return 1;
 	} else {	/* -ENOMEM radix-tree allocation failure */
 		/*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a9c74b409681..986c06b85808 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -803,6 +803,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
+		bool lazyfree = false;
 
 		cond_resched();
 
@@ -944,6 +945,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (PageAnon(page) && !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
+			/* try_to_unmap will set dirty flag */
 			if (!add_to_swap(page, page_list))
 				goto activate_locked;
 			may_enter_fs = 1;
@@ -964,6 +966,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 			case SWAP_MLOCK:
 				goto cull_mlocked;
+			case SWAP_DISCARD:
+				if (PageSwapCache(page))
+					try_to_free_swap(page);
+				if (!page_freeze_refs(page, 1))
+					goto keep_locked;
+				__clear_page_locked(page);
+				count_vm_event(PGLAZYFREED);
+				goto free_it;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -1078,6 +1088,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		__clear_page_locked(page);
 free_it:
 		nr_reclaimed++;
+		if (lazyfree)
+			count_vm_event(PGLAZYFREED);
 
 		/*
 		 * Is there need to periodically free_page_list? It would
diff --git a/mm/vmstat.c b/mm/vmstat.c
index def5dd2fbe61..2d80f7ed495d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -789,6 +789,7 @@ const char * const vmstat_text[] = {
 
 	"pgfault",
 	"pgmajfault",
+	"pglazyfreed",
 
 	TEXTS_FOR_ZONES("pgrefill")
 	TEXTS_FOR_ZONES("pgsteal_kswapd")
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
