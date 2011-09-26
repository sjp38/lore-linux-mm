Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DC4919000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 07:30:22 -0400 (EDT)
Date: Mon, 26 Sep 2011 13:29:45 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch] mm: remove sysctl to manually rescue unevictable pages
Message-ID: <20110926112944.GC14333@redhat.com>
References: <1316948380-1879-1-git-send-email-consul.kautuk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1316948380-1879-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Sun, Sep 25, 2011 at 04:29:40PM +0530, Kautuk Consul wrote:
> write_scan_unavictable_node checks the value req returned by
> strict_strtoul and returns 1 if req is 0.
> 
> However, when strict_strtoul returns 0, it means successful conversion
> of buf to unsigned long.
> 
> Due to this, the function was not proceeding to scan the zones for
> unevictable pages even though we write a valid value to the 
> scan_unevictable_pages sys file.

Given that there is not a real reason for this knob (anymore) and that
it apparently never really worked since the day it was introduced, how
about we just drop all that code instead?

	Hannes

---
From: Johannes Weiner <jweiner@redhat.com>
Subject: mm: remove sysctl to manually rescue unevictable pages

At one point, anonymous pages were supposed to go on the unevictable
list when no swap space was configured, and the idea was to manually
rescue those pages after adding swap and making them evictable again.
But nowadays, swap-backed pages on the anon LRU list are not scanned
without available swap space anyway, so there is no point in moving
them to a separate list anymore.

The manual rescue could also be used in case pages were stranded on
the unevictable list due to race conditions.  But the code has been
around for a while now and newly discovered bugs should be properly
reported and dealt with instead of relying on such a manual fixup.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 drivers/base/node.c  |    3 -
 include/linux/swap.h |   16 ------
 kernel/sysctl.c      |    7 ---
 mm/vmscan.c          |  130 --------------------------------------------------
 4 files changed, 0 insertions(+), 156 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 9e58e71..b9d6e93 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -278,8 +278,6 @@ int register_node(struct node *node, int num, struct node *parent)
 		sysdev_create_file(&node->sysdev, &attr_distance);
 		sysdev_create_file_optional(&node->sysdev, &attr_vmstat);
 
-		scan_unevictable_register_node(node);
-
 		hugetlb_register_node(node);
 
 		compaction_register_node(node);
@@ -303,7 +301,6 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_distance);
 	sysdev_remove_file_optional(&node->sysdev, &attr_vmstat);
 
-	scan_unevictable_unregister_node(node);
 	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
 
 	sysdev_unregister(&node->sysdev);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index b156e80..a6a9ee5 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -276,22 +276,6 @@ static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
 extern int page_evictable(struct page *page, struct vm_area_struct *vma);
 extern void scan_mapping_unevictable_pages(struct address_space *);
 
-extern unsigned long scan_unevictable_pages;
-extern int scan_unevictable_handler(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
-#ifdef CONFIG_NUMA
-extern int scan_unevictable_register_node(struct node *node);
-extern void scan_unevictable_unregister_node(struct node *node);
-#else
-static inline int scan_unevictable_register_node(struct node *node)
-{
-	return 0;
-}
-static inline void scan_unevictable_unregister_node(struct node *node)
-{
-}
-#endif
-
 extern int kswapd_run(int nid);
 extern void kswapd_stop(int nid);
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 4f057f9..0d66092 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1325,13 +1325,6 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
-	{
-		.procname	= "scan_unevictable_pages",
-		.data		= &scan_unevictable_pages,
-		.maxlen		= sizeof(scan_unevictable_pages),
-		.mode		= 0644,
-		.proc_handler	= scan_unevictable_handler,
-	},
 #ifdef CONFIG_MEMORY_FAILURE
 	{
 		.procname	= "memory_failure_early_kill",
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7502726..c99a097 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3396,133 +3396,3 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 	}
 
 }
-
-/**
- * scan_zone_unevictable_pages - check unevictable list for evictable pages
- * @zone - zone of which to scan the unevictable list
- *
- * Scan @zone's unevictable LRU lists to check for pages that have become
- * evictable.  Move those that have to @zone's inactive list where they
- * become candidates for reclaim, unless shrink_inactive_zone() decides
- * to reactivate them.  Pages that are still unevictable are rotated
- * back onto @zone's unevictable list.
- */
-#define SCAN_UNEVICTABLE_BATCH_SIZE 16UL /* arbitrary lock hold batch size */
-static void scan_zone_unevictable_pages(struct zone *zone)
-{
-	struct list_head *l_unevictable = &zone->lru[LRU_UNEVICTABLE].list;
-	unsigned long scan;
-	unsigned long nr_to_scan = zone_page_state(zone, NR_UNEVICTABLE);
-
-	while (nr_to_scan > 0) {
-		unsigned long batch_size = min(nr_to_scan,
-						SCAN_UNEVICTABLE_BATCH_SIZE);
-
-		spin_lock_irq(&zone->lru_lock);
-		for (scan = 0;  scan < batch_size; scan++) {
-			struct page *page = lru_to_page(l_unevictable);
-
-			if (!trylock_page(page))
-				continue;
-
-			prefetchw_prev_lru_page(page, l_unevictable, flags);
-
-			if (likely(PageLRU(page) && PageUnevictable(page)))
-				check_move_unevictable_page(page, zone);
-
-			unlock_page(page);
-		}
-		spin_unlock_irq(&zone->lru_lock);
-
-		nr_to_scan -= batch_size;
-	}
-}
-
-
-/**
- * scan_all_zones_unevictable_pages - scan all unevictable lists for evictable pages
- *
- * A really big hammer:  scan all zones' unevictable LRU lists to check for
- * pages that have become evictable.  Move those back to the zones'
- * inactive list where they become candidates for reclaim.
- * This occurs when, e.g., we have unswappable pages on the unevictable lists,
- * and we add swap to the system.  As such, it runs in the context of a task
- * that has possibly/probably made some previously unevictable pages
- * evictable.
- */
-static void scan_all_zones_unevictable_pages(void)
-{
-	struct zone *zone;
-
-	for_each_zone(zone) {
-		scan_zone_unevictable_pages(zone);
-	}
-}
-
-/*
- * scan_unevictable_pages [vm] sysctl handler.  On demand re-scan of
- * all nodes' unevictable lists for evictable pages
- */
-unsigned long scan_unevictable_pages;
-
-int scan_unevictable_handler(struct ctl_table *table, int write,
-			   void __user *buffer,
-			   size_t *length, loff_t *ppos)
-{
-	proc_doulongvec_minmax(table, write, buffer, length, ppos);
-
-	if (write && *(unsigned long *)table->data)
-		scan_all_zones_unevictable_pages();
-
-	scan_unevictable_pages = 0;
-	return 0;
-}
-
-#ifdef CONFIG_NUMA
-/*
- * per node 'scan_unevictable_pages' attribute.  On demand re-scan of
- * a specified node's per zone unevictable lists for evictable pages.
- */
-
-static ssize_t read_scan_unevictable_node(struct sys_device *dev,
-					  struct sysdev_attribute *attr,
-					  char *buf)
-{
-	return sprintf(buf, "0\n");	/* always zero; should fit... */
-}
-
-static ssize_t write_scan_unevictable_node(struct sys_device *dev,
-					   struct sysdev_attribute *attr,
-					const char *buf, size_t count)
-{
-	struct zone *node_zones = NODE_DATA(dev->id)->node_zones;
-	struct zone *zone;
-	unsigned long res;
-	unsigned long req = strict_strtoul(buf, 10, &res);
-
-	if (!req)
-		return 1;	/* zero is no-op */
-
-	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
-		if (!populated_zone(zone))
-			continue;
-		scan_zone_unevictable_pages(zone);
-	}
-	return 1;
-}
-
-
-static SYSDEV_ATTR(scan_unevictable_pages, S_IRUGO | S_IWUSR,
-			read_scan_unevictable_node,
-			write_scan_unevictable_node);
-
-int scan_unevictable_register_node(struct node *node)
-{
-	return sysdev_create_file(&node->sysdev, &attr_scan_unevictable_pages);
-}
-
-void scan_unevictable_unregister_node(struct node *node)
-{
-	sysdev_remove_file(&node->sysdev, &attr_scan_unevictable_pages);
-}
-#endif
-- 
1.7.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
