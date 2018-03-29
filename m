Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF09D6B0003
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 23:36:22 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id c16so2800378pgv.8
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 20:36:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1-v6sor1546741pln.97.2018.03.28.20.36.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 20:36:21 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/page_alloc: call set_pageblock_order() once for each node
Date: Thu, 29 Mar 2018 11:36:07 +0800
Message-Id: <20180329033607.8440-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, mgorman@suse.de
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

set_pageblock_order() is a standalone function which sets pageblock_order,
while current implementation calls this function on each ZONE of each node
in free_area_init_core().

Since free_area_init_node() is the only user of free_area_init_core(),
this patch moves set_pageblock_order() up one level to invoke
set_pageblock_order() only once on each node.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8c964dcc3a9e..828f5014b006 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6169,7 +6169,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		if (!size)
 			continue;
 
-		set_pageblock_order();
 		setup_usemap(pgdat, zone, zone_start_pfn, size);
 		init_currently_empty_zone(zone, zone_start_pfn, size);
 		memmap_init(size, nid, j, zone_start_pfn);
@@ -6254,6 +6253,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	alloc_node_mem_map(pgdat);
 
 	reset_deferred_meminit(pgdat);
+	set_pageblock_order();
 	free_area_init_core(pgdat);
 }
 
-- 
2.15.1
