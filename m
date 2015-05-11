Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id F39C56B0074
	for <linux-mm@kvack.org>; Mon, 11 May 2015 10:36:14 -0400 (EDT)
Received: by wiun10 with SMTP id n10so98904563wiu.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 07:36:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wb11si39190wic.105.2015.05.11.07.36.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 May 2015 07:36:04 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 4/4] mm, thp: wake up khugepaged when huge page is not available
Date: Mon, 11 May 2015 16:35:40 +0200
Message-Id: <1431354940-30740-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1431354940-30740-1-git-send-email-vbabka@suse.cz>
References: <1431354940-30740-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

After previous patch, THP page faults check the thp_avail_nodes nodemask to
determine whether to attempt allocating hugepage or fallback immediately.
The khugepaged task is responsible for attempting reclaim and compaction for
nodes where hugepages are not available, and updating the nodemask as
appropriate.

To get faster reaction on THP allocation failures, we will wake up khugepaged
whenever THP page fault has to fallback. This includes both situations when
hugepage was supposed to be available, but allocation fails, and situations
where hugepage is already marked as unavailable. In the latter case, khugepaged
will not wait according to its alloc_sleep_millisecs parameter under /sys, but
retry allocation immediately. This is done to scale the khugepaged activity
with respect to THP demand, instead of a fixed tunable. Excessive compaction
failures are still being prevented by the self-tuning deferred compaction
mechanism in this case.  For this mechanism to work as intended, the check for
deferred compaction should be done on each THP allocation attempt to bump the
internal counter, and waiting full alloc_sleep_millisecs period could make the
deferred periods excessively long.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/huge_memory.c | 22 ++++++++++++++++++----
 mm/internal.h    |  5 +----
 2 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d3081a7..b3d08a0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -104,6 +104,15 @@ static struct khugepaged_scan khugepaged_scan = {
 };
 
 nodemask_t thp_avail_nodes = NODE_MASK_ALL;
+static bool khugepaged_thp_requested = false;
+
+void thp_avail_clear(int nid)
+{
+	node_clear(nid, thp_avail_nodes);
+	khugepaged_thp_requested = true;
+	wake_up_interruptible(&khugepaged_wait);
+}
+
 
 static int set_recommended_min_free_kbytes(void)
 {
@@ -2263,7 +2272,8 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 
 static void khugepaged_alloc_sleep(void)
 {
-	wait_event_freezable_timeout(khugepaged_wait, false,
+	wait_event_freezable_timeout(khugepaged_wait,
+			khugepaged_thp_requested,
 			msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
 }
 
@@ -2381,6 +2391,8 @@ static bool khugepaged_check_nodes(struct page **hpage)
 	struct page *newpage = NULL;
 	gfp_t gfp = alloc_hugepage_gfpmask(khugepaged_defrag());
 
+	khugepaged_thp_requested = false;
+
 	for_each_online_node(nid) {
 		if (node_isset(nid, thp_avail_nodes)) {
 			ret = true;
@@ -2780,13 +2792,15 @@ breakouterloop_mmap_sem:
 
 static int khugepaged_has_work(void)
 {
-	return !list_empty(&khugepaged_scan.mm_head) &&
+	return (khugepaged_thp_requested ||
+			!list_empty(&khugepaged_scan.mm_head)) &&
 		khugepaged_enabled();
 }
 
 static int khugepaged_wait_event(void)
 {
-	return !list_empty(&khugepaged_scan.mm_head) ||
+	return khugepaged_thp_requested ||
+		!list_empty(&khugepaged_scan.mm_head) ||
 		kthread_should_stop();
 }
 
@@ -2837,7 +2851,7 @@ static void khugepaged_wait_work(void)
 			return;
 
 		wait_event_freezable_timeout(khugepaged_wait,
-					     kthread_should_stop(),
+			khugepaged_thp_requested || kthread_should_stop(),
 			msecs_to_jiffies(khugepaged_scan_sleep_millisecs));
 		return;
 	}
diff --git a/mm/internal.h b/mm/internal.h
index 6d9a711..5c37e4d 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -179,10 +179,7 @@ static inline void thp_avail_set(int nid)
 	node_set(nid, thp_avail_nodes);
 }
 
-static inline void thp_avail_clear(int nid)
-{
-	node_clear(nid, thp_avail_nodes);
-}
+extern void thp_avail_clear(int nid);
 
 #else
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
