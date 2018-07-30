Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDB36B000D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 09:37:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f11-v6so8001773wmc.3
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 06:37:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l17-v6sor1447299wmd.84.2018.07.30.06.37.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 06:37:32 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH] mm: Remove zone_id() and make use of zone_idx() in is_dev_zone()
Date: Mon, 30 Jul 2018 15:37:18 +0200
Message-Id: <20180730133718.28683-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, sfr@canb.auug.org.au, rientjes@google.com, pasha.tatashin@oracle.com, kemi.wang@intel.com, jia.he@hxt-semitech.com, ptesarik@suse.com, aryabinin@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

is_dev_zone() is using zone_id() to check if the zone is ZONE_DEVICE.
zone_id() looks pretty much the same as zone_idx(), and while the use of
zone_idx() is quite spread in the kernel, zone_id() is only being
used by is_dev_zone().

This patch removes zone_id() and makes is_dev_zone() use zone_idx()
to check the zone, so we do not have two things with the same
functionality around.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 include/linux/mmzone.h | 31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 83b1d11e90eb..dbe7635c33dd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -755,25 +755,6 @@ static inline bool pgdat_is_empty(pg_data_t *pgdat)
 	return !pgdat->node_start_pfn && !pgdat->node_spanned_pages;
 }
 
-static inline int zone_id(const struct zone *zone)
-{
-	struct pglist_data *pgdat = zone->zone_pgdat;
-
-	return zone - pgdat->node_zones;
-}
-
-#ifdef CONFIG_ZONE_DEVICE
-static inline bool is_dev_zone(const struct zone *zone)
-{
-	return zone_id(zone) == ZONE_DEVICE;
-}
-#else
-static inline bool is_dev_zone(const struct zone *zone)
-{
-	return false;
-}
-#endif
-
 #include <linux/memory_hotplug.h>
 
 void build_all_zonelists(pg_data_t *pgdat);
@@ -824,6 +805,18 @@ static inline int local_memory_node(int node_id) { return node_id; };
  */
 #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
 
+#ifdef CONFIG_ZONE_DEVICE
+static inline bool is_dev_zone(const struct zone *zone)
+{
+	return zone_idx(zone) == ZONE_DEVICE;
+}
+#else
+static inline bool is_dev_zone(const struct zone *zone)
+{
+	return false;
+}
+#endif
+
 /*
  * Returns true if a zone has pages managed by the buddy allocator.
  * All the reclaim decisions have to use this function rather than
-- 
2.13.6
