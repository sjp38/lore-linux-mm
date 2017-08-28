Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FEBF6B02F3
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 06:20:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a2so162503pfj.2
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 03:20:39 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e7si65393pgp.145.2017.08.28.03.20.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 03:20:37 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v15 4/5] mm: support reporting free page blocks
Date: Mon, 28 Aug 2017 18:08:32 +0800
Message-Id: <1503914913-28893-5-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1503914913-28893-1-git-send-email-wei.w.wang@intel.com>
References: <1503914913-28893-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

This patch adds support to walk through the free page blocks in the
system and report them via a callback function. Some page blocks may
leave the free list after zone->lock is released, so it is the caller's
responsibility to either detect or prevent the use of such pages.

One use example of this patch is to accelerate live migration by skipping
the transfer of free pages reported from the guest. A popular method used
by the hypervisor to track which part of memory is written during live
migration is to write-protect all the guest memory. So, those pages that
are reported as free pages but are written after the report function
returns will be captured by the hypervisor, and they will be added to the
next round of memory transfer.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/mm.h |  5 +++++
 mm/page_alloc.c    | 65 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 70 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 46b9ac5..3c4267d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1835,6 +1835,11 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
 
+extern void walk_free_mem_block(void *opaque,
+				int min_order,
+				bool (*report_page_block)(void *, unsigned long,
+							  unsigned long));
+
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
  * into the buddy system. The freed pages will be poisoned with pattern
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d00f74..81eedc7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4762,6 +4762,71 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 	show_swap_cache_info();
 }
 
+/**
+ * walk_free_mem_block - Walk through the free page blocks in the system
+ * @opaque: the context passed from the caller
+ * @min_order: the minimum order of free lists to check
+ * @report_page_block: the callback function to report free page blocks
+ *
+ * If the callback returns 1, stop iterating the list of free page blocks.
+ * Otherwise, continue to report.
+ *
+ * Please note that there are no locking guarantees for the callback and
+ * that the reported pfn range might be freed or disappear after the
+ * callback returns so the caller has to be very careful how it is used.
+ *
+ * The callback itself must not sleep or perform any operations which would
+ * require any memory allocations directly (not even GFP_NOWAIT/GFP_ATOMIC)
+ * or via any lock dependency. It is generally advisable to implement
+ * the callback as simple as possible and defer any heavy lifting to a
+ * different context.
+ *
+ * There is no guarantee that each free range will be reported only once
+ * during one walk_free_mem_block invocation.
+ *
+ * pfn_to_page on the given range is strongly discouraged and if there is
+ * an absolute need for that make sure to contact MM people to discuss
+ * potential problems.
+ *
+ * The function itself might sleep so it cannot be called from atomic
+ * contexts.
+ *
+ * In general low orders tend to be very volatile and so it makes more
+ * sense to query larger ones first for various optimizations which like
+ * ballooning etc... This will reduce the overhead as well.
+ */
+void walk_free_mem_block(void *opaque,
+			 int min_order,
+			 bool (*report_page_block)(void *, unsigned long,
+						   unsigned long))
+{
+	struct zone *zone;
+	struct page *page;
+	struct list_head *list;
+	int order;
+	enum migratetype mt;
+	unsigned long pfn, flags;
+	bool stop = 0;
+
+	for_each_populated_zone(zone) {
+		for (order = MAX_ORDER - 1; order >= min_order; order--) {
+			for (mt = 0; !stop && mt < MIGRATE_TYPES; mt++) {
+				spin_lock_irqsave(&zone->lock, flags);
+				list = &zone->free_area[order].free_list[mt];
+				list_for_each_entry(page, list, lru) {
+					pfn = page_to_pfn(page);
+					stop = report_page_block(opaque, pfn,
+								 1 << order);
+					if (stop)
+						break;
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
