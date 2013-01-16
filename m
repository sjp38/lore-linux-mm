Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4A18B6B0081
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:26:28 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 17:26:27 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 614CCC4000F
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:23 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0PY7t249778
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:34 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0PXWJ010900
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:34 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 01/17] mm/compaction: rename var zone_end_pfn to avoid conflicts with new function
Date: Tue, 15 Jan 2013 16:24:38 -0800
Message-Id: <1358295894-24167-2-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Patches that follow add a inline function zone_end_pfn(), which
conflicts with the naming of a local variable in isolate_freepages().

Rename the variable so it does not conflict.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/compaction.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index c62bd06..1b52528 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -644,7 +644,7 @@ static void isolate_freepages(struct zone *zone,
 				struct compact_control *cc)
 {
 	struct page *page;
-	unsigned long high_pfn, low_pfn, pfn, zone_end_pfn, end_pfn;
+	unsigned long high_pfn, low_pfn, pfn, z_end_pfn, end_pfn;
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
@@ -663,7 +663,7 @@ static void isolate_freepages(struct zone *zone,
 	 */
 	high_pfn = min(low_pfn, pfn);
 
-	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	z_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
 
 	/*
 	 * Isolate free pages until enough are available to migrate the
@@ -706,7 +706,7 @@ static void isolate_freepages(struct zone *zone,
 		 * only scans within a pageblock
 		 */
 		end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
-		end_pfn = min(end_pfn, zone_end_pfn);
+		end_pfn = min(end_pfn, z_end_pfn);
 		isolated = isolate_freepages_block(cc, pfn, end_pfn,
 						   freelist, false);
 		nr_freepages += isolated;
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
