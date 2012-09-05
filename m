Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id EEDE26B00AB
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:44:57 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [RFC v9 PATCH 17/21] memory_hotplug: clear zone when the memory is removed
Date: Wed, 5 Sep 2012 17:25:51 +0800
Message-Id: <1346837155-534-18-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

When a memory is added, we update zone's and pgdat's start_pfn and spanned_pages
in the function __add_zone(). So we should revert these when the memory is
removed. Add a new function __remove_zone() to do this.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/memory_hotplug.c |  207 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 207 insertions(+), 0 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c54922c..afda7e9 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -308,10 +308,213 @@ static int __meminit __add_section(int nid, struct zone *zone,
 	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
 }
 
+/* find the smallest valid pfn in the range [start_pfn, end_pfn) */
+static int find_smallest_section_pfn(int nid, struct zone *zone,
+				     unsigned long start_pfn,
+				     unsigned long end_pfn)
+{
+	struct mem_section *ms;
+
+	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
+		ms = __pfn_to_section(start_pfn);
+
+		if (unlikely(!valid_section(ms)))
+			continue;
+
+		if (unlikely(pfn_to_nid(start_pfn)) != nid)
+			continue;
+
+		if (zone && zone != page_zone(pfn_to_page(start_pfn)))
+			continue;
+
+		return start_pfn;
+	}
+
+	return 0;
+}
+
+/* find the biggest valid pfn in the range [start_pfn, end_pfn). */
+static int find_biggest_section_pfn(int nid, struct zone *zone,
+				    unsigned long start_pfn,
+				    unsigned long end_pfn)
+{
+	struct mem_section *ms;
+	unsigned long pfn;
+
+	/* pfn is the end pfn of a memory section. */
+	pfn = end_pfn - 1;
+	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION) {
+		ms = __pfn_to_section(pfn);
+
+		if (unlikely(!valid_section(ms)))
+			continue;
+
+		if (unlikely(pfn_to_nid(pfn)) != nid)
+			continue;
+
+		if (zone && zone != page_zone(pfn_to_page(pfn)))
+			continue;
+
+		return pfn;
+	}
+
+	return 0;
+}
+
+static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
+			     unsigned long end_pfn)
+{
+	unsigned long zone_start_pfn =  zone->zone_start_pfn;
+	unsigned long zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	unsigned long pfn;
+	struct mem_section *ms;
+	int nid = zone_to_nid(zone);
+
+	zone_span_writelock(zone);
+	if (zone_start_pfn == start_pfn) {
+		/*
+		 * If the section is smallest section in the zone, it need
+		 * shrink zone->zone_start_pfn and zone->zone_spanned_pages.
+		 * In this case, we find second smallest valid mem_section
+		 * for shrinking zone.
+		 */
+		pfn = find_smallest_section_pfn(nid, zone, end_pfn,
+						zone_end_pfn);
+		if (pfn) {
+			zone->zone_start_pfn = pfn;
+			zone->spanned_pages = zone_end_pfn - pfn;
+		}
+	} else if (zone_end_pfn == end_pfn) {
+		/*
+		 * If the section is biggest section in the zone, it need
+		 * shrink zone->spanned_pages.
+		 * In this case, we find second biggest valid mem_section for
+		 * shrinking zone.
+		 */
+		pfn = find_biggest_section_pfn(nid, zone, zone_start_pfn,
+					       start_pfn);
+		if (pfn)
+			zone->spanned_pages = pfn - zone_start_pfn + 1;
+	}
+
+	/*
+	 * The section is not biggest or smallest mem_section in the zone, it
+	 * only creates a hole in the zone. So in this case, we need not
+	 * change the zone. But perhaps, the zone has only hole data. Thus
+	 * it check the zone has only hole or not.
+	 */
+	pfn = zone_start_pfn;
+	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
+		ms = __pfn_to_section(pfn);
+
+		if (unlikely(!valid_section(ms)))
+			continue;
+
+		if (page_zone(pfn_to_page(pfn)) != zone)
+			continue;
+
+		 /* If the section is current section, it continues the loop */
+		if (start_pfn == pfn)
+			continue;
+
+		/* If we find valid section, we have nothing to do */
+		zone_span_writeunlock(zone);
+		return;
+	}
+
+	/* The zone has no valid section */
+	zone->zone_start_pfn = 0;
+	zone->spanned_pages = 0;
+	zone_span_writeunlock(zone);
+}
+
+static void shrink_pgdat_span(struct pglist_data *pgdat,
+			      unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pgdat_start_pfn =  pgdat->node_start_pfn;
+	unsigned long pgdat_end_pfn =
+		pgdat->node_start_pfn + pgdat->node_spanned_pages;
+	unsigned long pfn;
+	struct mem_section *ms;
+	int nid = pgdat->node_id;
+
+	if (pgdat_start_pfn == start_pfn) {
+		/*
+		 * If the section is smallest section in the pgdat, it need
+		 * shrink pgdat->node_start_pfn and pgdat->node_spanned_pages.
+		 * In this case, we find second smallest valid mem_section
+		 * for shrinking zone.
+		 */
+		pfn = find_smallest_section_pfn(nid, NULL, end_pfn,
+						pgdat_end_pfn);
+		if (pfn) {
+			pgdat->node_start_pfn = pfn;
+			pgdat->node_spanned_pages = pgdat_end_pfn - pfn;
+		}
+	} else if (pgdat_end_pfn == end_pfn) {
+		/*
+		 * If the section is biggest section in the pgdat, it need
+		 * shrink pgdat->node_spanned_pages.
+		 * In this case, we find second biggest valid mem_section for
+		 * shrinking zone.
+		 */
+		pfn = find_biggest_section_pfn(nid, NULL, pgdat_start_pfn,
+					       start_pfn);
+		if (pfn)
+			pgdat->node_spanned_pages = pfn - pgdat_start_pfn + 1;
+	}
+
+	/*
+	 * If the section is not biggest or smallest mem_section in the pgdat,
+	 * it only creates a hole in the pgdat. So in this case, we need not
+	 * change the pgdat.
+	 * But perhaps, the pgdat has only hole data. Thus it check the pgdat
+	 * has only hole or not.
+	 */
+	pfn = pgdat_start_pfn;
+	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SECTION) {
+		ms = __pfn_to_section(pfn);
+
+		if (unlikely(!valid_section(ms)))
+			continue;
+
+		if (pfn_to_nid(pfn) != nid)
+			continue;
+
+		 /* If the section is current section, it continues the loop */
+		if (start_pfn == pfn)
+			continue;
+
+		/* If we find valid section, we have nothing to do */
+		return;
+	}
+
+	/* The pgdat has no valid section */
+	pgdat->node_start_pfn = 0;
+	pgdat->node_spanned_pages = 0;
+}
+
+static void __remove_zone(struct zone *zone, unsigned long start_pfn)
+{
+	struct pglist_data *pgdat = zone->zone_pgdat;
+	int nr_pages = PAGES_PER_SECTION;
+	int zone_type;
+	unsigned long flags;
+
+	zone_type = zone - pgdat->node_zones;
+
+	pgdat_resize_lock(zone->zone_pgdat, &flags);
+	shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
+	shrink_pgdat_span(pgdat, start_pfn, start_pfn + nr_pages);
+	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+}
+
 static int __remove_section(struct zone *zone, struct mem_section *ms)
 {
 	unsigned long flags;
 	struct pglist_data *pgdat = zone->zone_pgdat;
+	unsigned long start_pfn;
+	int scn_nr;
 	int ret = -EINVAL;
 
 	if (!valid_section(ms))
@@ -321,6 +524,10 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
 	if (ret)
 		return ret;
 
+	scn_nr = __section_nr(ms);
+	start_pfn = section_nr_to_pfn(scn_nr);
+	__remove_zone(zone, start_pfn);
+
 	pgdat_resize_lock(pgdat, &flags);
 	sparse_remove_one_section(zone, ms);
 	pgdat_resize_unlock(pgdat, &flags);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
