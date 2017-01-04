Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AEBA66B0261
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 06:10:51 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id dh1so52277288wjb.0
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 03:10:51 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id wj9si81054129wjb.8.2017.01.04.03.10.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 03:10:50 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 2076A99258
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 11:10:50 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 4/4] mm, page_alloc: Add a bulk page allocator
Date: Wed,  4 Jan 2017 11:10:49 +0000
Message-Id: <20170104111049.15501-5-mgorman@techsingularity.net>
In-Reply-To: <20170104111049.15501-1-mgorman@techsingularity.net>
References: <20170104111049.15501-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

This patch adds a new page allocator interface via alloc_pages_bulk,
__alloc_pages_bulk and __alloc_pages_bulk_nodemask. A caller requests
a number of pages to be allocated and added to a list. They can be
freed in bulk using free_hot_cold_page_list.

The API is not guaranteed to return the requested number of pages and
may fail if the preferred allocation zone has limited free memory,
the cpuset changes during the allocation or page debugging decides
to fail an allocation. It's up to the caller to request more pages
in batch if necessary.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/gfp.h | 23 ++++++++++++++
 mm/page_alloc.c     | 92 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 115 insertions(+)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4175dca4ac39..1da3a9a48701 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -433,6 +433,29 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
 	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
 }
 
+unsigned long
+__alloc_pages_bulk_nodemask(gfp_t gfp_mask, unsigned int order,
+			struct zonelist *zonelist, nodemask_t *nodemask,
+			unsigned long nr_pages, struct list_head *alloc_list);
+
+static inline unsigned long
+__alloc_pages_bulk(gfp_t gfp_mask, unsigned int order,
+		struct zonelist *zonelist, unsigned long nr_pages,
+		struct list_head *list)
+{
+	return __alloc_pages_bulk_nodemask(gfp_mask, order, zonelist, NULL,
+						nr_pages, list);
+}
+
+static inline unsigned long
+alloc_pages_bulk(gfp_t gfp_mask, unsigned int order,
+		unsigned long nr_pages, struct list_head *list)
+{
+	int nid = numa_mem_id();
+	return __alloc_pages_bulk(gfp_mask, order,
+			node_zonelist(nid, gfp_mask), nr_pages, list);
+}
+
 /*
  * Allocate pages, preferring the node given as nid. The node must be valid and
  * online. For more general interface, see alloc_pages_node().
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 01b09f9da288..307ad4299dec 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3887,6 +3887,98 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 EXPORT_SYMBOL(__alloc_pages_nodemask);
 
 /*
+ * This is a batched version of the page allocator that attempts to
+ * allocate nr_pages quickly from the preferred zone and add them to list.
+ * Note that there is no guarantee that nr_pages will be allocated although
+ * every effort will be made to allocate at least one. Unlike the core
+ * allocator, no special effort is made to recover from transient
+ * failures caused by changes in cpusets.
+ */
+unsigned long
+__alloc_pages_bulk_nodemask(gfp_t gfp_mask, unsigned int order,
+			struct zonelist *zonelist, nodemask_t *nodemask,
+			unsigned long nr_pages, struct list_head *alloc_list)
+{
+	struct page *page;
+	unsigned long alloced = 0;
+	unsigned int alloc_flags = ALLOC_WMARK_LOW;
+	struct zone *zone;
+	struct per_cpu_pages *pcp;
+	struct list_head *pcp_list;
+	unsigned long flags;
+	int migratetype;
+	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
+	struct alloc_context ac = { };
+	bool cold = ((gfp_mask & __GFP_COLD) != 0);
+
+	/* If there are already pages on the list, don't bother */
+	if (!list_empty(alloc_list))
+		return 0;
+
+	/* Only handle bulk allocation of order-0 */
+	if (order)
+		goto failed;
+
+	gfp_mask &= gfp_allowed_mask;
+	if (!prepare_alloc_pages(gfp_mask, order, zonelist, nodemask, &ac, &alloc_mask, &alloc_flags))
+		return 0;
+
+	finalise_ac(gfp_mask, order, &ac);
+	if (!ac.preferred_zoneref)
+		return 0;
+
+	/*
+	 * Only attempt a batch allocation if watermarks on the preferred zone
+	 * are safe.
+	 */
+	zone = ac.preferred_zoneref->zone;
+	if (!zone_watermark_fast(zone, order, zone->watermark[ALLOC_WMARK_HIGH] + nr_pages,
+				 zonelist_zone_idx(ac.preferred_zoneref), alloc_flags))
+		goto failed;
+
+	/* Attempt the batch allocation */
+	migratetype = ac.migratetype;
+
+	local_irq_save(flags);
+	pcp = &this_cpu_ptr(zone->pageset)->pcp;
+	pcp_list = &pcp->lists[migratetype];
+
+	while (nr_pages) {
+		page = __rmqueue_pcplist(zone, order, gfp_mask, migratetype,
+								cold, pcp, pcp_list);
+		if (!page)
+			break;
+
+		nr_pages--;
+		alloced++;
+		list_add(&page->lru, alloc_list);
+	}
+
+	if (!alloced) {
+		local_irq_restore(flags);
+		preempt_enable();
+		goto failed;
+	}
+
+	__count_zid_vm_events(PGALLOC, zone_idx(zone), alloced);
+	zone_statistics(zone, zone, gfp_mask);
+
+	local_irq_restore(flags);
+
+	return alloced;
+
+failed:
+	page = __alloc_pages_nodemask(gfp_mask, order, zonelist, nodemask);
+	if (page) {
+		alloced++;
+		list_add(&page->lru, alloc_list);
+	}
+
+	return alloced;
+}
+EXPORT_SYMBOL(__alloc_pages_bulk_nodemask);
+
+/*
  * Common helper functions.
  */
 unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
