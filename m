Received: from fujitsu2.fujitsu.com (localhost [127.0.0.1])
	by fujitsu2.fujitsu.com (8.12.10/8.12.9) with ESMTP id i9Q2ZANo006156
	for <linux-mm@kvack.org>; Mon, 25 Oct 2004 19:35:10 -0700 (PDT)
Date: Mon, 25 Oct 2004 19:34:50 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: [RFC/Patch]Making Removable zone[1/4]
In-Reply-To: <20041025160642.690F.YGOTO@us.fujitsu.com>
References: <20041025160642.690F.YGOTO@us.fujitsu.com>
Message-Id: <20041025193322.6911.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch makes new zones (Hot-removable DMA/ Hotremovable-Normal/
Hotremovable-Highmem).


 hotremovable-goto/include/linux/mmzone.h |   40 +++++++------------------------
 hotremovable-goto/mm/page_alloc.c        |    3 +-
 2 files changed, 12 insertions(+), 31 deletions(-)

diff -puN include/linux/mmzone.h~new_zone include/linux/mmzone.h
--- hotremovable/include/linux/mmzone.h~new_zone	Fri Aug 27 21:06:50 2004
+++ hotremovable-goto/include/linux/mmzone.h	Fri Aug 27 21:06:50 2004
@@ -73,37 +73,17 @@ struct per_cpu_pageset {
 #define ZONE_NORMAL		1
 #define ZONE_HIGHMEM		2
 
-#define MAX_NR_ZONES		3	/* Sync this with ZONES_SHIFT */
-#define ZONES_SHIFT		2	/* ceil(log2(MAX_NR_ZONES)) */
+#define ZONE_REMOVABLE		3
+#define ZONE_DMA_RMV		(ZONE_DMA + ZONE_REMOVABLE)	/* Hot-Removable DMA zone */
+#define ZONE_NORMAL_RMV		(ZONE_NORMAL + ZONE_REMOVABLE)	/* Hot-Removable DMA zone */
+#define ZONE_HIGHMEM_RMV	(ZONE_HIGHMEM + ZONE_REMOVABLE)	/* Hot-Removable DMA zone */
 
+#define MAX_NR_ZONES		6	/* Sync this with ZONES_SHIFT */
+#define ZONES_SHIFT		3	/* ceil(log2(MAX_NR_ZONES)) */
 
-/*
- * When a memory allocation must conform to specific limitations (such
- * as being suitable for DMA) the caller will pass in hints to the
- * allocator in the gfp_mask, in the zone modifier bits.  These bits
- * are used to select a priority ordered list of memory zones which
- * match the requested limits.  GFP_ZONEMASK defines which bits within
- * the gfp_mask should be considered as zone modifiers.  Each valid
- * combination of the zone modifier bits has a corresponding list
- * of zones (in node_zonelists).  Thus for two zone modifiers there
- * will be a maximum of 4 (2 ** 2) zonelists, for 3 modifiers there will
- * be 8 (2 ** 3) zonelists.  GFP_ZONETYPES defines the number of possible
- * combinations of zone modifiers in "zone modifier space".
- */
-#define GFP_ZONEMASK	0x03
-/*
- * As an optimisation any zone modifier bits which are only valid when
- * no other zone modifier bits are set (loners) should be placed in
- * the highest order bits of this field.  This allows us to reduce the
- * extent of the zonelists thus saving space.  For example in the case
- * of three zone modifier bits, we could require up to eight zonelists.
- * If the left most zone modifier is a "loner" then the highest valid
- * zonelist would be four allowing us to allocate only five zonelists.
- * Use the first form when the left most bit is not a "loner", otherwise
- * use the second.
- */
-/* #define GFP_ZONETYPES	(GFP_ZONEMASK + 1) */		/* Non-loner */
-#define GFP_ZONETYPES	((GFP_ZONEMASK + 1) / 2 + 1)		/* Loner */
+#define GFP_ZONEMASK	0x07
+
+#define GFP_ZONETYPES	(MAX_NR_ZONES + 1)
 
 /*
  * On machines where it is needed (eg PCs) we divide physical memory
@@ -414,7 +394,7 @@ extern struct pglist_data contig_page_da
  * with 32 bit page->flags field, we reserve 8 bits for node/zone info.
  * there are 3 zones (2 bits) and this leaves 8-2=6 bits for nodes.
  */
-#define MAX_NODES_SHIFT		6
+#define MAX_NODES_SHIFT		5
 #elif BITS_PER_LONG == 64
 /*
  * with 64 bit flags field, there's plenty of room.
diff -puN mm/page_alloc.c~new_zone mm/page_alloc.c
--- hotremovable/mm/page_alloc.c~new_zone	Fri Aug 27 21:06:50 2004
+++ hotremovable-goto/mm/page_alloc.c	Fri Aug 27 21:06:50 2004
@@ -57,7 +57,8 @@ EXPORT_SYMBOL(nr_swap_pages);
 struct zone *zone_table[1 << (ZONES_SHIFT + NODES_SHIFT)];
 EXPORT_SYMBOL(zone_table);
 
-static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
+static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem",
+					  "DMA-Removable", "Normal-Removable","Highmem-Removable"};
 int min_free_kbytes = 1024;
 
 unsigned long __initdata nr_kernel_pages;
_


-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
