Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9BAB56B0099
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 06:27:04 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LDD00DNY6GY1I70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 13 Dec 2010 11:26:58 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LDD00HYE6GX7J@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 13 Dec 2010 11:26:58 +0000 (GMT)
Date: Mon, 13 Dec 2010 12:26:46 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCHv7 05/10] mm: alloc_contig_free_pages() added
In-reply-to: <cover.1292004520.git.m.nazarewicz@samsung.com>
Message-id: 
 <f94d1c5a7b4265c4cf537226e584f48583c82c67.1292004520.git.m.nazarewicz@samsung.com>
References: <cover.1292004520.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, BooJin Kim <boojin.kim@samsung.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Michal Nazarewicz <m.nazarewicz@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This commit introduces alloc_contig_free_pages() function
which allocates (ie. removes from buddy system) free pages
in range.  Caller has to guarantee that all pages in range
are in buddy system.

Along with alloc_contig_free_pages(), a free_contig_pages()
function is provided which frees (or a subset of) pages
allocated with alloc_contig_free_pages().

I, Michal Nazarewicz, have modified the
alloc_contig_free_pages() function slightly from the original
version, mostly to make it easier to allocate note MAX_ORDER
aligned pages.  This is done by making the function return
a pfn of a page one past the one allocated which may be
further then caller requested.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/page-isolation.h |    3 ++
 mm/page_alloc.c                |   42 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 58cdbac..f1417ed 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -32,6 +32,9 @@ test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
  */
 extern int set_migratetype_isolate(struct page *page);
 extern void unset_migratetype_isolate(struct page *page);
+extern unsigned long alloc_contig_freed_pages(unsigned long start,
+					      unsigned long end, gfp_t flag);
+extern void free_contig_pages(struct page *page, int nr_pages);
 
 /*
  * For migration.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 826ba69..997f6c8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5425,6 +5425,48 @@ out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
+unsigned long alloc_contig_freed_pages(unsigned long start,
+				       unsigned long end, gfp_t flag)
+{
+	unsigned long pfn = start, count;
+	struct page *page;
+	struct zone *zone;
+	int order;
+
+	VM_BUG_ON(!pfn_valid(pfn));
+	page = pfn_to_page(pfn);
+
+	zone = page_zone(page);
+	spin_lock_irq(&zone->lock);
+	for (;;) {
+		VM_BUG_ON(page_count(page) || !PageBuddy(page));
+		list_del(&page->lru);
+		order = page_order(page);
+		zone->free_area[order].nr_free--;
+		rmv_page_order(page);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
+		pfn  += 1 << order;
+		if (pfn >= end)
+			break;
+		VM_BUG_ON(!pfn_valid(pfn));
+		page += 1 << order;
+	}
+	spin_unlock_irq(&zone->lock);
+
+	/* After this, pages in the range can be freed one be one */
+	page = pfn_to_page(start);
+	for (count = pfn - start; count; --count, ++page)
+		prep_new_page(page, 0, flag);
+
+	return pfn;
+}
+
+void free_contig_pages(struct page *page, int nr_pages)
+{
+	for (; nr_pages; --nr_pages, ++page)
+		__free_page(page);
+}
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * All pages in the range must be isolated before calling this.
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
