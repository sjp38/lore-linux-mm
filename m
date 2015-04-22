Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 37E336B0081
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 13:08:27 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so254020091wgy.2
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 10:08:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ml5si9970532wic.74.2015.04.22.10.08.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 10:08:10 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/13] mm: meminit: Reduce number of times pageblocks are set during struct page init
Date: Wed, 22 Apr 2015 18:07:52 +0100
Message-Id: <1429722473-28118-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1429722473-28118-1-git-send-email-mgorman@suse.de>
References: <1429722473-28118-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

During parallel sturct page initialisation, ranges are checked for every
PFN unnecessarily which increases boot times. This patch alters when the
ranges are checked.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 45 +++++++++++++++++++++++----------------------
 1 file changed, 23 insertions(+), 22 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8d3fd13a09c9..945d56667b61 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -876,33 +876,12 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
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
@@ -1091,6 +1070,7 @@ void __defermem_init deferred_free_range(struct page *page, unsigned long pfn,
 	int i;
 
 	if (nr_pages == MAX_ORDER_NR_PAGES && (pfn & (MAX_ORDER_NR_PAGES-1)) == 0) {
+		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 		__free_pages_boot_core(page, pfn, MAX_ORDER-1);
 		return;
 	}
@@ -4500,7 +4480,28 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 						&nr_initialised))
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
