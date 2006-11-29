Message-Id: <20061129033826.268090000@menage.corp.google.com>
References: <20061129030655.941148000@menage.corp.google.com>
Date: Tue, 28 Nov 2006 19:06:56 -0800
From: menage@google.com
Subject: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
Content-Disposition: inline; filename=node_reclaim.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Currently the page migration APIs allow you to migrate pages from
particular processes, but don't provide a clean and efficient way to
migrate and/or reclaim memory from individual nodes.

This patch provides:

- an additional parameter to try_to_free_pages() to specify the
  priority at which the reclaim should give up if it doesn't make
  progress

- a way to trigger try_to_free_pages() for a given node with a given
  minimum priority, vy writing an integer to
  /sys/device/system/node/node<id>/try_to_free_pages

- a way to request that any migratable pages on a given node be
  migrated to availage pages on a specified set of nodes by writing a
  destination nodemask (in ASCII form) to
  /sys/device/system/node/node<id>/migrate_node

Signed-off-by: Paul Menage <menage@google.com>

---
 drivers/base/node.c       |   92 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/buffer.c               |    2 -
 include/linux/mempolicy.h |    2 +
 include/linux/swap.h      |    2 -
 mm/mempolicy.c            |    3 -
 mm/page_alloc.c           |    2 -
 mm/vmscan.c               |    5 +-
 7 files changed, 101 insertions(+), 7 deletions(-)

Index: 2.6.19-node_reclaim/drivers/base/node.c
===================================================================
--- 2.6.19-node_reclaim.orig/drivers/base/node.c
+++ 2.6.19-node_reclaim/drivers/base/node.c
@@ -12,6 +12,8 @@
 #include <linux/topology.h>
 #include <linux/nodemask.h>
 #include <linux/cpu.h>
+#include <linux/swap.h>
+#include <linux/migrate.h>
 
 static struct sysdev_class node_class = {
 	set_kset_name("node"),
@@ -137,6 +139,92 @@ static ssize_t node_read_distance(struct
 static SYSDEV_ATTR(distance, S_IRUGO, node_read_distance, NULL);
 
 
+static ssize_t node_store_ttfp(struct sys_device *dev,
+			       struct sysdev_attribute *attr,
+			       const char *buf,
+			       size_t count) {
+	int nid = dev->id;
+	unsigned int priority;
+	struct zonelist *zl;
+	nodemask_t nodes;
+	ssize_t ret = count;
+
+	priority = max(0, min(DEF_PRIORITY, (int)simple_strtoul(buf, NULL, 0)));
+	printk(KERN_INFO "Calling try_to_free_pages(%d, %d)\n",
+	       nid, priority);
+
+	nodes_clear(nodes);
+	node_set(nid, nodes);
+	zl = bind_zonelist(&nodes);
+
+	if (!try_to_free_pages(zl->zones, GFP_USER, priority))
+		ret = -ENOMEM;
+
+	kfree(zl);
+
+	return ret;
+}
+
+static SYSDEV_ATTR(try_to_free_pages, 0200, NULL, node_store_ttfp);
+
+static struct page *migrate_from_node_page(struct page *page,
+					   unsigned long private,
+					   int **result) {
+	struct zonelist *zl = (struct zonelist *) private;
+	return __alloc_pages(GFP_HIGHUSER & ~__GFP_WAIT, 0, zl);
+}
+
+static ssize_t node_store_migrate_node(struct sys_device *dev,
+				       struct sysdev_attribute *attr,
+				       const char *buf,
+				       size_t count) {
+	int nid = dev->id;
+	nodemask_t nodes;
+	ssize_t ret;
+	struct zonelist *zl;
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	int i;
+	int pagecount = 0, failcount = 0;
+	LIST_HEAD(pagelist);
+
+	ret = nodelist_parse(buf, nodes);
+	if (ret)
+		return ret;
+
+	zl = bind_zonelist(&nodes);
+
+	migrate_prep();
+
+	for (i = 0; i < pgdat->node_spanned_pages; ++i) {
+		struct page *page = pgdat_page_nr(pgdat, i);
+		if (!isolate_lru_page(page, &pagelist)) {
+			pagecount++;
+		} else {
+			failcount++;
+		}
+	}
+
+	ret = count;
+	printk(KERN_INFO "Migrating %d pages from node %d\n", pagecount, nid);
+	if (!list_empty(&pagelist)) {
+		int migrate_ret = migrate_pages(&pagelist,
+						migrate_from_node_page,
+						(unsigned long)zl);
+
+		printk(KERN_INFO "migrate_pages returned %d\n", migrate_ret);
+		if (migrate_ret < 0) {
+			ret = migrate_ret;
+		}
+	} else {
+		printk(KERN_INFO "No pages to migrate. Failcount = %d!\n",
+		       failcount++);
+	}
+
+	kfree(zl);
+	return ret;
+}
+
+static SYSDEV_ATTR(migrate_node, 0200, NULL, node_store_migrate_node);
 /*
  * register_node - Setup a driverfs device for a node.
  * @num - Node number to use when creating the device.
@@ -156,6 +244,8 @@ int register_node(struct node *node, int
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
 		sysdev_create_file(&node->sysdev, &attr_numastat);
 		sysdev_create_file(&node->sysdev, &attr_distance);
+		sysdev_create_file(&node->sysdev, &attr_try_to_free_pages);
+		sysdev_create_file(&node->sysdev, &attr_migrate_node);
 	}
 	return error;
 }
@@ -173,6 +263,8 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_meminfo);
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
+	sysdev_remove_file(&node->sysdev, &attr_try_to_free_pages);
+	sysdev_remove_file(&node->sysdev, &attr_migrate_node);
 
 	sysdev_unregister(&node->sysdev);
 }
Index: 2.6.19-node_reclaim/fs/buffer.c
===================================================================
--- 2.6.19-node_reclaim.orig/fs/buffer.c
+++ 2.6.19-node_reclaim/fs/buffer.c
@@ -374,7 +374,7 @@ static void free_more_memory(void)
 	for_each_online_pgdat(pgdat) {
 		zones = pgdat->node_zonelists[gfp_zone(GFP_NOFS)].zones;
 		if (*zones)
-			try_to_free_pages(zones, GFP_NOFS);
+			try_to_free_pages(zones, GFP_NOFS, 0);
 	}
 }
 
Index: 2.6.19-node_reclaim/include/linux/mempolicy.h
===================================================================
--- 2.6.19-node_reclaim.orig/include/linux/mempolicy.h
+++ 2.6.19-node_reclaim/include/linux/mempolicy.h
@@ -175,6 +175,8 @@ int do_migrate_pages(struct mm_struct *m
 
 extern void *cpuset_being_rebound;	/* Trigger mpol_copy vma rebind */
 
+struct zonelist *bind_zonelist(nodemask_t *nodes);
+
 #else
 
 struct mempolicy {};
Index: 2.6.19-node_reclaim/include/linux/swap.h
===================================================================
--- 2.6.19-node_reclaim.orig/include/linux/swap.h
+++ 2.6.19-node_reclaim/include/linux/swap.h
@@ -187,7 +187,7 @@ extern int rotate_reclaimable_page(struc
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
-extern unsigned long try_to_free_pages(struct zone **, gfp_t);
+extern unsigned long try_to_free_pages(struct zone **, gfp_t, int priority);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
Index: 2.6.19-node_reclaim/mm/mempolicy.c
===================================================================
--- 2.6.19-node_reclaim.orig/mm/mempolicy.c
+++ 2.6.19-node_reclaim/mm/mempolicy.c
@@ -134,7 +134,7 @@ static int mpol_check_policy(int mode, n
 }
 
 /* Generate a custom zonelist for the BIND policy. */
-static struct zonelist *bind_zonelist(nodemask_t *nodes)
+struct zonelist *bind_zonelist(nodemask_t *nodes)
 {
 	struct zonelist *zl;
 	int num, max, nd;
@@ -1908,4 +1908,3 @@ out:
 		m->version = (vma != priv->tail_vma) ? vma->vm_start : 0;
 	return 0;
 }
-
Index: 2.6.19-node_reclaim/mm/page_alloc.c
===================================================================
--- 2.6.19-node_reclaim.orig/mm/page_alloc.c
+++ 2.6.19-node_reclaim/mm/page_alloc.c
@@ -1371,7 +1371,7 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist->zones, gfp_mask);
+	did_some_progress = try_to_free_pages(zonelist->zones, gfp_mask, 0);
 
 	p->reclaim_state = NULL;
 
Index: 2.6.19-node_reclaim/mm/vmscan.c
===================================================================
--- 2.6.19-node_reclaim.orig/mm/vmscan.c
+++ 2.6.19-node_reclaim/mm/vmscan.c
@@ -1014,7 +1014,8 @@ static unsigned long shrink_zones(int pr
  * holds filesystem locks which prevent writeout this might not work, and the
  * allocation attempt will fail.
  */
-unsigned long try_to_free_pages(struct zone **zones, gfp_t gfp_mask)
+unsigned long try_to_free_pages(struct zone **zones, gfp_t gfp_mask,
+				int min_priority)
 {
 	int priority;
 	int ret = 0;
@@ -1057,7 +1058,7 @@ unsigned long try_to_free_pages(struct z
 		lru_pages += zone->nr_active + zone->nr_inactive;
 	}
 
-	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
+	for (priority = DEF_PRIORITY; priority >= min_priority; priority--) {
 		sc.nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
