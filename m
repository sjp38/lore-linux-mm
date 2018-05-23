Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3976B027A
	for <linux-mm@kvack.org>; Wed, 23 May 2018 04:27:34 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t5-v6so13860367ply.13
        for <linux-mm@kvack.org>; Wed, 23 May 2018 01:27:34 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p7-v6si14354610pga.473.2018.05.23.01.27.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 01:27:33 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V3 19/21] mm, THP, swap: Support PMD swap mapping in common path
Date: Wed, 23 May 2018 16:26:23 +0800
Message-Id: <20180523082625.6897-20-ying.huang@intel.com>
In-Reply-To: <20180523082625.6897-1-ying.huang@intel.com>
References: <20180523082625.6897-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

Original code is only for PMD migration entry, it is revised to
support PMD swap mapping.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
---
 fs/proc/task_mmu.c |  8 ++++----
 mm/gup.c           | 34 ++++++++++++++++++++++------------
 mm/huge_memory.c   |  6 +++---
 mm/mempolicy.c     |  2 +-
 4 files changed, 30 insertions(+), 20 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 597969db9e90..ddb6a2832f86 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -978,7 +978,7 @@ static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 		pmd = pmd_clear_soft_dirty(pmd);
 
 		set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
-	} else if (is_migration_entry(pmd_to_swp_entry(pmd))) {
+	} else if (is_swap_pmd(pmd)) {
 		pmd = pmd_swp_clear_soft_dirty(pmd);
 		set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
 	}
@@ -1309,7 +1309,7 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 				frame = pmd_pfn(pmd) +
 					((addr & ~PMD_MASK) >> PAGE_SHIFT);
 		}
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+#if defined(CONFIG_ARCH_ENABLE_THP_MIGRATION) || defined(CONFIG_THP_SWAP)
 		else if (is_swap_pmd(pmd)) {
 			swp_entry_t entry = pmd_to_swp_entry(pmd);
 			unsigned long offset;
@@ -1323,8 +1323,8 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 			flags |= PM_SWAP;
 			if (pmd_swp_soft_dirty(pmd))
 				flags |= PM_SOFT_DIRTY;
-			VM_BUG_ON(!is_pmd_migration_entry(pmd));
-			page = migration_entry_to_page(entry);
+			if (is_pmd_migration_entry(pmd))
+				page = migration_entry_to_page(entry);
 		}
 #endif
 
diff --git a/mm/gup.c b/mm/gup.c
index b70d7ba7cc13..84ba4ad8120d 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -216,6 +216,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
+	swp_entry_t entry;
 
 	pmd = pmd_offset(pudp, address);
 	/*
@@ -243,18 +244,21 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
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
+		if (thp_swap_supported() && !non_swap_entry(entry))
 			return no_page_table(vma, flags);
-		goto retry;
+		VM_BUG_ON(1);
 	}
 	if (pmd_devmap(pmdval)) {
 		ptl = pmd_lock(mm, pmd);
@@ -276,11 +280,17 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
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
+		if (thp_swap_supported() && !non_swap_entry(entry))
+			return no_page_table(vma, flags);
+		VM_BUG_ON(1);
 	}
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(ptl);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e057b966ea68..e80d03c2412a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2074,7 +2074,7 @@ static inline int pmd_move_must_withdraw(spinlock_t *new_pmd_ptl,
 static pmd_t move_soft_dirty_pmd(pmd_t pmd)
 {
 #ifdef CONFIG_MEM_SOFT_DIRTY
-	if (unlikely(is_pmd_migration_entry(pmd)))
+	if (unlikely(is_swap_pmd(pmd)))
 		pmd = pmd_swp_mksoft_dirty(pmd);
 	else if (pmd_present(pmd))
 		pmd = pmd_mksoft_dirty(pmd);
@@ -2160,11 +2160,11 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	preserve_write = prot_numa && pmd_write(*pmd);
 	ret = 1;
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+#if defined(CONFIG_ARCH_ENABLE_THP_MIGRATION) || defined(CONFIG_THP_SWAP)
 	if (is_swap_pmd(*pmd)) {
 		swp_entry_t entry = pmd_to_swp_entry(*pmd);
 
-		VM_BUG_ON(!is_pmd_migration_entry(*pmd));
+		VM_BUG_ON(!thp_swap_supported() && !is_migration_entry(entry));
 		if (is_write_migration_entry(entry)) {
 			pmd_t newpmd;
 			/*
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9ac49ef17b4e..180d7c08f6cc 100644
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
2.16.1
