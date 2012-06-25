Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 529C46B030A
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 00:59:32 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/2] mm: Factor out memory isolate functions
Date: Mon, 25 Jun 2012 13:59:26 +0900
Message-Id: <1340600367-23620-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1340600367-23620-1-git-send-email-minchan@kernel.org>
References: <1340600367-23620-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, Marek Szyprowski <m.szyprowski@samsung.com>

Now mm/page_alloc.c has some memory isolation functions but they
are used oly when we enable CONFIG_{CMA|MEMORY_HOTPLUG|MEMORY_FAILURE}.
So let's make it configurable by new CONFIG_MEMORY_ISOLATION so that it
can reduce binary size and we can check it simple by
CONFIG_MEMORY_ISOLATION,
not if defined CONFIG_{CMA|MEMORY_HOTPLUG|MEMORY_FAILURE}.

This patch is based on next-20120621.

Cc: Andi Kleen <andi@firstfloor.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---

Andrew, I know this patch is conflict with current mmotm totally but
I don't know what tree I should use. I hope it's a git tree instead of
quit-based version. Anyway, If you feel it's inconvenient,
let me know it and I will resend it on tree you mention.
Thanks.

 drivers/base/Kconfig           |    1 +
 include/linux/page-isolation.h |    8 ++---
 mm/Kconfig                     |    5 +++
 mm/Makefile                    |    4 +--
 mm/page_alloc.c                |   71 ----------------------------------------
 mm/page_isolation.c            |   71 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 83 insertions(+), 77 deletions(-)

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
index 3bdcab3..0569a3e 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -10,7 +10,7 @@
  * free all pages in the range. test_page_isolated() can be used for
  * test it.
  */
-extern int
+int
 start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			 unsigned migratetype);
 
@@ -18,7 +18,7 @@ start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
  * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
  * target range is [start_pfn, end_pfn)
  */
-extern int
+int
 undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			unsigned migratetype);
 
@@ -30,8 +30,8 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
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
index 25e8002..a0c7725 100644
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
index 2c29b1c..c175fa9 100644
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
@@ -5555,76 +5554,6 @@ bool is_pageblock_removable_nolock(struct page *page)
 	return __count_immobile_pages(zone, page, 0);
 }
 
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
-	if (__count_immobile_pages(zone, page, arg.pages_found))
-		ret = 0;
-
-	/*
-	 * immobile means "not-on-lru" paes. If immobile is larger than
-	 * removable-by-driver pages reported by notifier, we'll fail.
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
-}
-
 #ifdef CONFIG_CMA
 
 static unsigned long pfn_max_align_down(unsigned long pfn)
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index c9f0477..1a9cb36 100644
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
+	if (__count_immobile_pages(zone, page, arg.pages_found))
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
