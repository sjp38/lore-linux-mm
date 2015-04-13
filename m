Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id E64AC6B0082
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:17:42 -0400 (EDT)
Received: by wizk4 with SMTP id k4so66090799wiz.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:17:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fa3si16817730wjd.148.2015.04.13.03.17.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 03:17:24 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/14] mm: meminit: Reduce number of times pageblocks are set during initialisation
Date: Mon, 13 Apr 2015 11:17:05 +0100
Message-Id: <1428920226-18147-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1428920226-18147-1-git-send-email-mgorman@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

During parallel memory initialisation, ranges are checked for every PFN
unnecessarily which increases boot times. This patch alters when the
ranges are checked to reduce the work done for each page frame.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 45 +++++++++++++++++++++++----------------------
 1 file changed, 23 insertions(+), 22 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bacd97b0030e..b4c320beebc7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -875,33 +875,12 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
-	struct zone *z = &NODE_DATA(nid)->node_zones[zone];
-
 	set_page_links(page, zone, nid, pfn);
 	mminit_verify_page_links(page, zone, nid, pfn);
 	init_page_count(page);
 	page_mapcount_reset(page);
 	page_cpupid_reset_last(page);
 
-	/*
-	 * Mark the block movable so that blocks are reserved for
-	 * movable at startup. This will force kernel allocations
-	 * to reserve their blocks rather than leaking throughout
-	 * the address space during boot when many long-lived
-	 * kernel allocations are made. Later some blocks near
-	 * the start are marked MIGRATE_RESERVE by
-	 * setup_zone_migrate_reserve()
-	 *
-	 * bitmap is created for zone's valid pfn range. but memmap
-	 * can be created for invalid pages (for alignment)
-	 * check here not to call set_pageblock_migratetype() against
-	 * pfn out of zone.
-	 */
-	if ((z->zone_start_pfn <= pfn)
-	    && (pfn < zone_end_pfn(z))
-	    && !(pfn & (pageblock_nr_pages - 1)))
-		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-
 	INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL
 	/* The shift won't overflow because ZONE_NORMAL is below 4G. */
@@ -1083,6 +1062,7 @@ void __defermem_init deferred_free_range(struct page *page, unsigned long pfn,
 	int i;
 
 	if (nr_pages == MAX_ORDER_NR_PAGES && (pfn & (MAX_ORDER_NR_PAGES-1)) == 0) {
+		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 		__free_pages_boot_core(page, pfn, MAX_ORDER-1);
 		return;
 	}
@@ -4490,7 +4470,28 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			if (!update_defer_init(pgdat, pfn, &nr_initialised))
 				break;
 		}
-		__init_single_pfn(pfn, zone, nid);
+
+		/*
+		 * Mark the block movable so that blocks are reserved for
+		 * movable at startup. This will force kernel allocations
+		 * to reserve their blocks rather than leaking throughout
+		 * the address space during boot when many long-lived
+		 * kernel allocations are made. Later some blocks near
+		 * the start are marked MIGRATE_RESERVE by
+		 * setup_zone_migrate_reserve()
+		 *
+		 * bitmap is created for zone's valid pfn range. but memmap
+		 * can be created for invalid pages (for alignment)
+		 * check here not to call set_pageblock_migratetype() against
+		 * pfn out of zone.
+		 */
+		if (!(pfn & (pageblock_nr_pages - 1))) {
+			struct page *page = pfn_to_page(pfn);
+			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+			__init_single_page(page, pfn, zone, nid);
+		} else {
+			__init_single_pfn(pfn, zone, nid);
+		}
 	}
 }
 
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
