Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id E7EC46B0078
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 03:11:48 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id g10so2556700pdj.23
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 00:11:48 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id xl10si6548940pbc.222.2014.11.21.00.11.37
        for <linux-mm@kvack.org>;
        Fri, 21 Nov 2014 00:11:38 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 7/7] mm/page_owner: correct owner information for early allocated pages
Date: Fri, 21 Nov 2014 17:14:06 +0900
Message-Id: <1416557646-21755-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1416557646-21755-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1416557646-21755-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Extended memory to store page owner information is initialized some time
later than that page allocator starts. Until initialization, many pages
can be allocated and they have no owner information. This make debugging
using page owner harder, so some fixup will be helpful.

This patch fix up this situation by setting fake owner information
immediately after page extension is initialized. Information doesn't
tell the right owner, but, at least, it can tell whether page is
allocated or not, more correctly.

On my testing, this patch catches 13343 early allocated pages, although
they are mostly allocated from page extension feature. Anyway, after then,
there is no page left that it is allocated and has no page owner flag.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_owner.c |   93 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 91 insertions(+), 2 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index f75dfe0..2ea8d02 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -10,6 +10,8 @@
 static bool page_owner_disabled;
 static bool page_owner_enabled __read_mostly;
 
+static void init_early_allocated_pages(void);
+
 static int early_disable_page_owner(char *buf)
 {
 	page_owner_disabled = true;
@@ -32,6 +34,7 @@ static void init_page_owner(void)
 		return;
 
 	page_owner_enabled = true;
+	init_early_allocated_pages();
 }
 
 struct page_ext_operations page_owner_ops = {
@@ -186,8 +189,8 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 		page_ext = lookup_page_ext(page);
 
 		/*
-		 * Pages allocated before initialization of page_owner are
-		 * non-buddy and have no page_owner info.
+		 * Some pages could be missed by concurrent allocation or free,
+		 * because we don't hold the zone lock.
 		 */
 		if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
 			continue;
@@ -201,6 +204,92 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 	return 0;
 }
 
+static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
+{
+	struct page *page;
+	struct page_ext *page_ext;
+	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;
+	unsigned long end_pfn = pfn + zone->spanned_pages;
+	unsigned long count = 0;
+
+	/* Scan block by block. First and last block may be incomplete */
+	pfn = zone->zone_start_pfn;
+
+	/*
+	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
+	 * a zone boundary, it will be double counted between zones. This does
+	 * not matter as the mixed block count will still be correct
+	 */
+	for (; pfn < end_pfn; ) {
+		if (!pfn_valid(pfn)) {
+			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
+			continue;
+		}
+
+		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+		block_end_pfn = min(block_end_pfn, end_pfn);
+
+		page = pfn_to_page(pfn);
+
+		for (; pfn < block_end_pfn; pfn++) {
+			if (!pfn_valid_within(pfn))
+				continue;
+
+			page = pfn_to_page(pfn);
+
+			/*
+			 * We are safe to check buddy flag and order, because
+			 * this is init stage and only single thread runs.
+			 */
+			if (PageBuddy(page)) {
+				pfn += (1UL << page_order(page)) - 1;
+				continue;
+			}
+
+			if (PageReserved(page))
+				continue;
+
+			page_ext = lookup_page_ext(page);
+
+			/* Maybe overraping zone */
+			if (test_bit(PAGE_EXT_OWNER, &page_ext->flags))
+				continue;
+
+			/* Found early allocated page */
+			set_page_owner(page, 0, 0);
+			count++;
+		}
+	}
+
+	pr_info("Node %d, zone %8s: page owner found early allocated %lu pages\n",
+		pgdat->node_id, zone->name, count);
+}
+
+static void init_zones_in_node(pg_data_t *pgdat)
+{
+	struct zone *zone;
+	struct zone *node_zones = pgdat->node_zones;
+	unsigned long flags;
+
+	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
+		if (!populated_zone(zone))
+			continue;
+
+		spin_lock_irqsave(&zone->lock, flags);
+		init_pages_in_zone(pgdat, zone);
+		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+}
+
+static void init_early_allocated_pages(void)
+{
+	pg_data_t *pgdat;
+
+	drain_all_pages(NULL);
+	for_each_online_pgdat(pgdat)
+		init_zones_in_node(pgdat);
+}
+
 static const struct file_operations proc_page_owner_operations = {
 	.read		= read_page_owner,
 };
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
