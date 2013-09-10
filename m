Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E3A6F6B003D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:32:43 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/50] mm: numa: Do not migrate or account for hinting faults on the zero page
Date: Tue, 10 Sep 2013 10:31:49 +0100
Message-Id: <1378805550-29949-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The zero page is not replicated between nodes and is often shared between
processes. The data is read-only and likely to be cached in local CPUs
if heavily accessed meaning that the remote memory access cost is less
of a concern. This patch prevents trapping faults on the zero pages. For
tasks using the zero page this will reduce the number of PTE updates,
TLB flushes and hinting faults.

[peterz@infradead.org: Correct use of is_huge_zero_page]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c |  7 ++++++-
 mm/memory.c      |  1 +
 mm/mprotect.c    | 10 +++++++++-
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 94d0739..40f75a6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1303,6 +1303,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_unlock;
 
 	page = pmd_page(pmd);
+	BUG_ON(is_huge_zero_page(page));
 	page_nid = page_to_nid(page);
 	count_vm_numa_event(NUMA_HINT_FAULTS);
 	if (page_nid == this_nid)
@@ -1488,8 +1489,12 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		} else {
 			struct page *page = pmd_page(*pmd);
 
-			/* only check non-shared pages */
+			/*
+			 * Only check non-shared pages. See change_pte_range
+			 * for comment on why the zero page is not modified
+			 */
 			if (page_mapcount(page) == 1 &&
+			    !is_huge_zero_page(page) &&
 			    !pmd_numa(*pmd)) {
 				entry = pmd_mknuma(entry);
 			}
diff --git a/mm/memory.c b/mm/memory.c
index c20f872..86c3caf 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3575,6 +3575,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte_unmap_unlock(ptep, ptl);
 		return 0;
 	}
+	BUG_ON(is_zero_pfn(page_to_pfn(page)));
 
 	page_nid = page_to_nid(page);
 	target_nid = numa_migrate_prep(page, vma, addr, page_nid);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 2bbb648..faa499e 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -62,7 +62,15 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				struct page *page;
 
 				page = vm_normal_page(vma, addr, oldpte);
-				if (page) {
+
+				/*
+				 * Do not trap faults against the zero page.
+				 * The read-only data is likely to be
+				 * read-cached on the local CPU cache and it
+				 * is less useful to know about local vs remote
+				 * hits on the zero page
+				 */
+				if (page && !is_zero_pfn(page_to_pfn(page))) {
 					int this_nid = page_to_nid(page);
 					if (last_nid == -1)
 						last_nid = this_nid;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
