Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D5E2A6B009F
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 15:38:43 -0500 (EST)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LDH003FTLCCO0@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 15 Dec 2010 20:38:39 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LDH0008LLCC0F@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Dec 2010 20:38:37 +0000 (GMT)
Date: Wed, 15 Dec 2010 21:34:26 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCHv8 06/12] mm: alloc_contig_range() added
In-reply-to: <cover.1292443200.git.m.nazarewicz@samsung.com>
Message-id: 
 <37264739706c35290be16df4d61b1d2827b72f61.1292443200.git.m.nazarewicz@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This commit adds the alloc_contig_range() function which tries
to allecate given range of pages.  It tries to migrate all
already allocated pages that fall in the range thus freeing them.
Once all pages in the range are freed they are removed from the
buddy system thus allocated for the caller to use.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/page-isolation.h |    2 +
 mm/page_alloc.c                |  144 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 146 insertions(+), 0 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index f1417ed..c5d1a7c 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -34,6 +34,8 @@ extern int set_migratetype_isolate(struct page *page);
 extern void unset_migratetype_isolate(struct page *page);
 extern unsigned long alloc_contig_freed_pages(unsigned long start,
 					      unsigned long end, gfp_t flag);
+extern int alloc_contig_range(unsigned long start, unsigned long end,
+			      gfp_t flags);
 extern void free_contig_pages(struct page *page, int nr_pages);
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index be240a3..008a6e8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5463,6 +5463,150 @@ unsigned long alloc_contig_freed_pages(unsigned long start, unsigned long end,
 	return pfn;
 }
 
+static unsigned long pfn_to_maxpage(unsigned long pfn)
+{
+	return pfn & ~(MAX_ORDER_NR_PAGES - 1);
+}
+
+static unsigned long pfn_to_maxpage_up(unsigned long pfn)
+{
+	return ALIGN(pfn, MAX_ORDER_NR_PAGES);
+}
+
+#define MIGRATION_RETRY	5
+static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
+{
+	int migration_failed = 0, ret;
+	unsigned long pfn = start;
+
+	/*
+	 * Some code "borrowed" from KAMEZAWA Hiroyuki's
+	 * __alloc_contig_pages().
+	 */
+
+	for (;;) {
+		pfn = scan_lru_pages(pfn, end);
+		if (!pfn || pfn >= end)
+			break;
+
+		ret = do_migrate_range(pfn, end);
+		if (!ret) {
+			migration_failed = 0;
+		} else if (ret != -EBUSY
+			|| ++migration_failed >= MIGRATION_RETRY) {
+			return ret;
+		} else {
+			/* There are unstable pages.on pagevec. */
+			lru_add_drain_all();
+			/*
+			 * there may be pages on pcplist before
+			 * we mark the range as ISOLATED.
+			 */
+			drain_all_pages();
+		}
+		cond_resched();
+	}
+
+	if (!migration_failed) {
+		/* drop all pages in pagevec and pcp list */
+		lru_add_drain_all();
+		drain_all_pages();
+	}
+
+	/* Make sure all pages are isolated */
+	if (WARN_ON(test_pages_isolated(start, end)))
+		return -EBUSY;
+
+	return 0;
+}
+
+/**
+ * alloc_contig_range() -- tries to allocate given range of pages
+ * @start:	start PFN to allocate
+ * @end:	one-past-the-last PFN to allocate
+ * @flags:	flags passed to alloc_contig_freed_pages().
+ *
+ * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
+ * aligned, hovewer it's callers responsibility to guarantee that we
+ * are the only thread that changes migrate type of pageblocks the
+ * pages fall in.
+ *
+ * Returns zero on success or negative error code.  On success all
+ * pages which PFN is in (start, end) are allocated for the caller and
+ * need to be freed with free_contig_pages().
+ */
+int alloc_contig_range(unsigned long start, unsigned long end,
+		       gfp_t flags)
+{
+	unsigned long _start, _end;
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
+	ret = start_isolate_page_range(pfn_to_maxpage(start),
+				       pfn_to_maxpage_up(end));
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
+		if (WARN_ON(++ret >= MAX_ORDER))
+			return -EINVAL;
+
+	_start = start & (~0UL << ret);
+	_end   = alloc_contig_freed_pages(_start, end, flags);
+
+	/* Free head and tail (if any) */
+	if (start != _start)
+		free_contig_pages(pfn_to_page(_start), start - _start);
+	if (end != _end)
+		free_contig_pages(pfn_to_page(end), _end - end);
+
+	ret = 0;
+done:
+	undo_isolate_page_range(pfn_to_maxpage(start), pfn_to_maxpage_up(end));
+	return ret;
+}
+
 void free_contig_pages(struct page *page, int nr_pages)
 {
 	for (; nr_pages; --nr_pages, ++page)
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
