Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id C8DEE6B0070
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 06:33:24 -0400 (EDT)
Received: by wgen6 with SMTP id n6so13526922wge.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 03:33:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bz8si13028140wjc.178.2015.04.23.03.33.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 03:33:20 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/13] mm: meminit: Move page initialization into a separate function.
Date: Thu, 23 Apr 2015 11:33:05 +0100
Message-Id: <1429785196-7668-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1429785196-7668-1-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Robin Holt <holt@sgi.com>

Currently, memmap_init_zone() has all the smarts for initializing a single
page. A subset of this is required for parallel page initialisation and so
this patch breaks up the monolithic function in preparation.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 79 +++++++++++++++++++++++++++++++++------------------------
 1 file changed, 46 insertions(+), 33 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40e29429e7b0..fd7a6d09062d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -778,6 +778,51 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 	return 0;
 }
 
+static void __meminit __init_single_page(struct page *page, unsigned long pfn,
+				unsigned long zone, int nid)
+{
+	struct zone *z = &NODE_DATA(nid)->node_zones[zone];
+
+	set_page_links(page, zone, nid, pfn);
+	mminit_verify_page_links(page, zone, nid, pfn);
+	init_page_count(page);
+	page_mapcount_reset(page);
+	page_cpupid_reset_last(page);
+	SetPageReserved(page);
+
+	/*
+	 * Mark the block movable so that blocks are reserved for
+	 * movable at startup. This will force kernel allocations
+	 * to reserve their blocks rather than leaking throughout
+	 * the address space during boot when many long-lived
+	 * kernel allocations are made. Later some blocks near
+	 * the start are marked MIGRATE_RESERVE by
+	 * setup_zone_migrate_reserve()
+	 *
+	 * bitmap is created for zone's valid pfn range. but memmap
+	 * can be created for invalid pages (for alignment)
+	 * check here not to call set_pageblock_migratetype() against
+	 * pfn out of zone.
+	 */
+	if ((z->zone_start_pfn <= pfn)
+	    && (pfn < zone_end_pfn(z))
+	    && !(pfn & (pageblock_nr_pages - 1)))
+		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+
+	INIT_LIST_HEAD(&page->lru);
+#ifdef WANT_PAGE_VIRTUAL
+	/* The shift won't overflow because ZONE_NORMAL is below 4G. */
+	if (!is_highmem_idx(zone))
+		set_page_address(page, __va(pfn << PAGE_SHIFT));
+#endif
+}
+
+static void __meminit __init_single_pfn(unsigned long pfn, unsigned long zone,
+					int nid)
+{
+	return __init_single_page(pfn_to_page(pfn), pfn, zone, nid);
+}
+
 static bool free_pages_prepare(struct page *page, unsigned int order)
 {
 	bool compound = PageCompound(page);
@@ -4124,7 +4169,6 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		unsigned long start_pfn, enum memmap_context context)
 {
-	struct page *page;
 	unsigned long end_pfn = start_pfn + size;
 	unsigned long pfn;
 	struct zone *z;
@@ -4145,38 +4189,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			if (!early_pfn_in_nid(pfn, nid))
 				continue;
 		}
-		page = pfn_to_page(pfn);
-		set_page_links(page, zone, nid, pfn);
-		mminit_verify_page_links(page, zone, nid, pfn);
-		init_page_count(page);
-		page_mapcount_reset(page);
-		page_cpupid_reset_last(page);
-		SetPageReserved(page);
-		/*
-		 * Mark the block movable so that blocks are reserved for
-		 * movable at startup. This will force kernel allocations
-		 * to reserve their blocks rather than leaking throughout
-		 * the address space during boot when many long-lived
-		 * kernel allocations are made. Later some blocks near
-		 * the start are marked MIGRATE_RESERVE by
-		 * setup_zone_migrate_reserve()
-		 *
-		 * bitmap is created for zone's valid pfn range. but memmap
-		 * can be created for invalid pages (for alignment)
-		 * check here not to call set_pageblock_migratetype() against
-		 * pfn out of zone.
-		 */
-		if ((z->zone_start_pfn <= pfn)
-		    && (pfn < zone_end_pfn(z))
-		    && !(pfn & (pageblock_nr_pages - 1)))
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-
-		INIT_LIST_HEAD(&page->lru);
-#ifdef WANT_PAGE_VIRTUAL
-		/* The shift won't overflow because ZONE_NORMAL is below 4G. */
-		if (!is_highmem_idx(zone))
-			set_page_address(page, __va(pfn << PAGE_SHIFT));
-#endif
+		__init_single_pfn(pfn, zone, nid);
 	}
 }
 
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
