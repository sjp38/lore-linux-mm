Date: Fri, 6 Jul 2007 18:26:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memory unplug v7 [4/6] - page isolation
Message-Id: <20070706182611.b16b6720.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070706181903.428c3713.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070706181903.428c3713.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Implement generic chunk-of-pages isolation method by using page grouping ops.

This patch add MIGRATE_ISOLATE to MIGRATE_TYPES. By this
 - MIGRATE_TYPES increases.
 - bitmap for migratetype is enlarged.

pages of MIGRATE_ISOLATE migratetype will not be allocated even if it is free.
By this, you can isolated *freed* pages from users. How-to-free pages is not
a purpose of this patch. You may use reclaim and migrate codes to free pages.

If start_isolate_page_range(start,end) is called,
 - migratetype of the range turns to be MIGRATE_ISOLATE  if 
   its type is MIGRATE_MOVABLE. (*) this check can be updated if other
   memory reclaiming works make progress.
 - MIGRATE_ISOLATE is not on migratetype fallback list.
 - All free pages and will-be-freed pages are isolated.
To check all pages in the range are isolated or not,  use test_pages_isolated(),
To cancel isolation, use undo_isolate_page_range().

Changes V6 -> V7
 - removed unnecessary #ifdef

There are HOLES_IN_ZONE handling codes...I'm glad if we can remove them..

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/mmzone.h          |    3 
 include/linux/page-isolation.h  |   37 ++++++++++
 include/linux/pageblock-flags.h |    2 
 mm/Makefile                     |    2 
 mm/page_alloc.c                 |   44 ++++++++++++
 mm/page_isolation.c             |  138 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 223 insertions(+), 3 deletions(-)

Index: linux-2.6.22-rc6-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/mmzone.h
+++ linux-2.6.22-rc6-mm1/include/linux/mmzone.h
@@ -39,7 +39,8 @@ extern int page_group_by_mobility_disabl
 #define MIGRATE_RECLAIMABLE   1
 #define MIGRATE_MOVABLE       2
 #define MIGRATE_RESERVE       3
-#define MIGRATE_TYPES         4
+#define MIGRATE_ISOLATE       4 /* can't allocate from here */
+#define MIGRATE_TYPES         5
 
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
Index: linux-2.6.22-rc6-mm1/include/linux/pageblock-flags.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/pageblock-flags.h
+++ linux-2.6.22-rc6-mm1/include/linux/pageblock-flags.h
@@ -31,7 +31,7 @@
 
 /* Bit indices that affect a whole block of pages */
 enum pageblock_bits {
-	PB_range(PB_migrate, 2), /* 2 bits required for migrate types */
+	PB_range(PB_migrate, 3), /* 3 bits required for migrate types */
 	NR_PAGEBLOCK_BITS
 };
 
Index: linux-2.6.22-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/page_alloc.c
+++ linux-2.6.22-rc6-mm1/mm/page_alloc.c
@@ -41,6 +41,7 @@
 #include <linux/pfn.h>
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
+#include <linux/page-isolation.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -4412,3 +4413,46 @@ void set_pageblock_flags_group(struct pa
 		else
 			__clear_bit(bitidx + start_bitidx, bitmap);
 }
+
+/*
+ * This is designed as sub function...plz see page_isolation.c also.
+ * set/clear page block's type to be ISOLATE.
+ * page allocater never alloc memory from ISOLATE block.
+ */
+
+int set_migratetype_isolate(struct page *page)
+{
+	struct zone *zone;
+	unsigned long flags;
+	int ret = -EBUSY;
+
+	zone = page_zone(page);
+	spin_lock_irqsave(&zone->lock, flags);
+	/*
+	 * In future, more migrate types will be able to be isolation target.
+	 */
+	if (get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
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
+void unset_migratetype_isolate(struct page *page)
+{
+	struct zone *zone;
+	unsigned long flags;
+	zone = page_zone(page);
+	spin_lock_irqsave(&zone->lock, flags);
+	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
+		goto out;
+	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+	move_freepages_block(zone, page, MIGRATE_MOVABLE);
+out:
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
Index: linux-2.6.22-rc6-mm1/mm/page_isolation.c
===================================================================
--- /dev/null
+++ linux-2.6.22-rc6-mm1/mm/page_isolation.c
@@ -0,0 +1,138 @@
+/*
+ * linux/mm/page_isolation.c
+ */
+
+#include <stddef.h>
+#include <linux/mm.h>
+#include <linux/page-isolation.h>
+#include <linux/pageblock-flags.h>
+#include "internal.h"
+
+static inline struct page *
+__first_valid_page(unsigned long pfn, unsigned long nr_pages)
+{
+	int i;
+	for (i = 0; i < nr_pages; i++)
+		if (pfn_valid_within(pfn + i))
+			break;
+	if (unlikely(i == nr_pages))
+		return NULL;
+	return pfn_to_page(pfn + i);
+}
+
+/*
+ * start_isolate_page_range() -- make page-allocation-type of range of pages
+ * to be MIGRATE_ISOLATE.
+ * @start_pfn: The lower PFN of the range to be isolated.
+ * @end_pfn: The upper PFN of the range to be isolated.
+ *
+ * Making page-allocation-type to be MIGRATE_ISOLATE means free pages in
+ * the range will never be allocated. Any free pages and pages freed in the
+ * future will not be allocated again.
+ *
+ * start_pfn/end_pfn must be aligned to pageblock_order.
+ * Returns 0 on success and -EBUSY if any part of range cannot be isolated.
+ */
+int
+start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn;
+	unsigned long undo_pfn;
+	struct page *page;
+
+	BUG_ON((start_pfn) & (pageblock_nr_pages - 1));
+	BUG_ON((end_pfn) & (pageblock_nr_pages - 1));
+
+	for (pfn = start_pfn;
+	     pfn < end_pfn;
+	     pfn += pageblock_nr_pages) {
+		page = __first_valid_page(pfn, pageblock_nr_pages);
+		if (page && set_migratetype_isolate(page)) {
+			undo_pfn = pfn;
+			goto undo;
+		}
+	}
+	return 0;
+undo:
+	for (pfn = start_pfn;
+	     pfn <= undo_pfn;
+	     pfn += pageblock_nr_pages)
+		unset_migratetype_isolate(pfn_to_page(pfn));
+
+	return -EBUSY;
+}
+
+/*
+ * Make isolated pages available again.
+ */
+int
+undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn;
+	struct page *page;
+	BUG_ON((start_pfn) & (pageblock_nr_pages - 1));
+	BUG_ON((end_pfn) & (pageblock_nr_pages - 1));
+	for (pfn = start_pfn;
+	     pfn < end_pfn;
+	     pfn += pageblock_nr_pages) {
+		page = __first_valid_page(pfn, pageblock_nr_pages);
+		if (!page || get_pageblock_flags(page) != MIGRATE_ISOLATE)
+			continue;
+		unset_migratetype_isolate(page);
+	}
+	return 0;
+}
+/*
+ * Test all pages in the range is free(means isolated) or not.
+ * all pages in [start_pfn...end_pfn) must be in the same zone.
+ * zone->lock must be held before call this.
+ *
+ * Returns 0 if all pages in the range is isolated.
+ */
+static int
+__test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
+{
+	struct page *page;
+
+	while (pfn < end_pfn) {
+		if (!pfn_valid_within(pfn)) {
+			pfn++;
+			continue;
+		}
+		page = pfn_to_page(pfn);
+		if (PageBuddy(page))
+			pfn += 1 << page_order(page);
+		else if (page_count(page) == 0 &&
+				page_private(page) == MIGRATE_ISOLATE)
+			pfn += 1;
+		else
+			break;
+	}
+	if (pfn < end_pfn)
+		return 0;
+	return 1;
+}
+
+int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn;
+	struct page *page;
+
+	pfn = start_pfn;
+	/*
+	 * Note: pageblock_nr_page != MAX_ORDER. Then, chunks of free page
+	 * is not aligned to pageblock_nr_pages.
+	 * Then we just check pagetype fist.
+	 */
+	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
+		page = __first_valid_page(pfn, pageblock_nr_pages);
+		if (page && get_pageblock_flags(page) != MIGRATE_ISOLATE)
+			break;
+	}
+	if (pfn < end_pfn)
+		return -EBUSY;
+	/* Check all pages are free or Marked as ISOLATED */
+	if (__test_page_isolated_in_pageblock(start_pfn, end_pfn))
+		return 0;
+	return -EBUSY;
+}
Index: linux-2.6.22-rc6-mm1/include/linux/page-isolation.h
===================================================================
--- /dev/null
+++ linux-2.6.22-rc6-mm1/include/linux/page-isolation.h
@@ -0,0 +1,37 @@
+#ifndef __LINUX_PAGEISOLATION_H
+#define __LINUX_PAGEISOLATION_H
+
+/*
+ * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
+ * If specified range includes migrate types other than MOVABLE,
+ * this will fail with -EBUSY.
+ *
+ * For isolating all pages in the range finally, the caller have to
+ * free all pages in the range. test_page_isolated() can be used for
+ * test it.
+ */
+extern int
+start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn);
+
+/*
+ * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
+ * target range is [start_pfn, end_pfn)
+ */
+extern int
+undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn);
+
+/*
+ * test all pages in [start_pfn, end_pfn)are isolated or not.
+ */
+extern int
+test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
+
+/*
+ * Internal funcs.Changes pageblock's migrate type.
+ * Please use make_pagetype_isolated()/make_pagetype_movable().
+ */
+extern int set_migratetype_isolate(struct page *page);
+extern void unset_migratetype_isolate(struct page *page);
+
+
+#endif
Index: linux-2.6.22-rc6-mm1/mm/Makefile
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/Makefile
+++ linux-2.6.22-rc6-mm1/mm/Makefile
@@ -11,7 +11,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   $(mmu-y)
+			   page_isolation.o $(mmu-y)
 
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
