Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C4BCF6B006C
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 14:29:27 -0400 (EDT)
From: Greg Pearson <greg.pearson@hp.com>
Subject: [PATCH v3] mm/memblock: fix overlapping allocation when doubling reserved array
Date: Mon, 18 Jun 2012 12:28:47 -0600
Message-Id: <1340044127-13864-1-git-send-email-greg.pearson@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, hpa@linux.intel.com, akpm@linux-foundation.org, shangw@linux.vnet.ibm.com, mingo@elte.hu
Cc: yinghai@kernel.org, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, greg.pearson@hp.com

The __alloc_memory_core_early() routine will ask memblock for a range
of memory then try to reserve it. If the reserved region array lacks
space for the new range, memblock_double_array() is called to allocate
more space for the array. If memblock is used to allocate memory for
the new array it can end up using a range that overlaps with the range
originally allocated in __alloc_memory_core_early(), leading to possible
data corruption.

With this patch memblock_double_array() now calls memblock_find_in_range()
with a narrowed candidate range (in cases where the reserved.regions array
is being doubled) so any memory allocated will not overlap with the original
range that was being reserved. The range is narrowed by passing in the
starting address and size of the previously allocated range. Then the
range above the ending address is searched and if a candidate is not
found, the range below the starting address is searched.

Changes from v1 to v2 (based on comments from Yinghai Lu):
- use obase instead of base in memblock_add_region() for excluding start address
- pass in both the starting and ending address of the exclude range to
  memblock_double_array()
- have memblock_double_array() search above the exclude ending address
  and below the exclude starting address for a free range

Changes from v2 to v3 (based on comments from Yinghai Lu):
- pass in exclude_start and exclude_size to memblock_double_array()
- only exclude a range if doubling the reserved.regions array
- make sure narrowed range passed to memblock_find_in_range() is accessible
- to make the code less confusing, change memblock_isolate_range() to
  pass in exclude_start and exclude_size
- remove unneeded comment in memblock_add_region() between while and
  one line loop body

Signed-off-by: Greg Pearson <greg.pearson@hp.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yinghai Lu <yinghai@kernel.org>
---
 mm/memblock.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 952123e..3a61e74 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -184,7 +184,9 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 	}
 }
 
-static int __init_memblock memblock_double_array(struct memblock_type *type)
+static int __init_memblock memblock_double_array(struct memblock_type *type,
+						phys_addr_t exclude_start,
+						phys_addr_t exclude_size)
 {
 	struct memblock_region *new_array, *old_array;
 	phys_addr_t old_size, new_size, addr;
@@ -222,7 +224,18 @@ static int __init_memblock memblock_double_array(struct memblock_type *type)
 		new_array = kmalloc(new_size, GFP_KERNEL);
 		addr = new_array ? __pa(new_array) : 0;
 	} else {
-		addr = memblock_find_in_range(0, MEMBLOCK_ALLOC_ACCESSIBLE, new_size, sizeof(phys_addr_t));
+		/* only exclude range when trying to double reserved.regions */
+		if (type != &memblock.reserved)
+			exclude_start = exclude_size = 0;
+
+		addr = memblock_find_in_range(exclude_start + exclude_size,
+						memblock.current_limit,
+						new_size, sizeof(phys_addr_t));
+		if (!addr && exclude_size)
+			addr = memblock_find_in_range(0,
+					min(exclude_start, memblock.current_limit),
+					new_size, sizeof(phys_addr_t));
+
 		new_array = addr ? __va(addr) : 0;
 	}
 	if (!addr) {
@@ -399,7 +412,7 @@ repeat:
 	 */
 	if (!insert) {
 		while (type->cnt + nr_new > type->max)
-			if (memblock_double_array(type) < 0)
+			if (memblock_double_array(type, obase, size) < 0)
 				return -ENOMEM;
 		insert = true;
 		goto repeat;
@@ -450,7 +463,7 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 
 	/* we'll create at most two more regions */
 	while (type->cnt + 2 > type->max)
-		if (memblock_double_array(type) < 0)
+		if (memblock_double_array(type, base, size) < 0)
 			return -ENOMEM;
 
 	for (i = 0; i < type->cnt; i++) {
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
