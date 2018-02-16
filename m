Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD176B005A
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 11:02:28 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id t1so1798471oth.21
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 08:02:28 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [69.252.207.43])
        by mx.google.com with ESMTPS id l3si1361290ite.54.2018.02.16.08.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 08:02:27 -0800 (PST)
Message-Id: <20180216160121.519788537@linux.com>
Date: Fri, 16 Feb 2018 10:01:11 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 1/2] Protect larger order pages from breaking up
References: <20180216160110.641666320@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=limit_order
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

Over time as the kernel is churning through memory it will break
up larger pages and as time progresses larger contiguous allocations
will no longer be possible. This is an approach to preserve these
large pages and prevent them from being broken up.

This is useful for example for the use of jumbo pages and can
satify various needs of subsystems and device drivers that require
large contiguous allocation to operate properly.

The idea is to reserve a pool of pages of the required order
so that the kernel is not allowed to use the pages for allocations
of a different order. This is a pool that is fully integrated
into the page allocator and therefore transparently usable.

Control over this feature is by writing to /proc/zoneinfo.

F.e. to ensure that 2000 16K pages stay available for jumbo
frames do

	echo "2=2000" >/proc/zoneinfo

or through the order=<page spec> on the kernel command line.
F.e.

	order=2=2000,4N2=500

These pages will be subject to reclaim etc as usual but will not
be broken up.

One can then also f.e. operate the slub allocator with
64k pages. Specify "slub_max_order=4 slub_min_order=4" on
the kernel command line and all slab allocator allocations
will occur in 64K page sizes.

Note that this will reduce the memory available to the application
in some cases. Reclaim may occur more often. If more than
the reserved number of higher order pages are being used then
allocations will still fail as normal.

In order to make this work just right one needs to be able to
know the workload well enough to reserve the right amount
of pages. This is comparable to other reservation schemes.

Well that f.e brings up huge pages. You can of course
also use this to reserve those and can then be sure that
you can dynamically resize your huge page pools even after
a long time of system up time.

The idea for this patch came from Thomas Schoebel-Theuer whom I met
at the LCA and who described the approach to me promising
a patch that would do this. Sadly he has vanished somehow.
However, he has been using this approach to support a
production environment for numerous years.

So I redid his patch and this is the first draft of it.


Idea-by: Thomas Schoebel-Theuer <tst@schoebel-theuer.de>

First performance tests in a virtual enviroment show
a hackbench improvement by 6% just by increasing
the page size used by the page allocator to order 3.

Signed-off-by: Christopher Lameter <cl@linux.com>

Index: linux/include/linux/mmzone.h
===================================================================
--- linux.orig/include/linux/mmzone.h
+++ linux/include/linux/mmzone.h
@@ -96,6 +96,11 @@ extern int page_group_by_mobility_disabl
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
+	/* We stop breaking up pages of this order if less than
+	 * min are available. At that point the pages can only
+	 * be used for allocations of that particular order.
+	 */
+	unsigned long		min;
 };
 
 struct pglist_data;
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -1844,7 +1844,12 @@ struct page *__rmqueue_smallest(struct z
 		area = &(zone->free_area[current_order]);
 		page = list_first_entry_or_null(&area->free_list[migratetype],
 							struct page, lru);
-		if (!page)
+		/*
+		 * Continue if no page is found or if our freelist contains
+		 * less than the minimum pages of that order. In that case
+		 * we better look for a different order.
+		 */
+		if (!page || area->nr_free < area->min)
 			continue;
 		list_del(&page->lru);
 		rmv_page_order(page);
@@ -5190,6 +5195,57 @@ static void build_zonelists(pg_data_t *p
 
 #endif	/* CONFIG_NUMA */
 
+int set_page_order_min(int node, int order, unsigned min)
+{
+	int i, o;
+	long min_pages = 0;			/* Pages already reserved */
+	long managed_pages = 0;			/* Pages managed on the node */
+	struct zone *last;
+	unsigned remaining;
+
+	/*
+	 * Determine already reserved memory for orders
+	 * plus the total of the pages on the node
+	 */
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		struct zone *z = &NODE_DATA(node)->node_zones[i];
+		if (managed_zone(z)) {
+			for (o = 0; o < MAX_ORDER; o++) {
+				if (o != order)
+					min_pages += z->free_area[o].min << o;
+
+			}
+			managed_pages += z->managed_pages;
+		}
+	}
+
+	if (min_pages + (min << order) > managed_pages / 2)
+		return -ENOMEM;
+
+	/* Set the min values for all zones on the node */
+	remaining = min;
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		struct zone *z = &NODE_DATA(node)->node_zones[i];
+		if (managed_zone(z)) {
+			u64 tmp;
+
+			tmp = (u64)z->managed_pages * (min << order);
+			do_div(tmp, managed_pages);
+			tmp >>= order;
+			z->free_area[order].min = tmp;
+
+			last = z;
+			remaining -= tmp;
+		}
+	}
+
+	/* Deal with rounding errors */
+	if (remaining)
+		last->free_area[order].min += remaining;
+
+	return 0;
+}
+
 /*
  * Boot pageset table. One per cpu which is going to be used for all
  * zones and all nodes. The parameters will be set in such a way
@@ -5424,6 +5480,7 @@ static void __meminit zone_init_free_lis
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
 		zone->free_area[order].nr_free = 0;
+		zone->free_area[order].min = 0;
 	}
 }
 
@@ -6998,6 +7055,7 @@ static void __setup_per_zone_wmarks(void
 	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
 	struct zone *zone;
+	int order;
 	unsigned long flags;
 
 	/* Calculate total number of !ZONE_HIGHMEM pages */
@@ -7012,6 +7070,10 @@ static void __setup_per_zone_wmarks(void
 		spin_lock_irqsave(&zone->lock, flags);
 		tmp = (u64)pages_min * zone->managed_pages;
 		do_div(tmp, lowmem_pages);
+
+		for (order = 0; order < MAX_ORDER; order++)
+			tmp += zone->free_area[order].min << order;
+
 		if (is_highmem(zone)) {
 			/*
 			 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -27,6 +27,7 @@
 #include <linux/mm_inline.h>
 #include <linux/page_ext.h>
 #include <linux/page_owner.h>
+#include <linux/ctype.h>
 
 #include "internal.h"
 
@@ -1614,6 +1615,11 @@ static void zoneinfo_show_print(struct s
 				zone_numa_state_snapshot(zone, i));
 #endif
 
+	for (i = 0; i < MAX_ORDER; i++)
+		if (zone->free_area[i].min)
+			seq_printf(m, "\nPreserve %lu pages of order %d from breaking up.",
+				zone->free_area[i].min, i);
+
 	seq_printf(m, "\n  pagesets");
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
@@ -1641,6 +1647,122 @@ static void zoneinfo_show_print(struct s
 	seq_putc(m, '\n');
 }
 
+static int __order_protect(char *p)
+{
+	char c;
+
+	do {
+		int order = 0;
+		int pages = 0;
+		int node = 0;
+		int rc;
+
+		/* Syntax <order>[N<node>]=number */
+		if (!isdigit(*p))
+			return -EFAULT;
+
+		while (true) {
+			c = *p++;
+
+			if (!isdigit(c))
+				break;
+
+			order = order * 10 + c - '0';
+		}
+
+		/* Check for optional node specification */
+		if (c == 'N') {
+			if (!isdigit(*p))
+				return -EFAULT;
+
+			while (true) {
+				c = *p++;
+				if (!isdigit(c))
+					break;
+				node = node * 10 + c - '0';
+			}
+		}
+
+		if (c != '=')
+			return -EINVAL;
+
+		if (!isdigit(*p))
+			return -EINVAL;
+
+		while (true) {
+			c = *p++;
+			if (!isdigit(c))
+				break;
+			pages = pages * 10 + c - '0';
+		}
+
+		if (order == 0 || order >= MAX_ORDER)
+		       return -EINVAL;
+
+		if (!node_online(node))
+			return -ENOSYS;
+
+		rc = set_page_order_min(node, order, pages);
+		if (rc)
+			return rc;
+
+	} while (c == ',');
+
+	if (c)
+		return -EINVAL;
+
+	setup_per_zone_wmarks();
+
+	return 0;
+}
+
+/*
+ * Writing to /proc/zoneinfo allows to setup the large page breakup
+ * protection.
+ *
+ * Syntax:
+ * 	<order>[N<node>]=<number>{,<order>[N<node>]=<number>}
+ *
+ * F.e. Protecting 500 pages of order 2 (16K on intel) and 300 of
+ * order 4 (64K) on node 1
+ *
+ * 	echo "2=500,4N1=300" >/proc/zoneinfo
+ *
+ */
+static ssize_t zoneinfo_write(struct file *file, const char __user *buffer,
+			size_t count, loff_t *ppos)
+{
+	char zinfo[200];
+	int rc;
+
+	if (count > sizeof(zinfo))
+		return -EINVAL;
+
+	if (copy_from_user(zinfo, buffer, count))
+		return -EFAULT;
+
+	zinfo[count - 1] = 0;
+
+	rc = __order_protect(zinfo);
+
+	if (rc)
+		return rc;
+
+	return count;
+}
+
+static int order_protect(char *s)
+{
+	int rc;
+
+	rc = __order_protect(s);
+	if (rc)
+		printk("Invalid order=%s rc=%d\n",s, rc);
+
+	return 1;
+}
+__setup("order=", order_protect);
+
 /*
  * Output information about zones in @pgdat.  All zones are printed regardless
  * of whether they are populated or not: lowmem_reserve_ratio operates on the
@@ -1672,6 +1794,7 @@ static const struct file_operations zone
 	.read		= seq_read,
 	.llseek		= seq_lseek,
 	.release	= seq_release,
+	.write		= zoneinfo_write,
 };
 
 enum writeback_stat_item {
@@ -2016,7 +2139,7 @@ void __init init_mm_internals(void)
 	proc_create("buddyinfo", 0444, NULL, &buddyinfo_file_operations);
 	proc_create("pagetypeinfo", 0444, NULL, &pagetypeinfo_file_operations);
 	proc_create("vmstat", 0444, NULL, &vmstat_file_operations);
-	proc_create("zoneinfo", 0444, NULL, &zoneinfo_file_operations);
+	proc_create("zoneinfo", 0644, NULL, &zoneinfo_file_operations);
 #endif
 }
 
Index: linux/include/linux/gfp.h
===================================================================
--- linux.orig/include/linux/gfp.h
+++ linux/include/linux/gfp.h
@@ -543,6 +543,7 @@ void drain_all_pages(struct zone *zone);
 void drain_local_pages(struct zone *zone);
 
 void page_alloc_init_late(void);
+int set_page_order_min(int node, int order, unsigned min);
 
 /*
  * gfp_allowed_mask is set to GFP_BOOT_MASK during early boot to restrict what

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
