Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id BB3306B0277
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:24 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 18:01:23 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id C175619D8046
	for <linux-mm@kvack.org>; Thu,  2 May 2013 18:01:15 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301Lag119564
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:21 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301KEh003538
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:21 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 09/31] page_alloc: in move_freepages(), skip pages instead of VM_BUG on node differences.
Date: Thu,  2 May 2013 17:00:41 -0700
Message-Id: <1367539263-19999-10-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

With dynamic numa, pages are going to be gradully moved from one node to
another, causing the page ranges that move_freepages() examines to
contain pages that actually belong to another node.

When dynamic numa is enabled, we skip these pages instead of VM_BUGing
out on them.

This additionally moves the VM_BUG_ON() (which detects a change in node)
so that it follows the pfn_valid_within() check.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 739b405..657f773 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -958,6 +958,7 @@ int move_freepages(struct zone *zone,
 	struct page *page;
 	unsigned long order;
 	int pages_moved = 0;
+	int zone_nid = zone_to_nid(zone);
 
 #ifndef CONFIG_HOLES_IN_ZONE
 	/*
@@ -971,14 +972,24 @@ int move_freepages(struct zone *zone,
 #endif
 
 	for (page = start_page; page <= end_page;) {
-		/* Make sure we are not inadvertently changing nodes */
-		VM_BUG_ON(page_to_nid(page) != zone_to_nid(zone));
-
 		if (!pfn_valid_within(page_to_pfn(page))) {
 			page++;
 			continue;
 		}
 
+		if (page_to_nid(page) != zone_nid) {
+#ifndef CONFIG_DYNAMIC_NUMA
+			/*
+			 * In the normal case (without Dynamic NUMA), all pages
+			 * in a pageblock should belong to the same zone (and
+			 * as a result all have the same nid).
+			 */
+			VM_BUG_ON(page_to_nid(page) != zone_nid);
+#endif
+			page++;
+			continue;
+		}
+
 		if (!PageBuddy(page)) {
 			page++;
 			continue;
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
