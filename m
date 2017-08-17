Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EBFC46B02FD
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 23:38:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m133so54428781pga.2
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 20:38:32 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o19si1353342pgk.231.2017.08.16.20.38.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 20:38:31 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v14 4/5] mm: support reporting free page blocks
Date: Thu, 17 Aug 2017 11:26:55 +0800
Message-Id: <1502940416-42944-5-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1502940416-42944-1-git-send-email-wei.w.wang@intel.com>
References: <1502940416-42944-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

This patch adds support to walk through the free page blocks in the
system and report them via a callback function. Some page blocks may
leave the free list after zone->lock is released, so it is the caller's
responsibility to either detect or prevent the use of such pages.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/mm.h |  6 ++++++
 mm/page_alloc.c    | 44 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 46b9ac5..cd29b9f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1835,6 +1835,12 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
 
+extern void walk_free_mem_block(void *opaque1,
+				unsigned int min_order,
+				void (*visit)(void *opaque2,
+					      unsigned long pfn,
+					      unsigned long nr_pages));
+
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
  * into the buddy system. The freed pages will be poisoned with pattern
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d00f74..a721a35 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4762,6 +4762,50 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 	show_swap_cache_info();
 }
 
+/**
+ * walk_free_mem_block - Walk through the free page blocks in the system
+ * @opaque1: the context passed from the caller
+ * @min_order: the minimum order of free lists to check
+ * @visit: the callback function given by the caller
+ *
+ * The function is used to walk through the free page blocks in the system,
+ * and each free page block is reported to the caller via the @visit callback.
+ * Please note:
+ * 1) The function is used to report hints of free pages, so the caller should
+ * not use those reported pages after the callback returns.
+ * 2) The callback is invoked with the zone->lock being held, so it should not
+ * block and should finish as soon as possible.
+ */
+void walk_free_mem_block(void *opaque1,
+			 unsigned int min_order,
+			 void (*visit)(void *opaque2,
+				       unsigned long pfn,
+				       unsigned long nr_pages))
+{
+	struct zone *zone;
+	struct page *page;
+	struct list_head *list;
+	unsigned int order;
+	enum migratetype mt;
+	unsigned long pfn, flags;
+
+	for_each_populated_zone(zone) {
+		for (order = MAX_ORDER - 1;
+		     order < MAX_ORDER && order >= min_order; order--) {
+			for (mt = 0; mt < MIGRATE_TYPES; mt++) {
+				spin_lock_irqsave(&zone->lock, flags);
+				list = &zone->free_area[order].free_list[mt];
+				list_for_each_entry(page, list, lru) {
+					pfn = page_to_pfn(page);
+					visit(opaque1, pfn, 1 << order);
+				}
+				spin_unlock_irqrestore(&zone->lock, flags);
+			}
+		}
+	}
+}
+EXPORT_SYMBOL_GPL(walk_free_mem_block);
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
