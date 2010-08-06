Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1912F6B02AC
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:37 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FR1r029534
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:27 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FYJo872516
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FXuI017051
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 30/43] memblock: Add array resizing support
Date: Fri,  6 Aug 2010 15:15:11 +1000
Message-Id: <1281071724-28740-31-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

When one of the array gets full, we resize it. After much thinking and
a few iterations of that code, I went back to on-demand resizing using
the (new) internal memblock_find_base() function, which is pretty much what
Yinghai initially proposed, though there some differences in the details.

To work this relies on the default alloc limit being set sensibly by
the architecture.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 mm/memblock.c |  104 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 102 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index e5f3f9b..0787790 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -11,6 +11,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/bitops.h>
 #include <linux/poison.h>
@@ -18,12 +19,23 @@
 
 struct memblock memblock;
 
-static int memblock_debug;
+static int memblock_debug, memblock_can_resize;
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS + 1];
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS + 1];
 
 #define MEMBLOCK_ERROR	(~(phys_addr_t)0)
 
+/* inline so we don't get a warning when pr_debug is compiled out */
+static inline const char *memblock_type_name(struct memblock_type *type)
+{
+	if (type == &memblock.memory)
+		return "memory";
+	else if (type == &memblock.reserved)
+		return "reserved";
+	else
+		return "unknown";
+}
+
 /*
  * Address comparison utilities
  */
@@ -156,6 +168,79 @@ static void memblock_coalesce_regions(struct memblock_type *type,
 	memblock_remove_region(type, r2);
 }
 
+/* Defined below but needed now */
+static long memblock_add_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size);
+
+static int memblock_double_array(struct memblock_type *type)
+{
+	struct memblock_region *new_array, *old_array;
+	phys_addr_t old_size, new_size, addr;
+	int use_slab = slab_is_available();
+
+	/* We don't allow resizing until we know about the reserved regions
+	 * of memory that aren't suitable for allocation
+	 */
+	if (!memblock_can_resize)
+		return -1;
+
+	pr_debug("memblock: %s array full, doubling...", memblock_type_name(type));
+
+	/* Calculate new doubled size */
+	old_size = type->max * sizeof(struct memblock_region);
+	new_size = old_size << 1;
+
+	/* Try to find some space for it.
+	 *
+	 * WARNING: We assume that either slab_is_available() and we use it or
+	 * we use MEMBLOCK for allocations. That means that this is unsafe to use
+	 * when bootmem is currently active (unless bootmem itself is implemented
+	 * on top of MEMBLOCK which isn't the case yet)
+	 *
+	 * This should however not be an issue for now, as we currently only
+	 * call into MEMBLOCK while it's still active, or much later when slab is
+	 * active for memory hotplug operations
+	 */
+	if (use_slab) {
+		new_array = kmalloc(new_size, GFP_KERNEL);
+		addr = new_array == NULL ? MEMBLOCK_ERROR : __pa(new_array);
+	} else
+		addr = memblock_find_base(new_size, sizeof(phys_addr_t), MEMBLOCK_ALLOC_ACCESSIBLE);
+	if (addr == MEMBLOCK_ERROR) {
+		pr_err("memblock: Failed to double %s array from %ld to %ld entries !\n",
+		       memblock_type_name(type), type->max, type->max * 2);
+		return -1;
+	}
+	new_array = __va(addr);
+
+	/* Found space, we now need to move the array over before
+	 * we add the reserved region since it may be our reserved
+	 * array itself that is full.
+	 */
+	memcpy(new_array, type->regions, old_size);
+	memset(new_array + type->max, 0, old_size);
+	old_array = type->regions;
+	type->regions = new_array;
+	type->max <<= 1;
+
+	/* If we use SLAB that's it, we are done */
+	if (use_slab)
+		return 0;
+
+	/* Add the new reserved region now. Should not fail ! */
+	BUG_ON(memblock_add_region(&memblock.reserved, addr, new_size) < 0);
+
+	/* If the array wasn't our static init one, then free it. We only do
+	 * that before SLAB is available as later on, we don't know whether
+	 * to use kfree or free_bootmem_pages(). Shouldn't be a big deal
+	 * anyways
+	 */
+	if (old_array != memblock_memory_init_regions &&
+	    old_array != memblock_reserved_init_regions)
+		memblock_free(__pa(old_array), old_size);
+
+	return 0;
+}
+
 static long memblock_add_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long coalesced = 0;
@@ -196,7 +281,11 @@ static long memblock_add_region(struct memblock_type *type, phys_addr_t base, ph
 
 	if (coalesced)
 		return coalesced;
-	if (type->cnt >= type->max)
+
+	/* If we are out of space, we fail. It's too late to resize the array
+	 * but then this shouldn't have happened in the first place.
+	 */
+	if (WARN_ON(type->cnt >= type->max))
 		return -1;
 
 	/* Couldn't coalesce the MEMBLOCK, so add it to the sorted table. */
@@ -217,6 +306,14 @@ static long memblock_add_region(struct memblock_type *type, phys_addr_t base, ph
 	}
 	type->cnt++;
 
+	/* The array is full ? Try to resize it. If that fails, we undo
+	 * our allocation and return an error
+	 */
+	if (type->cnt == type->max && memblock_double_array(type)) {
+		type->cnt--;
+		return -1;
+	}
+
 	return 0;
 }
 
@@ -541,6 +638,9 @@ void __init memblock_analyze(void)
 
 	for (i = 0; i < memblock.memory.cnt; i++)
 		memblock.memory_size += memblock.memory.regions[i].size;
+
+	/* We allow resizing from there */
+	memblock_can_resize = 1;
 }
 
 void __init memblock_init(void)
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
