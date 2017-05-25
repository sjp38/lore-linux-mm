Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 023CD6B0315
	for <linux-mm@kvack.org>; Thu, 25 May 2017 10:20:03 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v195so82457356qka.1
        for <linux-mm@kvack.org>; Thu, 25 May 2017 07:20:02 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id u10si3209411qta.278.2017.05.25.07.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 07:19:55 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v6 06/10] mm: thp: check pmd migration entry in common path
Date: Thu, 25 May 2017 10:19:41 -0400
Message-Id: <20170525141945.56028-7-zi.yan@sent.com>
In-Reply-To: <20170525141945.56028-1-zi.yan@sent.com>
References: <20170525141945.56028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com

From: Zi Yan <zi.yan@cs.rutgers.edu>

If one of callers of page migration starts to handle thp,
memory management code start to see pmd migration entry, so we need
to prepare for it before enabling. This patch changes various code
point which checks the status of given pmds in order to prevent race
between thp migration and the pmd-related works.

ChangeLog v1 -> v2:
- introduce pmd_related() (I know the naming is not good, but can't
  think up no better name. Any suggesntion is welcomed.)

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

ChangeLog v2 -> v3:
- add is_swap_pmd()
- a pmd entry should be pmd pointing to pte pages, is_swap_pmd(),
  pmd_trans_huge(), pmd_devmap(), or pmd_none()
- pmd_none_or_trans_huge_or_clear_bad() and pmd_trans_unstable() return
  true on pmd_migration_entry, so that migration entries are not
  treated as pmd page table entries.

ChangeLog v4 -> v5:
- add explanation in pmd_none_or_trans_huge_or_clear_bad() to state
  the equivalence of !pmd_present() and is_pmd_migration_entry()
- fix migration entry wait deadlock code (from v1) in follow_page_mask()
- remove unnecessary code (from v1) in follow_trans_huge_pmd()
- use is_swap_pmd() instead of !pmd_present() for pmd migration entry,
  so it will not be confused with pmd_none()
- change author information

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 arch/x86/mm/gup.c             |  7 +++--
 fs/proc/task_mmu.c            | 30 +++++++++++++--------
 include/asm-generic/pgtable.h | 17 +++++++++++-
 include/linux/huge_mm.h       | 14 ++++++++--
 mm/gup.c                      | 22 ++++++++++++++--
 mm/huge_memory.c              | 61 ++++++++++++++++++++++++++++++++++++++-----
 mm/memcontrol.c               |  5 ++++
 mm/memory.c                   | 12 +++++++--
 mm/mprotect.c                 |  4 +--
 mm/mremap.c                   |  2 +-
 10 files changed, 145 insertions(+), 29 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 456dfdfd2249..096bbcc801e6 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -9,6 +9,7 @@
 #include <linux/vmstat.h>
 #include <linux/highmem.h>
 #include <linux/swap.h>
+#include <linux/swapops.h>
 #include <linux/memremap.h>
 
 #include <asm/mmu_context.h>
@@ -243,9 +244,11 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		pmd_t pmd = *pmdp;
 
 		next = pmd_addr_end(addr, end);
-		if (pmd_none(pmd))
+		if (!pmd_present(pmd)) {
+			VM_BUG_ON(is_swap_pmd(pmd) && IS_ENABLED(CONFIG_MIGRATION) &&
+					  !is_pmd_migration_entry(pmd));
 			return 0;
-		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
+		} else if (unlikely(pmd_large(pmd))) {
 			/*
 			 * NUMA hinting faults need to be handled in the GUP
 			 * slowpath for accounting purposes and so that they
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f0c8b33d99b1..86ea6e400e8f 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -601,7 +601,8 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
-		smaps_pmd_entry(pmd, addr, walk);
+		if (pmd_present(*pmd))
+			smaps_pmd_entry(pmd, addr, walk);
 		spin_unlock(ptl);
 		return 0;
 	}
@@ -943,6 +944,9 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 			goto out;
 		}
 
+		if (!pmd_present(*pmd))
+			goto out;
+
 		page = pmd_page(*pmd);
 
 		/* Clear accessed and referenced bits. */
@@ -1222,28 +1226,32 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 	if (ptl) {
 		u64 flags = 0, frame = 0;
 		pmd_t pmd = *pmdp;
+		struct page *page = NULL;
 
 		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(pmd))
 			flags |= PM_SOFT_DIRTY;
 
-		/*
-		 * Currently pmd for thp is always present because thp
-		 * can not be swapped-out, migrated, or HWPOISONed
-		 * (split in such cases instead.)
-		 * This if-check is just to prepare for future implementation.
-		 */
 		if (pmd_present(pmd)) {
-			struct page *page = pmd_page(pmd);
-
-			if (page_mapcount(page) == 1)
-				flags |= PM_MMAP_EXCLUSIVE;
+			page = pmd_page(pmd);
 
 			flags |= PM_PRESENT;
 			if (pm->show_pfn)
 				frame = pmd_pfn(pmd) +
 					((addr & ~PMD_MASK) >> PAGE_SHIFT);
+		} else if (is_swap_pmd(pmd)) {
+			swp_entry_t entry = pmd_to_swp_entry(pmd);
+
+			frame = swp_type(entry) |
+				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
+			flags |= PM_SWAP;
+			VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
+					  !is_pmd_migration_entry(pmd));
+			page = migration_entry_to_page(entry);
 		}
 
+		if (page && page_mapcount(page) == 1)
+			flags |= PM_MMAP_EXCLUSIVE;
+
 		for (; addr != end; addr += PAGE_SIZE) {
 			pagemap_entry_t pme = make_pme(frame, flags);
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 7dfa767dc680..88119351fecc 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -834,7 +834,22 @@ static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	barrier();
 #endif
-	if (pmd_none(pmdval) || pmd_trans_huge(pmdval))
+	/*
+	 * !pmd_present() checks for pmd migration entries
+	 *
+	 * The complete check uses is_pmd_migration_entry() in linux/swapops.h
+	 * But using that requires moving current function and pmd_trans_unstable()
+	 * to linux/swapops.h to resovle dependency, which is too much code move.
+	 *
+	 * !pmd_present() is equivalent to is_pmd_migration_entry() currently,
+	 * because !pmd_present() pages can only be under migration not swapped
+	 * out.
+	 *
+	 * pmd_none() is preseved for future condition checks on pmd migration
+	 * entries and not confusing with this function name, although it is
+	 * redundant with !pmd_present().
+	 */
+	if (pmd_none(pmdval) || pmd_trans_huge(pmdval) || !pmd_present(pmdval))
 		return 1;
 	if (unlikely(pmd_bad(pmdval))) {
 		pmd_clear_bad(pmd);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 93635a6e32b0..d89d9f9b5634 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -127,7 +127,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 #define split_huge_pmd(__vma, __pmd, __address)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
-		if (pmd_trans_huge(*____pmd)				\
+		if (is_swap_pmd(*____pmd) || pmd_trans_huge(*____pmd)	\
 					|| pmd_devmap(*____pmd))	\
 			__split_huge_pmd(__vma, __pmd, __address,	\
 						false, NULL);		\
@@ -158,12 +158,18 @@ extern spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd,
 		struct vm_area_struct *vma);
 extern spinlock_t *__pud_trans_huge_lock(pud_t *pud,
 		struct vm_area_struct *vma);
+
+static inline int is_swap_pmd(pmd_t pmd)
+{
+	return !pmd_none(pmd) && !pmd_present(pmd);
+}
+
 /* mmap_sem must be held on entry */
 static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 		struct vm_area_struct *vma)
 {
 	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
-	if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
+	if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
 		return __pmd_trans_huge_lock(pmd, vma);
 	else
 		return NULL;
@@ -276,6 +282,10 @@ static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
 					 long adjust_next)
 {
 }
+static inline int is_swap_pmd(pmd_t pmd)
+{
+	return 0;
+}
 static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 		struct vm_area_struct *vma)
 {
diff --git a/mm/gup.c b/mm/gup.c
index d97aada92b90..f8fac2afb16c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -234,6 +234,16 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 			return page;
 		return no_page_table(vma, flags);
 	}
+retry:
+	if (!pmd_present(*pmd)) {
+		if (likely(!(flags & FOLL_MIGRATION)))
+			return no_page_table(vma, flags);
+		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
+				  !is_pmd_migration_entry(*pmd));
+		if (is_pmd_migration_entry(*pmd))
+			pmd_migration_entry_wait(mm, pmd);
+		goto retry;
+	}
 	if (pmd_devmap(*pmd)) {
 		ptl = pmd_lock(mm, pmd);
 		page = follow_devmap_pmd(vma, address, pmd, flags);
@@ -247,7 +257,15 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
 		return no_page_table(vma, flags);
 
+retry_locked:
 	ptl = pmd_lock(mm, pmd);
+	if (unlikely(!pmd_present(*pmd))) {
+		spin_unlock(ptl);
+		if (likely(!(flags & FOLL_MIGRATION)))
+			return no_page_table(vma, flags);
+		pmd_migration_entry_wait(mm, pmd);
+		goto retry_locked;
+	}
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(ptl);
 		return follow_page_pte(vma, address, pmd, flags);
@@ -424,7 +442,7 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 	pud = pud_offset(p4d, address);
 	BUG_ON(pud_none(*pud));
 	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd))
+	if (!pmd_present(*pmd))
 		return -EFAULT;
 	VM_BUG_ON(pmd_trans_huge(*pmd));
 	pte = pte_offset_map(pmd, address);
@@ -1546,7 +1564,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		pmd_t pmd = READ_ONCE(*pmdp);
 
 		next = pmd_addr_end(addr, end);
-		if (pmd_none(pmd))
+		if (!pmd_present(pmd))
 			return 0;
 
 		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 05d8288c3eea..04e12b2929a0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -914,6 +914,22 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	ret = -EAGAIN;
 	pmd = *src_pmd;
+
+	if (unlikely(is_swap_pmd(pmd))) {
+		swp_entry_t entry = pmd_to_swp_entry(pmd);
+
+		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
+				  !is_pmd_migration_entry(pmd));
+		if (is_write_migration_entry(entry)) {
+			make_migration_entry_read(&entry);
+			pmd = swp_entry_to_pmd(entry);
+			set_pmd_at(src_mm, addr, src_pmd, pmd);
+		}
+		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
+		ret = 0;
+		goto out_unlock;
+	}
+
 	if (unlikely(!pmd_trans_huge(pmd))) {
 		pte_free(dst_mm, pgtable);
 		goto out_unlock;
@@ -1220,6 +1236,9 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
 		goto out_unlock;
 
+	if (unlikely(!pmd_present(orig_pmd)))
+		goto out_unlock;
+
 	page = pmd_page(orig_pmd);
 	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
 	/*
@@ -1550,6 +1569,12 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	if (is_huge_zero_pmd(orig_pmd))
 		goto out;
 
+	if (unlikely(!pmd_present(orig_pmd))) {
+		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
+				  !is_pmd_migration_entry(orig_pmd));
+		goto out;
+	}
+
 	page = pmd_page(orig_pmd);
 	/*
 	 * If other processes are mapping this page, we couldn't discard
@@ -1760,6 +1785,21 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	preserve_write = prot_numa && pmd_write(*pmd);
 	ret = 1;
 
+	if (is_swap_pmd(*pmd)) {
+		swp_entry_t entry = pmd_to_swp_entry(*pmd);
+
+		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
+				  !is_pmd_migration_entry(*pmd));
+		if (is_write_migration_entry(entry)) {
+			pmd_t newpmd;
+
+			make_migration_entry_read(&entry);
+			newpmd = swp_entry_to_pmd(entry);
+			set_pmd_at(mm, addr, pmd, newpmd);
+		}
+		goto unlock;
+	}
+
 	/*
 	 * Avoid trapping faults against the zero page. The read-only
 	 * data is likely to be read-cached on the local CPU and
@@ -1825,7 +1865,8 @@ spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
 {
 	spinlock_t *ptl;
 	ptl = pmd_lock(vma->vm_mm, pmd);
-	if (likely(pmd_trans_huge(*pmd) || pmd_devmap(*pmd)))
+	if (likely(is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) ||
+			pmd_devmap(*pmd)))
 		return ptl;
 	spin_unlock(ptl);
 	return NULL;
@@ -1943,14 +1984,15 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	struct page *page;
 	pgtable_t pgtable;
 	pmd_t _pmd;
-	bool young, write, dirty, soft_dirty;
+	bool young, write, dirty, soft_dirty, pmd_migration;
 	unsigned long addr;
 	int i;
 
 	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
 	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
 	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
-	VM_BUG_ON(!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd));
+	VM_BUG_ON(!is_pmd_migration_entry(*pmd) && !pmd_trans_huge(*pmd)
+				&& !pmd_devmap(*pmd));
 
 	count_vm_event(THP_SPLIT_PMD);
 
@@ -1975,7 +2017,14 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		return __split_huge_zero_page_pmd(vma, haddr, pmd);
 	}
 
-	page = pmd_page(*pmd);
+	pmd_migration = is_pmd_migration_entry(*pmd);
+	if (pmd_migration) {
+		swp_entry_t entry;
+
+		entry = pmd_to_swp_entry(*pmd);
+		page = pfn_to_page(swp_offset(entry));
+	} else
+		page = pmd_page(*pmd);
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	page_ref_add(page, HPAGE_PMD_NR - 1);
 	write = pmd_write(*pmd);
@@ -1994,7 +2043,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		 * transferred to avoid any possibility of altering
 		 * permissions across VMAs.
 		 */
-		if (freeze) {
+		if (freeze || pmd_migration) {
 			swp_entry_t swp_entry;
 			swp_entry = make_migration_entry(page + i, write);
 			entry = swp_entry_to_pte(swp_entry);
@@ -2093,7 +2142,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		page = pmd_page(*pmd);
 		if (PageMlocked(page))
 			clear_page_mlock(page);
-	} else if (!pmd_devmap(*pmd))
+	} else if (!(pmd_devmap(*pmd) || is_pmd_migration_entry(*pmd)))
 		goto out;
 	__split_huge_pmd_locked(vma, pmd, haddr, freeze);
 out:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c131f7e5ecd1..780ce3621a9b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4628,6 +4628,11 @@ static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
 	struct page *page = NULL;
 	enum mc_target_type ret = MC_TARGET_NONE;
 
+	if (unlikely(is_swap_pmd(pmd))) {
+		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
+				  !is_pmd_migration_entry(pmd));
+		return ret;
+	}
 	page = pmd_page(pmd);
 	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
 	if (!(mc.flags & MOVE_ANON))
diff --git a/mm/memory.c b/mm/memory.c
index d0fa5a215da9..efc2f712cb27 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1036,7 +1036,8 @@ static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src
 	src_pmd = pmd_offset(src_pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
-		if (pmd_trans_huge(*src_pmd) || pmd_devmap(*src_pmd)) {
+		if (is_swap_pmd(*src_pmd) || pmd_trans_huge(*src_pmd)
+			|| pmd_devmap(*src_pmd)) {
 			int err;
 			VM_BUG_ON_VMA(next-addr != HPAGE_PMD_SIZE, vma);
 			err = copy_huge_pmd(dst_mm, src_mm,
@@ -1296,7 +1297,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
-		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
+		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
 				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
 				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
@@ -3822,6 +3823,13 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		pmd_t orig_pmd = *vmf.pmd;
 
 		barrier();
+		if (unlikely(is_swap_pmd(orig_pmd))) {
+			VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
+					  !is_pmd_migration_entry(orig_pmd));
+			if (is_pmd_migration_entry(orig_pmd))
+				pmd_migration_entry_wait(mm, vmf.pmd);
+			return 0;
+		}
 		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
 			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
 				return do_huge_pmd_numa_page(&vmf, orig_pmd);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 1a8c9ca83e48..d60a1eedcc54 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -148,7 +148,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		unsigned long this_pages;
 
 		next = pmd_addr_end(addr, end);
-		if (!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)
+		if (!is_swap_pmd(*pmd) && !pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)
 				&& pmd_none_or_clear_bad(pmd))
 			continue;
 
@@ -158,7 +158,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 			mmu_notifier_invalidate_range_start(mm, mni_start, end);
 		}
 
-		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
+		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
 				__split_huge_pmd(vma, pmd, addr, false, NULL);
 			} else {
diff --git a/mm/mremap.c b/mm/mremap.c
index cd8a1b199ef9..1c49b9fb994a 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -222,7 +222,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 		new_pmd = alloc_new_pmd(vma->vm_mm, vma, new_addr);
 		if (!new_pmd)
 			break;
-		if (pmd_trans_huge(*old_pmd)) {
+		if (is_swap_pmd(*old_pmd) || pmd_trans_huge(*old_pmd)) {
 			if (extent == HPAGE_PMD_SIZE) {
 				bool moved;
 				/* See comment in move_ptes() */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
