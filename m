Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 4C8C16B0036
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:29 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 19:14:27 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 4351B3E40042
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:12 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1EOmf082778
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:24 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1EOvn007113
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:24 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 08/25] page_alloc: in move_freepages(), skip pages instead of VM_BUG on node differences.
Date: Thu, 11 Apr 2013 18:13:40 -0700
Message-Id: <1365729237-29711-9-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

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
index 1fbf5f2..75192eb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -957,6 +957,7 @@ int move_freepages(struct zone *zone,
 	struct page *page;
 	unsigned long order;
 	int pages_moved = 0;
+	int zone_nid = zone_to_nid(zone);
 
 #ifndef CONFIG_HOLES_IN_ZONE
 	/*
@@ -970,14 +971,24 @@ int move_freepages(struct zone *zone,
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
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
