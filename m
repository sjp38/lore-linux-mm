Message-Id: <20080611184340.245727738@redhat.com>
References: <20080611184214.605110868@redhat.com>
Date: Wed, 11 Jun 2008 14:42:36 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 22/24] vmscan: unevictable LRU scan sysctl
Content-Disposition: inline; filename=mm-only-vmscan-noreclaim-lru-scan-sysctl.patch
Sender: owner-linux-mm@kvack.org
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

This patch adds a function to scan individual or all zones' unevictable
lists and move any pages that have become evictable onto the respective
zone's inactive list, where shrink_inactive_list() will deal with them.

Adds sysctl to scan all nodes, and per node attributes to individual
nodes' zones.

Kosaki:
If evictable page found in unevictable lru when write
/proc/sys/vm/scan_unevictable_pages, print filename and file offset of
these pages.

---
TODO:  DEBUGGING ONLY: NOT FOR UPSTREAM MERGE

V6:
+ moved to end of series as optional debug patch

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split LRU series

New in V2

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


 drivers/base/node.c  |    5 +
 include/linux/rmap.h |    3 
 include/linux/swap.h |   15 ++++
 kernel/sysctl.c      |   10 +++
 mm/rmap.c            |    4 -
 mm/vmscan.c          |  163 +++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 198 insertions(+), 2 deletions(-)

Index: linux-2.6.26-rc5-mm2/include/linux/swap.h
===================================================================
--- linux-2.6.26-rc5-mm2.orig/include/linux/swap.h	2008-06-10 22:38:56.000000000 -0400
+++ linux-2.6.26-rc5-mm2/include/linux/swap.h	2008-06-10 22:38:58.000000000 -0400
@@ -7,6 +7,7 @@
 #include <linux/list.h>
 #include <linux/memcontrol.h>
 #include <linux/sched.h>
+#include <linux/node.h>
 
 #include <asm/atomic.h>
 #include <asm/page.h>
@@ -235,15 +236,29 @@ static inline int zone_reclaim(struct zo
 #ifdef CONFIG_UNEVICTABLE_LRU
 extern int page_evictable(struct page *page, struct vm_area_struct *vma);
 extern void scan_mapping_unevictable_pages(struct address_space *);
+
+extern unsigned long scan_unevictable_pages;
+extern int scan_unevictable_handler(struct ctl_table *, int, struct file *,
+					void __user *, size_t *, loff_t *);
+extern int scan_unevictable_register_node(struct node *node);
+extern void scan_unevictable_unregister_node(struct node *node);
 #else
 static inline int page_evictable(struct page *page,
 						struct vm_area_struct *vma)
 {
 	return 1;
 }
+
 static inline void scan_mapping_unevictable_pages(struct address_space *mapping)
 {
 }
+
+static inline int scan_unevictable_register_node(struct node *node)
+{
+	return 0;
+}
+
+static inline void scan_unevictable_unregister_node(struct node *node) { }
 #endif
 
 extern int kswapd_run(int nid);
Index: linux-2.6.26-rc5-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.26-rc5-mm2.orig/mm/vmscan.c	2008-06-10 22:38:57.000000000 -0400
+++ linux-2.6.26-rc5-mm2/mm/vmscan.c	2008-06-10 23:02:07.000000000 -0400
@@ -39,6 +39,7 @@
 #include <linux/freezer.h>
 #include <linux/memcontrol.h>
 #include <linux/delayacct.h>
+#include <linux/sysctl.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -2362,6 +2363,39 @@ int page_evictable(struct page *page, st
 	return 1;
 }
 
+static void show_page_path(struct page *page)
+{
+	char buf[256];
+	if (page_is_file_cache(page)) {
+		struct address_space *mapping = page->mapping;
+		struct dentry *dentry;
+		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+
+		spin_lock(&mapping->i_mmap_lock);
+		dentry = d_find_alias(mapping->host);
+		printk(KERN_INFO "rescued: %s %lu\n",
+		       dentry_path(dentry, buf, 256), pgoff);
+		spin_unlock(&mapping->i_mmap_lock);
+	} else {
+#ifdef CONFIG_MM_OWNER
+		struct anon_vma *anon_vma;
+		struct vm_area_struct *vma;
+
+		anon_vma = page_lock_anon_vma(page);
+		if (!anon_vma)
+			return;
+
+		list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+			printk(KERN_INFO "rescued: anon %s\n",
+			       vma->vm_mm->owner->comm);
+			break;
+		}
+		page_unlock_anon_vma(anon_vma);
+#endif
+	}
+}
+
+
 /**
  * check_move_unevictable_page - check page for evictability and move to appropriate zone lru list
  * @page: page to check evictability and move to appropriate lru list
@@ -2379,6 +2413,9 @@ static void check_move_unevictable_page(
 	ClearPageUnevictable(page); /* for page_evictable() */
 	if (page_evictable(page, NULL)) {
 		enum lru_list l = LRU_INACTIVE_ANON + page_is_file_cache(page);
+
+		show_page_path(page);
+
 		__dec_zone_state(zone, NR_UNEVICTABLE);
 		list_move(&page->lru, &zone->lru[l].list);
 		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
@@ -2459,4 +2496,130 @@ void scan_mapping_unevictable_pages(stru
 	}
 
 }
+
+/**
+ * scan_zone_unevictable_pages - check unevictable list for evictable pages
+ * @zone - zone of which to scan the unevictable list
+ *
+ * Scan @zone's unevictable LRU lists to check for pages that have become
+ * evictable.  Move those that have to @zone's inactive list where they
+ * become candidates for reclaim, unless shrink_inactive_zone() decides
+ * to reactivate them.  Pages that are still unevictable are rotated
+ * back onto @zone's unevictable list.
+ */
+#define SCAN_UNEVICTABLE_BATCH_SIZE 16UL /* arbitrary lock hold batch size */
+void scan_zone_unevictable_pages(struct zone *zone)
+{
+	struct list_head *l_unevictable = &zone->lru[LRU_UNEVICTABLE].list;
+	unsigned long scan;
+	unsigned long nr_to_scan = zone_page_state(zone, NR_UNEVICTABLE);
+
+	while (nr_to_scan > 0) {
+		unsigned long batch_size = min(nr_to_scan,
+						SCAN_UNEVICTABLE_BATCH_SIZE);
+
+		spin_lock_irq(&zone->lru_lock);
+		for (scan = 0;  scan < batch_size; scan++) {
+			struct page *page = lru_to_page(l_unevictable);
+
+			if (TestSetPageLocked(page))
+				continue;
+
+			prefetchw_prev_lru_page(page, l_unevictable, flags);
+
+			if (likely(PageLRU(page) && PageUnevictable(page)))
+				check_move_unevictable_page(page, zone);
+
+			unlock_page(page);
+		}
+		spin_unlock_irq(&zone->lru_lock);
+
+		nr_to_scan -= batch_size;
+	}
+}
+
+
+/**
+ * scan_all_zones_unevictable_pages - scan all unevictable lists for evictable pages
+ *
+ * A really big hammer:  scan all zones' unevictable LRU lists to check for
+ * pages that have become evictable.  Move those back to the zones'
+ * inactive list where they become candidates for reclaim.
+ * This occurs when, e.g., we have unswappable pages on the unevictable lists,
+ * and we add swap to the system.  As such, it runs in the context of a task
+ * that has possibly/probably made some previously unevictable pages
+ * evictable.
+ */
+void scan_all_zones_unevictable_pages(void)
+{
+	struct zone *zone;
+
+	for_each_zone(zone) {
+		scan_zone_unevictable_pages(zone);
+	}
+}
+
+/*
+ * scan_unevictable_pages [vm] sysctl handler.  On demand re-scan of
+ * all nodes' unevictable lists for evictable pages
+ */
+unsigned long scan_unevictable_pages;
+
+int scan_unevictable_handler(struct ctl_table *table, int write,
+			   struct file *file, void __user *buffer,
+			   size_t *length, loff_t *ppos)
+{
+	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+
+	if (write && *(unsigned long *)table->data)
+		scan_all_zones_unevictable_pages();
+
+	scan_unevictable_pages = 0;
+	return 0;
+}
+
+/*
+ * per node 'scan_unevictable_pages' attribute.  On demand re-scan of
+ * a specified node's per zone unevictable lists for evictable pages.
+ */
+
+static ssize_t read_scan_unevictable_node(struct sys_device *dev, char *buf)
+{
+	return sprintf(buf, "0\n");	/* always zero; should fit... */
+}
+
+static ssize_t write_scan_unevictable_node(struct sys_device *dev,
+					const char *buf, size_t count)
+{
+	struct zone *node_zones = NODE_DATA(dev->id)->node_zones;
+	struct zone *zone;
+	unsigned long res;
+	unsigned long req = strict_strtoul(buf, 10, &res);
+
+	if (!req)
+		return 1;	/* zero is no-op */
+
+	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
+		if (!populated_zone(zone))
+			continue;
+		scan_zone_unevictable_pages(zone);
+	}
+	return 1;
+}
+
+
+static SYSDEV_ATTR(scan_unevictable_pages, S_IRUGO | S_IWUSR,
+			read_scan_unevictable_node,
+			write_scan_unevictable_node);
+
+int scan_unevictable_register_node(struct node *node)
+{
+	return sysdev_create_file(&node->sysdev, &attr_scan_unevictable_pages);
+}
+
+void scan_unevictable_unregister_node(struct node *node)
+{
+	sysdev_remove_file(&node->sysdev, &attr_scan_unevictable_pages);
+}
+
 #endif
Index: linux-2.6.26-rc5-mm2/kernel/sysctl.c
===================================================================
--- linux-2.6.26-rc5-mm2.orig/kernel/sysctl.c	2008-06-10 22:36:48.000000000 -0400
+++ linux-2.6.26-rc5-mm2/kernel/sysctl.c	2008-06-10 22:38:58.000000000 -0400
@@ -1141,6 +1141,16 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+#ifdef CONFIG_UNEVICTABLE_LRU
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "scan_unevictable_pages",
+		.data		= &scan_unevictable_pages,
+		.maxlen		= sizeof(scan_unevictable_pages),
+		.mode		= 0644,
+		.proc_handler	= &scan_unevictable_handler,
+	},
+#endif
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
Index: linux-2.6.26-rc5-mm2/drivers/base/node.c
===================================================================
--- linux-2.6.26-rc5-mm2.orig/drivers/base/node.c	2008-06-10 22:38:44.000000000 -0400
+++ linux-2.6.26-rc5-mm2/drivers/base/node.c	2008-06-10 22:38:58.000000000 -0400
@@ -13,6 +13,7 @@
 #include <linux/nodemask.h>
 #include <linux/cpu.h>
 #include <linux/device.h>
+#include <linux/swap.h>
 
 static struct sysdev_class node_class = {
 	.name = "node",
@@ -186,6 +187,8 @@ int register_node(struct node *node, int
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
 		sysdev_create_file(&node->sysdev, &attr_numastat);
 		sysdev_create_file(&node->sysdev, &attr_distance);
+
+		scan_unevictable_register_node(node);
 	}
 	return error;
 }
@@ -205,6 +208,8 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
 
+	scan_unevictable_unregister_node(node);
+
 	sysdev_unregister(&node->sysdev);
 }
 
Index: linux-2.6.26-rc5-mm2/include/linux/rmap.h
===================================================================
--- linux-2.6.26-rc5-mm2.orig/include/linux/rmap.h	2008-06-10 22:37:26.000000000 -0400
+++ linux-2.6.26-rc5-mm2/include/linux/rmap.h	2008-06-10 22:38:58.000000000 -0400
@@ -67,6 +67,9 @@ void anon_vma_unlink(struct vm_area_stru
 void anon_vma_link(struct vm_area_struct *);
 void __anon_vma_link(struct vm_area_struct *);
 
+extern struct anon_vma *page_lock_anon_vma(struct page *page);
+extern void page_unlock_anon_vma(struct anon_vma *anon_vma);
+
 /*
  * rmap interfaces called when adding or removing pte of page
  */
Index: linux-2.6.26-rc5-mm2/mm/rmap.c
===================================================================
--- linux-2.6.26-rc5-mm2.orig/mm/rmap.c	2008-06-10 22:37:26.000000000 -0400
+++ linux-2.6.26-rc5-mm2/mm/rmap.c	2008-06-10 22:38:58.000000000 -0400
@@ -158,7 +158,7 @@ void __init anon_vma_init(void)
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
-static struct anon_vma *page_lock_anon_vma(struct page *page)
+struct anon_vma *page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma;
 	unsigned long anon_mapping;
@@ -178,7 +178,7 @@ out:
 	return NULL;
 }
 
-static void page_unlock_anon_vma(struct anon_vma *anon_vma)
+void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
 	spin_unlock(&anon_vma->lock);
 	rcu_read_unlock();

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
