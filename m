Date: Tue, 22 May 2007 16:01:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Patch] memory unplug v3 [1/4] page isolation
Message-Id: <20070522160151.3ae5e5d7.kamezawa.hiroyu@jp.fujitsu.com>
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

Patch for isoalte pages.
'isoalte'means make pages to be free and never allocated.
This feature helps making the range of pages unused.

This patch is based on Mel's page grouping method.

This patch add MIGRATE_ISOLATE to MIGRATE_TYPES. By this
- MIGRATE_TYPES increases.
- bitmap for migratetype is enlarged.

If isolate_pages(start,end) is called,
- migratetype of the range turns to be MIGRATE_ISOLATE  if 
  its current type is MIGRATE_MOVABLE or MIGRATE_RESERVE.
- MIGRATE_ISOLATE is not on migratetype fallback list.

Then, pages of this migratetype will not be allocated even if it is free.

Now, isolate_pages() only can treat the range aligned to MAX_ORDER.
This can be adjusted if necesasry...maybe.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: devel-2.6.22-rc1-mm1/include/linux/mmzone.h
===================================================================
--- devel-2.6.22-rc1-mm1.orig/include/linux/mmzone.h	2007-05-22 14:30:43.000000000 +0900
+++ devel-2.6.22-rc1-mm1/include/linux/mmzone.h	2007-05-22 15:12:28.000000000 +0900
@@ -35,11 +35,12 @@
  */
 #define PAGE_ALLOC_COSTLY_ORDER 3
 
-#define MIGRATE_UNMOVABLE     0
-#define MIGRATE_RECLAIMABLE   1
-#define MIGRATE_MOVABLE       2
-#define MIGRATE_RESERVE       3
-#define MIGRATE_TYPES         4
+#define MIGRATE_UNMOVABLE     0		/* not reclaimable pages */
+#define MIGRATE_RECLAIMABLE   1		/* shrink_xxx routine can reap this */
+#define MIGRATE_MOVABLE       2		/* migrate_page can migrate this */
+#define MIGRATE_RESERVE       3		/* no type yet */
+#define MIGRATE_ISOLATE       4		/* never allocated from */
+#define MIGRATE_TYPES         5
 
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
Index: devel-2.6.22-rc1-mm1/include/linux/pageblock-flags.h
===================================================================
--- devel-2.6.22-rc1-mm1.orig/include/linux/pageblock-flags.h	2007-05-22 14:30:43.000000000 +0900
+++ devel-2.6.22-rc1-mm1/include/linux/pageblock-flags.h	2007-05-22 15:12:28.000000000 +0900
@@ -31,7 +31,7 @@
 
 /* Bit indices that affect a whole block of pages */
 enum pageblock_bits {
-	PB_range(PB_migrate, 2), /* 2 bits required for migrate types */
+	PB_range(PB_migrate, 3), /* 3 bits required for migrate types */
 	NR_PAGEBLOCK_BITS
 };
 
Index: devel-2.6.22-rc1-mm1/mm/page_alloc.c
===================================================================
--- devel-2.6.22-rc1-mm1.orig/mm/page_alloc.c	2007-05-22 14:30:43.000000000 +0900
+++ devel-2.6.22-rc1-mm1/mm/page_alloc.c	2007-05-22 15:12:28.000000000 +0900
@@ -41,6 +41,7 @@
 #include <linux/pfn.h>
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
+#include <linux/page-isolation.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1056,6 +1057,7 @@
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
+	unsigned long migrate_type;
 
 	if (PageAnon(page))
 		page->mapping = NULL;
@@ -1064,6 +1066,12 @@
 
 	if (!PageHighMem(page))
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
+
+	migrate_type = get_pageblock_migratetype(page);
+	if (migrate_type == MIGRATE_ISOLATE) {
+		__free_pages_ok(page, 0);
+		return;
+	}
 	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 
@@ -1071,7 +1079,7 @@
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
 	list_add(&page->lru, &pcp->list);
-	set_page_private(page, get_pageblock_migratetype(page));
+	set_page_private(page, migrate_type);
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
 		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
@@ -4389,3 +4397,53 @@
 		else
 			__clear_bit(bitidx + start_bitidx, bitmap);
 }
+
+/*
+ * set/clear page block's type to be ISOLATE.
+ * page allocater never alloc memory from ISOLATE blcok.
+ */
+
+int is_page_isolated(struct page *page)
+{
+	if ((page_count(page) == 0) &&
+	    (get_pageblock_migratetype(page) == MIGRATE_ISOLATE))
+		return 1;
+	return 0;
+}
+
+int set_migratetype_isolate(struct page *page)
+{
+	struct zone *zone;
+	unsigned long flags;
+	int migrate_type;
+	int ret = -EBUSY;
+
+	zone = page_zone(page);
+	spin_lock_irqsave(&zone->lock, flags);
+	migrate_type = get_pageblock_migratetype(page);
+	if ((migrate_type != MIGRATE_MOVABLE) &&
+	    (migrate_type != MIGRATE_RESERVE))
+		goto out;
+	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
+	move_freepages_block(zone, page, MIGRATE_ISOLATE);
+	ret = 0;
+out:
+	spin_unlock_irqrestore(&zone->lock, flags);
+	if (!ret)
+		drain_all_local_pages();
+	return ret;
+}
+
+void clear_migratetype_isolate(struct page *page)
+{
+	struct zone *zone;
+	unsigned long flags;
+	zone = page_zone(page);
+	spin_lock_irqsave(&zone->lock, flags);
+	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
+		goto out;
+	set_pageblock_migratetype(page, MIGRATE_RESERVE);
+	move_freepages_block(zone, page, MIGRATE_RESERVE);
+out:
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
Index: devel-2.6.22-rc1-mm1/mm/page_isolation.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ devel-2.6.22-rc1-mm1/mm/page_isolation.c	2007-05-22 15:12:28.000000000 +0900
@@ -0,0 +1,67 @@
+/*
+ * linux/mm/page_isolation.c
+ */
+
+#include <stddef.h>
+#include <linux/mm.h>
+#include <linux/page-isolation.h>
+
+#define ROUND_DOWN(x,y)	((x) & ~((y) - 1))
+#define ROUND_UP(x,y)	(((x) + (y) -1) & ~((y) - 1))
+int
+isolate_pages(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn, start_pfn_aligned, end_pfn_aligned;
+	unsigned long undo_pfn;
+
+	start_pfn_aligned = ROUND_DOWN(start_pfn, NR_PAGES_ISOLATION_BLOCK);
+	end_pfn_aligned = ROUND_UP(end_pfn, NR_PAGES_ISOLATION_BLOCK);
+
+	for (pfn = start_pfn_aligned;
+	     pfn < end_pfn_aligned;
+	     pfn += NR_PAGES_ISOLATION_BLOCK)
+		if (set_migratetype_isolate(pfn_to_page(pfn))) {
+			undo_pfn = pfn;
+			goto undo;
+		}
+	return 0;
+undo:
+	for (pfn = start_pfn_aligned;
+	     pfn <= undo_pfn;
+	     pfn += NR_PAGES_ISOLATION_BLOCK)
+		clear_migratetype_isolate(pfn_to_page(pfn));
+
+	return -EBUSY;
+}
+
+
+int
+free_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn, start_pfn_aligned, end_pfn_aligned;
+	start_pfn_aligned = ROUND_DOWN(start_pfn, NR_PAGES_ISOLATION_BLOCK);
+        end_pfn_aligned = ROUND_UP(end_pfn, NR_PAGES_ISOLATION_BLOCK);
+
+	for (pfn = start_pfn_aligned;
+	     pfn < end_pfn_aligned;
+	     pfn += MAX_ORDER_NR_PAGES)
+		clear_migratetype_isolate(pfn_to_page(pfn));
+	return 0;
+}
+
+int
+test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn;
+	int ret = 0;
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+		if (!is_page_isolated(pfn_to_page(pfn))) {
+			ret = 1;
+			break;
+		}
+	}
+	return ret;
+}
Index: devel-2.6.22-rc1-mm1/include/linux/page-isolation.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ devel-2.6.22-rc1-mm1/include/linux/page-isolation.h	2007-05-22 15:12:28.000000000 +0900
@@ -0,0 +1,47 @@
+#ifndef __LINUX_PAGEISOLATION_H
+#define __LINUX_PAGEISOLATION_H
+/*
+ * Define an interface for capturing and isolating some amount of
+ * contiguous pages.
+ * isolated pages are freed but wll never be allocated until they are
+ * pushed back.
+ *
+ * This isolation function requires some alignment.
+ */
+
+#define PAGE_ISOLATION_ORDER	(MAX_ORDER - 1)
+#define NR_PAGES_ISOLATION_BLOCK	(1 << PAGE_ISOLATION_ORDER)
+
+/*
+ * set page isolation range.
+ * If specified range includes migrate types other than MOVABLE,
+ * this will fail with -EBUSY.
+ */
+extern int
+isolate_pages(unsigned long start_pfn, unsigned long end_pfn);
+
+/*
+ * Free all isolated memory and push back them as MIGRATE_RESERVE type.
+ */
+extern int
+free_isolated_pages(unsigned long start_pfn, unsigned long end_pfn);
+
+/*
+ * test all pages are isolated or not.
+ */
+extern int
+test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
+
+/* test routine for check page is isolated or not */
+extern int is_page_isolated(struct page *page);
+
+/*
+ * Internal funcs.
+ * Changes pageblock's migrate type
+ */
+extern int set_migratetype_isolate(struct page *page);
+extern void clear_migratetype_isolate(struct page *page);
+extern int __is_page_isolated(struct page *page);
+
+
+#endif
Index: devel-2.6.22-rc1-mm1/mm/Makefile
===================================================================
--- devel-2.6.22-rc1-mm1.orig/mm/Makefile	2007-05-22 14:30:43.000000000 +0900
+++ devel-2.6.22-rc1-mm1/mm/Makefile	2007-05-22 15:12:28.000000000 +0900
@@ -11,7 +11,7 @@
 			   page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   $(mmu-y)
+			   page_isolation.o $(mmu-y)
 
 ifeq ($(CONFIG_MMU)$(CONFIG_BLOCK),yy)
 obj-y			+= bounce.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
