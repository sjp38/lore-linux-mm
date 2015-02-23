Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id CABC16B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 07:59:21 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id r20so16712452wiv.2
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 04:59:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wl5si11242113wjc.91.2015.02.23.04.59.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 04:59:20 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 2/6] mm, thp: make khugepaged check for THP allocability before scanning
Date: Mon, 23 Feb 2015 13:58:38 +0100
Message-Id: <1424696322-21952-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

Khugepaged could be scanning for collapse candidates uselessly, if it cannot
allocate a hugepage in the end. The hugepage preallocation mechanism prevented
this, but only for !NUMA configurations. It was removed by the previous patch,
and this patch replaces it with a more generic mechanism.

The patch itroduces a thp_avail_nodes nodemask, which initially assumes that
hugepage can be allocated on any node. Whenever khugepaged fails to allocate
a hugepage, it clears the corresponding node bit. Before scanning for collapse
candidates, it tries to allocate a hugepage on each online node with the bit
cleared, and set it back on success. It tries to hold on to the hugepage if
it doesn't hold any other yet. But the assumption is that even if the hugepage
is freed back, it should be possible to allocate it in near future without
further reclaim and compaction attempts.

During the scaning, khugepaged avoids collapsing on nodes with the bit cleared,
as soon as possible. If no nodes have hugepages available, scanning is skipped
altogether.

During testing, the patch did not show much difference in preventing
thp_collapse_failed events from khugepaged, but this can be attributed to the
sync compaction, which only khugepaged is allowed to use, and which is
heavyweight enough to succeed frequently enough nowadays. However, with the
plan to convert THP collapsing to task_work context, this patch is a
preparation to avoid useless scanning and/or heavyweight THP allocations in
that context. A later patch also extends the THP availability check to page
fault context.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/huge_memory.c | 56 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 55 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 44fecfc4..55846b8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -101,7 +101,7 @@ struct khugepaged_scan {
 static struct khugepaged_scan khugepaged_scan = {
 	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
 };
-
+static nodemask_t thp_avail_nodes = NODE_MASK_ALL;
 
 static int set_recommended_min_free_kbytes(void)
 {
@@ -2244,6 +2244,14 @@ static bool khugepaged_scan_abort(int nid)
 	int i;
 
 	/*
+	 * If it's clear that we are going to select a node where THP
+	 * allocation is unlikely to succeed, abort
+	 */
+	if (khugepaged_node_load[nid] == (HPAGE_PMD_NR) / 2 &&
+				!node_isset(nid, thp_avail_nodes))
+		return true;
+
+	/*
 	 * If zone_reclaim_mode is disabled, then no extra effort is made to
 	 * allocate memory locally.
 	 */
@@ -2330,6 +2338,7 @@ static struct page
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
+		node_clear(node, thp_avail_nodes);
 		return NULL;
 	}
 
@@ -2337,6 +2346,42 @@ static struct page
 	return *hpage;
 }
 
+/* Return true, if THP should be allocatable on at least one node */
+static bool khugepaged_check_nodes(struct page **hpage)
+{
+	bool ret = false;
+	int nid;
+	struct page *newpage = NULL;
+	gfp_t gfp = alloc_hugepage_gfpmask(khugepaged_defrag());
+
+	for_each_online_node(nid) {
+		if (node_isset(nid, thp_avail_nodes)) {
+			ret = true;
+			continue;
+		}
+
+		newpage = alloc_hugepage_node(gfp, nid);
+
+		if (newpage) {
+			node_set(nid, thp_avail_nodes);
+			ret = true;
+			/*
+			 * Heuristic - try to hold on to the page for collapse
+			 * scanning, if we don't hold any yet.
+			 */
+			if (IS_ERR_OR_NULL(*hpage)) {
+				*hpage = newpage;
+				//NIXME: should we count all/no allocations?
+				count_vm_event(THP_COLLAPSE_ALLOC);
+			} else {
+				put_page(newpage);
+			}
+		}
+	}
+
+	return ret;
+}
+
 static bool hugepage_vma_check(struct vm_area_struct *vma)
 {
 	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
@@ -2557,6 +2602,10 @@ out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret) {
 		node = khugepaged_find_target_node();
+		if (!node_isset(node, thp_avail_nodes)) {
+			ret = 0;
+			goto out;
+		}
 		/* collapse_huge_page will return with the mmap_sem released */
 		collapse_huge_page(mm, address, hpage, vma, node);
 	}
@@ -2713,6 +2762,11 @@ static void khugepaged_do_scan(void)
 	unsigned int progress = 0, pass_through_head = 0;
 	unsigned int pages = READ_ONCE(khugepaged_pages_to_scan);
 
+	if (!khugepaged_check_nodes(&hpage)) {
+		khugepaged_alloc_sleep();
+		return;
+	}
+
 	while (progress < pages) {
 		cond_resched();
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
