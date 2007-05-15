From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070515150411.16348.27937.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/8] Print out PAGE_OWNER statistics in relation to fragmentation avoidance
Date: Tue, 15 May 2007 16:04:11 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When PAGE_OWNER is set, more information is available of relevance
to fragmentation avoidance. A second line is added to /proc/page_owner
showing the PFN, the pageblock number, the mobility type of the page based
on its allocation flags, whether the allocation is improperly placed and
the flags. A sample entry looks like

Page allocated via order 0, mask 0x1280d2
PFN 7355 Block 7 type 3 Fallback Flags      LA     
[0xc01528c6] __handle_mm_fault+598
[0xc0320427] do_page_fault+279
[0xc031ed9a] error_code+114

This information can be used to identify pages that are improperly placed. As
the format of PAGE_OWNER data is now different, the comment at the top of
Documentation/page_owner.c is updated with new instructions.

As PAGE_OWNER tracks the GFP flags used to allocate the pages,
/proc/fragavoidance is enhanced to contain how many mixed blocks exist. The
additional output looks like

Number of mixed blocks    Unmovable  Reclaimable      Movable      Reserve
Node 0, zone      DMA            0            1            2            1
Node 0, zone   Normal            2           11           33            0

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 Documentation/page_owner.c |    3 -
 fs/proc/proc_misc.c        |   28 ++++++++++++
 mm/vmstat.c                |   92 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 122 insertions(+), 1 deletion(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-005_statistics/Documentation/page_owner.c linux-2.6.21-mm2-006_statistics_owner/Documentation/page_owner.c
--- linux-2.6.21-mm2-005_statistics/Documentation/page_owner.c	2007-05-11 21:16:06.000000000 +0100
+++ linux-2.6.21-mm2-006_statistics_owner/Documentation/page_owner.c	2007-05-15 12:26:35.000000000 +0100
@@ -2,7 +2,8 @@
  * User-space helper to sort the output of /proc/page_owner
  *
  * Example use:
- * cat /proc/page_owner > page_owner.txt
+ * cat /proc/page_owner > page_owner_full.txt
+ * grep -v ^PFN page_owner_full.txt > page_owner.txt
  * ./sort page_owner.txt sorted_page_owner.txt
 */
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-005_statistics/fs/proc/proc_misc.c linux-2.6.21-mm2-006_statistics_owner/fs/proc/proc_misc.c
--- linux-2.6.21-mm2-005_statistics/fs/proc/proc_misc.c	2007-05-15 12:24:58.000000000 +0100
+++ linux-2.6.21-mm2-006_statistics_owner/fs/proc/proc_misc.c	2007-05-15 12:26:35.000000000 +0100
@@ -760,6 +760,7 @@ read_page_owner(struct file *file, char 
 	unsigned long offset = 0, symsize;
 	int i;
 	ssize_t num_written = 0;
+	int blocktype = 0, pagetype = 0;
 
 	pfn = min_low_pfn + *ppos;
 	page = pfn_to_page(pfn);
@@ -788,6 +789,33 @@ read_page_owner(struct file *file, char 
 		goto out;
 	}
 
+	/* Print information relevant to grouping pages by mobility */
+	blocktype = get_pageblock_migratetype(page);
+	pagetype  = allocflags_to_migratetype(page->gfp_mask);
+	ret += snprintf(kbuf+ret, count-ret,
+			"PFN %lu Block %lu type %d %s "
+			"Flags %s%s%s%s%s%s%s%s%s%s%s%s\n",
+			pfn,
+			pfn >> pageblock_order,
+			blocktype,
+			blocktype != pagetype ? "Fallback" : "        ",
+			PageLocked(page)	? "K" : " ",
+			PageError(page)		? "E" : " ",
+			PageReferenced(page)	? "R" : " ",
+			PageUptodate(page)	? "U" : " ",
+			PageDirty(page)		? "D" : " ",
+			PageLRU(page)		? "L" : " ",
+			PageActive(page)	? "A" : " ",
+			PageSlab(page)		? "S" : " ",
+			PageWriteback(page)	? "W" : " ",
+			PageCompound(page)	? "C" : " ",
+			PageSwapCache(page)	? "B" : " ",
+			PageMappedToDisk(page)	? "M" : " ");
+	if (ret >= count) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
 	num_written = ret;
 
 	for (i = 0; i < 8; i++) {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-005_statistics/mm/vmstat.c linux-2.6.21-mm2-006_statistics_owner/mm/vmstat.c
--- linux-2.6.21-mm2-005_statistics/mm/vmstat.c	2007-05-15 12:24:58.000000000 +0100
+++ linux-2.6.21-mm2-006_statistics_owner/mm/vmstat.c	2007-05-15 12:26:35.000000000 +0100
@@ -427,6 +427,77 @@ static void frag_stop(struct seq_file *m
 {
 }
 
+#ifdef CONFIG_PAGE_OWNER
+static void fragavoidance_showmixedcount_print(struct seq_file *m,
+							pg_data_t *pgdat,
+							struct zone *zone)
+{
+	int mtype, pagetype;
+	unsigned long pfn;
+	unsigned long start_pfn = zone->zone_start_pfn;
+	unsigned long end_pfn = start_pfn + zone->spanned_pages;
+	unsigned long count[MIGRATE_TYPES] = { 0, };
+
+	/* Align PFNs to nr_pages_pageblock boundary */
+	pfn = start_pfn & ~(nr_pages_pageblock-1);
+
+	/*
+	 * Walk the zone in nr_pages_pageblock steps. If a page block spans
+	 * a zone boundary, it will be double counted between zones. This does
+	 * not matter as the mixed block count will still be correct
+	 */
+	for (; pfn < end_pfn; pfn += nr_pages_pageblock) {
+		struct page *page;
+		unsigned long offset = 0;
+
+		/* Do not read before the zone start */
+		if (pfn < start_pfn)
+			offset = start_pfn - pfn;
+
+		if (!pfn_valid(pfn + offset))
+			continue;
+
+		page = pfn_to_page(pfn + offset);
+		mtype = get_pageblock_migratetype(page);
+
+		/* Check the block for bad migrate types */
+		for (; offset < nr_pages_pageblock; offset++) {
+			/* Do not past the end of the zone */
+			if (pfn + offset >= end_pfn)
+				break;
+
+			if (!pfn_valid_within(pfn + offset))
+				continue;
+
+			page = pfn_to_page(pfn + offset);
+
+			/* Skip free pages */
+			if (PageBuddy(page)) {
+				offset += (1UL << page_private(page)) - 1UL;
+				continue;
+			}
+			if (page->order < 0)
+				continue;
+
+			pagetype = allocflags_to_migratetype(page->gfp_mask);
+			if (pagetype != mtype) {
+				count[mtype]++;
+				break;
+			}
+
+			/* Move to end of this allocation */
+			offset += (1 << page->order) - 1;
+		}
+	}
+
+	/* Print counts */
+	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
+		seq_printf(m, "%12lu ", count[mtype]);
+	seq_putc(m, '\n');
+}
+#endif /* CONFIG_PAGE_OWNER */
+
 /* Walk all the zones in a node and print using a callback */
 static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 		void (*print)(struct seq_file *m, pg_data_t *, struct zone *))
@@ -546,6 +617,26 @@ static int fragavoidance_showblockcount(
 }
 
 /*
+ * Print out the number of pageblocks for each migratetype that contain pages
+ * of other types. This gives an indication of how well fallbacks are being
+ * contained by rmqueue_fallback(). It requires information from PAGE_OWNER
+ * to determine what is going on
+ */
+static void fragavoidance_showmixedcount(struct seq_file *m, pg_data_t *pgdat)
+{
+#ifdef CONFIG_PAGE_OWNER
+	int mtype;
+
+	seq_printf(m, "\n%-23s", "Number of mixed blocks ");
+	/* Print header */
+	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
+		seq_printf(m, "%12s ", migratetype_names[mtype]);
+	seq_putc(m, '\n');
+	walk_zones_in_node(m, pgdat, fragavoidance_showmixedcount_print);
+#endif /* CONFIG_PAGE_OWNER */
+}
+
+/*
  * This prints out statistics in relation to  grouping pages by mobility.
  * It is expensive to collect do not constantly read the file.
  */
@@ -555,6 +646,7 @@ static int fragavoidance_show(struct seq
 
 	fragavoidance_showfree(m, pgdat);
 	fragavoidance_showblockcount(m, pgdat);
+	fragavoidance_showmixedcount(m, pgdat);
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
