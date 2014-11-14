Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 463276B00D1
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 08:33:16 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so2655860wiw.15
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 05:33:15 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx7si3773364wib.18.2014.11.14.05.33.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 05:33:14 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/7] mm: numa: Do not trap faults on the huge zero page
Date: Fri, 14 Nov 2014 13:33:04 +0000
Message-Id: <1415971986-16143-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1415971986-16143-1-git-send-email-mgorman@suse.de>
References: <1415971986-16143-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

Faults on the huge zero page are pointless and there is a BUG_ON
to catch them during fault time. This patch reintroduces a check
that avoids marking the zero page PAGE_NONE.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/huge_mm.h |  3 ++-
 mm/huge_memory.c        | 13 ++++++++++++-
 mm/memory.c             |  1 -
 mm/mprotect.c           | 15 ++++++++++++++-
 4 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 554bbe3..ad9051b 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -31,7 +31,8 @@ extern int move_huge_pmd(struct vm_area_struct *vma,
 			 unsigned long new_addr, unsigned long old_end,
 			 pmd_t *old_pmd, pmd_t *new_pmd);
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-			unsigned long addr, pgprot_t newprot);
+			unsigned long addr, pgprot_t newprot,
+			int prot_numa);
 
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8295c9a..4f02010 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1501,7 +1501,7 @@ out:
  *  - HPAGE_PMD_NR is protections changed and TLB flush necessary
  */
 int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long addr, pgprot_t newprot)
+		unsigned long addr, pgprot_t newprot, int prot_numa)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	spinlock_t *ptl;
@@ -1509,6 +1509,17 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		pmd_t entry;
+
+		/*
+		 * Avoid trapping faults against the zero page. The read-only
+		 * data is likely to be read-cached on the local CPU and
+		 * local/remote hits to the zero page are not interesting.
+		 */
+		if (prot_numa && is_huge_zero_pmd(*pmd)) {
+			spin_unlock(ptl);
+			return 0;
+		}
+
 		ret = 1;
 		entry = pmdp_get_and_clear(mm, addr, pmd);
 		entry = pmd_modify(entry, newprot);
diff --git a/mm/memory.c b/mm/memory.c
index 62604b1..360c3e3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3145,7 +3145,6 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte_unmap_unlock(ptep, ptl);
 		return 0;
 	}
-	BUG_ON(is_zero_pfn(page_to_pfn(page)));
 
 	/*
 	 * Avoid grouping on DSO/COW pages in specific and RO pages
diff --git a/mm/mprotect.c b/mm/mprotect.c
index dc65c0f..33dfafb 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -75,6 +75,19 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		oldpte = *pte;
 		if (pte_present(oldpte)) {
 			pte_t ptent;
+
+			/*
+			 * Avoid trapping faults against the zero or KSM
+			 * pages. See similar comment in change_huge_pmd.
+			 */
+			if (prot_numa) {
+				struct page *page;
+
+				page = vm_normal_page(vma, addr, oldpte);
+				if (!page || PageKsm(page))
+					continue;
+			}
+
 			ptent = ptep_modify_prot_start(mm, addr, pte);
 			ptent = pte_modify(ptent, newprot);
 
@@ -141,7 +154,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 				split_huge_page_pmd(vma, addr, pmd);
 			else {
 				int nr_ptes = change_huge_pmd(vma, pmd, addr,
-						newprot);
+						newprot, prot_numa);
 
 				if (nr_ptes) {
 					if (nr_ptes == HPAGE_PMD_NR) {
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
