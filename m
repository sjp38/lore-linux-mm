Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 198196B007E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 12:29:12 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 09 Sep 2009 12:32:23 -0400
Message-Id: <20090909163223.12963.51024.sendpatchset@localhost.localdomain>
In-Reply-To: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
Subject: [PATCH 3/3] hugetlb:  offload per node attribute registrations
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 3/3 hugetlb:  offload [un]registration of sysfs attr to worker thread

Against:  2.6.31-rc7-mmotm-090827-1651

This patch offloads the registration and unregistration of per node
hstate sysfs attributes to a worker thread rather than attempt the
allocation/attachment or detachment/freeing of the attributes in 
the context of the memory hotplug handler.

N.B.,  Only tested build, boot, libhugetlbfs regression.
       i.e., no memory hotplug testing.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 drivers/base/node.c  |   34 ++++++++++++++++++++++++++++------
 include/linux/node.h |    5 +++++
 2 files changed, 33 insertions(+), 6 deletions(-)

Index: linux-2.6.31-rc7-mmotm-090827-1651/include/linux/node.h
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-1651.orig/include/linux/node.h	2009-09-09 11:57:37.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-1651/include/linux/node.h	2009-09-09 11:57:39.000000000 -0400
@@ -21,9 +21,14 @@
 
 #include <linux/sysdev.h>
 #include <linux/cpumask.h>
+#include <linux/workqueue.h>
 
 struct node {
 	struct sys_device	sysdev;
+
+#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
+	struct work_struct	node_work;
+#endif
 };
 
 struct memory_block;
Index: linux-2.6.31-rc7-mmotm-090827-1651/drivers/base/node.c
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-1651.orig/drivers/base/node.c	2009-09-09 11:57:39.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-1651/drivers/base/node.c	2009-09-09 11:57:39.000000000 -0400
@@ -390,6 +390,20 @@ static int link_mem_sections(int nid)
  * Handle per node hstate attribute [un]registration on transistions
  * to/from memoryless state.
  */
+static void node_hugetlb_work(struct work_struct *work)
+{
+	struct node *node = container_of(work, struct node, node_work);
+
+	if (node_state(node->sysdev.id, N_HIGH_MEMORY))
+		hugetlb_register_node(node);
+	else
+		hugetlb_unregister_node(node);
+}
+
+static void init_node_hugetlb_work(int nid)
+{
+	INIT_WORK(&node_devices[nid].node_work, node_hugetlb_work);
+}
 
 static int node_memory_callback(struct notifier_block *self,
 				unsigned long action, void *arg)
@@ -398,14 +412,16 @@ static int node_memory_callback(struct n
 	int nid = mnb->status_change_nid;
 
 	switch (action) {
-	case MEM_ONLINE:    /* memory successfully brought online */
+	case MEM_ONLINE:
+	case MEM_OFFLINE:
+		/*
+		 * offload per node hstate[un]registration to work thread
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
@@ -424,6 +440,9 @@ static inline int node_memory_callback(s
 {
 	return NOTIFY_OK;
 }
+
+static void init_node_hugetlb_work(int nid) { }
+
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
 int register_one_node(int nid)
@@ -448,6 +467,9 @@ int register_one_node(int nid)
 
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
