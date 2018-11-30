Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FDE36B5A77
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 16:53:22 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p9so5519068pfj.3
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 13:53:22 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f38si5003973pgf.206.2018.11.30.13.53.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 13:53:20 -0800 (PST)
Subject: [mm PATCH v6 6/7] mm: Add reserved flag setting to set_page_links
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Fri, 30 Nov 2018 13:53:18 -0800
Message-ID: <154361479877.7497.2824031260670152276.stgit@ahduyck-desk1.amr.corp.intel.com>
In-Reply-To: <154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
References: <154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.comalexander.h.duyck@linux.intel.com

Modify the set_page_links function to include the setting of the reserved
flag via a simple AND and OR operation. The motivation for this is the fact
that the existing __set_bit call still seems to have effects on performance
as replacing the call with the AND and OR can reduce initialization time.

Looking over the assembly code before and after the change the main
difference between the two is that the reserved bit is stored in a value
that is generated outside of the main initialization loop and is then
written with the other flags field values in one write to the page->flags
value. Previously the generated value was written and then then a btsq
instruction was issued.

On my x86_64 test system with 3TB of persistent memory per node I saw the
persistent memory initialization time on average drop from 23.49s to
19.12s per node.

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mm.h |    9 ++++++++-
 mm/page_alloc.c    |   39 +++++++++++++++++++++++++--------------
 2 files changed, 33 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index eb6e52b66bc2..5faf66dd4559 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1238,11 +1238,18 @@ static inline void set_page_node(struct page *page, unsigned long node)
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
index 416bbb6f05ab..61eb9945d805 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1183,10 +1183,16 @@ static void free_one_page(struct zone *zone,
 
 static void __meminit __init_struct_page_nolru(struct page *page,
 					       unsigned long pfn,
-					       unsigned long zone, int nid)
+					       unsigned long zone, int nid,
+					       bool is_reserved)
 {
 	mm_zero_struct_page(page);
-	set_page_links(page, zone, nid, pfn);
+
+	/*
+	 * We can use a non-atomic operation for setting the
+	 * PG_reserved flag as we are still initializing the pages.
+	 */
+	set_page_links(page, zone, nid, pfn, is_reserved);
 	init_page_count(page);
 	page_mapcount_reset(page);
 	page_cpupid_reset_last(page);
@@ -1202,14 +1208,15 @@ static void __meminit __init_struct_page_nolru(struct page *page,
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
-	__init_struct_page_nolru(page, pfn, zone, nid);
+	__init_struct_page_nolru(page, pfn, zone, nid, false);
 	INIT_LIST_HEAD(&page->lru);
 }
 
 static void __meminit __init_pageblock(unsigned long start_pfn,
 				       unsigned long nr_pages,
 				       unsigned long zone, int nid,
-				       struct dev_pagemap *pgmap)
+				       struct dev_pagemap *pgmap,
+				       bool is_reserved)
 {
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
 	struct page *start_page = pfn_to_page(start_pfn);
@@ -1235,15 +1242,8 @@ static void __meminit __init_pageblock(unsigned long start_pfn,
 	 * is not defined.
 	 */
 	for (page = start_page + nr_pages; page-- != start_page; pfn--) {
-		__init_struct_page_nolru(page, pfn, zone, nid);
-		/*
-		 * Mark page reserved as it will need to wait for onlining
-		 * phase for it to be fully associated with a zone.
-		 *
-		 * We can use the non-atomic __set_bit operation for setting
-		 * the flag as we are still initializing the pages.
-		 */
-		__SetPageReserved(page);
+		__init_struct_page_nolru(page, pfn, zone, nid, is_reserved);
+
 		/*
 		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
 		 * pointer and hmm_data.  It is a bug if a ZONE_DEVICE
@@ -5780,7 +5780,18 @@ static void __meminit __memmap_init_hotplug(unsigned long size, int nid,
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
