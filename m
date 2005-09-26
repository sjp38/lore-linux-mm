Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8QK8d9P006362
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 16:08:39 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8QK9wrJ408046
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 14:09:58 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8QK9w5j029732
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 14:09:58 -0600
Message-ID: <43385594.3080303@austin.ibm.com>
Date: Mon, 26 Sep 2005 15:09:56 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 4/9] defrag helper functions
References: <4338537E.8070603@austin.ibm.com>
In-Reply-To: <4338537E.8070603@austin.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------020403000006080605070602"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Joel Schopp <jschopp@austin.ibm.com>, lhms <lhms-devel@lists.sourceforge.net>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Mike Kravetz <kravetz@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020403000006080605070602
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch contains a handful of trivial functions, and one fairly short function
that finds an unallocated 2^MAX_ORDER-1 sized block from one type and moves it
to another type.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Joel Schopp <jschopp@austin.ibm.com>



--------------020403000006080605070602
Content-Type: text/plain;
 name="4_defrag_helper_funcs"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4_defrag_helper_funcs"

Index: 2.6.13-joel2/mm/page_alloc.c
===================================================================
--- 2.6.13-joel2.orig/mm/page_alloc.c	2005-09-20 13:45:47.%N -0500
+++ 2.6.13-joel2/mm/page_alloc.c	2005-09-20 14:16:35.%N -0500
@@ -63,7 +63,62 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_Z
 
 EXPORT_SYMBOL(totalram_pages);
 EXPORT_SYMBOL(nr_swap_pages);
+static inline int need_min_fallback_reserve(struct zone *zone)
+{
+	return (zone->free_pages >> MAX_ORDER) < zone->fallback_reserve;
+}
+static inline int is_min_fallback_reserved(struct zone *zone)
+{
+	return zone->fallback_balance < 0;
+}
+static inline unsigned int get_pageblock_type(struct zone *zone,
+					      struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	int i, bitidx;
+	unsigned int type = 0;
+	unsigned long *usemap;
+
+	bitidx = pfn_to_bitidx(zone, pfn);
+	usemap = pfn_to_usemap(zone, pfn);
+
+	for (i=0; i < BITS_PER_RCLM_TYPE; i++) {
+		type = (type << 1);
+		type |= (!!test_bit(bitidx+i, usemap));
+	}
+
+	return type;
+}
 
+void assign_bit(int bit_nr, unsigned long* map, int value)
+{
+	switch (value) {
+	case 0:
+		clear_bit(bit_nr, map);
+		break;
+	default:
+		set_bit(bit_nr, map);
+	}
+}
+/*
+ * Reserve a block of pages for an allocation type & enforce function
+ * being changed if more bits are added to keep track of additional types
+ */
+BUILD_BUG_ON(BITS_PER_RCLM_TYPE > 2)
+static inline void set_pageblock_type(struct zone *zone, struct page *page,
+				      int type)
+{
+	unsigned long pfn = page_to_pfn(page);
+	int bitidx;
+	unsigned long *usemap;
+
+	usemap = pfn_to_usemap(zone, pfn);
+	bitidx = pfn_to_bitidx(zone, pfn);
+
+	assign_bit(bitidx, usemap, (type & 0x1));
+	assign_bit(bitidx + 1, usemap, (type & 0x2));
+
+}
 /*
  * Used by page_zone() to look up the address of the struct zone whose
  * id is encoded in the upper bits of page->flags
@@ -465,6 +520,41 @@ static void prep_new_page(struct page *p
 	kernel_map_pages(page, 1 << order, 1);
 }
 
+/*
+ * Find a list that has a 2^MAX_ORDER-1 block of pages available and
+ * return it
+ */
+static inline struct page* steal_largepage(struct zone *zone, int alloctype)
+{
+	struct page *page;
+	struct free_area *area;
+	int i=0;
+
+	for(i = 0; i < RCLM_TYPES; i++) {
+		if(i == alloctype)
+			continue;
+
+		area = &zone->free_area_lists[i][MAX_ORDER-1];
+		if(!list_empty(&area->free_list))
+			break;
+	}
+	if (i == RCLM_TYPES) return NULL;
+
+	page = list_entry(area->free_list.next, struct page, lru);
+	area->nr_free--;
+
+	if (!is_min_fallback_reserved(zone) &&
+	    need_min_fallback_reserve(zone)) {
+		alloctype = RCLM_FALLBACK;
+	}
+
+	set_pageblock_type(zone, page, alloctype);
+	dec_reserve_count(zone, i);
+	inc_reserve_count(zone, alloctype);
+
+	return page;
+}
+
 /* 
  * Do the hard work of removing an element from the buddy allocator.
  * Call me with the zone->lock already held.

--------------020403000006080605070602--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
