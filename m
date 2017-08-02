Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4FEAE6B0621
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 16:39:18 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r62so54973674pfj.1
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 13:39:18 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n84si16003685pfh.410.2017.08.02.13.39.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 13:39:17 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v4 13/15] mm: stop zeroing memory during allocation in vmemmap
Date: Wed,  2 Aug 2017 16:38:22 -0400
Message-Id: <1501706304-869240-14-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1501706304-869240-1-git-send-email-pasha.tatashin@oracle.com>
References: <1501706304-869240-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org

Replace allocators in sprase-vmemmap to use the non-zeroing version. So,
we will get the performance improvement by zeroing the memory in parallel
when struct pages are zeroed.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 mm/sparse-vmemmap.c | 6 +++---
 mm/sparse.c         | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index d40c721ab19f..3b646b5ce1b6 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -41,7 +41,7 @@ static void * __ref __earlyonly_bootmem_alloc(int node,
 				unsigned long align,
 				unsigned long goal)
 {
-	return memblock_virt_alloc_try_nid(size, align, goal,
+	return memblock_virt_alloc_try_nid_raw(size, align, goal,
 					    BOOTMEM_ALLOC_ACCESSIBLE, node);
 }
 
@@ -56,11 +56,11 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 
 		if (node_state(node, N_HIGH_MEMORY))
 			page = alloc_pages_node(
-				node, GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
+				node, GFP_KERNEL | __GFP_RETRY_MAYFAIL,
 				get_order(size));
 		else
 			page = alloc_pages(
-				GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
+				GFP_KERNEL | __GFP_RETRY_MAYFAIL,
 				get_order(size));
 		if (page)
 			return page_address(page);
diff --git a/mm/sparse.c b/mm/sparse.c
index 7b4be3fd5cac..0e315766ad11 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -441,9 +441,9 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 	}
 
 	size = PAGE_ALIGN(size);
-	map = memblock_virt_alloc_try_nid(size * map_count,
-					  PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
-					  BOOTMEM_ALLOC_ACCESSIBLE, nodeid);
+	map = memblock_virt_alloc_try_nid_raw(size * map_count,
+					      PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
+					      BOOTMEM_ALLOC_ACCESSIBLE, nodeid);
 	if (map) {
 		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 			if (!present_section_nr(pnum))
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
