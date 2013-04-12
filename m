Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 04E2A6B0036
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:24 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 21:14:23 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id B039AC9001E
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:20 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1EKPR65405148
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:20 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1EKUn029248
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:20 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 05/25] mm/memory_hotplug: use {pgdat,zone}_is_empty() when resizing zones & pgdats
Date: Thu, 11 Apr 2013 18:13:37 -0700
Message-Id: <1365729237-29711-6-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Use the *_is_empty() helpers to be more clear about what we're actually
checking for.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index df04c36..deea8c2 100644
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
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
