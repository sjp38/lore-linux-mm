Message-Id: <20080530194738.997752885@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:29 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 09/14] bootmem: free/reserve helpers
Content-Disposition: inline; filename=bootmem-free-reserve-helpers.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Factor out the common operation of marking a range on the bitmap.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
CC: Ingo Molnar <mingo@elte.hu>
CC: Yinghai Lu <yhlu.kernel@gmail.com>
CC: Andi Kleen <andi@firstfloor.org>
---

 mm/bootmem.c |   64 +++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 43 insertions(+), 21 deletions(-)

--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -225,6 +225,44 @@ unsigned long __init free_all_bootmem(vo
 	return free_all_bootmem_core(NODE_DATA(0)->bdata);
 }
 
+static void __init __free(bootmem_data_t *bdata,
+			unsigned long sidx, unsigned long eidx)
+{
+	unsigned long idx;
+
+	bdebug("nid=%d start=%lx end=%lx\n", bdata - bootmem_node_data,
+		sidx + PFN_DOWN(bdata->node_boot_start),
+		eidx + PFN_DOWN(bdata->node_boot_start));
+
+	for (idx = sidx; idx < eidx; idx++)
+		if (!test_and_clear_bit(idx, bdata->node_bootmem_map))
+			BUG();
+}
+
+static int __init __reserve(bootmem_data_t *bdata, unsigned long sidx,
+			unsigned long eidx, int flags)
+{
+	unsigned long idx;
+	int exclusive = flags & BOOTMEM_EXCLUSIVE;
+
+	bdebug("nid=%d start=%lx end=%lx flags=%x\n",
+		bdata - bootmem_node_data,
+		sidx + PFN_DOWN(bdata->node_boot_start),
+		eidx + PFN_DOWN(bdata->node_boot_start),
+		flags);
+
+	for (idx = sidx; idx < eidx; idx++)
+		if (test_and_set_bit(idx, bdata->node_bootmem_map)) {
+			if (exclusive) {
+				__free(bdata, sidx, idx);
+				return -EBUSY;
+			}
+			bdebug("silent double reserve of PFN %lx\n",
+				idx + PFN_DOWN(bdata->node_boot_start));
+		}
+	return 0;
+}
+
 static void __init free_bootmem_core(bootmem_data_t *bdata, unsigned long addr,
 				     unsigned long size)
 {
@@ -257,14 +295,7 @@ static void __init free_bootmem_core(boo
 	if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
 		eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
 
-	bdebug("nid=%d start=%lx end=%lx\n", bdata - bootmem_node_data,
-		sidx + PFN_DOWN(bdata->node_boot_start),
-		eidx + PFN_DOWN(bdata->node_boot_start));
-
-	for (i = sidx; i < eidx; i++) {
-		if (unlikely(!test_and_clear_bit(i, bdata->node_bootmem_map)))
-			BUG();
-	}
+	__free(bdata, sidx, eidx);
 }
 
 /**
@@ -366,16 +397,7 @@ static void __init reserve_bootmem_core(
 	if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
 		eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
 
-	bdebug("nid=%d start=%lx end=%lx flags=%x\n",
-		bdata - bootmem_node_data,
-		sidx + PFN_DOWN(bdata->node_boot_start),
-		eidx + PFN_DOWN(bdata->node_boot_start),
-		flags);
-
-	for (i = sidx; i < eidx; i++)
-		if (test_and_set_bit(i, bdata->node_bootmem_map))
-			bdebug("hm, page %lx reserved twice.\n",
-				PFN_DOWN(bdata->node_boot_start) + i);
+	return __reserve(bdata, sidx, eidx, flags);
 }
 
 /**
@@ -504,9 +526,9 @@ find_block:
 		/*
 		 * Reserve the area now:
 		 */
-		for (i = PFN_DOWN(new_start) + merge; i < PFN_UP(new_end); i++)
-			if (test_and_set_bit(i, bdata->node_bootmem_map))
-				BUG();
+		if (__reserve(bdata, PFN_DOWN(new_start) + merge,
+				PFN_UP(new_end), BOOTMEM_EXCLUSIVE))
+			BUG();
 
 		region = phys_to_virt(bdata->node_boot_start + new_start);
 		memset(region, 0, size);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
