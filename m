Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3696B0072
	for <linux-mm@kvack.org>; Mon, 11 May 2015 10:36:09 -0400 (EDT)
Received: by wgiu9 with SMTP id u9so130328698wgi.3
        for <linux-mm@kvack.org>; Mon, 11 May 2015 07:36:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e7si123531wib.9.2015.05.11.07.36.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 May 2015 07:36:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 2/4] mm, thp: khugepaged checks for THP allocability before scanning
Date: Mon, 11 May 2015 16:35:38 +0200
Message-Id: <1431354940-30740-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1431354940-30740-1-git-send-email-vbabka@suse.cz>
References: <1431354940-30740-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

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
heavyweight enough to succeed frequently enough nowadays. The next patch will
however extend the nodemask check to page fault context, where it has much
larger impact. Also, with the future plan to convert THP collapsing to
task_work context, this patch is a preparation to avoid useless scanning or
heavyweight THP allocations in that context.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/huge_memory.c | 71 +++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 63 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 565864b..b86a72a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -102,7 +102,7 @@ struct khugepaged_scan {
 static struct khugepaged_scan khugepaged_scan = {
 	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
 };
-
+static nodemask_t thp_avail_nodes = NODE_MASK_ALL;
 
 static int set_recommended_min_free_kbytes(void)
 {
@@ -2273,6 +2273,14 @@ static bool khugepaged_scan_abort(int nid)
 	int i;
 
 	/*
+	 * If it's clear that we are going to select a node where THP
+	 * allocation is unlikely to succeed, abort
+	 */
+	if (khugepaged_node_load[nid] == (HPAGE_PMD_NR / 2) &&
+				!node_isset(nid, thp_avail_nodes))
+		return true;
+
+	/*
 	 * If zone_reclaim_mode is disabled, then no extra effort is made to
 	 * allocate memory locally.
 	 */
@@ -2356,6 +2364,7 @@ static struct page
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
+		node_clear(node, thp_avail_nodes);
 		return NULL;
 	}
 
@@ -2363,6 +2372,42 @@ static struct page
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
@@ -2590,6 +2635,10 @@ out_unmap:
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
@@ -2740,12 +2789,16 @@ static int khugepaged_wait_event(void)
 		kthread_should_stop();
 }
 
-static void khugepaged_do_scan(void)
+/* Return false if THP allocation failed, true otherwise */
+static bool khugepaged_do_scan(void)
 {
 	struct page *hpage = NULL;
 	unsigned int progress = 0, pass_through_head = 0;
 	unsigned int pages = READ_ONCE(khugepaged_pages_to_scan);
 
+	if (!khugepaged_check_nodes(&hpage))
+		return false;
+
 	while (progress < pages) {
 		cond_resched();
 
@@ -2764,14 +2817,14 @@ static void khugepaged_do_scan(void)
 		spin_unlock(&khugepaged_mm_lock);
 
 		/* THP allocation has failed during collapse */
-		if (IS_ERR(hpage)) {
-			khugepaged_alloc_sleep();
-			break;
-		}
+		if (IS_ERR(hpage))
+			return false;
 	}
 
 	if (!IS_ERR_OR_NULL(hpage))
 		put_page(hpage);
+
+	return true;
 }
 
 static void khugepaged_wait_work(void)
@@ -2800,8 +2853,10 @@ static int khugepaged(void *none)
 	set_user_nice(current, MAX_NICE);
 
 	while (!kthread_should_stop()) {
-		khugepaged_do_scan();
-		khugepaged_wait_work();
+		if (khugepaged_do_scan())
+			khugepaged_wait_work();
+		else
+			khugepaged_alloc_sleep();
 	}
 
 	spin_lock(&khugepaged_mm_lock);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
