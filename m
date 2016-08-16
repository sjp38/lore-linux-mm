Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD06B6B0262
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 22:51:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so149771620pfg.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 19:51:32 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id y82si29637703pfd.118.2016.08.15.19.51.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 19:51:32 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id cf3so4468253pad.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 19:51:32 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 3/6] mm/page_owner: move page_owner specific function to page_owner.c
Date: Tue, 16 Aug 2016 11:51:16 +0900
Message-Id: <1471315879-32294-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1471315879-32294-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1471315879-32294-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is no reason that page_owner specific function resides on vmstat.c.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/page_owner.h |  2 ++
 mm/page_owner.c            | 77 ++++++++++++++++++++++++++++++++++++++++++++
 mm/vmstat.c                | 79 ----------------------------------------------
 3 files changed, 79 insertions(+), 79 deletions(-)

diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
index 30583ab..2be728d 100644
--- a/include/linux/page_owner.h
+++ b/include/linux/page_owner.h
@@ -14,6 +14,8 @@ extern void __split_page_owner(struct page *page, unsigned int order);
 extern void __copy_page_owner(struct page *oldpage, struct page *newpage);
 extern void __set_page_owner_migrate_reason(struct page *page, int reason);
 extern void __dump_page_owner(struct page *page);
+extern void pagetypeinfo_showmixedcount_print(struct seq_file *m,
+					pg_data_t *pgdat, struct zone *zone);
 
 static inline void reset_page_owner(struct page *page, unsigned int order)
 {
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 3b241f5..2cae0b2 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -8,6 +8,7 @@
 #include <linux/jump_label.h>
 #include <linux/migrate.h>
 #include <linux/stackdepot.h>
+#include <linux/seq_file.h>
 
 #include "internal.h"
 
@@ -214,6 +215,82 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
 	__set_bit(PAGE_EXT_OWNER, &new_ext->flags);
 }
 
+void pagetypeinfo_showmixedcount_print(struct seq_file *m, pg_data_t *pgdat,
+					struct zone *zone)
+{
+	struct page *page;
+	struct page_ext *page_ext;
+	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;
+	unsigned long end_pfn = pfn + zone->spanned_pages;
+	unsigned long count[MIGRATE_TYPES] = { 0, };
+	int pageblock_mt, page_mt;
+	int i;
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
+			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+			continue;
+		}
+
+		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+		block_end_pfn = min(block_end_pfn, end_pfn);
+
+		page = pfn_to_page(pfn);
+		pageblock_mt = get_pageblock_migratetype(page);
+
+		for (; pfn < block_end_pfn; pfn++) {
+			if (!pfn_valid_within(pfn))
+				continue;
+
+			page = pfn_to_page(pfn);
+
+			if (page_zone(page) != zone)
+				continue;
+
+			if (PageBuddy(page)) {
+				pfn += (1UL << page_order(page)) - 1;
+				continue;
+			}
+
+			if (PageReserved(page))
+				continue;
+
+			page_ext = lookup_page_ext(page);
+			if (unlikely(!page_ext))
+				continue;
+
+			if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
+				continue;
+
+			page_mt = gfpflags_to_migratetype(page_ext->gfp_mask);
+			if (pageblock_mt != page_mt) {
+				if (is_migrate_cma(pageblock_mt))
+					count[MIGRATE_MOVABLE]++;
+				else
+					count[pageblock_mt]++;
+
+				pfn = block_end_pfn;
+				break;
+			}
+			pfn += (1UL << page_ext->order) - 1;
+		}
+	}
+
+	/* Print counts */
+	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	for (i = 0; i < MIGRATE_TYPES; i++)
+		seq_printf(m, "%12lu ", count[i]);
+	seq_putc(m, '\n');
+}
+
 static ssize_t
 print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		struct page *page, struct page_ext *page_ext,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 84397e8..dc04e76 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1254,85 +1254,6 @@ static int pagetypeinfo_showblockcount(struct seq_file *m, void *arg)
 	return 0;
 }
 
-#ifdef CONFIG_PAGE_OWNER
-static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
-							pg_data_t *pgdat,
-							struct zone *zone)
-{
-	struct page *page;
-	struct page_ext *page_ext;
-	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;
-	unsigned long end_pfn = pfn + zone->spanned_pages;
-	unsigned long count[MIGRATE_TYPES] = { 0, };
-	int pageblock_mt, page_mt;
-	int i;
-
-	/* Scan block by block. First and last block may be incomplete */
-	pfn = zone->zone_start_pfn;
-
-	/*
-	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
-	 * a zone boundary, it will be double counted between zones. This does
-	 * not matter as the mixed block count will still be correct
-	 */
-	for (; pfn < end_pfn; ) {
-		if (!pfn_valid(pfn)) {
-			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
-			continue;
-		}
-
-		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
-		block_end_pfn = min(block_end_pfn, end_pfn);
-
-		page = pfn_to_page(pfn);
-		pageblock_mt = get_pageblock_migratetype(page);
-
-		for (; pfn < block_end_pfn; pfn++) {
-			if (!pfn_valid_within(pfn))
-				continue;
-
-			page = pfn_to_page(pfn);
-
-			if (page_zone(page) != zone)
-				continue;
-
-			if (PageBuddy(page)) {
-				pfn += (1UL << page_order(page)) - 1;
-				continue;
-			}
-
-			if (PageReserved(page))
-				continue;
-
-			page_ext = lookup_page_ext(page);
-			if (unlikely(!page_ext))
-				continue;
-
-			if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
-				continue;
-
-			page_mt = gfpflags_to_migratetype(page_ext->gfp_mask);
-			if (pageblock_mt != page_mt) {
-				if (is_migrate_cma(pageblock_mt))
-					count[MIGRATE_MOVABLE]++;
-				else
-					count[pageblock_mt]++;
-
-				pfn = block_end_pfn;
-				break;
-			}
-			pfn += (1UL << page_ext->order) - 1;
-		}
-	}
-
-	/* Print counts */
-	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
-	for (i = 0; i < MIGRATE_TYPES; i++)
-		seq_printf(m, "%12lu ", count[i]);
-	seq_putc(m, '\n');
-}
-#endif /* CONFIG_PAGE_OWNER */
-
 /*
  * Print out the number of pageblocks for each migratetype that contain pages
  * of other types. This gives an indication of how well fallbacks are being
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
