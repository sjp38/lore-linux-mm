Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1B06A620097
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:57:32 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 60 of 67] Add a tunable that decides when memory should be
	compacted and when it should be reclaimed
Message-Id: <d30726d73f79986e7fbf.1270691503@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:43 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

From: Mel Gorman <mel@csn.ul.ie>

The kernel applies some heuristics when deciding if memory should be
compacted or reclaimed to satisfy a high-order allocation. One of these
is based on the fragmentation. If the index is below 500, memory will
not be compacted. This choice is arbitrary and not based on data. To
help optimise the system and set a sensible default for this value, this
patch adds a sysctl extfrag_threshold. The kernel will only compact
memory if the fragmentation index is above the extfrag_threshold.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -27,6 +27,7 @@ Currently, these files are in /proc/sys/
 - dirty_ratio
 - dirty_writeback_centisecs
 - drop_caches
+- extfrag_threshold
 - hugepages_treat_as_movable
 - hugetlb_shm_group
 - laptop_mode
@@ -130,8 +131,7 @@ 100'ths of a second.
 
 Setting this to zero disables periodic writeback altogether.
 
-==============================================================
-
+============================================================== 
 drop_caches
 
 Writing to this will cause the kernel to drop clean caches, dentries and
@@ -149,6 +149,20 @@ user should run `sync' first.
 
 ==============================================================
 
+extfrag_threshold
+
+This parameter affects whether the kernel will compact memory or direct
+reclaim to satisfy a high-order allocation. /proc/extfrag_index shows what
+the fragmentation index for each order is in each zone in the system. Values
+tending towards 0 imply allocations would fail due to lack of memory,
+values towards 1000 imply failures are due to fragmentation and -1 implies
+that the allocation will succeed as long as watermarks are met.
+
+The kernel will not compact memory in a zone if the
+fragmentation index is <= extfrag_threshold. The default value is 500.
+
+==============================================================
+
 hugepages_treat_as_movable
 
 This parameter is only useful when kernelcore= is specified at boot time to
diff --git a/include/linux/compaction.h b/include/linux/compaction.h
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -11,6 +11,9 @@
 extern int sysctl_compact_memory;
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos);
+extern int sysctl_extfrag_threshold;
+extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
+			void __user *buffer, size_t *length, loff_t *ppos);
 
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -241,6 +241,11 @@ static int min_sched_shares_ratelimit = 
 static int max_sched_shares_ratelimit = NSEC_PER_SEC; /* 1 second */
 #endif
 
+#ifdef CONFIG_COMPACTION
+static int min_extfrag_threshold = 0;
+static int max_extfrag_threshold = 1000;
+#endif
+
 static struct ctl_table kern_table[] = {
 	{
 		.procname	= "sched_child_runs_first",
@@ -1108,6 +1113,16 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0200,
 		.proc_handler	= sysctl_compaction_handler,
 	},
+	{
+		.procname	= "extfrag_threshold",
+		.data		= &sysctl_extfrag_threshold,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= sysctl_extfrag_handler,
+		.extra1		= &min_extfrag_threshold,
+		.extra2		= &max_extfrag_threshold,
+	},
+
 #endif /* CONFIG_COMPACTION */
 	{
 		.procname	= "min_free_kbytes",
diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -429,6 +429,8 @@ static unsigned long compact_zone_order(
 	return compact_zone(zone, &cc);
 }
 
+int sysctl_extfrag_threshold = 500;
+
 /**
  * try_to_compact_pages - Direct compact to satisfy a high-order allocation
  * @zonelist: The zonelist used for the current allocation
@@ -487,7 +489,7 @@ unsigned long try_to_compact_pages(struc
 		 * Only compact if a failure would be due to fragmentation.
 		 */
 		fragindex = fragmentation_index(zone, order);
-		if (fragindex >= 0 && fragindex <= 500)
+		if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
 			continue;
 
 		if (fragindex == -1 && zone_watermark_ok(zone, order, watermark, 0, 0)) {
@@ -568,6 +570,14 @@ int sysctl_compaction_handler(struct ctl
 	return 0;
 }
 
+int sysctl_extfrag_handler(struct ctl_table *table, int write,
+			void __user *buffer, size_t *length, loff_t *ppos)
+{
+	proc_dointvec_minmax(table, write, buffer, length, ppos);
+
+	return 0;
+}
+
 #if defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
 ssize_t sysfs_compact_node(struct sys_device *dev,
 			struct sysdev_attribute *attr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
