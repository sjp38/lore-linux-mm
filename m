Date: Mon, 12 Feb 2007 10:16:23 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Use ZVC counters to establish exact size of dirtyable pages
Message-ID: <Pine.LNX.4.64.0702121014500.15560@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We can use the global ZVC counters to establish the exact size of the LRU
and the free pages allowing a more accurate determination of the dirty
ratio.

This patch will fix the broken ratio calculations if large amounts of
memory are allocated to huge pags or other consumers that do not put the
pages on to the LRU.

Notes:
- I did not add NR_SLAB_RECLAIMABLE to the calculation of the
  dirtyable pages. Those may be reclaimable but they are at this
  point not dirtyable. If NR_SLAB_RECLAIMABLE would be considered
  then a huge number of reclaimable slab pages could stop writeback
  from occurring.

- This patch used to be in mm as the last one in a series of patches.
  It was removed when Linus updated the treatment of highmem because
  there was a conflict. I updated the patch to follow Linus' approach.
  This patch is neede to fulfill the claims made in the beginning of the
  patchset that is now in Linus' tree.

- I added an optimized path for i386 NUMA since the zone
  layout allows determination of the non HIGHMEM pages
  by adding up lowmem zones on node 0.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-02-12 09:15:22.000000000 -0800
+++ linux-2.6/mm/page-writeback.c	2007-02-12 10:06:15.000000000 -0800
@@ -119,6 +119,58 @@ static void background_writeout(unsigned
  * We make sure that the background writeout level is below the adjusted
  * clamping level.
  */
+
+static unsigned long determine_dirtyable_memory(void)
+{
+	unsigned long x;
+
+#ifndef CONFIG_HIGHMEM
+	x = global_page_state(NR_FREE_PAGES)
+		+ global_page_state(NR_INACTIVE)
+		+ global_page_state(NR_ACTIVE);
+#else
+	/*
+	 * We always exclude high memory from our count
+	 */
+#if defined(CONFIG_NUMA) && defined(CONFIG_X86_32)
+	/*
+	 * i386 32 bit NUMA configurations have all non HIGHMEM zones on
+	 * node 0. So its easier to just add up the lowmemt zones on node 0.
+	 */
+	struct zone * z;
+
+	x = 0;
+	for (z = NODE_DATA(0)->node_zones;
+			z < NODE_DATA(0)->node_zones + ZONE_HIGHMEM;
+			z++)
+		x = zone_page_state(z, NR_FREE_PAGES)
+			+ zone_page_state(z, NR_INACTIVE)
+			+ zone_page_state(z, NR_ACTIVE);
+
+#else
+	/*
+	 * Just subtract the HIGHMEM zones.
+	 */
+	int node;
+
+	x = global_page_state(NR_FREE_PAGES)
+		+ global_page_state(NR_INACTIVE)
+		+ global_page_state(NR_ACTIVE);
+
+	for_each_online_node(node) {
+		struct zone *z =
+			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
+
+		x -= zone_page_state(z, NR_FREE_PAGES)
+			+ zone_page_state(z, NR_INACTIVE)
+			+ zone_page_state(z, NR_ACTIVE);
+	}
+
+#endif
+#endif /* CONFIG_HIGHMEM */
+	return x;
+}
+
 static void
 get_dirty_limits(long *pbackground, long *pdirty,
 					struct address_space *mapping)
@@ -128,17 +180,9 @@ get_dirty_limits(long *pbackground, long
 	int unmapped_ratio;
 	long background;
 	long dirty;
-	unsigned long available_memory = vm_total_pages;
+	unsigned long available_memory = determine_dirtyable_memory();
 	struct task_struct *tsk;
 
-#ifdef CONFIG_HIGHMEM
-	/*
-	 * We always exclude high memory from our count.
-	 */
-	available_memory -= totalhigh_pages;
-#endif
-
-
 	unmapped_ratio = 100 - ((global_page_state(NR_FILE_MAPPED) +
 				global_page_state(NR_ANON_PAGES)) * 100) /
 					vm_total_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
