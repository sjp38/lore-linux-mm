Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC9116B0009
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 21:19:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 17so2407142pfo.23
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 18:19:20 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y15si2598728pgv.251.2018.03.14.18.19.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 18:19:19 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm] mm, madvise, THP: Use THP aligned address in madvise_free_huge_pmd()
Date: Thu, 15 Mar 2018 09:18:40 +0800
Message-Id: <20180315011840.27599-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, jglisse@redhat.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: Huang Ying <ying.huang@intel.com>

The address argument passed in madvise_free_huge_pmd() may be not THP
aligned.  But some THP operations like pmdp_invalidate(),
set_pmd_at(), and tlb_remove_pmd_tlb_entry() need the address to be
THP aligned.  Fix this via using THP aligned address for these
functions in madvise_free_huge_pmd().

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: jglisse@redhat.com
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/huge_memory.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0cc62405de9c..c5e1bfb08bd7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1617,6 +1617,7 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	struct page *page;
 	struct mm_struct *mm = tlb->mm;
 	bool ret = false;
+	unsigned long haddr = addr & HPAGE_PMD_MASK;
 
 	tlb_remove_check_page_size_change(tlb, HPAGE_PMD_SIZE);
 
@@ -1663,12 +1664,12 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	unlock_page(page);
 
 	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
-		pmdp_invalidate(vma, addr, pmd);
+		pmdp_invalidate(vma, haddr, pmd);
 		orig_pmd = pmd_mkold(orig_pmd);
 		orig_pmd = pmd_mkclean(orig_pmd);
 
-		set_pmd_at(mm, addr, pmd, orig_pmd);
-		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
+		set_pmd_at(mm, haddr, pmd, orig_pmd);
+		tlb_remove_pmd_tlb_entry(tlb, pmd, haddr);
 	}
 
 	mark_page_lazyfree(page);
-- 
2.16.1
