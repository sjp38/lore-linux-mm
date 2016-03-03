Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 35A086B0258
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:42:20 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fi3so8280820pac.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:20 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id y67si9857107pfi.213.2016.03.02.23.42.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:42:19 -0800 (PST)
Received: by mail-pa0-x22f.google.com with SMTP id fy10so10115857pac.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:19 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 05/11] mm: thp: check pmd migration entry in common path
Date: Thu,  3 Mar 2016 16:41:52 +0900
Message-Id: <1456990918-30906-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

If one of callers of page migration starts to handle thp, memory management code
start to see pmd migration entry, so we need to prepare for it before enabling.
This patch changes various code point which checks the status of given pmds in
order to prevent race between thp migration and the pmd-related works.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/x86/mm/gup.c  |  3 +++
 fs/proc/task_mmu.c | 25 +++++++++++++--------
 mm/gup.c           |  8 +++++++
 mm/huge_memory.c   | 66 ++++++++++++++++++++++++++++++++++++++++++++++++------
 mm/memcontrol.c    |  2 ++
 mm/memory.c        |  5 +++++
 6 files changed, 93 insertions(+), 16 deletions(-)

diff --git v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/mm/gup.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/mm/gup.c
index f8d0b5e..34c3d43 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/arch/x86/mm/gup.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/arch/x86/mm/gup.c
@@ -10,6 +10,7 @@
 #include <linux/highmem.h>
 #include <linux/swap.h>
 #include <linux/memremap.h>
+#include <linux/swapops.h>
 
 #include <asm/pgtable.h>
 
@@ -210,6 +211,8 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		if (pmd_none(pmd))
 			return 0;
 		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
+			if (unlikely(is_pmd_migration_entry(pmd)))
+				return 0;
 			/*
 			 * NUMA hinting faults need to be handled in the GUP
 			 * slowpath for accounting purposes and so that they
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/fs/proc/task_mmu.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/fs/proc/task_mmu.c
index fa95ab2..20205d4 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/fs/proc/task_mmu.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/fs/proc/task_mmu.c
@@ -907,6 +907,9 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
+		if (unlikely(is_pmd_migration_entry(*pmd)))
+			goto out;
+
 		if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
 			clear_soft_dirty_pmd(vma, addr, pmd);
 			goto out;
@@ -1184,19 +1187,18 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 	if (ptl) {
 		u64 flags = 0, frame = 0;
 		pmd_t pmd = *pmdp;
+		struct page *page;
 
 		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(pmd))
 			flags |= PM_SOFT_DIRTY;
 
-		/*
-		 * Currently pmd for thp is always present because thp
-		 * can not be swapped-out, migrated, or HWPOISONed
-		 * (split in such cases instead.)
-		 * This if-check is just to prepare for future implementation.
-		 */
-		if (pmd_present(pmd)) {
-			struct page *page = pmd_page(pmd);
-
+		if (is_pmd_migration_entry(pmd)) {
+			swp_entry_t entry = pmd_to_swp_entry(pmd);
+			frame = swp_type(entry) |
+				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
+			page = migration_entry_to_page(entry);
+		} else if (pmd_present(pmd)) {
+			page = pmd_page(pmd);
 			if (page_mapcount(page) == 1)
 				flags |= PM_MMAP_EXCLUSIVE;
 
@@ -1518,6 +1520,11 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 		pte_t huge_pte = *(pte_t *)pmd;
 		struct page *page;
 
+		if (unlikely(is_pmd_migration_entry(*pmd))) {
+			spin_unlock(ptl);
+			return 0;
+		}
+
 		page = can_gather_numa_stats(huge_pte, vma, addr);
 		if (page)
 			gather_stats(page, md, pte_dirty(huge_pte),
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/gup.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/gup.c
index 36ca850..113930b 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/gup.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/gup.c
@@ -271,6 +271,11 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 		spin_unlock(ptl);
 		return follow_page_pte(vma, address, pmd, flags);
 	}
+	if (is_pmd_migration_entry(*pmd)) {
+		spin_unlock(ptl);
+		return no_page_table(vma, flags);
+	}
+
 	if (flags & FOLL_SPLIT) {
 		int ret;
 		page = pmd_page(*pmd);
@@ -1324,6 +1329,9 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 			return 0;
 
 		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
+			if (unlikely(is_pmd_migration_entry(pmd)))
+				return 0;
+
 			/*
 			 * NUMA hinting faults need to be handled in the GUP
 			 * slowpath for accounting purposes and so that they
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/huge_memory.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/huge_memory.c
index c6d5406..7120036 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/huge_memory.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/huge_memory.c
@@ -1107,6 +1107,19 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		goto out_unlock;
 	}
 
+	if (unlikely(is_pmd_migration_entry(pmd))) {
+		swp_entry_t entry = pmd_to_swp_entry(pmd);
+
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
 	if (!vma_is_dax(vma)) {
 		/* thp accounting separate from pmd_devmap accounting */
 		src_page = pmd_page(pmd);
@@ -1284,6 +1297,9 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_unlock;
 
+	if (unlikely(is_pmd_migration_entry(*pmd)))
+		goto out_unlock;
+
 	page = pmd_page(orig_pmd);
 	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
 	/*
@@ -1418,7 +1434,14 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
 		goto out;
 
-	page = pmd_page(*pmd);
+	if (is_pmd_migration_entry(*pmd)) {
+		swp_entry_t entry;
+		entry = pmd_to_swp_entry(*pmd);
+		page = pfn_to_page(swp_offset(entry));
+		if (!is_migration_entry(entry))
+			goto out;
+	} else
+		page = pmd_page(*pmd);
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	if (flags & FOLL_TOUCH)
 		touch_pmd(vma, addr, pmd);
@@ -1601,6 +1624,9 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		goto out;
 	}
 
+	if (unlikely(is_pmd_migration_entry(orig_pmd)))
+		goto out;
+
 	page = pmd_page(orig_pmd);
 	/*
 	 * If other processes are mapping this page, we couldn't discard
@@ -1681,15 +1707,28 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		spin_unlock(ptl);
 		put_huge_zero_page();
 	} else {
-		struct page *page = pmd_page(orig_pmd);
-		page_remove_rmap(page, true);
-		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
-		add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
-		VM_BUG_ON_PAGE(!PageHead(page), page);
+		struct page *page;
+		int migration = 0;
+
+		if (!is_pmd_migration_entry(orig_pmd)) {
+			page = pmd_page(orig_pmd);
+			page_remove_rmap(page, true);
+			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
+			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+			VM_BUG_ON_PAGE(!PageHead(page), page);
+		} else {
+			swp_entry_t entry;
+
+			entry = pmd_to_swp_entry(orig_pmd);
+			free_swap_and_cache(entry); /* waring in failure? */
+			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+			migration = 1;
+		}
 		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
 		atomic_long_dec(&tlb->mm->nr_ptes);
 		spin_unlock(ptl);
-		tlb_remove_page(tlb, page);
+		if (!migration)
+			tlb_remove_page(tlb, page);
 	}
 	return 1;
 }
@@ -1775,6 +1814,11 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			return ret;
 		}
 
+		if (is_pmd_migration_entry(*pmd)) {
+			spin_unlock(ptl);
+			return ret;
+		}
+
 		if (!prot_numa || !pmd_protnone(*pmd)) {
 			entry = pmdp_huge_get_and_clear_notify(mm, addr, pmd);
 			entry = pmd_modify(entry, newprot);
@@ -3071,6 +3115,9 @@ static void split_huge_pmd_address(struct vm_area_struct *vma,
 	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd) || (!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)))
 		return;
+	if (pmd_trans_huge(*pmd) && is_pmd_migration_entry(*pmd))
+		return;
+
 	/*
 	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
 	 * materialize from under us.
@@ -3151,6 +3198,11 @@ static void freeze_page_vma(struct vm_area_struct *vma, struct page *page,
 		return;
 	}
 	if (pmd_trans_huge(*pmd)) {
+		if (is_pmd_migration_entry(*pmd)) {
+			spin_unlock(ptl);
+			return;
+		}
+
 		if (page == pmd_page(*pmd))
 			__split_huge_pmd_locked(vma, pmd, haddr, true);
 		spin_unlock(ptl);
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/memcontrol.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/memcontrol.c
index ae8b81c..1772043 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/memcontrol.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/memcontrol.c
@@ -4548,6 +4548,8 @@ static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
 	struct page *page = NULL;
 	enum mc_target_type ret = MC_TARGET_NONE;
 
+	if (unlikely(is_pmd_migration_entry(pmd)))
+		return ret;
 	page = pmd_page(pmd);
 	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
 	if (!(mc.flags & MOVE_ANON))
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/memory.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/memory.c
index 6c92a99..a04a685 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/memory.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/memory.c
@@ -3405,6 +3405,11 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
 			unsigned int dirty = flags & FAULT_FLAG_WRITE;
 
+			if (unlikely(is_pmd_migration_entry(orig_pmd))) {
+				pmd_migration_entry_wait(mm, pmd);
+				return 0;
+			}
+
 			if (pmd_protnone(orig_pmd))
 				return do_huge_pmd_numa_page(mm, vma, address,
 							     orig_pmd, pmd);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
