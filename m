Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 944CC6B03A2
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:40:12 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id n5so30581647pgd.19
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:40:12 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q7si23444825pfq.336.2017.04.13.02.40.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 02:40:11 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v9 3/5] mm: function to offer a page block on the free list
Date: Thu, 13 Apr 2017 17:35:06 +0800
Message-Id: <1492076108-117229-4-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

Add a function to find a page block on the free list specified by the
caller. Pages from the page block may be used immediately after the
function returns. The caller is responsible for detecting or preventing
the use of such pages.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 include/linux/mm.h |  3 ++
 mm/page_alloc.c    | 87 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 90 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b84615b..096705e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1764,6 +1764,9 @@ extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
+extern int inquire_unused_page_block(struct zone *zone, unsigned int order,
+				     unsigned int migratetype,
+				     struct page **page);
 
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f3e0c69..fa8203f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4498,6 +4498,93 @@ void show_free_areas(unsigned int filter)
 	show_swap_cache_info();
 }
 
+/**
+ * Heuristically get a page block in the system that is unused.
+ * It is possible that pages from the page block are used immediately after
+ * inquire_unused_page_block() returns. It is the caller's responsibility
+ * to either detect or prevent the use of such pages.
+ *
+ * The free list to check: zone->free_area[order].free_list[migratetype].
+ *
+ * If the caller supplied page block (i.e. **page) is on the free list, offer
+ * the next page block on the list to the caller. Otherwise, offer the first
+ * page block on the list.
+ *
+ * Return 0 when a page block is found on the caller specified free list.
+ */
+int inquire_unused_page_block(struct zone *zone, unsigned int order,
+			      unsigned int migratetype, struct page **page)
+{
+	struct zone *this_zone;
+	struct list_head *this_list;
+	int ret = 0;
+	unsigned long flags;
+
+	/* Sanity check */
+	if (zone == NULL || page == NULL || order >= MAX_ORDER ||
+	    migratetype >= MIGRATE_TYPES)
+		return -EINVAL;
+
+	/* Zone validity check */
+	for_each_populated_zone(this_zone) {
+		if (zone == this_zone)
+			break;
+	}
+
+	/* Got a non-existent zone from the caller? */
+	if (zone != this_zone)
+		return -EINVAL;
+
+	spin_lock_irqsave(&this_zone->lock, flags);
+
+	this_list = &zone->free_area[order].free_list[migratetype];
+	if (list_empty(this_list)) {
+		*page = NULL;
+		ret = 1;
+		goto out;
+	}
+
+	/* The caller is asking for the first free page block on the list */
+	if ((*page) == NULL) {
+		*page = list_first_entry(this_list, struct page, lru);
+		ret = 0;
+		goto out;
+	}
+
+	/**
+	 * The page block passed from the caller is not on this free list
+	 * anymore (e.g. a 1MB free page block has been split). In this case,
+	 * offer the first page block on the free list that the caller is
+	 * asking for.
+	 */
+	if (PageBuddy(*page) && order != page_order(*page)) {
+		*page = list_first_entry(this_list, struct page, lru);
+		ret = 0;
+		goto out;
+	}
+
+	/**
+	 * The page block passed from the caller has been the last page block
+	 * on the list.
+	 */
+	if ((*page)->lru.next == this_list) {
+		*page = NULL;
+		ret = 1;
+		goto out;
+	}
+
+	/**
+	 * Finally, fall into the regular case: the page block passed from the
+	 * caller is still on the free list. Offer the next one.
+	 */
+	*page = list_next_entry((*page), lru);
+	ret = 0;
+out:
+	spin_unlock_irqrestore(&this_zone->lock, flags);
+	return ret;
+}
+EXPORT_SYMBOL(inquire_unused_page_block);
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
