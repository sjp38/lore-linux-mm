Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 52D086B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 22:43:34 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j8so128532482itb.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 19:43:34 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id q5si60669oig.39.2016.07.13.19.43.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 19:43:33 -0700 (PDT)
Message-ID: <5786F81B.1070502@huawei.com>
Date: Thu, 14 Jul 2016 10:25:31 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mem-hotplug: use GFP_HIGHUSER_MOVABLE and alloc from next
 node in alloc_migrate_target()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

alloc_migrate_target() is called from migrate_pages(), and the page
is always from user space, so we can add __GFP_HIGHMEM directly.

Second, when we offline a node, the new page should alloced from other
nodes instead of the current node, because re-migrate is a waste of
time.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_isolation.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 612122b..83848dc 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -282,20 +282,16 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 struct page *alloc_migrate_target(struct page *page, unsigned long private,
 				  int **resultp)
 {
-	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
-
 	/*
-	 * TODO: allocate a destination hugepage from a nearest neighbor node,
+	 * TODO: allocate a destination page from a nearest neighbor node,
 	 * accordance with memory policy of the user process if possible. For
 	 * now as a simple work-around, we use the next node for destination.
 	 */
+	int nid = next_node_in(page_to_nid(page), node_online_map);
+
 	if (PageHuge(page))
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
-					    next_node_in(page_to_nid(page),
-							 node_online_map));
-
-	if (PageHighMem(page))
-		gfp_mask |= __GFP_HIGHMEM;
-
-	return alloc_page(gfp_mask);
+						 nid);
+	else
+		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
 }
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
