Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4DF6B0022
	for <linux-mm@kvack.org>; Thu,  3 May 2018 19:30:00 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id c4-v6so14681242qtp.9
        for <linux-mm@kvack.org>; Thu, 03 May 2018 16:30:00 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id e12si6574530qkm.167.2018.05.03.16.29.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 16:29:58 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 3/4] mm: add find_alloc_contig_pages() interface
Date: Thu,  3 May 2018 16:29:34 -0700
Message-Id: <20180503232935.22539-4-mike.kravetz@oracle.com>
In-Reply-To: <20180503232935.22539-1-mike.kravetz@oracle.com>
References: <20180503232935.22539-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Reinette Chatre <reinette.chatre@intel.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

find_alloc_contig_pages() is a new interface that attempts to locate
and allocate a contiguous range of pages.  It is provided as a more
convenient interface than alloc_contig_range() which is currently
used by CMA and gigantic huge pages.

When attempting to allocate a range of pages, migration is employed
if possible.  There is no guarantee that the routine will succeed.
So, the user must be prepared for failure and have a fall back plan.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/gfp.h |  12 +++++
 mm/page_alloc.c     | 136 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 146 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 86a0d06463ab..b0d11777d487 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -573,6 +573,18 @@ static inline bool pm_suspended_storage(void)
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype, gfp_t gfp_mask);
 extern void free_contig_range(unsigned long pfn, unsigned long nr_pages);
+extern struct page *find_alloc_contig_pages(unsigned long nr_pages, gfp_t gfp,
+						int nid, nodemask_t *nodemask);
+extern void free_contig_pages(struct page *page, unsigned long nr_pages);
+#else
+static inline struct page *find_alloc_contig_pages(unsigned long nr_pages,
+				gfp_t gfp, int nid, nodemask_t *nodemask)
+{
+	return NULL;
+}
+static inline void free_contig_pages(struct page *page, unsigned long nr_pages)
+{
+}
 #endif
 
 #ifdef CONFIG_CMA
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cb1a5e0be6ee..d0a2d0da9eae 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -67,6 +67,7 @@
 #include <linux/ftrace.h>
 #include <linux/lockdep.h>
 #include <linux/nmi.h>
+#include <linux/mmzone.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -7913,8 +7914,12 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	/* Make sure the range is really isolated. */
 	if (test_pages_isolated(outer_start, end, false)) {
-		pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
-			__func__, outer_start, end);
+#ifdef MIGRATE_CMA
+		/* Only print messages for CMA allocations */
+		if (migratetype == MIGRATE_CMA)
+			pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
+				__func__, outer_start, end);
+#endif
 		ret = -EBUSY;
 		goto done;
 	}
@@ -7950,6 +7955,133 @@ void free_contig_range(unsigned long pfn, unsigned long nr_pages)
 	}
 	WARN(count != 0, "%ld pages are still in use!\n", count);
 }
+
+/*
+ * Only check for obvious pfn/pages which can not be used/migrated.  The
+ * migration code will do the final check.  Under stress, this minimal set
+ * has been observed to provide the best results.  The checks can be expanded
+ * if needed.
+ */
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
+		page = pfn_to_online_page(i);
+
+		if (page_zone(page) != z)
+			return false;
+
+	}
+
+	return true;
+}
+
+/*
+ * Search for and attempt to allocate contiguous allocations greater than
+ * MAX_ORDER.
+ */
+static struct page *__alloc_contig_pages_nodemask(gfp_t gfp,
+						unsigned long order,
+						int nid, nodemask_t *nodemask)
+{
+	unsigned long nr_pages, pfn, flags;
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
+		pgdat_resize_lock(zone->zone_pgdat, &flags);
+		pfn = ALIGN(zone->zone_start_pfn, nr_pages);
+		while (zone_spans_pfn(zone, pfn + nr_pages - 1)) {
+			if (contig_pfn_range_valid(zone, pfn, nr_pages)) {
+				struct page *page = pfn_to_online_page(pfn);
+				unsigned int migratetype;
+
+				/*
+				 * All pageblocks in range must be of same
+				 * migrate type.
+				 */
+				migratetype = get_pageblock_migratetype(page);
+				pgdat_resize_unlock(zone->zone_pgdat, &flags);
+
+				rc = alloc_contig_range(pfn, pfn + nr_pages,
+						migratetype, gfp);
+				if (!rc) {
+					ret_page = pfn_to_page(pfn);
+					return ret_page;
+				}
+				pgdat_resize_lock(zone->zone_pgdat, &flags);
+			}
+			pfn += nr_pages;
+		}
+		pgdat_resize_unlock(zone->zone_pgdat, &flags);
+	}
+
+	return ret_page;
+}
+
+/**
+ * find_alloc_contig_pages() -- attempt to find and allocate a contiguous
+ *				range of pages
+ * @nr_pages:	number of pages to find/allocate
+ * @gfp:	gfp mask used to limit search as well as during compaction
+ * @nid:	target node
+ * @nodemask:	mask of other possible nodes
+ *
+ * Pages can be freed with a call to free_contig_pages(), or by manually
+ * calling __free_page() for each page allocated.
+ *
+ * Return: pointer to 'order' pages on success, or NULL if not successful.
+ */
+struct page *find_alloc_contig_pages(unsigned long nr_pages, gfp_t gfp,
+					int nid, nodemask_t *nodemask)
+{
+	unsigned long i, alloc_order, order_pages;
+	struct page *pages;
+
+	/*
+	 * Underlying allocators perform page order sized allocations.
+	 */
+	alloc_order = get_count_order(nr_pages);
+	if (alloc_order < MAX_ORDER) {
+		pages = __alloc_pages_nodemask(gfp, (unsigned int)alloc_order,
+						nid, nodemask);
+		split_page(pages, alloc_order);
+	} else {
+		pages = __alloc_contig_pages_nodemask(gfp, alloc_order, nid,
+							nodemask);
+	}
+
+	if (pages) {
+		/*
+		 * More pages than desired could have been allocated due to
+		 * rounding up to next page order.  Free any excess pages.
+		 */
+		order_pages = 1UL << alloc_order;
+		for (i = nr_pages; i < order_pages; i++)
+			__free_page(pages + i);
+	}
+
+	return pages;
+}
+EXPORT_SYMBOL_GPL(find_alloc_contig_pages);
+
+void free_contig_pages(struct page *page, unsigned long nr_pages)
+{
+	free_contig_range(page_to_pfn(page), nr_pages);
+}
+EXPORT_SYMBOL_GPL(free_contig_pages);
 #endif
 
 #if defined CONFIG_MEMORY_HOTPLUG || defined CONFIG_CMA
-- 
2.13.6
