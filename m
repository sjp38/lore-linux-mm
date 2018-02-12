Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB2976B0008
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 17:21:25 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id q4so2908458ioh.4
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 14:21:25 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id k76si2554087ita.85.2018.02.12.14.21.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 14:21:24 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 2/3] mm: add find_alloc_contig_pages() interface
Date: Mon, 12 Feb 2018 14:20:55 -0800
Message-Id: <20180212222056.9735-3-mike.kravetz@oracle.com>
In-Reply-To: <20180212222056.9735-1-mike.kravetz@oracle.com>
References: <20180212222056.9735-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

find_alloc_contig_pages() is a new interface that attempts to locate
and allocate a contiguous range of pages.  It is provided as a more
convenient interface to the existing alloc_contig_range() interface
which is used by CMA, memory hotplug and gigantic huge pages.

When attempting to allocate a range of pages, migration is employed
if possible.  There is no guarantee that the routine will succeed.
So, the user must be prepared for failure and have a fall back plan.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/gfp.h | 12 ++++++++
 mm/page_alloc.c     | 89 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 99 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 1a4582b44d32..456979022956 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -573,6 +573,18 @@ static inline bool pm_suspended_storage(void)
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype, gfp_t gfp_mask);
 extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
+extern struct page *find_alloc_contig_pages(unsigned int order, gfp_t gfp,
+						int nid, nodemask_t *nodemask);
+extern void free_contig_pages(struct page *page, unsigned nr_pages);
+#else
+static inline page *find_alloc_contig_pages(unsigned int order, gfp_t gfp,
+						int nid, nodemask_t *nodemask)
+{
+	return NULL;
+}
+static void free_contig_pages(struct page *page, unsigned nr_pages)
+{
+}
 #endif
 
 #ifdef CONFIG_CMA
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 064458f317bf..0a5a547acdbf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -67,6 +67,7 @@
 #include <linux/ftrace.h>
 #include <linux/lockdep.h>
 #include <linux/nmi.h>
+#include <linux/mmzone.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -1873,9 +1874,13 @@ static __always_inline struct page *__rmqueue_cma_fallback(struct zone *zone,
 {
 	return __rmqueue_smallest(zone, order, MIGRATE_CMA);
 }
+#define contig_alloc_migratetype_ok(migratetype) \
+	((migratetype) == MIGRATE_CMA || (migratetype) == MIGRATE_MOVABLE)
 #else
 static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
 					unsigned int order) { return NULL; }
+#define contig_alloc_migratetype_ok(migratetype) \
+	((migratetype) == MIGRATE_MOVABLE)
 #endif
 
 /*
@@ -7633,6 +7638,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	};
 	INIT_LIST_HEAD(&cc.migratepages);
 
+	if (!contig_alloc_migratetype_ok(migratetype))
+		return -EINVAL;
+
 	/*
 	 * What we do here is we mark all pageblocks in range as
 	 * MIGRATE_ISOLATE.  Because pageblock and max order pages may
@@ -7723,8 +7731,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	/* Make sure the range is really isolated. */
 	if (test_pages_isolated(outer_start, end, false)) {
-		pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
-			__func__, outer_start, end);
+		if (!(migratetype == MIGRATE_MOVABLE)) /* only print for CMA */
+			pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
+				__func__, outer_start, end);
 		ret = -EBUSY;
 		goto done;
 	}
@@ -7760,6 +7769,82 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 	}
 	WARN(count != 0, "%d pages are still in use!\n", count);
 }
+
+static bool contig_pfn_range_valid(struct zone *z, unsigned long start_pfn,
+					unsigned long nr_pages)
+{
+	unsigned long i, end_pfn = start_pfn + nr_pages;
+	struct page *page;
+
+	for (i = start_pfn; i < end_pfn; i++) {
+		if (!pfn_valid(i))
+			return false;
+
+		page = pfn_to_page(i);
+
+		if (page_zone(page) != z)
+			return false;
+
+	}
+
+	return true;
+}
+
+/**
+ * find_alloc_contig_pages() -- attempt to find and allocate a contiguous
+ *				range of pages
+ * @order:	number of pages
+ * @gfp:	gfp mask used to limit search as well as during compaction
+ * @nid:	target node
+ * @nodemask:	mask of other possible nodes
+ *
+ * Returns pointer to 'order' pages on success, or NULL if not successful.
+ *
+ * Pages can be freed with a call to free_contig_pages(), or by manually
+ * calling __free_page() for each page allocated.
+ */
+struct page *find_alloc_contig_pages(unsigned int order, gfp_t gfp,
+					int nid, nodemask_t *nodemask)
+{
+	unsigned long pfn, nr_pages, flags;
+	struct page *ret_page = NULL;
+	struct zonelist *zonelist;
+	struct zoneref *z;
+	struct zone *zone;
+	int rc;
+
+	nr_pages = 1 << order;
+	zonelist = node_zonelist(nid, gfp);
+	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp),
+					nodemask) {
+		spin_lock_irqsave(&zone->lock, flags);
+		pfn = ALIGN(zone->zone_start_pfn, nr_pages);
+		while (zone_spans_pfn(zone, pfn + nr_pages - 1)) {
+			if (contig_pfn_range_valid(zone, pfn, nr_pages)) {
+				spin_unlock_irqrestore(&zone->lock, flags);
+
+				rc = alloc_contig_range(pfn, pfn + nr_pages,
+							MIGRATE_MOVABLE, gfp);
+				if (!rc) {
+					ret_page = pfn_to_page(pfn);
+					return ret_page;
+				}
+				spin_lock_irqsave(&zone->lock, flags);
+			}
+			pfn += nr_pages;
+		}
+		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+
+	return ret_page;
+}
+EXPORT_SYMBOL_GPL(find_alloc_contig_pages);
+
+void free_contig_pages(struct page *page, unsigned nr_pages)
+{
+	free_contig_range(page_to_pfn(page), nr_pages);
+}
+EXPORT_SYMBOL_GPL(free_contig_pages);
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
