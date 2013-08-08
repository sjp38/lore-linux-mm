Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 3303A900008
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:00:58 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/27] mm: Only flush TLBs if a transhuge PMD is modified for NUMA pte scanning
Date: Thu,  8 Aug 2013 15:00:25 +0100
Message-Id: <1375970439-5111-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

NUMA PTE scanning is expensive both in terms of the scanning itself and
the TLB flush if there are any updates. The TLB flush is avoided if no
PTEs are updated but there is a bug where transhuge PMDs are considered
to be updated even if they were already pmd_numa. This patch addresses
the problem and TLB flushes should be reduced.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 20 +++++++++++++++++---
 mm/mprotect.c    | 14 ++++++++++----
 2 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bf59194..e6beb0f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1456,6 +1456,12 @@ out:
 	return ret;
 }
 
+/*
+ * Returns
+ *  - 0 if PMD could not be locked
+ *  - 1 if PMD was locked but protections unchange and TLB flush unnecessary
+ *  - HPAGE_PMD_NR is protections changed and TLB flush necessary
+ */
 int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, pgprot_t newprot, int prot_numa)
 {
@@ -1464,22 +1470,30 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
 		pmd_t entry;
-		entry = pmdp_get_and_clear(mm, addr, pmd);
+		ret = 1;
 		if (!prot_numa) {
+			entry = pmdp_get_and_clear(mm, addr, pmd);
 			entry = pmd_modify(entry, newprot);
+			ret = HPAGE_PMD_NR;
 			BUG_ON(pmd_write(entry));
 		} else {
 			struct page *page = pmd_page(*pmd);
+			ret = 1;
 
 			/* only check non-shared pages */
 			if (page_mapcount(page) == 1 &&
 			    !pmd_numa(*pmd)) {
+				entry = pmdp_get_and_clear(mm, addr, pmd);
 				entry = pmd_mknuma(entry);
+				ret = HPAGE_PMD_NR;
 			}
 		}
-		set_pmd_at(mm, addr, pmd, entry);
+
+		/* Set PMD if cleared earlier */
+		if (ret == HPAGE_PMD_NR)
+			set_pmd_at(mm, addr, pmd, entry);
+
 		spin_unlock(&vma->vm_mm->page_table_lock);
-		ret = 1;
 	}
 
 	return ret;
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 94722a4..1f4ab1c 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -143,10 +143,16 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		if (pmd_trans_huge(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE)
 				split_huge_page_pmd(vma, addr, pmd);
-			else if (change_huge_pmd(vma, pmd, addr, newprot,
-						 prot_numa)) {
-				pages += HPAGE_PMD_NR;
-				continue;
+			else {
+				int nr_ptes = change_huge_pmd(vma, pmd, addr,
+						newprot, prot_numa);
+
+				if (nr_ptes) {
+					if (nr_ptes == HPAGE_PMD_NR)
+						pages += HPAGE_PMD_NR;
+
+					continue;
+				}
 			}
 			/* fall through */
 		}
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
