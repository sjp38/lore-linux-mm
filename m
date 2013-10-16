Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8DD6B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 06:42:35 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so653620pbc.4
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 03:42:34 -0700 (PDT)
Date: Wed, 16 Oct 2013 11:42:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: Do not walk all of system memory during show_mem
Message-ID: <20131016104228.GM11028@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

It has been reported on very large machines that show_mem is taking almost
5 minutes to display information. This is a serious problem if there is
an OOM storm. The bulk of the cost is in show_mem doing a very expensive
PFN walk to give us the following information

Total RAM:	Also available as totalram_pages
Highmem pages:	Also available as totalhigh_pages
Reserved pages:	Can be inferred from the zone structure
Shared pages:	PFN walk required
Unshared pages:	PFN walk required
Quick pages:	Per-cpu walk required

Only the shared/unshared pages requires a full PFN walk but that information
is useless. It is also inaccurate as page pins of unshared pages would
be accounted for as shared.  Even if the information was accurate, I'm
struggling to think how the shared/unshared information could be useful
for debugging OOM conditions. Maybe it was useful before rmap existed when
reclaiming shared pages was costly but it is less relevant today.

The PFN walk could be optimised a bit but why bother as the information is
useless. This patch deletes the PFN walker and infers the total RAM, highmem
and reserved pages count from struct zone. It omits the shared/unshared page
usage on the grounds that it is useless.  It also corrects the reporting
of HighMem as HighMem/MovableOnly as ZONE_MOVABLE has similar problems to
HighMem with respect to lowmem/highmem exhaustion.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 lib/show_mem.c | 39 +++++++++++----------------------------
 1 file changed, 11 insertions(+), 28 deletions(-)

diff --git a/lib/show_mem.c b/lib/show_mem.c
index b7c7231..5847a49 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -12,8 +12,7 @@
 void show_mem(unsigned int filter)
 {
 	pg_data_t *pgdat;
-	unsigned long total = 0, reserved = 0, shared = 0,
-		nonshared = 0, highmem = 0;
+	unsigned long total = 0, reserved = 0, highmem = 0;
 
 	printk("Mem-Info:\n");
 	show_free_areas(filter);
@@ -22,43 +21,27 @@ void show_mem(unsigned int filter)
 		return;
 
 	for_each_online_pgdat(pgdat) {
-		unsigned long i, flags;
+		unsigned long flags;
+		int zoneid;
 
 		pgdat_resize_lock(pgdat, &flags);
-		for (i = 0; i < pgdat->node_spanned_pages; i++) {
-			struct page *page;
-			unsigned long pfn = pgdat->node_start_pfn + i;
-
-			if (unlikely(!(i % MAX_ORDER_NR_PAGES)))
-				touch_nmi_watchdog();
-
-			if (!pfn_valid(pfn))
+		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+			struct zone *zone = &pgdat->node_zones[zoneid];
+			if (!populated_zone(zone))
 				continue;
 
-			page = pfn_to_page(pfn);
-
-			if (PageHighMem(page))
-				highmem++;
+			total += zone->present_pages;
+			reserved = zone->present_pages - zone->managed_pages;
 
-			if (PageReserved(page))
-				reserved++;
-			else if (page_count(page) == 1)
-				nonshared++;
-			else if (page_count(page) > 1)
-				shared += page_count(page) - 1;
-
-			total++;
+			if (is_highmem_idx(zoneid))
+				highmem += zone->present_pages;
 		}
 		pgdat_resize_unlock(pgdat, &flags);
 	}
 
 	printk("%lu pages RAM\n", total);
-#ifdef CONFIG_HIGHMEM
-	printk("%lu pages HighMem\n", highmem);
-#endif
+	printk("%lu pages HighMem/MovableOnly\n", highmem);
 	printk("%lu pages reserved\n", reserved);
-	printk("%lu pages shared\n", shared);
-	printk("%lu pages non-shared\n", nonshared);
 #ifdef CONFIG_QUICKLIST
 	printk("%lu pages in pagetable cache\n",
 		quicklist_total_size());

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
