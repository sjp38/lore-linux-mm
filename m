Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F76C6B02AE
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:35 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765BAlQ011487
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:11:10 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FWEZ753716
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FVtE016363
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 14/43] memblock: Remove memblock_find()
Date: Fri,  6 Aug 2010 15:14:55 +1000
Message-Id: <1281071724-28740-15-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Nobody uses it anymore. It's semantics were ... weird

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/memblock.h |    1 -
 mm/memblock.c            |   32 --------------------------------
 2 files changed, 0 insertions(+), 33 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 7d70fdd..776c7d9 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -60,7 +60,6 @@ extern int memblock_is_memory(u64 addr);
 extern int memblock_is_region_memory(u64 base, u64 size);
 extern int __init memblock_is_reserved(u64 addr);
 extern int memblock_is_region_reserved(u64 base, u64 size);
-extern int memblock_find(struct memblock_region *res);
 
 extern void memblock_dump_all(void);
 
diff --git a/mm/memblock.c b/mm/memblock.c
index aa88c62..8a118b7 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -531,35 +531,3 @@ int memblock_is_region_reserved(u64 base, u64 size)
 	return memblock_overlaps_region(&memblock.reserved, base, size) >= 0;
 }
 
-/*
- * Given a <base, len>, find which memory regions belong to this range.
- * Adjust the request and return a contiguous chunk.
- */
-int memblock_find(struct memblock_region *res)
-{
-	int i;
-	u64 rstart, rend;
-
-	rstart = res->base;
-	rend = rstart + res->size - 1;
-
-	for (i = 0; i < memblock.memory.cnt; i++) {
-		u64 start = memblock.memory.regions[i].base;
-		u64 end = start + memblock.memory.regions[i].size - 1;
-
-		if (start > rend)
-			return -1;
-
-		if ((end >= rstart) && (start < rend)) {
-			/* adjust the request */
-			if (rstart < start)
-				rstart = start;
-			if (rend > end)
-				rend = end;
-			res->base = rstart;
-			res->size = rend - rstart + 1;
-			return 0;
-		}
-	}
-	return -1;
-}
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
