Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4DG0U0c576014
	for <linux-mm@kvack.org>; Fri, 13 May 2005 12:00:31 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4DG0ULY190666
	for <linux-mm@kvack.org>; Fri, 13 May 2005 10:00:30 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4DG0U9Q030324
	for <linux-mm@kvack.org>; Fri, 13 May 2005 10:00:30 -0600
Subject: [RFC] consistency of zone->zone_start_pfn, spanned_pages
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: text/plain
Date: Fri, 13 May 2005 09:00:19 -0700
Message-Id: <1116000019.32433.10.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms <lhms-devel@lists.sourceforge.net>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The zone struct has a few important members which explicitly define the
range of pages that it manages: zone_start_pfn and spanned_pages.

The current memory hotplug coded has concentrated on appending memory to
existing zones, which means just increasing spanned_pages.  There is
currently no code that breaks at runtime if this value is simply
incremented.

However, some cases exist where memory will be added to the beginning
(or before) an existing zone.  That means that zone_start_pfn will need
to change.  Now, consider what happens if this code: 

        static int bad_range(struct zone *zone, struct page *page)
        {
                if (page_to_pfn(page) >= 
                    zone->zone_start_pfn + zone->spanned_pages)
                        return 1;
        ...

is run while zone_start_pfn is being decremented, but before
zone->spanned_pages has been incremented.

bad_range() has four callers: __free_pages_bulk()x2, expand() and
buffered_rmqueue().  Of these, all but buffered_rmqueue() do the
bad_range() call under zone->lock.

So, one idea I had was to move just the spanned_pages part of
bad_range() under the zone->lock and hold the lock during just the part
of a hotplug operation where the resize occurs (patch appended).  This
will, however, increase lock hold times.  I'm currently running
performance tests to see if I can detect this.

Another idea I had was to use memory barriers.  But, that's quite a bit
more complex than a single lock, and I think it has the potential to be
even more expensive.

Perhaps a seq_lock which is conditional on memory hotplug?

Any other ideas?

-- Dave


When doing memory hotplug operations, the size of existing zones can
obviously change.  This means that zone->zone_{start_pfn,spanned_pages}
can change.

There are currently no locks that protect these structure members.
However, they are rarely accessed at runtime.  Outside of swsusp, the
only place that I can find is bad_range().

bad_range() has four callers: __free_pages_bulk()x2, expand() and
buffered_rmqueue().  Of these, all but buffered_rmqueue() do the
bad_range() call under zone->lock.



---

 memhotplug-dave/mm/page_alloc.c |   30 ++++++++++++++++++++++++++----
 1 files changed, 26 insertions(+), 4 deletions(-)

diff -puN mm/page_alloc.c~bad_range-rework mm/page_alloc.c
--- memhotplug/mm/page_alloc.c~bad_range-rework	2005-05-12 15:36:04.000000000 -0700
+++ memhotplug-dave/mm/page_alloc.c	2005-05-12 16:07:07.000000000 -0700
@@ -76,20 +76,40 @@ unsigned long __initdata nr_kernel_pages
 unsigned long __initdata nr_all_pages;
 
 /*
- * Temporary debugging check for pages not lying within a given zone.
+ * Due to memory hotplug, this function needs to be called
+ * under zone->lock.
  */
-static int bad_range(struct zone *zone, struct page *page)
+static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
 	if (page_to_pfn(page) >= zone->zone_start_pfn + zone->spanned_pages)
 		return 1;
 	if (page_to_pfn(page) < zone->zone_start_pfn)
 		return 1;
+
+	return 0;
+}
+
+static int page_is_consistent(struct zone *zone, struct page *page)
+{
 #ifdef CONFIG_HOLES_IN_ZONE
 	if (!pfn_valid(page_to_pfn(page)))
-		return 1;
+		return 0;
 #endif
 	if (zone != page_zone(page))
+		return 0;
+
+	return 1;
+}
+/*
+ * Temporary debugging check for pages not lying within a given zone.
+ */
+static int bad_range(struct zone *zone, struct page *page)
+{
+	if (page_outside_zone_boundaries(zone, page))
 		return 1;
+	if (!page_is_consistent(zone, page))
+		return 1;
+
 	return 0;
 }
 
@@ -502,6 +522,7 @@ static int rmqueue_bulk(struct zone *zon
 		page = __rmqueue(zone, order);
 		if (page == NULL)
 			break;
+		BUG_ON(page_outside_zone_boundaries(zone, page));
 		allocated++;
 		list_add_tail(&page->lru, list);
 	}
@@ -674,11 +695,12 @@ buffered_rmqueue(struct zone *zone, int 
 	if (page == NULL) {
 		spin_lock_irqsave(&zone->lock, flags);
 		page = __rmqueue(zone, order);
+		BUG_ON(page && page_outside_zone_boundaries(zone, page));
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 
 	if (page != NULL) {
-		BUG_ON(bad_range(zone, page));
+		BUG_ON(!page_is_consistent(zone, page));
 		mod_page_state_zone(zone, pgalloc, 1 << order);
 		prep_new_page(page, order);
 
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
