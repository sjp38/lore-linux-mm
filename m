Message-Id: <20080530194737.961788044@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:24 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 04/14] bootmem: add debugging framework
Content-Disposition: inline; filename=bootmem-debugging.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce the bootmem_debug kernel parameter that enables very verbose
diagnostics regarding all range operations of bootmem as well as the
initialization and release of nodes.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---

 mm/bootmem.c |   51 ++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 44 insertions(+), 7 deletions(-)

--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -34,6 +34,22 @@ unsigned long saved_max_pfn;
 
 bootmem_data_t bootmem_node_data[MAX_NUMNODES] __initdata;
 
+static int bootmem_debug;
+
+static int __init bootmem_debug_setup(char *buf)
+{
+	bootmem_debug = 1;
+	return 0;
+}
+early_param("bootmem_debug", bootmem_debug_setup);
+
+#define bdebug(fmt, args...) ({				\
+	if (unlikely(bootmem_debug))			\
+		printk(KERN_INFO			\
+			"bootmem::%s " fmt,		\
+			__FUNCTION__, ## args);		\
+})
+
 /*
  * Given an initialised bdata, it returns the size of the boot bitmap
  */
@@ -104,6 +120,9 @@ static unsigned long __init init_bootmem
 	mapsize = get_mapsize(bdata);
 	memset(bdata->node_bootmem_map, 0xff, mapsize);
 
+	bdebug("nid=%d start=%lx map=%lx end=%lx mapsize=%ld\n",
+		bdata - bootmem_node_data, start, mapstart, end, mapsize);
+
 	return mapsize;
 }
 
@@ -198,6 +217,8 @@ static unsigned long __init free_all_boo
 	count += i;
 	bdata->node_bootmem_map = NULL;
 
+	bdebug("nid=%d released=%ld\n", bdata - bootmem_node_data, count);
+
 	return count;
 }
 
@@ -255,6 +276,10 @@ static void __init free_bootmem_core(boo
 	if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
 		eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
 
+	bdebug("nid=%d start=%lx end=%lx\n", bdata - bootmem_node_data,
+		sidx + PFN_DOWN(bdata->node_boot_start),
+		eidx + PFN_DOWN(bdata->node_boot_start));
+
 	for (i = sidx; i < eidx; i++) {
 		if (unlikely(!test_and_clear_bit(i, bdata->node_bootmem_map)))
 			BUG();
@@ -360,13 +385,16 @@ static void __init reserve_bootmem_core(
 	if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
 		eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
 
-	for (i = sidx; i < eidx; i++) {
-		if (test_and_set_bit(i, bdata->node_bootmem_map)) {
-#ifdef CONFIG_DEBUG_BOOTMEM
-			printk("hm, page %08lx reserved twice.\n", i*PAGE_SIZE);
-#endif
-		}
-	}
+	bdebug("nid=%d start=%lx end=%lx flags=%x\n",
+		bdata - bootmem_node_data,
+		sidx + PFN_DOWN(bdata->node_boot_start),
+		eidx + PFN_DOWN(bdata->node_boot_start),
+		flags);
+
+	for (i = sidx; i < eidx; i++)
+		if (test_and_set_bit(i, bdata->node_bootmem_map))
+			bdebug("hm, page %lx reserved twice.\n",
+				PFN_DOWN(bdata->node_boot_start) + i);
 }
 
 /**
@@ -451,6 +479,10 @@ alloc_bootmem_core(struct bootmem_data *
 	if (!bdata->node_bootmem_map)
 		return NULL;
 
+	bdebug("nid=%d size=%lx [%lu pages] align=%lx goal=%lx limit=%lx\n",
+		bdata - bootmem_node_data, size, PAGE_ALIGN(size) >> PAGE_SHIFT,
+		align, goal, limit);
+
 	/* bdata->node_boot_start is supposed to be (12+6)bits alignment on x86_64 ? */
 	node_boot_start = bdata->node_boot_start;
 	node_bootmem_map = bdata->node_bootmem_map;
@@ -558,6 +590,11 @@ found:
 		ret = phys_to_virt(start * PAGE_SIZE + node_boot_start);
 	}
 
+	bdebug("nid=%d start=%lx end=%lx\n",
+		bdata - bootmem_node_data,
+		start + PFN_DOWN(bdata->node_boot_start),
+		start + areasize + PFN_DOWN(bdata->node_boot_start));
+
 	/*
 	 * Reserve the area now:
 	 */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
