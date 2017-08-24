Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3847F28084A
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 03:20:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t3so32953610pgt.5
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 00:20:25 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id b1si2614833plm.462.2017.08.24.00.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 00:20:23 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id m7so2716336pga.3
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 00:20:23 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH] mm/mlock: use page_zone() instead of page_zone_id()
Date: Thu, 24 Aug 2017 16:20:11 +0900
Message-Id: <1503559211-10259-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

page_zone_id() is a specialized function to compare the zone for the pages
that are within the section range. If the section of the pages are
different, page_zone_id() can be different even if their zone is the same.
This wrong usage doesn't cause any actual problem since
__munlock_pagevec_fill() would be called again with failed index. However,
it's better to use more appropriate function here.

This patch is also preparation for futher change about page_zone_id().

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/mlock.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index b562b55..dfc6f19 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -365,8 +365,8 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
  * @start + PAGE_SIZE when no page could be added by the pte walk.
  */
 static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
-		struct vm_area_struct *vma, int zoneid,	unsigned long start,
-		unsigned long end)
+			struct vm_area_struct *vma, struct zone *zone,
+			unsigned long start, unsigned long end)
 {
 	pte_t *pte;
 	spinlock_t *ptl;
@@ -394,7 +394,7 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
 		 * Break if page could not be obtained or the page's node+zone does not
 		 * match
 		 */
-		if (!page || page_zone_id(page) != zoneid)
+		if (!page || page_zone(page) != zone)
 			break;
 
 		/*
@@ -446,7 +446,6 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		unsigned long page_increm;
 		struct pagevec pvec;
 		struct zone *zone;
-		int zoneid;
 
 		pagevec_init(&pvec, 0);
 		/*
@@ -481,7 +480,6 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 				 */
 				pagevec_add(&pvec, page);
 				zone = page_zone(page);
-				zoneid = page_zone_id(page);
 
 				/*
 				 * Try to fill the rest of pagevec using fast
@@ -490,7 +488,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 				 * pagevec.
 				 */
 				start = __munlock_pagevec_fill(&pvec, vma,
-						zoneid, start, end);
+						zone, start, end);
 				__munlock_pagevec(&pvec, zone);
 				goto next;
 			}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
