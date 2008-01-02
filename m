From: linux-kernel@vger.kernel.org
Subject: [patch 12/19] scan noreclaim list for reclaimable pages
Date: Wed, 02 Jan 2008 17:41:56 -0500
Message-ID: <20080102224154.825971702@redhat.com>
References: <20080102224144.885671949@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759993AbYABXZr@vger.kernel.org>
Content-Disposition: inline; filename=noreclaim-01.3-scan-noreclaim-list-for-reclaimable-pages.patch
Sender: linux-kernel-owner@vger.kernel.org
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com
List-Id: linux-mm.kvack.org

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split LRU series

New in V2

This patch adds a function to scan individual or all zones' noreclaim
lists and move any pages that have become reclaimable onto the respective
zone's inactive list, where shrink_inactive_list() will deal with them.

This replaces the function to splice the entire noreclaim list onto the
active list for rescan by shrink_active_list().  That method had problems
with vmstat accounting and complicated '[__]isolate_lru_pages()'.  Now,
__isolate_lru_page() will never isolate a non-reclaimable page.  The
only time it should see one is when scanning nearby pages for lumpy
reclaim.

  TODO:  This approach may still need some refinement.
         E.g., put back to active list?

DEBUGGING ONLY: NOT FOR UPSTREAM MERGE

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by:  Rik van Riel <riel@redhat.com>


Index: linux-2.6.24-rc6-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/swap.h	2008-01-02 13:00:16.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/swap.h	2008-01-02 13:07:09.000000000 -0500
@@ -7,6 +7,7 @@
 #include <linux/list.h>
 #include <linux/sched.h>
 #include <linux/memcontrol.h>
+#include <linux/node.h>
 
 #include <asm/atomic.h>
 #include <asm/page.h>
@@ -215,12 +216,26 @@ static inline int zone_reclaim(struct zo
 
 #ifdef CONFIG_NORECLAIM
 extern int page_reclaimable(struct page *page, struct vm_area_struct *vma);
+extern void scan_zone_noreclaim_pages(struct zone *);
+extern void scan_all_zones_noreclaim_pages(void);
+extern unsigned long scan_noreclaim_pages;
+extern int scan_noreclaim_handler(struct ctl_table *, int, struct file *,
+					void __user *, size_t *, loff_t *);
+extern int scan_noreclaim_register_node(struct node *node);
+extern void scan_noreclaim_unregister_node(struct node *node);
 #else
 static inline int page_reclaimable(struct page *page,
 						struct vm_area_struct *vma)
 {
 	return 1;
 }
+static inline void scan_zone_noreclaim_pages(struct zone *z) { }
+static inline void scan_all_zones_noreclaim_pages(void) { }
+static inline int scan_noreclaim_register_node(struct node *node)
+{
+	return 0;
+}
+static inline void scan_noreclaim_unregister_node(struct node *node) { }
 #endif
 
 extern int kswapd_run(int nid);
Index: linux-2.6.24-rc6-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmscan.c	2008-01-02 13:00:16.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmscan.c	2008-01-02 13:07:09.000000000 -0500
@@ -39,6 +39,7 @@
 #include <linux/kthread.h>
 #include <linux/freezer.h>
 #include <linux/memcontrol.h>
+#include <linux/sysctl.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -2249,4 +2250,144 @@ int page_reclaimable(struct page *page, 
 
 	return 1;
 }
+
+/**
+ * scan_zone_noreclaim_pages(@zone)
+ * @zone - zone to scan
+ *
+ * Scan @zone's noreclaim LRU lists to check for pages that have become
+ * reclaimable.  Move those that have to @zone's inactive list where they
+ * become candidates for reclaim, unless shrink_inactive_zone() decides
+ * to reactivate them.  Pages that are still non-reclaimable are rotated
+ * back onto @zone's noreclaim list.
+ */
+#define SCAN_NORECLAIM_BATCH_SIZE 16UL	/* arbitrary lock hold batch size */
+void scan_zone_noreclaim_pages(struct zone *zone)
+{
+	struct list_head *l_noreclaim = &zone->list[LRU_NORECLAIM];
+	struct list_head *l_inactive_anon  = &zone->list[LRU_INACTIVE_ANON];
+	struct list_head *l_inactive_file  = &zone->list[LRU_INACTIVE_FILE];
+	unsigned long scan;
+	unsigned long nr_to_scan = zone_page_state(zone, NR_NORECLAIM);
+
+	while (nr_to_scan > 0) {
+		unsigned long batch_size = min(nr_to_scan,
+						SCAN_NORECLAIM_BATCH_SIZE);
+
+		spin_lock_irq(&zone->lru_lock);
+		for (scan = 0;  scan < batch_size; scan++) {
+			struct page* page = lru_to_page(l_noreclaim);
+
+			if (unlikely(!PageLRU(page) || !PageNoreclaim(page)))
+				continue;
+
+			prefetchw_prev_lru_page(page, l_noreclaim, flags);
+
+			ClearPageNoreclaim(page); /* for page_reclaimable() */
+			if(page_reclaimable(page, NULL)) {
+				__dec_zone_state(zone, NR_NORECLAIM);
+				if (page_file_cache(page)) {
+					list_move(&page->lru, l_inactive_file);
+					__inc_zone_state(zone, NR_INACTIVE_FILE);
+				} else {
+					list_move(&page->lru, l_inactive_anon);
+					__inc_zone_state(zone, NR_INACTIVE_ANON);
+				}
+			} else {
+				SetPageNoreclaim(page);
+				list_move(&page->lru, l_noreclaim);
+			}
+
+		}
+		spin_unlock_irq(&zone->lru_lock);
+
+		nr_to_scan -= batch_size;
+	}
+}
+
+
+/**
+ * scan_all_zones_noreclaim_pages()
+ *
+ * A really big hammer:  scan all zones' noreclaim LRU lists to check for
+ * pages that have become reclaimable.  Move those back to the zones'
+ * inactive list where they become candidates for reclaim.
+ * This occurs when, e.g., we have unswappable pages on the noreclaim lists,
+ * and we add swap to the system.  As such, it runs in the context of a task
+ * that has possibly/probably made some previously non-reclaimable pages
+ * reclaimable.
+//TODO:  or as a last resort under extreme memory pressure--before OOM?
+ */
+void scan_all_zones_noreclaim_pages(void)
+{
+	struct zone *zone;
+
+	for_each_zone(zone) {
+		scan_zone_noreclaim_pages(zone);
+	}
+}
+
+/*
+ * scan_noreclaim_pages [vm] sysctl handler.  On demand re-scan of
+ * all nodes' noreclaim lists for reclaimable pages
+ */
+unsigned long scan_noreclaim_pages;
+
+int scan_noreclaim_handler( struct ctl_table *table, int write,
+			   struct file *file, void __user *buffer,
+			   size_t *length, loff_t *ppos)
+{
+	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+
+	if (write && *(unsigned long *)table->data)
+		scan_all_zones_noreclaim_pages();
+
+	scan_noreclaim_pages = 0;
+	return 0;
+}
+
+/*
+ * per node 'scan_noreclaim_pages' attribute.  On demand re-scan of
+ * a specified node's per zone noreclaim lists for reclaimable pages.
+ */
+
+static ssize_t read_scan_noreclaim_node(struct sys_device *dev, char *buf)
+{
+	return sprintf(buf, "0\n");	/* always zero; should fit... */
+}
+
+static ssize_t write_scan_noreclaim_node(struct sys_device *dev,
+                                       const char *buf, size_t count)
+{
+	struct zone *node_zones = NODE_DATA(dev->id)->node_zones;
+	struct zone *zone;
+	unsigned long req = simple_strtoul(buf, NULL, 10);
+
+	if (!req)
+		return 1;	/* zero is no-op */
+
+	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
+		if (!populated_zone(zone))
+			continue;
+		scan_zone_noreclaim_pages(zone);
+	}
+	return 1;
+}
+
+
+static SYSDEV_ATTR(scan_noreclaim_pages, S_IRUGO | S_IWUSR,
+			read_scan_noreclaim_node,
+			write_scan_noreclaim_node);
+
+int scan_noreclaim_register_node(struct node *node)
+{
+	return sysdev_create_file(&node->sysdev, &attr_scan_noreclaim_pages);
+}
+
+void scan_noreclaim_unregister_node(struct node *node)
+{
+	sysdev_remove_file(&node->sysdev, &attr_scan_noreclaim_pages);
+}
+
+
 #endif
Index: linux-2.6.24-rc6-mm1/kernel/sysctl.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/kernel/sysctl.c	2007-12-23 23:45:44.000000000 -0500
+++ linux-2.6.24-rc6-mm1/kernel/sysctl.c	2008-01-02 13:07:09.000000000 -0500
@@ -1151,6 +1151,16 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+#ifdef CONFIG_NORECLAIM
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "scan_noreclaim_pages",
+		.data		= &scan_noreclaim_pages,
+		.maxlen		= sizeof(scan_noreclaim_pages),
+		.mode		= 0644,
+		.proc_handler	= &scan_noreclaim_handler,
+	},
+#endif
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
Index: linux-2.6.24-rc6-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/drivers/base/node.c	2008-01-02 13:00:37.000000000 -0500
+++ linux-2.6.24-rc6-mm1/drivers/base/node.c	2008-01-02 13:07:09.000000000 -0500
@@ -13,6 +13,7 @@
 #include <linux/nodemask.h>
 #include <linux/cpu.h>
 #include <linux/device.h>
+#include <linux/swap.h>
 
 static struct sysdev_class node_class = {
 	.name = "node",
@@ -162,6 +163,8 @@ int register_node(struct node *node, int
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
 		sysdev_create_file(&node->sysdev, &attr_numastat);
 		sysdev_create_file(&node->sysdev, &attr_distance);
+
+		scan_noreclaim_register_node(node);
 	}
 	return error;
 }
@@ -180,6 +183,8 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
 
+	scan_noreclaim_unregister_node(node);
+
 	sysdev_unregister(&node->sysdev);
 }
 

-- 
All Rights Reversed

