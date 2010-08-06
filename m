Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 000F96B02AC
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:34 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FPHG029499
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:25 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FWDk1593344
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FVqk021025
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 09/43] memblock/sh: Use new accessors
Date: Fri,  6 Aug 2010 15:14:50 +1000
Message-Id: <1281071724-28740-10-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mundt <lethal@linux-sh.org>
List-ID: <linux-mm.kvack.org>

CC: Paul Mundt <lethal@linux-sh.org>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/sh/mm/init.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index d0e2491..b977475 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -200,7 +200,6 @@ static void __init bootmem_init_one_node(unsigned int nid)
 	unsigned long total_pages, paddr;
 	unsigned long end_pfn;
 	struct pglist_data *p;
-	int i;
 
 	p = NODE_DATA(nid);
 
@@ -226,11 +225,12 @@ static void __init bootmem_init_one_node(unsigned int nid)
 	 * reservations in other nodes.
 	 */
 	if (nid == 0) {
+		struct memblock_region *reg;
+
 		/* Reserve the sections we're already using. */
-		for (i = 0; i < memblock.reserved.cnt; i++)
-			reserve_bootmem(memblock.reserved.region[i].base,
-					memblock_size_bytes(&memblock.reserved, i),
-					BOOTMEM_DEFAULT);
+		for_each_memblock(reserved, reg) {
+			reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
+		}
 	}
 
 	sparse_memory_present_with_active_regions(nid);
@@ -238,13 +238,14 @@ static void __init bootmem_init_one_node(unsigned int nid)
 
 static void __init do_init_bootmem(void)
 {
+	struct memblock_region *reg;
 	int i;
 
 	/* Add active regions with valid PFNs. */
-	for (i = 0; i < memblock.memory.cnt; i++) {
+	for_each_memblock(memory, reg) {
 		unsigned long start_pfn, end_pfn;
-		start_pfn = memblock.memory.region[i].base >> PAGE_SHIFT;
-		end_pfn = start_pfn + memblock_size_pages(&memblock.memory, i);
+		start_pfn = memblock_region_base_pfn(reg);
+		end_pfn = memblock_region_end_pfn(reg);
 		__add_active_range(0, start_pfn, end_pfn);
 	}
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
