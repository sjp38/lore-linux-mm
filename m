Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 272C46B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 23:00:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so191226242pfa.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 20:00:09 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id cw8si6439468pad.134.2016.07.14.20.00.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 20:00:08 -0700 (PDT)
Message-ID: <57884FAA.9040500@huawei.com>
Date: Fri, 15 Jul 2016 10:51:22 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] mem-hotplug: use different mempolicy in alloc_migrate_target()
References: <57884EAA.9030603@huawei.com>
In-Reply-To: <57884EAA.9030603@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

When we offline a node, the new page should alloced from other
nodes instead of the current node, because re-migrate is a waste of
time.
So use prefer mempolicy for hotplug, use default mempolicy for cma.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/page-isolation.h | 2 +-
 mm/memory_hotplug.c            | 5 ++++-
 mm/page_alloc.c                | 2 +-
 mm/page_isolation.c            | 8 +++++---
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 047d647..c163de3 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -65,7 +65,7 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 			bool skip_hwpoisoned_pages);
 
-struct page *alloc_migrate_target(struct page *page, unsigned long private,
+struct page *alloc_migrate_target(struct page *page, unsigned long nid,
 				int **resultp);
 
 #endif
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e3cbdca..b5963bf 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1510,12 +1510,15 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
 	int not_managed = 0;
 	int ret = 0;
+	int nid = NUMA_NO_NODE;
 	LIST_HEAD(source);
 
 	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
 		if (!pfn_valid(pfn))
 			continue;
 		page = pfn_to_page(pfn);
+		if (nid == NUMA_NO_NODE)
+			nid = next_node_in(page_to_nid(page), node_online_map);
 
 		if (PageHuge(page)) {
 			struct page *head = compound_head(page);
@@ -1568,7 +1571,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		 * alloc_migrate_target should be improooooved!!
 		 * migrate_pages returns # of failed pages.
 		 */
-		ret = migrate_pages(&source, alloc_migrate_target, NULL, 0,
+		ret = migrate_pages(&source, alloc_migrate_target, NULL, nid,
 					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
 		if (ret)
 			putback_movable_pages(&source);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6903b69..b99f1c2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7322,7 +7322,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 		cc->nr_migratepages -= nr_reclaimed;
 
 		ret = migrate_pages(&cc->migratepages, alloc_migrate_target,
-				    NULL, 0, cc->mode, MR_CMA);
+				    NULL, NUMA_NO_NODE, cc->mode, MR_CMA);
 	}
 	if (ret < 0) {
 		putback_movable_pages(&cc->migratepages);
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 4f32c9f..f471be6 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -279,18 +279,20 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	return pfn < end_pfn ? -EBUSY : 0;
 }
 
-struct page *alloc_migrate_target(struct page *page, unsigned long private,
+struct page *alloc_migrate_target(struct page *page, unsigned long nid,
 				  int **resultp)
 {
 	/*
-	 * TODO: allocate a destination hugepage from a nearest neighbor node,
+	 * hugeTLB: allocate a destination page from a nearest neighbor node,
 	 * accordance with memory policy of the user process if possible. For
 	 * now as a simple work-around, we use the next node for destination.
+	 * Normal page: use prefer mempolicy for destination if called by
+	 * hotplug, use default mempolicy for destination if called by cma.
 	 */
 	if (PageHuge(page))
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					    next_node_in(page_to_nid(page),
 							 node_online_map));
 	else
-		return alloc_page(GFP_HIGHUSER_MOVABLE);
+		return alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
 }
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
