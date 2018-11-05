Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2F06B0273
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:19:58 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id s24-v6so11318622plp.12
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:19:58 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 61-v6si14602011plb.125.2018.11.05.13.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 13:19:56 -0800 (PST)
Subject: [mm PATCH v5 6/7] mm: Add reserved flag setting to set_page_links
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 05 Nov 2018 13:19:56 -0800
Message-ID: <154145279604.30046.5646399488589213615.stgit@ahduyck-desk1.jf.intel.com>
In-Reply-To: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
References: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.comalexander.h.duyck@linux.intel.com

This patch modifies the set_page_links function to include the setting of
the reserved flag via a simple AND and OR operation. The motivation for
this is the fact that the existing __set_bit call still seems to have
effects on performance as replacing the call with the AND and OR can reduce
initialization time.

Looking over the assembly code before and after the change the main
difference between the two is that the reserved bit is stored in a value
that is generated outside of the main initialization loop and is then
written with the other flags field values in one write to the page->flags
value. Previously the generated value was written and then then a btsq
instruction was issued.

On my x86_64 test system with 3TB of persistent memory per node I saw the
persistent memory initialization time on average drop from 23.49s to
19.12s per node.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mm.h |    9 ++++++++-
 mm/page_alloc.c    |   29 +++++++++++++++++++----------
 2 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 288c407c08fc..de6535a98e45 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1171,11 +1171,18 @@ static inline void set_page_node(struct page *page, unsigned long node)
 	page->flags |= (node & NODES_MASK) << NODES_PGSHIFT;
 }
 
+static inline void set_page_reserved(struct page *page, bool reserved)
+{
+	page->flags &= ~(1ul << PG_reserved);
+	page->flags |= (unsigned long)(!!reserved) << PG_reserved;
+}
+
 static inline void set_page_links(struct page *page, enum zone_type zone,
-	unsigned long node, unsigned long pfn)
+	unsigned long node, unsigned long pfn, bool reserved)
 {
 	set_page_zone(page, zone);
 	set_page_node(page, node);
+	set_page_reserved(page, reserved);
 #ifdef SECTION_IN_PAGE_FLAGS
 	set_page_section(page, pfn_to_section_nr(pfn));
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dbe00c1a0e23..9eb993a9be99 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1179,7 +1179,7 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
 	mm_zero_struct_page(page);
-	set_page_links(page, zone, nid, pfn);
+	set_page_links(page, zone, nid, pfn, false);
 	init_page_count(page);
 	page_mapcount_reset(page);
 	page_cpupid_reset_last(page);
@@ -1195,7 +1195,8 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 static void __meminit __init_pageblock(unsigned long start_pfn,
 				       unsigned long nr_pages,
 				       unsigned long zone, int nid,
-				       struct dev_pagemap *pgmap)
+				       struct dev_pagemap *pgmap,
+				       bool is_reserved)
 {
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
 	struct page *start_page = pfn_to_page(start_pfn);
@@ -1231,18 +1232,15 @@ static void __meminit __init_pageblock(unsigned long start_pfn,
 		 * call because of the fact that the pfn number is used to
 		 * get the section_nr and this function should not be
 		 * spanning more than a single section.
+		 *
+		 * We can use a non-atomic operation for setting the
+		 * PG_reserved flag as we are still initializing the pages.
 		 */
-		set_page_links(page, zone, nid, start_pfn);
+		set_page_links(page, zone, nid, start_pfn, is_reserved);
 		init_page_count(page);
 		page_mapcount_reset(page);
 		page_cpupid_reset_last(page);
 
-		/*
-		 * We can use the non-atomic __set_bit operation for setting
-		 * the flag as we are still initializing the pages.
-		 */
-		__SetPageReserved(page);
-
 		/*
 		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
 		 * pointer and hmm_data.  It is a bug if a ZONE_DEVICE
@@ -5612,7 +5610,18 @@ static void __meminit __memmap_init_hotplug(unsigned long size, int nid,
 		pfn = max(ALIGN_DOWN(pfn - 1, pageblock_nr_pages), start_pfn);
 		stride -= pfn;
 
-		__init_pageblock(pfn, stride, zone, nid, pgmap);
+		/*
+		 * The last argument of __init_pageblock is a boolean
+		 * value indicating if the page will be marked as reserved.
+		 *
+		 * Mark page reserved as it will need to wait for onlining
+		 * phase for it to be fully associated with a zone.
+		 *
+		 * Under certain circumstances ZONE_DEVICE pages may not
+		 * need to be marked as reserved, however there is still
+		 * code that is depending on this being set for now.
+		 */
+		__init_pageblock(pfn, stride, zone, nid, pgmap, true);
 
 		cond_resched();
 	}
