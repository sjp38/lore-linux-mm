Date: Tue, 22 May 2007 16:07:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Patch] memory unplug v3 [3/4] page removal
Message-Id: <20070522160733.964e531b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This is page hot removal core patch.

How this works:
* isolate all specified range.
* for_all_pfn_in_range
	- skip if !pfn_valid()
	- skip if page_count(page)==0 && PageReserved()
	- skip if a page is isolated (freed)
	- migrate a page if it is used. (uses migration_nocontext)
	- if page cannot be migrated, returns -EBUSY.
* if timeout returns -EAGAIN.
* if signals are recevied, returns -EINTR.

* Make all pages in the range to be Reserved if they all are freed.


* This patch doesn't implement a user interface. An arch, which want to
  support memory unplug, should add offline_pages() call to its remove_pages().
  (see ia64 patch)
* This patch doesn't free memmap. this will be implemented by other patch.

if your arch support,
echo offline > /sys/devices/system/memory/memoryXXX/state 
will offline memory if it can.

offliend memory can be added again by
echo online > /sys/device/system/memory/memoryXXX/state.

A kind of defrag by hand :).

I wonder the logic can be more sophisticated and simpler...

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: devel-2.6.22-rc1-mm1/mm/Kconfig
===================================================================
--- devel-2.6.22-rc1-mm1.orig/mm/Kconfig	2007-05-22 15:12:29.000000000 +0900
+++ devel-2.6.22-rc1-mm1/mm/Kconfig	2007-05-22 15:12:30.000000000 +0900
@@ -126,6 +126,12 @@
 	def_bool y
 	depends on SPARSEMEM && MEMORY_HOTPLUG
 
+config MEMORY_HOTREMOVE
+	bool "Allow for memory hot remove"
+	depends on MEMORY_HOTPLUG
+	select MIGRATION
+	select MIGRATION_BY_KERNEL
+
 # Heavily threaded applications may benefit from splitting the mm-wide
 # page_table_lock, so that faults on different parts of the user address
 # space can be handled with less contention: split it at this NR_CPUS.
Index: devel-2.6.22-rc1-mm1/mm/memory_hotplug.c
===================================================================
--- devel-2.6.22-rc1-mm1.orig/mm/memory_hotplug.c	2007-05-22 14:30:39.000000000 +0900
+++ devel-2.6.22-rc1-mm1/mm/memory_hotplug.c	2007-05-22 15:12:30.000000000 +0900
@@ -23,6 +23,9 @@
 #include <linux/vmalloc.h>
 #include <linux/ioport.h>
 #include <linux/cpuset.h>
+#include <linux/delay.h>
+#include <linux/migrate.h>
+#include <linux/page-isolation.h>
 
 #include <asm/tlbflush.h>
 
@@ -308,3 +311,196 @@
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory);
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+
+static struct page *
+hotremove_migrate_alloc(struct page *page,
+			unsigned long private,
+			int **x)
+{
+	return alloc_page(GFP_HIGH_MOVABLE);
+}
+
+
+#define NR_OFFLINE_AT_ONCE_PAGES	(256)
+static int
+do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn;
+	struct page *page;
+	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
+	int not_managed = 0;
+	int ret = 0;
+	LIST_HEAD(source);
+
+	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+		/* page is isolated or being freed ? */
+		if ((page_count(page) == 0) || PageReserved(page))
+			continue;
+		ret = isolate_lru_page(page, &source);
+
+		if (ret == 0) {
+			move_pages--;
+		} else {
+			not_managed++;
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
+	ret = migrate_pages_nocontext(&source, hotremove_migrate_alloc, 0);
+
+out:
+	return ret;
+}
+
+/*
+ * remove from free_area[] and mark all as Reserved.
+ */
+static void
+offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
+{
+	struct resource res;
+	unsigned long tmp_start, tmp_end;
+
+	res.start = start_pfn << PAGE_SHIFT;
+	res.end = (end_pfn - 1) << PAGE_SHIFT;
+	res.flags = IORESOURCE_MEM;
+	while ((res.start < res.end) && (find_next_system_ram(&res) >= 0)) {
+		tmp_start = res.start >> PAGE_SHIFT;
+		tmp_end = (res.end >> PAGE_SHIFT) + 1;
+		/* this function touches free_area[]...so please see
+		   page_alloc.c */
+		__offline_isolated_pages(tmp_start, tmp_end);
+		res.start = res.end + 1;
+		res.end = end_pfn;
+	}
+}
+
+/*
+ * Check all pages in range, recoreded as memory resource, are isolated.
+ */
+static long
+check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
+{
+	struct resource res;
+	unsigned long tmp_start, tmp_end;
+	int ret, offlined = 0;
+
+	res.start = start_pfn << PAGE_SHIFT;
+	res.end = (end_pfn - 1) << PAGE_SHIFT;
+	res.flags = IORESOURCE_MEM;
+	while ((res.start < res.end) && (find_next_system_ram(&res) >= 0)) {
+		tmp_start = res.start >> PAGE_SHIFT;
+		tmp_end = (res.end >> PAGE_SHIFT) + 1;
+		ret = test_pages_isolated(tmp_start, tmp_end);
+		if (ret)
+			return -EBUSY;
+		offlined += tmp_end - tmp_start;
+		res.start = res.end + 1;
+		res.end = end_pfn;
+	}
+	return offlined;
+}
+
+
+int offline_pages(unsigned long start_pfn,
+		  unsigned long end_pfn, unsigned long timeout)
+{
+	unsigned long pfn, nr_pages, expire;
+	long offlined_pages;
+	int ret;
+	struct page *page;
+	struct zone *zone;
+
+	BUG_ON(start_pfn >= end_pfn);
+	/* at least, alignment against pageblock is necessary */
+	if (start_pfn & (NR_PAGES_ISOLATION_BLOCK - 1))
+		return -EINVAL;
+	if (end_pfn & (NR_PAGES_ISOLATION_BLOCK - 1))
+		return -EINVAL;
+	/* This makes hotplug much easier...and readable.
+	   we assume this for now. .*/
+	if (page_zone(pfn_to_page(start_pfn)) !=
+		page_zone(pfn_to_page(end_pfn - 1)))
+		return -EINVAL;
+	/* set above range as isolated */
+	ret = isolate_pages(start_pfn, end_pfn);
+	if (ret)
+		return ret;
+	nr_pages = end_pfn - start_pfn;
+	pfn = start_pfn;
+	expire = jiffies + timeout;
+repeat:
+	/* start memory hot removal */
+	ret = -EAGAIN;
+	if (time_after(jiffies, expire))
+		goto failed_removal;
+	ret = -EINTR;
+	if (signal_pending(current))
+		goto failed_removal;
+	ret = 0;
+	/* drain all zone's lru pagevec */
+	lru_add_drain_all();
+
+	/* skip isolated pages */
+	for(; pfn < end_pfn; pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+		if (PageReserved(page))
+			continue;
+		if (!is_page_isolated(page))
+			break;
+	}
+	/* start point is here */
+	if (pfn != end_pfn) {
+		ret = do_migrate_range(pfn, end_pfn);
+		if (!ret) {
+			cond_resched();
+			goto repeat;
+		} else if (ret < 0) {
+			goto failed_removal;
+		} else if (ret > 0) {
+			/* some congestion found. sleep a bit */
+			msleep(10);
+			goto repeat;
+		}
+	}
+	/* check again */
+	ret = check_pages_isolated(start_pfn, end_pfn);
+	if (ret < 0) {
+		goto failed_removal;
+	}
+	offlined_pages = ret;
+	/* Ok, all of our target is islaoted.
+	   We cannot do rollback at this point. */
+	offline_isolated_pages(start_pfn, end_pfn);
+	/* removal success */
+	zone = page_zone(pfn_to_page(start_pfn));
+	zone->present_pages -= offlined_pages;
+	zone->zone_pgdat->node_present_pages -= offlined_pages;
+	totalram_pages -= offlined_pages;
+	num_physpages -= offlined_pages;
+	vm_total_pages = nr_free_pagecache_pages();
+	writeback_set_ratelimit();
+	return 0;
+
+failed_removal:
+	printk("memory offlining %lx to %lx failed\n",start_pfn, end_pfn);
+	/* pushback to free area */
+	free_isolated_pages(start_pfn, end_pfn);
+	return ret;
+}
+#endif /* CONFIG_MEMORY_HOTREMOVE */
Index: devel-2.6.22-rc1-mm1/include/linux/memory_hotplug.h
===================================================================
--- devel-2.6.22-rc1-mm1.orig/include/linux/memory_hotplug.h	2007-05-22 14:30:39.000000000 +0900
+++ devel-2.6.22-rc1-mm1/include/linux/memory_hotplug.h	2007-05-22 15:12:30.000000000 +0900
@@ -59,7 +59,10 @@
 extern void online_page(struct page *page);
 /* VM interface that may be used by firmware interface */
 extern int online_pages(unsigned long, unsigned long);
-
+#ifdef CONFIG_MEMORY_HOTREMOVE
+extern int offline_pages(unsigned long, unsigned long, unsigned long);
+extern void __offline_isolated_pages(unsigned long, unsigned long);
+#endif
 /* reasonably generic interface to expand the physical pages in a zone  */
 extern int __add_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
Index: devel-2.6.22-rc1-mm1/mm/page_alloc.c
===================================================================
--- devel-2.6.22-rc1-mm1.orig/mm/page_alloc.c	2007-05-22 15:12:28.000000000 +0900
+++ devel-2.6.22-rc1-mm1/mm/page_alloc.c	2007-05-22 15:12:30.000000000 +0900
@@ -4447,3 +4447,52 @@
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+/*
+ * All pages in the range must be isolated before calling this.
+ */
+void
+__offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
+{
+	struct page *page, *tmp;
+	struct zone *zone;
+	struct free_area *area;
+	int order, i;
+	unsigned long pfn;
+	/* find the first valid pfn */
+	for (pfn = start_pfn; pfn < end_pfn; pfn++)
+		if (pfn_valid(pfn))
+			break;
+	if (pfn == end_pfn)
+		return;
+	zone = page_zone(pfn_to_page(pfn));
+	spin_lock(&zone->lock);
+	printk("do isoalte \n");
+	for (order = 0; order < MAX_ORDER; order++) {
+		area = &zone->free_area[order];
+		list_for_each_entry_safe(page, tmp,
+					 &area->free_list[MIGRATE_ISOLATE],
+					 lru) {
+			pfn = page_to_pfn(page);
+			if (pfn < start_pfn || end_pfn <= pfn)
+				continue;
+			printk("found %lx %lx %lx\n",
+			       start_pfn, pfn, end_pfn);
+			list_del(&page->lru);
+			rmv_page_order(page);
+			area->nr_free--;
+			__mod_zone_page_state(zone, NR_FREE_PAGES,
+					      - (1UL << order));
+		}
+	}
+	spin_unlock(&zone->lock);
+	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+		BUG_ON(page_count(page));
+		SetPageReserved(page);
+	}
+}
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
