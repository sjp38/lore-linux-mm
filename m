Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7405D6B006E
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:17:15 -0400 (EDT)
Received: by wgin8 with SMTP id n8so75264870wgi.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:17:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t4si13238403wix.72.2015.04.13.03.17.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 03:17:12 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/14] mm: meminit: Move page initialization into a separate function.
Date: Mon, 13 Apr 2015 11:16:54 +0100
Message-Id: <1428920226-18147-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1428920226-18147-1-git-send-email-mgorman@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
