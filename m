Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id A559B6B0072
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:57 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 19:25:56 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 191ABC90046
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:54 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0PrTR338022
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:53 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0PrpA020142
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 22:25:53 -0200
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 14/17] mm/memory_hotplug: factor out zone+pgdat growth.
Date: Tue, 15 Jan 2013 16:24:51 -0800
Message-Id: <1358295894-24167-15-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Create a new function grow_pgdat_and_zone() which handles locking +
growth of a zone & the pgdat which it is associated with.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0a74b86a..c6149a3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -361,6 +361,16 @@ static void grow_pgdat_span(struct pglist_data *pgdat, unsigned long start_pfn,
 					pgdat->node_start_pfn;
 }
 
+static void grow_pgdat_and_zone(struct zone *zone, unsigned long start_pfn,
+		unsigned long end_pfn)
+{
+	unsigned long flags;
+	pgdat_resize_lock(zone->zone_pgdat, &flags);
+	grow_zone_span(zone, start_pfn, end_pfn);
+	grow_pgdat_span(zone->zone_pgdat, start_pfn, end_pfn);
+	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+}
+
 static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
@@ -375,11 +385,7 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 	if (ret)
 		return ret;
 
-	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	grow_zone_span(zone, phys_start_pfn, phys_start_pfn + nr_pages);
-	grow_pgdat_span(zone->zone_pgdat, phys_start_pfn,
-			phys_start_pfn + nr_pages);
-	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+	grow_pgdat_and_zone(zone, phys_start_pfn, phys_start_pfn + nr_pages);
 	memmap_init_zone(nr_pages, nid, zone_type,
 			 phys_start_pfn, MEMMAP_HOTPLUG);
 	return 0;
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
