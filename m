Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j2H0SRGo016920
	for <linux-mm@kvack.org>; Wed, 16 Mar 2005 19:28:27 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2H0SRs8090006
	for <linux-mm@kvack.org>; Wed, 16 Mar 2005 19:28:27 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j2H0SRST012728
	for <linux-mm@kvack.org>; Wed, 16 Mar 2005 19:28:27 -0500
Subject: [RFC][PATCH 6/6] sparsemem: MAX_ORDER optimizations
From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 16 Mar 2005 16:28:25 -0800
Message-Id: <E1DBisE-0000p1-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

With sparse, pfn_to_page() becomes a somewhat more expensive
operation.  This patch makes use of the guarentee that *_mem_map
will be contigious in sections aligned at MAX_ORDER to reduce
the number of pfn_to_page() calls.

By: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/arch/i386/mm/discontig.c |   10 ++++++++--
 memhotplug-dave/mm/bootmem.c             |   14 +++++++++++++-
 memhotplug-dave/mm/page_alloc.c          |    8 +++++++-
 3 files changed, 28 insertions(+), 4 deletions(-)

diff -puN arch/i386/mm/discontig.c~B-sparse-215-MAX_ORDER-optimisations arch/i386/mm/discontig.c
--- memhotplug/arch/i386/mm/discontig.c~B-sparse-215-MAX_ORDER-optimisations	2005-03-16 15:46:41.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/discontig.c	2005-03-16 15:46:41.000000000 -0800
@@ -408,10 +408,16 @@ void __init set_highmem_pages_init(int b
 				zone->name, zone->zone_pgdat->node_id,
 				zone_start_pfn, zone_end_pfn);
 
-		for (node_pfn = zone_start_pfn; node_pfn < zone_end_pfn; node_pfn++) {
+		/*
+		 * Make use of the guarentee that *_mem_map will be
+		 * contigious in sections aligned at MAX_ORDER.
+		 */
+		page = pfn_to_page(zone_start_pfn);
+		for (node_pfn = zone_start_pfn; node_pfn < zone_end_pfn; node_pfn++, page++) {
 			if (!pfn_valid(node_pfn))
 				continue;
-			page = pfn_to_page(node_pfn);
+			if ((node_pfn & ((1 << MAX_ORDER) - 1)) == 0)
+				page = pfn_to_page(node_pfn);
 			one_highpage_init(page, node_pfn, bad_ppro);
 		}
 	}
diff -puN mm/bootmem.c~B-sparse-215-MAX_ORDER-optimisations mm/bootmem.c
--- memhotplug/mm/bootmem.c~B-sparse-215-MAX_ORDER-optimisations	2005-03-16 15:46:41.000000000 -0800
+++ memhotplug-dave/mm/bootmem.c	2005-03-16 15:46:41.000000000 -0800
@@ -274,10 +274,21 @@ static unsigned long __init free_all_boo
 	if (bdata->node_boot_start == 0 ||
 	    ffs(bdata->node_boot_start) - PAGE_SHIFT > ffs(BITS_PER_LONG))
 		gofast = 1;
+
+	/*
+	 * APW/XXX: we are making an assumption that our node_boot_start
+	 * is aligned to BITS_PER_LONG ... is this valid/enforced.
+	 */
+	/*
+	 * Make use of the guarentee that *_mem_map will be
+	 * contigious in sections aligned at MAX_ORDER.
+	 */
+	page = pfn_to_page(pfn);
 	for (i = 0; i < idx; ) {
 		unsigned long v = ~map[i / BITS_PER_LONG];
 
-		page = pfn_to_page(pfn);
+		if ((pfn & ((1 << MAX_ORDER) - 1)) == 0)
+			page = pfn_to_page(pfn);
 
 		if (gofast && v == ~0UL) {
 			int j, order;
@@ -306,6 +317,7 @@ static unsigned long __init free_all_boo
 			}
 		} else {
 			i+=BITS_PER_LONG;
+			page += BITS_PER_LONG;
 		}
 		pfn += BITS_PER_LONG;
 	}
diff -puN mm/page_alloc.c~B-sparse-215-MAX_ORDER-optimisations mm/page_alloc.c
--- memhotplug/mm/page_alloc.c~B-sparse-215-MAX_ORDER-optimisations	2005-03-16 15:46:41.000000000 -0800
+++ memhotplug-dave/mm/page_alloc.c	2005-03-16 15:46:41.000000000 -0800
@@ -1583,10 +1583,16 @@ void __init memmap_init_zone(unsigned lo
 	int end_pfn = start_pfn + size;
 	int pfn;
 
+	/*
+	 * Make use of the guarentee that *_mem_map will be
+	 * contigious in sections aligned at MAX_ORDER.
+	 */
+	page = pfn_to_page(start_pfn);
 	for (pfn = start_pfn; pfn < end_pfn; pfn++, page++) {
 		if (!early_pfn_valid(pfn))
 			continue;
-		page = pfn_to_page(pfn);
+		if ((pfn & ((1 << MAX_ORDER) - 1)) == 0)
+			page = pfn_to_page(pfn);
 		set_page_links(page, zone, nid, pfn);
 		set_page_count(page, 0);
 		reset_page_mapcount(page);
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
