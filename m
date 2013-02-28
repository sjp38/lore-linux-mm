Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id DB1BA6B000A
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:45:05 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 13:45:04 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 1BC7D1FF0038
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 13:40:10 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SKixk4104004
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 13:44:59 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SKixMc026554
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 13:44:59 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 08/24] mm/memory_hotplug: use {pgdat,zone}_is_empty() when resizing zones & pgdats
Date: Thu, 28 Feb 2013 12:44:16 -0800
Message-Id: <1362084272-11282-9-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <20130228024112.GA24970@negative>
 <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: David Hansen <dave@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Use the *_is_empty() helpers to be more clear about what we're actually
checking for.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9f43c80..eae4a2a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -242,7 +242,7 @@ static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
 	zone_span_writelock(zone);
 
 	old_zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	if (!zone->spanned_pages || start_pfn < zone->zone_start_pfn)
+	if (zone_is_empty(zone) || start_pfn < zone->zone_start_pfn)
 		zone->zone_start_pfn = start_pfn;
 
 	zone->spanned_pages = max(old_zone_end_pfn, end_pfn) -
@@ -383,7 +383,7 @@ static void grow_pgdat_span(struct pglist_data *pgdat, unsigned long start_pfn,
 	unsigned long old_pgdat_end_pfn =
 		pgdat->node_start_pfn + pgdat->node_spanned_pages;
 
-	if (!pgdat->node_spanned_pages || start_pfn < pgdat->node_start_pfn)
+	if (pgdat_is_empty(pgdat) || start_pfn < pgdat->node_start_pfn)
 		pgdat->node_start_pfn = start_pfn;
 
 	pgdat->node_spanned_pages = max(old_pgdat_end_pfn, end_pfn) -
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
