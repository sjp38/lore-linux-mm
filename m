Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 197356B0071
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 07:48:24 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 4/8] numa: convert static memory to dynamically allocated memory for per node device
Date: Wed, 31 Oct 2012 19:23:10 +0800
Message-Id: <1351682594-17347-5-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351682594-17347-1-git-send-email-wency@cn.fujitsu.com>
References: <1351682594-17347-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org
Cc: Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rjw@sisk.pl, Lai Jiangshan <laijs@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>

We use a static array to store struct node. In many cases, we don't have too
many nodes, and some memory will be unused. Convert it to per-device
dynamically allocated memory.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 arch/powerpc/kernel/sysfs.c |  4 ++--
 drivers/base/node.c         | 38 ++++++++++++++++++++++----------------
 include/linux/node.h        |  2 +-
 mm/hugetlb.c                |  4 ++--
 4 files changed, 27 insertions(+), 21 deletions(-)

diff --git a/arch/powerpc/kernel/sysfs.c b/arch/powerpc/kernel/sysfs.c
index cf357a0..3ce1f86 100644
--- a/arch/powerpc/kernel/sysfs.c
+++ b/arch/powerpc/kernel/sysfs.c
@@ -607,7 +607,7 @@ static void register_nodes(void)
 
 int sysfs_add_device_to_node(struct device *dev, int nid)
 {
-	struct node *node = &node_devices[nid];
+	struct node *node = node_devices[nid];
 	return sysfs_create_link(&node->dev.kobj, &dev->kobj,
 			kobject_name(&dev->kobj));
 }
@@ -615,7 +615,7 @@ EXPORT_SYMBOL_GPL(sysfs_add_device_to_node);
 
 void sysfs_remove_device_from_node(struct device *dev, int nid)
 {
-	struct node *node = &node_devices[nid];
+	struct node *node = node_devices[nid];
 	sysfs_remove_link(&node->dev.kobj, kobject_name(&dev->kobj));
 }
 EXPORT_SYMBOL_GPL(sysfs_remove_device_from_node);
diff --git a/drivers/base/node.c b/drivers/base/node.c
index af1a177..28216ce 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -306,7 +306,7 @@ void unregister_node(struct node *node)
 	device_unregister(&node->dev);
 }
 
-struct node node_devices[MAX_NUMNODES];
+struct node *node_devices[MAX_NUMNODES];
 
 /*
  * register cpu under node
@@ -323,15 +323,15 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
 	if (!obj)
 		return 0;
 
-	ret = sysfs_create_link(&node_devices[nid].dev.kobj,
+	ret = sysfs_create_link(&node_devices[nid]->dev.kobj,
 				&obj->kobj,
 				kobject_name(&obj->kobj));
 	if (ret)
 		return ret;
 
 	return sysfs_create_link(&obj->kobj,
-				 &node_devices[nid].dev.kobj,
-				 kobject_name(&node_devices[nid].dev.kobj));
+				 &node_devices[nid]->dev.kobj,
+				 kobject_name(&node_devices[nid]->dev.kobj));
 }
 
 int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
@@ -345,10 +345,10 @@ int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 	if (!obj)
 		return 0;
 
-	sysfs_remove_link(&node_devices[nid].dev.kobj,
+	sysfs_remove_link(&node_devices[nid]->dev.kobj,
 			  kobject_name(&obj->kobj));
 	sysfs_remove_link(&obj->kobj,
-			  kobject_name(&node_devices[nid].dev.kobj));
+			  kobject_name(&node_devices[nid]->dev.kobj));
 
 	return 0;
 }
@@ -390,15 +390,15 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
 			continue;
 		if (page_nid != nid)
 			continue;
-		ret = sysfs_create_link_nowarn(&node_devices[nid].dev.kobj,
+		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
 					&mem_blk->dev.kobj,
 					kobject_name(&mem_blk->dev.kobj));
 		if (ret)
 			return ret;
 
 		return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
-				&node_devices[nid].dev.kobj,
-				kobject_name(&node_devices[nid].dev.kobj));
+				&node_devices[nid]->dev.kobj,
+				kobject_name(&node_devices[nid]->dev.kobj));
 	}
 	/* mem section does not span the specified node */
 	return 0;
@@ -431,10 +431,10 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 			continue;
 		if (node_test_and_set(nid, *unlinked_nodes))
 			continue;
-		sysfs_remove_link(&node_devices[nid].dev.kobj,
+		sysfs_remove_link(&node_devices[nid]->dev.kobj,
 			 kobject_name(&mem_blk->dev.kobj));
 		sysfs_remove_link(&mem_blk->dev.kobj,
-			 kobject_name(&node_devices[nid].dev.kobj));
+			 kobject_name(&node_devices[nid]->dev.kobj));
 	}
 	NODEMASK_FREE(unlinked_nodes);
 	return 0;
@@ -500,7 +500,7 @@ static void node_hugetlb_work(struct work_struct *work)
 
 static void init_node_hugetlb_work(int nid)
 {
-	INIT_WORK(&node_devices[nid].node_work, node_hugetlb_work);
+	INIT_WORK(&node_devices[nid]->node_work, node_hugetlb_work);
 }
 
 static int node_memory_callback(struct notifier_block *self,
@@ -517,7 +517,7 @@ static int node_memory_callback(struct notifier_block *self,
 		 * when transitioning to/from memoryless state.
 		 */
 		if (nid != NUMA_NO_NODE)
-			schedule_work(&node_devices[nid].node_work);
+			schedule_work(&node_devices[nid]->node_work);
 		break;
 
 	case MEM_GOING_ONLINE:
@@ -558,9 +558,13 @@ int register_one_node(int nid)
 		struct node *parent = NULL;
 
 		if (p_node != nid)
-			parent = &node_devices[p_node];
+			parent = node_devices[p_node];
 
-		error = register_node(&node_devices[nid], nid, parent);
+		node_devices[nid] = kzalloc(sizeof(struct node), GFP_KERNEL);
+		if (!node_devices[nid])
+			return -ENOMEM;
+
+		error = register_node(node_devices[nid], nid, parent);
 
 		/* link cpu under this node */
 		for_each_present_cpu(cpu) {
@@ -581,7 +585,9 @@ int register_one_node(int nid)
 
 void unregister_one_node(int nid)
 {
-	unregister_node(&node_devices[nid]);
+	unregister_node(node_devices[nid]);
+	kfree(node_devices[nid]);
+	node_devices[nid] = NULL;
 }
 
 /*
diff --git a/include/linux/node.h b/include/linux/node.h
index 624e53c..10316f1 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -27,7 +27,7 @@ struct node {
 };
 
 struct memory_block;
-extern struct node node_devices[];
+extern struct node *node_devices[];
 typedef  void (*node_registration_func_t)(struct node *);
 
 extern int register_node(struct node *, int, struct node *);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 59a0059..1ef2cd4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1800,7 +1800,7 @@ static void hugetlb_unregister_all_nodes(void)
 	 * remove hstate attributes from any nodes that have them.
 	 */
 	for (nid = 0; nid < nr_node_ids; nid++)
-		hugetlb_unregister_node(&node_devices[nid]);
+		hugetlb_unregister_node(node_devices[nid]);
 }
 
 /*
@@ -1845,7 +1845,7 @@ static void hugetlb_register_all_nodes(void)
 	int nid;
 
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		struct node *node = &node_devices[nid];
+		struct node *node = node_devices[nid];
 		if (node->dev.id == nid)
 			hugetlb_register_node(node);
 	}
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
