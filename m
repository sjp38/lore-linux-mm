Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 917086B0038
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 08:33:05 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id u68so4105674ybf.23
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 05:33:05 -0800 (PST)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id s194si6385931wmb.3.2018.01.09.05.33.04
        for <linux-mm@kvack.org>;
        Tue, 09 Jan 2018 05:33:04 -0800 (PST)
Date: Tue, 9 Jan 2018 14:33:03 +0100
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH] mm/page_owner.c Clean up init_pages_in_zone()
Message-ID: <20180109133303.GA11451@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com

This patch removes two redundant assignments in init_pages_in_zone function

Signed-off-by: Oscar Salvador <osalvador@techadventures.net>
---
 mm/page_owner.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 8602fb41b293..7d20c6cc98e0 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -528,14 +528,11 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 
 static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 {
-	struct page *page;
-	struct page_ext *page_ext;
 	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;
 	unsigned long end_pfn = pfn + zone->spanned_pages;
 	unsigned long count = 0;
 
 	/* Scan block by block. First and last block may be incomplete */
-	pfn = zone->zone_start_pfn;
 
 	/*
 	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
@@ -551,13 +548,11 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
-		page = pfn_to_page(pfn);
-
 		for (; pfn < block_end_pfn; pfn++) {
 			if (!pfn_valid_within(pfn))
 				continue;
 
-			page = pfn_to_page(pfn);
+			struct page *page = pfn_to_page(pfn);
 
 			if (page_zone(page) != zone)
 				continue;
@@ -580,7 +575,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 			if (PageReserved(page))
 				continue;
 
-			page_ext = lookup_page_ext(page);
+			struct page_ext *page_ext = lookup_page_ext(page);
 			if (unlikely(!page_ext))
 				continue;
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
