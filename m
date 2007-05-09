Date: Wed, 09 May 2007 12:11:22 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC] memory hotremove patch take 2 [05/10] (make basic remove code)
In-Reply-To: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
Message-Id: <20070509120512.B910.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Add MEMORY_HOTREMOVE config and implements basic algorythm.

This config selects ZONE_MOVABLE and PAGE_ISOLATION

how work:
1. register Isololation area of specified section
2. search mem_map and migrate pages.
3. detach isolation and make pages unused.

This works on my easy test, but I think I need more work on loop algorythm 
and policy.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


 include/linux/memory_hotplug.h |    1 
 mm/Kconfig                     |    8 +
 mm/memory_hotplug.c            |  221 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 229 insertions(+), 1 deletion(-)

Index: current_test/mm/Kconfig
===================================================================
--- current_test.orig/mm/Kconfig	2007-05-08 15:08:03.000000000 +0900
+++ current_test/mm/Kconfig	2007-05-08 15:08:27.000000000 +0900
@@ -126,6 +126,12 @@ config MEMORY_HOTPLUG_SPARSE
 	def_bool y
 	depends on SPARSEMEM && MEMORY_HOTPLUG
 
+config MEMORY_HOTREMOVE
+	bool "Allow for memory hot-remove"
+	depends on MEMORY_HOTPLUG_SPARSE
+	select	MIGRATION
+	select  PAGE_ISOLATION
+
 # Heavily threaded applications may benefit from splitting the mm-wide
 # page_table_lock, so that faults on different parts of the user address
 # space can be handled with less contention: split it at this NR_CPUS.
@@ -145,7 +151,7 @@ config SPLIT_PTLOCK_CPUS
 config MIGRATION
 	bool "Page migration"
 	def_bool y
-	depends on NUMA
+	depends on NUMA || MEMORY_HOTREMOVE
 	help
 	  Allows the migration of the physical location of pages of processes
 	  while the virtual addresses are not changed. This is useful for
Index: current_test/mm/memory_hotplug.c
===================================================================
--- current_test.orig/mm/memory_hotplug.c	2007-05-08 15:02:48.000000000 +0900
+++ current_test/mm/memory_hotplug.c	2007-05-08 15:08:27.000000000 +0900
@@ -23,6 +23,9 @@
 #include <linux/vmalloc.h>
 #include <linux/ioport.h>
 #include <linux/cpuset.h>
+#include <linux/page_isolation.h>
+#include <linux/delay.h>
+#include <linux/migrate.h>
 
 #include <asm/tlbflush.h>
 
@@ -308,3 +311,221 @@ error:
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory);
+
+
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+
+/*
+ * Just an easy implementation.
+ */
+static struct page *
+hotremove_migrate_alloc(struct page *page,
+			unsigned long private,
+			int **x)
+{
+	return alloc_page(GFP_HIGH_MOVABLE);
+}
+
+/* scans # of pages per itelation */
+#define HOTREMOVE_UNIT	(1024)
+
+static int do_migrate_and_isolate_pages(struct isolation_info *info,
+				unsigned long start_pfn,
+				unsigned long end_pfn)
+{
+	int move_pages = HOTREMOVE_UNIT;
+	int ret, managed, not_managed;
+	unsigned long pfn;
+	struct page *page;
+	LIST_HEAD(source);
+
+	not_managed = 0;
+	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
+		if (!pfn_valid(pfn))  /* never happens in sparsemem */
+			continue;
+		page = pfn_to_page(pfn);
+		if (is_page_isolated(info,page))
+			continue;
+		ret = isolate_lru_page(page, &source);
+
+		if (ret == 0) {
+			move_pages--;
+			managed++;
+		} else {
+			if (page_count(page))
+				not_managed++; /* someone uses this */
+		}
+	}
+	ret = -EBUSY;
+	if (not_managed) {
+		if (!list_empty(&source))
+			putback_lru_pages(&source);
+		goto out;
+	}
+	ret = 0;
+	if (list_empty(&source))
+		goto out;
+	/* this function returns # of failed pages */
+	ret = migrate_pages(&source, hotremove_migrate_alloc,
+			   (unsigned long)info);
+out:
+	return ret;
+}
+
+
+/*
+ * Check All pages registered as IORESOURCE_RAM are isolated or not.
+ */
+static int check_removal_success(struct isolation_info *info)
+{
+	struct resource res;
+	unsigned long section_end;
+	unsigned long start_pfn, i, nr_pages;
+	struct page *page;
+	int removed = 0;
+	res.start = info->start_pfn << PAGE_SHIFT;
+	res.end = (info->end_pfn - 1) << PAGE_SHIFT;
+	res.flags = IORESOURCE_MEM;
+	section_end = res.end;
+	while ((res.start < res.end) && (find_next_system_ram(&res) >= 0)) {
+		start_pfn =(res.start >> PAGE_SHIFT);
+		nr_pages = (res.end + 1UL - res.start) >> PAGE_SHIFT;
+		for (i = 0; i < nr_pages; i++) {
+			page = pfn_to_page(start_pfn + i);
+			if (!is_page_isolated(info,page))
+				return -EBUSY;
+			removed++;
+		}
+		res.start = res.end + 1;
+		res.end = section_end;
+	}
+	return removed;
+}
+/*
+ * start_pfn and end_pfn myst be aligned to SECTION_SIZE.
+ * start_pfn and end_pfn must be in the same zone.
+ * target page range must be in ZONE_MOVABLE.
+ *
+ * Under this, [start_pfn, end_pfn) pages are isolated.
+ * All freed pages in the range is captured info isolation_info.
+ *
+ * If all pages in the range are isolated, offline_pages() returns 0.
+ *
+ * Note: memory holes in section are marked as Reserved Memory.
+ *       So we igonre Reserved pages in the first check.
+ *       But bootmem is aslo makred as Reserved.
+ *	 We check memory resouce information and confirm we freed
+ *	 All necessary pages.
+ */
+
+int offline_pages(unsigned long start_pfn,
+		  unsigned long end_pfn,
+		  unsigned long timeout)
+{
+	struct isolation_info *info;
+	struct page *page;
+	LIST_HEAD(pagelist);
+	int ret, nr_pages;
+	unsigned long expire = jiffies + timeout;
+	struct zone *zone;
+	unsigned long pfn, offlined_pages;
+
+	if (start_pfn & (PAGES_PER_SECTION - 1))
+		return -EINVAL;
+	if (end_pfn & (PAGES_PER_SECTION - 1))
+		return -EINVAL;
+
+	zone = page_zone(pfn_to_page(start_pfn));
+
+	if (zone != zone->zone_pgdat->node_zones + ZONE_MOVABLE)
+		return -EBUSY;
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+		if (PageSlab(page) ||
+			PageUncached(page) ||
+			PageCompound(page))
+			break;
+	}
+	if (pfn < end_pfn)
+		return -EBUSY;
+
+	info = register_isolation(start_pfn, end_pfn);
+	if (IS_ERR(info))
+		return PTR_ERR(info);
+	/* start memory hot removal */
+
+	ret = capture_isolate_freed_pages(info);
+	if(ret < 0)
+		goto failed_removal;
+
+	nr_pages = end_pfn - start_pfn;
+	pfn = start_pfn;
+repeat:
+	ret = -EAGAIN;
+	if (time_after(jiffies, expire))
+		goto failed_removal;
+	ret = -EINTR;
+	if (signal_pending(current))
+		goto failed_removal;
+
+	lru_add_drain_all();
+
+	for(;pfn < end_pfn;pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+		if (PageReserved(page)) /* ignore Resrved page for now */
+			continue;
+		if (!is_page_isolated(info,page))
+			break;
+	}
+
+	if (pfn != end_pfn) {
+		ret = do_migrate_and_isolate_pages(info, pfn, end_pfn);
+		if (!ret) {
+			cond_resched();
+			goto repeat;
+		} else if (ret < 0) {
+			ret = -EBUSY;
+			goto failed_removal;
+		} else if (ret > 0) {
+			/* some congestion found. sleep a bit */
+			msleep(10);
+			goto repeat;
+		}
+	}
+	/* check memory holes and bootmem */
+	ret = check_removal_success(info);
+	if (ret < 0) {
+		goto failed_removal;
+	}
+	offlined_pages = ret;
+	/* all pages are isolated */
+	detach_isolation_info_zone(info);
+	unuse_all_isolated_pages(info);
+	free_isolation_info(info);
+	zone->present_pages -= offlined_pages;
+	zone->zone_pgdat->node_present_pages -= offlined_pages;
+	totalram_pages -= offlined_pages;
+	num_physpages -= offlined_pages;
+	vm_total_pages = nr_free_pagecache_pages();
+	writeback_set_ratelimit();
+	return 0;
+
+failed_removal:
+	if (ret == -EBUSY) {
+		printk("some unremovable pages are included in %lx to %lx\n",
+			info->start_pfn, info->end_pfn);
+	}
+	/* push back to free_list */
+	detach_isolation_info_zone(info);
+	free_all_isolated_pages(info);
+	free_isolation_info(info);
+	return ret;
+}
+
+#endif
Index: current_test/include/linux/memory_hotplug.h
===================================================================
--- current_test.orig/include/linux/memory_hotplug.h	2007-05-08 15:02:48.000000000 +0900
+++ current_test/include/linux/memory_hotplug.h	2007-05-08 15:08:06.000000000 +0900
@@ -59,6 +59,7 @@ extern int add_one_highpage(struct page 
 extern void online_page(struct page *page);
 /* VM interface that may be used by firmware interface */
 extern int online_pages(unsigned long, unsigned long);
+extern int offline_pages(unsigned long, unsigned long, unsigned long);
 
 /* reasonably generic interface to expand the physical pages in a zone  */
 extern int __add_pages(struct zone *zone, unsigned long start_pfn,

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
