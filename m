Date: Fri, 26 Oct 2007 15:47:19 +0100
Subject: Re: [PATCH] Add "removable" to /sysfs to show memblock removability
Message-ID: <20071026144718.GA14881@skynet.ie>
References: <1193351756.9894.30.camel@dyn9047017100.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1193351756.9894.30.camel@dyn9047017100.beaverton.ibm.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (25/10/07 15:35), Badari Pulavarty didst pronounce:
> Hi Dave & Mel,
> 
> Here is the new version of the patch with your suggestion. 
> Dave, does this suite your taste ? Mel, Can you handle the 
> corner case you mentioned earlier ?
> 

What I had in mind is below. I didn't spit the patch in two as it's both
trivial and I would expect it to be folded into your second patch.

----

A pageblock that is entirely free may be removed regardless of the
pageblock type. Similarly, a pageblock that starts with a reserved page
will not be removable no matter what the pageblock type is. Detect these
two situations when reporting whether a section may be removed or not.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

---
 page_alloc.c |   43 ++++++++++++++++++++++++++++++++++++-------
 1 file changed, 36 insertions(+), 7 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-002_add_removable/mm/page_alloc.c linux-2.6.23-rc8-mm2-005_detect_free/mm/page_alloc.c
--- linux-2.6.23-rc8-mm2-002_add_removable/mm/page_alloc.c	2007-10-26 11:05:47.000000000 +0100
+++ linux-2.6.23-rc8-mm2-005_detect_free/mm/page_alloc.c	2007-10-26 15:29:39.000000000 +0100
@@ -4600,30 +4600,59 @@ out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
+/* Returns true if the pageblock contains only free pages */
+static inline int pageblock_free(struct page *page)
+{
+	return PageBuddy(page) && page_order(page) >= pageblock_order;
+}
+
+/* Move to the next pageblock that is in use */
+static inline struct page *next_active_pageblock(struct page *page)
+{
+	/* Moving forward by at least 1 * pageblock_nr_pages */
+	int order = 1;
+
+	/* If the entire pageblock is free, move to the end of free page */
+	if (pageblock_free(page) && page_order(page) > pageblock_order)
+		order += page_order(page) - pageblock_order;
+
+	return page + (order * pageblock_nr_pages);
+}
+
 /*
  * Find out if this section of the memory is removable.
  */
 int
 is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
-	int type, i = 0;
-	struct page *page;
+	int type;
+	struct page *page, *end_page;
 
 	/*
 	 * Check all pageblocks in the section to ensure they are all
 	 * removable.
 	 */
 	page = pfn_to_page(start_pfn);
-	while (i < nr_pages) {
-		type = get_pageblock_migratetype(page + i);
+	end_page = page + nr_pages;
+
+	for (; page < end_page; page = next_active_pageblock(page)) {
+		type = get_pageblock_migratetype(page);
 
 		/*
-		 * For now, we can remove sections with only MOVABLE pages.
+		 * For now, we can remove sections with only MOVABLE pages
+		 * or contain free pages
 		 */
-		if (type != MIGRATE_MOVABLE)
+		if (type != MIGRATE_MOVABLE && !pageblock_free(page))
+			return 0;
+
+		/*
+		 * Check if the first page is reserved, this can happen
+		 * for bootmem reserved pages pageblocks
+		 */
+		if (PageReserved(page))
 			return 0;
-		i += pageblock_nr_pages;
 	}
+
 	return 1;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
