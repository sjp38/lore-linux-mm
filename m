Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 76BB3600299
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:36 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FU3J025377
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:30 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FYSu1781996
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FXbj017054
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 31/43] memblock: Add arch function to control coalescing of memblock memory regions
Date: Fri,  6 Aug 2010 15:15:12 +1000
Message-Id: <1281071724-28740-32-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Some archs such as ARM want to avoid coalescing accross things such
as the lowmem/highmem boundary or similar. This provides the option
to control it via an arch callback for which a weak default is provided
which always allows coalescing.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/memblock.h |    2 ++
 mm/memblock.c            |   19 ++++++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 150be93..e5e8f9d 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -72,6 +72,8 @@ extern void memblock_dump_all(void);
 
 /* Provided by the architecture */
 extern phys_addr_t memblock_nid_range(phys_addr_t start, phys_addr_t end, int *nid);
+extern int memblock_memory_can_coalesce(phys_addr_t addr1, phys_addr_t size1,
+				   phys_addr_t addr2, phys_addr_t size2);
 
 /**
  * memblock_set_current_limit - Set the current allocation limit to allow
diff --git a/mm/memblock.c b/mm/memblock.c
index 0787790..8715f09 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -241,6 +241,12 @@ static int memblock_double_array(struct memblock_type *type)
 	return 0;
 }
 
+extern int __weak memblock_memory_can_coalesce(phys_addr_t addr1, phys_addr_t size1,
+					  phys_addr_t addr2, phys_addr_t size2)
+{
+	return 1;
+}
+
 static long memblock_add_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long coalesced = 0;
@@ -262,6 +268,10 @@ static long memblock_add_region(struct memblock_type *type, phys_addr_t base, ph
 			return 0;
 
 		adjacent = memblock_addrs_adjacent(base, size, rgnbase, rgnsize);
+		/* Check if arch allows coalescing */
+		if (adjacent != 0 && type == &memblock.memory &&
+		    !memblock_memory_can_coalesce(base, size, rgnbase, rgnsize))
+			break;
 		if (adjacent > 0) {
 			type->regions[i].base -= size;
 			type->regions[i].size += size;
@@ -274,7 +284,14 @@ static long memblock_add_region(struct memblock_type *type, phys_addr_t base, ph
 		}
 	}
 
-	if ((i < type->cnt - 1) && memblock_regions_adjacent(type, i, i+1)) {
+	/* If we plugged a hole, we may want to also coalesce with the
+	 * next region
+	 */
+	if ((i < type->cnt - 1) && memblock_regions_adjacent(type, i, i+1) &&
+	    ((type != &memblock.memory || memblock_memory_can_coalesce(type->regions[i].base,
+							     type->regions[i].size,
+							     type->regions[i+1].base,
+							     type->regions[i+1].size)))) {
 		memblock_coalesce_regions(type, i, i+1);
 		coalesced++;
 	}
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
