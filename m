Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA896B004D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 23:15:23 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 05 Oct 2009 23:18:38 -0400
Message-Id: <20091006031838.22576.61261.sendpatchset@localhost.localdomain>
In-Reply-To: <20091006031739.22576.5248.sendpatchset@localhost.localdomain>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain>
Subject: [PATCH 10/11] hugetlb:  handle memory hot-plug events
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 10/11] hugetlb:  per node attributes -- handle memory hot plug

Against:  2.6.31-mmotm-090925-1435

Register per node hstate attributes only for nodes with memory.

With Memory Hotplug, memory can be added to a memoryless node and
a node with memory can become memoryless.  Therefore, add a memory
on/off-line notifier callback to [un]register a node's attributes
on transition to/from memoryless state.

N.B.,  Only tested build, boot, libhugetlbfs regression.
       i.e., no memory hotplug testing.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/hugetlbpage.txt |    3 +-
 drivers/base/node.c              |   53 +++++++++++++++++++++++++++++++++++----
 2 files changed, 50 insertions(+), 6 deletions(-)

Index: linux-2.6.31-mmotm-090925-1435/drivers/base/node.c
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/drivers/base/node.c	2009-09-30 15:05:20.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/drivers/base/node.c	2009-09-30 15:05:57.000000000 -0400
@@ -177,8 +177,8 @@ static SYSDEV_ATTR(distance, S_IRUGO, no
 /*
  * hugetlbfs per node attributes registration interface:
  * When/if hugetlb[fs] subsystem initializes [sometime after this module],
- * it will register its per node attributes for all nodes online at that
- * time.  It will also call register_hugetlbfs_with_node(), below, to
+ * it will register its per node attributes for all online nodes with
+ * memory.  It will also call register_hugetlbfs_with_node(), below, to
  * register its attribute registration functions with this node driver.
  * Once these hooks have been initialized, the node driver will call into
  * the hugetlb module to [un]register attributes for hot-plugged nodes.
@@ -188,7 +188,8 @@ static node_registration_func_t __hugetl
 
 static inline void hugetlb_register_node(struct node *node)
 {
-	if (__hugetlb_register_node)
+	if (__hugetlb_register_node &&
+			node_state(node->sysdev.id, N_HIGH_MEMORY))
 		__hugetlb_register_node(node);
 }
 
@@ -233,6 +234,7 @@ int register_node(struct node *node, int
 		sysdev_create_file(&node->sysdev, &attr_distance);
 
 		scan_unevictable_register_node(node);
+
 		hugetlb_register_node(node);
 	}
 	return error;
@@ -254,7 +256,7 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_distance);
 
 	scan_unevictable_unregister_node(node);
-	hugetlb_unregister_node(node);
+	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
 
 	sysdev_unregister(&node->sysdev);
 }
@@ -384,8 +386,45 @@ static int link_mem_sections(int nid)
 	}
 	return err;
 }
+
+/*
+ * Handle per node hstate attribute [un]registration on transistions
+ * to/from memoryless state.
+ */
+
+static int node_memory_callback(struct notifier_block *self,
+				unsigned long action, void *arg)
+{
+	struct memory_notify *mnb = arg;
+	int nid = mnb->status_change_nid;
+
+	switch (action) {
+	case MEM_ONLINE:    /* memory successfully brought online */
+		if (nid != NUMA_NO_NODE)
+			hugetlb_register_node(&node_devices[nid]);
+		break;
+	case MEM_OFFLINE:   /* or offline */
+		if (nid != NUMA_NO_NODE)
+			hugetlb_unregister_node(&node_devices[nid]);
+		break;
+	case MEM_GOING_ONLINE:
+	case MEM_GOING_OFFLINE:
+	case MEM_CANCEL_ONLINE:
+	case MEM_CANCEL_OFFLINE:
+	default:
+		break;
+	}
+
+	return NOTIFY_OK;
+}
 #else
 static int link_mem_sections(int nid) { return 0; }
+
+static inline int node_memory_callback(struct notifier_block *self,
+				unsigned long action, void *arg)
+{
+	return NOTIFY_OK;
+}
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
 int register_one_node(int nid)
@@ -499,13 +538,17 @@ static int node_states_init(void)
 	return err;
 }
 
+#define NODE_CALLBACK_PRI	2	/* lower than SLAB */
 static int __init register_node_type(void)
 {
 	int ret;
 
 	ret = sysdev_class_register(&node_class);
-	if (!ret)
+	if (!ret) {
 		ret = node_states_init();
+		hotplug_memory_notifier(node_memory_callback,
+					NODE_CALLBACK_PRI);
+	}
 
 	/*
 	 * Note:  we're not going to unregister the node class if we fail
Index: linux-2.6.31-mmotm-090925-1435/Documentation/vm/hugetlbpage.txt
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/Documentation/vm/hugetlbpage.txt	2009-09-30 15:05:31.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/Documentation/vm/hugetlbpage.txt	2009-09-30 15:05:57.000000000 -0400
@@ -231,7 +231,8 @@ resulting effect on persistent huge page
 Per Node Hugepages Attributes
 
 A subset of the contents of the root huge page control directory in sysfs,
-described above, has been replicated under each "node" system device in:
+described above, will be replicated under each the system device of each
+NUMA node with memory in:
 
 	/sys/devices/system/node/node[0-9]*/hugepages/
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
