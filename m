Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 978056B0272
	for <linux-mm@kvack.org>; Wed, 23 May 2018 04:27:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p189-v6so12807161pfp.2
        for <linux-mm@kvack.org>; Wed, 23 May 2018 01:27:18 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id d2-v6si18038840plh.387.2018.05.23.01.27.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 01:27:17 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V3 16/21] mm, THP, swap: Free PMD swap mapping when zap_huge_pmd()
Date: Wed, 23 May 2018 16:26:20 +0800
Message-Id: <20180523082625.6897-17-ying.huang@intel.com>
In-Reply-To: <20180523082625.6897-1-ying.huang@intel.com>
References: <20180523082625.6897-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

For a PMD swap mapping, zap_huge_pmd() will clear the PMD and call
free_swap_and_cache() to decrease the swap reference count and maybe
free or split the huge swap cluster and the THP in swap cache.

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
 mm/huge_memory.c | 32 +++++++++++++++++++++-----------
 1 file changed, 21 insertions(+), 11 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 01fdd59fe6d4..e057b966ea68 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2007,7 +2007,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		spin_unlock(ptl);
 		if (is_huge_zero_pmd(orig_pmd))
 			tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
-	} else if (is_huge_zero_pmd(orig_pmd)) {
+	} else if (pmd_present(orig_pmd) && is_huge_zero_pmd(orig_pmd)) {
 		zap_deposited_table(tlb->mm, pmd);
 		spin_unlock(ptl);
 		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
@@ -2020,17 +2020,27 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			page_remove_rmap(page, true);
 			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
 			VM_BUG_ON_PAGE(!PageHead(page), page);
-		} else if (thp_migration_supported()) {
-			swp_entry_t entry;
-
-			VM_BUG_ON(!is_pmd_migration_entry(orig_pmd));
-			entry = pmd_to_swp_entry(orig_pmd);
-			page = pfn_to_page(swp_offset(entry));
+		} else {
+			swp_entry_t entry = pmd_to_swp_entry(orig_pmd);
+
+			if (thp_migration_supported() &&
+			    is_migration_entry(entry))
+				page = pfn_to_page(swp_offset(entry));
+			else if (thp_swap_supported() &&
+				 !non_swap_entry(entry))
+				free_swap_and_cache(entry, true);
+			else {
+				WARN_ONCE(1,
+"Non present huge pmd without pmd migration or swap enabled!");
+				goto unlock;
+			}
 			flush_needed = 0;
-		} else
-			WARN_ONCE(1, "Non present huge pmd without pmd migration enabled!");
+		}
 
-		if (PageAnon(page)) {
+		if (!page) {
+			zap_deposited_table(tlb->mm, pmd);
+			add_mm_counter(tlb->mm, MM_SWAPENTS, -HPAGE_PMD_NR);
+		} else if (PageAnon(page)) {
 			zap_deposited_table(tlb->mm, pmd);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 		} else {
@@ -2038,7 +2048,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 				zap_deposited_table(tlb->mm, pmd);
 			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
 		}
-
+unlock:
 		spin_unlock(ptl);
 		if (flush_needed)
 			tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
-- 
2.16.1
