Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 944AA828E5
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:53:14 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id 4so13092534pfd.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:53:14 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id rr8si26140484pab.223.2016.03.03.02.53.13
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 02:53:13 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [RFC kernel 1/2] mm: Add the functions used to get free pages information
Date: Thu,  3 Mar 2016 18:46:58 +0800
Message-Id: <1457002019-15998-2-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1457002019-15998-1-git-send-email-liang.z.li@intel.com>
References: <1457002019-15998-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, pbonzini@redhat.com, rth@twiddle.net, ehabkost@redhat.com, quintela@redhat.com, amit.shah@redhat.com, qemu-devel@nongnu.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, dgilbert@redhat.com, Liang Li <liang.z.li@intel.com>

get_total_pages_count() tries to get the page count of the system
RAM.
get_free_pages() is intend to construct a free pages bitmap by
traversing the free_list.

The free pages information will be sent to QEMU through virtio
and used for live migration optimization.

Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 mm/page_alloc.c | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 838ca8bb..81922e6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3860,6 +3860,63 @@ void show_free_areas(unsigned int filter)
 	show_swap_cache_info();
 }
 
+#define PFN_4G (0x100000000 >> PAGE_SHIFT)
+
+unsigned long get_total_pages_count(unsigned long low_mem)
+{
+	if (max_pfn >= PFN_4G) {
+		unsigned long pfn_gap = PFN_4G - (low_mem >> PAGE_SHIFT);
+
+		return max_pfn - pfn_gap;
+	} else
+		return max_pfn;
+}
+EXPORT_SYMBOL(get_total_pages_count);
+
+static void mark_free_pages_bitmap(struct zone *zone,
+		 unsigned long *free_page_bitmap, unsigned long pfn_gap)
+{
+	unsigned long pfn, flags, i;
+	unsigned int order, t;
+	struct list_head *curr;
+
+	if (zone_is_empty(zone))
+		return;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	for_each_migratetype_order(order, t) {
+		list_for_each(curr, &zone->free_area[order].free_list[t]) {
+
+			pfn = page_to_pfn(list_entry(curr, struct page, lru));
+			for (i = 0; i < (1UL << order); i++) {
+				if ((pfn + i) >= PFN_4G)
+					set_bit_le(pfn + i - pfn_gap,
+						   free_page_bitmap);
+				else
+					set_bit_le(pfn + i, free_page_bitmap);
+			}
+		}
+	}
+
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
+
+void get_free_pages(unsigned long *free_page_bitmap,
+		unsigned long *free_pages_count,
+		unsigned long low_mem)
+{
+	struct zone *zone;
+	unsigned long pfn_gap;
+
+	pfn_gap = PFN_4G - (low_mem >> PAGE_SHIFT);
+	for_each_populated_zone(zone)
+		mark_free_pages_bitmap(zone, free_page_bitmap, pfn_gap);
+
+	*free_pages_count = global_page_state(NR_FREE_PAGES);
+}
+EXPORT_SYMBOL(get_free_pages);
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
