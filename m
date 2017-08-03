Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE1ED6B0662
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 02:48:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r29so5068543pfi.7
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 23:48:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z66si1004619pff.284.2017.08.02.23.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 23:48:46 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v13 4/5] mm: support reporting free page blocks
Date: Thu,  3 Aug 2017 14:38:18 +0800
Message-Id: <1501742299-4369-5-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, mawilcox@microsoft.com, akpm@linux-foundation.org
Cc: virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

This patch adds support to walk through the free page blocks in the
system and report them via a callback function. Some page blocks may
leave the free list after the report function returns, so it is the
caller's responsibility to either detect or prevent the use of such
pages.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/mm.h     |   7 ++++
 include/linux/mmzone.h |   5 +++
 mm/page_alloc.c        | 109 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 121 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 46b9ac5..24481e3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1835,6 +1835,13 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
 
+#if IS_ENABLED(CONFIG_VIRTIO_BALLOON)
+extern void walk_free_mem_block(void *opaque1,
+				unsigned int min_order,
+				void (*visit)(void *opaque2,
+					      unsigned long pfn,
+					      unsigned long nr_pages));
+#endif
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
  * into the buddy system. The freed pages will be poisoned with pattern
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fc14b8b..59eacf2 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -83,6 +83,11 @@ static inline bool is_migrate_movable(int mt)
 	for (order = 0; order < MAX_ORDER; order++) \
 		for (type = 0; type < MIGRATE_TYPES; type++)
 
+#define for_each_migratetype_order_decend(min_order, order, type) \
+	for (order = MAX_ORDER - 1; order < MAX_ORDER && order >= min_order; \
+	     order--) \
+		for (type = 0; type < MIGRATE_TYPES; type++)
+
 extern int page_group_by_mobility_disabled;
 
 #define NR_MIGRATETYPE_BITS (PB_migrate_end - PB_migrate + 1)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d30e91..b90b513 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4761,6 +4761,115 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 	show_swap_cache_info();
 }
 
+#if IS_ENABLED(CONFIG_VIRTIO_BALLOON)
+
+/*
+ * Heuristically get a free page block in the system.
+ *
+ * It is possible that pages from the page block are used immediately after
+ * report_free_page_block() returns. It is the caller's responsibility to
+ * either detect or prevent the use of such pages.
+ *
+ * The input parameters specify the free list to check for a free page block:
+ * zone->free_area[order].free_list[migratetype]
+ *
+ * If the caller supplied page block (i.e. **page) is on the free list, offer
+ * the next page block on the list to the caller. Otherwise, offer the first
+ * page block on the list.
+ *
+ * Return 0 when a page block is found on the caller specified free list.
+ * Otherwise, no page block is found.
+ */
+static int report_free_page_block(struct zone *zone, unsigned int order,
+				  unsigned int migratetype, struct page **page)
+{
+	struct list_head *free_list;
+	int ret = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	free_list = &zone->free_area[order].free_list[migratetype];
+	if (list_empty(free_list)) {
+		*page = NULL;
+		ret = -EAGAIN;
+		goto out;
+	}
+
+	/* The caller is asking for the first free page block on the list */
+	if (!(*page)) {
+		*page = list_first_entry(free_list, struct page, lru);
+		ret = 0;
+		goto out;
+	}
+
+	/*
+	 * The page block passed from the caller is not on this free list
+	 * anymore (e.g. a 1MB free page block has been split). In this case,
+	 * offer the first page block on the free list that the caller is
+	 * asking for.
+	 */
+	if (PageBuddy(*page) && order != page_order(*page)) {
+		*page = list_first_entry(free_list, struct page, lru);
+		ret = 0;
+		goto out;
+	}
+
+	/*
+	 * The page block passed from the caller has been the last page block
+	 * on the list.
+	 */
+	if ((*page)->lru.next == free_list) {
+		*page = NULL;
+		ret = -EAGAIN;
+		goto out;
+	}
+
+	/*
+	 * Finally, fall into the regular case: the page block passed from the
+	 * caller is still on the free list. Offer the next one.
+	 */
+	*page = list_next_entry((*page), lru);
+out:
+	spin_unlock_irqrestore(&zone->lock, flags);
+	return ret;
+}
+
+/*
+ * Walk through the free page blocks in the system. The @visit callback is
+ * invoked to handle each free page block.
+ *
+ * Note: some page blocks may be used after the report function returns, so it
+ * is not safe for the callback to use any pages or discard data on such page
+ * blocks.
+ */
+void walk_free_mem_block(void *opaque1,
+			 unsigned int min_order,
+			 void (*visit)(void *opaque2,
+				       unsigned long pfn,
+				       unsigned long nr_pages))
+{
+	struct zone *zone = NULL;
+	struct page *page = NULL;
+	unsigned int order;
+	unsigned long pfn, nr_pages;
+	int type;
+
+	for_each_populated_zone(zone) {
+		for_each_migratetype_order_decend(min_order, order, type) {
+			while (!report_free_page_block(zone, order, type,
+						       &page)) {
+				pfn = page_to_pfn(page);
+				nr_pages = 1 << order;
+				visit(opaque1, pfn, nr_pages);
+			}
+		}
+	}
+}
+EXPORT_SYMBOL_GPL(walk_free_mem_block);
+
+#endif
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
