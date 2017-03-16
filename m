Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA126B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:13:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e129so71961364pfh.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 00:13:16 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k124si4374304pgk.356.2017.03.16.00.13.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 00:13:14 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH kernel v8 3/4] mm: add inerface to offer info about unused pages
Date: Thu, 16 Mar 2017 15:08:46 +0800
Message-Id: <1489648127-37282-4-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1489648127-37282-1-git-send-email-wei.w.wang@intel.com>
References: <1489648127-37282-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

From: Liang Li <liang.z.li@intel.com>

This patch adds a function to provides a snapshot of the present system
unused pages. An important usage of this function is to provide the
unsused pages to the Live migration thread, which skips the transfer of
thoses unused pages. Newly used pages can be re-tracked by the dirty
page logging mechanisms.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Signed-off-by: Wei Wang <wei.w.wang@intel.com>
---
 include/linux/mm.h |   3 ++
 mm/page_alloc.c    | 114 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 117 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b84615b..869749d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1764,6 +1764,9 @@ extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
+extern int record_unused_pages(struct zone **start_zone, int order,
+			       __le64 *pages, unsigned int size,
+			       unsigned int *pos, bool part_fill);
 
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f3e0c69..b72a7ac 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4498,6 +4498,120 @@ void show_free_areas(unsigned int filter)
 	show_swap_cache_info();
 }
 
+static int __record_unused_pages(struct zone *zone, int order,
+				 __le64 *buf, unsigned int size,
+				 unsigned int *offset, bool part_fill)
+{
+	unsigned long pfn, flags;
+	int t, ret = 0;
+	struct list_head *curr;
+	__le64 *chunk;
+
+	if (zone_is_empty(zone))
+		return 0;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	if (*offset + zone->free_area[order].nr_free > size && !part_fill) {
+		ret = -ENOSPC;
+		goto out;
+	}
+	for (t = 0; t < MIGRATE_TYPES; t++) {
+		list_for_each(curr, &zone->free_area[order].free_list[t]) {
+			pfn = page_to_pfn(list_entry(curr, struct page, lru));
+			chunk = buf + *offset;
+			if (*offset + 2 > size) {
+				ret = -ENOSPC;
+				goto out;
+			}
+			/* Align to the chunk format used in virtio-balloon */
+			*chunk = cpu_to_le64(pfn << 12);
+			*(chunk + 1) = cpu_to_le64((1 << order) << 12);
+			*offset += 2;
+		}
+	}
+
+out:
+	spin_unlock_irqrestore(&zone->lock, flags);
+
+	return ret;
+}
+
+/*
+ * The record_unused_pages() function is used to record the system unused
+ * pages. The unused pages can be skipped to transfer during live migration.
+ * Though the unused pages are dynamically changing, dirty page logging
+ * mechanisms are able to capture the newly used pages though they were
+ * recorded as unused pages via this function.
+ *
+ * This function scans the free page list of the specified order to record
+ * the unused pages, and chunks those continuous pages following the chunk
+ * format below:
+ * --------------------------------------
+ * |	Base (52-bit)	| Rsvd (12-bit) |
+ * --------------------------------------
+ * --------------------------------------
+ * |	Size (52-bit)	| Rsvd (12-bit) |
+ * --------------------------------------
+ *
+ * @start_zone: zone to start the record operation.
+ * @order: order of the free page list to record.
+ * @buf: buffer to record the unused page info in chunks.
+ * @size: size of the buffer in __le64 to record
+ * @offset: offset in the buffer to record.
+ * @part_fill: indicate if partial fill is used.
+ *
+ * return -EINVAL if parameter is invalid
+ * return -ENOSPC when the buffer is too small to record all the unsed pages
+ * return 0 when sccess
+ */
+int record_unused_pages(struct zone **start_zone, int order,
+			__le64 *buf, unsigned int size,
+			unsigned int *offset, bool part_fill)
+{
+	struct zone *zone;
+	int ret = 0;
+	bool skip_check = false;
+
+	/* Make sure all the parameters are valid */
+	if (buf == NULL || offset == NULL || order >= MAX_ORDER)
+		return -EINVAL;
+
+	if (*start_zone != NULL) {
+		bool found = false;
+
+		for_each_populated_zone(zone) {
+			if (zone != *start_zone)
+				continue;
+			found = true;
+			break;
+		}
+		if (!found)
+			return -EINVAL;
+	} else
+		skip_check = true;
+
+	for_each_populated_zone(zone) {
+		/* Start from *start_zone if it's not NULL */
+		if (!skip_check) {
+			if (*start_zone != zone)
+				continue;
+			else
+				skip_check = true;
+		}
+		ret = __record_unused_pages(zone, order, buf, size,
+					    offset, part_fill);
+		if (ret < 0) {
+			/* record the failed zone */
+			*start_zone = zone;
+			break;
+		}
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(record_unused_pages);
+
 static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
 {
 	zoneref->zone = zone;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
