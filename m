Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 55F486B00A3
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 07:39:21 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LWY00L40TTFOL80@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 29 Dec 2011 12:39:16 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LWY00L1UTTFZ0@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 29 Dec 2011 12:39:15 +0000 (GMT)
Date: Thu, 29 Dec 2011 13:39:05 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 04/11] mm: page_alloc: introduce alloc_contig_range()
In-reply-to: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1325162352-24709-5-git-send-email-m.szyprowski@samsung.com>
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

From: Michal Nazarewicz <mina86@mina86.com>

This commit adds the alloc_contig_range() function which tries
to allocate given range of pages.  It tries to migrate all
already allocated pages that fall in the range thus freeing them.
Once all pages in the range are freed they are removed from the
buddy system thus allocated for the caller to use.

__alloc_contig_migrate_range() borrows some code from KAMEZAWA
Hiroyuki's __alloc_contig_pages().

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 include/linux/page-isolation.h |    3 +
 mm/page_alloc.c                |  190 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 193 insertions(+), 0 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 051c1b1..d305080 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -33,5 +33,8 @@ test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
 extern int set_migratetype_isolate(struct page *page);
 extern void unset_migratetype_isolate(struct page *page);
 
+/* The below functions must be run on a range from a single zone. */
+int alloc_contig_range(unsigned long start, unsigned long end);
+void free_contig_range(unsigned long pfn, unsigned nr_pages);
 
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f88b320..47b0a85 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -57,6 +57,7 @@
 #include <linux/ftrace_event.h>
 #include <linux/memcontrol.h>
 #include <linux/prefetch.h>
+#include <linux/migrate.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -5711,6 +5712,195 @@ out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
+static unsigned long pfn_align_to_maxpage_down(unsigned long pfn)
+{
+	return pfn & ~(MAX_ORDER_NR_PAGES - 1);
+}
+
+static unsigned long pfn_align_to_maxpage_up(unsigned long pfn)
+{
+	return ALIGN(pfn, MAX_ORDER_NR_PAGES);
+}
+
+static struct page *
+__cma_migrate_alloc(struct page *page, unsigned long private, int **resultp)
+{
+	return alloc_page(GFP_HIGHUSER_MOVABLE);
+}
+
+static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
+{
+	/* This function is based on compact_zone() from compaction.c. */
+
+	unsigned long pfn = start;
+	int ret = -EBUSY;
+	unsigned tries = 0;
+
+	struct compact_control cc = {
+		.nr_migratepages = 0,
+		.order = -1,
+		.zone = page_zone(pfn_to_page(start)),
+		.sync = true,
+	};
+	INIT_LIST_HEAD(&cc.migratepages);
+
+	migrate_prep_local();
+
+	while (pfn < end || cc.nr_migratepages) {
+		/* Abort on signal */
+		if (fatal_signal_pending(current)) {
+			ret = -EINTR;
+			goto done;
+		}
+
+		/* Get some pages to migrate. */
+		if (list_empty(&cc.migratepages)) {
+			cc.nr_migratepages = 0;
+			pfn = isolate_migratepages_range(cc.zone, &cc,
+							 pfn, end);
+			if (!pfn) {
+				ret = -EINTR;
+				goto done;
+			}
+			tries = 0;
+		}
+
+		/* Try to migrate. */
+		ret = migrate_pages(&cc.migratepages, __cma_migrate_alloc,
+				    0, false, true);
+
+		/* Migrated all of them? Great! */
+		if (list_empty(&cc.migratepages))
+			continue;
+
+		/* Try five times. */
+		if (++tries == 5) {
+			ret = ret < 0 ? ret : -EBUSY;
+			goto done;
+		}
+
+		/* Before each time drain everything and reschedule. */
+		lru_add_drain_all();
+		drain_all_pages();
+		cond_resched();
+	}
+	ret = 0;
+
+done:
+	/* Make sure all pages are isolated. */
+	if (!ret) {
+		lru_add_drain_all();
+		drain_all_pages();
+		if (WARN_ON(test_pages_isolated(start, end)))
+			ret = -EBUSY;
+	}
+
+	/* Release pages */
+	putback_lru_pages(&cc.migratepages);
+
+	return ret;
+}
+
+/**
+ * alloc_contig_range() -- tries to allocate given range of pages
+ * @start:	start PFN to allocate
+ * @end:	one-past-the-last PFN to allocate
+ *
+ * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
+ * aligned, hovewer it's callers responsibility to guarantee that we
+ * are the only thread that changes migrate type of pageblocks the
+ * pages fall in.
+ *
+ * Returns zero on success or negative error code.  On success all
+ * pages which PFN is in (start, end) are allocated for the caller and
+ * need to be freed with free_contig_range().
+ */
+int alloc_contig_range(unsigned long start, unsigned long end)
+{
+	unsigned long outer_start, outer_end;
+	int ret;
+
+	/*
+	 * What we do here is we mark all pageblocks in range as
+	 * MIGRATE_ISOLATE.  Because of the way page allocator work, we
+	 * align the range to MAX_ORDER pages so that page allocator
+	 * won't try to merge buddies from different pageblocks and
+	 * change MIGRATE_ISOLATE to some other migration type.
+	 *
+	 * Once the pageblocks are marked as MIGRATE_ISOLATE, we
+	 * migrate the pages from an unaligned range (ie. pages that
+	 * we are interested in).  This will put all the pages in
+	 * range back to page allocator as MIGRATE_ISOLATE.
+	 *
+	 * When this is done, we take the pages in range from page
+	 * allocator removing them from the buddy system.  This way
+	 * page allocator will never consider using them.
+	 *
+	 * This lets us mark the pageblocks back as
+	 * MIGRATE_CMA/MIGRATE_MOVABLE so that free pages in the
+	 * MAX_ORDER aligned range but not in the unaligned, original
+	 * range are put back to page allocator so that buddy can use
+	 * them.
+	 */
+
+	ret = start_isolate_page_range(pfn_align_to_maxpage_down(start),
+				       pfn_align_to_maxpage_up(end));
+	if (ret)
+		goto done;
+
+	ret = __alloc_contig_migrate_range(start, end);
+	if (ret)
+		goto done;
+
+	/*
+	 * Pages from [start, end) are within a MAX_ORDER_NR_PAGES
+	 * aligned blocks that are marked as MIGRATE_ISOLATE.  What's
+	 * more, all pages in [start, end) are free in page allocator.
+	 * What we are going to do is to allocate all pages from
+	 * [start, end) (that is remove them from page allocater).
+	 *
+	 * The only problem is that pages at the beginning and at the
+	 * end of interesting range may be not aligned with pages that
+	 * page allocator holds, ie. they can be part of higher order
+	 * pages.  Because of this, we reserve the bigger range and
+	 * once this is done free the pages we are not interested in.
+	 */
+
+	ret = 0;
+	while (!PageBuddy(pfn_to_page(start & (~0UL << ret))))
+		if (WARN_ON(++ret >= MAX_ORDER)) {
+			ret = -EINVAL;
+			goto done;
+		}
+
+	outer_start = start & (~0UL << ret);
+	outer_end = isolate_freepages_range(page_zone(pfn_to_page(outer_start)),
+					    outer_start, end, NULL);
+	if (!outer_end) {
+		ret = -EBUSY;
+		goto done;
+	}
+	outer_end += outer_start;
+
+	/* Free head and tail (if any) */
+	if (start != outer_start)
+		free_contig_range(outer_start, start - outer_start);
+	if (end != outer_end)
+		free_contig_range(end, outer_end - end);
+
+	ret = 0;
+done:
+	undo_isolate_page_range(pfn_align_to_maxpage_down(start),
+				pfn_align_to_maxpage_up(end));
+	return ret;
+}
+
+void free_contig_range(unsigned long pfn, unsigned nr_pages)
+{
+	for (; nr_pages--; ++pfn)
+		__free_page(pfn_to_page(pfn));
+}
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * All pages in the range must be isolated before calling this.
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
