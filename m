Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7456B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 21:09:41 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so3979165iec.12
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 18:09:41 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id f20si8212479icc.101.2014.07.14.18.09.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 18:09:40 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so3952573iec.40
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 18:09:40 -0700 (PDT)
Date: Mon, 14 Jul 2014 18:09:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, thp: only collapse hugepages to nodes with affinity
Message-ID: <alpine.DEB.2.02.1407141807030.8808@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit 9f1b868a13ac ("mm: thp: khugepaged: add policy for finding target 
node") improved the previous khugepaged logic which allocated a 
transparent hugepages from the node of the first page being collapsed.

However, it is still possible to collapse pages to remote memory which may 
suffer from additional access latency.  With the current policy, it is 
possible that 255 pages (with PAGE_SHIFT == 12) will be collapsed remotely 
if the majority are allocated from that node.

Introduce a strict requirement that pages can only be collapsed to nodes 
at or below RECLAIM_DISTANCE to ensure the access latency of the pages 
scanned does not regress.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/huge_memory.c | 54 ++++++++++++------------------------------------------
 1 file changed, 12 insertions(+), 42 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2231,34 +2231,7 @@ static void khugepaged_alloc_sleep(void)
 			msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
 }
 
-static int khugepaged_node_load[MAX_NUMNODES];
-
 #ifdef CONFIG_NUMA
-static int khugepaged_find_target_node(void)
-{
-	static int last_khugepaged_target_node = NUMA_NO_NODE;
-	int nid, target_node = 0, max_value = 0;
-
-	/* find first node with max normal pages hit */
-	for (nid = 0; nid < MAX_NUMNODES; nid++)
-		if (khugepaged_node_load[nid] > max_value) {
-			max_value = khugepaged_node_load[nid];
-			target_node = nid;
-		}
-
-	/* do some balance if several nodes have the same hit record */
-	if (target_node <= last_khugepaged_target_node)
-		for (nid = last_khugepaged_target_node + 1; nid < MAX_NUMNODES;
-				nid++)
-			if (max_value == khugepaged_node_load[nid]) {
-				target_node = nid;
-				break;
-			}
-
-	last_khugepaged_target_node = target_node;
-	return target_node;
-}
-
 static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 {
 	if (IS_ERR(*hpage)) {
@@ -2309,11 +2282,6 @@ static struct page
 	return *hpage;
 }
 #else
-static int khugepaged_find_target_node(void)
-{
-	return 0;
-}
-
 static inline struct page *alloc_hugepage(int defrag)
 {
 	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
@@ -2522,7 +2490,6 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	if (!pmd)
 		goto out;
 
-	memset(khugepaged_node_load, 0, sizeof(khugepaged_node_load));
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, _address += PAGE_SIZE) {
@@ -2538,14 +2505,18 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		page = vm_normal_page(vma, _address, pteval);
 		if (unlikely(!page))
 			goto out_unmap;
-		/*
-		 * Record which node the original page is from and save this
-		 * information to khugepaged_node_load[].
-		 * Khupaged will allocate hugepage from the node has the max
-		 * hit record.
-		 */
-		node = page_to_nid(page);
-		khugepaged_node_load[node]++;
+		if (node == NUMA_NO_NODE) {
+			node = page_to_nid(page);
+		} else {
+			int distance = node_distance(page_to_nid(page), node);
+
+			/*
+			 * Do not migrate to memory that would not be reclaimed
+			 * from.
+			 */
+			if (distance > RECLAIM_DISTANCE)
+				goto out_unmap;
+		}
 		VM_BUG_ON_PAGE(PageCompound(page), page);
 		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
 			goto out_unmap;
@@ -2561,7 +2532,6 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret) {
-		node = khugepaged_find_target_node();
 		/* collapse_huge_page will return with the mmap_sem released */
 		collapse_huge_page(mm, address, hpage, vma, node);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
