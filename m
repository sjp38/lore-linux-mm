Message-Id: <20080530194739.417271003@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:31 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 11/14] bootmem: respect goal more likely
Content-Disposition: inline; filename=bootmem-respect-goal-more-likely.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The old node-agnostic code tried allocating on all nodes starting from
the one with the lowest range.  alloc_bootmem_core retried without the
goal if it could not satisfy it and so the goal was only respected at
all when it happened to be on the first (lowest page numbers) node (or
theoretically if allocations failed on all nodes before to the one
holding the goal).

Introduce a non-panicking helper that starts allocating from the node
holding the goal and falls back only after all thes tries failed.

Make all other allocation helpers benefit from this new helper.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
CC: Ingo Molnar <mingo@elte.hu>
CC: Yinghai Lu <yhlu.kernel@gmail.com>
CC: Andi Kleen <andi@firstfloor.org>
---

 mm/bootmem.c |   77 +++++++++++++++++++++++++++++++----------------------------
 1 file changed, 41 insertions(+), 36 deletions(-)

--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -487,11 +487,33 @@ find_block:
 		memset(region, 0, size);
 		return region;
 	}
+	return NULL;
+}
+
+static void * __init ___alloc_bootmem_nopanic(unsigned long size,
+					unsigned long align,
+					unsigned long goal,
+					unsigned long limit)
+{
+	bootmem_data_t *bdata;
+
+restart:
+	list_for_each_entry(bdata, &bdata_list, list) {
+		void *region;
+
+		if (goal && goal < bdata->node_boot_start)
+			continue;
+		if (limit && limit < bdata->node_boot_start)
+			continue;
+
+		region = alloc_bootmem_core(bdata, size, align, goal, limit);
+		if (region)
+			return region;
+	}
 
 	if (goal) {
 		goal = 0;
-		start = 0;
-		goto find_block;
+		goto restart;
 	}
 
 	return NULL;
@@ -511,16 +533,23 @@ find_block:
  * Returns NULL on failure.
  */
 void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
-				      unsigned long goal)
+					unsigned long goal)
 {
-	bootmem_data_t *bdata;
-	void *ptr;
+	return ___alloc_bootmem_nopanic(size, align, goal, 0);
+}
 
-	list_for_each_entry(bdata, &bdata_list, list) {
-		ptr = alloc_bootmem_core(bdata, size, align, goal, 0);
-		if (ptr)
-			return ptr;
-	}
+static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
+					unsigned long goal, unsigned long limit)
+{
+	void *mem = ___alloc_bootmem_nopanic(size, align, goal, limit);
+
+	if (mem)
+		return mem;
+	/*
+	 * Whoops, we cannot satisfy the allocation request.
+	 */
+	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
+	panic("Out of memory");
 	return NULL;
 }
 
@@ -540,16 +569,7 @@ void * __init __alloc_bootmem_nopanic(un
 void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 			      unsigned long goal)
 {
-	void *mem = __alloc_bootmem_nopanic(size,align,goal);
-
-	if (mem)
-		return mem;
-	/*
-	 * Whoops, we cannot satisfy the allocation request.
-	 */
-	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
-	panic("Out of memory");
-	return NULL;
+	return ___alloc_bootmem(size, align, goal, 0);
 }
 
 #ifndef ARCH_LOW_ADDRESS_LIMIT
@@ -572,22 +592,7 @@ void * __init __alloc_bootmem(unsigned l
 void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
 				  unsigned long goal)
 {
-	bootmem_data_t *bdata;
-	void *ptr;
-
-	list_for_each_entry(bdata, &bdata_list, list) {
-		ptr = alloc_bootmem_core(bdata, size, align, goal,
-					ARCH_LOW_ADDRESS_LIMIT);
-		if (ptr)
-			return ptr;
-	}
-
-	/*
-	 * Whoops, we cannot satisfy the allocation request.
-	 */
-	printk(KERN_ALERT "low bootmem alloc of %lu bytes failed!\n", size);
-	panic("Out of low memory");
-	return NULL;
+	return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT);
 }
 
 /**

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
