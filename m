Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 1A6C66B0080
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 05:10:30 -0400 (EDT)
Message-ID: <52020EEE.1020005@huawei.com>
Date: Wed, 7 Aug 2013 17:10:06 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] mm: use zone_is_empty() instead of if(zone->spanned_pages)
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Use "zone_is_empty()" instead of "if (zone->spanned_pages)".
Simplify the code, no functional change.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory_hotplug.c |    6 +++---
 mm/page_alloc.c     |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2cd2207..f3fcac1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -230,7 +230,7 @@ static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
 	zone_span_writelock(zone);
 
 	old_zone_end_pfn = zone_end_pfn(zone);
-	if (!zone->spanned_pages || start_pfn < zone->zone_start_pfn)
+	if (zone_is_empty(zone) || start_pfn < zone->zone_start_pfn)
 		zone->zone_start_pfn = start_pfn;
 
 	zone->spanned_pages = max(old_zone_end_pfn, end_pfn) -
@@ -305,7 +305,7 @@ static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
 		goto out_fail;
 
 	/* use start_pfn for z1's start_pfn if z1 is empty */
-	if (z1->spanned_pages)
+	if (!zone_is_empty(z1))
 		z1_start_pfn = z1->zone_start_pfn;
 	else
 		z1_start_pfn = start_pfn;
@@ -347,7 +347,7 @@ static int __meminit move_pfn_range_right(struct zone *z1, struct zone *z2,
 		goto out_fail;
 
 	/* use end_pfn for z2's end_pfn if z2 is empty */
-	if (z2->spanned_pages)
+	if (!zone_is_empty(z2))
 		z2_end_pfn = zone_end_pfn(z2);
 	else
 		z2_end_pfn = end_pfn;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..4a82aa3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1281,7 +1281,7 @@ void mark_free_pages(struct zone *zone)
 	int order, t;
 	struct list_head *curr;
 
-	if (!zone->spanned_pages)
+	if (zone_is_empty(zone))
 		return;
 
 	spin_lock_irqsave(&zone->lock, flags);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
