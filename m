Date: Thu, 14 Jun 2007 16:04:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] memory unplug v5 [5/6] page unplug
Message-Id: <20070614160458.62e20cbd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Changes V4->V5
 - adjusted to meet changes in lower patch stack.
 

Logic.
 - set all pages in  [start,end)  as isolated migration-type.
   by this, all free pages in the range will be not-for-use.
 - Migrate all LRU pages in the range.
 - Test all pages in the range's refcnt is zero or not.

Todo:
 - allocate migration destination page from better area.
 - confirm page_count(page)== 0 && PageReserved(page) page is safe to be freed..
 (I don't like this kind of page but..
 - Find out pages which cannot be migrated.
 - more running tests.
 - need more comments.
 - Use reclaim for unplugging other memory type area.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-Off-By: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 include/linux/memory_hotplug.h |    5 
 mm/Kconfig                     |    5 
 mm/memory_hotplug.c            |  256 +++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c                |   48 +++++++
 4 files changed, 313 insertions(+), 1 deletion(-)

Index: devel-2.6.22-rc4-mm2/mm/Kconfig
===================================================================
--- devel-2.6.22-rc4-mm2.orig/mm/Kconfig
+++ devel-2.6.22-rc4-mm2/mm/Kconfig
@@ -126,6 +126,11 @@ config MEMORY_HOTPLUG_SPARSE
 	def_bool y
 	depends on SPARSEMEM && MEMORY_HOTPLUG
 
+config MEMORY_HOTREMOVE
+	bool "Allow for memory hot remove"
+	depends on MEMORY_HOTPLUG
+	depends on MIGRATION
+
 # Heavily threaded applications may benefit from splitting the mm-wide
 # page_table_lock, so that faults on different parts of the user address
 # space can be handled with less contention: split it at this NR_CPUS.
Index: devel-2.6.22-rc4-mm2/mm/memory_hotplug.c
===================================================================
--- devel-2.6.22-rc4-mm2.orig/mm/memory_hotplug.c
+++ devel-2.6.22-rc4-mm2/mm/memory_hotplug.c
@@ -23,6 +23,9 @@
 #include <linux/vmalloc.h>
 #include <linux/ioport.h>
 #include <linux/cpuset.h>
+#include <linux/delay.h>
+#include <linux/migrate.h>
+#include <linux/page-isolation.h>
 
 #include <asm/tlbflush.h>
 
@@ -301,3 +304,256 @@ error:
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory);
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+/*
+ * Confirm all pages in a range [start, end) is belongs to the same zone.
+ */
+static int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn;
+	struct zone *zone = NULL;
+	struct page *page;
+	for (pfn = start_pfn;
+             pfn < end_pfn;
+	     pfn += MAX_ORDER_NR_PAGES) {
+#ifdef CONFIG_HOLES_IN_ZONE
+		int i;
+		for (i = 0; i < MAX_ORDER_NR_PAGES; i++) {
+			if (pfn_valid_within(pfn + i))
+				break;
+		}
+		if (i == MAX_ORDER_NR_PAGES)
+			continue;
+		page = pfn_to_page(pfn + i);
+#else
+		page = pfn_to_page(pfn);
+#endif
+		if (zone && page_zone(page) != zone)
+			return 0;
+		zone = page_zone(page);
+	}
+	return 1;
+}
+
+/*
+ * Scanning pfn is much easier than scanning lru list.
+ * Scan pfn from start to end and Find LRU page.
+ */
+int scan_lru_pages(unsigned long start, unsigned long end)
+{
+	unsigned long pfn;
+	struct page *page;
+	for (pfn = start; pfn < end; pfn++) {
+		if (pfn_valid(pfn)) {
+			page = pfn_to_page(pfn);
+			if (PageLRU(page))
+				return pfn;
+		}
+	}
+	return 0;
+}
+
+static struct page *
+hotremove_migrate_alloc(struct page *page,
+			unsigned long private,
+			int **x)
+{
+	/* This should be improoooooved!! */
+	return alloc_page(GFP_HIGHUSER_PAGECACHE);
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
+		if (!page_count(page))
+			continue;
+		/*
+		 * We can skip free pages. And we can only deal with pages on
+		 * LRU.
+		 */
+		ret = isolate_lru_page(page, &source);
+		if (!ret) { /* Success */
+			move_pages--;
+		} else {
+			/* Becasue we don't have big zone->lock. we should
+			   check this again here. */
+			if (page_count(page))
+				not_managed++;
+#ifdef CONFIG_DEBUG_VM
+			printk("Not Migratable page found %lx/%d/%lx\n",
+				pfn, page_count(page), page->flags);
+#endif
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
+	ret = migrate_pages(&source, hotremove_migrate_alloc, 0);
+
+out:
+	return ret;
+}
+
+/*
+ * remove from free_area[] and mark all as Reserved.
+ */
+static int
+offline_isolated_pages_cb(unsigned long start, unsigned long nr_pages,
+			void *data)
+{
+	__offline_isolated_pages(start, start + nr_pages);
+	return 0;
+}
+
+static void
+offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
+{
+	walk_memory_resource(start_pfn, end_pfn - start_pfn, NULL,
+				offline_isolated_pages_cb);
+}
+
+/*
+ * Check all pages in range, recoreded as memory resource, are isolated.
+ */
+static int
+check_pages_isolated_cb(unsigned long start_pfn, unsigned long nr_pages,
+			void *data)
+{
+	int ret;
+	long offlined = *(long*)data;
+	ret = test_pages_isolated(start_pfn, start_pfn + nr_pages);
+	offlined = nr_pages;
+	if (!ret)
+		*(long*)data += offlined;
+	return ret;
+}
+
+static long
+check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
+{
+	long offlined = 0;
+	int ret;
+
+	ret = walk_memory_resource(start_pfn, end_pfn - start_pfn, &offlined,
+			check_pages_isolated_cb);
+	if (ret < 0)
+		offlined = (long)ret;
+	return offlined;
+}
+
+extern void drain_all_local_pages(void);
+
+int offline_pages(unsigned long start_pfn,
+		  unsigned long end_pfn, unsigned long timeout)
+{
+	unsigned long pfn, nr_pages, expire;
+	long offlined_pages;
+	int ret, drain, retry_max;
+	struct zone *zone;
+
+	BUG_ON(start_pfn >= end_pfn);
+	/* at least, alignment against pageblock is necessary */
+	if (start_pfn & (pageblock_nr_pages - 1))
+		return -EINVAL;
+	if (end_pfn & (pageblock_nr_pages - 1))
+		return -EINVAL;
+	/* This makes hotplug much easier...and readable.
+	   we assume this for now. .*/
+	if (test_pages_in_a_zone(start_pfn, end_pfn))
+		return -EINVAL;
+	/* set above range as isolated */
+	ret = start_isolate_page_range(start_pfn, end_pfn);
+	if (ret)
+		return ret;
+	nr_pages = end_pfn - start_pfn;
+	pfn = start_pfn;
+	expire = jiffies + timeout;
+	drain = 0;
+	retry_max = 5;
+repeat:
+	/* start memory hot removal */
+	ret = -EAGAIN;
+	if (time_after(jiffies, expire))
+		goto failed_removal;
+	ret = -EINTR;
+	if (signal_pending(current))
+		goto failed_removal;
+	ret = 0;
+	if (drain) {
+		lru_add_drain_all();
+		flush_scheduled_work();
+		cond_resched();
+		drain_all_local_pages();
+	}
+
+	pfn = scan_lru_pages(start_pfn, end_pfn);
+	if (pfn) { /* We have page on LRU */
+		ret = do_migrate_range(pfn, end_pfn);
+		if (!ret) {
+			drain = 1;
+			goto repeat;
+		} else {
+			if (ret < 0)
+				if (--retry_max == 0)
+					goto failed_removal;
+			yield();
+			drain = 1;
+			goto repeat;
+		}
+	}
+	/* drain all zone's lru pagevec, this is asyncronous... */
+	lru_add_drain_all();
+	flush_scheduled_work();
+	yield();
+	/* drain pcp pages , this is synchrouns. */
+	drain_all_local_pages();
+	/* check again */
+	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
+	if (offlined_pages < 0) {
+		ret = -EBUSY;
+		goto failed_removal;
+	}
+	printk("Offlined Pages %ld\n",offlined_pages);
+	/* Ok, all of our target is islaoted.
+	   We cannot do rollback at this point. */
+	offline_isolated_pages(start_pfn, end_pfn);
+	/* reset pagetype flags */
+	start_isolate_page_range(start_pfn, end_pfn);
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
+	undo_isolate_page_range(start_pfn, end_pfn);
+	return ret;
+}
+#endif /* CONFIG_MEMORY_HOTREMOVE */
Index: devel-2.6.22-rc4-mm2/include/linux/memory_hotplug.h
===================================================================
--- devel-2.6.22-rc4-mm2.orig/include/linux/memory_hotplug.h
+++ devel-2.6.22-rc4-mm2/include/linux/memory_hotplug.h
@@ -59,7 +59,10 @@ extern int add_one_highpage(struct page 
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
Index: devel-2.6.22-rc4-mm2/mm/page_alloc.c
===================================================================
--- devel-2.6.22-rc4-mm2.orig/mm/page_alloc.c
+++ devel-2.6.22-rc4-mm2/mm/page_alloc.c
@@ -4453,3 +4453,51 @@ void unset_migratetype_isolate(struct pa
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
+	struct page *page;
+	struct zone *zone;
+	int order, i;
+	unsigned long pfn;
+	unsigned long flags;
+	/* find the first valid pfn */
+	for (pfn = start_pfn; pfn < end_pfn; pfn++)
+		if (pfn_valid(pfn))
+			break;
+	if (pfn == end_pfn)
+		return;
+	zone = page_zone(pfn_to_page(pfn));
+	spin_lock_irqsave(&zone->lock, flags);
+	printk("do offline \n");
+	pfn = start_pfn;
+	while (pfn < end_pfn) {
+		if (!pfn_valid(pfn)) {
+			pfn++;
+			continue;
+		}
+		page = pfn_to_page(pfn);
+		BUG_ON(page_count(page));
+		BUG_ON(!PageBuddy(page));
+		order = page_order(page);
+#ifdef CONFIG_DEBUG_VM
+		printk("remove from free list %lx %d %lx\n",
+		       pfn, 1 << order, end_pfn);
+#endif
+		list_del(&page->lru);
+		rmv_page_order(page);
+		zone->free_area[order].nr_free--;
+		__mod_zone_page_state(zone, NR_FREE_PAGES,
+				      - (1UL << order));
+		for (i = 0; i < (1 << order); i++)
+			SetPageReserved((page+i));
+		pfn += (1 << order);
+	}
+	spin_unlock_irqrestore(&zone->lock,flags);
+}
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
