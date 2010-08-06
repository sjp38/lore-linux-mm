Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EAF746B02B3
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:35 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FU2c025376
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:30 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FYFZ1753172
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FXNE017059
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 32/43] memblock: Add "start" argument to memblock_find_base()
Date: Fri,  6 Aug 2010 15:15:13 +1000
Message-Id: <1281071724-28740-33-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

To constraint the search of a region between two boundaries,
which will be used by the new NUMA aware allocator among others.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 mm/memblock.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 8715f09..468ff43 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -117,19 +117,18 @@ static phys_addr_t __init memblock_find_region(phys_addr_t start, phys_addr_t en
 	return MEMBLOCK_ERROR;
 }
 
-static phys_addr_t __init memblock_find_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
+static phys_addr_t __init memblock_find_base(phys_addr_t size, phys_addr_t align,
+					phys_addr_t start, phys_addr_t end)
 {
 	long i;
-	phys_addr_t base = 0;
-	phys_addr_t res_base;
 
 	BUG_ON(0 == size);
 
 	size = memblock_align_up(size, align);
 
 	/* Pump up max_addr */
-	if (max_addr == MEMBLOCK_ALLOC_ACCESSIBLE)
-		max_addr = memblock.current_limit;
+	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
+		end = memblock.current_limit;
 
 	/* We do a top-down search, this tends to limit memory
 	 * fragmentation by keeping early boot allocs near the
@@ -138,13 +137,19 @@ static phys_addr_t __init memblock_find_base(phys_addr_t size, phys_addr_t align
 	for (i = memblock.memory.cnt - 1; i >= 0; i--) {
 		phys_addr_t memblockbase = memblock.memory.regions[i].base;
 		phys_addr_t memblocksize = memblock.memory.regions[i].size;
+		phys_addr_t bottom, top, found;
 
 		if (memblocksize < size)
 			continue;
-		base = min(memblockbase + memblocksize, max_addr);
-		res_base = memblock_find_region(memblockbase, base, size, align);
-		if (res_base != MEMBLOCK_ERROR)
-			return res_base;
+		if ((memblockbase + memblocksize) <= start)
+			break;
+		bottom = max(memblockbase, start);
+		top = min(memblockbase + memblocksize, end);
+		if (bottom >= top)
+			continue;
+		found = memblock_find_region(bottom, top, size, align);
+		if (found != MEMBLOCK_ERROR)
+			return found;
 	}
 	return MEMBLOCK_ERROR;
 }
@@ -204,7 +209,7 @@ static int memblock_double_array(struct memblock_type *type)
 		new_array = kmalloc(new_size, GFP_KERNEL);
 		addr = new_array == NULL ? MEMBLOCK_ERROR : __pa(new_array);
 	} else
-		addr = memblock_find_base(new_size, sizeof(phys_addr_t), MEMBLOCK_ALLOC_ACCESSIBLE);
+		addr = memblock_find_base(new_size, sizeof(phys_addr_t), 0, MEMBLOCK_ALLOC_ACCESSIBLE);
 	if (addr == MEMBLOCK_ERROR) {
 		pr_err("memblock: Failed to double %s array from %ld to %ld entries !\n",
 		       memblock_type_name(type), type->max, type->max * 2);
@@ -416,7 +421,7 @@ phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, ph
 	 */
 	size = memblock_align_up(size, align);
 
-	found = memblock_find_base(size, align, max_addr);
+	found = memblock_find_base(size, align, 0, max_addr);
 	if (found != MEMBLOCK_ERROR &&
 	    memblock_add_region(&memblock.reserved, found, size) >= 0)
 		return found;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
