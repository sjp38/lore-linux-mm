Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA7A16B0279
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 19:54:33 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id c123-v6so11122638ywf.9
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 16:54:33 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a142-v6si6680026ywe.179.2018.10.17.16.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 16:54:32 -0700 (PDT)
Subject: [mm PATCH v4 5/6] mm: Add reserved flag setting to set_page_links
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Wed, 17 Oct 2018 16:54:31 -0700
Message-ID: <20181017235431.17213.11512.stgit@localhost.localdomain>
In-Reply-To: <20181017235043.17213.92459.stgit@localhost.localdomain>
References: <20181017235043.17213.92459.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

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
index 6e2c9631af05..14d06d7d2986 100644
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
index a0b81e0bef03..e7fee7a5f8a3 100644
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
@@ -1231,19 +1232,16 @@ static void __meminit __init_pageblock(unsigned long start_pfn,
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
 
 		/*
-		 * We can use the non-atomic __set_bit operation for setting
-		 * the flag as we are still initializing the pages.
-		 */
-		__SetPageReserved(page);
-
-		/*
 		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
 		 * pointer and hmm_data.  It is a bug if a ZONE_DEVICE
 		 * page is ever freed or placed on a driver-private list.
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
