Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 916D928029C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 07:45:15 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y18so9612862wrh.12
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 04:45:15 -0800 (PST)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id n13si3762693wrn.309.2018.01.17.04.45.14
        for <linux-mm@kvack.org>;
        Wed, 17 Jan 2018 04:45:14 -0800 (PST)
Date: Wed, 17 Jan 2018 13:45:13 +0100
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v3] mm/page_owner: Clean up init_pages_in_zone()
Message-ID: <20180117124513.GA876@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: vbabka@suse.cz, mhocko@suse.com, akpm@linux-foundation.org

This patch cleans up init_pages_in_zone() function.

v2 -> v3: Added suggestions made by Vlastimil Babka
v1 -> v2: Added suggestions made by Michal Hocko

@Andrew: Could you please replace the patch that it's in the -mm tree (next-20180115) 
with commit b5dc82ee364757fcd1d67f2ea8fa4e19bedd6e48 with this one?
Thanks

Signed-off-by: Oscar Salvador (SuSe) <osalvador@techadventures.net>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_owner.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 8602fb41b293..ee55d55a7822 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -528,21 +528,17 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 
 static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 {
-	struct page *page;
-	struct page_ext *page_ext;
-	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;
-	unsigned long end_pfn = pfn + zone->spanned_pages;
+	unsigned long pfn = zone->zone_start_pfn;
+	unsigned long end_pfn = zone_end_pfn(zone);
 	unsigned long count = 0;
 
-	/* Scan block by block. First and last block may be incomplete */
-	pfn = zone->zone_start_pfn;
-
 	/*
 	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
 	 * a zone boundary, it will be double counted between zones. This does
 	 * not matter as the mixed block count will still be correct
 	 */
 	for (; pfn < end_pfn; ) {
+		unsigned long block_end_pfn;
 		if (!pfn_valid(pfn)) {
 			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 			continue;
@@ -551,9 +547,9 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
-		page = pfn_to_page(pfn);
-
 		for (; pfn < block_end_pfn; pfn++) {
+			struct page *page;
+			struct page_ext *page_ext;
 			if (!pfn_valid_within(pfn))
 				continue;
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
