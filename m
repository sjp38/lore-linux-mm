Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id F151B6B005C
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 22:50:46 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/3 v3] mm: Factor out memory isolate functions
Date: Thu, 12 Jul 2012 11:50:47 +0900
Message-Id: <1342061449-29590-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar@ap.sony.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, Marek Szyprowski <m.szyprowski@samsung.com>

Now mm/page_alloc.c has some memory isolation functions but they
are used oly when we enable CONFIG_{CMA|MEMORY_HOTPLUG|MEMORY_FAILURE}.
So let's make it configurable by new CONFIG_MEMORY_ISOLATION so that it
can reduce binary size and we can check it simple by CONFIG_MEMORY_ISOLATION,
not if defined CONFIG_{CMA|MEMORY_HOTPLUG|MEMORY_FAILURE}.

* from v2
 - rebase on mmotm-2012-07-10-16-59

* from v1
 - rebase on next-20120626

Cc: Andi Kleen <andi@firstfloor.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/base/Kconfig           |    1 +
 include/linux/page-isolation.h |   13 +++++--
 mm/Kconfig                     |    5 +++
 mm/Makefile                    |    4 +-
 mm/page_alloc.c                |   80 ++--------------------------------------
 mm/page_isolation.c            |   71 +++++++++++++++++++++++++++++++++++
 6 files changed, 92 insertions(+), 82 deletions(-)

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 9b21469..08b4c52 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -196,6 +196,7 @@ config CMA
 	bool "Contiguous Memory Allocator (EXPERIMENTAL)"
 	depends on HAVE_DMA_CONTIGUOUS && HAVE_MEMBLOCK && EXPERIMENTAL
 	select MIGRATION
+	select MEMORY_ISOLATION
 	help
 	  This enables the Contiguous Memory Allocator which allows drivers
 	  to allocate big physically-contiguous blocks of memory for use with
diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 3bdcab3..105077a 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -1,6 +1,11 @@
 #ifndef __LINUX_PAGEISOLATION_H
 #define __LINUX_PAGEISOLATION_H
 
+
+bool has_unmovable_pages(struct zone *zone, struct page *page, int count);
+void set_pageblock_migratetype(struct page *page, int migratetype);
+int move_freepages_block(struct zone *zone, struct page *page,
+				int migratetype);
 /*
  * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
  * If specified range includes migrate types other than MOVABLE or CMA,
@@ -10,7 +15,7 @@
  * free all pages in the range. test_page_isolated() can be used for
  * test it.
  */
-extern int
+int
 start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			 unsigned migratetype);
 
@@ -18,7 +23,7 @@ start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
  * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
  * target range is [start_pfn, end_pfn)
  */
-extern int
+int
 undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			unsigned migratetype);
 
@@ -30,8 +35,8 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
 /*
  * Internal functions. Changes pageblock's migrate type.
  */
-extern int set_migratetype_isolate(struct page *page);
-extern void unset_migratetype_isolate(struct page *page, unsigned migratetype);
+int set_migratetype_isolate(struct page *page);
+void unset_migratetype_isolate(struct page *page, unsigned migratetype);
 
 
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 82fed4e..d5c8019 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -140,9 +140,13 @@ config ARCH_DISCARD_MEMBLOCK
 config NO_BOOTMEM
 	boolean
 
+config MEMORY_ISOLATION
+	boolean
+
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
+	select MEMORY_ISOLATION
 	depends on SPARSEMEM || X86_64_ACPI_NUMA
 	depends on HOTPLUG && ARCH_ENABLE_MEMORY_HOTPLUG
 	depends on (IA64 || X86 || PPC_BOOK3S_64 || SUPERH || S390)
@@ -272,6 +276,7 @@ config MEMORY_FAILURE
 	depends on MMU
 	depends on ARCH_SUPPORTS_MEMORY_FAILURE
 	bool "Enable recovery from hardware memory errors"
+	select MEMORY_ISOLATION
 	help
 	  Enables code to recover from some memory failures on systems
 	  with MCA recovery. This allows a system to continue running
diff --git a/mm/Makefile b/mm/Makefile
index 262360a..7deaa29 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -15,8 +15,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   maccess.o page_alloc.o page-writeback.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   page_isolation.o mm_init.o mmu_context.o percpu.o \
-			   compaction.o $(mmu-y)
+			   mm_init.o mmu_context.o percpu.o compaction.o $(mmu-y)
 obj-y += init-mm.o
 
 ifdef CONFIG_NO_BOOTMEM
@@ -55,3 +54,4 @@ obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
+obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd94467..f17e6e4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -51,7 +51,6 @@
 #include <linux/page_cgroup.h>
 #include <linux/debugobjects.h>
 #include <linux/kmemleak.h>
-#include <linux/memory.h>
 #include <linux/compaction.h>
 #include <trace/events/kmem.h>
 #include <linux/ftrace_event.h>
@@ -219,7 +218,7 @@ EXPORT_SYMBOL(nr_online_nodes);
 
 int page_group_by_mobility_disabled __read_mostly;
 
-static void set_pageblock_migratetype(struct page *page, int migratetype)
+void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 
 	if (unlikely(page_group_by_mobility_disabled))
@@ -953,7 +952,7 @@ static int move_freepages(struct zone *zone,
 	return pages_moved;
 }
 
-static int move_freepages_block(struct zone *zone, struct page *page,
+int move_freepages_block(struct zone *zone, struct page *page,
 				int migratetype)
 {
 	unsigned long start_pfn, end_pfn;
@@ -5468,8 +5467,7 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
  * MIGRATE_MOVABLE block might include unmovable pages. It means you can't
  * expect this function should be exact.
  */
-static bool
-__has_unmovable_pages(struct zone *zone, struct page *page, int count)
+bool has_unmovable_pages(struct zone *zone, struct page *page, int count)
 {
 	unsigned long pfn, iter, found;
 	int mt;
@@ -5546,77 +5544,7 @@ bool is_pageblock_removable_nolock(struct page *page)
 			zone->zone_start_pfn + zone->spanned_pages <= pfn)
 		return false;
 
-	return !__has_unmovable_pages(zone, page, 0);
-}
-
-int set_migratetype_isolate(struct page *page)
-{
-	struct zone *zone;
-	unsigned long flags, pfn;
-	struct memory_isolate_notify arg;
-	int notifier_ret;
-	int ret = -EBUSY;
-
-	zone = page_zone(page);
-
-	spin_lock_irqsave(&zone->lock, flags);
-
-	pfn = page_to_pfn(page);
-	arg.start_pfn = pfn;
-	arg.nr_pages = pageblock_nr_pages;
-	arg.pages_found = 0;
-
-	/*
-	 * It may be possible to isolate a pageblock even if the
-	 * migratetype is not MIGRATE_MOVABLE. The memory isolation
-	 * notifier chain is used by balloon drivers to return the
-	 * number of pages in a range that are held by the balloon
-	 * driver to shrink memory. If all the pages are accounted for
-	 * by balloons, are free, or on the LRU, isolation can continue.
-	 * Later, for example, when memory hotplug notifier runs, these
-	 * pages reported as "can be isolated" should be isolated(freed)
-	 * by the balloon driver through the memory notifier chain.
-	 */
-	notifier_ret = memory_isolate_notify(MEM_ISOLATE_COUNT, &arg);
-	notifier_ret = notifier_to_errno(notifier_ret);
-	if (notifier_ret)
-		goto out;
-	/*
-	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
-	 * We just check MOVABLE pages.
-	 */
-	if (!__has_unmovable_pages(zone, page, arg.pages_found))
-		ret = 0;
-	/*
-	 * Unmovable means "not-on-lru" pages. If Unmovable pages are
-	 * larger than removable-by-driver pages reported by notifier,
-	 * we'll fail.
-	 */
-
-out:
-	if (!ret) {
-		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
-		move_freepages_block(zone, page, MIGRATE_ISOLATE);
-	}
-
-	spin_unlock_irqrestore(&zone->lock, flags);
-	if (!ret)
-		drain_all_pages();
-	return ret;
-}
-
-void unset_migratetype_isolate(struct page *page, unsigned migratetype)
-{
-	struct zone *zone;
-	unsigned long flags;
-	zone = page_zone(page);
-	spin_lock_irqsave(&zone->lock, flags);
-	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
-		goto out;
-	set_pageblock_migratetype(page, migratetype);
-	move_freepages_block(zone, page, migratetype);
-out:
-	spin_unlock_irqrestore(&zone->lock, flags);
+	return !has_unmovable_pages(zone, page, 0);
 }
 
 #ifdef CONFIG_CMA
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index c9f0477..fb482cf 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -5,8 +5,79 @@
 #include <linux/mm.h>
 #include <linux/page-isolation.h>
 #include <linux/pageblock-flags.h>
+#include <linux/memory.h>
 #include "internal.h"
 
+int set_migratetype_isolate(struct page *page)
+{
+	struct zone *zone;
+	unsigned long flags, pfn;
+	struct memory_isolate_notify arg;
+	int notifier_ret;
+	int ret = -EBUSY;
+
+	zone = page_zone(page);
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	pfn = page_to_pfn(page);
+	arg.start_pfn = pfn;
+	arg.nr_pages = pageblock_nr_pages;
+	arg.pages_found = 0;
+
+	/*
+	 * It may be possible to isolate a pageblock even if the
+	 * migratetype is not MIGRATE_MOVABLE. The memory isolation
+	 * notifier chain is used by balloon drivers to return the
+	 * number of pages in a range that are held by the balloon
+	 * driver to shrink memory. If all the pages are accounted for
+	 * by balloons, are free, or on the LRU, isolation can continue.
+	 * Later, for example, when memory hotplug notifier runs, these
+	 * pages reported as "can be isolated" should be isolated(freed)
+	 * by the balloon driver through the memory notifier chain.
+	 */
+	notifier_ret = memory_isolate_notify(MEM_ISOLATE_COUNT, &arg);
+	notifier_ret = notifier_to_errno(notifier_ret);
+	if (notifier_ret)
+		goto out;
+	/*
+	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
+	 * We just check MOVABLE pages.
+	 */
+	if (!has_unmovable_pages(zone, page, arg.pages_found))
+		ret = 0;
+
+	/*
+	 * immobile means "not-on-lru" paes. If immobile is larger than
+	 * removable-by-driver pages reported by notifier, we'll fail.
+	 */
+
+out:
+	if (!ret) {
+		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
+		move_freepages_block(zone, page, MIGRATE_ISOLATE);
+	}
+
+	spin_unlock_irqrestore(&zone->lock, flags);
+	if (!ret)
+		drain_all_pages();
+	return ret;
+}
+
+void unset_migratetype_isolate(struct page *page, unsigned migratetype)
+{
+	struct zone *zone;
+	unsigned long flags;
+	zone = page_zone(page);
+	spin_lock_irqsave(&zone->lock, flags);
+	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
+		goto out;
+	set_pageblock_migratetype(page, migratetype);
+	move_freepages_block(zone, page, migratetype);
+out:
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
+
 static inline struct page *
 __first_valid_page(unsigned long pfn, unsigned long nr_pages)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
