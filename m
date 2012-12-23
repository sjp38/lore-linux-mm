Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id CBABB8D0001
	for <linux-mm@kvack.org>; Sun, 23 Dec 2012 15:15:53 -0500 (EST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 1/3] mm, sparse: allocate bootmem without panicing in sparse_mem_maps_populate_node
Date: Sun, 23 Dec 2012 15:15:06 -0500
Message-Id: <1356293711-23864-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Gavin Shan <shangw@linux.vnet.ibm.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

__alloc_bootmem_node_high() would panic if it failed allocating, so the fallback
would never get reached. Switch to using __alloc_bootmem_node_high_nopanic().

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/sparse.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 6b5fb76..72a0db6 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -401,7 +401,7 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 	}
 
 	size = PAGE_ALIGN(size);
-	map = __alloc_bootmem_node_high(NODE_DATA(nodeid), size * map_count,
+	map = __alloc_bootmem_node_high_nopanic(NODE_DATA(nodeid), size * map_count,
 					 PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
 	if (map) {
 		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
