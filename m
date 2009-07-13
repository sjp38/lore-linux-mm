Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CA64E6B005D
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 01:41:39 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6D62SMh025192
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 13 Jul 2009 15:02:28 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B4BF045DE79
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 15:02:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 924C845DE6F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 15:02:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 516111DB803E
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 15:02:27 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BA2EF1DB803A
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 15:02:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/4][resend]  Show kernel stack usage in /proc/meminfo and OOM log output
In-Reply-To: <20090713144924.6257.A69D9226@jp.fujitsu.com>
References: <20090713144924.6257.A69D9226@jp.fujitsu.com>
Message-Id: <20090713150114.6260.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 13 Jul 2009 15:02:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

ChangeLog
  Since v1
   - Rewrote the descriptin (Thanks Christoph!)

=====================
Subject: [PATCH] Show kernel stack usage in /proc/meminfo and OOM log output

The amount of memory allocated to kernel stacks can become significant and
cause OOM conditions. However, we do not display the amount of memory
consumed by stacks.

Add code to display the amount of memory used for stacks in /proc/meminfo.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 drivers/base/node.c    |    3 +++
 fs/proc/meminfo.c      |    2 ++
 include/linux/mmzone.h |    3 ++-
 kernel/fork.c          |   11 +++++++++++
 mm/page_alloc.c        |    3 +++
 mm/vmstat.c            |    1 +
 6 files changed, 22 insertions(+), 1 deletion(-)

Index: b/fs/proc/meminfo.c
===================================================================
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -84,6 +84,7 @@ static int meminfo_proc_show(struct seq_
 		"Slab:           %8lu kB\n"
 		"SReclaimable:   %8lu kB\n"
 		"SUnreclaim:     %8lu kB\n"
+		"KernelStack:    %8lu kB\n"
 		"PageTables:     %8lu kB\n"
 #ifdef CONFIG_QUICKLIST
 		"Quicklists:     %8lu kB\n"
@@ -128,6 +129,7 @@ static int meminfo_proc_show(struct seq_
 				global_page_state(NR_SLAB_UNRECLAIMABLE)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE)),
 		K(global_page_state(NR_SLAB_UNRECLAIMABLE)),
+		global_page_state(NR_KERNEL_STACK) * THREAD_SIZE / 1024,
 		K(global_page_state(NR_PAGETABLE)),
 #ifdef CONFIG_QUICKLIST
 		K(quicklist_total_size()),
Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -94,10 +94,11 @@ enum zone_stat_item {
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
 	NR_PAGETABLE,		/* used for pagetables */
+	NR_KERNEL_STACK,
+	/* Second 128 byte cacheline */
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_BOUNCE,
 	NR_VMSCAN_WRITE,
-	/* Second 128 byte cacheline */
 	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
Index: b/kernel/fork.c
===================================================================
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -137,9 +137,17 @@ struct kmem_cache *vm_area_cachep;
 /* SLAB cache for mm_struct structures (tsk->mm) */
 static struct kmem_cache *mm_cachep;
 
+static void account_kernel_stack(struct thread_info *ti, int account)
+{
+	struct zone *zone = page_zone(virt_to_page(ti));
+
+	mod_zone_page_state(zone, NR_KERNEL_STACK, account);
+}
+
 void free_task(struct task_struct *tsk)
 {
 	prop_local_destroy_single(&tsk->dirties);
+	account_kernel_stack(tsk->stack, -1);
 	free_thread_info(tsk->stack);
 	rt_mutex_debug_task_free(tsk);
 	ftrace_graph_exit_task(tsk);
@@ -255,6 +263,9 @@ static struct task_struct *dup_task_stru
 	tsk->btrace_seq = 0;
 #endif
 	tsk->splice_pipe = NULL;
+
+	account_kernel_stack(ti, 1);
+
 	return tsk;
 
 out:
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2158,6 +2158,7 @@ void show_free_areas(void)
 			" mapped:%lukB"
 			" slab_reclaimable:%lukB"
 			" slab_unreclaimable:%lukB"
+			" kernel_stack:%lukB"
 			" pagetables:%lukB"
 			" unstable:%lukB"
 			" bounce:%lukB"
@@ -2182,6 +2183,8 @@ void show_free_areas(void)
 			K(zone_page_state(zone, NR_FILE_MAPPED)),
 			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
 			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
+			zone_page_state(zone, NR_KERNEL_STACK) *
+				THREAD_SIZE / 1024,
 			K(zone_page_state(zone, NR_PAGETABLE)),
 			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
 			K(zone_page_state(zone, NR_BOUNCE)),
Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -639,6 +639,7 @@ static const char * const vmstat_text[] 
 	"nr_slab_reclaimable",
 	"nr_slab_unreclaimable",
 	"nr_page_table_pages",
+	"nr_kernel_stack",
 	"nr_unstable",
 	"nr_bounce",
 	"nr_vmscan_write",
Index: b/drivers/base/node.c
===================================================================
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -85,6 +85,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d FilePages:      %8lu kB\n"
 		       "Node %d Mapped:         %8lu kB\n"
 		       "Node %d AnonPages:      %8lu kB\n"
+		       "Node %d KernelStack:    %8lu kB\n"
 		       "Node %d PageTables:     %8lu kB\n"
 		       "Node %d NFS_Unstable:   %8lu kB\n"
 		       "Node %d Bounce:         %8lu kB\n"
@@ -116,6 +117,8 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
+		       nid, node_page_state(nid, NR_KERNEL_STACK) *
+				THREAD_SIZE / 1024,
 		       nid, K(node_page_state(nid, NR_PAGETABLE)),
 		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
 		       nid, K(node_page_state(nid, NR_BOUNCE)),


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
