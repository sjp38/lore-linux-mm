Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 98B8F6B02A5
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:34 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FVL1013725
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FV0l1294358
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FVQf020979
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:31 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 04/43] memblock: Implement memblock_is_memory and memblock_is_region_memory
Date: Fri,  6 Aug 2010 15:14:45 +1000
Message-Id: <1281071724-28740-5-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

To make it fast, we steal ARM's binary search for memblock_is_memory()
and we use that to also the replace existing implementation of
memblock_is_reserved().

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/memblock.h |    2 ++
 mm/memblock.c            |   42 ++++++++++++++++++++++++++++++++++--------
 2 files changed, 36 insertions(+), 8 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 4b69313..47bceb1 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -56,6 +56,8 @@ extern u64 __init __memblock_alloc_base(u64 size,
 extern u64 __init memblock_phys_mem_size(void);
 extern u64 memblock_end_of_DRAM(void);
 extern void __init memblock_enforce_memory_limit(u64 memory_limit);
+extern int memblock_is_memory(u64 addr);
+extern int memblock_is_region_memory(u64 base, u64 size);
 extern int __init memblock_is_reserved(u64 addr);
 extern int memblock_is_region_reserved(u64 base, u64 size);
 extern int memblock_find(struct memblock_region *res);
diff --git a/mm/memblock.c b/mm/memblock.c
index 6f407cc..aa88c62 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -487,17 +487,43 @@ void __init memblock_enforce_memory_limit(u64 memory_limit)
 	}
 }
 
+static int memblock_search(struct memblock_type *type, u64 addr)
+{
+	unsigned int left = 0, right = type->cnt;
+
+	do {
+		unsigned int mid = (right + left) / 2;
+
+		if (addr < type->regions[mid].base)
+			right = mid;
+		else if (addr >= (type->regions[mid].base +
+				  type->regions[mid].size))
+			left = mid + 1;
+		else
+			return mid;
+	} while (left < right);
+	return -1;
+}
+
 int __init memblock_is_reserved(u64 addr)
 {
-	int i;
+	return memblock_search(&memblock.reserved, addr) != -1;
+}
 
-	for (i = 0; i < memblock.reserved.cnt; i++) {
-		u64 upper = memblock.reserved.regions[i].base +
-			memblock.reserved.regions[i].size - 1;
-		if ((addr >= memblock.reserved.regions[i].base) && (addr <= upper))
-			return 1;
-	}
-	return 0;
+int memblock_is_memory(u64 addr)
+{
+	return memblock_search(&memblock.memory, addr) != -1;
+}
+
+int memblock_is_region_memory(u64 base, u64 size)
+{
+	int idx = memblock_search(&memblock.reserved, base);
+
+	if (idx == -1)
+		return 0;
+	return memblock.reserved.regions[idx].base <= base &&
+		(memblock.reserved.regions[idx].base +
+		 memblock.reserved.regions[idx].size) >= (base + size);
 }
 
 int memblock_is_region_reserved(u64 base, u64 size)
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
