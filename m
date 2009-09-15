Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 564586B0099
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:41:57 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 15 Sep 2009 16:45:27 -0400
Message-Id: <20090915204527.4828.97005.sendpatchset@localhost.localdomain>
In-Reply-To: <20090915204327.4828.4349.sendpatchset@localhost.localdomain>
References: <20090915204327.4828.4349.sendpatchset@localhost.localdomain>
Subject: [PATCH 11/11] hugetlb:  offload per node attribute registrations
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 11/11] hugetlb:  offload [un]registration of sysfs attr to worker thread

Against:  2.6.31-mmotm-090914-0157

New in V6

V7:  + remove redundant check for memory{ful|less} node from 
       node_hugetlb_work().  Rely on [added] return from
       hugetlb_register_node() to differentiate between transitions
       to/from memoryless state.

This patch offloads the registration and unregistration of per node
hstate sysfs attributes to a worker thread rather than attempt the
allocation/attachment or detachment/freeing of the attributes in 
the context of the memory hotplug handler.

N.B.,  Only tested build, boot, libhugetlbfs regression.
       i.e., no memory hotplug testing.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 drivers/base/node.c  |   51 ++++++++++++++++++++++++++++++++++++++++++---------
 include/linux/node.h |    5 +++++
 2 files changed, 47 insertions(+), 9 deletions(-)

Index: linux-2.6.31-mmotm-090914-0157/include/linux/node.h
===================================================================
--- linux-2.6.31-mmotm-090914-0157.orig/include/linux/node.h	2009-09-15 13:42:22.000000000 -0400
+++ linux-2.6.31-mmotm-090914-0157/include/linux/node.h	2009-09-15 13:52:09.000000000 -0400
@@ -21,9 +21,14 @@
 
 #include <linux/sysdev.h>
 #include <linux/cpumask.h>
+#include <linux/workqueue.h>
 
 struct node {
 	struct sys_device	sysdev;
+
+#if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
+	struct work_struct	node_work;
+#endif
 };
 
 struct memory_block;
Index: linux-2.6.31-mmotm-090914-0157/drivers/base/node.c
===================================================================
--- linux-2.6.31-mmotm-090914-0157.orig/drivers/base/node.c	2009-09-15 13:52:07.000000000 -0400
+++ linux-2.6.31-mmotm-090914-0157/drivers/base/node.c	2009-09-15 13:52:09.000000000 -0400
@@ -190,11 +190,14 @@ static SYSDEV_ATTR(distance, S_IRUGO, no
 static node_registration_func_t __hugetlb_register_node;
 static node_registration_func_t __hugetlb_unregister_node;
 
-static inline void hugetlb_register_node(struct node *node)
+static inline bool hugetlb_register_node(struct node *node)
 {
 	if (__hugetlb_register_node &&
-			node_state(node->sysdev.id, N_HIGH_MEMORY))
+			node_state(node->sysdev.id, N_HIGH_MEMORY)) {
 		__hugetlb_register_node(node);
+		return true;
+	}
+	return false;
 }
 
 static inline void hugetlb_unregister_node(struct node *node)
@@ -391,10 +394,31 @@ static int link_mem_sections(int nid)
 	return err;
 }
 
+#ifdef CONFIG_HUGETLBFS
 /*
  * Handle per node hstate attribute [un]registration on transistions
  * to/from memoryless state.
  */
+static void node_hugetlb_work(struct work_struct *work)
+{
+	struct node *node = container_of(work, struct node, node_work);
+
+	/*
+	 * We only get here when a node transitions to/from memoryless state.
+	 * We can detect which transition occurred by examining whether the
+	 * node has memory now.  hugetlb_register_node() already check this
+	 * so we try to register the attributes.  If that fails, then the
+	 * node has transitioned to memoryless, try to unregister the
+	 * attributes.
+	 */
+	if (!hugetlb_register_node(node))
+		hugetlb_unregister_node(node);
+}
+
+static void init_node_hugetlb_work(int nid)
+{
+	INIT_WORK(&node_devices[nid].node_work, node_hugetlb_work);
+}
 
 static int node_memory_callback(struct notifier_block *self,
 				unsigned long action, void *arg)
@@ -403,14 +427,16 @@ static int node_memory_callback(struct n
 	int nid = mnb->status_change_nid;
 
 	switch (action) {
-	case MEM_ONLINE:    /* memory successfully brought online */
+	case MEM_ONLINE:
+	case MEM_OFFLINE:
+		/*
+		 * offload per node hstate [un]registration to a work thread
+		 * when transitioning to/from memoryless state.
+		 */
 		if (nid != NUMA_NO_NODE)
-			hugetlb_register_node(&node_devices[nid]);
-		break;
-	case MEM_OFFLINE:   /* or offline */
-		if (nid != NUMA_NO_NODE)
-			hugetlb_unregister_node(&node_devices[nid]);
+			schedule_work(&node_devices[nid].node_work);
 		break;
+
 	case MEM_GOING_ONLINE:
 	case MEM_GOING_OFFLINE:
 	case MEM_CANCEL_ONLINE:
@@ -421,7 +447,8 @@ static int node_memory_callback(struct n
 
 	return NOTIFY_OK;
 }
-#else
+#endif	/* CONFIG_HUGETLBFS */
+#else	/* !CONFIG_MEMORY_HOTPLUG_SPARSE */
 static int link_mem_sections(int nid) { return 0; }
 
 static inline int node_memory_callback(struct notifier_block *self,
@@ -429,6 +456,9 @@ static inline int node_memory_callback(s
 {
 	return NOTIFY_OK;
 }
+
+static void init_node_hugetlb_work(int nid) { }
+
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
 int register_one_node(int nid)
@@ -453,6 +483,9 @@ int register_one_node(int nid)
 
 		/* link memory sections under this node */
 		error = link_mem_sections(nid);
+
+		/* initialize work queue for memory hot plug */
+		init_node_hugetlb_work(nid);
 	}
 
 	return error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
