From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070529173830.1570.91184.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
References: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 7/7] Add /proc/sys/vm/compact_node for the explicit compaction of a node
Date: Tue, 29 May 2007 18:38:30 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This patch adds a special file /proc/sys/vm/compact_node. When a number is
written to this file, each zone in that node will be compacted. sysfs did
not look appropriate for exporting this trigger. While the current use of
this trigger is for debugging, it is not clear if it should be only exported
via debugfs. Hence, it is exposed via /proc to start with.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 include/linux/compaction.h |    3 ++
 include/linux/sysctl.h     |    1 
 kernel/sysctl.c            |   13 +++++++++
 mm/compaction.c            |   53 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 70 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-110_compact_zone/include/linux/compaction.h linux-2.6.22-rc2-mm1-115_compact_viaproc/include/linux/compaction.h
--- linux-2.6.22-rc2-mm1-110_compact_zone/include/linux/compaction.h	2007-05-29 10:20:32.000000000 +0100
+++ linux-2.6.22-rc2-mm1-115_compact_viaproc/include/linux/compaction.h	2007-05-29 10:23:51.000000000 +0100
@@ -2,6 +2,9 @@
 #define _LINUX_COMPACTION_H
 
 #ifdef CONFIG_MIGRATION
+extern int sysctl_compaction_handler(struct ctl_table *table, int write,
+				struct file *file, void __user *buffer,
+				size_t *length, loff_t *ppos);
 extern int unusable_free_index(struct zone *zone, unsigned int target_order);
 extern int fragmentation_index(struct zone *zone, unsigned int target_order);
 #else
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-110_compact_zone/include/linux/sysctl.h linux-2.6.22-rc2-mm1-115_compact_viaproc/include/linux/sysctl.h
--- linux-2.6.22-rc2-mm1-110_compact_zone/include/linux/sysctl.h	2007-05-24 10:13:34.000000000 +0100
+++ linux-2.6.22-rc2-mm1-115_compact_viaproc/include/linux/sysctl.h	2007-05-29 10:23:51.000000000 +0100
@@ -209,6 +209,7 @@ enum
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
 	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
 	VM_HUGETLB_TREAT_MOVABLE=36, /* Allocate hugepages from ZONE_MOVABLE */
+	VM_COMPACT_NODE = 37,	/* Compact memory within a node */
 
 	/* s390 vm cmm sysctls */
 	VM_CMM_PAGES=1111,
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-110_compact_zone/kernel/sysctl.c linux-2.6.22-rc2-mm1-115_compact_viaproc/kernel/sysctl.c
--- linux-2.6.22-rc2-mm1-110_compact_zone/kernel/sysctl.c	2007-05-24 10:13:34.000000000 +0100
+++ linux-2.6.22-rc2-mm1-115_compact_viaproc/kernel/sysctl.c	2007-05-29 10:23:51.000000000 +0100
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
@@ -829,6 +831,17 @@ static ctl_table vm_table[] = {
 		.proc_handler	= drop_caches_sysctl_handler,
 		.strategy	= &sysctl_intvec,
 	},
+#ifdef CONFIG_MIGRATION
+	{
+		.ctl_name	= VM_COMPACT_NODE,
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
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-110_compact_zone/mm/compaction.c linux-2.6.22-rc2-mm1-115_compact_viaproc/mm/compaction.c
--- linux-2.6.22-rc2-mm1-110_compact_zone/mm/compaction.c	2007-05-29 10:22:15.000000000 +0100
+++ linux-2.6.22-rc2-mm1-115_compact_viaproc/mm/compaction.c	2007-05-29 10:23:51.000000000 +0100
@@ -10,6 +10,7 @@
 #include <linux/vmstat.h>
 #include <linux/swap.h>
 #include <linux/migrate.h>
+#include <linux/sysctl.h>
 #include <linux/swap-prefetch.h>
 #include "internal.h"
 
@@ -372,3 +373,55 @@ static unsigned long compact_zone(struct
 
 	return 0;
 }
+
+/* Compact all zones within a node */
+int compact_node(int nodeid)
+{
+	int zoneid;
+	pg_data_t *pgdat;
+	struct zone *zone;
+	struct compact_control cc;
+
+	if (nodeid < 0)
+		return -EINVAL;
+
+	pgdat = NODE_DATA(nodeid);
+	if (!pgdat || pgdat->node_id != nodeid)
+		return -EINVAL;
+
+	printk(KERN_INFO "Compacting memory in node %d\n", nodeid);
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+
+		zone = &pgdat->node_zones[zoneid];
+		if (!populated_zone(zone))
+			continue;
+
+		cc.nr_freepages = 0,
+		cc.nr_migratepages = 0,
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
