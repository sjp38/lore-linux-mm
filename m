Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 6E9F26B0034
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 05:47:07 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/16] mm: numa: Do not migrate or account for hinting faults on the zero page
Date: Thu, 11 Jul 2013 10:46:48 +0100
Message-Id: <1373536020-2799-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1373536020-2799-1-git-send-email-mgorman@suse.de>
References: <1373536020-2799-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The zero page is not replicated between nodes and is often shared
between processes. The data is read-only and likely to be cached in
local CPUs if heavily accessed meaning that the remote memory access
cost is less of a concern. This patch stops accounting for numa hinting
faults on the zero page in both terms of counting faults and scheduling
tasks on nodes.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 9 +++++++++
 mm/memory.c      | 7 ++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e4a79fa..ec938ed 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1302,6 +1302,15 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	page = pmd_page(pmd);
 	get_page(page);
+
+	/*
+	 * Do not account for faults against the huge zero page. The read-only
+	 * data is likely to be read-cached on the local CPUs and it is less
+	 * useful to know about local versus remote hits on the zero page.
+	 */
+	if (is_huge_zero_pfn(page_to_pfn(page)))
+		goto clear_pmdnuma;
+
 	src_nid = numa_node_id();
 	count_vm_numa_event(NUMA_HINT_FAULTS);
 	if (src_nid == page_to_nid(page))
diff --git a/mm/memory.c b/mm/memory.c
index ba94dec..422351c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3560,8 +3560,13 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	set_pte_at(mm, addr, ptep, pte);
 	update_mmu_cache(vma, addr, ptep);
 
+	/*
+	 * Do not account for faults against the huge zero page. The read-only
+	 * data is likely to be read-cached on the local CPUs and it is less
+	 * useful to know about local versus remote hits on the zero page.
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
