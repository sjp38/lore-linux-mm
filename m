Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B12C6B037C
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 10:39:36 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w126so5673833wme.10
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:39:36 -0700 (PDT)
Received: from mail-wr0-f195.google.com (mail-wr0-f195.google.com. [209.85.128.195])
        by mx.google.com with ESMTPS id i66si1130333wmc.212.2017.07.21.07.39.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 07:39:34 -0700 (PDT)
Received: by mail-wr0-f195.google.com with SMTP id 12so4466642wrb.4
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:39:34 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 9/9] mm, sparse, page_ext: drop ugly N_HIGH_MEMORY branches for allocations
Date: Fri, 21 Jul 2017 16:39:15 +0200
Message-Id: <20170721143915.14161-10-mhocko@kernel.org>
In-Reply-To: <20170721143915.14161-1-mhocko@kernel.org>
References: <20170721143915.14161-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <js1304@gmail.com>, Shaohua Li <shaohua.li@intel.com>

From: Michal Hocko <mhocko@suse.com>

f52407ce2dea ("memory hotplug: alloc page from other node in memory
online") has introduced N_HIGH_MEMORY checks to only use NUMA aware
allocations when there is some memory present because the respective
node might not have any memory yet at the time and so it could fail
or even OOM. Things have changed since then though. Zonelists are
now always initialized before we do any allocations even for hotplug
(see 959ecc48fc75 ("mm/memory_hotplug.c: fix building of node hotplug
zonelist")). Therefore these checks are not really needed. In fact
caller of the allocator should never care about whether the node is
populated because that might change at any time.

Cc: Shaohua Li <shaohua.li@intel.com>
Cc: Joonsoo Kim <js1304@gmail.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_ext.c       |  5 +----
 mm/sparse-vmemmap.c | 11 +++--------
 mm/sparse.c         | 10 +++-------
 3 files changed, 7 insertions(+), 19 deletions(-)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 88ccc044b09a..714ce79256c5 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -222,10 +222,7 @@ static void *__meminit alloc_page_ext(size_t size, int nid)
 		return addr;
 	}
 
-	if (node_state(nid, N_HIGH_MEMORY))
-		addr = vzalloc_node(size, nid);
-	else
-		addr = vzalloc(size);
+	addr = vzalloc_node(size, nid);
 
 	return addr;
 }
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index c50b1a14d55e..d1a39b8051e0 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -54,14 +54,9 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 	if (slab_is_available()) {
 		struct page *page;
 
-		if (node_state(node, N_HIGH_MEMORY))
-			page = alloc_pages_node(
-				node, GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
-				get_order(size));
-		else
-			page = alloc_pages(
-				GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
-				get_order(size));
+		page = alloc_pages_node(node,
+			GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
+			get_order(size));
 		if (page)
 			return page_address(page);
 		return NULL;
diff --git a/mm/sparse.c b/mm/sparse.c
index 7b4be3fd5cac..a9783acf2bb9 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -65,14 +65,10 @@ static noinline struct mem_section __ref *sparse_index_alloc(int nid)
 	unsigned long array_size = SECTIONS_PER_ROOT *
 				   sizeof(struct mem_section);
 
-	if (slab_is_available()) {
-		if (node_state(nid, N_HIGH_MEMORY))
-			section = kzalloc_node(array_size, GFP_KERNEL, nid);
-		else
-			section = kzalloc(array_size, GFP_KERNEL);
-	} else {
+	if (slab_is_available())
+		section = kzalloc_node(array_size, GFP_KERNEL, nid);
+	else
 		section = memblock_virt_alloc_node(array_size, nid);
-	}
 
 	return section;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
