Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 33A87900002
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:00:48 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/27] mm: numa: Do not migrate or account for hinting faults on the zero page
Date: Thu,  8 Aug 2013 15:00:16 +0100
Message-Id: <1375970439-5111-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The zero page is not replicated between nodes and is often shared
between processes. The data is read-only and likely to be cached in
local CPUs if heavily accessed meaning that the remote memory access
cost is less of a concern. This patch stops accounting for numa hinting
faults on the zero page in both terms of counting faults and scheduling
tasks on nodes.

[peterz@infradead.org: Correct use of is_huge_zero_page]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 9 +++++++++
 mm/memory.c      | 7 ++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e52c131..4ebe3aa 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1301,6 +1301,15 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_unlock;
 
 	page = pmd_page(pmd);
+
+	/*
+	 * Do not account for faults against the huge zero page. The read-only
+	 * data is likely to be read-cached on the local CPUs and it is less
+	 * useful to know about local versus remote hits on the zero page.
+	 */
+	if (is_huge_zero_page(page))
+		goto clear_pmdnuma;
+
 	get_page(page);
 	src_nid = numa_node_id();
 	count_vm_numa_event(NUMA_HINT_FAULTS);
diff --git a/mm/memory.c b/mm/memory.c
index 1ce2e2a..871b881 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3557,8 +3557,13 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	set_pte_at(mm, addr, ptep, pte);
 	update_mmu_cache(vma, addr, ptep);
 
+	/*
+	 * Do not account for faults against the zero page. The read-only data
+	 * is likely to be read-cached on the local CPUs and it is less useful
+	 * to know about local versus remote hits on the zero page.
+	 */
 	page = vm_normal_page(vma, addr, pte);
-	if (!page) {
+	if (!page || is_zero_pfn(page_to_pfn(page))) {
 		pte_unmap_unlock(ptep, ptl);
 		return 0;
 	}
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
