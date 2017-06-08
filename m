Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B781D6B02B4
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 03:46:08 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id s4so4024336wrc.15
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 00:46:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l133sor626772wmd.47.2017.06.08.00.46.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Jun 2017 00:46:07 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/4] mm, memory_hotplug: simplify empty node mask handling in new_node_page
Date: Thu,  8 Jun 2017 09:45:50 +0200
Message-Id: <20170608074553.22152-2-mhocko@kernel.org>
In-Reply-To: <20170608074553.22152-1-mhocko@kernel.org>
References: <20170608074553.22152-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Joonsoo Kim <js1304@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

new_node_page tries to allocate the target page on a different NUMA node
than the source page. This makes sense in most cases during the hotplug
because we are likely to offline the whole numa node. But there are
cases where there are no other nodes to fallback (e.g. when offlining
parts of the only existing node) and we have to fallback to allocating
from the source node. The current code does that but it can be
simplified by checking the nmask and updating it before we even try to
allocate rather than special casing it.

This patch shouldn't introduce any functional change.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d61509752112..1ca373bdffbf 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1432,7 +1432,15 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
 	int nid = page_to_nid(page);
 	nodemask_t nmask = node_states[N_MEMORY];
-	struct page *new_page = NULL;
+
+	/*
+	 * try to allocate from a different node but reuse this node if there
+	 * are no other online nodes to be used (e.g. we are offlining a part
+	 * of the only existing node)
+	 */
+	node_clear(nid, nmask);
+	if (nodes_empty(nmask))
+		node_set(nid, nmask);
 
 	/*
 	 * TODO: allocate a destination hugepage from a nearest neighbor node,
@@ -1443,18 +1451,11 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					next_node_in(nid, nmask));
 
-	node_clear(nid, nmask);
-
 	if (PageHighMem(page)
 	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
 		gfp_mask |= __GFP_HIGHMEM;
 
-	if (!nodes_empty(nmask))
-		new_page = __alloc_pages_nodemask(gfp_mask, 0, nid, &nmask);
-	if (!new_page)
-		new_page = __alloc_pages(gfp_mask, 0, nid);
-
-	return new_page;
+	return __alloc_pages_nodemask(gfp_mask, 0, nid, &nmask);
 }
 
 #define NR_OFFLINE_AT_ONCE_PAGES	(256)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
