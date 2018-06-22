Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BDB4F6B0274
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 23:55:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a13-v6so2542745pfo.22
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 20:55:45 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n61-v6si6160066plb.256.2018.06.21.20.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 20:55:44 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v4 13/21] mm, THP, swap: Support PMD swap mapping in madvise_free()
Date: Fri, 22 Jun 2018 11:51:43 +0800
Message-Id: <20180622035151.6676-14-ying.huang@intel.com>
In-Reply-To: <20180622035151.6676-1-ying.huang@intel.com>
References: <20180622035151.6676-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

From: Huang Ying <ying.huang@intel.com>

When madvise_free() found a PMD swap mapping, if only part of the huge
swap cluster is operated on, the PMD swap mapping will be split and
fallback to PTE swap mapping processing.  Otherwise, if all huge swap
cluster is operated on, free_swap_and_cache() will be called to
decrease the PMD swap mapping count and probably free the swap space
and the THP in swap cache too.

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
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/huge_memory.c | 50 +++++++++++++++++++++++++++++++++++---------------
 mm/madvise.c     |  2 +-
 2 files changed, 36 insertions(+), 16 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 73fc77633642..fe946ca09b28 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1842,6 +1842,15 @@ static inline void __split_huge_swap_pmd(struct vm_area_struct *vma,
 }
 #endif
 
+static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
+{
+	pgtable_t pgtable;
+
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+	pte_free(mm, pgtable);
+	mm_dec_nr_ptes(mm);
+}
+
 /*
  * Return true if we do MADV_FREE successfully on entire pmd page.
  * Otherwise, return false.
@@ -1862,15 +1871,35 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		goto out_unlocked;
 
 	orig_pmd = *pmd;
-	if (is_huge_zero_pmd(orig_pmd))
-		goto out;
-
 	if (unlikely(!pmd_present(orig_pmd))) {
-		VM_BUG_ON(thp_migration_supported() &&
-				  !is_pmd_migration_entry(orig_pmd));
-		goto out;
+		swp_entry_t entry = pmd_to_swp_entry(orig_pmd);
+
+		if (is_migration_entry(entry)) {
+			VM_BUG_ON(!thp_migration_supported());
+			goto out;
+		} else if (thp_swap_supported() && !non_swap_entry(entry)) {
+			/* If part of THP is discarded */
+			if (next - addr != HPAGE_PMD_SIZE) {
+				unsigned long haddr = addr & HPAGE_PMD_MASK;
+
+				__split_huge_swap_pmd(vma, haddr, pmd);
+				goto out;
+			}
+			free_swap_and_cache(entry, true);
+			pmd_clear(pmd);
+			zap_deposited_table(mm, pmd);
+			if (current->mm == mm)
+				sync_mm_rss(mm);
+			add_mm_counter(mm, MM_SWAPENTS, -HPAGE_PMD_NR);
+			ret = true;
+			goto out;
+		} else
+			VM_BUG_ON(1);
 	}
 
+	if (is_huge_zero_pmd(orig_pmd))
+		goto out;
+
 	page = pmd_page(orig_pmd);
 	/*
 	 * If other processes are mapping this page, we couldn't discard
@@ -1916,15 +1945,6 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	return ret;
 }
 
-static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
-{
-	pgtable_t pgtable;
-
-	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
-	pte_free(mm, pgtable);
-	mm_dec_nr_ptes(mm);
-}
-
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
diff --git a/mm/madvise.c b/mm/madvise.c
index a96abb915e22..fc423d96d4d6 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -321,7 +321,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	unsigned long next;
 
 	next = pmd_addr_end(addr, end);
-	if (pmd_trans_huge(*pmd))
+	if (pmd_trans_huge(*pmd) || is_swap_pmd(*pmd))
 		if (madvise_free_huge_pmd(tlb, vma, pmd, addr, next))
 			goto next;
 
-- 
2.16.4
