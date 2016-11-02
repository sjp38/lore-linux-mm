Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 465256B02AD
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 02:30:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i88so1850671pfk.3
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 23:30:52 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v2si1173708pge.21.2016.11.01.23.30.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 23:30:51 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH kernel v4 5/7] mm: add the related functions to get unused page
Date: Wed,  2 Nov 2016 14:17:25 +0800
Message-Id: <1478067447-24654-6-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1478067447-24654-1-git-send-email-liang.z.li@intel.com>
References: <1478067447-24654-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, dave.hansen@intel.com
Cc: pbonzini@redhat.com, amit.shah@redhat.com, quintela@redhat.com, dgilbert@redhat.com, qemu-devel@nongnu.org, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, mgorman@techsingularity.net, cornelia.huck@de.ibm.com, Liang Li <liang.z.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>

Save the unused page info into a split page bitmap. The virtio
balloon driver will use this new API to get the unused page bitmap
and send the bitmap to hypervisor(QEMU) to speed up live migration.
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
 mm/page_alloc.c    | 85 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 87 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f47862a..7014d8a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1773,6 +1773,8 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
 extern unsigned long get_max_pfn(void);
+extern int get_unused_pages(unsigned long start_pfn, unsigned long end_pfn,
+	unsigned long *bitmap[], unsigned long len, unsigned int nr_bmap);
 
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 12cc8ed..72537cc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4438,6 +4438,91 @@ unsigned long get_max_pfn(void)
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
+					pos = pfn - start_pfn + i;
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
