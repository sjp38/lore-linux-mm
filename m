Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 430776B006C
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 14:14:17 -0500 (EST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm/sparse: don't check return value of alloc_bootmem calls
Date: Thu, 20 Dec 2012 14:11:38 -0500
Message-Id: <1356030701-16284-30-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com>
References: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Gavin Shan <shangw@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Sasha Levin <sasha.levin@oracle.com>

These calls will panic if they can't allocate the memory, so we can
assume that we get actual memory back. This simplifies some functions
and removes unneeded checks.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/sparse.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 6b5fb76..ae64d6e 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -403,15 +403,13 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 	size = PAGE_ALIGN(size);
 	map = __alloc_bootmem_node_high(NODE_DATA(nodeid), size * map_count,
 					 PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
-	if (map) {
-		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-			if (!present_section_nr(pnum))
-				continue;
-			map_map[pnum] = map;
-			map += size;
-		}
-		return;
+	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
+		if (!present_section_nr(pnum))
+			continue;
+		map_map[pnum] = map;
+		map += size;
 	}
+	return;
 
 	/* fallback */
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
@@ -497,8 +495,6 @@ void __init sparse_init(void)
 	 */
 	size = sizeof(unsigned long *) * NR_MEM_SECTIONS;
 	usemap_map = alloc_bootmem(size);
-	if (!usemap_map)
-		panic("can not allocate usemap_map\n");
 
 	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
 		struct mem_section *ms;
@@ -538,8 +534,6 @@ void __init sparse_init(void)
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
 	map_map = alloc_bootmem(size2);
-	if (!map_map)
-		panic("can not allocate map_map\n");
 
 	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
 		struct mem_section *ms;
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
