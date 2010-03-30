Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 49D296B0200
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 05:14:58 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 12/14] Add a tunable that decides when memory should be compacted and when it should be reclaimed
Date: Tue, 30 Mar 2010 10:14:47 +0100
Message-Id: <1269940489-5776-13-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The kernel applies some heuristics when deciding if memory should be
compacted or reclaimed to satisfy a high-order allocation. One of these
is based on the fragmentation. If the index is below 500, memory will
not be compacted. This choice is arbitrary and not based on data. To
help optimise the system and set a sensible default for this value, this
patch adds a sysctl extfrag_threshold. The kernel will only compact
memory if the fragmentation index is above the extfrag_threshold.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 Documentation/sysctl/vm.txt |   18 ++++++++++++++++--
 include/linux/compaction.h  |    3 +++
 kernel/sysctl.c             |   15 +++++++++++++++
 mm/compaction.c             |   12 +++++++++++-
 4 files changed, 45 insertions(+), 3 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 803c018..878b1b4 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -27,6 +27,7 @@ Currently, these files are in /proc/sys/vm:
 - dirty_ratio
 - dirty_writeback_centisecs
 - drop_caches
+- extfrag_threshold
 - hugepages_treat_as_movable
 - hugetlb_shm_group
 - laptop_mode
@@ -131,8 +132,7 @@ out to disk.  This tunable expresses the interval between those wakeups, in
 
 Setting this to zero disables periodic writeback altogether.
 
-==============================================================
-
+============================================================== 
 drop_caches
 
 Writing to this will cause the kernel to drop clean caches, dentries and
@@ -150,6 +150,20 @@ user should run `sync' first.
 
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
index faa3faf..ae98afc 100644
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
index 3838928..b8f292e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -243,6 +243,11 @@ static int min_sched_shares_ratelimit = 100000; /* 100 usec */
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
@@ -1111,6 +1116,16 @@ static struct ctl_table vm_table[] = {
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
index e8ef511..3bb65d7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -418,6 +418,8 @@ static unsigned long compact_zone_order(struct zone *zone,
 	return compact_zone(zone, &cc);
 }
 
+int sysctl_extfrag_threshold = 500;
+
 /**
  * try_to_compact_pages - Direct compact to satisfy a high-order allocation
  * @zonelist: The zonelist used for the current allocation
@@ -476,7 +478,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 		 * Only compact if a failure would be due to fragmentation.
 		 */
 		fragindex = fragmentation_index(zone, order);
-		if (fragindex >= 0 && fragindex <= 500)
+		if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
 			continue;
 
 		if (fragindex == -1 && zone_watermark_ok(zone, order, watermark, 0, 0)) {
@@ -556,6 +558,14 @@ int sysctl_compaction_handler(struct ctl_table *table, int write,
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
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
