Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5AF6B0081
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:17:40 -0400 (EDT)
Received: by widdi4 with SMTP id di4so66008641wid.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:17:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3si16794457wjs.203.2015.04.13.03.17.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 03:17:23 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/14] mm: meminit: Free pages in large chunks where possible
Date: Mon, 13 Apr 2015 11:17:04 +0100
Message-Id: <1428920226-18147-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1428920226-18147-1-git-send-email-mgorman@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Parallel initialisation frees pages one at a time. Try free pages as single
large pages where possible.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 46 +++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 41 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cb38583063cb..bacd97b0030e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1076,6 +1076,20 @@ void __defer_init __free_pages_bootmem(struct page *page, unsigned long pfn,
 }
 
 #ifdef CONFIG_DEFERRED_MEM_INIT
+
+void __defermem_init deferred_free_range(struct page *page, unsigned long pfn,
+					int nr_pages)
+{
+	int i;
+
+	if (nr_pages == MAX_ORDER_NR_PAGES && (pfn & (MAX_ORDER_NR_PAGES-1)) == 0) {
+		__free_pages_boot_core(page, pfn, MAX_ORDER-1);
+		return;
+	}
+
+	for (i = 0; i < nr_pages; i++, page++, pfn++)
+		__free_pages_boot_core(page, pfn, 0);
+}
 /* Initialise remaining memory on a node */
 void __defermem_init deferred_init_memmap(int nid)
 {
@@ -1102,6 +1116,9 @@ void __defermem_init deferred_init_memmap(int nid)
 		for_each_mem_pfn_range(i, nid, &walk_start, &walk_end, NULL) {
 			unsigned long pfn, end_pfn;
 			struct page *page = NULL;
+			struct page *free_base_page = NULL;
+			unsigned long free_base_pfn = 0;
+			int nr_to_free = 0;
 
 			end_pfn = min(walk_end, zone_end_pfn(zone));
 			pfn = first_init_pfn;
@@ -1112,7 +1129,7 @@ void __defermem_init deferred_init_memmap(int nid)
 
 			for (; pfn < end_pfn; pfn++) {
 				if (!pfn_valid_within(pfn))
-					continue;
+					goto free_range;
 
 				/*
 				 * Ensure pfn_valid is checked every
@@ -1121,30 +1138,49 @@ void __defermem_init deferred_init_memmap(int nid)
 				if ((pfn & (MAX_ORDER_NR_PAGES - 1)) == 0) {
 					if (!pfn_valid(pfn)) {
 						page = NULL;
-						continue;
+						goto free_range;
 					}
 				}
 
 				if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state)) {
 					page = NULL;
-					continue;
+					goto free_range;
 				}
 
 				/* Minimise pfn page lookups and scheduler checks */
 				if (page && (pfn & (MAX_ORDER_NR_PAGES - 1)) != 0) {
 					page++;
 				} else {
+					deferred_free_range(free_base_page,
+							free_base_pfn, nr_to_free);
+					free_base_page = NULL;
+					free_base_pfn = nr_to_free = 0;
+
 					page = pfn_to_page(pfn);
 					cond_resched();
 				}
 
 				if (page->flags) {
 					VM_BUG_ON(page_zone(page) != zone);
-					continue;
+					goto free_range;
 				}
 
 				__init_single_page(page, pfn, zid, nid);
-				__free_pages_boot_core(page, pfn, 0);
+				if (!free_base_page) {
+					free_base_page = page;
+					free_base_pfn = pfn;
+					nr_to_free = 0;
+				}
+				nr_to_free++;
+
+				/* Where possible, batch up pages for a single free */
+				continue;
+free_range:
+				/* Free the current block of pages to allocator */
+				if (free_base_page)
+					deferred_free_range(free_base_page, free_base_pfn, nr_to_free);
+				free_base_page = NULL;
+				free_base_pfn = nr_to_free = 0;
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
