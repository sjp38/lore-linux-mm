Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3A86B007E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 12:28:52 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 09 Sep 2009 12:32:17 -0400
Message-Id: <20090909163217.12963.5606.sendpatchset@localhost.localdomain>
In-Reply-To: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
Subject: [PATCH 2/3] hugetlb:  handle memory hot-plug events
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 2/3 hugetlb:  per node attributes -- handle memory hot plug

Against:  2.6.31-rc7-mmotm-090827-1651

Register per node hstate attributes only for nodes with memory.

With Memory Hotplug, memory can be added to a memoryless node and
a node with memory can become memoryless.  Therefore, add a memory
on/off-line notifier callback to [un]register a node's attributes
on transition to/from memoryless state.

N.B.,  Only tested build, boot, libhugetlbfs regression.
       i.e., no memory hotplug testing.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/hugetlbpage.txt |    7 ++--
 drivers/base/node.c              |   56 ++++++++++++++++++++++++++++++++++-----
 2 files changed, 54 insertions(+), 9 deletions(-)

Index: linux-2.6.31-rc7-mmotm-090827-1651/drivers/base/node.c
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-1651.orig/drivers/base/node.c	2009-09-09 11:57:37.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-1651/drivers/base/node.c	2009-09-09 11:57:39.000000000 -0400
@@ -180,11 +180,12 @@ static SYSDEV_ATTR(distance, S_IRUGO, no
 /*
  * hugetlbfs per node attributes registration interface:
  * When/if hugetlb[fs] subsystem initializes [sometime after this module],
- * it will register it's per node attributes for all nodes on-line at that
- * point.  It will also call register_hugetlbfs_with_node(), below, to
+ * it will register it's per node attributes for all on-line nodes with
+ * memory.  It will also call register_hugetlbfs_with_node(), below, to
  * register it's attribute registration functions with this node driver.
  * Once these hooks have been initialized, the node driver will call into
- * the hugetlb module to [un]register attributes for hot-plugged nodes.
+ * the hugetlb module to [un]register attributes for hot-plugged nodes
+ * with memory and transitions to/from memoryless state.
  */
 NODE_REGISTRATION_FUNC __hugetlb_register_node;
 NODE_REGISTRATION_FUNC __hugetlb_unregister_node;
@@ -231,7 +232,9 @@ int register_node(struct node *node, int
 		sysdev_create_file(&node->sysdev, &attr_distance);
 
 		scan_unevictable_register_node(node);
-		hugetlb_register_node(node);
+
+		if (node_state(node->sysdev.id, N_HIGH_MEMORY))
+			hugetlb_register_node(node);
 	}
 	return error;
 }
@@ -252,7 +255,7 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_distance);
 
 	scan_unevictable_unregister_node(node);
-	hugetlb_unregister_node(node);
+	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
 
 	sysdev_unregister(&node->sysdev);
 }
@@ -382,8 +385,45 @@ static int link_mem_sections(int nid)
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
@@ -497,13 +537,17 @@ static int node_states_init(void)
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
Index: linux-2.6.31-rc7-mmotm-090827-1651/Documentation/vm/hugetlbpage.txt
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-1651.orig/Documentation/vm/hugetlbpage.txt	2009-09-09 11:57:38.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-1651/Documentation/vm/hugetlbpage.txt	2009-09-09 11:57:39.000000000 -0400
@@ -227,7 +227,8 @@ used.  The effect on persistent huge pag
 Per Node Hugepages Attributes
 
 A subset of the contents of the root huge page control directory in sysfs,
-described above, has been replicated under each "node" system device in:
+described above, will be replicated under each the system device of each
+NUMA node with memory in:
 
 	/sys/devices/system/node/node[0-9]*/hugepages/
 
@@ -248,8 +249,8 @@ pages on the parent node will be adjuste
 resources exist, regardless of the task's mempolicy or cpuset constraints.
 
 Note that the number of overcommit and reserve pages remain global quantities,
-as we don't know until fault time, when the faulting task's mempolicy is applied,
-from which node the huge page allocation will be attempted.
+as we don't know until fault time, when the faulting task's mempolicy is
+applied, from which node the huge page allocation will be attempted.
 
 
 Using Huge Pages:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
