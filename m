Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1600B6B0072
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 07:59:35 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id hi2so19156296wib.1
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 04:59:34 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mt5si61460990wjc.97.2015.02.23.04.59.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 04:59:21 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 5/6] mm, thp: wakeup khugepaged when THP allocation fails
Date: Mon, 23 Feb 2015 13:58:41 +0100
Message-Id: <1424696322-21952-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

The previous patch has taken away the THP collapse scanning from khugepaged,
leaving it only to maintain the thp_avail_nodes nodemask through heavyweight
attempts to make a hugepage available on nodes where it could not be allocated
from the process context, both through page fault or the collapse scanning.

This patch improves the coordination between failed THP allocations and
khugepaged by wakeups, repurposing the khugepaged_wait infrastructure.
Instead of periodical sleeping and checking for work, khugepaged will now sleep
at least alloc_sleep_millisecs after its last allocation attempt in order to
prevent excessive activity, and then respond to a failed THP allocation
immediately through khugepaged_wait.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/huge_memory.c | 77 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 44 insertions(+), 33 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1c92edc..9172c7f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -158,9 +158,6 @@ static int start_khugepaged(void)
 			khugepaged_thread = NULL;
 		}
 
-		if (!list_empty(&khugepaged_scan.mm_head))
-			wake_up_interruptible(&khugepaged_wait);
-
 		set_recommended_min_free_kbytes();
 	} else if (khugepaged_thread) {
 		kthread_stop(khugepaged_thread);
@@ -430,7 +427,6 @@ static ssize_t scan_sleep_millisecs_store(struct kobject *kobj,
 		return -EINVAL;
 
 	khugepaged_scan_sleep_millisecs = msecs;
-	wake_up_interruptible(&khugepaged_wait);
 
 	return count;
 }
@@ -781,8 +777,10 @@ fault_alloc_hugepage(struct vm_area_struct *vma, unsigned long haddr)
 	gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma));
 	hpage = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
 
-	if (!hpage)
+	if (!hpage) {
 		node_clear(nid, thp_avail_nodes);
+		wake_up_interruptible(&khugepaged_wait);
+	}
 
 	return hpage;
 }
@@ -2054,8 +2052,6 @@ int __khugepaged_enter(struct mm_struct *mm)
 	spin_unlock(&khugepaged_mm_lock);
 
 	atomic_inc(&mm->mm_count);
-	if (wakeup)
-		wake_up_interruptible(&khugepaged_wait);
 
 	return 0;
 }
@@ -2252,12 +2248,6 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 	}
 }
 
-static void khugepaged_alloc_sleep(void)
-{
-	wait_event_freezable_timeout(khugepaged_wait, false,
-			msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
-}
-
 static bool khugepaged_scan_abort(int nid, int *node_load)
 {
 	int i;
@@ -2358,6 +2348,7 @@ static struct page
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
 		node_clear(node, thp_avail_nodes);
+		wake_up_interruptible(&khugepaged_wait);
 		return NULL;
 	}
 
@@ -2365,7 +2356,7 @@ static struct page
 	return *hpage;
 }
 
-/* Return true, if THP should be allocatable on at least one node */
+/* Return true if we tried to allocate on at least one node */
 static bool khugepaged_check_nodes(void)
 {
 	bool ret = false;
@@ -2375,15 +2366,14 @@ static bool khugepaged_check_nodes(void)
 
 	for_each_online_node(nid) {
 		if (node_isset(nid, thp_avail_nodes)) {
-			ret = true;
 			continue;
 		}
 
 		newpage = alloc_hugepage_node(gfp, nid);
+		ret = true;
 
 		if (newpage) {
 			node_set(nid, thp_avail_nodes);
-			ret = true;
 			put_page(newpage);
 		}
 		if (unlikely(kthread_should_stop() || freezing(current)))
@@ -2393,6 +2383,19 @@ static bool khugepaged_check_nodes(void)
 	return ret;
 }
 
+/* Return true if hugepages are available on at least one node */
+static bool check_thp_avail(void)
+{
+	int nid;
+
+	for_each_online_node(nid) {
+		if (node_isset(nid, thp_avail_nodes))
+			return true;
+	}
+
+	return false;
+}
+
 static bool hugepage_vma_check(struct vm_area_struct *vma)
 {
 	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
@@ -2656,6 +2659,9 @@ bool khugepaged_scan_mm(struct mm_struct *mm, unsigned long *start, long pages)
 	int ret;
 	int *node_load;
 
+	if (!check_thp_avail())
+		return false;
+
 	//TODO: #ifdef this for NUMA only
 	node_load = kmalloc(sizeof(int) * MAX_NUMNODES,
 						GFP_KERNEL | GFP_NOWAIT);
@@ -2706,30 +2712,36 @@ out:
 	return true;
 }
 
-static int khugepaged_has_work(void)
+static bool khugepaged_has_work(void)
 {
-	return !list_empty(&khugepaged_scan.mm_head) &&
-		khugepaged_enabled();
+	int nid;
+
+	for_each_online_node(nid) {
+		if (!node_isset(nid, thp_avail_nodes))
+			return true;
+	}
+
+	return false;
 }
 
-static int khugepaged_wait_event(void)
+static bool khugepaged_wait_event(void)
 {
-	return !list_empty(&khugepaged_scan.mm_head) ||
-		kthread_should_stop();
+	return khugepaged_has_work() || kthread_should_stop();
 }
 
-static void khugepaged_wait_work(void)
+static void khugepaged_wait_work(bool did_alloc)
 {
+	unsigned int msec_sleep;
+
 	try_to_freeze();
 
-	if (khugepaged_has_work()) {
-		if (!khugepaged_scan_sleep_millisecs)
-			return;
+	if (did_alloc) {
+		msec_sleep = READ_ONCE(khugepaged_alloc_sleep_millisecs);
 
-		wait_event_freezable_timeout(khugepaged_wait,
+		if (msec_sleep)
+			wait_event_freezable_timeout(khugepaged_wait,
 					     kthread_should_stop(),
-			msecs_to_jiffies(khugepaged_scan_sleep_millisecs));
-		return;
+						msecs_to_jiffies(msec_sleep));
 	}
 
 	if (khugepaged_enabled())
@@ -2739,15 +2751,14 @@ static void khugepaged_wait_work(void)
 static int khugepaged(void *none)
 {
 	struct mm_slot *mm_slot;
+	bool did_alloc;
 
 	set_freezable();
 	set_user_nice(current, MAX_NICE);
 
 	while (!kthread_should_stop()) {
-		if (khugepaged_check_nodes())
-			khugepaged_wait_work();
-		else
-			khugepaged_alloc_sleep();
+		did_alloc = khugepaged_check_nodes();
+		khugepaged_wait_work(did_alloc);
 	}
 
 	spin_lock(&khugepaged_mm_lock);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
