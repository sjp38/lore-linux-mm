Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9ACB26B007D
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 13:08:24 -0400 (EDT)
Received: by wiax7 with SMTP id x7so134923967wia.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 10:08:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gj3si9447114wjd.98.2015.04.22.10.08.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 10:08:09 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/13] mm: meminit: Free pages in large chunks where possible
Date: Wed, 22 Apr 2015 18:07:51 +0100
Message-Id: <1429722473-28118-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1429722473-28118-1-git-send-email-mgorman@suse.de>
References: <1429722473-28118-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Parallel struct page frees pages one at a time. Try free pages as single
large pages where possible.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 46 +++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 41 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6b2f6c21b70f..8d3fd13a09c9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1085,6 +1085,20 @@ void __defer_init __free_pages_bootmem(struct page *page, unsigned long pfn,
 }
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
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
+
 /* Initialise remaining memory on a node */
 void __defermem_init deferred_init_memmap(int nid)
 {
@@ -1111,6 +1125,9 @@ void __defermem_init deferred_init_memmap(int nid)
 		for_each_mem_pfn_range(i, nid, &walk_start, &walk_end, NULL) {
 			unsigned long pfn, end_pfn;
 			struct page *page = NULL;
+			struct page *free_base_page = NULL;
+			unsigned long free_base_pfn = 0;
+			int nr_to_free = 0;
 
 			end_pfn = min(walk_end, zone_end_pfn(zone));
 			pfn = first_init_pfn;
@@ -1121,7 +1138,7 @@ void __defermem_init deferred_init_memmap(int nid)
 
 			for (; pfn < end_pfn; pfn++) {
 				if (!pfn_valid_within(pfn))
-					continue;
+					goto free_range;
 
 				/*
 				 * Ensure pfn_valid is checked every
@@ -1130,30 +1147,49 @@ void __defermem_init deferred_init_memmap(int nid)
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
