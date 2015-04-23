Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7FF6B007D
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 06:33:49 -0400 (EDT)
Received: by widdi4 with SMTP id di4so210332618wid.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 03:33:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9si13609710wif.30.2015.04.23.03.33.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 03:33:29 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/13] mm: meminit: Reduce number of times pageblocks are set during struct page init
Date: Thu, 23 Apr 2015 11:33:15 +0100
Message-Id: <1429785196-7668-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1429785196-7668-1-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

During parallel sturct page initialisation, ranges are checked for every
PFN unnecessarily which increases boot times. This patch alters when the
ranges are checked.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 45 +++++++++++++++++++++++----------------------
 1 file changed, 23 insertions(+), 22 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 73077dc63f0c..576b03bc9057 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -852,33 +852,12 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
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
@@ -1062,6 +1041,7 @@ void __defermem_init deferred_free_range(struct page *page, unsigned long pfn,
 	int i;
 
 	if (nr_pages == MAX_ORDER_NR_PAGES && (pfn & (MAX_ORDER_NR_PAGES-1)) == 0) {
+		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 		__free_pages_boot_core(page, pfn, MAX_ORDER-1);
 		return;
 	}
@@ -4471,7 +4451,28 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
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
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
