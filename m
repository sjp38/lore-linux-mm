Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 927AB6B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 19:48:14 -0400 (EDT)
From: Greg Pearson <greg.pearson@hp.com>
Subject: [PATCH v4] mm/memblock: fix overlapping allocation when doubling reserved array
Date: Mon, 18 Jun 2012 17:47:58 -0600
Message-Id: <1340063278-31601-1-git-send-email-greg.pearson@hp.com>
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

Changes from v3 to v4 (based on comments from Tejun Heo):
- change parameter names passed to memblock_double_array() so they
  are not misleading and better signify the reason why the array is
  being doubled
- add function comment block to memblock_double_arry() to ensure
  the details of the possible overlap are explained

Signed-off-by: Greg Pearson <greg.pearson@hp.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yinghai Lu <yinghai@kernel.org>
---
 mm/memblock.c |   36 ++++++++++++++++++++++++++++++++----
 1 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 952123e..0e737d9 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -184,7 +184,24 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 	}
 }
 
-static int __init_memblock memblock_double_array(struct memblock_type *type)
+/**
+ * memblock_double_array - double the size of the memblock regions array
+ * @type: memblock type of the regions array being doubled
+ * @new_area_start: starting address of memory range to avoid overlap with
+ * @new_area_size: size of memory range to avoid overlap with
+ *
+ * Double the size of the @type regions array. If memblock is being used to
+ * allocate memory for a new reserved regions array and there is a previously
+ * allocated memory range [@new_area_start,@new_area_start+@new_area_size]
+ * waiting to be reserved, ensure the memory used by the new array does
+ * not overlap.
+ *
+ * RETURNS:
+ * 0 on success, -1 on failure.
+ */
+static int __init_memblock memblock_double_array(struct memblock_type *type,
+						phys_addr_t new_area_start,
+						phys_addr_t new_area_size)
 {
 	struct memblock_region *new_array, *old_array;
 	phys_addr_t old_size, new_size, addr;
@@ -222,7 +239,18 @@ static int __init_memblock memblock_double_array(struct memblock_type *type)
 		new_array = kmalloc(new_size, GFP_KERNEL);
 		addr = new_array ? __pa(new_array) : 0;
 	} else {
-		addr = memblock_find_in_range(0, MEMBLOCK_ALLOC_ACCESSIBLE, new_size, sizeof(phys_addr_t));
+		/* only exclude range when trying to double reserved.regions */
+		if (type != &memblock.reserved)
+			new_area_start = new_area_size = 0;
+
+		addr = memblock_find_in_range(new_area_start + new_area_size,
+						memblock.current_limit,
+						new_size, sizeof(phys_addr_t));
+		if (!addr && new_area_size)
+			addr = memblock_find_in_range(0,
+					min(new_area_start, memblock.current_limit),
+					new_size, sizeof(phys_addr_t));
+
 		new_array = addr ? __va(addr) : 0;
 	}
 	if (!addr) {
@@ -399,7 +427,7 @@ repeat:
 	 */
 	if (!insert) {
 		while (type->cnt + nr_new > type->max)
-			if (memblock_double_array(type) < 0)
+			if (memblock_double_array(type, obase, size) < 0)
 				return -ENOMEM;
 		insert = true;
 		goto repeat;
@@ -450,7 +478,7 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 
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
