Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 24A996B0075
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 06:33:42 -0400 (EDT)
Received: by wiax7 with SMTP id x7so9400754wia.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 03:33:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dq7si13561651wib.104.2015.04.23.03.33.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 03:33:26 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/13] mm: meminit: Minimise number of pfn->page lookups during initialisation
Date: Thu, 23 Apr 2015 11:33:12 +0100
Message-Id: <1429785196-7668-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1429785196-7668-1-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Deferred struct page initialisation is using pfn_to_page() on every PFN
unnecessarily. This patch minimises the number of lookups and scheduler
checks.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 29 ++++++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f2db3d7aa6cb..11125634e375 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1081,6 +1081,7 @@ void __defermem_init deferred_init_memmap(int nid)
 
 		for_each_mem_pfn_range(i, nid, &walk_start, &walk_end, NULL) {
 			unsigned long pfn, end_pfn;
+			struct page *page = NULL;
 
 			end_pfn = min(walk_end, zone_end_pfn(zone));
 			pfn = first_init_pfn;
@@ -1090,13 +1091,32 @@ void __defermem_init deferred_init_memmap(int nid)
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
@@ -1105,7 +1125,6 @@ void __defermem_init deferred_init_memmap(int nid)
 
 				__init_single_page(page, pfn, zid, nid);
 				__free_pages_boot_core(page, pfn, 0);
-				cond_resched();
 			}
 			first_init_pfn = max(end_pfn, first_init_pfn);
 		}
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
