Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 801E56B006E
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 20:28:25 -0400 (EDT)
From: Greg Pearson <greg.pearson@hp.com>
Subject: [PATCH v2] mm/memblock: fix overlapping allocation when doubling reserved array
Date: Fri, 15 Jun 2012 18:28:16 -0600
Message-Id: <1339806496-17435-1-git-send-email-greg.pearson@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, hpa@linux.intel.com, akpm@linux-foundation.org, shangw@linux.vnet.ibm.com, mingo@elte.hu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, greg.pearson@hp.com

The __alloc_memory_core_early() routine will ask memblock for a range
of memory then try to reserve it. If the reserved region array lacks
space for the new range, memblock_double_array() is called to allocate
more space for the array. If memblock is used to allocate memory for
the new array it can end up using a range that overlaps with the range
originally allocated in __alloc_memory_core_early(), leading to possible
data corruption.

With this patch memblock_double_array() now calls memblock_find_in_range()
with a narrowed candidate range so any memory allocated will not overlap
with the original range that was being reserved. The range is narrowed by
passing in both the starting and ending address of the previously allocated
range. Then the range above the ending address is searched and if a candidate
is not found, the range below the starting address is searched.

Changes from v1: (based on comments from Yinghai Lu)
- use obase instead of base in memblock_add_region() for exclude start address
- pass in both the starting and ending address of the exclude range to
  memblock_double_array()
- have memblock_double_array() search above the exclude ending address
  and below the exclude starting address for a free range

Signed-off-by: Greg Pearson <greg.pearson@hp.com>
---
 mm/memblock.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 952123e..fee3ad9 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -184,7 +184,8 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 	}
 }
 
-static int __init_memblock memblock_double_array(struct memblock_type *type)
+static int __init_memblock memblock_double_array(struct memblock_type *type,
+			phys_addr_t exclude_start, phys_addr_t exclude_end)
 {
 	struct memblock_region *new_array, *old_array;
 	phys_addr_t old_size, new_size, addr;
@@ -222,7 +223,12 @@ static int __init_memblock memblock_double_array(struct memblock_type *type)
 		new_array = kmalloc(new_size, GFP_KERNEL);
 		addr = new_array ? __pa(new_array) : 0;
 	} else {
-		addr = memblock_find_in_range(0, MEMBLOCK_ALLOC_ACCESSIBLE, new_size, sizeof(phys_addr_t));
+		addr = memblock_find_in_range(exclude_end,
+			MEMBLOCK_ALLOC_ACCESSIBLE,
+			new_size, sizeof(phys_addr_t));
+		if (!addr)
+			addr = memblock_find_in_range(0, exclude_start,
+				new_size, sizeof(phys_addr_t));
 		new_array = addr ? __va(addr) : 0;
 	}
 	if (!addr) {
@@ -399,7 +405,8 @@ repeat:
 	 */
 	if (!insert) {
 		while (type->cnt + nr_new > type->max)
-			if (memblock_double_array(type) < 0)
+			/* Avoid possible overlap if range is being reserved */
+			if (memblock_double_array(type, obase, obase+size) < 0)
 				return -ENOMEM;
 		insert = true;
 		goto repeat;
@@ -450,7 +457,7 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 
 	/* we'll create at most two more regions */
 	while (type->cnt + 2 > type->max)
-		if (memblock_double_array(type) < 0)
+		if (memblock_double_array(type, 0, MEMBLOCK_ALLOC_ACCESSIBLE) < 0)
 			return -ENOMEM;
 
 	for (i = 0; i < type->cnt; i++) {
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
