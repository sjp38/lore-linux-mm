Subject: 100 cleanup node zone
In-Reply-To: <4173D219.3010706@shadowen.org>
Message-Id: <E1CJYbY-0000aC-5j@ladymac.shadowen.org>
From: Andy Whitcroft <apw@shadowen.org>
Date: Mon, 18 Oct 2004 15:35:20 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

diffstat 100-cleanup-node-zone
---
 mm.h     |   43 ++++++++++++++++++++++++++++++++++++-------
 mmzone.h |   16 +++-------------
 2 files changed, 39 insertions(+), 20 deletions(-)

diff -upN reference/include/linux/mm.h current/include/linux/mm.h
--- reference/include/linux/mm.h
+++ current/include/linux/mm.h
@@ -376,16 +376,41 @@ static inline void put_page(struct page 
  * We'll have up to (MAX_NUMNODES * MAX_NR_ZONES) zones total,
  * so we use (MAX_NODES_SHIFT + MAX_ZONES_SHIFT) here to get enough bits.
  */
-#define NODEZONE_SHIFT (sizeof(page_flags_t)*8 - MAX_NODES_SHIFT - MAX_ZONES_SHIFT)
-#define NODEZONE(node, zone)	((node << ZONES_SHIFT) | zone)
+
+#define FLAGS_SHIFT	(sizeof(page_flags_t)*8)
+
+/* 32bit: NODE:ZONE */
+#define PGFLAGS_NODES_SHIFT	(FLAGS_SHIFT - NODES_SHIFT)
+#define PGFLAGS_ZONES_SHIFT	(PGFLAGS_NODES_SHIFT - ZONES_SHIFT)
+
+#define ZONETABLE_SHIFT		(NODES_SHIFT + ZONES_SHIFT)
+#define PGFLAGS_ZONETABLE_SHIFT	(FLAGS_SHIFT - ZONETABLE_SHIFT)
+
+#if NODES_SHIFT+ZONES_SHIFT > FLAGS_TOTAL_SHIFT
+#error NODES_SHIFT+ZONES_SHIFT > FLAGS_TOTAL_SHIFT
+#endif
+
+#define NODEZONE(node, zone)		((node << ZONES_SHIFT) | zone)
+
+#define ZONES_MASK		(~((~0UL) << ZONES_SHIFT))
+#define NODES_MASK		(~((~0UL) << NODES_SHIFT))
+#define ZONETABLE_MASK		(~((~0UL) << ZONETABLE_SHIFT))
+
+#define PGFLAGS_MASK		(~((~0UL) << PGFLAGS_ZONETABLE_SHIFT)
 
 static inline unsigned long page_zonenum(struct page *page)
 {
-	return (page->flags >> NODEZONE_SHIFT) & (~(~0UL << ZONES_SHIFT));
+	if (FLAGS_SHIFT == (PGFLAGS_ZONES_SHIFT + ZONES_SHIFT))
+ 		return (page->flags >> PGFLAGS_ZONES_SHIFT);
+ 	else
+ 		return (page->flags >> PGFLAGS_ZONES_SHIFT) & ZONES_MASK;
 }
 static inline unsigned long page_to_nid(struct page *page)
 {
-	return (page->flags >> (NODEZONE_SHIFT + ZONES_SHIFT));
+	if (FLAGS_SHIFT == (PGFLAGS_NODES_SHIFT + NODES_SHIFT))
+		return (page->flags >> PGFLAGS_NODES_SHIFT);
+	else
+		return (page->flags >> PGFLAGS_NODES_SHIFT) & NODES_MASK;
 }
 
 struct zone;
@@ -393,13 +418,17 @@ extern struct zone *zone_table[];
 
 static inline struct zone *page_zone(struct page *page)
 {
-	return zone_table[page->flags >> NODEZONE_SHIFT];
+	if (FLAGS_SHIFT == (PGFLAGS_ZONETABLE_SHIFT + ZONETABLE_SHIFT))
+		return zone_table[page->flags >> PGFLAGS_ZONETABLE_SHIFT];
+	else
+		return zone_table[page->flags >> PGFLAGS_ZONETABLE_SHIFT &
+			ZONETABLE_MASK];
 }
 
 static inline void set_page_zone(struct page *page, unsigned long nodezone_num)
 {
-	page->flags &= ~(~0UL << NODEZONE_SHIFT);
-	page->flags |= nodezone_num << NODEZONE_SHIFT;
+	page->flags &= PGFLAGS_MASK;
+	page->flags |= nodezone_num << PGFLAGS_ZONETABLE_SHIFT;
 }
 
 #ifndef CONFIG_DISCONTIGMEM
diff -upN reference/include/linux/mmzone.h current/include/linux/mmzone.h
--- reference/include/linux/mmzone.h
+++ current/include/linux/mmzone.h
@@ -389,27 +389,17 @@ extern struct pglist_data contig_page_da
  * with 32 bit page->flags field, we reserve 8 bits for node/zone info.
  * there are 3 zones (2 bits) and this leaves 8-2=6 bits for nodes.
  */
-#define MAX_NODES_SHIFT		6
+#define FLAGS_TOTAL_SHIFT	8
+
 #elif BITS_PER_LONG == 64
 /*
  * with 64 bit flags field, there's plenty of room.
  */
-#define MAX_NODES_SHIFT		10
+#define FLAGS_TOTAL_SHIFT	12
 #endif
 
 #endif /* !CONFIG_DISCONTIGMEM */
 
-#if NODES_SHIFT > MAX_NODES_SHIFT
-#error NODES_SHIFT > MAX_NODES_SHIFT
-#endif
-
-/* There are currently 3 zones: DMA, Normal & Highmem, thus we need 2 bits */
-#define MAX_ZONES_SHIFT		2
-
-#if ZONES_SHIFT > MAX_ZONES_SHIFT
-#error ZONES_SHIFT > MAX_ZONES_SHIFT
-#endif
-
 extern DECLARE_BITMAP(node_online_map, MAX_NUMNODES);
 
 #if defined(CONFIG_DISCONTIGMEM) || defined(CONFIG_NUMA)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
