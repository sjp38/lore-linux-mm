Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id A847C6B000E
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 17:54:22 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 17 Jan 2013 17:54:21 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 6FA3FC9003E
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 17:54:20 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0HMsKIo18022548
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 17:54:20 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0HMsJJl004263
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 20:54:20 -0200
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 8/9] mm/memory_hotplug: use ensure_zone_is_initialized()
Date: Thu, 17 Jan 2013 14:53:00 -0800
Message-Id: <1358463181-17956-9-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Remove open coding of ensure_zone_is_initialzied().

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 29 ++++++++++-------------------
 1 file changed, 10 insertions(+), 19 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index bede456..016944f 100644
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
+	ret = ensure_zone_is_initialized(z2, start_pfn, end_pfn - start_pfn);
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
