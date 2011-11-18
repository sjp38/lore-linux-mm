Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 49D336B006C
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 11:43:29 -0500 (EST)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LUV00LJ97S904@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 18 Nov 2011 16:43:22 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LUV009ZY7S9US@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 18 Nov 2011 16:43:21 +0000 (GMT)
Date: Fri, 18 Nov 2011 17:43:11 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 04/11] mm: compaction: export some of the functions
In-reply-to: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1321634598-16859-5-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

From: Michal Nazarewicz <mina86@mina86.com>

This commit exports some of the functions from compaction.c file
outside of it adding their declaration into internal.h header
file so that other mm related code can use them.

This forced compaction.c to always be compiled (as opposed to being
compiled only if CONFIG_COMPACTION is defined) but as to avoid
introducing code that user did not ask for, part of the compaction.c
is now wrapped in on #ifdef.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 mm/Makefile     |    3 +-
 mm/compaction.c |  112 +++++++++++++++++++++++--------------------------------
 mm/internal.h   |   35 +++++++++++++++++
 3 files changed, 83 insertions(+), 67 deletions(-)

diff --git a/mm/Makefile b/mm/Makefile
index 50ec00e..24ed801 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -13,7 +13,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
 			   page_isolation.o mm_init.o mmu_context.o percpu.o \
-			   $(mmu-y)
+			   $(mmu-y) compaction.o
 obj-y += init-mm.o
 
 ifdef CONFIG_NO_BOOTMEM
@@ -32,7 +32,6 @@ obj-$(CONFIG_NUMA) 	+= mempolicy.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
-obj-$(CONFIG_COMPACTION) += compaction.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
diff --git a/mm/compaction.c b/mm/compaction.c
index 09c9702..e71ceaf 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -19,28 +19,7 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/compaction.h>
 
-/*
- * compact_control is used to track pages being migrated and the free pages
- * they are being migrated to during memory compaction. The free_pfn starts
- * at the end of a zone and migrate_pfn begins at the start. Movable pages
- * are moved to the end of a zone during a compaction run and the run
- * completes when free_pfn <= migrate_pfn
- */
-struct compact_control {
-	struct list_head freepages;	/* List of free pages to migrate to */
-	struct list_head migratepages;	/* List of pages being migrated */
-	unsigned long nr_freepages;	/* Number of isolated free pages */
-	unsigned long nr_migratepages;	/* Number of pages to migrate */
-	unsigned long free_pfn;		/* isolate_freepages search base */
-	unsigned long migrate_pfn;	/* isolate_migratepages search base */
-	bool sync;			/* Synchronous migration */
-
-	unsigned int order;		/* order a direct compactor needs */
-	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
-	struct zone *zone;
-};
-
-static unsigned long release_freepages(struct list_head *freelist)
+unsigned long release_freepages(struct list_head *freelist)
 {
 	struct page *page, *next;
 	unsigned long count = 0;
@@ -71,7 +50,7 @@ static unsigned long release_freepages(struct list_head *freelist)
  * Returns number of isolated pages.  This may be more then end-start
  * if end fell in a middle of a free page.
  */
-static unsigned long
+unsigned long
 isolate_freepages_range(struct zone *zone,
 			unsigned long start, unsigned long end,
 			struct list_head *freelist)
@@ -263,13 +242,6 @@ static bool too_many_isolated(struct zone *zone)
 	return isolated > (inactive + active) / 2;
 }
 
-/* possible outcome of isolate_migratepages */
-typedef enum {
-	ISOLATE_ABORT,		/* Abort compaction now */
-	ISOLATE_NONE,		/* No pages isolated, continue scanning */
-	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
-} isolate_migrate_t;
-
 /**
  * isolate_migratepages_range() - isolate all migrate-able pages in range.
  * @zone:	Zone pages are in.
@@ -289,7 +261,7 @@ typedef enum {
  * does not modify any cc's fields, ie. it does not modify (or read
  * for that matter) cc->migrate_pfn.
  */
-static unsigned long
+unsigned long
 isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			   unsigned long low_pfn, unsigned long end_pfn)
 {
@@ -404,43 +376,11 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 }
 
 /*
- * Isolate all pages that can be migrated from the block pointed to by
- * the migrate scanner within compact_control.
- */
-static isolate_migrate_t isolate_migratepages(struct zone *zone,
-					struct compact_control *cc)
-{
-	unsigned long low_pfn, end_pfn;
-
-	/* Do not scan outside zone boundaries */
-	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
-
-	/* Only scan within a pageblock boundary */
-	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
-
-	/* Do not cross the free scanner or scan within a memory hole */
-	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
-		cc->migrate_pfn = end_pfn;
-		return ISOLATE_NONE;
-	}
-
-	/* Perform the isolation */
-	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
-	if (!low_pfn)
-		return ISOLATE_ABORT;
-
-	cc->migrate_pfn = low_pfn;
-
-	return ISOLATE_SUCCESS;
-}
-
-/*
  * This is a migrate-callback that "allocates" freepages by taking pages
  * from the isolated freelists in the block we are migrating to.
  */
-static struct page *compaction_alloc(struct page *migratepage,
-					unsigned long data,
-					int **result)
+struct page *compaction_alloc(struct page *migratepage, unsigned long data,
+			      int **result)
 {
 	struct compact_control *cc = (struct compact_control *)data;
 	struct page *freepage;
@@ -460,6 +400,8 @@ static struct page *compaction_alloc(struct page *migratepage,
 	return freepage;
 }
 
+#ifdef CONFIG_COMPACTION
+
 /*
  * We cannot control nr_migratepages and nr_freepages fully when migration is
  * running as migrate_pages() has no knowledge of compact_control. When
@@ -480,6 +422,44 @@ static void update_nr_listpages(struct compact_control *cc)
 	cc->nr_freepages = nr_freepages;
 }
 
+/* possible outcome of isolate_migratepages */
+typedef enum {
+	ISOLATE_ABORT,		/* Abort compaction now */
+	ISOLATE_NONE,		/* No pages isolated, continue scanning */
+	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
+} isolate_migrate_t;
+
+/*
+ * Isolate all pages that can be migrated from the block pointed to by
+ * the migrate scanner within compact_control.
+ */
+static isolate_migrate_t isolate_migratepages(struct zone *zone,
+					struct compact_control *cc)
+{
+	unsigned long low_pfn, end_pfn;
+
+	/* Do not scan outside zone boundaries */
+	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
+
+	/* Only scan within a pageblock boundary */
+	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
+
+	/* Do not cross the free scanner or scan within a memory hole */
+	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
+		cc->migrate_pfn = end_pfn;
+		return ISOLATE_NONE;
+	}
+
+	/* Perform the isolation */
+	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
+	if (!low_pfn)
+		return ISOLATE_ABORT;
+
+	cc->migrate_pfn = low_pfn;
+
+	return ISOLATE_SUCCESS;
+}
+
 static int compact_finished(struct zone *zone,
 			    struct compact_control *cc)
 {
@@ -796,3 +776,5 @@ void compaction_unregister_node(struct node *node)
 	return sysdev_remove_file(&node->sysdev, &attr_compact);
 }
 #endif /* CONFIG_SYSFS && CONFIG_NUMA */
+
+#endif /* CONFIG_COMPACTION */
diff --git a/mm/internal.h b/mm/internal.h
index 2189af4..67ec1d3 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -100,6 +100,41 @@ extern void prep_compound_page(struct page *page, unsigned long order);
 extern bool is_free_buddy_page(struct page *page);
 #endif
 
+/*
+ * in mm/compaction.c
+ */
+/*
+ * compact_control is used to track pages being migrated and the free pages
+ * they are being migrated to during memory compaction. The free_pfn starts
+ * at the end of a zone and migrate_pfn begins at the start. Movable pages
+ * are moved to the end of a zone during a compaction run and the run
+ * completes when free_pfn <= migrate_pfn
+ */
+struct compact_control {
+	struct list_head freepages;	/* List of free pages to migrate to */
+	struct list_head migratepages;	/* List of pages being migrated */
+	unsigned long nr_freepages;	/* Number of isolated free pages */
+	unsigned long nr_migratepages;	/* Number of pages to migrate */
+	unsigned long free_pfn;		/* isolate_freepages search base */
+	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+	bool sync;			/* Synchronous migration */
+
+	unsigned int order;		/* order a direct compactor needs */
+	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
+	struct zone *zone;
+};
+
+unsigned long release_freepages(struct list_head *freelist);
+unsigned long
+isolate_freepages_range(struct zone *zone,
+			unsigned long start, unsigned long end,
+			struct list_head *freelist);
+unsigned long
+isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
+			   unsigned long low_pfn, unsigned long end_pfn);
+struct page *compaction_alloc(struct page *migratepage, unsigned long data,
+			      int **result);
+
 
 /*
  * function for dealing with page's order in buddy system.
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
