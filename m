Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 447516B005D
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:26:58 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 17:26:57 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 8AE4D19D803F
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:57 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0PvX6027732
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:57 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0Puc4012048
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:57 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 16/17] mm/memory_hotplug: use zone_end_pfn() instead of open coding
Date: Tue, 15 Jan 2013 16:24:53 -0800
Message-Id: <1358295894-24167-17-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Switch to using zone_end_pfn() in move_pfn_range_left() and
move_pfn_range_right() instead of open coding the same.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c6149a3..515b917 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -278,7 +278,7 @@ static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
 	pgdat_resize_lock(z1->zone_pgdat, &flags);
 
 	/* can't move pfns which are higher than @z2 */
-	if (end_pfn > z2->zone_start_pfn + z2->spanned_pages)
+	if (end_pfn > zone_end_pfn(z2))
 		goto out_fail;
 	/* the move out part mast at the left most of @z2 */
 	if (start_pfn > z2->zone_start_pfn)
@@ -294,7 +294,7 @@ static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
 		z1_start_pfn = start_pfn;
 
 	resize_zone(z1, z1_start_pfn, end_pfn);
-	resize_zone(z2, end_pfn, z2->zone_start_pfn + z2->spanned_pages);
+	resize_zone(z2, end_pfn, zone_end_pfn(z2));
 
 	pgdat_resize_unlock(z1->zone_pgdat, &flags);
 
@@ -323,15 +323,15 @@ static int __meminit move_pfn_range_right(struct zone *z1, struct zone *z2,
 	if (z1->zone_start_pfn > start_pfn)
 		goto out_fail;
 	/* the move out part mast at the right most of @z1 */
-	if (z1->zone_start_pfn + z1->spanned_pages >  end_pfn)
+	if (zone_end_pfn(z1) >  end_pfn)
 		goto out_fail;
 	/* must included/overlap */
-	if (start_pfn >= z1->zone_start_pfn + z1->spanned_pages)
+	if (start_pfn >= zone_end_pfn(z1))
 		goto out_fail;
 
 	/* use end_pfn for z2's end_pfn if z2 is empty */
 	if (z2->spanned_pages)
-		z2_end_pfn = z2->zone_start_pfn + z2->spanned_pages;
+		z2_end_pfn = zone_end_pfn(z2);
 	else
 		z2_end_pfn = end_pfn;
 
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
