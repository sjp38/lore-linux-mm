Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7603E6B000C
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 09:38:24 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id j6-v6so13774783wrr.15
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 06:38:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b139-v6sor400451wmd.16.2018.08.07.06.38.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 06:38:23 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [RFC PATCH 3/3] mm/memory_hotplug: Refactor shrink_zone/pgdat_span
Date: Tue,  7 Aug 2018 15:37:57 +0200
Message-Id: <20180807133757.18352-4-osalvador@techadventures.net>
In-Reply-To: <20180807133757.18352-1-osalvador@techadventures.net>
References: <20180807133757.18352-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@oracle.com, jglisse@redhat.com, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patch refactors shrink_zone_span and shrink_pgdat_span functions.

In case that find_smallest/biggest_section do not return any pfn,
it means that the zone/pgdat has no online sections left, so we can
set the respective values to 0:

   zone case:
        zone->zone_start_pfn = 0;
        zone->spanned_pages = 0;

   pgdat case:
        pgdat->node_start_pfn = 0;
        pgdat->node_spanned_pages = 0;

Also, the check that loops over all sections to see if we have something left
is moved to an own function, and so the code can be shared by shrink_zone_span
and shrink_pgdat_span.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 127 +++++++++++++++++++++++++++-------------------------
 1 file changed, 65 insertions(+), 62 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e33555651e46..ccac36eaac05 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -365,6 +365,29 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
 	return 0;
 }
 
+static bool has_only_holes(struct zone *zone, int nid, unsigned long zone_start_pfn,
+							unsigned long zone_end_pfn)
+{
+	unsigned long pfn;
+
+	pfn = zone_start_pfn;
+	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
+		struct mem_section *ms = __pfn_to_section(pfn);
+
+		if (unlikely(!online_section(ms)))
+			continue;
+		if (zone && page_zone(pfn_to_page(pfn)) != zone)
+			continue;
+
+		if (pfn_to_nid(pfn) != nid)
+			continue;
+
+		return false;
+	}
+
+	return true;
+}
+
 static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 			     unsigned long end_pfn)
 {
@@ -372,7 +395,6 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	unsigned long z = zone_end_pfn(zone); /* zone_end_pfn namespace clash */
 	unsigned long zone_end_pfn = z;
 	unsigned long pfn;
-	struct mem_section *ms;
 	int nid = zone_to_nid(zone);
 
 	zone_span_writelock(zone);
@@ -385,10 +407,11 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 		 */
 		pfn = find_smallest_section_pfn(nid, zone, end_pfn,
 						zone_end_pfn);
-		if (pfn) {
-			zone->zone_start_pfn = pfn;
-			zone->spanned_pages = zone_end_pfn - pfn;
-		}
+		if (!pfn)
+			goto only_holes;
+
+		zone->zone_start_pfn = pfn;
+		zone->spanned_pages = zone_end_pfn - pfn;
 	} else if (zone_end_pfn == end_pfn) {
 		/*
 		 * If the section is biggest section in the zone, it need
@@ -398,38 +421,28 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 		 */
 		pfn = find_biggest_section_pfn(nid, zone, zone_start_pfn,
 					       start_pfn);
-		if (pfn)
-			zone->spanned_pages = pfn - zone_start_pfn + 1;
-	}
-
-	/*
-	 * The section is not biggest or smallest mem_section in the zone, it
-	 * only creates a hole in the zone. So in this case, we need not
-	 * change the zone. But perhaps, the zone has only hole data. Thus
-	 * it check the zone has only hole or not.
-	 */
-	pfn = zone_start_pfn;
-	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(pfn);
-
-		if (unlikely(!online_section(ms)))
-			continue;
+		if (!pfn)
+			goto only_holes;
 
-		if (page_zone(pfn_to_page(pfn)) != zone)
-			continue;
-
-		 /* If the section is current section, it continues the loop */
-		if (start_pfn == pfn)
-			continue;
-
-		/* If we find valid section, we have nothing to do */
-		zone_span_writeunlock(zone);
-		return;
+		zone->spanned_pages = pfn - zone_start_pfn + 1;
+	} else {
+		/*
+		 * The section is not biggest or smallest mem_section in the zone, it
+		 * only creates a hole in the zone. So in this case, we need not
+		 * change the zone. But perhaps, the zone has only hole data. Thus
+		 * it check the zone has only hole or not.
+		 */
+		if (has_only_holes(zone, nid, zone_start_pfn, zone_end_pfn))
+			goto only_holes;
 	}
 
+	goto out;
+
+only_holes:
 	/* The zone has no valid section */
 	zone->zone_start_pfn = 0;
 	zone->spanned_pages = 0;
+out:
 	zone_span_writeunlock(zone);
 }
 
@@ -440,7 +453,6 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	unsigned long p = pgdat_end_pfn(pgdat); /* pgdat_end_pfn namespace clash */
 	unsigned long pgdat_end_pfn = p;
 	unsigned long pfn;
-	struct mem_section *ms;
 	int nid = pgdat->node_id;
 
 	if (pgdat_start_pfn == start_pfn) {
@@ -452,10 +464,11 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 		 */
 		pfn = find_smallest_section_pfn(nid, NULL, end_pfn,
 						pgdat_end_pfn);
-		if (pfn) {
-			pgdat->node_start_pfn = pfn;
-			pgdat->node_spanned_pages = pgdat_end_pfn - pfn;
-		}
+		if (!pfn)
+			goto only_holes;
+
+		pgdat->node_start_pfn = pfn;
+		pgdat->node_spanned_pages = pgdat_end_pfn - pfn;
 	} else if (pgdat_end_pfn == end_pfn) {
 		/*
 		 * If the section is biggest section in the pgdat, it need
@@ -465,35 +478,25 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 		 */
 		pfn = find_biggest_section_pfn(nid, NULL, pgdat_start_pfn,
 					       start_pfn);
-		if (pfn)
-			pgdat->node_spanned_pages = pfn - pgdat_start_pfn + 1;
-	}
-
-	/*
-	 * If the section is not biggest or smallest mem_section in the pgdat,
-	 * it only creates a hole in the pgdat. So in this case, we need not
-	 * change the pgdat.
-	 * But perhaps, the pgdat has only hole data. Thus it check the pgdat
-	 * has only hole or not.
-	 */
-	pfn = pgdat_start_pfn;
-	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(pfn);
-
-		if (unlikely(!online_section(ms)))
-			continue;
-
-		if (pfn_to_nid(pfn) != nid)
-			continue;
+		if (!pfn)
+			goto only_holes;
 
-		 /* If the section is current section, it continues the loop */
-		if (start_pfn == pfn)
-			continue;
-
-		/* If we find valid section, we have nothing to do */
-		return;
+		pgdat->node_spanned_pages = pfn - pgdat_start_pfn + 1;
+	} else {
+		/*
+		 * If the section is not biggest or smallest mem_section in the pgdat,
+		 * it only creates a hole in the pgdat. So in this case, we need not
+		 * change the pgdat.
+		 * But perhaps, the pgdat has only hole data. Thus it check the pgdat
+		 * has only hole or not.
+		 */
+		if (has_only_holes(NULL, nid, pgdat_start_pfn, pgdat_end_pfn))
+			goto only_holes;
 	}
 
+	return;
+
+only_holes:
 	/* The pgdat has no valid section */
 	pgdat->node_start_pfn = 0;
 	pgdat->node_spanned_pages = 0;
-- 
2.13.6
