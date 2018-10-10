Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7551A6B0276
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 03:27:43 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a64-v6so3893655pfg.16
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 00:27:43 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id n84-v6si21364295pfg.127.2018.10.10.00.27.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 00:27:42 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V6 15/21] swap: Support to copy PMD swap mapping when fork()
Date: Wed, 10 Oct 2018 15:19:18 +0800
Message-Id: <20181010071924.18767-16-ying.huang@intel.com>
In-Reply-To: <20181010071924.18767-1-ying.huang@intel.com>
References: <20181010071924.18767-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

During fork, the page table need to be copied from parent to child.  A
PMD swap mapping need to be copied too and the swap reference count
need to be increased.

When the huge swap cluster has been split already, we need to split
the PMD swap mapping and fallback to PTE copying.

When swap count continuation failed to allocate a page with
GFP_ATOMIC, we need to unlock the spinlock and try again with
GFP_KERNEL.

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
 mm/huge_memory.c | 72 ++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 57 insertions(+), 15 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ebd043528309..74c8621619cb 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -987,6 +987,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	if (unlikely(!pgtable))
 		goto out;
 
+retry:
 	dst_ptl = pmd_lock(dst_mm, dst_pmd);
 	src_ptl = pmd_lockptr(src_mm, src_pmd);
 	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
@@ -994,26 +995,67 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	ret = -EAGAIN;
 	pmd = *src_pmd;
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 	if (unlikely(is_swap_pmd(pmd))) {
 		swp_entry_t entry = pmd_to_swp_entry(pmd);
 
-		VM_BUG_ON(!is_pmd_migration_entry(pmd));
-		if (is_write_migration_entry(entry)) {
-			make_migration_entry_read(&entry);
-			pmd = swp_entry_to_pmd(entry);
-			if (pmd_swp_soft_dirty(*src_pmd))
-				pmd = pmd_swp_mksoft_dirty(pmd);
-			set_pmd_at(src_mm, addr, src_pmd, pmd);
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+		if (is_migration_entry(entry)) {
+			if (is_write_migration_entry(entry)) {
+				make_migration_entry_read(&entry);
+				pmd = swp_entry_to_pmd(entry);
+				if (pmd_swp_soft_dirty(*src_pmd))
+					pmd = pmd_swp_mksoft_dirty(pmd);
+				set_pmd_at(src_mm, addr, src_pmd, pmd);
+			}
+			add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+			mm_inc_nr_ptes(dst_mm);
+			pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
+			set_pmd_at(dst_mm, addr, dst_pmd, pmd);
+			ret = 0;
+			goto out_unlock;
 		}
-		add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
-		mm_inc_nr_ptes(dst_mm);
-		pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
-		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
-		ret = 0;
-		goto out_unlock;
-	}
 #endif
+		if (IS_ENABLED(CONFIG_THP_SWAP) && !non_swap_entry(entry)) {
+			ret = swap_duplicate(&entry, HPAGE_PMD_NR);
+			if (!ret) {
+				add_mm_counter(dst_mm, MM_SWAPENTS,
+					       HPAGE_PMD_NR);
+				mm_inc_nr_ptes(dst_mm);
+				pgtable_trans_huge_deposit(dst_mm, dst_pmd,
+							   pgtable);
+				set_pmd_at(dst_mm, addr, dst_pmd, pmd);
+				/* make sure dst_mm is on swapoff's mmlist. */
+				if (unlikely(list_empty(&dst_mm->mmlist))) {
+					spin_lock(&mmlist_lock);
+					if (list_empty(&dst_mm->mmlist))
+						list_add(&dst_mm->mmlist,
+							 &src_mm->mmlist);
+					spin_unlock(&mmlist_lock);
+				}
+			} else if (ret == -ENOTDIR) {
+				/*
+				 * The huge swap cluster has been split, split
+				 * the PMD swap mapping and fallback to PTE
+				 */
+				__split_huge_swap_pmd(vma, addr, src_pmd);
+				pte_free(dst_mm, pgtable);
+			} else if (ret == -ENOMEM) {
+				spin_unlock(src_ptl);
+				spin_unlock(dst_ptl);
+				ret = add_swap_count_continuation(entry,
+								  GFP_KERNEL);
+				if (ret < 0) {
+					ret = -ENOMEM;
+					pte_free(dst_mm, pgtable);
+					goto out;
+				}
+				goto retry;
+			} else
+				VM_BUG_ON(1);
+			goto out_unlock;
+		}
+		VM_BUG_ON(1);
+	}
 
 	if (unlikely(!pmd_trans_huge(pmd))) {
 		pte_free(dst_mm, pgtable);
-- 
2.16.4
