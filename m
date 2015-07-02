Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4FE9003CE
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 04:47:36 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so66704453wib.1
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 01:47:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hf10si8343279wib.2.2015.07.02.01.47.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Jul 2015 01:47:24 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 3/4] mm, thp: check for hugepage availability in khugepaged
Date: Thu,  2 Jul 2015 10:46:34 +0200
Message-Id: <1435826795-13777-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

Khugepaged could be scanning for collapse candidates uselessly, if it cannot
allocate a hugepage for the actual collapse event. The hugepage preallocation
mechanism has prevented this, but only for !NUMA configurations.  It was
removed by the previous patch, and this patch replaces it with a more generic
mechanism.

The patch itroduces a thp_avail_nodes nodemask, which initially assumes that
hugepage can be allocated on any node. Whenever khugepaged fails to allocate
a hugepage, it clears the corresponding node bit. Before scanning for collapse
candidates, it checks the availability on all nodes and wakes up kcompactd
on nodes that have their bit cleared. Kcompactd sets the bit back in case of
a successful compaction.

During the scaning, khugepaged avoids collapsing on nodes with the bit
cleared. If no nodes have hugepages available, collapse scanning is skipped
altogether.

During testing, the patch did not show much difference in preventing
thp_collapse_failed events from khugepaged, but this can be attributed to the
sync compaction, which only khugepaged is allowed to use, and which is
heavyweight enough to succeed frequently enough nowadays. The next patch will
however extend the nodemask check to page fault context, where it has much
larger impact. Also, with the possible future plan to convert THP collapsing
to task_work context, this patch is also a preparation to avoid useless
scanning or heavyweight THP allocations in that context.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/compaction.h |  2 ++
 include/linux/mmzone.h     |  4 ++++
 mm/compaction.c            | 38 +++++++++++++++++++++++++++--
 mm/huge_memory.c           | 60 ++++++++++++++++++++++++++++++++++++++++------
 mm/internal.h              | 39 ++++++++++++++++++++++++++++++
 mm/vmscan.c                |  7 ++++++
 6 files changed, 141 insertions(+), 9 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index a2525d8..9c1cdb3 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -53,6 +53,8 @@ extern bool compaction_restarting(struct zone *zone, int order);
 
 extern int kcompactd_run(int nid);
 extern void kcompactd_stop(int nid);
+extern bool kcompactd_work_requested(pg_data_t *pgdat);
+extern void wakeup_kcompactd(int nid, bool want_thp);
 
 #else
 static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bc96a23..4532585 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -766,6 +766,10 @@ typedef struct pglist_data {
 	struct task_struct *kcompactd;
 	wait_queue_head_t kcompactd_wait;
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	bool kcompactd_want_thp;
+#endif
+
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/mm/compaction.c b/mm/compaction.c
index fcbc093..027a2e0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1723,8 +1723,13 @@ void compaction_unregister_node(struct node *node)
 /*
  * Has any special work been requested of kcompactd?
  */
-static bool kcompactd_work_requested(pg_data_t *pgdat)
+bool kcompactd_work_requested(pg_data_t *pgdat)
 {
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (pgdat->kcompactd_want_thp)
+		return true;
+#endif
+
 	return false;
 }
 
@@ -1738,6 +1743,13 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	 * With no special task, compact all zones so that a pageblock-order
 	 * page is allocatable. Wake up kswapd if there's not enough free
 	 * memory for compaction.
+	 *
+	 * //TODO: with thp requested, just do the same thing as usual. We
+	 * could try really allocating a hugepage, but that would be
+	 * reclaim+compaction. If kswapd reclaim and kcompactd compaction
+	 * cannot yield a hugepage, it probably means the system is busy
+	 * enough with allocation/reclaim and being aggressive about THP
+	 * would be of little benefit?
 	 */
 	int zoneid;
 	struct zone *zone;
@@ -1747,6 +1759,15 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		.ignore_skip_hint = true,
 	};
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	/*
+	 * Clear the flag regardless of success. If somebody still wants a
+	 * hugepage, they will set it again.
+	 */
+	if (pgdat->kcompactd_want_thp)
+		pgdat->kcompactd_want_thp = false;
+#endif
+
 	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
 
 		int suitable;
@@ -1778,13 +1799,26 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		compact_zone(zone, &cc);
 
 		if (zone_watermark_ok(zone, cc.order,
-						low_wmark_pages(zone), 0, 0))
+						low_wmark_pages(zone), 0, 0)) {
 			compaction_defer_reset(zone, cc.order, false);
+			thp_avail_set(pgdat->node_id);
+		}
 
 		VM_BUG_ON(!list_empty(&cc.freepages));
 		VM_BUG_ON(!list_empty(&cc.migratepages));
 	}
+}
+
+void wakeup_kcompactd(int nid, bool want_thp)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (want_thp)
+		pgdat->kcompactd_want_thp = true;
+#endif
 
+	wake_up_interruptible(&pgdat->kcompactd_wait);
 }
 
 /*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6d83d05..885cb4e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -22,6 +22,7 @@
 #include <linux/mman.h>
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
+#include <linux/compaction.h>
 #include <linux/hashtable.h>
 
 #include <asm/tlb.h>
@@ -103,6 +104,7 @@ static struct khugepaged_scan khugepaged_scan = {
 	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
 };
 
+nodemask_t thp_avail_nodes = NODE_MASK_ALL;
 
 static int set_recommended_min_free_kbytes(void)
 {
@@ -2273,6 +2275,14 @@ static bool khugepaged_scan_abort(int nid)
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
@@ -2346,6 +2356,7 @@ static struct page
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
+		node_clear(node, thp_avail_nodes);
 		return NULL;
 	}
 
@@ -2353,6 +2364,31 @@ static struct page
 	return *hpage;
 }
 
+/*
+ * Return true, if THP should be allocatable on at least one node.
+ * Wake up kcompactd for nodes where THP is not available.
+ */
+static bool khugepaged_check_nodes(void)
+{
+	bool ret = false;
+	int nid;
+
+	for_each_online_node(nid) {
+		if (node_isset(nid, thp_avail_nodes)) {
+			ret = true;
+			continue;
+		}
+
+		/*
+		 * Tell kcompactd we want a hugepage available. It will
+		 * set the thp_avail_nodes when successful.
+		 */
+		wakeup_kcompactd(nid, true);
+	}
+
+	return ret;
+}
+
 static bool hugepage_vma_check(struct vm_area_struct *vma)
 {
 	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
@@ -2580,6 +2616,10 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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
@@ -2730,12 +2770,16 @@ static int khugepaged_wait_event(void)
 		kthread_should_stop();
 }
 
-static void khugepaged_do_scan(void)
+/* Return false if THP allocation failed, true otherwise */
+static bool khugepaged_do_scan(void)
 {
 	struct page *hpage = NULL;
 	unsigned int progress = 0, pass_through_head = 0;
 	unsigned int pages = READ_ONCE(khugepaged_pages_to_scan);
 
+	if (!khugepaged_check_nodes())
+		return false;
+
 	while (progress < pages) {
 		cond_resched();
 
@@ -2754,14 +2798,14 @@ static void khugepaged_do_scan(void)
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
@@ -2790,8 +2834,10 @@ static int khugepaged(void *none)
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
diff --git a/mm/internal.h b/mm/internal.h
index a25e359..6d9a711 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -162,6 +162,45 @@ extern bool is_free_buddy_page(struct page *page);
 #endif
 extern int user_min_free_kbytes;
 
+/*
+ * in mm/huge_memory.c
+ */
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+
+extern nodemask_t thp_avail_nodes;
+
+static inline bool thp_avail_isset(int nid)
+{
+	return node_isset(nid, thp_avail_nodes);
+}
+
+static inline void thp_avail_set(int nid)
+{
+	node_set(nid, thp_avail_nodes);
+}
+
+static inline void thp_avail_clear(int nid)
+{
+	node_clear(nid, thp_avail_nodes);
+}
+
+#else
+
+static inline bool thp_avail_isset(int nid)
+{
+	return true;
+}
+
+static inline void thp_avail_set(int nid)
+{
+}
+
+static inline void thp_avail_clear(int nid)
+{
+}
+
+#endif
+
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd..d91e4d0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3322,6 +3322,13 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		 */
 		reset_isolation_suitable(pgdat);
 
+		/*
+		 * If kcompactd has work to do, it's possible that it was
+		 * waiting for kswapd to reclaim enough memory first.
+		 */
+		if (kcompactd_work_requested(pgdat))
+			wakeup_kcompactd(pgdat->node_id, false);
+
 		if (!kthread_should_stop())
 			schedule();
 
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
