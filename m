Date: Sat, 21 Jul 2007 16:03:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] zone config patch set [2/2] CONFIG_ZONE_MOVABLE
Message-Id: <20070721160336.28ec3ad8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070721160049.75bc8d9f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070721160049.75bc8d9f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "apw@shadowen.org" <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>, nickpiggin@yahoo.com.au, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Makes ZONE_MOVABLE as configurable

Based on "zone_ifdef_cleanup_by_renumbering.patch"

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



---
 include/linux/gfp.h    |    3 ++-
 include/linux/mmzone.h |   11 +++++++----
 include/linux/vmstat.h |   13 +++++++++++--
 mm/Kconfig             |   13 +++++++++++++
 mm/page_alloc.c        |    6 ++++++
 mm/vmstat.c            |    8 +++++++-
 6 files changed, 46 insertions(+), 8 deletions(-)

Index: linux-2.6.22-rc6-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/mmzone.h
+++ linux-2.6.22-rc6-mm1/include/linux/mmzone.h
@@ -177,7 +177,9 @@ enum zone_type {
 	 */
 	ZONE_HIGHMEM,
 #endif
+#ifdef CONFIG_ZONE_MOVABLE
 	ZONE_MOVABLE,
+#endif
 	MAX_NR_ZONES,
 #ifndef CONFIG_ZONE_DMA
 	ZONE_DMA,
@@ -188,6 +190,9 @@ enum zone_type {
 #ifndef CONFIG_HIGHMEM
 	ZONE_HIGHMEM,
 #endif
+#ifndef CONFIG_ZONE_MOVABLE
+	ZONE_MOVABLE,
+#endif
 	MAX_POSSIBLE_ZONES,
 };
 
@@ -567,11 +572,9 @@ static inline int zone_idx_is(enum zone_
 
 static inline int zone_movable_is_highmem(void)
 {
-#if CONFIG_ARCH_POPULATES_NODE_MAP
-	if (is_configured_zone(ZONE_HIGHMEM))
-		return movable_zone == ZONE_HIGHMEM;
-#endif
-	return 0;
+	return is_configured_zone(ZONE_HIGHMEM) &&
+	       is_configured_zone(ZONE_MOVABLE) &&
+		(movable_zone == ZONE_HIGHMEM);
 }
 
 static inline int is_highmem_idx(enum zone_type idx)
Index: linux-2.6.22-rc6-mm1/include/linux/gfp.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/gfp.h
+++ linux-2.6.22-rc6-mm1/include/linux/gfp.h
@@ -122,7 +122,8 @@ static inline enum zone_type gfp_zone(gf
 	if (is_configured_zone(ZONE_DMA32) && (flags & __GFP_DMA32))
 		return ZONE_DMA32;
 
-	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
+	if (is_configured_zone(ZONE_MOVABLE) &&
+	    (flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
 			(__GFP_HIGHMEM | __GFP_MOVABLE))
 		return ZONE_MOVABLE;
 
Index: linux-2.6.22-rc6-mm1/mm/Kconfig
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/Kconfig
+++ linux-2.6.22-rc6-mm1/mm/Kconfig
@@ -112,6 +112,19 @@ config SPARSEMEM_EXTREME
 	def_bool y
 	depends on SPARSEMEM && !SPARSEMEM_STATIC
 
+
+config ZONE_MOVABLE
+	bool	"A zone for movable pages"
+	depends on ARCH_POPULATES_NODE_MAP
+	help
+	  Allows creating a zone type only for movable pages, i.e page cache
+	  and anonymous memory. Because movable pages are tend to be easily
+	  reclaimed and page migration technique can move them, your chance
+	  for allocating big size memory will be better in this zone than
+  	  other zones.
+	  To use this zone, please see "kernelcore=" or "movablecore=" in
+	  Documentation/kernel-parameters.txt
+
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
Index: linux-2.6.22-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/page_alloc.c
+++ linux-2.6.22-rc6-mm1/mm/page_alloc.c
@@ -86,7 +86,9 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_Z
 #ifdef CONFIG_HIGHMEM
 	 32,
 #endif
+#ifdef CONFIG_ZONE_MOVABLE
 	 32,
+#endif
 };
 
 EXPORT_SYMBOL(totalram_pages);
@@ -3883,6 +3885,10 @@ static int __init cmdline_parse_kernelco
 	if (!p)
 		return -EINVAL;
 
+	if (!is_configured_zone(ZONE_MOVABLE)) {
+		printk ("ZONE_MOVABLE is not configured, kernelcore= is ignored.\n");
+		return 0;
+	}
 	coremem = memparse(p, &p);
 	required_kernelcore = coremem >> PAGE_SHIFT;
 
Index: linux-2.6.22-rc6-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/vmstat.c
+++ linux-2.6.22-rc6-mm1/mm/vmstat.c
@@ -694,8 +694,14 @@ const struct seq_operations pagetypeinfo
 #define TEXT_FOR_HIGHMEM(xx)
 #endif
 
+#ifdef CONFIG_ZONE_MOVABLE
+#define TEXT_FOR_MOVABLE(xx) xx "_movable",
+#else
+#define TEXT_FOR_MOVABLE(xx)
+#endif
+
 #define TEXTS_FOR_ZONES(xx) TEXT_FOR_DMA(xx) TEXT_FOR_DMA32(xx) xx "_normal", \
-					TEXT_FOR_HIGHMEM(xx) xx "_movable",
+					TEXT_FOR_HIGHMEM(xx) xx TEXT_FOR_MOVABLE(xx)
 
 static const char * const vmstat_text[] = {
 	/* Zoned VM counters */
Index: linux-2.6.22-rc6-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/vmstat.h
+++ linux-2.6.22-rc6-mm1/include/linux/vmstat.h
@@ -25,7 +25,14 @@
 #define HIGHMEM_ZONE(xx)
 #endif
 
-#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) , xx##_MOVABLE
+#ifdef CONFIG_ZONE_MOVABLE
+#define MOVABLE_ZONE(xx) , xx##_MOVABLE
+#else
+#define MOVABLE_ZONE(xx)
+#endif
+
+
+#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) MOVABLE_ZONE(xx)
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
@@ -170,7 +177,9 @@ static inline unsigned long node_page_st
 	if (is_configured_zone(ZONE_HIGHMEM))
 		val += zone_page_state(&zones[ZONE_HIGHMEM], item);
 
-	val += zone_page_state(&zones[ZONE_MOVABLE], item);
+	if (is_configured_zone(ZONE_MOVABLE))
+		val += zone_page_state(&zones[ZONE_MOVABLE], item);
+
 	return val;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
