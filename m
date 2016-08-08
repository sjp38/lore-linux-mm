Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6076B0262
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 02:43:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h186so650863925pfg.2
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 23:43:25 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id d10si35396154pag.94.2016.08.07.23.43.24
        for <linux-mm@kvack.org>;
        Sun, 07 Aug 2016 23:43:24 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v3 kernel 5/7] mm: add the related functions to get unused page
Date: Mon,  8 Aug 2016 14:35:32 +0800
Message-Id: <1470638134-24149-6-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
References: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, Liang Li <liang.z.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

Save the unused page info into page bitmap. The virtio balloon
driver call this new API to get the unused page bitmap and send
the bitmap to hypervisor(QEMU) for speeding up live migration.
During sending the bitmap, some the pages may be modified and are
no free anymore, this inaccuracy can be corrected by the dirty
page logging mechanism.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 include/linux/mm.h |  2 ++
 mm/page_alloc.c    | 84 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 86 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5873057..d181864 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1789,6 +1789,8 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
 extern unsigned long get_max_pfn(void);
+extern int get_unused_pages(unsigned long start_pfn, unsigned long end_pfn,
+	unsigned long *bitmap[], unsigned long len, unsigned int nr_bmap);
 
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3373704..1b5419d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4401,6 +4401,90 @@ unsigned long get_max_pfn(void)
 }
 EXPORT_SYMBOL(get_max_pfn);
 
+static void mark_unused_pages_bitmap(struct zone *zone,
+		unsigned long start_pfn, unsigned long end_pfn,
+		unsigned long *bitmap[], unsigned long bits,
+		unsigned int nr_bmap)
+{
+	unsigned long pfn, flags, nr_pg, pos, *bmap;
+	unsigned int order, i, t, bmap_idx;
+	struct list_head *curr;
+
+	if (zone_is_empty(zone))
+		return;
+
+	end_pfn = min(start_pfn + nr_bmap * bits, end_pfn);
+	spin_lock_irqsave(&zone->lock, flags);
+
+	for_each_migratetype_order(order, t) {
+		list_for_each(curr, &zone->free_area[order].free_list[t]) {
+			pfn = page_to_pfn(list_entry(curr, struct page, lru));
+			if (pfn < start_pfn || pfn >= end_pfn)
+				continue;
+			nr_pg = 1UL << order;
+			if (pfn + nr_pg > end_pfn)
+				nr_pg = end_pfn - pfn;
+			bmap_idx = (pfn - start_pfn) / bits;
+			if (bmap_idx == (pfn + nr_pg - start_pfn) / bits) {
+				bmap = bitmap[bmap_idx];
+				pos = (pfn - start_pfn) % bits;
+				bitmap_set(bmap, pos, nr_pg);
+			} else
+				for (i = 0; i < nr_pg; i++) {
+					bmap_idx = pos / bits;
+					bmap = bitmap[bmap_idx];
+					pos = pos % bits;
+					bitmap_set(bmap, pos, 1);
+				}
+		}
+	}
+
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
+
+/*
+ * During live migration, page is always discardable unless it's
+ * content is needed by the system.
+ * get_unused_pages provides an API to get the unused pages, these
+ * unused pages can be discarded if there is no modification since
+ * the request. Some other mechanism, like the dirty page logging
+ * can be used to track the modification.
+ *
+ * This function scans the free page list to get the unused pages
+ * whose pfn are range from start_pfn to end_pfn, and set the
+ * corresponding bit in the bitmap if an unused page is found.
+ *
+ * Allocating a large bitmap may fail because of fragmentation,
+ * instead of using a single bitmap, we use a scatter/gather bitmap.
+ * The 'bitmap' is the start address of an array which contains
+ * 'nr_bmap' separate small bitmaps, each bitmap contains 'bits' bits.
+ *
+ * return -1 if parameters are invalid
+ * return 0 when end_pfn >= max_pfn
+ * return 1 when end_pfn < max_pfn
+ */
+int get_unused_pages(unsigned long start_pfn, unsigned long end_pfn,
+	unsigned long *bitmap[], unsigned long bits, unsigned int nr_bmap)
+{
+	struct zone *zone;
+	int ret = 0;
+
+	if (bitmap == NULL || *bitmap == NULL || nr_bmap == 0 ||
+		 bits == 0 || start_pfn > end_pfn)
+		return -1;
+	if (end_pfn < max_pfn)
+		ret = 1;
+	if (end_pfn >= max_pfn)
+		ret = 0;
+
+	for_each_populated_zone(zone)
+		mark_unused_pages_bitmap(zone, start_pfn, end_pfn, bitmap,
+					 bits, nr_bmap);
+
+	return ret;
+}
+EXPORT_SYMBOL(get_unused_pages);
+
 static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
 {
 	zoneref->zone = zone;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
