Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 068AB6B0295
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:49 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 18:01:49 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 6B69C3E40040
	for <linux-mm@kvack.org>; Thu,  2 May 2013 18:01:12 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301LP6071606
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:22 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301LS9003634
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:21 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 10/31] page_alloc: when dynamic numa is enabled, don't check that all pages in a block belong to the same zone
Date: Thu,  2 May 2013 17:00:42 -0700
Message-Id: <1367539263-19999-11-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

When dynamic numa is enabled, the last or first page in a pageblock may
have been transplanted to a new zone (or may not yet be transplanted to
a new zone).

Disable a BUG_ON() which checks that the start_page and end_page are in
the same zone, if they are not in the proper zone they will simply be
skipped.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 657f773..9de55a2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -960,13 +960,16 @@ int move_freepages(struct zone *zone,
 	int pages_moved = 0;
 	int zone_nid = zone_to_nid(zone);
 
-#ifndef CONFIG_HOLES_IN_ZONE
+#if !defined(CONFIG_HOLES_IN_ZONE) && !defined(CONFIG_DYNAMIC_NUMA)
 	/*
-	 * page_zone is not safe to call in this context when
-	 * CONFIG_HOLES_IN_ZONE is set. This bug check is probably redundant
-	 * anyway as we check zone boundaries in move_freepages_block().
-	 * Remove at a later date when no bug reports exist related to
-	 * grouping pages by mobility
+	 * With CONFIG_HOLES_IN_ZONE set, this check is unsafe as start_page or
+	 * end_page may not be "valid".
+	 * With CONFIG_DYNAMIC_NUMA set, this condition is a valid occurence &
+	 * not a bug.
+	 *
+	 * This bug check is probably redundant anyway as we check zone
+	 * boundaries in move_freepages_block().  Remove at a later date when
+	 * no bug reports exist related to grouping pages by mobility
 	 */
 	BUG_ON(page_zone(start_page) != page_zone(end_page));
 #endif
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
