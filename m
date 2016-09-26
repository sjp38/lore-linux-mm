Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D40D6B02A9
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:24:10 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y10so305651602qty.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:24:10 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id a141si14796705qkg.200.2016.09.26.08.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:24:09 -0700 (PDT)
From: zi.yan@sent.com
Subject: [PATCH v1 05/12] mm: thp: check pmd migration entry in common path
Date: Mon, 26 Sep 2016 11:22:27 -0400
Message-Id: <20160926152234.14809-6-zi.yan@sent.com>
In-Reply-To: <20160926152234.14809-1-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <zi.yan@cs.rutgers.edu>

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

If one of callers of page migration starts to handle thp, memory management code
start to see pmd migration entry, so we need to prepare for it before enabling.
This patch changes various code point which checks the status of given pmds in
order to prevent race between thp migration and the pmd-related works.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 arch/x86/mm/gup.c  |  3 +++
 fs/proc/task_mmu.c | 20 +++++++-------
 mm/gup.c           |  8 ++++++
 mm/huge_memory.c   | 76 +++++++++++++++++++++++++++++++++++++++++++++++-------
 mm/memcontrol.c    |  2 ++
 mm/memory.c        |  5 ++++
 6 files changed, 95 insertions(+), 19 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index b8b6a60..72d0bef 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -10,6 +10,7 @@
 #include <linux/highmem.h>
 #include <linux/swap.h>
 #include <linux/memremap.h>
+#include <linux/swapops.h>
 
 #include <asm/mmu_context.h>
 #include <asm/pgtable.h>
@@ -225,6 +226,8 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		if (pmd_none(pmd))
 			return 0;
 		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
+			if (unlikely(is_pmd_migration_entry(pmd)))
+				return 0;
 			/*
 			 * NUMA hinting faults need to be handled in the GUP
 			 * slowpath for accounting purposes and so that they
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f6fa99e..60f6ce3 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -931,6 +931,9 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
+		if (unlikely(is_pmd_migration_entry(*pmd)))
+			goto out;
+
 		if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
 			clear_soft_dirty_pmd(vma, addr, pmd);
 			goto out;
@@ -1215,19 +1218,18 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
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
 
diff --git a/mm/gup.c b/mm/gup.c
index 96b2b2f..ef56be2 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -272,6 +272,11 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
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
@@ -1362,6 +1367,9 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 			return 0;
 
 		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
+			if (unlikely(is_pmd_migration_entry(pmd)))
+				return 0;
+
 			/*
 			 * NUMA hinting faults need to be handled in the GUP
 			 * slowpath for accounting purposes and so that they
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0cd39ef..f4fcfc7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -787,6 +787,19 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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
 	src_page = pmd_page(pmd);
 	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
 	get_page(src_page);
@@ -952,6 +965,9 @@ int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd)
 	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
 		goto out_unlock;
 
+	if (unlikely(is_pmd_migration_entry(*fe->pmd)))
+		goto out_unlock;
+
 	page = pmd_page(orig_pmd);
 	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
 	/*
@@ -1077,7 +1093,15 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
 		goto out;
 
-	page = pmd_page(*pmd);
+	if (is_pmd_migration_entry(*pmd)) {
+		swp_entry_t entry;
+		entry = pmd_to_swp_entry(*pmd);
+		if (!is_migration_entry(entry))
+			goto out;
+		page = pfn_to_page(swp_offset(entry));
+	} else
+		page = pmd_page(*pmd);
+
 	VM_BUG_ON_PAGE(!PageHead(page) && !is_zone_device_page(page), page);
 	if (flags & FOLL_TOUCH)
 		touch_pmd(vma, addr, pmd);
@@ -1273,6 +1297,9 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	if (is_huge_zero_pmd(orig_pmd))
 		goto out;
 
+	if (unlikely(is_pmd_migration_entry(orig_pmd)))
+		goto out;
+
 	page = pmd_page(orig_pmd);
 	/*
 	 * If other processes are mapping this page, we couldn't discard
@@ -1348,21 +1375,40 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		spin_unlock(ptl);
 		tlb_remove_page(tlb, pmd_page(orig_pmd));
 	} else {
-		struct page *page = pmd_page(orig_pmd);
-		page_remove_rmap(page, true);
-		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
-		VM_BUG_ON_PAGE(!PageHead(page), page);
-		if (PageAnon(page)) {
+		struct page *page;
+		int migration = 0;
+
+		if (!is_pmd_migration_entry(orig_pmd)) {
+			page = pmd_page(orig_pmd);
+			page_remove_rmap(page, true);
+			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
+			VM_BUG_ON_PAGE(!PageHead(page), page);
+			if (PageAnon(page)) {
+				pgtable_t pgtable;
+				pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
+				pte_free(tlb->mm, pgtable);
+				atomic_long_dec(&tlb->mm->nr_ptes);
+				add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+			} else {
+				add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
+			}
+		} else {
+			swp_entry_t entry;
 			pgtable_t pgtable;
+
+			entry = pmd_to_swp_entry(orig_pmd);
+			free_swap_and_cache(entry); /* waring in failure? */
+
+			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 			pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
 			pte_free(tlb->mm, pgtable);
 			atomic_long_dec(&tlb->mm->nr_ptes);
-			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
-		} else {
-			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
+
+			migration = 1;
 		}
 		spin_unlock(ptl);
-		tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
+		if (!migration)
+			tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
 	}
 	return 1;
 }
@@ -1445,6 +1491,11 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
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
@@ -1656,6 +1707,11 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (pmd_trans_huge(*pmd)) {
 		page = pmd_page(*pmd);
+
+		if (is_pmd_migration_entry(*pmd)) {
+			goto out;
+		}
+
 		if (PageMlocked(page))
 			clear_page_mlock(page);
 	} else if (!pmd_devmap(*pmd))
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4be518d..421ac4ff 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4649,6 +4649,8 @@ static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
 	struct page *page = NULL;
 	enum mc_target_type ret = MC_TARGET_NONE;
 
+	if (unlikely(is_pmd_migration_entry(pmd)))
+		return ret;
 	page = pmd_page(pmd);
 	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
 	if (!(mc.flags & MOVE_ANON))
diff --git a/mm/memory.c b/mm/memory.c
index 83be99d..3ad3bb2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3590,6 +3590,11 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 
 		barrier();
 		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
+			if (unlikely(is_pmd_migration_entry(orig_pmd))) {
+				pmd_migration_entry_wait(mm, fe.pmd);
+				return 0;
+			}
+
 			if (pmd_protnone(orig_pmd))
 				return do_huge_pmd_numa_page(&fe, orig_pmd);
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
