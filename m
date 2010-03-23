Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 149E36B01B5
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 08:25:57 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 09/11] Add /sys trigger for per-node memory compaction
Date: Tue, 23 Mar 2010 12:25:44 +0000
Message-Id: <1269347146-7461-10-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds a per-node sysfs file called compact. When the file is
written to, each zone in that node is compacted. The intention that this
would be used by something like a job scheduler in a batch system before
a job starts so that the job can allocate the maximum number of
hugepages without significant start-up cost.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 Documentation/ABI/testing/sysfs-devices-node |    7 +++++++
 drivers/base/node.c                          |    3 +++
 include/linux/compaction.h                   |   16 ++++++++++++++++
 mm/compaction.c                              |   23 +++++++++++++++++++++++
 4 files changed, 49 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-devices-node

diff --git a/Documentation/ABI/testing/sysfs-devices-node b/Documentation/ABI/testing/sysfs-devices-node
new file mode 100644
index 0000000..0cb286a
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-devices-node
@@ -0,0 +1,7 @@
+What:		/sys/devices/system/node/nodeX/compact
+Date:		February 2010
+Contact:	Mel Gorman <mel@csn.ul.ie>
+Description:
+		When this file is written to, all memory within that node
+		will be compacted. When it completes, memory will be free
+		in as contiguous blocks as possible.
diff --git a/drivers/base/node.c b/drivers/base/node.c
index ad43185..15fb30d 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -15,6 +15,7 @@
 #include <linux/cpu.h>
 #include <linux/device.h>
 #include <linux/swap.h>
+#include <linux/compaction.h>
 
 static struct sysdev_class_attribute *node_state_attrs[];
 
@@ -242,6 +243,8 @@ int register_node(struct node *node, int num, struct node *parent)
 		scan_unevictable_register_node(node);
 
 		hugetlb_register_node(node);
+
+		compaction_register_node(node);
 	}
 	return error;
 }
diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 52762d2..c94890b 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -11,4 +11,20 @@ extern int sysctl_compaction_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos);
 #endif /* CONFIG_COMPACTION */
 
+#if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
+extern int compaction_register_node(struct node *node);
+extern void compaction_unregister_node(struct node *node);
+
+#else
+
+static inline int compaction_register_node(struct node *node)
+{
+	return 0;
+}
+
+static inline void compaction_unregister_node(struct node *node)
+{
+}
+#endif /* CONFIG_COMPACTION && CONFIG_SYSFS && CONFIG_NUMA */
+
 #endif /* _LINUX_COMPACTION_H */
diff --git a/mm/compaction.c b/mm/compaction.c
index faa9b53..8df6e3d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -12,6 +12,7 @@
 #include <linux/compaction.h>
 #include <linux/mm_inline.h>
 #include <linux/sysctl.h>
+#include <linux/sysfs.h>
 #include "internal.h"
 
 /*
@@ -407,3 +408,25 @@ int sysctl_compaction_handler(struct ctl_table *table, int write,
 
 	return 0;
 }
+
+#if defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
+ssize_t sysfs_compact_node(struct sys_device *dev,
+			struct sysdev_attribute *attr,
+			const char *buf, size_t count)
+{
+	compact_node(dev->id);
+
+	return count;
+}
+static SYSDEV_ATTR(compact, S_IWUSR, NULL, sysfs_compact_node);
+
+int compaction_register_node(struct node *node)
+{
+	return sysdev_create_file(&node->sysdev, &attr_compact);
+}
+
+void compaction_unregister_node(struct node *node)
+{
+	return sysdev_remove_file(&node->sysdev, &attr_compact);
+}
+#endif /* CONFIG_SYSFS && CONFIG_NUMA */
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
