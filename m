Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 45DAD6B0078
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:17:33 -0400 (EDT)
Received: by wiun10 with SMTP id n10so60680573wiu.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:17:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si13228876wie.74.2015.04.13.03.17.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 03:17:20 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/14] mm: meminit: Minimise number of pfn->page lookups during initialisation
Date: Mon, 13 Apr 2015 11:17:01 +0100
Message-Id: <1428920226-18147-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1428920226-18147-1-git-send-email-mgorman@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Deferred memory initialisation is using pfn_to_page() on every PFN
unnecessarily. This patch minimises the number of lookups and scheduler
checks.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 29 ++++++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 10ba841c7609..21bb818aa3c4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1077,6 +1077,7 @@ void __defermem_init deferred_init_memmap(int nid)
 
 		for_each_mem_pfn_range(i, nid, &walk_start, &walk_end, NULL) {
 			unsigned long pfn, end_pfn;
+			struct page *page = NULL;
 
 			end_pfn = min(walk_end, zone_end_pfn(zone));
 			pfn = first_init_pfn;
@@ -1086,13 +1087,32 @@ void __defermem_init deferred_init_memmap(int nid)
 				pfn = zone->zone_start_pfn;
 
 			for (; pfn < end_pfn; pfn++) {
-				struct page *page;
-
-				if (!pfn_valid(pfn))
+				if (!pfn_valid_within(pfn))
 					continue;
 
-				if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state))
+				/*
+				 * Ensure pfn_valid is checked every
+				 * MAX_ORDER_NR_PAGES for memory holes
+				 */
+				if ((pfn & (MAX_ORDER_NR_PAGES - 1)) == 0) {
+					if (!pfn_valid(pfn)) {
+						page = NULL;
+						continue;
+					}
+				}
+
+				if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state)) {
+					page = NULL;
 					continue;
+				}
+
+				/* Minimise pfn page lookups and scheduler checks */
+				if (page && (pfn & (MAX_ORDER_NR_PAGES - 1)) != 0) {
+					page++;
+				} else {
+					page = pfn_to_page(pfn);
+					cond_resched();
+				}
 
 				if (page->flags) {
 					VM_BUG_ON(page_zone(page) != zone);
@@ -1101,7 +1121,6 @@ void __defermem_init deferred_init_memmap(int nid)
 
 				__init_single_page(page, pfn, zid, nid);
 				__free_pages_boot_core(page, pfn, 0);
-				cond_resched();
 			}
 			first_init_pfn = max(end_pfn, first_init_pfn);
 		}
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
