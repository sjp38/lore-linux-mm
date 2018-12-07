Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 210606B7EB5
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 00:42:23 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i3so2410365pfj.4
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 21:42:23 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id cf16si2126256plb.227.2018.12.06.21.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 21:42:21 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V8 19/21] swap: Support PMD swap mapping in common path
Date: Fri,  7 Dec 2018 13:41:19 +0800
Message-Id: <20181207054122.27822-20-ying.huang@intel.com>
In-Reply-To: <20181207054122.27822-1-ying.huang@intel.com>
References: <20181207054122.27822-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Original code is only for PMD migration entry, it is revised to
support PMD swap mapping.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 fs/proc/task_mmu.c | 12 +++++-------
 mm/gup.c           | 36 ++++++++++++++++++++++++------------
 mm/huge_memory.c   |  7 ++++---
 mm/mempolicy.c     |  2 +-
 4 files changed, 34 insertions(+), 23 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 39e96a21366e..0e65233f2cc2 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -986,7 +986,7 @@ static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 		pmd = pmd_clear_soft_dirty(pmd);
 
 		set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
-	} else if (is_migration_entry(pmd_to_swp_entry(pmd))) {
+	} else if (is_swap_pmd(pmd)) {
 		pmd = pmd_swp_clear_soft_dirty(pmd);
 		set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
 	}
@@ -1316,9 +1316,8 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 			if (pm->show_pfn)
 				frame = pmd_pfn(pmd) +
 					((addr & ~PMD_MASK) >> PAGE_SHIFT);
-		}
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
-		else if (is_swap_pmd(pmd)) {
+		} else if (IS_ENABLED(CONFIG_HAVE_PMD_SWAP_ENTRY) &&
+			   is_swap_pmd(pmd)) {
 			swp_entry_t entry = pmd_to_swp_entry(pmd);
 			unsigned long offset;
 
@@ -1331,10 +1330,9 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 			flags |= PM_SWAP;
 			if (pmd_swp_soft_dirty(pmd))
 				flags |= PM_SOFT_DIRTY;
-			VM_BUG_ON(!is_pmd_migration_entry(pmd));
-			page = migration_entry_to_page(entry);
+			if (is_pmd_migration_entry(pmd))
+				page = migration_entry_to_page(entry);
 		}
-#endif
 
 		if (page && page_mapcount(page) == 1)
 			flags |= PM_MMAP_EXCLUSIVE;
diff --git a/mm/gup.c b/mm/gup.c
index 6dd33e16a806..460565825ef0 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -215,6 +215,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
+	swp_entry_t entry;
 
 	pmd = pmd_offset(pudp, address);
 	/*
@@ -242,18 +243,22 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 	if (!pmd_present(pmdval)) {
 		if (likely(!(flags & FOLL_MIGRATION)))
 			return no_page_table(vma, flags);
-		VM_BUG_ON(thp_migration_supported() &&
-				  !is_pmd_migration_entry(pmdval));
-		if (is_pmd_migration_entry(pmdval))
+		entry = pmd_to_swp_entry(pmdval);
+		if (thp_migration_supported() && is_migration_entry(entry)) {
 			pmd_migration_entry_wait(mm, pmd);
-		pmdval = READ_ONCE(*pmd);
-		/*
-		 * MADV_DONTNEED may convert the pmd to null because
-		 * mmap_sem is held in read mode
-		 */
-		if (pmd_none(pmdval))
+			pmdval = READ_ONCE(*pmd);
+			/*
+			 * MADV_DONTNEED may convert the pmd to null because
+			 * mmap_sem is held in read mode
+			 */
+			if (pmd_none(pmdval))
+				return no_page_table(vma, flags);
+			goto retry;
+		}
+		if (IS_ENABLED(CONFIG_THP_SWAP) && !non_swap_entry(entry))
 			return no_page_table(vma, flags);
-		goto retry;
+		WARN_ON(1);
+		return no_page_table(vma, flags);
 	}
 	if (pmd_devmap(pmdval)) {
 		ptl = pmd_lock(mm, pmd);
@@ -275,11 +280,18 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 		return no_page_table(vma, flags);
 	}
 	if (unlikely(!pmd_present(*pmd))) {
+		entry = pmd_to_swp_entry(*pmd);
 		spin_unlock(ptl);
 		if (likely(!(flags & FOLL_MIGRATION)))
 			return no_page_table(vma, flags);
-		pmd_migration_entry_wait(mm, pmd);
-		goto retry_locked;
+		if (thp_migration_supported() && is_migration_entry(entry)) {
+			pmd_migration_entry_wait(mm, pmd);
+			goto retry_locked;
+		}
+		if (IS_ENABLED(CONFIG_THP_SWAP) && !non_swap_entry(entry))
+			return no_page_table(vma, flags);
+		WARN_ON(1);
+		return no_page_table(vma, flags);
 	}
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(ptl);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5b2eb7871cd7..b75af88c505a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2138,7 +2138,7 @@ static inline int pmd_move_must_withdraw(spinlock_t *new_pmd_ptl,
 static pmd_t move_soft_dirty_pmd(pmd_t pmd)
 {
 #ifdef CONFIG_MEM_SOFT_DIRTY
-	if (unlikely(is_pmd_migration_entry(pmd)))
+	if (unlikely(is_swap_pmd(pmd)))
 		pmd = pmd_swp_mksoft_dirty(pmd);
 	else if (pmd_present(pmd))
 		pmd = pmd_mksoft_dirty(pmd);
@@ -2222,11 +2222,12 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	preserve_write = prot_numa && pmd_write(*pmd);
 	ret = 1;
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+#if defined(CONFIG_ARCH_ENABLE_THP_MIGRATION) || defined(CONFIG_THP_SWAP)
 	if (is_swap_pmd(*pmd)) {
 		swp_entry_t entry = pmd_to_swp_entry(*pmd);
 
-		VM_BUG_ON(!is_pmd_migration_entry(*pmd));
+		VM_BUG_ON(!IS_ENABLED(CONFIG_THP_SWAP) &&
+			  !is_migration_entry(entry));
 		if (is_write_migration_entry(entry)) {
 			pmd_t newpmd;
 			/*
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index e4f8248822c1..39335bf99169 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -436,7 +436,7 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
 	struct queue_pages *qp = walk->private;
 	unsigned long flags;
 
-	if (unlikely(is_pmd_migration_entry(*pmd))) {
+	if (unlikely(is_swap_pmd(*pmd))) {
 		ret = 1;
 		goto unlock;
 	}
-- 
2.18.1
