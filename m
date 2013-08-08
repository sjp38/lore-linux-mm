Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id E9FFF900002
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:00:46 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/27] mm: numa: Account for THP numa hinting faults on the correct node
Date: Thu,  8 Aug 2013 15:00:15 +0100
Message-Id: <1375970439-5111-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

THP NUMA hinting fault on pages that are not migrated are being
accounted for incorrectly. Currently the fault will be counted as if the
task was running on a node local to the page which is not necessarily
true.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 45ef9dc..e52c131 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1293,7 +1293,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
 	int target_nid;
-	int current_nid = -1;
+	int src_nid = -1;
 	bool migrated;
 
 	spin_lock(&mm->page_table_lock);
@@ -1302,9 +1302,9 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	page = pmd_page(pmd);
 	get_page(page);
-	current_nid = page_to_nid(page);
+	src_nid = numa_node_id();
 	count_vm_numa_event(NUMA_HINT_FAULTS);
-	if (current_nid == numa_node_id())
+	if (src_nid == page_to_nid(page))
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
 	target_nid = mpol_misplaced(page, vma, haddr);
@@ -1346,8 +1346,8 @@ clear_pmdnuma:
 	update_mmu_cache_pmd(vma, addr, pmdp);
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
-	if (current_nid != -1)
-		task_numa_fault(current_nid, HPAGE_PMD_NR, false);
+	if (src_nid != -1)
+		task_numa_fault(src_nid, HPAGE_PMD_NR, false);
 	return 0;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
