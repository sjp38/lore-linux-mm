From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 29 May 2008 15:51:40 -0400
Message-Id: <20080529195140.27159.11850.sendpatchset@lts-notebook>
In-Reply-To: <20080529195030.27159.66161.sendpatchset@lts-notebook>
References: <20080529195030.27159.66161.sendpatchset@lts-notebook>
Subject: [PATCH 23/25] Noreclaim LRU scan sysctl
Sender: owner-linux-mm@kvack.org
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Against:  2.6.26-rc2-mm1

V6:
+ moved to end of series as optional debug patch

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split LRU series

New in V2

This patch adds a function to scan individual or all zones' noreclaim
lists and move any pages that have become reclaimable onto the respective
zone's inactive list, where shrink_inactive_list() will deal with them.

Adds sysctl to scan all nodes, and per node attributes to individual
nodes' zones.

Kosaki:
If reclaimable page found in noreclaim lru when write
/proc/sys/vm/scan_noreclaim_pages, print filename and file offset of
these pages.

TODO:  DEBUGGING ONLY: NOT FOR UPSTREAM MERGE

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


 drivers/base/node.c  |    5 +
 include/linux/rmap.h |    3 
 include/linux/swap.h |   15 ++++
 kernel/sysctl.c      |   10 +++
 mm/rmap.c            |    4 -
 mm/vmscan.c          |  161 +++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 196 insertions(+), 2 deletions(-)

Index: linux-2.6.26-rc2-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/include/linux/swap.h	2008-05-28 13:03:07.000000000 -0400
+++ linux-2.6.26-rc2-mm1/include/linux/swap.h	2008-05-28 13:03:13.000000000 -0400
@@ -7,6 +7,7 @@
 #include <linux/list.h>
 #include <linux/memcontrol.h>
 #include <linux/sched.h>
+#include <linux/node.h>
 
 #include <asm/atomic.h>
 #include <asm/page.h>
@@ -235,15 +236,29 @@ static inline int zone_reclaim(struct zo
 #ifdef CONFIG_NORECLAIM_LRU
 extern int page_reclaimable(struct page *page, struct vm_area_struct *vma);
 extern void scan_mapping_noreclaim_pages(struct address_space *);
+
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
+
 static inline void scan_mapping_noreclaim_pages(struct address_space *mapping)
 {
 }
+
+static inline int scan_noreclaim_register_node(struct node *node)
+{
+	return 0;
+}
+
+static inline void scan_noreclaim_unregister_node(struct node *node) { }
 #endif
 
 extern int kswapd_run(int nid);
Index: linux-2.6.26-rc2-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/vmscan.c	2008-05-28 13:03:10.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/vmscan.c	2008-05-28 13:03:13.000000000 -0400
@@ -39,6 +39,7 @@
 #include <linux/kthread.h>
 #include <linux/freezer.h>
 #include <linux/memcontrol.h>
+#include <linux/sysctl.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -2352,6 +2353,37 @@ int page_reclaimable(struct page *page, 
 	return 1;
 }
 
+static void show_page_path(struct page *page)
+{
+	char buf[256];
+	if (page_file_cache(page)) {
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
+	}
+}
+
+
 /**
  * check_move_noreclaim_page - check page for reclaimability and move to appropriate lru list
  * @page: page to check reclaimability and move to appropriate lru list
@@ -2369,6 +2401,9 @@ static void check_move_noreclaim_page(st
 	ClearPageNoreclaim(page); /* for page_reclaimable() */
 	if (page_reclaimable(page, NULL)) {
 		enum lru_list l = LRU_INACTIVE_ANON + page_file_cache(page);
+
+		show_page_path(page);
+
 		__dec_zone_state(zone, NR_NORECLAIM);
 		list_move(&page->lru, &zone->list[l]);
 		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
@@ -2449,4 +2484,130 @@ void scan_mapping_noreclaim_pages(struct
 	}
 
 }
+
+/**
+ * scan_zone_noreclaim_pages - check noreclaim list for reclaimable pages
+ * @zone - zone of which to scan the noreclaim list
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
+	unsigned long scan;
+	unsigned long nr_to_scan = zone_page_state(zone, NR_NORECLAIM);
+
+	while (nr_to_scan > 0) {
+		unsigned long batch_size = min(nr_to_scan,
+						SCAN_NORECLAIM_BATCH_SIZE);
+
+		spin_lock_irq(&zone->lru_lock);
+		for (scan = 0;  scan < batch_size; scan++) {
+			struct page *page = lru_to_page(l_noreclaim);
+
+			if (TestSetPageLocked(page))
+				continue;
+
+			prefetchw_prev_lru_page(page, l_noreclaim, flags);
+
+			if (likely(PageLRU(page) && PageNoreclaim(page)))
+				check_move_noreclaim_page(page, zone);
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
+ * scan_all_zones_noreclaim_pages - scan all noreclaim lists for reclaimable pages
+ *
+ * A really big hammer:  scan all zones' noreclaim LRU lists to check for
+ * pages that have become reclaimable.  Move those back to the zones'
+ * inactive list where they become candidates for reclaim.
+ * This occurs when, e.g., we have unswappable pages on the noreclaim lists,
+ * and we add swap to the system.  As such, it runs in the context of a task
+ * that has possibly/probably made some previously non-reclaimable pages
+ * reclaimable.
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
+int scan_noreclaim_handler(struct ctl_table *table, int write,
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
 #endif
Index: linux-2.6.26-rc2-mm1/kernel/sysctl.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/kernel/sysctl.c	2008-05-28 13:01:13.000000000 -0400
+++ linux-2.6.26-rc2-mm1/kernel/sysctl.c	2008-05-28 13:03:13.000000000 -0400
@@ -1151,6 +1151,16 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+#ifdef CONFIG_NORECLAIM_LRU
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
Index: linux-2.6.26-rc2-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/drivers/base/node.c	2008-05-28 13:03:06.000000000 -0400
+++ linux-2.6.26-rc2-mm1/drivers/base/node.c	2008-05-28 13:03:13.000000000 -0400
@@ -13,6 +13,7 @@
 #include <linux/nodemask.h>
 #include <linux/cpu.h>
 #include <linux/device.h>
+#include <linux/swap.h>
 
 static struct sysdev_class node_class = {
 	.name = "node",
@@ -190,6 +191,8 @@ int register_node(struct node *node, int
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
 		sysdev_create_file(&node->sysdev, &attr_numastat);
 		sysdev_create_file(&node->sysdev, &attr_distance);
+
+		scan_noreclaim_register_node(node);
 	}
 	return error;
 }
@@ -209,6 +212,8 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
 
+	scan_noreclaim_unregister_node(node);
+
 	sysdev_unregister(&node->sysdev);
 }
 
Index: linux-2.6.26-rc2-mm1/include/linux/rmap.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/include/linux/rmap.h	2008-05-28 13:02:55.000000000 -0400
+++ linux-2.6.26-rc2-mm1/include/linux/rmap.h	2008-05-28 13:03:13.000000000 -0400
@@ -55,6 +55,9 @@ void anon_vma_unlink(struct vm_area_stru
 void anon_vma_link(struct vm_area_struct *);
 void __anon_vma_link(struct vm_area_struct *);
 
+extern struct anon_vma *page_lock_anon_vma(struct page *page);
+extern void page_unlock_anon_vma(struct anon_vma *anon_vma);
+
 /*
  * rmap interfaces called when adding or removing pte of page
  */
Index: linux-2.6.26-rc2-mm1/mm/rmap.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/rmap.c	2008-05-28 13:02:55.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/rmap.c	2008-05-28 13:03:13.000000000 -0400
@@ -168,7 +168,7 @@ void __init anon_vma_init(void)
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
-static struct anon_vma *page_lock_anon_vma(struct page *page)
+struct anon_vma *page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma;
 	unsigned long anon_mapping;
@@ -188,7 +188,7 @@ out:
 	return NULL;
 }
 
-static void page_unlock_anon_vma(struct anon_vma *anon_vma)
+void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
 	spin_unlock(&anon_vma->lock);
 	rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
