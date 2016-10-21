Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4DC2280250
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 02:37:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 128so45475541pfz.1
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 23:37:17 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p16si1246297pfj.117.2016.10.20.23.37.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 23:37:17 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [RESEND PATCH v3 kernel 5/7] mm: add the related functions to get unused page
Date: Fri, 21 Oct 2016 14:24:38 +0800
Message-Id: <1477031080-12616-6-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com, Liang Li <liang.z.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

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
---
 include/linux/mm.h |  2 ++
 mm/page_alloc.c    | 84 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 86 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2a89da0e..84f56ec 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1777,6 +1777,8 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
 extern unsigned long get_max_pfn(void);
+extern int get_unused_pages(unsigned long start_pfn, unsigned long end_pfn,
+	unsigned long *bitmap[], unsigned long len, unsigned int nr_bmap);
 
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e5f63a9..848bb85 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4436,6 +4436,90 @@ unsigned long get_max_pfn(void)
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
