Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8475F6B48F5
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:20:43 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 75so12143503pfq.8
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:20:43 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id h19si4399825plr.67.2018.11.27.08.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 08:20:41 -0800 (PST)
From: Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 5/5] mm, memory_hotplug: Refactor shrink_zone/pgdat_span
Date: Tue, 27 Nov 2018 17:20:05 +0100
Message-Id: <20181127162005.15833-6-osalvador@suse.de>
In-Reply-To: <20181127162005.15833-1-osalvador@suse.de>
References: <20181127162005.15833-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.com>

shrink_zone_span and shrink_pgdat_span look a bit weird.

They both have a loop at the end to check if the zone
or pgdat contains only holes in case the section to be removed
was not either the first one or the last one.

Both code loops look quite similar, so we can simplify it a bit.
We do that by creating a function (has_only_holes), that basically
calls find_smallest_section_pfn() with the full range.
In case nothing has to be found, we do not have any more sections
there.

To be honest, I am not really sure we even need to go through this
check in case we are removing a middle section, because from what I can see,
we will always have a first/last section.

Taking the chance, we could also simplify both find_smallest_section_pfn()
and find_biggest_section_pfn() functions and move the common code
to a helper.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 163 +++++++++++++++++++++-------------------------------
 1 file changed, 64 insertions(+), 99 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 49b91907e19e..0e3f89423153 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -325,28 +325,29 @@ static bool is_section_ok(struct mem_section *ms, bool zone)
 	else
 		return valid_section(ms);
 }
+
+static bool is_valid_section(struct zone *zone, int nid, unsigned long pfn)
+{
+	struct mem_section *ms = __pfn_to_section(pfn);
+
+	if (unlikely(!is_section_ok(ms, !!zone)))
+		return false;
+	if (unlikely(pfn_to_nid(pfn) != nid))
+		return false;
+	if (zone && zone != page_zone(pfn_to_page(pfn)))
+		return false;
+
+	return true;
+}
+
 /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
 static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 				     unsigned long start_pfn,
 				     unsigned long end_pfn)
 {
-	struct mem_section *ms;
-
-	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(start_pfn);
-
-		if (!is_section_ok(ms, !!zone))
-			continue;
-
-		if (unlikely(pfn_to_nid(start_pfn) != nid))
-			continue;
-
-		if (zone && zone != page_zone(pfn_to_page(start_pfn)))
-			continue;
-
-		return start_pfn;
-	}
-
+	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION)
+		if (is_valid_section(zone, nid, start_pfn))
+			return start_pfn;
 	return 0;
 }
 
@@ -355,29 +356,26 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
 				    unsigned long start_pfn,
 				    unsigned long end_pfn)
 {
-	struct mem_section *ms;
 	unsigned long pfn;
 
 	/* pfn is the end pfn of a memory section. */
 	pfn = end_pfn - 1;
-	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION) {
-		ms = __pfn_to_section(pfn);
-
-		if (!is_section_ok(ms, !!zone))
-			continue;
-
-		if (unlikely(pfn_to_nid(pfn) != nid))
-			continue;
-
-		if (zone && zone != page_zone(pfn_to_page(pfn)))
-			continue;
-
-		return pfn;
-	}
-
+	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION)
+		if (is_valid_section(zone, nid, pfn))
+			return pfn;
 	return 0;
 }
 
+static bool has_only_holes(int nid, struct zone *zone,
+				unsigned long start_pfn,
+				unsigned long end_pfn)
+{
+	/*
+	 * Let us check if the range has only holes
+	 */
+	return !find_smallest_section_pfn(nid, zone, start_pfn, end_pfn);
+}
+
 static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 			     unsigned long end_pfn)
 {
@@ -385,7 +383,6 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	unsigned long z = zone_end_pfn(zone); /* zone_end_pfn namespace clash */
 	unsigned long zone_end_pfn = z;
 	unsigned long pfn;
-	struct mem_section *ms;
 	int nid = zone_to_nid(zone);
 
 	zone_span_writelock(zone);
@@ -397,11 +394,12 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 		 * for shrinking zone.
 		 */
 		pfn = find_smallest_section_pfn(nid, zone, end_pfn,
-						zone_end_pfn);
-		if (pfn) {
-			zone->zone_start_pfn = pfn;
-			zone->spanned_pages = zone_end_pfn - pfn;
-		}
+							zone_end_pfn);
+		if (!pfn)
+			goto no_sections;
+
+		zone->zone_start_pfn = pfn;
+		zone->spanned_pages = zone_end_pfn - pfn;
 	} else if (zone_end_pfn == end_pfn) {
 		/*
 		 * If the section is biggest section in the zone, it need
@@ -410,39 +408,23 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 		 * shrinking zone.
 		 */
 		pfn = find_biggest_section_pfn(nid, zone, zone_start_pfn,
-					       start_pfn);
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
+								start_pfn);
+		if (!pfn)
+			goto no_sections;
 
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
+		if (has_only_holes(nid, zone, zone_start_pfn, zone_end_pfn))
+			goto no_sections;
 	}
 
+	goto out;
+
+no_sections:
 	/* The zone has no valid section */
 	zone->zone_start_pfn = 0;
 	zone->spanned_pages = 0;
+out:
 	zone_span_writeunlock(zone);
 }
 
@@ -453,7 +435,6 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	unsigned long p = pgdat_end_pfn(pgdat); /* pgdat_end_pfn namespace clash */
 	unsigned long pgdat_end_pfn = p;
 	unsigned long pfn;
-	struct mem_section *ms;
 	int nid = pgdat->node_id;
 
 	if (pgdat_start_pfn == start_pfn) {
@@ -465,10 +446,11 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 		 */
 		pfn = find_smallest_section_pfn(nid, NULL, end_pfn,
 						pgdat_end_pfn);
-		if (pfn) {
-			pgdat->node_start_pfn = pfn;
-			pgdat->node_spanned_pages = pgdat_end_pfn - pfn;
-		}
+		if (!pfn)
+			goto no_sections;
+
+		pgdat->node_start_pfn = pfn;
+		pgdat->node_spanned_pages = pgdat_end_pfn - pfn;
 	} else if (pgdat_end_pfn == end_pfn) {
 		/*
 		 * If the section is biggest section in the pgdat, it need
@@ -478,35 +460,18 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
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
-		if (unlikely(!valid_section(ms)))
-			continue;
-
-		if (pfn_to_nid(pfn) != nid)
-			continue;
+		if (!pfn)
+			goto no_sections;
 
-		 /* If the section is current section, it continues the loop */
-		if (start_pfn == pfn)
-			continue;
-
-		/* If we find valid section, we have nothing to do */
-		return;
+		pgdat->node_spanned_pages = pfn - pgdat_start_pfn + 1;
+	} else {
+		if (has_only_holes(nid, NULL, pgdat_start_pfn, pgdat_end_pfn))
+			goto no_sections;
 	}
 
+	return;
+
+no_sections:
 	/* The pgdat has no valid section */
 	pgdat->node_start_pfn = 0;
 	pgdat->node_spanned_pages = 0;
@@ -540,6 +505,7 @@ static int __remove_section(int nid, struct mem_section *ms,
 		unsigned long map_offset, struct vmem_altmap *altmap)
 {
 	int ret = -EINVAL;
+	int sect_nr = __section_nr(ms);
 
 	if (!valid_section(ms))
 		return ret;
@@ -548,9 +514,8 @@ static int __remove_section(int nid, struct mem_section *ms,
 	if (ret)
 		return ret;
 
-	shrink_pgdat(nid, __section_nr(ms));
-
 	sparse_remove_one_section(nid, ms, map_offset, altmap);
+	shrink_pgdat(nid, (unsigned long)sect_nr);
 	return 0;
 }
 
-- 
2.13.6
