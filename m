Date: Thu, 25 Jul 2002 18:10:59 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [RFC] start_aggressive_readahead
Message-ID: <20020725181059.A25857@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Another patch from the XFS tree, I'd be happy to get some comments on
this one again.

This function (start_aggressive_readahead()) checks whether all zones
of the given gfp mask have lots of free pages.  XFS needs this for it's
own readahead code (used only deep in the directory code, normal file
readahead is handled by the generic pagecache code).  We perform the
readahead only is it returns 1 for enough free pages.

We could rip it out of XFS entirely without funcionality-loss, but it
would cost directory handling performance.

I'm also open for a better name (I think the current one is very bad,
but don't have a better idea :)).  I'd also be ineterested in comments
how to avoid the new function and use existing functionality for it,
but I've tried to find it for a long time and didn't find something
suiteable.

-- 
The US Army issues lap-top computers now to squad-leaders on up. [...]
Believe me, there is nothing more lethal than a Power Point briefing
given by an Army person.	-- Leon A. Goldstein

--- linux/include/linux/mm.h Wed, 29 May 2002 14:00:22
+++ linux/include/linux/mm.h Mon, 22 Jul 2002 12:06:09
@@ -460,6 +460,8 @@ extern void FASTCALL(free_pages(unsigned
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr),0)
 
+extern int start_aggressive_readahead(int);
+
 extern void show_free_areas(void);
 extern void show_free_areas_node(pg_data_t *pgdat);
 
--- linux/kernel/ksyms.c Wed, 17 Jul 2002 12:08:06
+++ linux/kernel/ksyms.c Mon, 22 Jul 2002 12:06:09
@@ -90,6 +90,7 @@ EXPORT_SYMBOL(exit_fs);
 EXPORT_SYMBOL(exit_sighand);
 
 /* internal kernel memory management */
+EXPORT_SYMBOL(start_aggressive_readahead);
 EXPORT_SYMBOL(_alloc_pages);
 EXPORT_SYMBOL(__alloc_pages);
 EXPORT_SYMBOL(alloc_pages_node);
--- linux/mm/page_alloc.c Tue, 25 Jun 2002 10:15:12 
+++ linux/mm/page_alloc.c Mon, 22 Jul 2002 12:06:09
@@ -512,6 +512,37 @@ unsigned int nr_free_highpages (void)
 #define K(x) ((x) << (PAGE_SHIFT-10))
 
 /*
+ * If it returns non zero it means there's lots of ram "free"
+ * (note: not in cache!) so any caller will know that
+ * he can allocate some memory to do some more aggressive
+ * (possibly wasteful) readahead. The state of the memory
+ * should be rechecked after every few pages allocated for
+ * doing this aggressive readahead.
+ *
+ * NOTE: caller passes in gfp_mask of zones to check
+ */
+int start_aggressive_readahead(int gfp_mask)
+{
+	pg_data_t *pgdat = pgdat_list;
+	zonelist_t *zonelist;
+	zone_t **zonep, *zone;
+	int ret = 0;
+
+	do {
+		zonelist = pgdat->node_zonelists + (gfp_mask & GFP_ZONEMASK);
+		zonep = zonelist->zones;
+
+		for (zone = *zonep++; zone; zone = *zonep++)
+			if (zone->free_pages > zone->pages_high * 2)
+				ret = 1;
+
+		pgdat = pgdat->node_next;
+	} while (pgdat);
+
+	return ret;
+}
+
+/*
  * Show free area list (used inside shift_scroll-lock stuff)
  * We also calculate the percentage fragmentation. We do this by counting the
  * memory on each free list with the exception of the first item on the list.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
