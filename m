Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l7V7iZ7s015673
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 31 Aug 2007 16:44:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 984CE1B801E
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 16:44:35 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 641522DC03F
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 16:44:35 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8 [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 44D69181802B
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 16:44:35 +0900 (JST)
Received: from fjm503.ms.jp.fujitsu.com (fjm503.ms.jp.fujitsu.com [10.56.99.77])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id C7D73181802C
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 16:44:34 +0900 (JST)
Received: from fjmscan503.ms.jp.fujitsu.com (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm503.ms.jp.fujitsu.com with ESMTP id l7V7hp5e004479
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 16:43:51 +0900
Received: from GENEVIEVE ([10.124.100.187])
	by fjmscan503.ms.jp.fujitsu.com (8.13.1/8.12.11) with SMTP id l7V7hlPX029945
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 16:43:51 +0900
Date: Fri, 31 Aug 2007 16:46:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] patch for mulitiple lru in a zone [1/2] cleanup
 setup_per_zone_pages_min()
Message-Id: <20070831164611.2c29de69.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

setup_per_zone_pages_min() takes zone->lru_lock which modifing zone's 
pages_min,low,high values.
But refererer of these values seems not to take care of taking lock.

Instead of taking lock, using ordered modification of 3 values looks better.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/page_alloc.c |   20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

Index: linux-2.6.23-rc4/mm/page_alloc.c
===================================================================
--- linux-2.6.23-rc4.orig/mm/page_alloc.c
+++ linux-2.6.23-rc4/mm/page_alloc.c
@@ -3629,7 +3629,6 @@ void setup_per_zone_pages_min(void)
 	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
 	struct zone *zone;
-	unsigned long flags;
 
 	/* Calculate total number of !ZONE_HIGHMEM pages */
 	for_each_zone(zone) {
@@ -3639,8 +3638,8 @@ void setup_per_zone_pages_min(void)
 
 	for_each_zone(zone) {
 		u64 tmp;
+		unsigned long zone_pages_min;
 
-		spin_lock_irqsave(&zone->lru_lock, flags);
 		tmp = (u64)pages_min * zone->present_pages;
 		do_div(tmp, lowmem_pages);
 		if (is_highmem(zone)) {
@@ -3660,18 +3659,24 @@ void setup_per_zone_pages_min(void)
 				min_pages = SWAP_CLUSTER_MAX;
 			if (min_pages > 128)
 				min_pages = 128;
-			zone->pages_min = min_pages;
+			zone_pages_min = min_pages;
 		} else {
 			/*
 			 * If it's a lowmem zone, reserve a number of pages
 			 * proportionate to the zone's size.
 			 */
-			zone->pages_min = tmp;
+			zone_pages_min = tmp;
+		}
+		/* keep min < low < high during this change */
+		if (zone_pages_min < zone->pages_min) {
+			xchg(&zone->pages_min, zone_pages_min);
+			xchg(&zone->pages_low, zone_pages_min + (tmp >> 2));
+			xchg(&zone->pages_high, zone_pages_min + (tmp >> 1));
+		} else {
+			xchg(&zone->pages_high, zone_pages_min + (tmp >> 1));
+			xchg(&zone->pages_low, zone_pages_min + (tmp >> 2));
+			xchg(&zone->pages_min, zone_pages_min);
 		}
-
-		zone->pages_low   = zone->pages_min + (tmp >> 2);
-		zone->pages_high  = zone->pages_min + (tmp >> 1);
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
 
 	/* update totalreserve_pages */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
