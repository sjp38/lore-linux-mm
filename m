From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070831205339.22283.40267.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070831205139.22283.71284.sendpatchset@skynet.skynet.ie>
References: <20070831205139.22283.71284.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 6/6] Use macros instead of static inline functions for zonelist iterators
Date: Fri, 31 Aug 2007 21:53:39 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, ak@suse.de, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

gcc-3.4 and probably older compiler versions produce worse code for static
inline functions than they do for macros. Due to the fact the allocator
path is a hotpath, there is approximately a 0.2% performance difference on
kernbench's System CPU times when using static inline functions. This is
not a problem on gcc 4.1.

This patch should be ignored because the static inline functions come with
type-checking and there doesn't need to be concern about macro arguements
having funky side-effects. However, as the performance problem is noticable
on older compilers, the compiler version and this patch should be checked
as the potential source and solution to a performance regression.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 include/linux/gfp.h    |    8 ++++----
 include/linux/mmzone.h |   31 +++++++++++++++++++------------
 2 files changed, 23 insertions(+), 16 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-mm1-040_use_one_zonelist/include/linux/gfp.h linux-2.6.23-rc3-mm1-045_macro_not_inline/include/linux/gfp.h
--- linux-2.6.23-rc3-mm1-040_use_one_zonelist/include/linux/gfp.h	2007-08-31 17:22:55.000000000 +0100
+++ linux-2.6.23-rc3-mm1-045_macro_not_inline/include/linux/gfp.h	2007-08-31 17:23:10.000000000 +0100
@@ -156,11 +156,11 @@ static inline gfp_t set_migrateflags(gfp
  *
  * For the normal case of non-DISCONTIGMEM systems the NODE_DATA() gets
  * optimized to &contig_page_data at compile-time.
+ *
+ * See the explanation above zonelist_zone() in include/linux/mmzone.h as
+ * to why this is a macro and not a static inline
  */
-static inline struct zonelist *node_zonelist(int nid)
-{
-	return &NODE_DATA(nid)->node_zonelist;
-}
+#define node_zonelist(nid) (&NODE_DATA(nid)->node_zonelist)
 
 #ifndef HAVE_ARCH_FREE_PAGE
 static inline void arch_free_page(struct page *page, int order) { }
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-mm1-040_use_one_zonelist/include/linux/mmzone.h linux-2.6.23-rc3-mm1-045_macro_not_inline/include/linux/mmzone.h
--- linux-2.6.23-rc3-mm1-040_use_one_zonelist/include/linux/mmzone.h	2007-08-31 18:06:59.000000000 +0100
+++ linux-2.6.23-rc3-mm1-045_macro_not_inline/include/linux/mmzone.h	2007-08-31 17:23:10.000000000 +0100
@@ -687,15 +687,16 @@ extern struct zone *next_zone(struct zon
 #endif
 
 #define ZONELIST_ZONEIDX_MASK ((1UL << ZONES_SHIFT) - 1)
-static inline struct zone *zonelist_zone(unsigned long zone_addr)
-{
-	return (struct zone *)(zone_addr & ~ZONELIST_ZONEIDX_MASK);
-}
 
-static inline int zonelist_zone_idx(unsigned long zone_addr)
-{
-	return zone_addr & ZONELIST_ZONEIDX_MASK;
-}
+/*
+ * Subtle: These are macros, not static inlines because gcc 3.4 at least
+ * produces worse code with static inline functions. The effect is about 0.4%
+ * regression in kernbench tests. The problem doesn't appear to exist on
+ * gcc 4.1
+ */
+#define zonelist_zone_idx(zone_addr) ((zone_addr) & ZONELIST_ZONEIDX_MASK)
+#define zonelist_zone(zone_addr) \
+	((struct zone *)((zone_addr) & ~ZONELIST_ZONEIDX_MASK))
 
 static inline unsigned long encode_zone_idx(struct zone *zone)
 {
@@ -706,13 +707,19 @@ static inline unsigned long encode_zone_
 	return encoded;
 }
 
-static inline int zone_in_nodemask(unsigned long zone_addr, nodemask_t *nodes)
-{
 #ifdef CONFIG_NUMA
-	return node_isset(zonelist_zone(zone_addr)->node, *nodes);
+#define zone_in_nodemask(zone_addr, nodes) \
+	(node_isset(zonelist_zone(zone_addr)->node, *nodes))
 #else
-	return 1;
+#define zone_in_nodemask(zone_addr, nodes) (1)
 #endif /* CONFIG_NUMA */
+
+static inline int zone_in_nodemask(unsigned long zone_addr, nodemask_t *nodes)
+{
+	if (NUMA_BUILD)
+		return node_isset(zonelist_zone(zone_addr)->node, *nodes);
+
+	return 1;
 }
 
 /* Returns the first zone at or below highest_zoneidx in a zonelist */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
