Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 891C36B007D
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 05:10:25 -0400 (EDT)
Message-ID: <52020EE4.1090606@huawei.com>
Date: Wed, 7 Aug 2013 17:09:56 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] mm: use zone_end_pfn() instead of zone_start_pfn+spanned_pages
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Use "zone_end_pfn()" instead of "zone->zone_start_pfn + zone->spanned_pages".
Simplify the code, no functional change.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 kernel/power/snapshot.c |   12 ++++++------
 mm/memory_hotplug.c     |    4 ++--
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 349587b..358a146 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -352,7 +352,7 @@ static int create_mem_extents(struct list_head *list, gfp_t gfp_mask)
 		struct mem_extent *ext, *cur, *aux;
 
 		zone_start = zone->zone_start_pfn;
-		zone_end = zone->zone_start_pfn + zone->spanned_pages;
+		zone_end = zone_end_pfn(zone);
 
 		list_for_each_entry(ext, list, hook)
 			if (zone_start <= ext->end)
@@ -884,7 +884,7 @@ static unsigned int count_highmem_pages(void)
 			continue;
 
 		mark_free_pages(zone);
-		max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
+		max_zone_pfn = zone_end_pfn(zone);
 		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
 			if (saveable_highmem_page(zone, pfn))
 				n++;
@@ -948,7 +948,7 @@ static unsigned int count_data_pages(void)
 			continue;
 
 		mark_free_pages(zone);
-		max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
+		max_zone_pfn = zone_end_pfn(zone);
 		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
 			if (saveable_page(zone, pfn))
 				n++;
@@ -1041,7 +1041,7 @@ copy_data_pages(struct memory_bitmap *copy_bm, struct memory_bitmap *orig_bm)
 		unsigned long max_zone_pfn;
 
 		mark_free_pages(zone);
-		max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
+		max_zone_pfn = zone_end_pfn(zone);
 		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
 			if (page_is_saveable(zone, pfn))
 				memory_bm_set_bit(orig_bm, pfn);
@@ -1093,7 +1093,7 @@ void swsusp_free(void)
 	unsigned long pfn, max_zone_pfn;
 
 	for_each_populated_zone(zone) {
-		max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
+		max_zone_pfn = zone_end_pfn(zone);
 		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
 			if (pfn_valid(pfn)) {
 				struct page *page = pfn_to_page(pfn);
@@ -1755,7 +1755,7 @@ static int mark_unsafe_pages(struct memory_bitmap *bm)
 
 	/* Clear page flags */
 	for_each_populated_zone(zone) {
-		max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
+		max_zone_pfn = zone_end_pfn(zone);
 		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
 			if (pfn_valid(pfn))
 				swsusp_unset_page_free(pfn_to_page(pfn));
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ca1dd3a..2cd2207 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -229,7 +229,7 @@ static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
 
 	zone_span_writelock(zone);
 
-	old_zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	old_zone_end_pfn = zone_end_pfn(zone);
 	if (!zone->spanned_pages || start_pfn < zone->zone_start_pfn)
 		zone->zone_start_pfn = start_pfn;
 
@@ -515,7 +515,7 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 			     unsigned long end_pfn)
 {
 	unsigned long zone_start_pfn =  zone->zone_start_pfn;
-	unsigned long zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	unsigned long zone_end_pfn = zone_end_pfn(zone);
 	unsigned long pfn;
 	struct mem_section *ms;
 	int nid = zone_to_nid(zone);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
