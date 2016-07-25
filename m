Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB3FA6B0253
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 14:36:25 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q83so462887442iod.2
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 11:36:25 -0700 (PDT)
Received: from dfwrgout.huawei.com (dfwrgout.huawei.com. [206.16.17.72])
        by mx.google.com with ESMTPS id e66si11984758otb.286.2016.07.25.11.36.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 11:36:25 -0700 (PDT)
Message-ID: <5795E18B.5060302@huawei.com>
Date: Mon, 25 Jul 2016 17:53:15 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v3] mem-hotplug: alloc new page from a nearest neighbor node
 when mem-offline
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

If we offline a node, alloc the new page from a nearest neighbor
node instead of the current node or other remote nodes, because
re-migrate is a waste of time and the distance of the remote nodes
is often very large.

Also use GFP_HIGHUSER_MOVABLE to alloc new page if the zone is
movable zone or highmem zone.

Changelog:
V3:
	-alloc new page from a nearest neighbor node for both
	movable zone and non-movable zone
V2:
	-alloc new page from the next node for only movable zone

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory_hotplug.c | 38 +++++++++++++++++++++++++++++++++-----
 1 file changed, 33 insertions(+), 5 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e3cbdca..04dcf0e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1501,6 +1501,37 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 	return 0;
 }
 
+static struct page *new_node_page(struct page *page, unsigned long private,
+		int **result)
+{
+	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
+	int nid = page_to_nid(page);
+	nodemask_t nmask = node_online_map;
+	struct page *new_page;
+
+	/*
+	 * TODO: allocate a destination hugepage from a nearest neighbor node,
+	 * accordance with memory policy of the user process if possible. For
+	 * now as a simple work-around, we use the next node for destination.
+	 */
+	if (PageHuge(page))
+		return alloc_huge_page_node(page_hstate(compound_head(page)),
+					next_node_in(nid, nmask));
+
+	node_clear(nid, nmask);
+	if (PageHighMem(page)
+	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
+		gfp_mask |= __GFP_HIGHMEM;
+
+	new_page = __alloc_pages_nodemask(gfp_mask, 0,
+					node_zonelist(nid, gfp_mask), &nmask);
+	if (!new_page)
+		new_page = __alloc_pages(gfp_mask, 0,
+					node_zonelist(nid, gfp_mask));
+
+	return new_page;
+}
+
 #define NR_OFFLINE_AT_ONCE_PAGES	(256)
 static int
 do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
@@ -1564,11 +1595,8 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			goto out;
 		}
 
-		/*
-		 * alloc_migrate_target should be improooooved!!
-		 * migrate_pages returns # of failed pages.
-		 */
-		ret = migrate_pages(&source, alloc_migrate_target, NULL, 0,
+		/* Allocate a new page from the nearest neighbor node */
+		ret = migrate_pages(&source, new_node_page, NULL, 0,
 					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
 		if (ret)
 			putback_movable_pages(&source);
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
