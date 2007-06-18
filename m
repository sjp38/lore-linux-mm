From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070618093022.7790.37071.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 6/7] Add /proc/sys/vm/compact_node for the explicit compaction of a node
Date: Mon, 18 Jun 2007 10:30:22 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This patch adds a special file /proc/sys/vm/compact_node. When a number is
written to this file, each zone in that node will be compacted.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 include/linux/compaction.h |    7 +++++
 kernel/sysctl.c            |   13 +++++++++
 mm/compaction.c            |   54 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-110_compact_zone/include/linux/compaction.h linux-2.6.22-rc4-mm2-115_compact_viaproc/include/linux/compaction.h
--- linux-2.6.22-rc4-mm2-110_compact_zone/include/linux/compaction.h	2007-06-15 16:28:59.000000000 +0100
+++ linux-2.6.22-rc4-mm2-115_compact_viaproc/include/linux/compaction.h	2007-06-15 16:29:08.000000000 +0100
@@ -5,4 +5,11 @@
 #define COMPACT_INCOMPLETE	0
 #define COMPACT_COMPLETE	1
 
+#ifdef CONFIG_MIGRATION
+
+extern int sysctl_compaction_handler(struct ctl_table *table, int write,
+				struct file *file, void __user *buffer,
+				size_t *length, loff_t *ppos);
+
+#endif /* CONFIG_MIGRATION */
 #endif /* _LINUX_COMPACTION_H */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-110_compact_zone/kernel/sysctl.c linux-2.6.22-rc4-mm2-115_compact_viaproc/kernel/sysctl.c
--- linux-2.6.22-rc4-mm2-110_compact_zone/kernel/sysctl.c	2007-06-13 23:43:12.000000000 +0100
+++ linux-2.6.22-rc4-mm2-115_compact_viaproc/kernel/sysctl.c	2007-06-15 16:29:08.000000000 +0100
@@ -47,6 +47,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/acpi.h>
 #include <linux/reboot.h>
+#include <linux/compaction.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -77,6 +78,7 @@ extern int printk_ratelimit_jiffies;
 extern int printk_ratelimit_burst;
 extern int pid_max_min, pid_max_max;
 extern int sysctl_drop_caches;
+extern int sysctl_compact_node;
 extern int percpu_pagelist_fraction;
 extern int compat_log;
 extern int maps_protect;
@@ -858,6 +860,17 @@ static ctl_table vm_table[] = {
 		.proc_handler	= drop_caches_sysctl_handler,
 		.strategy	= &sysctl_intvec,
 	},
+#ifdef CONFIG_MIGRATION
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "compact_node",
+		.data		= &sysctl_compact_node,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= sysctl_compaction_handler,
+		.strategy	= &sysctl_intvec,
+	},
+#endif /* CONFIG_MIGRATION */
 	{
 		.ctl_name	= VM_MIN_FREE_KBYTES,
 		.procname	= "min_free_kbytes",
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-110_compact_zone/mm/compaction.c linux-2.6.22-rc4-mm2-115_compact_viaproc/mm/compaction.c
--- linux-2.6.22-rc4-mm2-110_compact_zone/mm/compaction.c	2007-06-15 16:28:59.000000000 +0100
+++ linux-2.6.22-rc4-mm2-115_compact_viaproc/mm/compaction.c	2007-06-15 16:29:08.000000000 +0100
@@ -6,6 +6,8 @@
  */
 #include <linux/migrate.h>
 #include <linux/compaction.h>
+#include <linux/swap.h>
+#include <linux/sysctl.h>
 #include "internal.h"
 
 /*
@@ -295,3 +297,55 @@ static int compact_zone(struct zone *zon
 
 	return ret;
 }
+
+/* Compact all zones within a node */
+int compact_node(int nodeid)
+{
+	int zoneid;
+	pg_data_t *pgdat;
+	struct zone *zone;
+
+	if (nodeid < 0 || nodeid > nr_node_ids || !node_online(nodeid))
+		return -EINVAL;
+	pgdat = NODE_DATA(nodeid);
+
+	/* Flush pending updates to the LRU lists */
+	lru_add_drain_all();
+
+	printk(KERN_INFO "Compacting memory in node %d\n", nodeid);
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+		struct compact_control cc;
+
+		zone = &pgdat->node_zones[zoneid];
+		if (!populated_zone(zone))
+			continue;
+
+		cc.nr_freepages = 0;
+		cc.nr_migratepages = 0;
+		INIT_LIST_HEAD(&cc.freepages);
+		INIT_LIST_HEAD(&cc.migratepages);
+
+		compact_zone(zone, &cc);
+
+		VM_BUG_ON(!list_empty(&cc.freepages));
+		VM_BUG_ON(!list_empty(&cc.migratepages));
+	}
+	printk(KERN_INFO "Compaction of node %d complete\n", nodeid);
+
+	return 0;
+}
+
+/* This is global and fierce ugly but it's straight-forward */
+int sysctl_compact_node;
+
+/* This is the entry point for compacting nodes via /proc/sys/vm */
+int sysctl_compaction_handler(struct ctl_table *table, int write,
+			struct file *file, void __user *buffer,
+			size_t *length, loff_t *ppos)
+{
+	proc_dointvec(table, write, file, buffer, length, ppos);
+	if (write)
+		return compact_node(sysctl_compact_node);
+
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
