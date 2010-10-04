Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4CF6B007E
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 03:03:22 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 10/10] memcg: check memcg dirty limits in page writeback
Date: Sun,  3 Oct 2010 23:58:05 -0700
Message-Id: <1286175485-30643-11-git-send-email-gthelen@google.com>
In-Reply-To: <1286175485-30643-1-git-send-email-gthelen@google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

If the current process is in a non-root memcg, then
global_dirty_limits() will consider the memcg dirty limit.
This allows different cgroups to have distinct dirty limits
which trigger direct and background writeback at different
levels.

Signed-off-by: Andrea Righi <arighi@develer.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/page-writeback.c |   87 ++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 72 insertions(+), 15 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index a0bb3e2..c1db336 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -180,7 +180,7 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
  * Returns the numebr of pages that can currently be freed and used
  * by the kernel for direct mappings.
  */
-static unsigned long determine_dirtyable_memory(void)
+static unsigned long get_global_dirtyable_memory(void)
 {
 	unsigned long x;
 
@@ -192,6 +192,58 @@ static unsigned long determine_dirtyable_memory(void)
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
+static unsigned long get_dirtyable_memory(void)
+{
+	unsigned long memory;
+	s64 memcg_memory;
+
+	memory = get_global_dirtyable_memory();
+	if (!mem_cgroup_has_dirty_limit())
+		return memory;
+	memcg_memory = mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
+	BUG_ON(memcg_memory < 0);
+
+	return min((unsigned long)memcg_memory, memory);
+}
+
+static long get_reclaimable_pages(void)
+{
+	s64 ret;
+
+	if (!mem_cgroup_has_dirty_limit())
+		return global_page_state(NR_FILE_DIRTY) +
+			global_page_state(NR_UNSTABLE_NFS);
+	ret = mem_cgroup_page_stat(MEMCG_NR_RECLAIM_PAGES);
+	BUG_ON(ret < 0);
+
+	return ret;
+}
+
+static long get_writeback_pages(void)
+{
+	s64 ret;
+
+	if (!mem_cgroup_has_dirty_limit())
+		return global_page_state(NR_WRITEBACK);
+	ret = mem_cgroup_page_stat(MEMCG_NR_WRITEBACK);
+	BUG_ON(ret < 0);
+
+	return ret;
+}
+
+static unsigned long get_dirty_writeback_pages(void)
+{
+	s64 ret;
+
+	if (!mem_cgroup_has_dirty_limit())
+		return global_page_state(NR_UNSTABLE_NFS) +
+			global_page_state(NR_WRITEBACK);
+	ret = mem_cgroup_page_stat(MEMCG_NR_DIRTY_WRITEBACK_PAGES);
+	BUG_ON(ret < 0);
+
+	return ret;
+}
+
 /*
  * couple the period to the dirty_ratio:
  *
@@ -204,7 +256,7 @@ static int calc_period_shift(void)
 	if (vm_dirty_bytes)
 		dirty_total = vm_dirty_bytes / PAGE_SIZE;
 	else
-		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
+		dirty_total = (vm_dirty_ratio * get_global_dirtyable_memory()) /
 				100;
 	return 2 + ilog2(dirty_total - 1);
 }
@@ -410,18 +462,23 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 {
 	unsigned long background;
 	unsigned long dirty;
-	unsigned long available_memory = determine_dirtyable_memory();
+	unsigned long available_memory = get_dirtyable_memory();
 	struct task_struct *tsk;
+	struct vm_dirty_param dirty_param;
 
-	if (vm_dirty_bytes)
-		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
+	get_vm_dirty_param(&dirty_param);
+
+	if (dirty_param.dirty_bytes)
+		dirty = DIV_ROUND_UP(dirty_param.dirty_bytes, PAGE_SIZE);
 	else
-		dirty = (vm_dirty_ratio * available_memory) / 100;
+		dirty = (dirty_param.dirty_ratio * available_memory) / 100;
 
-	if (dirty_background_bytes)
-		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
+	if (dirty_param.dirty_background_bytes)
+		background = DIV_ROUND_UP(dirty_param.dirty_background_bytes,
+					  PAGE_SIZE);
 	else
-		background = (dirty_background_ratio * available_memory) / 100;
+		background = (dirty_param.dirty_background_ratio *
+			      available_memory) / 100;
 
 	if (background >= dirty)
 		background = dirty / 2;
@@ -493,9 +550,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 			.range_cyclic	= 1,
 		};
 
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		nr_writeback = global_page_state(NR_WRITEBACK);
+		nr_reclaimable = get_reclaimable_pages();
+		nr_writeback = get_writeback_pages();
 
 		global_dirty_limits(&background_thresh, &dirty_thresh);
 
@@ -652,6 +708,7 @@ void throttle_vm_writeout(gfp_t gfp_mask)
 {
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
+	unsigned long dirty;
 
         for ( ; ; ) {
 		global_dirty_limits(&background_thresh, &dirty_thresh);
@@ -662,9 +719,9 @@ void throttle_vm_writeout(gfp_t gfp_mask)
                  */
                 dirty_thresh += dirty_thresh / 10;      /* wheeee... */
 
-                if (global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK) <= dirty_thresh)
-                        	break;
+		dirty = get_dirty_writeback_pages();
+		if (dirty <= dirty_thresh)
+			break;
                 congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
