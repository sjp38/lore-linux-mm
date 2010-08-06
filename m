Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9447760020C
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:35 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FXHE013751
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:33 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FWbe1896542
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FWMr021052
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 16/43] memblock: Factor the lowest level alloc function
Date: Fri,  6 Aug 2010 15:14:57 +1000
Message-Id: <1281071724-28740-17-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 mm/memblock.c |   59 ++++++++++++++++++++++++++------------------------------
 1 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 13807f2..e264e8c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -294,8 +294,8 @@ static u64 memblock_align_up(u64 addr, u64 size)
 	return (addr + (size - 1)) & ~(size - 1);
 }
 
-static u64 __init memblock_alloc_nid_unreserved(u64 start, u64 end,
-					   u64 size, u64 align)
+static u64 __init memblock_alloc_region(u64 start, u64 end,
+				   u64 size, u64 align)
 {
 	u64 base, res_base;
 	long j;
@@ -318,6 +318,13 @@ static u64 __init memblock_alloc_nid_unreserved(u64 start, u64 end,
 	return ~(u64)0;
 }
 
+u64 __weak __init memblock_nid_range(u64 start, u64 end, int *nid)
+{
+	*nid = 0;
+
+	return end;
+}
+
 static u64 __init memblock_alloc_nid_region(struct memblock_region *mp,
 				       u64 size, u64 align, int nid)
 {
@@ -333,8 +340,7 @@ static u64 __init memblock_alloc_nid_region(struct memblock_region *mp,
 
 		this_end = memblock_nid_range(start, end, &this_nid);
 		if (this_nid == nid) {
-			u64 ret = memblock_alloc_nid_unreserved(start, this_end,
-							   size, align);
+			u64 ret = memblock_alloc_region(start, this_end, size, align);
 			if (ret != ~(u64)0)
 				return ret;
 		}
@@ -351,6 +357,10 @@ u64 __init memblock_alloc_nid(u64 size, u64 align, int nid)
 
 	BUG_ON(0 == size);
 
+	/* We do a bottom-up search for a region with the right
+	 * nid since that's easier considering how memblock_nid_range()
+	 * works
+	 */
 	size = memblock_align_up(size, align);
 
 	for (i = 0; i < mem->cnt; i++) {
@@ -383,7 +393,7 @@ u64 __init memblock_alloc_base(u64 size, u64 align, u64 max_addr)
 
 u64 __init __memblock_alloc_base(u64 size, u64 align, u64 max_addr)
 {
-	long i, j;
+	long i;
 	u64 base = 0;
 	u64 res_base;
 
@@ -396,33 +406,24 @@ u64 __init __memblock_alloc_base(u64 size, u64 align, u64 max_addr)
 	if (max_addr == MEMBLOCK_ALLOC_ANYWHERE)
 		max_addr = MEMBLOCK_REAL_LIMIT;
 
+	/* Pump up max_addr */
+	if (max_addr == MEMBLOCK_ALLOC_ANYWHERE)
+		max_addr = ~(u64)0;
+
+	/* We do a top-down search, this tends to limit memory
+	 * fragmentation by keeping early boot allocs near the
+	 * top of memory
+	 */
 	for (i = memblock.memory.cnt - 1; i >= 0; i--) {
 		u64 memblockbase = memblock.memory.regions[i].base;
 		u64 memblocksize = memblock.memory.regions[i].size;
 
 		if (memblocksize < size)
 			continue;
-		if (max_addr == MEMBLOCK_ALLOC_ANYWHERE)
-			base = memblock_align_down(memblockbase + memblocksize - size, align);
-		else if (memblockbase < max_addr) {
-			base = min(memblockbase + memblocksize, max_addr);
-			base = memblock_align_down(base - size, align);
-		} else
-			continue;
-
-		while (base && memblockbase <= base) {
-			j = memblock_overlaps_region(&memblock.reserved, base, size);
-			if (j < 0) {
-				/* this area isn't reserved, take it */
-				if (memblock_add_region(&memblock.reserved, base, size) < 0)
-					return 0;
-				return base;
-			}
-			res_base = memblock.reserved.regions[j].base;
-			if (res_base < size)
-				break;
-			base = memblock_align_down(res_base - size, align);
-		}
+		base = min(memblockbase + memblocksize, max_addr);
+		res_base = memblock_alloc_region(memblockbase, base, size, align);
+		if (res_base != ~(u64)0)
+			return res_base;
 	}
 	return 0;
 }
@@ -528,9 +529,3 @@ int memblock_is_region_reserved(u64 base, u64 size)
 	return memblock_overlaps_region(&memblock.reserved, base, size) >= 0;
 }
 
-u64 __weak memblock_nid_range(u64 start, u64 end, int *nid)
-{
-	*nid = 0;
-
-	return end;
-}
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
