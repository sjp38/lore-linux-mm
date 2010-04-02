Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AEF0B6B01FD
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 12:02:53 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 09/14] Add /proc trigger for memory compaction
Date: Fri,  2 Apr 2010 17:02:43 +0100
Message-Id: <1270224168-14775-10-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds a proc file /proc/sys/vm/compact_memory. When an arbitrary
value is written to the file, all zones are compacted. The expected user
of such a trigger is a job scheduler that prepares the system before the
target application runs.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
---
 Documentation/sysctl/vm.txt |   11 +++++++
 include/linux/compaction.h  |    6 ++++
 kernel/sysctl.c             |   10 +++++++
 mm/compaction.c             |   62 ++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 88 insertions(+), 1 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 56366a5..803c018 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -19,6 +19,7 @@ files can be found in mm/swap.c.
 Currently, these files are in /proc/sys/vm:
 
 - block_dump
+- compact_memory
 - dirty_background_bytes
 - dirty_background_ratio
 - dirty_bytes
@@ -64,6 +65,16 @@ information on block I/O debugging is in Documentation/laptops/laptop-mode.txt.
 
 ==============================================================
 
+compact_memory
+
+Available only when CONFIG_COMPACTION is set. When an arbitrary value
+is written to the file, all zones are compacted such that free memory
+is available in contiguous blocks where possible. This can be important
+for example in the allocation of huge pages although processes will also
+directly compact memory as required.
+
+==============================================================
+
 dirty_background_bytes
 
 Contains the amount of dirty memory at which the pdflush background writeback
diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index dbebe58..fef591b 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -6,4 +6,10 @@
 #define COMPACT_PARTIAL		1
 #define COMPACT_COMPLETE	2
 
+#ifdef CONFIG_COMPACTION
+extern int sysctl_compact_memory;
+extern int sysctl_compaction_handler(struct ctl_table *table, int write,
+			void __user *buffer, size_t *length, loff_t *ppos);
+#endif /* CONFIG_COMPACTION */
+
 #endif /* _LINUX_COMPACTION_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 455f394..3838928 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -53,6 +53,7 @@
 #include <linux/slow-work.h>
 #include <linux/perf_event.h>
 #include <linux/kprobes.h>
+#include <linux/compaction.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -1102,6 +1103,15 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= drop_caches_sysctl_handler,
 	},
+#ifdef CONFIG_COMPACTION
+	{
+		.procname	= "compact_memory",
+		.data		= &sysctl_compact_memory,
+		.maxlen		= sizeof(int),
+		.mode		= 0200,
+		.proc_handler	= sysctl_compaction_handler,
+	},
+#endif /* CONFIG_COMPACTION */
 	{
 		.procname	= "min_free_kbytes",
 		.data		= &min_free_kbytes,
diff --git a/mm/compaction.c b/mm/compaction.c
index 4041209..615b811 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -12,6 +12,7 @@
 #include <linux/compaction.h>
 #include <linux/mm_inline.h>
 #include <linux/backing-dev.h>
+#include <linux/sysctl.h>
 #include "internal.h"
 
 /*
@@ -322,7 +323,7 @@ static void update_nr_listpages(struct compact_control *cc)
 	cc->nr_freepages = nr_freepages;
 }
 
-static inline int compact_finished(struct zone *zone,
+static int compact_finished(struct zone *zone,
 						struct compact_control *cc)
 {
 	if (fatal_signal_pending(current))
@@ -377,3 +378,62 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	return ret;
 }
 
+/* Compact all zones within a node */
+static int compact_node(int nid)
+{
+	int zoneid;
+	pg_data_t *pgdat;
+	struct zone *zone;
+
+	if (nid < 0 || nid >= nr_node_ids || !node_online(nid))
+		return -EINVAL;
+	pgdat = NODE_DATA(nid);
+
+	/* Flush pending updates to the LRU lists */
+	lru_add_drain_all();
+
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+		struct compact_control cc;
+
+		zone = &pgdat->node_zones[zoneid];
+		if (!populated_zone(zone))
+			continue;
+
+		cc.nr_freepages = 0;
+		cc.nr_migratepages = 0;
+		cc.zone = zone;
+		INIT_LIST_HEAD(&cc.freepages);
+		INIT_LIST_HEAD(&cc.migratepages);
+
+		compact_zone(zone, &cc);
+
+		VM_BUG_ON(!list_empty(&cc.freepages));
+		VM_BUG_ON(!list_empty(&cc.migratepages));
+	}
+
+	return 0;
+}
+
+/* Compact all nodes in the system */
+static int compact_nodes(void)
+{
+	int nid;
+
+	for_each_online_node(nid)
+		compact_node(nid);
+
+	return COMPACT_COMPLETE;
+}
+
+/* The written value is actually unused, all memory is compacted */
+int sysctl_compact_memory;
+
+/* This is the entry point for compacting all nodes via /proc/sys/vm */
+int sysctl_compaction_handler(struct ctl_table *table, int write,
+			void __user *buffer, size_t *length, loff_t *ppos)
+{
+	if (write)
+		return compact_nodes();
+
+	return 0;
+}
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
