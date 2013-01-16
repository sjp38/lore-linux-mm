Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 09FBA6B0078
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:26:00 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 19:26:00 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 2E5206E8040
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:40 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0PfNC186752
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:41 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0PeBl031831
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 22:25:40 -0200
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 05/17] mm/memory_hotplug: use ensure_zone_is_initialized()
Date: Tue, 15 Jan 2013 16:24:42 -0800
Message-Id: <1358295894-24167-6-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Remove open coding of ensure_zone_is_initialzied().

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 29 ++++++++++-------------------
 1 file changed, 10 insertions(+), 19 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 875bdfe..8e352fe 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -271,12 +271,9 @@ static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
 	unsigned long flags;
 	unsigned long z1_start_pfn;
 
-	if (!z1->wait_table) {
-		ret = init_currently_empty_zone(z1, start_pfn,
-			end_pfn - start_pfn, MEMMAP_HOTPLUG);
-		if (ret)
-			return ret;
-	}
+	ret = ensure_zone_is_initialized(z1, start_pfn, end_pfn - start_pfn);
+	if (ret)
+		return ret;
 
 	pgdat_resize_lock(z1->zone_pgdat, &flags);
 
@@ -316,12 +313,9 @@ static int __meminit move_pfn_range_right(struct zone *z1, struct zone *z2,
 	unsigned long flags;
 	unsigned long z2_end_pfn;
 
-	if (!z2->wait_table) {
-		ret = init_currently_empty_zone(z2, start_pfn,
-			end_pfn - start_pfn, MEMMAP_HOTPLUG);
-		if (ret)
-			return ret;
-	}
+	ret = ensure_zone_is_initialized(z2, start_pfn, end_pfn - start_pfn)
+	if (ret)
+		return ret;
 
 	pgdat_resize_lock(z1->zone_pgdat, &flags);
 
@@ -374,16 +368,13 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 	int nid = pgdat->node_id;
 	int zone_type;
 	unsigned long flags;
+	int ret;
 
 	zone_type = zone - pgdat->node_zones;
-	if (!zone->wait_table) {
-		int ret;
+	ret = ensure_zone_is_initialized(zone, phys_start_pfn, nr_pages);
+	if (ret)
+		return ret;
 
-		ret = init_currently_empty_zone(zone, phys_start_pfn,
-						nr_pages, MEMMAP_HOTPLUG);
-		if (ret)
-			return ret;
-	}
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
 	grow_zone_span(zone, phys_start_pfn, phys_start_pfn + nr_pages);
 	grow_pgdat_span(zone->zone_pgdat, phys_start_pfn,
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
