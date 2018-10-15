Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 618586B026D
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 16:27:33 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r134-v6so10450139pgr.19
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 13:27:33 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 207-v6si11120856pgb.298.2018.10.15.13.27.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 13:27:32 -0700 (PDT)
Subject: [mm PATCH v3 6/6] mm: Add reserved flag setting to set_page_links
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 15 Oct 2018 13:27:30 -0700
Message-ID: <20181015202730.2171.53682.stgit@localhost.localdomain>
In-Reply-To: <20181015202456.2171.88406.stgit@localhost.localdomain>
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
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
initialization time by as much as 4 seconds, ~26s down to ~22s, per NUMA
node on a 4 socket system with 3TB of persistent memory per node.

Looking over the assembly code before and after the change the main
difference between the two is that the reserved bit is stored in a value
that is generated outside of the main initialization loop and is then
written with the other flags field values in one write to the page->flags
value. Previously the generated value was written and then then btsq
instruction was issued after testing the is_reserved value.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mm.h |    9 ++++++++-
 mm/page_alloc.c    |   14 +++++---------
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ec6e57a0c14e..31d374279b90 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1152,11 +1152,18 @@ static inline void set_page_node(struct page *page, unsigned long node)
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
index f145063615a7..5c2f545c7669 100644
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
@@ -1232,20 +1232,16 @@ static void __meminit __init_pageblock(unsigned long start_pfn,
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
-		if (is_reserved)
-			__SetPageReserved(page);
-
-		/*
 		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
 		 * pointer and hmm_data.  It is a bug if a ZONE_DEVICE
 		 * page is ever freed or placed on a driver-private list.
