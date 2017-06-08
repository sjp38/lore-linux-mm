Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E71D6B02F3
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 03:46:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g15so2702728wmc.8
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 00:46:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z39sor769828wrz.13.2017.06.08.00.46.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Jun 2017 00:46:09 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/4] mm: unify new_node_page and alloc_migrate_target
Date: Thu,  8 Jun 2017 09:45:52 +0200
Message-Id: <20170608074553.22152-4-mhocko@kernel.org>
In-Reply-To: <20170608074553.22152-1-mhocko@kernel.org>
References: <20170608074553.22152-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Joonsoo Kim <js1304@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

394e31d2ceb4 ("mem-hotplug: alloc new page from a nearest neighbor node
when mem-offline") has duplicated a large part of alloc_migrate_target
with some hotplug specific special casing. To be more precise it tried
to enfore the allocation from a different node than the original page.
As a result the two function diverged in their shared logic, e.g. the
hugetlb allocation strategy. Let's unify the two and express different
NUMA requirements by the given nodemask. new_node_page will simply
exclude the node it doesn't care about and alloc_migrate_target will
use all the available nodes. alloc_migrate_target will then learn to
migrate hugetlb pages more sanely and use preallocated pool when
possible.

Please note that alloc_migrate_target used to call alloc_page resp.
alloc_pages_current so the memory policy of the current context which
is quite strange when we consider that it is used in the context of
alloc_contig_range which just tries to migrate pages which stand in the
way.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/migrate.h | 17 +++++++++++++++++
 mm/memory_hotplug.c     | 11 +----------
 mm/page_isolation.c     | 18 ++----------------
 3 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 48e24844b3c5..f80c9882403a 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -4,6 +4,7 @@
 #include <linux/mm.h>
 #include <linux/mempolicy.h>
 #include <linux/migrate_mode.h>
+#include <linux/hugetlb.h>
 
 typedef struct page *new_page_t(struct page *page, unsigned long private,
 				int **reason);
@@ -30,6 +31,22 @@ enum migrate_reason {
 /* In mm/debug.c; also keep sync with include/trace/events/migrate.h */
 extern char *migrate_reason_names[MR_TYPES];
 
+static inline struct page *new_page_nodemask(struct page *page, int preferred_nid,
+		nodemask_t *nodemask)
+{
+	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
+
+	if (PageHuge(page))
+		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
+				nodemask);
+
+	if (PageHighMem(page)
+	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
+		gfp_mask |= __GFP_HIGHMEM;
+
+	return __alloc_pages_nodemask(gfp_mask, 0, preferred_nid, nodemask);
+}
+
 #ifdef CONFIG_MIGRATION
 
 extern void putback_movable_pages(struct list_head *l);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6e0d964ac561..d2f13f2f3ebf 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1429,7 +1429,6 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 static struct page *new_node_page(struct page *page, unsigned long private,
 		int **result)
 {
-	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
 	int nid = page_to_nid(page);
 	nodemask_t nmask = node_states[N_MEMORY];
 
@@ -1442,15 +1441,7 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 	if (nodes_empty(nmask))
 		node_set(nid, nmask);
 
-	if (PageHuge(page))
-		return alloc_huge_page_nodemask(
-				page_hstate(compound_head(page)), &nmask);
-
-	if (PageHighMem(page)
-	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
-		gfp_mask |= __GFP_HIGHMEM;
-
-	return __alloc_pages_nodemask(gfp_mask, 0, nid, &nmask);
+	return new_page_nodemask(page, nid, &nmask);
 }
 
 #define NR_OFFLINE_AT_ONCE_PAGES	(256)
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 3606104893e0..757410d9f758 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -8,6 +8,7 @@
 #include <linux/memory.h>
 #include <linux/hugetlb.h>
 #include <linux/page_owner.h>
+#include <linux/migrate.h>
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -294,20 +295,5 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 struct page *alloc_migrate_target(struct page *page, unsigned long private,
 				  int **resultp)
 {
-	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
-
-	/*
-	 * TODO: allocate a destination hugepage from a nearest neighbor node,
-	 * accordance with memory policy of the user process if possible. For
-	 * now as a simple work-around, we use the next node for destination.
-	 */
-	if (PageHuge(page))
-		return alloc_huge_page_node(page_hstate(compound_head(page)),
-					    next_node_in(page_to_nid(page),
-							 node_online_map));
-
-	if (PageHighMem(page))
-		gfp_mask |= __GFP_HIGHMEM;
-
-	return alloc_page(gfp_mask);
+	return new_page_nodemask(page, numa_node_id(), &node_states[N_MEMORY]);
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
